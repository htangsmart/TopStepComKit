//
//  TSAIInterpreterFormatter.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TopStepAIKit/TSAIDefines.h>
#import <TopStepAIKit/TSAIInterpretationDefines.h>
#import <TopStepAIKit/TSAIInterpreterReport.h>

@class TSAIInterpretationRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Localization & naming helpers for the interpreter pages
 * @chinese 同传页面共用的本地化与命名工具
 *
 * @discussion
 * [EN]: Pure formatting helpers shared by the setup / live / report pages
 *       and the conversation page — no UI state, no SDK calls. Safe to call
 *       from any thread.
 * [CN]: 准备页 / 同传页 / 报告页与对话翻译页共用的纯格式化工具——
 *       不含 UI 状态、不调用 SDK，任意线程可用。
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
 * @brief Localized display name for a session end reason
 * @chinese 会话结束原因的本地化展示名
 *
 * @param reason
 * EN: Session-level end reason
 * CN: 会话级结束原因
 *
 * @return
 * EN: Localized text suitable for an alert body
 * CN: 适合作为弹窗正文的本地化文案
 */
+ (NSString *)displayNameForInterpretationEndReason:(TSAIInterpretationEndReason)reason;

/**
 * @brief Localized device name of a pickup ("手机" / "耳机" / "充电仓")
 * @chinese 拾音设备的本地化名称（"手机" / "耳机" / "充电仓"）
 *
 * @param pickup
 * EN: Pickup enum
 * CN: 拾音设备枚举
 *
 * @return
 * EN: Device name; empty for Unknown
 * CN: 设备名；Unknown 时为空
 */
+ (NSString *)displayNameForPickup:(TSAIInterpretationPickup)pickup;

/**
 * @brief Short playback-target name for a request ("仓端" / "耳机" / "手机")
 * @chinese 请求的播放端短名（"仓端" / "耳机" / "手机"）
 *
 * @param request
 * EN: Interpretation request; Automatic channel resolves to the pickup device
 * CN: 同传请求；Automatic 通道按拾音设备解析
 *
 * @return
 * EN: Short device name
 * CN: 设备短名
 */
+ (NSString *)playbackTargetShortNameForRequest:(TSAIInterpretationRequest *)request;

/**
 * @brief Playback description for a request ("仓端朗读" / "不朗读")
 * @chinese 请求的播放描述（"仓端朗读" / "不朗读"）
 *
 * @param request
 * EN: Interpretation request
 * CN: 同传请求
 *
 * @return
 * EN: Localized playback description
 * CN: 本地化播放描述
 */
+ (NSString *)playbackNameForRequest:(TSAIInterpretationRequest *)request;

/**
 * @brief Technical code of a pickup for logs ("phone" / "earbuds" / "case")
 * @chinese 拾音设备的技术代号（"phone" / "earbuds" / "case"），用于日志
 *
 * @param pickup
 * EN: Pickup enum
 * CN: 拾音设备枚举
 *
 * @return
 * EN: Lower-case code
 * CN: 小写代号
 */
+ (NSString *)codeForPickup:(TSAIInterpretationPickup)pickup;

/**
 * @brief Technical code of a request's playback target for logs ("case" / "none" …)
 * @chinese 请求播放端的技术代号（"case" / "none" …），用于日志
 *
 * @param request
 * EN: Interpretation request
 * CN: 同传请求
 *
 * @return
 * EN: Lower-case code
 * CN: 小写代号
 */
+ (NSString *)codeForPlaybackOfRequest:(TSAIInterpretationRequest *)request;

/**
 * @brief List of concrete (non-Auto) supported languages, in display order
 * @chinese 受支持的具体语言列表（不含 Auto），按展示顺序
 *
 * @return
 * EN: Boxed `TSAILanguage` values
 * CN: 装箱后的 `TSAILanguage` 值
 */
+ (NSArray<NSNumber *> *)concreteLanguageList __attribute__((deprecated("Use TSAIContext.interpretation.supportedLanguages")));

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
