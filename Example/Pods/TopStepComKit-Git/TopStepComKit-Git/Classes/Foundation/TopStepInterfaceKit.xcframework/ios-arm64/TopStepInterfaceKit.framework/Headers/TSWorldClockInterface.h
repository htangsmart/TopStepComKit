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
 * @brief World clock operation callback block type
 * @chinese 世界时钟操作回调块类型
 *
 * @param allWorldClocks
 * EN: Array of world clocks, containing all current world clock settings
 * CN: 世界时钟数组，包含当前所有世界时钟设置
 *
 * @param error
 * EN: Error object if operation fails, nil if successful
 * CN: 操作失败时的错误对象，成功时为nil
 *
 * @discussion
 * [EN]: This block is used for various world clock operations:
 * - Getting all world clocks
 * - Setting world clocks
 * - Monitoring world clock changes
 *
 * [CN]: 此回调块用于多种世界时钟操作：
 * - 获取所有世界时钟
 * - 设置世界时钟
 * - 监听世界时钟变化
 */
typedef void(^TSWorldClockResultBlock)(NSArray<TSWorldClockModel *> *allWorldClocks, NSError * _Nullable error);

/**
 * @brief World clock management interface protocol
 * @chinese 世界时钟管理接口协议
 *
 * @discussion
 * [EN]: This protocol defines the interface for managing device world clocks, including:
 * - Reading current world clock settings
 * - Writing new world clock settings
 * - Monitoring world clock setting changes
 * - Supporting multiple world clocks for different time zones
 *
 * [CN]: 此协议定义了设备世界时钟管理的接口，包括：
 * - 读取当前世界时钟设置
 * - 写入新的世界时钟设置
 * - 监控世界时钟设置变化
 * - 支持多个不同时区的世界时钟
 */
@protocol TSWorldClockInterface <TSKitBaseInterface>

/**
 * @brief Get maximum number of world clocks supported by device
 * @chinese 获取设备支持的最大世界时钟数量
 *
 * @return
 * EN: Integer value indicating maximum number of world clocks supported
 * CN: 整数值，表示设备支持的最大世界时钟数量
 *
 * @discussion
 * [EN]: Returns the device's maximum supported world clock count:
 * - Different device models may support different numbers of world clocks
 * - Returns 0 if device does not support world clock function
 * - Use this value to limit the number of world clocks that can be set
 * - Always check this before attempting to add new world clocks
 *
 * [CN]: 返回设备支持的最大世界时钟数：
 * - 不同的设备型号可能支持不同数量的世界时钟
 * - 如果设备不支持世界时钟功能，则返回0
 * - 使用此值限制可以设置的世界时钟数量
 * - 在尝试添加新世界时钟前始终检查此值
 */
- (NSInteger)supportMaxWorldClockCount;

/**
 * @brief Get maximum byte length of city name
 * @chinese 获取城市名称的最大字节长度限制
 *
 * @return
 * EN: Integer value indicating maximum byte length for city name
 * CN: 整数值，表示城市名称的最大字节长度
 *
 * @discussion
 * [EN]: Returns the maximum byte length allowed for city name:
 * - Represents the byte length limit for TSWorldClockModel's cityName property
 * - For example, returning 32 means the cityName cannot exceed 32 bytes
 * - Different device models may have different limits
 * - Note: One Chinese character typically takes 3 bytes in UTF-8 encoding
 * - Always validate city name length before setting world clocks
 * - Returns 0 if device does not support city name
 *
 * [CN]: 返回城市名称允许的最大字节长度：
 * - 表示TSWorldClockModel的cityName属性的字节长度限制
 * - 例如，返回32表示cityName不能超过32字节
 * - 不同的设备型号可能有不同的限制
 * - 注意：一个中文字符通常在UTF-8编码中占用3字节
 * - 在设置世界时钟前始终验证城市名称长度
 * - 如果设备不支持城市名称，则返回0
 */
- (NSInteger)supportMaxCityNameLength;

/**
 * @brief Get all world clocks from device
 * @chinese 从设备获取所有世界时钟
 *
 * @param completion
 * EN: Callback block that returns all world clocks or error
 * CN: 返回所有世界时钟或错误的回调块
 *
 * @discussion
 * [EN]: Retrieves all world clock settings from the device:
 * - Returns array of TSWorldClockModel objects
 * - Empty array if no world clocks are set
 * - Error details if operation fails
 *
 * [CN]: 从设备获取所有世界时钟设置：
 * - 返回TSWorldClockModel对象数组
 * - 如果没有设置世界时钟则返回空数组
 * - 操作失败时返回错误详情
 */
- (void)getAllWorldClocksCompletion:(_Nullable TSWorldClockResultBlock)completion;

