//
//  TSAIQADeviceRound.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TopStepAIKit/TopStepAIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief View model of one device-initiated question-answer round
 * @chinese 一轮设备发起问答的视图模型
 *
 * @discussion
 * [EN]: Aggregates the ordered cumulative snapshots (`TSAIDeviceQuestionAnswerEvent`)
 *       that share one `roundIdentifier`. Events with a stale `sequence` are dropped.
 * [CN]: 聚合同一 `roundIdentifier` 的有序累计快照（`TSAIDeviceQuestionAnswerEvent`），
 *       `sequence` 落后的事件会被丢弃。
 */
@interface TSAIQADeviceRound : NSObject

/**
 * @brief Globally unique round identifier
 * @chinese 全局唯一轮次标识
 */
@property (nonatomic, copy, readonly) NSString *roundIdentifier;

/**
 * @brief Public device session identifier
 * @chinese 对外设备会话标识
 */
@property (nonatomic, copy, readonly) NSString *sessionIdentifier;

/**
 * @brief 1-based display index within the session
 * @chinese 会话内从 1 开始的显示序号
 */
@property (nonatomic, assign, readonly) NSUInteger index;

/**
 * @brief Latest applied event sequence
 * @chinese 最近一次应用的事件序号
 */
@property (nonatomic, assign, readonly) NSInteger sequence;

/**
 * @brief Cumulative question text
 * @chinese 累计问题文本
 */
@property (nonatomic, copy, readonly) NSString *question;

/**
 * @brief Cumulative answer text
 * @chinese 累计答案文本
 */
@property (nonatomic, copy, readonly) NSString *answer;

/**
 * @brief Text phase reported by the SDK
 * @chinese SDK 上报的文字阶段
 */
@property (nonatomic, assign, readonly) TSAIDeviceQuestionAnswerPhase phase;

/**
 * @brief Underlying error, when failed or cancelled
 * @chinese 失败或取消时的底层错误
 */
@property (nonatomic, strong, readonly, nullable) NSError *error;

/**
 * @brief Unix time of the first event
 * @chinese 首个事件的 Unix 时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval startedAt;

/**
 * @brief Unix time of the latest applied event
 * @chinese 最近一次应用事件的 Unix 时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval updatedAt;

/**
 * @brief Create a round from its first event
 * @chinese 用首个事件创建轮次
 *
 * @param event
 * EN: First event of the round
 * CN: 该轮次的首个事件
 *
 * @param index
 * EN: 1-based display index
 * CN: 从 1 开始的显示序号
 *
 * @return
 * EN: A round that has applied the event
 * CN: 已应用该事件的轮次
 */
- (instancetype)initWithEvent:(TSAIDeviceQuestionAnswerEvent *)event index:(NSUInteger)index;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Apply one cumulative snapshot
 * @chinese 应用一条累计快照
 *
 * @param event
 * EN: Event belonging to this round
 * CN: 属于本轮次的事件
 *
 * @return
 * EN: NO when the event is stale or belongs to another round
 * CN: 事件落后或不属于本轮次时返回 NO
 */
- (BOOL)applyEvent:(TSAIDeviceQuestionAnswerEvent *)event;

/**
 * @brief Locally mark the round cancelled, e.g. after a disconnect
 * @chinese 本地标记为已取消，例如设备断连后
 *
 * @param error
 * EN: Optional reason
 * CN: 可选原因
 */
- (void)markCancelledWithError:(nullable NSError *)error;

/**
 * @brief Whether the round reached a terminal phase
 * @chinese 轮次是否已到终态阶段
 *
 * @return
 * EN: YES for completed, failed or cancelled
 * CN: 已完成、失败或已取消时返回 YES
 */
- (BOOL)isTerminal;

@end

NS_ASSUME_NONNULL_END
