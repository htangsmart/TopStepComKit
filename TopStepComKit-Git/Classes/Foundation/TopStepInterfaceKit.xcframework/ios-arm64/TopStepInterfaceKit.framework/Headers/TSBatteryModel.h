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
 * @brief Battery part identifier
 * @chinese 电池部件标识
 *
 * @discussion
 * EN: Identifies which physical part of a device a battery belongs to.
 *     For devices with a single main battery (watches, single-battery
 *     glasses, etc.), use TSBatteryPartMain. For multi-battery devices
 *     (earbuds with L/R/case, split-battery glasses, headsets with
 *     mic/speaker, etc.), use the specific part value.
 * CN: 标识电池所属的设备物理部件。对于只有一块主电池的设备
 *     （手表、单电池眼镜等），使用 TSBatteryPartMain。对于多电池设备
 *     （耳机的左耳/右耳/充电盒、左右分体眼镜、带麦克风/扬声器的头戴式设备等），
 *     使用具体的部件值。
 */
typedef NS_ENUM(UInt8, TSBatteryPart) {
    TSBatteryPartUnknown = 0,   // 未知部件
    TSBatteryPartMain,          // 主电池（适用于手表、单电池眼镜等单主电池形态的设备）
    TSBatteryPartLeft,          // 左侧部件（如耳机左耳、左镜腿）
    TSBatteryPartRight,         // 右侧部件（如耳机右耳、右镜腿）
    TSBatteryPartCase,          // 充电盒
    TSBatteryPartMic,           // 麦克风
    TSBatteryPartMainSpeaker,   // 主扬声器
    TSBatteryPartSideSpeaker,   // 副扬声器
    TSBatteryPartOther,         // 其他部件
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
 * @brief Battery part identifier
 * @chinese 电池部件标识
 *
 * @discussion
 * EN: Indicates which physical part of the device this battery belongs to.
 *     For single-battery devices created via initWithPercentage:chargeState:,
 *     this value defaults to TSBatteryPartMain.
 * CN: 指示该电池所属的设备物理部件。
 *     通过 initWithPercentage:chargeState: 创建的单电池设备模型，
 *     该值默认为 TSBatteryPartMain。
 *
 * @note
 * EN: See TSBatteryPart enum for possible values.
 * CN: 可能的值请参考 TSBatteryPart 枚举。
 */
@property (nonatomic, readonly) TSBatteryPart part;

/**
 * @brief Human-readable name of the battery part
 * @chinese 电池部件的可读名称
 *
 * @return
 * EN: A short English name corresponding to the part value
 *     (e.g. "Main", "Left", "Main Speaker"). Never nil.
 * CN: 与 part 取值对应的简短英文名称（如 "Main"、"Left"、"Main Speaker"），
 *     不会返回 nil。
 *
 * @discussion
 * EN: Convenience accessor for logging or debug UI. For end-user display
 *     callers should localize based on the part value rather than this string.
 * CN: 便于日志或调试 UI 使用。面向终端用户展示时，调用方应根据 part 值自行本地化，
 *     不要直接使用此字符串。
 */
- (NSString *)partName;

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
 * EN: A new battery model instance with part defaulted to TSBatteryPartMain
 * CN: 新的电池模型实例，part 默认为 TSBatteryPartMain
 *
 * @discussion
 * EN: Convenience initializer for single-battery devices. The part is
 *     implicitly set to TSBatteryPartMain. For multi-battery parts, use
 *     initWithPart:percentage:chargeState: instead.
 * CN: 单电池设备使用的便捷构造器，part 隐式设为 TSBatteryPartMain。
 *     多电池部件请使用 initWithPart:percentage:chargeState:。
 */
- (instancetype)initWithPercentage:(NSInteger)percentage
                       chargeState:(TSBatteryState)chargeState;

/**
 * @brief Create battery model with part, level and charging state
 * @chinese 使用部件、电量和充电状态创建电池模型
 *
 * @param part
 * EN: The battery part identifier
 * CN: 电池部件标识
 *
 * @param percentage
 * EN: Battery percentage (0-100)
 * CN: 电池电量百分比（0-100）
 *
 * @param chargeState
 * EN: Current charging state of this battery
 * CN: 该电池当前的充电状态
 *
 * @return
 * EN: A new battery model instance
 * CN: 新的电池模型实例
 *
 * @discussion
 * EN: Designated initializer. Use this for multi-battery devices where each
 *     physical battery is represented by an individual TSBatteryModel.
 * CN: 指定构造器。多电池设备使用此构造器，每个物理电池对应一个独立的 TSBatteryModel。
 */
- (instancetype)initWithPart:(TSBatteryPart)part
                  percentage:(NSInteger)percentage
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
