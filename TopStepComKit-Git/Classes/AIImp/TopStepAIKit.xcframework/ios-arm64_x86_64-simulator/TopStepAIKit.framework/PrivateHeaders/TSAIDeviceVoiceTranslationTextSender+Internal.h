//
//  TSAIDeviceVoiceTranslationTextSender+Internal.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAIDeviceBridge.h"

@class TSAIInterpreterUtterance;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief How the text pushed to the device screen is assembled
 * @chinese 推送到设备屏端的文本组装方式
 */
typedef NS_ENUM(NSInteger, TSAIDeviceVoiceTranslationSnapshotMode) {
    /// @brief All utterances so far, joined in index order (bridge contract default) @chinese 按序号拼接的累计快照（Bridge 契约默认）
    TSAIDeviceVoiceTranslationSnapshotModeCumulative = 0,
    /// @brief Only the latest utterance @chinese 仅最新一句
    TSAIDeviceVoiceTranslationSnapshotModeSentence = 1,
};

/**
 * @brief Ordered, acknowledged delivery of original / translated text to the device screen
 * @chinese 面向设备屏端的有序、带 ACK 的原文 / 译文下发组件
 *
 * @discussion
 * [EN]: Shared by every path that mirrors interpretation text to the charging
 *       case. Behaviour, matching the device-initiated coordinator:
 *         - one delivery in flight at a time, on a private serial queue;
 *         - per text type a snapshot is rebuilt from utterances ordered by
 *           index; an index that reached final is frozen;
 *         - pending partials of the same type are replaced, at most
 *           `maxPendingPartials` partials wait in total; a final drops the
 *           pending partials of its type;
 *         - a snapshot identical to the last final one of its type is skipped;
 *         - each send waits `ackTimeout`; a failed final is retried up to
 *           `maxFinalAttempts`, a failed partial is dropped;
 *         - payloads longer than `maxPayloadBytes` (UTF-8) keep their tail;
 *         - nothing is sent while delivery is disabled; enabling pumps the queue.
 * [CN]: 所有把同传文本镜像到充电仓的路径共用。行为与设备发起编排器一致：
 *         - 私有串行队列，同一时刻只有一条在途；
 *         - 每种文本类型按句序号重建快照，已定稿的序号冻结；
 *         - 同类型待发 partial 被新的替换，待发 partial 总数不超过
 *           `maxPendingPartials`；final 入队时清掉同类型 partial；
 *         - 与上一次同类型 final 快照相同的内容不重发；
 *         - 每次发送等待 `ackTimeout`；final 失败最多重试 `maxFinalAttempts` 次，
 *           partial 失败直接丢弃；
 *         - UTF-8 超过 `maxPayloadBytes` 的载荷保留尾部；
 *         - 发送未启用时只累计不发送，启用后立即泵出队列。
 */
@interface TSAIDeviceVoiceTranslationTextSender : NSObject

/**
 * @brief Create a sender bound to one bridge
 * @chinese 创建绑定到指定 Bridge 的下发组件
 */
- (instancetype)initWithBridge:(id<TSAIDeviceVoiceTranslationBridge>)bridge NS_DESIGNATED_INITIALIZER;

/** @brief Snapshot assembly; default Cumulative @chinese 快照组装方式；默认累计 */
@property (atomic, assign) TSAIDeviceVoiceTranslationSnapshotMode snapshotMode;
/** @brief UTF-8 payload cap, 0 = unlimited; default 250 @chinese UTF-8 载荷上限，0 表示不限；默认 250 */
@property (atomic, assign) NSUInteger maxPayloadBytes;
/** @brief ACK wait per send; default 12 s @chinese 单次发送的 ACK 等待；默认 12 s */
@property (atomic, assign) NSTimeInterval ackTimeout;
/** @brief Attempts for a final snapshot; default 3 @chinese final 快照的最大尝试次数；默认 3 */
@property (atomic, assign) NSUInteger maxFinalAttempts;
/** @brief Pending partial cap; default 2 @chinese 待发 partial 上限；默认 2 */
@property (atomic, assign) NSUInteger maxPendingPartials;

/** @brief Whether nothing is queued or in flight @chinese 队列与在途均为空 */
@property (atomic, assign, readonly) BOOL isIdle;

/**
 * @brief Gate sending; texts accepted while disabled are queued
 * @chinese 发送开关；关闭期间接受的文本只入队不发送
 */
- (void)setDeliveryEnabled:(BOOL)enabled;

/**
 * @brief Accept one streaming text update
 * @chinese 接收一条流式文本更新
 *
 * @param text EN: Current text of the utterance (cumulative within the utterance). CN: 该句当前文本（句内累计）。
 * @param utteranceIndex EN: Utterance ordinal. CN: 句序号。
 * @param isFinal EN: Whether the utterance text is definitive. CN: 该句文本是否定稿。
 * @param textType EN: Original or translated. CN: 原文或译文。
 */
- (void)acceptText:(NSString *)text
    utteranceIndex:(NSInteger)utteranceIndex
           isFinal:(BOOL)isFinal
          textType:(TSAIDeviceVoiceTranslationTextType)textType;

/**
 * @brief Fill utterances the stream missed, from the final report
 * @chinese 用最终报告补齐流式回调漏掉的句子
 */
- (void)mergeReportUtterances:(nullable NSArray<TSAIInterpreterUtterance *> *)utterances;

/**
 * @brief Queue a final snapshot for every text type that is not final yet
 * @chinese 为尚未定稿的文本类型补发 final 快照
 */
- (void)finishOutstandingSnapshots;

/**
 * @brief Wait until idle, at most `timeout`, then call back on the main thread
 * @chinese 等待队列清空，最多 `timeout`，然后在主线程回调
 */
- (void)drainWithTimeout:(NSTimeInterval)timeout completion:(nullable dispatch_block_t)completion;

/**
 * @brief Drop everything queued, invalidate in-flight callbacks, forget snapshots
 * @chinese 丢弃队列、作废在途回调、清空快照
 */
- (void)reset;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
