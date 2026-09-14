//
//  TSFitPreferCoordinator.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/6.
//


#import <Foundation/Foundation.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Mutation block for updating watch preferences
 * @chinese 修改手表偏好设置的 Block
 *
 * @param prefer
 * EN: Pointer to the latest preferences fetched from the watch
 * CN: 指向从手表读取到的最新偏好设置
 */
typedef void (^TSFitPreferMutationBlock)(FITCLOUDPREFER *prefer);

/**
 * @brief Completion block for fetching watch preferences
 * @chinese 查询手表偏好设置的完成回调
 */
typedef void (^TSFitPreferFetchCompletion)(BOOL succeed,
                                           FITCLOUDPREFER prefer,
                                           NSError *_Nullable error);

/**
 * @brief Completion block for updating watch preferences
 * @chinese 更新手表偏好设置的完成回调
 */
typedef void (^TSFitPreferUpdateCompletion)(BOOL succeed, NSError *_Nullable error);

/**
 * @brief Transport abstraction for watch preference commands
 * @chinese 手表偏好设置命令的传输抽象
 */
@protocol TSFitPreferTransport <NSObject>

/**
 * @brief Fetch preferences from the watch
 * @chinese 从手表查询偏好设置
 *
 * @param completion
 * EN: Completion called when the command finishes
 * CN: 命令完成时调用的回调
 */
- (void)fetchPreferWithCompletion:(TSFitPreferFetchCompletion)completion;

/**
 * @brief Set preferences on the watch
 * @chinese 设置手表偏好设置
 *
 * @param prefer
 * EN: Complete preference bitmask to set
 * CN: 要设置的完整偏好位掩码
 *
 * @param completion
 * EN: Completion called when the command finishes
 * CN: 命令完成时调用的回调
 */
- (void)setPrefer:(FITCLOUDPREFER)prefer completion:(TSFitPreferUpdateCompletion)completion;

@end

/**
 * @brief Serial coordinator for all FitCloud preference transactions
 * @chinese 所有 FitCloud 偏好设置事务的串行协调器
 *
 * @discussion
 * [EN]: Serializes the complete fetch-mutate-set transaction across modules.
 * [CN]: 跨模块串行执行完整的“查询-修改-写回”事务。
 */
@interface TSFitPreferCoordinator : NSObject

/**
 * @brief Shared coordinator for the active FitCloud connection
 * @chinese 当前 FitCloud 连接共享的协调器
 *
 * @return
 * EN: Shared coordinator instance
 * CN: 共享协调器实例
 */
+ (instancetype)sharedInstance;

/**
 * @brief Initialize with a transport and stage timeout
 * @chinese 使用传输层和阶段超时时间初始化
 *
 * @param transport
 * EN: Preference command transport
 * CN: 偏好设置命令传输层
 *
 * @param timeoutInterval
 * EN: Maximum duration of a fetch or set stage
 * CN: 单次查询或写入阶段的最大时长
 *
 * @return
 * EN: Initialized coordinator
 * CN: 初始化后的协调器
 */
- (instancetype)initWithTransport:(id<TSFitPreferTransport>)transport
                  timeoutInterval:(NSTimeInterval)timeoutInterval NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Fetch the latest preferences in transaction order
 * @chinese 按事务顺序查询最新偏好设置
 *
 * @param operationName
 * EN: Name used for diagnostics
 * CN: 用于诊断的操作名称
 *
 * @param completion
 * EN: Completion called on the main thread
 * CN: 在主线程调用的完成回调
 */
- (void)fetchPreferWithOperationName:(NSString *)operationName
                          completion:(TSFitPreferFetchCompletion)completion;

/**
 * @brief Fetch, mutate and set preferences as one serial transaction
 * @chinese 将查询、修改和写回作为一个串行事务执行
 *
 * @param operationName
 * EN: Name used for diagnostics
 * CN: 用于诊断的操作名称
 *
 * @param mutationBlock
 * EN: Block that changes only the owned preference bits
 * CN: 仅修改所属偏好位的 Block
 *
 * @param completion
 * EN: Optional completion called on the main thread
 * CN: 可选的主线程完成回调
 */
- (void)updatePreferWithOperationName:(NSString *)operationName
                        mutationBlock:(TSFitPreferMutationBlock)mutationBlock
                           completion:(nullable TSFitPreferUpdateCompletion)completion;

@end

NS_ASSUME_NONNULL_END
