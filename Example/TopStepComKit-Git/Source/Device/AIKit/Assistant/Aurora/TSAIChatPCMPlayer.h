//
//  TSAIChatPCMPlayer.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One-shot player for cached 16kHz mono 16-bit PCM (context-menu 「播放」)
 * @chinese 播放缓存的 16kHz 单声道 16bit PCM（长按菜单「播放」）
 */
@interface TSAIChatPCMPlayer : NSObject

/** @brief Whether playing @chinese 是否播放中 */
@property (nonatomic, assign, readonly) BOOL isPlaying;

/**
 * @brief Play a PCM buffer from the start; stops any current playback
 * @chinese 从头播放一段 PCM；会先停止当前播放
 * @param pcmData EN: 16k mono int16 PCM. CN: 16k 单声道 int16 PCM。
 * @param completion EN: Called on the main thread when finished or stopped. CN: 结束或停止后主线程回调。
 * @return EN: NO when the buffer is empty or the engine failed. CN: 数据为空或引擎失败时返回 NO。
 */
- (BOOL)playPCM:(NSData *)pcmData completion:(nullable void (^)(void))completion;

/** @brief Stop @chinese 停止 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
