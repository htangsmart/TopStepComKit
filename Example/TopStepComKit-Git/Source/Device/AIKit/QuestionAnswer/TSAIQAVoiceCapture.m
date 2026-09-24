//
//  TSAIQAVoiceCapture.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQAVoiceCapture.h"

#import <TopStepComKit/TopStepComKit.h>

#import "TSAIAudioRecordAppCapture.h"

/// 16 kHz · 16bit · 单声道每秒字节数
static const NSUInteger kTSAIQAVoiceBytesPerSecond = 16000 * 2;
/// 最短有效录音（秒）
static const NSTimeInterval kTSAIQAVoiceMinimumDuration = 0.4;
/// 最长录音（秒），超出自动结束
static const NSTimeInterval kTSAIQAVoiceMaximumDuration = 60.0;

@interface TSAIQAVoiceCapture ()

// 当前状态
@property (nonatomic, assign, readwrite) TSAIQAVoiceCaptureState state;
// 麦克风采集
@property (nonatomic, strong, nullable) TSAIAudioRecordAppCapture *capture;
// 累计 PCM
@property (nonatomic, strong) NSMutableData *pcmBuffer;
// 采集开始时间
@property (nonatomic, strong, nullable) NSDate *startedAt;
// 识别任务标识
@property (nonatomic, copy, nullable) NSString *recognitionTaskId;
// 代次，用于丢弃旧任务的回调
@property (nonatomic, assign) NSUInteger generation;
// 最长录音定时器
@property (nonatomic, strong, nullable) NSTimer *maximumDurationTimer;

@end

@implementation TSAIQAVoiceCapture

#pragma mark - 生命周期

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = TSAIQAVoiceCaptureStateIdle;
        _language = TSAILanguageAuto;
        _pcmBuffer = [NSMutableData data];
    }
    return self;
}

- (void)dealloc {
    [_maximumDurationTimer invalidate];
    [_capture stop];
}

#pragma mark - 公开方法

/** 从指定麦克风开始采集 */
- (BOOL)startWithSource:(TSAIQARoundSource)source error:(NSError * _Nullable __autoreleasing *)error {
    if (self.state != TSAIQAVoiceCaptureStateIdle) {
        if (error) {
            *error = [self errorWithCode:TSAIErrorCodeBusy description:@"上一次语音提问尚未结束"];
        }
        return NO;
    }
    TSAIAudioRecordAppCaptureInput input = source == TSAIQARoundSourceHeadset
        ? TSAIAudioRecordAppCaptureInputBluetoothHeadset
        : TSAIAudioRecordAppCaptureInputPhoneMicrophone;
    if (input == TSAIAudioRecordAppCaptureInputBluetoothHeadset &&
        ![TSAIAudioRecordAppCapture isBluetoothHeadsetInputAvailable]) {
        if (error) {
            *error = [self errorWithCode:TSAIErrorCodeAudioRouteUnavailable
                             description:@"未检测到蓝牙耳机（HFP）麦克风"];
        }
        return NO;
    }

    self.generation += 1;
    NSUInteger generation = self.generation;
    [self.pcmBuffer setLength:0];
    self.capture = [[TSAIAudioRecordAppCapture alloc] init];
    __weak typeof(self) weakSelf = self;
    NSError *startError = nil;
    BOOL started = [self.capture startWithInput:input
                                     pcmHandler:^(NSData *pcmData) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || generation != strongSelf.generation) return;
        @synchronized (strongSelf.pcmBuffer) {
            [strongSelf.pcmBuffer appendData:pcmData];
        }
    }
                                   errorHandler:^(NSError *captureError) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || generation != strongSelf.generation) return;
        [strongSelf log:[NSString stringWithFormat:@"capture error: %ld %@",
                         (long)captureError.code, captureError.localizedDescription ?: @""]];
        [strongSelf failWithError:captureError];
    }
                                          error:&startError];
    if (!started) {
        self.capture = nil;
        if (error) {
            *error = startError ?: [self errorWithCode:TSAIErrorCodeTaskFailed description:@"麦克风采集启动失败"];
        }
        return NO;
    }
    self.startedAt = [NSDate date];
    self.state = TSAIQAVoiceCaptureStateListening;
    [self log:[NSString stringWithFormat:@"capture started input=%@",
               source == TSAIQARoundSourceHeadset ? @"BluetoothHeadset" : @"PhoneMicrophone"]];
    [self.delegate voiceCapture:self didChangeState:self.state];

    [self.maximumDurationTimer invalidate];
    self.maximumDurationTimer = [NSTimer scheduledTimerWithTimeInterval:kTSAIQAVoiceMaximumDuration
                                                                 repeats:NO
                                                                   block:^(NSTimer *timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || generation != strongSelf.generation ||
            strongSelf.state != TSAIQAVoiceCaptureStateListening) return;
        [strongSelf log:@"capture reached maximum duration, finishing"];
        [strongSelf finish];
    }];
    return YES;
}

