//
//  TSBatteryInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import "TSKitBaseInterface.h"
#import "TSBatteryModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Battery operation callback
 * @chinese 电池操作回调
 *
 * @param batteryModel
 * EN: Battery information model containing level and charging status
 * CN: 包含电量和充电状态的电池信息模型
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 操作失败时的错误信息，成功时为nil
 */
typedef void (^TSBatteryBlock)(TSBatteryModel *_Nullable batteryModel, NSError *_Nullable error);

/**
 * @brief Multi-battery operation callback
 * @chinese 多电池操作回调
 *
 * @param batteryModels
 * EN: Array of battery information models, one per physical battery part
 * CN: 电池信息模型数组，每个物理电池部件对应一个元素
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 操作失败时的错误信息，成功时为nil
 */
typedef void (^TSBatteriesBlock)(NSArray<TSBatteryModel *> *_Nullable batteryModels, NSError *_Nullable error);

/**
 * @brief Battery management interface
 * @chinese 电池管理接口
 *
 * @discussion
 * EN: This interface defines all operations related to device battery, including:
 *     1. Get overall battery information (level and charging status)
 *     2. Get per-part battery information for multi-battery devices
 *     3. Monitor battery information changes
 * CN: 该接口定义了与设备电池相关的所有操作，包括：
 *     1. 获取总览电池信息（电量和充电状态）
 *     2. 获取多电池设备各部件的电池信息
 *     3. 监听电池信息变化
 */
@protocol TSBatteryInterface <TSKitBaseInterface>

/**
 * @brief Get overall battery information
 * @chinese 获取总览电池信息
 *
 * @param completion
 * EN: Completion callback
 *     - batteryModel: Battery information model containing level and charging status
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - batteryModel: 包含电量和充电状态的电池信息模型
 *     - error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Retrieve a single battery model representing the device's overall
 *     battery status. For single-battery devices this is the main battery.
 *     For multi-battery devices (earbuds, split-battery glasses, etc.),
 *     implementations should return the lowest-percentage part so that
 *     callers rendering an overall indicator (e.g. top status bar) get a
 *     conservative value. To enumerate every battery part, use
 *     getAllBatteriesInfoCompletion:.
 * CN: 获取表示设备总览电池状态的单个电池模型。单电池设备返回主电池；
 *     多电池设备（耳机、左右分体眼镜等）实现方应返回电量最低的部件，
 *     便于调用方（如顶部状态栏）以保守值展示总览。
 *     需要枚举所有部件电量请使用 getAllBatteriesInfoCompletion:。
 */
- (void)getBatteryInfoCompletion:(nullable TSBatteryBlock)completion;

/**
 * @brief Get battery information for all parts
 * @chinese 获取所有部件的电池信息
 *
 * @param completion
 * EN: Completion callback
 *     - batteryModels: Array of battery models, one per physical battery part.
 *       For single-battery devices the array contains exactly one element
 *       with part == TSBatteryPartMain.
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - batteryModels: 电池模型数组，每个物理电池部件对应一个元素。
 *       单电池设备返回只含一个元素的数组，元素的 part 为 TSBatteryPartMain。
 *     - error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Retrieve per-part battery information. Multi-battery devices
 *     (earbuds with L/R/case, split-battery glasses, headsets with
 *     mic/speaker, etc.) return one TSBatteryModel per part. Single-battery
 *     devices return a single-element array so callers can use the same
 *     iteration code regardless of device type.
 * CN: 获取每个部件的电池信息。多电池设备（耳机左耳/右耳/充电盒、
 *     左右分体眼镜、带麦克风/扬声器的头戴式设备等）返回每个部件对应的
 *     TSBatteryModel；单电池设备返回单元素数组，以便调用方对所有设备
 *     使用统一的遍历逻辑。
 */
- (void)getAllBatteriesInfoCompletion:(nullable TSBatteriesBlock)completion;

/**
 * @brief Register battery information change listener
 * @chinese 注册电池信息变化监听
 *
 * @param completion
 * EN: Callback when battery information changes
 *     - batteryModel: Updated battery information model. For multi-battery
 *       devices, this callback is invoked once per changed part, carrying
 *       that single part's TSBatteryModel (identifiable via the part property).
 *     - error: Error information if failed, nil if successful
 * CN: 电池信息变化时的回调
 *     - batteryModel: 更新后的电池信息模型。多电池设备每当某个部件电量变化时
 *       回调一次，模型即为该部件的 TSBatteryModel（通过 part 属性区分）。
 *     - error: 监听失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: This callback will be triggered when the device battery information changes.
 *     For multi-battery devices, callers should inspect batteryModel.part to
 *     route the update to the correct UI element.
 * CN: 当设备电池信息发生变化时，此回调会被触发。
 *     多电池设备的调用方应通过 batteryModel.part 区分变更的部件，并更新对应 UI。
 */
- (void)registerBatteryDidChanged:(nullable TSBatteryBlock)completion;

@end

NS_ASSUME_NONNULL_END
