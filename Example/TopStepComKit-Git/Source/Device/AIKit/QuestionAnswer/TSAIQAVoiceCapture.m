//
//  TSAIQAVoiceCapture.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQAVoiceCapture.h"

#import <TopStepComKit/TopStepComKit.h>

/// 最长录音（秒），到时 SDK 自动结束并识别
static const NSTimeInterval kTSAIQAVoiceMaximumDuration = 60.0;

@interface TSAIQAVoiceCapture ()

// 当前状态
@property (nonatomic, assign, readwrite) TSAIQAVoiceCaptureState state;
// SDK 麦克风识别的当前状态
@property (nonatomic, assign, readwrite) TSAIASRMicrophoneState microphoneState;
// 开始录音（Ready）时间；Ready 之前为 nil
@property (nonatomic, strong, nullable) NSDate *startedAt;
// 停止录音时已录的秒数
@property (nonatomic, assign) NSTimeInterval finishedDuration;
// SDK 识别任务标识
@property (nonatomic, copy, nullable) NSString *recognitionTaskId;
// 代次，用于丢弃旧任务的回调
@property (nonatomic, assign) NSUInteger generation;

@end

@implementation TSAIQAVoiceCapture

#pragma mark - 生命周期

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = TSAIQAVoiceCaptureStateIdle;
        _language = TSAILanguageAuto;
    }
    return self;
}

- (void)dealloc {
    if (_recognitionTaskId.length > 0) {
        [_speech cancelRecognitionWithTaskId:_recognitionTaskId];
    }
}

#pragma mark - 公开方法

/** 用 SDK 麦克风识别开始拾音：手机麦或耳机麦都由 SDK 采集，停止后整段识别 */
- (BOOL)startWithSource:(TSAIQARoundSource)source error:(NSError * _Nullable __autoreleasing *)error {
    if (self.state != TSAIQAVoiceCaptureStateIdle) {
        if (error) {
            *error = [self errorWithCode:TSAIErrorCodeBusy description:@"上一次语音提问尚未结束"];
        }
        return NO;
    }
    id<TSAISpeechInterface> speech = self.speech;
    if (speech == nil) {
        if (error) {
            *error = [self errorWithCode:TSAIErrorCodeContextInactive description:@"Speech 接口不可用，无法识别问题"];
        }
        return NO;
    }
    TSAIAudioInputChannel channel = source == TSAIQARoundSourceHeadset
        ? TSAIAudioInputChannelSCO
        : TSAIAudioInputChannelBuiltInMic;
    TSAIASRMicrophoneConfig *config = [TSAIASRMicrophoneConfig configWithAudioInputChannel:channel
                                                                                   language:self.language];
    config.maximumDuration = kTSAIQAVoiceMaximumDuration;

    self.generation += 1;
    NSUInteger generation = self.generation;
    self.startedAt = nil;
    self.finishedDuration = 0;
    self.microphoneState = TSAIASRMicrophoneStateConnecting;
    self.state = TSAIQAVoiceCaptureStateListening;
    __weak typeof(self) weakSelf = self;
    self.recognitionTaskId = [speech recognizeSpeechWithMicrophoneConfig:config
                                                           onStateChange:^(NSString *taskId, TSAIASRMicrophoneState state) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || generation != strongSelf.generation) return;
        [strongSelf handleMicrophoneState:state];
    }
                                                              completion:^(TSAIASRResult * _Nullable result,
                                                                           NSError * _Nullable recognitionError) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || generation != strongSelf.generation) return;
        [strongSelf handleResult:result error:recognitionError];
    }];
    [self log:[NSString stringWithFormat:@"recognizeSpeechWithMicrophoneConfig → taskId=%@ input=%@ language=%ld",
               self.recognitionTaskId ?: @"nil",
               source == TSAIQARoundSourceHeadset ? @"SCO" : @"BuiltInMic", (long)self.language]];
    // 回调可能已同步失败并回到空闲
    if (generation != self.generation) {
        return YES;
    }
    [self.delegate voiceCapture:self didChangeState:self.state];
    return YES;
}