/** 停止采集并识别缓冲 */
- (void)finish {
    if (self.state != TSAIQAVoiceCaptureStateListening) {
        return;
    }
    id<TSAISpeechInterface> speech = self.speech;
    [self.maximumDurationTimer invalidate];
    self.maximumDurationTimer = nil;
    [self.capture stop];
    self.capture = nil;

    NSData *pcm = nil;
    @synchronized (self.pcmBuffer) {
        pcm = [self.pcmBuffer copy];
    }
    NSTimeInterval duration = (NSTimeInterval)pcm.length / kTSAIQAVoiceBytesPerSecond;
    [self log:[NSString stringWithFormat:@"capture stopped bytes=%lu duration=%.2fs",
               (unsigned long)pcm.length, duration]];
    if (duration < kTSAIQAVoiceMinimumDuration) {
        [self failWithError:[self errorWithCode:TSAIErrorCodeInvalidParameter
                                    description:@"录音太短，请按住说完整的一句话"]];
        return;
    }
    if (!speech) {
        [self failWithError:[self errorWithCode:TSAIErrorCodeContextInactive
                                    description:@"Speech 接口不可用，无法识别问题"]];
        return;
    }

    self.state = TSAIQAVoiceCaptureStateRecognizing;
    [self.delegate voiceCapture:self didChangeState:self.state];

    NSUInteger generation = self.generation;
    __weak typeof(self) weakSelf = self;
    TSAIASRPCMConfig *config = [TSAIASRPCMConfig configWithLanguage:self.language];
    self.recognitionTaskId = [speech recognizeSpeechWithPCMData:pcm
                                                         config:config
                                                onPartialResult:^(TSAIASRPartialResult *partial) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.generation) return;
            [strongSelf.delegate voiceCapture:strongSelf didUpdatePartialText:partial.text ?: @""];
        });
    }
                                                     completion:^(TSAIASRResult * _Nullable result,
                                                                  NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.generation) return;
            strongSelf.recognitionTaskId = nil;
            if (error) {
                [strongSelf log:[NSString stringWithFormat:@"ASR failed: %@ %ld %@",
                                 error.domain, (long)error.code, error.localizedDescription ?: @""]];
                [strongSelf failWithError:error];
                return;
            }
            NSString *text = [result.text stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (text.length == 0) {
                [strongSelf failWithError:[strongSelf errorWithCode:TSAIErrorCodeTaskFailed
                                                        description:@"未识别到有效语音"]];
                return;
            }
            [strongSelf log:[NSString stringWithFormat:@"ASR done text=%@ asrDuration=%.2fs", text, result.duration]];
            strongSelf.state = TSAIQAVoiceCaptureStateIdle;
            [strongSelf.delegate voiceCapture:strongSelf didChangeState:strongSelf.state];
            [strongSelf.delegate voiceCapture:strongSelf didFinishWithText:text voiceDuration:duration error:nil];
        });
    }];
    [self log:[NSString stringWithFormat:@"recognizeSpeechWithPCMData → taskId=%@ language=%ld",
               self.recognitionTaskId ?: @"nil", (long)self.language]];
}

/** 取消采集或识别 */
- (void)cancel {
    if (self.state == TSAIQAVoiceCaptureStateIdle) {
        return;
    }
    id<TSAISpeechInterface> speech = self.speech;
    [self.maximumDurationTimer invalidate];
    self.maximumDurationTimer = nil;
    [self.capture stop];
    self.capture = nil;
    if (self.recognitionTaskId.length > 0 && speech) {
        [speech cancelRecognitionWithTaskId:self.recognitionTaskId];
        [self log:[NSString stringWithFormat:@"cancelRecognition taskId=%@", self.recognitionTaskId]];
    }
    self.recognitionTaskId = nil;
    [self failWithError:[self errorWithCode:TSAIErrorCodeCancelled description:@"已取消语音提问"]];
}

- (NSTimeInterval)capturedDuration {
    if (self.state == TSAIQAVoiceCaptureStateListening && self.startedAt) {
        return [[NSDate date] timeIntervalSinceDate:self.startedAt];
    }
    NSUInteger length = 0;
    @synchronized (self.pcmBuffer) {
        length = self.pcmBuffer.length;
    }
    return (NSTimeInterval)length / kTSAIQAVoiceBytesPerSecond;
}

#pragma mark - 私有方法

/** 以失败结束本次采集 */
- (void)failWithError:(NSError *)error {
    NSTimeInterval duration = [self capturedDuration];
    self.generation += 1;
    self.recognitionTaskId = nil;
    self.state = TSAIQAVoiceCaptureStateIdle;
    [self.delegate voiceCapture:self didChangeState:self.state];
    [self.delegate voiceCapture:self didFinishWithText:nil voiceDuration:duration error:error];
}

/** 写日志 */
- (void)log:(NSString *)line {
    TSLog(@"[TSAIQAVoiceCapture] %@", line);
    [self.delegate voiceCapture:self didAppendLog:[NSString stringWithFormat:@"[voice] %@", line]];
}

/** 构造 TSAIErrorDomain 的错误 */
- (NSError *)errorWithCode:(TSAIErrorCode)code description:(NSString *)description {
    return [NSError errorWithDomain:TSAIErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: description ?: @""}];
}

@end
