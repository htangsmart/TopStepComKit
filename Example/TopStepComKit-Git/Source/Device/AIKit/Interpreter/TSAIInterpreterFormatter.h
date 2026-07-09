//
//  TSAIInterpreterFormatter.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"
#import "TSAIInterpreterReport.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Localization & ID-shortening helpers for the interpreter test page
 * @chinese 同传测试页用的本地化与 taskId 短码工具
 *
 * @discussion
 * [EN]: Pulled out of `TSAIInterpreterVC.m` to keep the VC under the project's
 *       800-line per-file budget. Holds purely formatting helpers — no UI
 *       state, no SDK calls. Safe to call from any thread.
 * [CN]: 从 `TSAIInterpreterVC.m` 拆出，避免主 VC 超过项目单文件 800 行限制。
 *       只承载格式化工具——不含 UI 状态、不调用 SDK，任意线程可用。
 */
@interface TSAIInterpreterFormatter : NSObject

/**
 * @brief Localized display name for a language enum
 * @chinese 语言枚举的本地化展示名
 *
 * @param language
 * EN: Language enum (Auto / Unknown / concrete)
 * CN: 语言枚举（Auto / Unknown / 具体语言）
 *
 * @return
 * EN: Localized display name; for Unknown returns the "Required" placeholder
 * CN: 本地化展示名；Unknown 时返回"待选择"占位
 */
+ (NSString *)displayNameForLanguage:(TSAILanguage)language;

/**
 * @brief Localized display name for an end-reason enum
 * @chinese EndReason 枚举的本地化展示名
 *
 * @param reason
 * EN: End-reason enum
 * CN: EndReason 枚举
 *
 * @return
 * EN: Localized display name; for Unknown returns the generic Unknown string
 * CN: 本地化展示名；Unknown 时返回通用 Unknown 文案
 */
+ (NSString *)displayNameForEndReason:(TSAIInterpreterEndReason)reason;

/**
 * @brief List of concrete (non-Auto) supported languages, in display order
 * @chinese 受支持的具体语言列表（不含 Auto），按展示顺序
 *
 * @return
 * EN: Boxed `TSAILanguage` values
 * CN: 装箱后的 `TSAILanguage` 值
 */
+ (NSArray<NSNumber *> *)concreteLanguageList;

/**
 * @brief Shorten a UUID-style taskId for log display
 * @chinese 将 UUID 风格 taskId 截短便于日志展示
 *
 * @param taskId
 * EN: Original taskId, length 8 or shorter is returned as-is
 * CN: 原始 taskId，长度 ≤8 时原样返回
 *
 * @return
 * EN: First 4 + ellipsis + last 4 chars; nil-safe (returns empty string)
 * CN: 前 4 字符 + 省略号 + 后 4 字符；nil 安全（返回空字符串）
 */
+ (NSString *)shortIdForTaskId:(nullable NSString *)taskId;

@end

NS_ASSUME_NONNULL_END
