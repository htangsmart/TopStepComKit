//
//  TSAIDeviceVoiceTranslationConfig.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

@class TSAIAudioRouteConfiguration;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Configuration for one device-initiated voice-translation session
 * @chinese 单次设备发起语音翻译会话配置
 *
 * @discussion
 * [EN]: Languages are reported by the device for every utterance. This model
 *       therefore owns only App-selected session behavior.
 * [CN]: 语种由设备在每轮语音中上报，因此本模型只承载 App 选择的会话行为。
 */
@interface TSAIDeviceVoiceTranslationConfig : NSObject <NSCopying>

/**
 * @brief Audio route used by this device-initiated session
 * @chinese 本次设备发起会话使用的音频路由
 */
@property (nonatomic, copy, nullable) TSAIAudioRouteConfiguration *audioRouteConfiguration;

/**
 * @brief Create a configuration using the legacy automatic route
 * @chinese 创建使用旧版自动路由的配置
 * @return EN: A new default configuration. CN: 新的默认配置对象。
 */
+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
