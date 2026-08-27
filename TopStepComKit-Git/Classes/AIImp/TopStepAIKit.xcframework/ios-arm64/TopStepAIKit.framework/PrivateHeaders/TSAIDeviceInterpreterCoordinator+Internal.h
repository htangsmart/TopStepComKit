//
//  TSAIDeviceInterpreterCoordinator+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

#import "TSAIDeviceBridge.h"
#import "TSAIDeviceVoiceTranslationOutputSink.h"
#import "TSAIInterpreterProvider+Internal.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal coordinator for one device-initiated voice translation flow
 * @chinese 单轮设备发起语音翻译的内部编排器
 */
@interface TSAIDeviceInterpreterCoordinator : NSObject

/** App 侧 PCM 输出对象，仅弱引用 */
@property (nonatomic, weak, nullable) id<TSAIDeviceVoiceTranslationOutputSink> outputSink;

/**
 * @brief Create a coordinator bound to one Provider and one device bridge
 * @chinese 创建绑定单个 Provider 与设备 Bridge 的编排器
 * @param interpreterProvider EN: One-shot device PCM Provider. CN: 设备整段 PCM Provider。
 * @param deviceBridge EN: Device text output bridge. CN: 设备文本下行 Bridge。
 * @return EN: A coordinator instance. CN: 编排器实例。
 */
- (instancetype)initWithInterpreterProvider:
        (id<TSAIDeviceInterpreterProvider>)interpreterProvider
                                deviceBridge:
        (id<TSAIDeviceVoiceTranslationBridge>)deviceBridge NS_DESIGNATED_INITIALIZER;

/** @brief Begin a device round @chinese 开始设备翻译轮次 */
- (void)handleDeviceVoiceTranslationDidBegin;

/**
 * @brief Handle incremental device audio
 * @chinese 处理设备增量音频
 */
- (void)handleDeviceVoiceTranslationOpusData:(nullable NSData *)opusData
                                      pcmData:(nullable NSData *)pcmData
                               sourceLanguage:(TSAILanguage)sourceLanguage
                               targetLanguage:(TSAILanguage)targetLanguage;

/**
 * @brief Handle the device capture stop event
 * @chinese 处理设备采音停止事件
 */
- (void)handleDeviceVoiceTranslationDidStopWithOpusData:(nullable NSData *)opusData
                                                 pcmData:(nullable NSData *)pcmData
                                          sourceLanguage:(TSAILanguage)sourceLanguage
                                          targetLanguage:(TSAILanguage)targetLanguage;

/** @brief Apply a device playback command @chinese 执行设备播放指令 */
- (void)handleDeviceVoiceTranslationPlaybackState:
    (TSAIDeviceVoicePlaybackState)state;

/** @brief Invalidate all active and replayable tasks @chinese 使当前及可重播任务全部失效 */
- (void)invalidate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
