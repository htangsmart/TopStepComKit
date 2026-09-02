//
//  TSFwSyncHandler.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//
//  文件说明:
//  Fw 数据同步责任链的节点基类。一个 handler 负责一种数据类型的
//  「拉取 → 入库 → 查库 → 回调 → 推进锚点」闭环，全异步、无信号量阻塞。
//  同构类型（普通 5 类）通过属性参数化复用本基类；异构类型（HR 静息、DailyActivity 今日）
//  由子类重写对应步骤。
//
//  与 Npk 版差异：Fw 的拉取/入库/查库都在同一个 TSFw*DataSync 类上（无 meta/store 之分），
//  故只持有单个 syncClass；拉取回调直接返回 TSHealthValueModel 数组 + error。

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import "TSFwSyncContext.h"
#import "TSFwHealthData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief A single node in the Fw data-sync responsibility chain
 * @chinese Fw 数据同步责任链的单个节点
 */
@interface TSFwSyncHandler : NSObject

/**
 * @brief The data type this handler syncs
 * @chinese 此 handler 负责同步的数据类型
 */
@property (nonatomic, assign, readonly) TSDataSyncOption option;

/**
 * @brief Sync class handling fetch/insert/query for this type (subclass of TSFwBaseDataSync)
 * @chinese 负责该类型拉取/入库/查库的类（TSFwBaseDataSync 子类）
 */
@property (nonatomic, assign, readonly, nullable) Class syncClass;

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
                     syncClass:(nullable Class)syncClass
                   isSupported:(BOOL)isSupported;

/**
 * @brief Run this node, then invoke next to drive the following node
 * @chinese 执行本节点，完成后调用 next 驱动下一个节点
 */
- (void)handleWithContext:(TSFwSyncContext *)context next:(void (^)(void))next;

@end

NS_ASSUME_NONNULL_END
