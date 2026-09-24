//
//  TSAIQASpeechPlayer.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQASpeechPlayer.h"

#import <AVFoundation/AVFoundation.h>
#import <TopStepComKit/TopStepComKit.h>

@interface TSAIQASpeechPlayer () <AVAudioPlayerDelegate>

// 合成任务标识
@property (nonatomic, copy, nullable) NSString *synthesisTaskId;
// Speech 接口（用于取消）
@property (nonatomic, strong, nullable) id<TSAISpeechInterface> speech;
// 播放器
@property (nonatomic, strong, nullable) AVAudioPlayer *player;
// 临时音频文件
@property (nonatomic, strong, nullable) NSURL *fileURL;
// 状态回调
@property (nonatomic, copy, nullable) void (^statusHandler)(NSString *status, BOOL finished);
// 代次
@property (nonatomic, assign) NSUInteger generation;

@end

@implementation TSAIQASpeechPlayer

#pragma mark - 生命周期

- (instancetype)init {
    self = [super init];
    if (self) {
        _speakerId = @"zh_female_tianmeitaozi_mars_bigtts";
    }
    return self;
}

- (void)dealloc {
    [self tearDownPlayer];
}

#pragma mark - 公开方法

/** 合成并播放 */
- (void)speakText:(NSString *)text
           speech:(id<TSAISpeechInterface>)speech
    statusHandler:(void (^)(NSString *, BOOL))statusHandler {
    [self stop];
    if (text.length == 0 || !speech) {
        if (statusHandler) statusHandler(@"无可播报文本", YES);
        return;
    }
    self.generation += 1;
    NSUInteger generation = self.generation;
    self.speech = speech;
    self.statusHandler = statusHandler;
    [self reportStatus:@"合成中…" finished:NO];

    __weak typeof(self) weakSelf = self;
    TSAITTSConfig *config = [TSAITTSConfig configWithSpeakerId:self.speakerId];
    self.synthesisTaskId = [speech synthesizeSpeechWithText:text
                                                     config:config
                                                 completion:^(TSAITTSResult * _Nullable result,
                                                              NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.generation) return;
            strongSelf.synthesisTaskId = nil;
            if (error) {
                [strongSelf reportStatus:[NSString stringWithFormat:@"合成失败 · %ld %@",
                                          (long)error.code, error.localizedDescription ?: @""]
                                finished:YES];
                return;
            }
            [strongSelf playResult:result];
        });
    }];
    TSLog(@"[TSAIQASpeechPlayer] synthesize taskId=%@ len=%lu speaker=%@",
          self.synthesisTaskId ?: @"nil", (unsigned long)text.length, self.speakerId);
}

/** 取消合成并停止播放 */
- (void)stop {
    self.generation += 1;
    if (self.synthesisTaskId.length > 0 && self.speech) {
        [self.speech cancelSynthesisWithTaskId:self.synthesisTaskId];
    }
    self.synthesisTaskId = nil;
    [self tearDownPlayer];
    self.statusHandler = nil;
}

- (BOOL)isBusy {
    return self.synthesisTaskId.length > 0 || self.player.isPlaying;
}

#pragma mark - 私有方法

/** 播放合成结果 */
- (void)playResult:(TSAITTSResult *)result {
    if (result.audioData.length == 0) {
        [self reportStatus:@"合成结果为空" finished:YES];
        return;
    }
    NSData *playable = nil;
    NSString *extension = nil;
    if (result.audioFormat == TSAIAudioFormatPcm) {
        NSInteger sampleRate = result.sampleRate > 0 ? result.sampleRate : 16000;
        playable = [self wrapPCMAsWav:result.audioData sampleRate:sampleRate];
        extension = @"wav";
    } else if (result.audioFormat == TSAIAudioFormatWav) {
        playable = result.audioData;
        extension = @"wav";
    } else if (result.audioFormat == TSAIAudioFormatMp3) {
        playable = result.audioData;
        extension = @"mp3";
    } else {
        [self reportStatus:[NSString stringWithFormat:@"音频格式 %ld 无法在手机直接播放", (long)result.audioFormat]
                  finished:YES];
        return;
    }
    NSString *filename = [NSString stringWithFormat:@"qa_tts_%@.%@", NSUUID.UUID.UUIDString, extension];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filename]];
    if (![playable writeToURL:fileURL options:NSDataWritingAtomic error:nil]) {
        [self reportStatus:@"写入临时音频失败" finished:YES];
        return;
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:0 error:nil];
    [session setActive:YES error:nil];

    NSError *playerError = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&playerError];
    if (!player) {
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        [self reportStatus:[NSString stringWithFormat:@"播放器创建失败 · %@", playerError.localizedDescription ?: @""]
                  finished:YES];
        return;
    }
    player.delegate = self;
    [player prepareToPlay];
    [player play];
    self.player = player;
    self.fileURL = fileURL;
    [self reportStatus:[NSString stringWithFormat:@"手机播放中 · %.1fs · %@", player.duration, self.speakerId]
              finished:NO];
}

/** 释放播放器与临时文件 */
- (void)tearDownPlayer {
    if (self.player) {
        self.player.delegate = nil;
        [self.player stop];
        self.player = nil;
    }
    if (self.fileURL) {
        [[NSFileManager defaultManager] removeItemAtURL:self.fileURL error:nil];
        self.fileURL = nil;
    }
}

/** 上报状态 */
- (void)reportStatus:(NSString *)status finished:(BOOL)finished {
    TSLog(@"[TSAIQASpeechPlayer] %@", status);
    void (^handler)(NSString *, BOOL) = self.statusHandler;
    if (handler) handler(status, finished);
    if (finished) {
        self.statusHandler = nil;
    }
}

/** 把 16bit 单声道 PCM 包成 WAV */
- (NSData *)wrapPCMAsWav:(NSData *)pcm sampleRate:(NSInteger)sampleRate {
    NSMutableData *wav = [NSMutableData dataWithCapacity:pcm.length + 44];
    uint32_t dataSize = (uint32_t)pcm.length;
    uint16_t channels = 1;
    uint16_t bitsPerSample = 16;
    uint32_t byteRate = (uint32_t)(sampleRate * channels * bitsPerSample / 8);
    uint16_t blockAlign = (uint16_t)(channels * bitsPerSample / 8);
    uint32_t chunkSize = 36 + dataSize;
    uint16_t audioFormat = 1;
    uint32_t sampleRateLE = (uint32_t)sampleRate;
    uint32_t subchunk1Size = 16;
    [wav appendBytes:"RIFF" length:4];
    [wav appendBytes:&chunkSize length:4];
    [wav appendBytes:"WAVE" length:4];
    [wav appendBytes:"fmt " length:4];
    [wav appendBytes:&subchunk1Size length:4];
    [wav appendBytes:&audioFormat length:2];
    [wav appendBytes:&channels length:2];
    [wav appendBytes:&sampleRateLE length:4];
    [wav appendBytes:&byteRate length:4];
    [wav appendBytes:&blockAlign length:2];
    [wav appendBytes:&bitsPerSample length:2];
    [wav appendBytes:"data" length:4];
    [wav appendBytes:&dataSize length:4];
    [wav appendData:pcm];
    return wav;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (player != self.player) return;
    [self tearDownPlayer];
    [self reportStatus:flag ? @"播放完成" : @"播放中断" finished:YES];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    if (player != self.player) return;
    [self tearDownPlayer];
    [self reportStatus:[NSString stringWithFormat:@"解码失败 · %@", error.localizedDescription ?: @""] finished:YES];
}

@end
