//
//  TSWorldClockInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/22.
//

#import "TSKitBaseInterface.h"
#import "TSWorldClockModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Protocol for managing world clock functionality
 * @chinese 世界时钟功能管理协议
 *
 * @discussion
 * [EN]: This protocol defines the interface for managing world clocks in the device.
 * It provides methods for setting, querying, and deleting world clock data.
 * [CN]: 该协议定义了设备中世界时钟管理的接口。
 * 提供了设置、查询和删除世界时钟数据的方法。
 */
@protocol TSWorldClockInterface <TSKitBaseInterface>

/**
 * @brief Get the maximum number of world clocks supported by the device
 * @chinese 获取设备支持的最大世界时钟数量
 *
 * @return 
 * EN: The maximum number of world clocks that can be set
 * CN: 可以设置的世界时钟最大数量
 */
- (NSInteger)supportMaxWorldClockCount;

/**
 * @brief Set world clocks for the device
 * @chinese 设置设备的世界时钟
 *
 * @param worldClocks
 * EN: Array of world clock models to be set
 * CN: 要设置的世界时钟模型数组
 *
 * @param completion 
 * EN: Callback block to be executed after the operation completes
 * CN: 操作完成后的回调块
 */
- (void)setWorldClocks:(NSArray<TSWorldClockModel *> *)worldClocks
           completion:(TSCompletionBlock)completion;

/**
 * @brief Get all world clocks from the device
 * @chinese 查询设备中的所有世界时钟
 *
 * @param completion 
 * EN: Callback block that returns an array of world clock models and any error that occurred
 * CN: 返回世界时钟模型数组和可能发生的错误的回调块
 */
- (void)queryWorldClockCompletion:(void(^)(NSArray<TSWorldClockModel *> *_Nullable allWorldClocks, NSError * _Nullable error))completion;

/**
 * @brief Delete a specific world clock from the device
 * @chinese 从设备中删除特定的世界时钟
 *
 * @param worldClock 
 * EN: The world clock model to be deleted
 * CN: 要删除的世界时钟模型
 *
 * @param completion 
 * EN: Callback block to be executed after the operation completes
 * CN: 操作完成后的回调块
 */
- (void)deleteWorldClock:(TSWorldClockModel *)worldClock completion:(TSCompletionBlock)completion;

/**
 * @brief Delete all world clocks from the device
 * @chinese 从设备中删除所有世界时钟
 *
 * @param completion 
 * EN: Callback block to be executed after the operation completes
 * CN: 操作完成后的回调块
 */
- (void)deleteAllWorldClockCompletion:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
