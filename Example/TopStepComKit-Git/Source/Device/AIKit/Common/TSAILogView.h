//
//  TSAILogView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Append-only scrolling log view for AI test screens
 * @chinese AI 测试页用的只追加滚动日志视图
 *
 * @discussion
 * [EN]: Lightweight wrapper around UITextView used by every AIKit test VC to
 *       dump session events, content callbacks, errors and any debugging text.
 *       Each appended line is automatically prefixed with HH:mm:ss.SSS and the
 *       view auto-scrolls to the bottom.
 * [CN]: 基于 UITextView 的轻量封装，供每个 AIKit 测试 VC 输出会话事件、
 *       content 回调、错误及任意调试文本。每行自动加 HH:mm:ss.SSS 前缀，
 *       自动滚动到底部。
 */
@interface TSAILogView : UIView

/**
 * @brief Append a single log line; thread-safe, marshals to main queue
 * @chinese 追加一行日志，线程安全，内部切回主线程
 *
 * @param line
 * EN: Log content; nil and empty lines are ignored
 * CN: 日志内容，nil 与空行忽略
 */
- (void)appendLine:(nullable NSString *)line;

/**
 * @brief Append a formatted log line
 * @chinese 追加一行格式化日志
 *
 * @param format
 * EN: printf-style format string
 * CN: printf 风格格式化字符串
 */
- (void)appendLineWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

/**
 * @brief Clear all log content
 * @chinese 清空全部日志内容
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END
