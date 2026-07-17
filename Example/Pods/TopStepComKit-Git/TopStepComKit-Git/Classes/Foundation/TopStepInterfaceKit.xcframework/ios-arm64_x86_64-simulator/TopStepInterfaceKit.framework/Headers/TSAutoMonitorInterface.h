//
//  TSAutoMonitorInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/3.
//

#import "TSKitBaseInterface.h"
#import "TSAutoMonitorConfigs.h"
#import "TSAutoMonitorHRConfigs.h"
#import "TSAutoMonitorBPConfigs.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TSAutoMonitorInterface <TSKitBaseInterface>

#pragma mark - Heart Rate Auto Monitor

/**
 * @brief Fetch heart rate auto monitor configurations
 * @chinese 获取心率自动监测配置
 *
 * @param completion Completion block with heart rate monitor configs and error
 * @chinese completion 完成回调，包含心率监测配置和错误信息
 *
 * @discussion
 * [EN]: Retrieves current heart rate auto monitor configurations from the device,
 *       including monitor schedule, resting/exercise heart rate alerts, and heart rate zones.
 *       The configuration includes enable/disable status, time schedule, alert thresholds,
 *       and maximum exercise heart rate for zone calculation.
 * [CN]: 从设备获取当前的心率自动监测配置，包括监测计划、静息/运动心率告警和心率区间。
 *       配置包含开关状态、时间计划、告警阈值以及用于心率区间计算的最大运动心率。
 *
 * @note
 * [EN]: This is an asynchronous operation. The completion block will be called on the main queue.
 * [CN]: 这是一个异步操作。完成回调将在主队列上调用。
 */
+ (void)fetchHeartRateAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorHRConfigs *_Nullable configs, NSError *_Nullable error))completion;

/**
 * @brief Push heart rate auto monitor configuration to device
 * @chinese 推送心率自动监测配置到设备
 *
 * @param config Heart rate auto monitor configuration to be set
 * @chinese config 要设置的心率自动监测配置
 * @param completion Completion block with operation result
 * @chinese completion 完成回调，包含操作结果
 *
 * @discussion
 * [EN]: Sends heart rate auto monitor configuration to the device. The configuration includes:
 *       - Monitor schedule (enable/disable, start/end time, interval)
 *       - Resting heart rate alert thresholds
 *       - Exercise heart rate alert thresholds
 *       - Maximum exercise heart rate for zone calculation
 *       The device will apply these settings for automatic heart rate monitoring.
 * [CN]: 向设备发送心率自动监测配置。配置包括：
 *       - 监测计划（开关、开始/结束时间、间隔）
 *       - 静息心率告警阈值
 *       - 运动心率告警阈值
 *       - 用于心率区间计算的最大运动心率
 *       设备将应用这些设置进行自动心率监测。
 *
 * @note
 * [EN]: This is an asynchronous operation. The completion block will be called on the main queue.
 * [CN]: 这是一个异步操作。完成回调将在主队列上调用。
 */
+ (void)pushHeartRateAutoMonitorConfig:(TSAutoMonitorHRConfigs *)config
                            completion:(TSCompletionBlock)completion;

#pragma mark - Blood Pressure Auto Monitor

/**
 * @brief Fetch blood pressure auto monitor configurations
 * @chinese 获取血压自动监测配置
 *
 * @param completion Completion block with blood pressure monitor configs and error
 * @chinese completion 完成回调，包含血压监测配置和错误信息
 *
 * @discussion
 * [EN]: Retrieves current blood pressure auto monitor configurations from the device,
 *       including monitor schedule and blood pressure alert thresholds.
 *       The configuration includes enable/disable status, time schedule, interval,
 *       and separate systolic/diastolic blood pressure alert limits.
 * [CN]: 从设备获取当前的血压自动监测配置，包括监测计划和血压告警阈值。
 *       配置包含开关状态、时间计划、间隔以及分别的收缩压/舒张压告警限制。
 *
 * @note
 * [EN]: This is an asynchronous operation. The completion block will be called on the main queue.
 * [CN]: 这是一个异步操作。完成回调将在主队列上调用。
 */
+ (void)fetchBloodPressureAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorBPConfigs *_Nullable configs, NSError *_Nullable error))completion;

