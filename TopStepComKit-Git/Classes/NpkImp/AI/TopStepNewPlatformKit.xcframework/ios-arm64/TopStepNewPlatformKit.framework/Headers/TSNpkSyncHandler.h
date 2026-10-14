//
//  TSNpkSyncHandler.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/5.
//
//  文件说明:
//  数据同步责任链的节点基类。一个 handler 负责一种数据类型的
//  「拉取 → 入库 → 查库 → 回调 → 推进锚点」闭环，全异步、无信号量阻塞。
//  同构类型（Npk 9 类）通过属性参数化复用本基类；异构类型（如 Fw 的 HR/DailyActivity）
//  由子类重写对应步骤。

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>
#import "TSNpkSyncContext.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief A single node in the data-sync responsibility chain
 * @chinese 数据同步责任链的单个节点
 */
@interface TSNpkSyncHandler : NSObject

/**
 * @brief The data type this handler syncs
 * @chinese 此 handler 负责同步的数据类型
 */
@property (nonatomic, assign, readonly) TSDataSyncOption option;

/**
 * @brief Device fetch class (BleMetaKit layer, subclass of TSMetaBaseDataSync)
 * @chinese 设备拉取类（BleMetaKit 层，TSMetaBaseDataSync 子类）
 */
@property (nonatomic, assign, readonly, nullable) Class metaClass;

/**
 * @brief Store class for insert/query (Npk layer, subclass of TSNpkBaseDataSync)
 * @chinese 入库/查库类（Npk 层，TSNpkBaseDataSync 子类）
 */
@property (nonatomic, assign, readonly, nullable) Class storeClass;

/**
 * @brief Whether this type is actually supported (unsupported types skip fetch and return notSupport)
 * @chinese 该类型是否真正支持（不支持则跳过拉取、直接回 notSupport，锚点不动）
 */
@property (nonatomic, assign, readonly) BOOL isSupported;

/**
 * @brief Create a handler for one data type
 * @chinese 创建某一数据类型的 handler
 */
- (instancetype)initWithOption:(TSDataSyncOption)option
                     metaClass:(nullable Class)metaClass
                    storeClass:(nullable Class)storeClass
                   isSupported:(BOOL)isSupported;

/**
 * @brief Run this node, then invoke next to drive the following node
 * @chinese 执行本节点，完成后调用 next 驱动下一个节点
 *
 * @param context
 * [EN]: Shared context carrying config, callbacks and accumulated results.
 * [CN]: 携带配置、回调与累积结果的共享上下文。
 * @param next
 * [EN]: Continuation to advance the chain. Must be called exactly once when this node finishes.
 * [CN]: 驱动链条前进的续延。节点结束时必须且仅调用一次。
 */
- (void)handleWithContext:(TSNpkSyncContext *)context next:(void (^)(void))next;

@end

NS_ASSUME_NONNULL_END
