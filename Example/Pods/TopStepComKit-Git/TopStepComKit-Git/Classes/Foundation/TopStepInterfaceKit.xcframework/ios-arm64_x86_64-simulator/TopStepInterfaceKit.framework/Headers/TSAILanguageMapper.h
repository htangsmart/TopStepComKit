//
//  TSAILanguageMapper.h
//  TopStepInterfaceKit
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
 * [EN]: Shared by all TSAIKit sub-modules (Translate / ASR / Interpret /
 *       Summary ...) that need to feed an underlying AI SDK with hyphenated
 *       BCP-47 language identifiers (e.g. `zh-CN`, `en-US`).
 *
 *       `Auto` is encoded as an empty string `""` — this is the de-facto
 *       convention shared by current backing SDKs (AIBudsAI, etc.) where an
 *       empty source-language string requests backend auto-detection.
 *       Whether `Auto` is semantically valid in the current call site is
 *       the caller's responsibility (e.g. translate `targetLanguage` must
 *       reject `Auto` before calling here).
 *
 * [CN]: TSAIKit 各子模块（翻译 / ASR / 同传 / 摘要 ...）共用的语言代码映射，
 *       面向需要把 BCP-47（如 `zh-CN`、`en-US`）传给底层 AI SDK 的场景。
 *
 *       `Auto` 编码为空字符串 `""`，这是当前底层 SDK（AIBudsAI 等）的
 *       事实约定 —— 源语言传空串即表示请求自动检测。`Auto` 在当前调用
 *       语义下是否合法由调用方负责（例如翻译的 `targetLanguage` 必须在
 *       调用前拒绝 `Auto`）。
 */
@interface TSAILanguageMapper : NSObject

/**
 * @brief Convert TSAILanguage to a BCP-47 language code
 * @chinese 将 TSAILanguage 转换为 BCP-47 语言代码
 *
 * @param language
 * EN: TSAIKit unified language enum value
 * CN: TSAIKit 统一语言枚举值
 *
 * @return
 * EN: BCP-47 code (e.g. `zh-CN`); empty string `""` for `Auto`
 *     (auto-detect convention); `nil` for `Unknown` or any value that has
 *     no BCP-47 mapping. Caller should treat `nil` as a not-supported
 *     error.
 * CN: BCP-47 代码（如 `zh-CN`）；`Auto` 返回空字符串 `""`
 *     （自动检测约定）；`Unknown` 及无 BCP-47 映射的取值返回 `nil`，
 *     调用方应将 `nil` 视为 not-support 错误。
 */
+ (nullable NSString *)bcp47CodeForLanguage:(TSAILanguage)language;

/**
 * @brief Resolve a BCP-47 language code back to TSAILanguage
 * @chinese 将 BCP-47 语言代码反向解析为 TSAILanguage
 *
 * @param code
 * EN: BCP-47 code returned by an underlying AI SDK, case-insensitive
 *     (e.g. `zh-CN` / `EN-US`)
 * CN: 底层 AI SDK 返回的 BCP-47 代码，大小写不敏感
 *     （如 `zh-CN` / `EN-US`）
 *
 * @return
 * EN: Matching `TSAILanguage`. Returns `TSAILanguageUnknown` for nil, empty
 *     or unrecognized input. Never returns `TSAILanguageAuto` — `Auto` is a
 *     request-side concept, never a resolved result.
 * CN: 匹配的 `TSAILanguage`。nil、空串、无法识别时返回 `TSAILanguageUnknown`。
 *     永远不会返回 `TSAILanguageAuto`——Auto 仅在请求侧使用，
 *     解析结果中不会出现。
 */
+ (TSAILanguage)languageForBcp47Code:(nullable NSString *)code;

@end

NS_ASSUME_NONNULL_END
