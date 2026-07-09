//
//  TSAIAudioPlayer.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIAudioPlayer.h"

@implementation TSAIAudioPlayer

#pragma mark - 公开方法

/// 追加 PCM 片段（待实现：使用 AVAudioEngine 或 AudioQueue 播放）
- (void)appendPCM:(NSData *)pcmData {
    // TODO: 接入 AVAudioEngine 实时播放 16kHz 单声道 16bit PCM
}

/// 追加 Opus 片段（待实现：先解码为 PCM，再排队播放）
- (void)appendOpus:(NSData *)opusData {
    // TODO: 用 libopus 解码后转 appendPCM:
}

/// 停止播放（待实现：停止引擎并清空队列）
- (void)stop {
    // TODO: 停止 AudioEngine 并清空已排队片段
}

@end
