//
//  TSAlarmClockInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/12.
//

#import "TSKitBaseInterface.h"
#import "TSAlarmClockModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Alarm clock operation callback block type
 * @chinese 闹钟操作回调块类型
 *
 * @param allAlarmClocks 
 * EN: Array of alarm clocks, containing all current alarm settings
 * CN: 闹钟数组，包含当前所有闹钟设置
 *
 * @param error 
 * EN: Error object if operation fails, nil if successful
 * CN: 操作失败时的错误对象，成功时为nil
 *
 * @discussion
 * [EN]: This block is used for various alarm clock operations:
 * - Getting all alarm clocks
 * - Setting alarm clocks
 * - Monitoring alarm clock changes
 *
 * [CN]: 此回调块用于多种闹钟操作：
 * - 获取所有闹钟
 * - 设置闹钟
 * - 监听闹钟变化
 */
typedef void(^TSAlarmClockResultBlock)(NSArray<TSAlarmClockModel *> *allAlarmClocks, NSError * _Nullable error);

/**
 * @brief Alarm clock management interface protocol
 * @chinese 闹钟管理接口协议
 *
 * @discussion
 * [EN]: This protocol defines the interface for managing device alarm clocks, including:
 * - Reading current alarm settings
 * - Writing new alarm settings
 * - Monitoring alarm setting changes
 * - Supporting multiple alarms with different configurations
 *
 * [CN]: 此协议定义了设备闹钟管理的接口，包括：
 * - 读取当前闹钟设置
 * - 写入新的闹钟设置
 * - 监控闹钟设置变化
 * - 支持多个不同配置的闹钟
 */
@protocol TSAlarmClockInterface <TSKitBaseInterface>

/**
 * @brief Get maximum number of alarm clocks supported by device
 * @chinese 获取设备支持的最大闹钟数量
 *
 * @return 
 * EN: Integer value indicating maximum number of alarms supported
 * CN: 整数值，表示设备支持的最大闹钟数量
 *
 * @discussion
 * [EN]: Returns the device's maximum supported alarm count:
 * - Different device models may support different numbers of alarms
 * - Returns 0 if device does not support alarm function
 * - Use this value to limit the number of alarms that can be set
 * - Always check this before attempting to add new alarms
 *
 * [CN]: 返回设备支持的最大闹钟数：
 * - 不同的设备型号可能支持不同数量的闹钟
 * - 如果设备不支持闹钟功能，则返回0
 * - 使用此值限制可以设置的闹钟数量
 * - 在尝试添加新闹钟前始终检查此值
 */
- (NSInteger)supportMaxAlarmCount;

/**
 * @brief Get maximum byte length of alarm remark/label
 * @chinese 获取闹钟标签的最大字节长度限制
 *
 * @return 
 * EN: Integer value indicating maximum byte length for alarm remark
 * CN: 整数值，表示闹钟标签的最大字节长度
 *
 * @discussion
 * [EN]: Returns the maximum byte length allowed for alarm remark:
 * - Represents the byte length limit for TSAlarmClockModel's remark property
 * - For example, returning 64 means the remark cannot exceed 64 bytes
 * - Different device models may have different limits
 * - Note: One Chinese character typically takes 3 bytes in UTF-8 encoding
 * - Always validate remark length before setting alarms
 * - Returns 0 if device does not support alarm remarks
 *
 * [CN]: 返回闹钟标签允许的最大字节长度：
 * - 表示TSAlarmClockModel的remark属性的字节长度限制
 * - 例如，返回64表示remark不能超过64字节
 * - 不同的设备型号可能有不同的限制
 * - 注意：一个中文字符通常在UTF-8编码中占用3字节
 * - 在设置闹钟前始终验证标签长度
 * - 如果设备不支持闹钟标签，则返回0
 */
- (NSInteger)supportMaxAlarmRemarkLength;

/**
 * @brief Get all alarm clocks from device
 * @chinese 从设备获取所有闹钟
 *
 * @param completion 
 * EN: Callback block that returns all alarm clocks or error
 * CN: 返回所有闹钟或错误的回调块
 *
 * @discussion
 * [EN]: Retrieves all alarm clock settings from the device:
 * - Returns array of TSAlarmClockModel objects
 * - Empty array if no alarms are set
 * - Error details if operation fails
 *
 * [CN]: 从设备获取所有闹钟设置：
 * - 返回TSAlarmClockModel对象数组
 * - 如果没有设置闹钟则返回空数组
 * - 操作失败时返回错误详情
 */
- (void)getAllAlarmClocksCompletion:(_Nullable TSAlarmClockResultBlock)completion;

/**
 * @brief Set all alarm clocks to device
 * @chinese 设置所有闹钟到设备
 *
 * @param allAlarmClocks 
 * EN: Array of TSAlarmClockModel objects to be set
 * CN: 要设置的TSAlarmClockModel对象数组
 *
 * @param completion 
 * EN: Callback block that returns operation result and error if any
 * CN: 返回操作结果和错误（如果有）的回调块
 *
 * @discussion
 * [EN]: Synchronizes alarm clock settings to the device:
 * - Overwrites all existing alarm settings
 * - Validates alarm configurations before setting
 * - Returns error if validation or setting fails
 *
 * [CN]: 同步闹钟设置到设备：
 * - 覆盖所有现有的闹钟设置
 * - 在设置前验证闹钟配置
 * - 如果验证或设置失败则返回错误
 */
- (void)setAllAlarmClocks:(NSArray<TSAlarmClockModel *> *_Nullable)allAlarmClocks
               completion:(TSCompletionBlock)completion;

/**
 * @brief Register for alarm clock change notifications
 * @chinese 注册闹钟变化通知
 *
 * @param completion 
 * EN: Callback block that is triggered when alarm settings change
 * CN: 闹钟设置发生变化时触发的回调块
 *
 * @discussion
 * [EN]: Monitors device alarm clock changes:
 * - Only one listener is allowed at a time
 * - New registration will replace the previous listener
 * - Triggered when alarms are added, modified, or deleted
 * - Provides updated array of all alarm settings
 * - Returns error if monitoring fails
 *
 * [CN]: 监控设备闹钟变化：
 * - 同一时间只允许一个监听者
 * - 新的注册会替换之前的监听者
 * - 当闹钟被添加、修改或删除时触发
 * - 提供更新后的所有闹钟设置数组
 * - 如果监控失败则返回错误
 */
- (void)registerAlarmClocksDidChangedBlock:(_Nullable TSAlarmClockResultBlock)completion;




@end

NS_ASSUME_NONNULL_END
