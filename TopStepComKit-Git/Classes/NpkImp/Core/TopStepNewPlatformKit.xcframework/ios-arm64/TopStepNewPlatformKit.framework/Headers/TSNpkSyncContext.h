//
//  TSNpkSyncContext.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/5.
//
//  文件说明:
//  数据同步责任链的共享上下文，贯穿整条 handler 链，承载一次同步的共享状态。

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Shared context for one data-sync run passed through the handler chain
 * @chinese 一次数据同步的共享上下文，贯穿整条责任链
 */
@interface TSNpkSyncContext : NSObject

/**
 * @brief Sync configuration
 * @chinese 本次同步配置
 */
@property (nonatomic, strong) TSDataSyncConfig *config;

/**
 * @brief Request end time used to advance lastSyncTime when a type returns empty data
 * @chinese 空数据类型推进 lastSyncTime 的目标时间（所有 option 共用同一个 endTime）
 */
@property (nonatomic, assign) NSTimeInterval requestEndTime;

/**
 * @brief Per-type completion callback (invoked on main thread), may be nil
 * @chinese 单类型完成回调（主线程触发），可为 nil
 */
@property (nonatomic, copy, nullable) TSDataSyncHealthDataBlock onHealthData;

/**
 * @brief Accumulated per-type results, retained for compatibility
 * @chinese 逐类型累积的结果，为兼容既有接口予以保留
 *
 * @discussion
 * [EN]: Framework internals record and snapshot results through the thread-safe semantic methods below.
 * [CN]: 框架内部通过下方线程安全的语义方法记录并生成结果快照。
 */
@property (nonatomic, strong) NSMutableArray<TSHealthData *> *results;

/**
 * @brief Returns whether a cancel has been requested (read at type boundaries)
 * @chinese 返回是否已请求取消（在类型边界读取）
 */
@property (nonatomic, copy) BOOL (^isCancelled)(void);

/**
 * @brief Record one per-type result while this sync is active
 * @chinese 在本次同步仍活跃时记录一个分类结果
 *
 * @param result
 * EN: Per-type result to append to the final snapshot.
 * CN: 需追加到最终快照的分类结果。
 *
 * @return
 * EN: YES when the result was recorded; NO when final completion was already delivered.
 * CN: 记录成功返回 YES；最终回调已交付时返回 NO。
 */
- (BOOL)recordResultIfActive:(TSHealthData *)result;

/**
 * @brief Deliver the immutable result snapshot exactly once
 * @chinese 仅一次交付不可变的结果快照
 *
 * @param resultsHandler
 * EN: Handler invoked synchronously on the caller's queue with an immutable result snapshot.
 * CN: 在调用方队列同步执行的回调，参数为不可变结果快照。
 *
 * @return
 * EN: YES when this call delivered completion; NO when completion had already been delivered.
 * CN: 本次成功交付回调返回 YES；回调已交付时返回 NO。
 */
- (BOOL)completeOnceWithResultsHandler:(void (^)(NSArray<TSHealthData *> *results))resultsHandler;

@end

NS_ASSUME_NONNULL_END