/**
 * @brief Push blood pressure auto monitor configuration to device
 * @chinese 推送血压自动监测配置到设备
 *
 * @param config Blood pressure auto monitor configuration to be set
 * @chinese config 要设置的血压自动监测配置
 * @param completion Completion block with operation result
 * @chinese completion 完成回调，包含操作结果
 *
 * @discussion
 * [EN]: Sends blood pressure auto monitor configuration to the device. The configuration includes:
 *       - Monitor schedule (enable/disable, start/end time, interval)
 *       - Blood pressure alert thresholds (systolic and diastolic upper/lower limits)
 *       The device will apply these settings for automatic blood pressure monitoring.
 *       All pressure values are in mmHg (millimeters of mercury).
 * [CN]: 向设备发送血压自动监测配置。配置包括：
 *       - 监测计划（开关、开始/结束时间、间隔）
 *       - 血压告警阈值（收缩压和舒张压的上下限）
 *       设备将应用这些设置进行自动血压监测。
 *       所有压力值均以毫米汞柱（mmHg）为单位。
 *
 * @note
 * [EN]: This is an asynchronous operation. The completion block will be called on the main queue.
 * [CN]: 这是一个异步操作。完成回调将在主队列上调用。
 */
+ (void)pushBloodPressureAutoMonitorConfig:(TSAutoMonitorBPConfigs *)config
                                completion:(TSCompletionBlock)completion;

#pragma mark - Blood Oxygen Auto Monitor

/**
 * @brief Fetch blood oxygen auto monitor configurations
 * @chinese 获取血氧自动监测配置
 *
 * @param completion Completion block with blood oxygen monitor configs and error
 * @chinese completion 完成回调，包含血氧监测配置和错误信息
 *
 * @discussion
 * [EN]: Retrieves current blood oxygen (SpO2) auto monitor configurations from the device,
 *       including monitor schedule and blood oxygen alert thresholds.
 *       The configuration includes enable/disable status, time schedule, interval,
 *       and blood oxygen percentage alert limits. Uses TSAutoMonitorConfigs for basic
 *       monitor configuration with TSMonitorAlert for threshold settings.
 * [CN]: 从设备获取当前的血氧（SpO2）自动监测配置，包括监测计划和血氧告警阈值。
 *       配置包含开关状态、时间计划、间隔以及血氧百分比告警限制。使用 TSAutoMonitorConfigs
 *       作为基础监测配置，TSMonitorAlert 用于阈值设置。
 *
 * @note
 * [EN]: This is an asynchronous operation. The completion block will be called on the main queue.
 * [CN]: 这是一个异步操作。完成回调将在主队列上调用。
 */
+ (void)fetchBloodOxygenAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;

/**
 * @brief Push blood oxygen auto monitor configuration to device
 * @chinese 推送血氧自动监测配置到设备
 *
 * @param config Blood oxygen auto monitor configuration to be set
 * @chinese config 要设置的血氧自动监测配置
 * @param completion Completion block with operation result
 * @chinese completion 完成回调，包含操作结果
 *
 * @discussion
 * [EN]: Sends blood oxygen (SpO2) auto monitor configuration to the device. The configuration includes:
 *       - Monitor schedule (enable/disable, start/end time, interval)
 *       - Blood oxygen alert thresholds (upper and lower percentage limits)
 *       The device will apply these settings for automatic blood oxygen monitoring.
 *       All oxygen values are in percentage (%). Uses TSAutoMonitorConfigs with TSMonitorAlert
 *       for threshold configuration.
 * [CN]: 向设备发送血氧（SpO2）自动监测配置。配置包括：
 *       - 监测计划（开关、开始/结束时间、间隔）
 *       - 血氧告警阈值（上下百分比限制）
 *       设备将应用这些设置进行自动血氧监测。
 *       所有血氧值均以百分比（%）为单位。使用 TSAutoMonitorConfigs 和 TSMonitorAlert 进行阈值配置。
 *
 * @note
 * [EN]: This is an asynchronous operation. The completion block will be called on the main queue.
 * [CN]: 这是一个异步操作。完成回调将在主队列上调用。
 */
+ (void)pushBloodOxygenAutoMonitorConfig:(TSAutoMonitorConfigs *)config
                            completion:(TSCompletionBlock)completion;

#pragma mark - Stress Auto Monitor

