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

@class TSAIDeviceVoiceTranslationConfig;
@class TSAIAudioRouteCoordinator;
@protocol TSAISystemAudioDriver;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal coordinator for one device-initiated voice translation flow
 * @chinese 单轮设备发起语音翻译的内部编排器
 */
@interface TSAIDeviceInterpreterCoordinator : NSObject

/** App 侧 PCM 输出对象，仅弱引用 */
@property (nonatomic, weak, nullable) id<TSAIDeviceVoiceTranslationOutputSink> outputSink;

/** @brief Provider system-audio driver @chinese Provider 系统音频驱动 */
@property (nonatomic, strong, nullable) id<TSAISystemAudioDriver> systemAudioDriver;

/** @brief Shared audio-route lease coordinator @chinese 共享音频路由占用协调器 */
@property (nonatomic, strong, nullable) TSAIAudioRouteCoordinator *audioRouteCoordinator;

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

/**
 * @brief Freeze the configuration used by following device events
 * @chinese 冻结后续设备事件使用的会话配置
 * @param config EN: Per-session configuration. CN: 本次会话配置。
 * @param sessionIdentifier EN: Public session identifier. CN: 对外会话标识。
 */
- (void)prepareSessionWithConfig:(TSAIDeviceVoiceTranslationConfig *)config
               sessionIdentifier:(NSString *)sessionIdentifier;

/**
 * @brief Stop one prepared device session
 * @chinese 停止一个已准备的设备会话
 * @param sessionIdentifier EN: Public session identifier. CN: 对外会话标识。
 */
- (void)stopPreparedSessionWithIdentifier:(NSString *)sessionIdentifier;

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
