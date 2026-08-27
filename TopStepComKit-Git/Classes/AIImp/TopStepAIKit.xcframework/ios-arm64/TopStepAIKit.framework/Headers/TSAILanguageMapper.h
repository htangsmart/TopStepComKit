//
//  TSAILanguageMapper.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>

#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Mapper between TSAILanguage and BCP-47 language codes
 * @chinese TSAILanguage 与 BCP-47 语言代码之间的映射工具
 *
 * @discussion
 * [EN]: Shared by AI modules that need BCP-47 language identifiers.
 *       `Auto` is encoded as `auto`, matching the existing provider behavior.
 * [CN]: 供需要 BCP-47 语言标识的 AI 模块共用。
 *       `Auto` 编码为 `auto`，与现有 Provider 行为保持一致。
 */
@interface TSAILanguageMapper : NSObject

/**
 * @brief Convert TSAILanguage to a BCP-47 language code
 * @chinese 将 TSAILanguage 转换为 BCP-47 语言代码
 *
 * @param language
 * EN: Unified AI language enum value
 * CN: AI 统一语言枚举值
 *
 * @return
 * EN: BCP-47 code, `auto` for Auto, or nil when no mapping exists
 * CN: BCP-47 代码，Auto 返回 `auto`，无映射时返回 nil
 */
+ (nullable NSString *)bcp47CodeForLanguage:(TSAILanguage)language;

/**
 * @brief Convert TSAILanguage to a translation target BCP-47 language code
 * @chinese 将 TSAILanguage 转换为翻译目标语言 BCP-47 代码
 *
 * @discussion
 * [EN]: Uses the target-language wire contract. Most languages share the
 *       canonical code; Russian uses `ru-RU` as target while its source code is `ru`.
 * [CN]: 遵循目标语言传输契约。大多数语言与规范码一致；俄语源语言使用 `ru`，
 *       目标语言使用 `ru-RU`。
 *
 * @param language
 * EN: Unified AI language enum value
 * CN: AI 统一语言枚举值
 *
 * @return
 * EN: Target language code, or nil when no mapping exists
 * CN: 目标语言代码，无映射时返回 nil
 */
+ (nullable NSString *)targetBcp47CodeForLanguage:(TSAILanguage)language;

/**
 * @brief Resolve a BCP-47 language code back to TSAILanguage
 * @chinese 将 BCP-47 语言代码反向解析为 TSAILanguage
 *
 * @param code
 * EN: BCP-47 code or a supported language alias. Leading/trailing whitespace,
 *     letter case, and underscore separators are normalized.
 * CN: BCP-47 代码或受支持的语言别名；会统一处理首尾空格、大小写及下划线分隔符。
 *
 * @return
 * EN: Matching language, or Unknown for nil, empty, auto, or unrecognized input
 * CN: 匹配的语言；nil、空串、auto 或无法识别时返回 Unknown
 */
+ (TSAILanguage)languageForBcp47Code:(nullable NSString *)code
    NS_SWIFT_NAME(language(forBcp47Code:));

@end

NS_ASSUME_NONNULL_END
