//
//  TSActivityMeasureParam.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/5.
//

#import <Foundation/Foundation.h>

/**
 * @brief Measurement item type enumeration
 * @chinese 测量项目类型枚举
 *
 * @discussion
 * [EN]: Defines different types of health measurements that can be selected:
 * - None: No measurement selected
 * - Heart Rate: Real-time heart rate monitoring
 * - Blood Pressure: Systolic and diastolic blood pressure
 * - Blood Oxygen: Blood oxygen saturation SpO2
 * - Stress: Mental stress level assessment
 * - Temperature: Body temperature measurement
 * - ECG: Electrocardiogram recording
 * 
 * Only one measurement type can be selected at a time.
 *
 * [CN]: 定义可以选择的不同类型健康测量：
 * - 无：未选择测量项目
 * - 心率：实时心率监测
 * - 血压：收缩压和舒张压
 * - 血氧：血氧饱和度SpO2
 * - 压力：精神压力水平评估
 * - 体温：体温测量
 * - 心电：心电图记录
 * 
 * 一次只能选择一种测量类型。
 */
typedef NS_ENUM(UInt8, TSActiveMeasureItem) {
    TSMeasureItemNone           = 0,          // 无测量项目 No measurement items
    TSMeasureItemHeartRate      = 1,          // 心率 Heart Rate
    TSMeasureItemBloodPressure  = 2,          // 血压 Blood Pressure
    TSMeasureItemBloodOxygen    = 3,          // 血氧 Blood Oxygen
    TSMeasureItemStress         = 4,          // 压力 Stress
    TSMeasureItemTemperature    = 5,          // 体温 Temperature
    TSMeasureItemECG            = 6           // 心电 ECG
};

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Active measurement parameters model
 * @chinese 主动测量参数模型
 *
 * @discussion
 * [EN]: This class defines parameters for active health measurements:
 * - Measurement type selection (only one type at a time)
 * - Sampling interval configuration
 * - Maximum measurement duration setting
 * Used to customize and control various health measurement sessions.
 *
 * [CN]: 该类定义主动健康测量的参数：
 * - 测量类型选择（一次只能选择一种类型）
 * - 采样间隔配置
 * - 最大测量时长设置
 * 用于自定义和控制各种健康测量会话。
 */
@interface TSActivityMeasureParam : NSObject

/**
 * @brief Type of measurement to perform
 * @chinese 要执行的测量类型
 *
 * @discussion
 * [EN]: Specifies which health metric to measure.
 * Only one measurement type can be selected at a time.
 * Example: param.measureItem = TSMeasureItemHeartRate;
 *
 * [CN]: 指定要测量的健康指标。
 * 一次只能选择一种测量类型。
 * 示例：param.measureItem = TSMeasureItemHeartRate;
 *
 * @note
 * [EN]: Not all measurement types may be supported by all devices.
 * Check device capabilities before setting.
 *
 * [CN]: 并非所有设备都支持所有测量类型。
 * 设置前请检查设备功能。
 */
@property (nonatomic, assign) TSActiveMeasureItem measureItem;

/**
 * @brief Sampling interval in seconds
 * @chinese 采样间隔（秒）
 *
 * @discussion
 * [EN]: Time between consecutive measurements in seconds.
 * Affects measurement frequency and data granularity.
 *
 * [CN]: 连续测量之间的时间间隔（以秒为单位）。
 * 影响测量频率和数据颗粒度。
 *
 * @note
 * [EN]: Valid range varies by measurement type.
 * [CN]: 有效范围因测量类型而异。
 */
@property (nonatomic, assign) UInt8 interval;

/**
 * @brief Maximum measurement duration in minutes
 * @chinese 最大测量时长（分钟）
 *
 * @discussion
 * [EN]: Maximum duration for the measurement session in second.
 * Measurement automatically stops after this duration.
 * Default value is 60 seconds.
 *
 * [CN]: 测量会话的最大持续时间（以秒为单位）。
 * 达到此时长后测量自动停止。
 * 默认值为60秒。
 *
 * @note
 * [EN]: Set to 0 for continuous measurement until manual stop.
 * Minimum valid value is 15 seconds.
 * 
 * [CN]: 设置为0表示持续测量直到手动停止。
 * 最小有效值为15秒。
 */
@property (nonatomic, assign) UInt8 maxMeasureDuration;

@end

NS_ASSUME_NONNULL_END
