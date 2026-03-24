//
//  TSDataSyncDefines.h
//  Pods
//
//  Created by 磐石 on 2025/11/24.
//

#ifndef TSDataSyncDefines_h
#define TSDataSyncDefines_h

/**
 * @brief Data granularity for synchronization
 * @chinese 数据同步颗粒度
 *
 * @discussion
 * [EN]: Defines the granularity level for data synchronization.
 *       Currently supports only raw data and daily aggregated data.
 *
 * [CN]: 定义数据同步的颗粒度级别。
 *       目前仅支持原始数据和按天聚合的数据。
 */
typedef NS_ENUM(NSInteger, TSDataGranularity) {
    /// 原始数据 (Raw data)
    TSDataGranularityRaw = 0,
    /// 天级数据 (Daily data)
    TSDataGranularityDay
};

/**
 * @brief Data synchronization options
 * @chinese 数据同步选项
 *
 * @discussion
 * [EN]: Defines the types of health data that can be synchronized from the device.
 *       These options can be combined using bitwise OR operations for batch synchronization.
 *       Each option represents a specific category of health metrics collected by the device.
 *
 * [CN]: 定义可以从设备同步的健康数据类型。
 *       这些选项可以使用按位或操作组合进行批量同步。
 *       每个选项代表设备收集的特定健康指标类别。
 */
typedef NS_OPTIONS(NSInteger, TSDataSyncOption) {
    /// 无数据选项 (No data option)
    TSDataSyncOptionNone          = 0,
    /// 心率数据 (Heart rate data)
    TSDataSyncOptionHeartRate     = 1 << 0,
    /// 血氧数据 (Blood oxygen data)
    TSDataSyncOptionBloodOxygen   = 1 << 1,
    /// 血压数据 (Blood pressure data)
    TSDataSyncOptionBloodPressure = 1 << 2,
    /// 压力水平数据 (Stress level data)
    TSDataSyncOptionStress        = 1 << 3,
    /// 睡眠监测数据 (Sleep monitoring data)
    TSDataSyncOptionSleep         = 1 << 4,
    /// 体温数据 (Temperature data)
    TSDataSyncOptionTemperature   = 1 << 5,
    /// 心电图数据 (ECG data)
    TSDataSyncOptionECG           = 1 << 6,
    /// 运动活动数据 (Sports activity data)
    TSDataSyncOptionSport         = 1 << 7,
    /// 日常活动数据 (Daily activity data)
    TSDataSyncOptionDailyActivity = 1 << 8,
    /// 所有数据选项的组合 (All data options combined)
    TSDataSyncOptionAll           = (TSDataSyncOptionHeartRate |
                                     TSDataSyncOptionBloodOxygen |
                                     TSDataSyncOptionBloodPressure |
                                     TSDataSyncOptionStress |
                                     TSDataSyncOptionSleep |
                                     TSDataSyncOptionTemperature |
                                     TSDataSyncOptionECG |
                                     TSDataSyncOptionSport |
                                     TSDataSyncOptionDailyActivity)
};



#endif /* TSDataSyncDefines_h */
