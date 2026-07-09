//
//  TSAIAudioPlayer.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Streaming audio player for AI test screens (skeleton)
 * @chinese AI 测试页用的流式音频播放器（骨架）
 *
 * @discussion
 * [EN]: Sink for AI streaming audio output. Test VCs feed PCM / Opus chunks as
 *       they arrive via TTS / Chat / Interpreter content callbacks; the player
 *       handles decoding, queueing and playback. Not implemented yet — only
 *       the public surface is fixed in this skeleton.
 * [CN]: AI 流式音频输出的播放收口。测试 VC 在 TTS / Chat / Interpreter
 *       content 回调里把 PCM / Opus 分片喂进来，播放器负责解码、排队、播放。
 *       本骨架仅锁定对外接口，实现后续填充。
 */
@interface TSAIAudioPlayer : NSObject

/**
 * @brief Append a 16kHz mono 16-bit PCM chunk to the playback queue
 * @chinese 追加一段 16kHz 单声道 16bit PCM 音频片段
 */
- (void)appendPCM:(NSData *)pcmData;

/**
 * @brief Append an Opus-encoded chunk; the player decodes internally
 * @chinese 追加一段 Opus 编码音频片段，内部解码后播放
 */
- (void)appendOpus:(NSData *)opusData;

/**
 * @brief Stop playback and drop any queued audio
 * @chinese 停止播放并丢弃所有排队中的音频
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
