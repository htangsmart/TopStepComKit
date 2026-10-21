//
//  TSAIChatPCMPlayer.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatPCMPlayer.h"

#import <AVFoundation/AVFoundation.h>

#import "TSAIAudioSessionIdleWaiter.h"

@interface TSAIChatPCMPlayer ()

// 音频引擎
@property (nonatomic, strong, nullable) AVAudioEngine *engine;
// 播放节点
@property (nonatomic, strong, nullable) AVAudioPlayerNode *playerNode;
// 播放代次，用于忽略过期回调
@property (nonatomic, assign) NSUInteger generation;
// 完成回调
@property (nonatomic, copy, nullable) void (^completion)(void);
// 是否播放中
@property (nonatomic, assign, readwrite) BOOL isPlaying;
// 等待 SDK 拆完音频会话（会话刚结束时）
@property (nonatomic, strong, nullable) TSAIAudioSessionIdleWaiter *idleWaiter;

@end

@implementation TSAIChatPCMPlayer

#pragma mark - 公开方法

- (BOOL)playPCM:(NSData *)pcmData completion:(void (^)(void))completion {
    [self stop];
    if (pcmData.length < 2) return NO;

    AVAudioFormat *format = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
                                                             sampleRate:16000
                                                               channels:1
                                                            interleaved:YES];
    AVAudioFrameCount frameCount = (AVAudioFrameCount)(pcmData.length / 2);
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:frameCount];
    if (!buffer) return NO;
    buffer.frameLength = frameCount;
    memcpy(buffer.int16ChannelData[0], pcmData.bytes, frameCount * 2);

    if ([TSAIAudioSessionIdleWaiter isAudioSessionIdle]) {
        return [self startPlaybackWithBuffer:buffer completion:completion];
    }
    // SDK 还在拆除刚结束的会话：等它用完音频会话再配置，避免拆除里的反激活把这次播放停掉
    self.generation += 1;
    NSUInteger generation = self.generation;
    self.completion = completion;
    self.isPlaying = YES;
    __weak typeof(self) weakSelf = self;
    self.idleWaiter = [TSAIAudioSessionIdleWaiter waitForIdleWithLabel:@"TSAIChatPCMPlayer" handler:^(BOOL timedOut) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || strongSelf.generation != generation) return;
        strongSelf.idleWaiter = nil;
        void (^pendingCompletion)(void) = strongSelf.completion;
        strongSelf.completion = nil;
        strongSelf.isPlaying = NO;
        if (![strongSelf startPlaybackWithBuffer:buffer completion:pendingCompletion]) {
            if (pendingCompletion) pendingCompletion();
        }
    }];
    return YES;
}

- (void)stop {
    if (!self.isPlaying) return;
    self.generation += 1;
    [self.idleWaiter cancel];
    self.idleWaiter = nil;
    [self finish];
}

#pragma mark - 私有方法

/// 配置会话、启动引擎并播放；引擎启动失败返回 NO（不回调）
- (BOOL)startPlaybackWithBuffer:(AVAudioPCMBuffer *)buffer completion:(nullable void (^)(void))completion {
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:0 error:&error];
    [session setActive:YES error:&error];

    AVAudioEngine *engine = [[AVAudioEngine alloc] init];
    AVAudioPlayerNode *node = [[AVAudioPlayerNode alloc] init];
    [engine attachNode:node];
    [engine connect:node to:engine.mainMixerNode format:buffer.format];
    if (![engine startAndReturnError:&error]) {
        return NO;
    }
    self.engine = engine;
    self.playerNode = node;
    self.completion = completion;
    self.isPlaying = YES;
    self.generation += 1;
    NSUInteger generation = self.generation;

    __weak typeof(self) weakSelf = self;
    [node scheduleBuffer:buffer completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || strongSelf.generation != generation) return;
            [strongSelf finish];
        });
    }];
    [node play];
    return YES;
}

/// 停引擎并回调
- (void)finish {
    [self.playerNode stop];
    [self.engine stop];
    self.playerNode = nil;
    self.engine = nil;
    self.isPlaying = NO;
    void (^completion)(void) = self.completion;
    self.completion = nil;
    if (completion) completion();
}

@end
