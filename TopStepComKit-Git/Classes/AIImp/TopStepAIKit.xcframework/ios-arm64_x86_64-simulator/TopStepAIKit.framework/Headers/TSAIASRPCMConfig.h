//
//  TSAIASRPCMConfig.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Configuration for one-shot PCM speech recognition
 * @chinese 一次性 PCM 语音识别配置
 *
 * @discussion
 * [EN]: Input audio is always 16 kHz, mono, signed 16-bit little-endian PCM.
 * [CN]: 输入音频固定为 16 kHz、单声道、有符号 16 位小端 PCM。
 */
@interface TSAIASRPCMConfig : NSObject

/**
 * @brief Recognition language
 * @chinese 识别语言
 *
 * @discussion
 * [EN]: Unknown uses the current App localization. Auto is invalid.
 * [CN]: Unknown 使用当前 App 本地化语言；Auto 为非法值。
 */
@property (nonatomic, assign) TSAILanguage language;

/**
 * @brief Create a PCM recognition configuration
 * @chinese 创建 PCM 识别配置
 *
 * @param language EN: Recognition language. CN: 识别语言。
 * @return EN: A new configuration. CN: 新配置对象。
 */
+ (instancetype)configWithLanguage:(TSAILanguage)language;

@end

NS_ASSUME_NONNULL_END
