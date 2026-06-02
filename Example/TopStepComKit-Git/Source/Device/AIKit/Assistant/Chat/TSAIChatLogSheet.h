//
//  TSAIChatLogSheet.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIChatContent;
@class TSAIChatEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Bottom sheet showing the dual streams (Content / Event) of a session
 * @chinese 显示一次会话双流（Content / Event）的底部弹层
 *
 * @discussion
 * [EN]: Used as a debug surface to inspect every `onContent` and `onEvent`
 *       callback delivered during a chat session. Two segmented tabs share the
 *       same scroll container; each row is rendered with monospace text plus
 *       a millisecond timestamp. Append-only — entries are never revised.
 * [CN]: 调试用弹层，逐条查看一次会话期间的 `onContent` / `onEvent` 回调。
 *       两个 segment 共享同一滚动容器，每条记录使用等宽字体并附带毫秒级时间戳。
 *       仅追加，永不修改已写入的条目。
 */
@interface TSAIChatLogSheet : UIViewController

/**
 * @brief Append a content callback record
 * @chinese 追加一条 content 回调记录
 *
 * @param content
 * EN: Snapshot of `onContent` payload to render
 * CN: 待渲染的 `onContent` 载荷快照
 */
- (void)appendContent:(TSAIChatContent *)content;

/**
 * @brief Append an event callback record
 * @chinese 追加一条 event 回调记录
 *
 * @param event
 * EN: Snapshot of `onEvent` payload to render
 * CN: 待渲染的 `onEvent` 载荷快照
 */
- (void)appendEvent:(TSAIChatEvent *)event;

/**
 * @brief Drop all log entries and refresh the visible list
 * @chinese 清空全部日志并刷新当前可见列表
 */
- (void)clearAll;

@end

NS_ASSUME_NONNULL_END
