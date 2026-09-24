//
//  TSAIQASpeechPlayer.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TopStepAIKit/TopStepAIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Speak an answer on the phone: `synthesizeSpeechWithText:` → AVAudioPlayer
 * @chinese 在手机上播报答案：`synthesizeSpeechWithText:` → AVAudioPlayer
 *
 * @discussion
 * [EN]: Used by the phone / headset pickup modes, where no device route exists. PCM
 *       results are wrapped as WAV; Opus results cannot be played and are reported.
 * [CN]: 用于手机 / 耳机拾音模式（没有设备路由）。PCM 结果包成 WAV 播放；Opus 结果无法
 *       直接播放，只上报状态。
 */
@interface TSAIQASpeechPlayer : NSObject

/**
 * @brief Speaker used for synthesis
 * @chinese 合成使用的音色
 */
@property (nonatomic, copy) NSString *speakerId;

/**
 * @brief Whether synthesis or playback is in flight
 * @chinese 是否正在合成或播放
 */
@property (nonatomic, assign, readonly) BOOL isBusy;

/**
 * @brief Synthesize and play one text
 * @chinese 合成并播放一段文本
 *
 * @param text EN: Answer text. CN: 答案文本。
 * @param speech EN: Speech interface. CN: Speech 接口。
 * @param statusHandler EN: Main-thread status text for the UI; called several times, last one is terminal. CN: 主线程状态文本，多次回调，最后一次为终态。
 */
- (void)speakText:(NSString *)text
           speech:(id<TSAISpeechInterface>)speech
    statusHandler:(void (^)(NSString *status, BOOL finished))statusHandler;

/**
 * @brief Cancel synthesis and stop playback
 * @chinese 取消合成并停止播放
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
