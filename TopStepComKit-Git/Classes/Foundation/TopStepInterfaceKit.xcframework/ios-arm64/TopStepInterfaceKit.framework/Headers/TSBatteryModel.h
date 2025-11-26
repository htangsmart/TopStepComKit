//
//  TSBatteryModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Battery charging state
 * @chinese 电池充电状态
 *
 * @discussion
 * EN: Defines different states of battery charging:
 *     1. Unknown - Charging state is unknown
 *     2. Charging - Connected to power and charging
 *     3. NoPower - Not connected to power
 *     4. NotCharging - Connected to power but not charging
 *     5. Full - Battery is fully charged
 *
 * CN: 定义不同的电池充电状态：
 *     1. 未知 - 充电状态未知
 *     2. 充电中 - 已连接电源并且正在充电
 *     3. 未连接 - 未连接电源
 *     4. 未充电 - 已连接电源但未在充电
 *     5. 已充满 - 电池已充满
 */
typedef NS_ENUM(UInt8, TSBatteryState) {
    TSBatteryStateUnknown = 1,          // 未知
    TSBatteryStateCharging,             // 充电中
    TSBatteryStateUnConnectNoCharging,  // 未连接电源
    TSBatteryStateConnectNotCharging,   // 已连接但未充电
    TSBatteryStateFull                  // 已充满
};

/**
 * @brief Battery information model
 * @chinese 电池信息模型
 *
 * @discussion
 * EN: This model contains device battery information, including:
 *     1. Charging state
 *     2. Battery level percentage
 * CN: 该模型包含设备电池信息，包括：
 *     1. 充电状态
 *     2. 电量百分比
 */
@interface TSBatteryModel : TSKitBaseModel

/**
 * @brief Device charging state
 * @chinese 设备充电状态
 *
 * @discussion
 * EN: Indicates the current charging state of the device
 * CN: 表示设备当前的充电状态
 *
 * @note
 * EN: See TSBatteryState enum for possible values
 * CN: 可能的值请参考 TSBatteryState 枚举
 */
@property (nonatomic ,readonly) TSBatteryState chargeState;

/**
 * @brief Battery percentage
 * @chinese 电池电量百分比
 *
 * @discussion
 * EN: Battery percentage (0-100)
 * CN: 电池电量百分比（0-100）
 */
@property (nonatomic ,readonly) UInt8 percentage;

/**
 * @brief Create battery model with level and charging state
 * @chinese 使用电量和充电状态创建电池模型
 *
 * @param percentage
 * EN: Battery percentage (0-100)
 * CN: 电池电量百分比（0-100）
 *
 * @param chargeState
 * EN: Current charging state of the device
 * CN: 设备当前的充电状态
 *
 * @return
 * EN: A new battery model instance
 * CN: 新的电池模型实例
 */
- (instancetype)initWithPercentage:(NSInteger)percentage
                       chargeState:(TSBatteryState)chargeState NS_DESIGNATED_INITIALIZER;

/**
 * @brief Unavailable default initializer
 * @chinese 不可用的默认初始化方法
 *
 * @discussion
 * [EN]: This initializer is unavailable. Use initWithUserId: instead.
 * [CN]: 此初始化方法不可用。请使用 initWithUserId: 方法代替。
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Disable copy method
 * @chinese 禁用复制方法
 *
 * @discussion
 * [EN]: This method is unavailable. TSBatteryModel instances should not be copied.
 * [CN]: 此方法不可用。TSBatteryModel实例不应被复制。
 */
- (instancetype)copy NS_UNAVAILABLE;

/**
 * @brief Disable new method
 * @chinese 禁用new方法
 *
 * @discussion
 * [EN]: This method is unavailable. Use initWithUserId: instead.
 * [CN]: 此方法不可用。请使用initWithUserId:代替。
 */
- (instancetype)new NS_UNAVAILABLE;


@end

NS_ASSUME_NONNULL_END