/**
 * @brief Set all world clocks to device
 * @chinese 设置所有世界时钟到设备
 *
 * @param allWorldClocks
 * EN: Array of TSWorldClockModel objects to be set
 * CN: 要设置的TSWorldClockModel对象数组
 *
 * @param completion
 * EN: Callback block that returns operation result and error if any
 * CN: 返回操作结果和错误（如果有）的回调块
 *
 * @discussion
 * [EN]: Synchronizes world clock settings to the device:
 * - Overwrites all existing world clock settings
 * - Validates world clock configurations before setting
 * - Returns error if validation or setting fails
 *
 * [CN]: 同步世界时钟设置到设备：
 * - 覆盖所有现有的世界时钟设置
 * - 在设置前验证世界时钟配置
 * - 如果验证或设置失败则返回错误
 */
- (void)setAllWorldClocks:(NSArray<TSWorldClockModel *> *_Nullable)allWorldClocks completion:(TSCompletionBlock)completion;

/**
 * @brief Add a single world clock to device
 * @chinese 向设备添加单个世界时钟
 *
 * @param worldClock
 * EN: The world clock model to add; clockId will be assigned automatically by the SDK
 * CN: 要添加的世界时钟模型，clockId 由 SDK 内部自动分配，调用方无需设置
 *
 * @param completion
 * EN: Callback block returning success status and error if any
 * CN: 返回操作结果和错误（如果有）的回调块
 *
 * @discussion
 * [EN]: Adds a single world clock without affecting other existing world clocks.
 * - SDK internally fetches the current world clock list and assigns the first available clockId
 * - Fails with error if existing world clocks have reached supportMaxWorldClockCount
 *
 * [CN]: 添加单个世界时钟，不影响其他已有世界时钟。
 * - SDK 内部自动获取当前世界时钟列表并分配第一个可用的 clockId
 * - 若已有世界时钟数量达到 supportMaxWorldClockCount，则返回错误
 */
- (void)addWorldClock:(TSWorldClockModel *)worldClock completion:(_Nullable TSCompletionBlock)completion;

/**
 * @brief Delete a single world clock from device by clockId
 * @chinese 通过 clockId 从设备删除单个世界时钟
 *
 * @param clockId
 * EN: The clockId of the world clock to delete; must be a valid ID obtained from getAllWorldClocksCompletion:
 * CN: 要删除的世界时钟 clockId，必须是从 getAllWorldClocksCompletion: 返回列表中获取的有效 ID
 *
 * @param completion
 * EN: Callback block returning success status and error if any
 * CN: 返回操作结果和错误（如果有）的回调块
 *
 * @discussion
 * [EN]: Deletes only the specified world clock identified by clockId.
 * Other world clocks remain unchanged.
 * - Returns error if no world clock with the given clockId exists on device
 *
 * [CN]: 仅删除由 clockId 标识的指定世界时钟，其他世界时钟不受影响。
 * - 若设备上不存在对应 clockId 的世界时钟，则返回错误
 */
- (void)deleteWorldClockWithId:(UInt8)clockId completion:(_Nullable TSCompletionBlock)completion;

/**
 * @brief Delete all world clocks from device
 * @chinese 删除设备上的所有世界时钟
 *
 * @param completion
 * EN: Callback block returning success status and error if any
 * CN: 返回操作结果和错误（如果有）的回调块
 *
 * @discussion
 * [EN]: Removes all world clocks from the device at once.
 * - Equivalent to calling setAllWorldClocks:@[] but with clearer intent
 * - Returns error if device communication fails
 *
 * [CN]: 一次性删除设备上的所有世界时钟。
 * - 等价于 setAllWorldClocks:@[]，但语义更明确
 * - 设备通信失败时返回错误
 */
- (void)deleteAllWorldClocksWithCompletion:(_Nullable TSCompletionBlock)completion;

/**
 * @brief Register for world clock change notifications
 * @chinese 注册世界时钟变化通知
 *
 * @param completion
 * EN: Callback block that is triggered when world clock settings change
 * CN: 世界时钟设置发生变化时触发的回调块
 *
 * @discussion
 * [EN]: Monitors device world clock changes:
 * - Only one listener is allowed at a time
 * - New registration will replace the previous listener
 * - Triggered when world clocks are added, modified, or deleted
 * - Provides updated array of all world clock settings
 * - Returns error if monitoring fails
 *
 * [CN]: 监控设备世界时钟变化：
 * - 同一时间只允许一个监听者
 * - 新的注册会替换之前的监听者
 * - 当世界时钟被添加、修改或删除时触发
 * - 提供更新后的所有世界时钟设置数组
 * - 如果监控失败则返回错误
 */
- (void)registerWorldClocksDidChangedBlock:(_Nullable TSWorldClockResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
