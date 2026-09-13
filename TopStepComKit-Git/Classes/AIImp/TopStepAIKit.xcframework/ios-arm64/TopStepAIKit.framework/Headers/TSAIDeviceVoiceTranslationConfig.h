//
//  TSAIDeviceVoiceTranslationConfig.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIDefines.h"

@class TSAIAudioRouteConfiguration;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Configuration for one device-initiated voice-translation session
 * @chinese 单次设备发起语音翻译会话配置
 *
 * @discussion
 * [EN]: A device may omit languages on voice packets. Explicit fallback
 *       languages keep those devices usable without changing valid reports.
 * [CN]: 设备语音包可能不携带语种；显式兜底语种用于兼容此类设备，且不会覆盖有效上报。
 */
@interface TSAIDeviceVoiceTranslationConfig : NSObject <NSCopying>

/**
 * @brief Audio route used by this device-initiated session
 * @chinese 本次设备发起会话使用的音频路由
 */
@property (nonatomic, copy, nullable) TSAIAudioRouteConfiguration *audioRouteConfiguration;

/**
 * @brief Source-language fallback used when the device omits its language
 * @chinese 设备未上报语言时使用的源语言兜底值
 * @note EN: Unknown disables the fallback. CN: Unknown 表示不启用兜底。
 */
@property (nonatomic, assign) TSAILanguage fallbackSourceLanguage;

/**
 * @brief Target-language fallback used when the device omits its language
 * @chinese 设备未上报语言时使用的目标语言兜底值
 * @note EN: Unknown disables the fallback. CN: Unknown 表示不启用兜底。
 */
@property (nonatomic, assign) TSAILanguage fallbackTargetLanguage;

/**
 * @brief Create a configuration using the legacy automatic route
 * @chinese 创建使用旧版自动路由的配置
 * @return EN: A new default configuration. CN: 新的默认配置对象。
 */
+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