/** 停止录音并识别：SDK 结束录音后整段识别；Ready 之前停止按「录音太短」处理 */
- (void)finish {
    if (self.state != TSAIQAVoiceCaptureStateListening || self.recognitionTaskId.length == 0) {
        return;
    }
    self.finishedDuration = [self capturedDuration];
    [self log:[NSString stringWithFormat:@"stopMicrophoneRecognition duration=%.2fs", self.finishedDuration]];
    [self.speech stopMicrophoneRecognitionWithTaskId:self.recognitionTaskId];
}

/** 取消采集或识别 */
- (void)cancel {
    if (self.state == TSAIQAVoiceCaptureStateIdle) {
        return;
    }
    id<TSAISpeechInterface> speech = self.speech;
    if (self.recognitionTaskId.length > 0 && speech) {
        [speech cancelRecognitionWithTaskId:self.recognitionTaskId];
        [self log:[NSString stringWithFormat:@"cancelRecognition taskId=%@", self.recognitionTaskId]];
    }
    self.recognitionTaskId = nil;
    [self failWithError:[self errorWithCode:TSAIErrorCodeCancelled description:@"已取消语音提问"]];
}

- (NSTimeInterval)capturedDuration {
    if (self.state == TSAIQAVoiceCaptureStateListening && self.startedAt) {
        return MIN([[NSDate date] timeIntervalSinceDate:self.startedAt], kTSAIQAVoiceMaximumDuration);
    }
    return self.finishedDuration;
}

- (BOOL)isWaitingForMicrophone {
    return self.state == TSAIQAVoiceCaptureStateListening &&
        (self.microphoneState == TSAIASRMicrophoneStateConnecting ||
         self.microphoneState == TSAIASRMicrophoneStateRecovering);
}

#pragma mark - 私有方法

/** SDK 状态：Connecting → Ready（开始计时）→ [Recovering → Ready] → Recognizing */
- (void)handleMicrophoneState:(TSAIASRMicrophoneState)state {
    self.microphoneState = state;
    switch (state) {
        case TSAIASRMicrophoneStateConnecting:
            [self log:@"microphone connecting"];
            break;
        case TSAIASRMicrophoneStateReady:
            if (self.startedAt == nil) {
                self.startedAt = [NSDate date];
            }
            [self log:@"microphone ready, speak now"];
            break;
        case TSAIASRMicrophoneStateRecovering:
            [self log:@"earbuds left, waiting for them"];
            break;
        case TSAIASRMicrophoneStateRecognizing:
            if (self.finishedDuration <= 0) {
                // 到达最长时长由 SDK 自动停止
                self.finishedDuration = [self capturedDuration];
            }
            self.state = TSAIQAVoiceCaptureStateRecognizing;
            [self log:@"recording stopped, recognizing"];
            break;
    }
    [self.delegate voiceCapture:self didChangeState:self.state];
}

/** 识别结束：成功交回文本；太短、取消、耳机错误交回错误 */
- (void)handleResult:(nullable TSAIASRResult *)result error:(nullable NSError *)error {
    self.recognitionTaskId = nil;
    if (error) {
        [self log:[NSString stringWithFormat:@"ASR failed: %@ %ld %@",
                   error.domain, (long)error.code, error.localizedDescription ?: @""]];
        BOOL tooShort = [error.domain isEqualToString:TSAIErrorDomain] &&
            error.code == TSAIErrorCodeCancelled &&
            [error.userInfo[TSAIErrorUserInfoCancellationReasonKey] isEqual:TSAICancellationReasonTooShort];
        [self failWithError:tooShort
            ? [self errorWithCode:TSAIErrorCodeInvalidParameter description:@"录音太短，请说完整的一句话"]
            : error];
        return;
    }
    NSString *text = [result.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        [self failWithError:[self errorWithCode:TSAIErrorCodeTaskFailed description:@"未识别到有效语音"]];
        return;
    }
    NSTimeInterval duration = [self capturedDuration];
    [self log:[NSString stringWithFormat:@"ASR done text=%@ asrDuration=%.2fs", text, result.duration]];
    self.generation += 1;
    self.state = TSAIQAVoiceCaptureStateIdle;
    [self.delegate voiceCapture:self didChangeState:self.state];
    [self.delegate voiceCapture:self didFinishWithText:text voiceDuration:duration error:nil];
}

/** 以失败结束本次采集 */
- (void)failWithError:(NSError *)error {
    NSTimeInterval duration = [self capturedDuration];
    self.finishedDuration = duration;
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