/**
 * @brief Fetch stress auto monitor configurations
 * @chinese 获取压力自动监测配置
 *
 * @param completion Completion block with stress monitor configs and error
 * @chinese completion 完成回调，包含压力监测配置和错误信息
 *
 * @discussion
 * [EN]: Retrieves current stress auto monitor configurations from the device,
 *       including monitor schedule and stress alert thresholds.
 *       The configuration includes enable/disable status, time schedule, interval,
 *       and stress level alert limits. Uses TSAutoMonitorConfigs for basic
 *       monitor configuration with TSMonitorAlert for threshold settings.
 * [CN]: 从设备获取当前的压力自动监测配置，包括监测计划和压力告警阈值。
 *       配置包含开关状态、时间计划、间隔以及压力等级告警限制。使用 TSAutoMonitorConfigs
 *       作为基础监测配置，TSMonitorAlert 用于阈值设置。
 *
 * @note
 * [EN]: This is an asynchronous operation. The completion block will be called on the main queue.
 * [CN]: 这是一个异步操作。完成回调将在主队列上调用。
 */
+ (void)fetchStressAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;

/**
 * @brief Push stress auto monitor configuration to device
 * @chinese 推送压力自动监测配置到设备
 *
 * @param config Stress auto monitor configuration to be set
 * @chinese config 要设置的压力自动监测配置
 * @param completion Completion block with operation result
 * @chinese completion 完成回调，包含操作结果
 *
 * @discussion
 * [EN]: Sends stress auto monitor configuration to the device. The configuration includes:
 *       - Monitor schedule (enable/disable, start/end time, interval)
 *       - Stress alert thresholds (upper and lower stress level limits)
 *       The device will apply these settings for automatic stress monitoring.
 *       Stress levels are typically measured on a scale (e.g., 0-100). Uses TSAutoMonitorConfigs
 *       with TSMonitorAlert for threshold configuration.
 * [CN]: 向设备发送压力自动监测配置。配置包括：
 *       - 监测计划（开关、开始/结束时间、间隔）
 *       - 压力告警阈值（上下压力等级限制）
 *       设备将应用这些设置进行自动压力监测。
 *       压力等级通常在某个范围内测量（例如，0-100）。使用 TSAutoMonitorConfigs 和 TSMonitorAlert 进行阈值配置。
 *
 * @note
 * [EN]: This is an asynchronous operation. The completion block will be called on the main queue.
 * [CN]: 这是一个异步操作。完成回调将在主队列上调用。
 */
+ (void)pushStressAutoMonitorConfig:(TSAutoMonitorConfigs *)config
                            completion:(TSCompletionBlock)completion;


#pragma mark - Temperature Auto Monitor

/**
 * @brief Fetch temperature auto monitor configurations
 * @chinese 获取体温自动监测配置
 *
 * @param completion Completion block with temperature monitor configs and error
 * @chinese completion 完成回调，包含体温监测配置和错误信息
 *
 * @discussion
 * [EN]: Retrieves current temperature auto monitor configurations from the device,
 *       including monitor schedule and temperature alert thresholds.
 *       The configuration includes enable/disable status, time schedule, interval,
 *       and temperature alert limits for body temperature monitoring.
 * [CN]: 从设备获取当前的体温自动监测配置，包括监测计划和体温告警阈值。
 *       配置包含开关状态、时间计划、间隔以及体温告警限制。
 *
 * @note
 * [EN]: This is an asynchronous operation. The completion block will be called on the main queue.
 * [CN]: 这是一个异步操作。完成回调将在主队列上调用。
 */
+ (void)fetchTemperatureAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;

/**
 * @brief Push temperature auto monitor configuration to device
 * @chinese 推送体温自动监测配置到设备
 *
 * @param config Temperature auto monitor configuration to be set
 * @chinese config 要设置的体温自动监测配置
 * @param completion Completion block with operation result
 * @chinese completion 完成回调，包含操作结果
 *
 * @discussion
 * [EN]: Sends temperature auto monitor configuration to the device. The configuration includes:
 *       - Monitor schedule (enable/disable, start/end time, interval)
 *       - Temperature alert thresholds (upper and lower temperature limits)
 *       The device will apply these settings for automatic temperature monitoring.
 *       All temperature values are in Celsius (°C).
 * [CN]: 向设备发送体温自动监测配置。配置包括：
 *       - 监测计划（开关、开始/结束时间、间隔）
 *       - 体温告警阈值（上下温度限制）
 *       设备将应用这些设置进行自动体温监测。
 *       所有温度值均以摄氏度（°C）为单位。
 *
 * @note
 * [EN]: This is an asynchronous operation. The completion block will be called on the main queue.
 * [CN]: 这是一个异步操作。完成回调将在主队列上调用。
 */
+ (void)pushTemperatureAutoMonitorConfig:(TSAutoMonitorConfigs *)config
                            completion:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
