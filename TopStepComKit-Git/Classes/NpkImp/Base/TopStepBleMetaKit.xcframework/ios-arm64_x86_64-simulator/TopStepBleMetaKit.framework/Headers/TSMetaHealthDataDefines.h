//
//  TSMetaHealthDataDefines.h
//  Pods
//
//  Created by 磐石 on 2025/11/24.
//

#ifndef TSMetaHealthDataDefines_h
#define TSMetaHealthDataDefines_h

/**
 * @brief Data sync type options (bitmask)
 * @chinese 数据同步类型（位掩码）
 *
 * @discussion
 * [EN]: Bitwise-combinable data types for synchronization.
 * [CN]: 可按位组合的同步数据类型。
 */
typedef NS_OPTIONS(NSUInteger, TSMetaDataOpetions) {
    TSMetaDataOpetionNone           = 0,        // 无 None
    TSMetaDataOpetionHeartRate      = 1 << 0,  // 心率 Heart rate
    TSMetaDataOpetionBloodOxygen    = 1 << 1,  // 血氧 Blood oxygen
    TSMetaDataOpetionBloodPressure  = 1 << 2,  // 血压 Blood pressure
    TSMetaDataOpetionStress         = 1 << 3,  // 压力 Stress
    TSMetaDataOpetionSleep          = 1 << 4,  // 睡眠 Sleep
    TSMetaDataOpetionTemperature    = 1 << 5,  // 体温 Temperature
    TSMetaDataOpetionECG            = 1 << 6,  // 心电图 ECG
    TSMetaDataOpetionSport          = 1 << 7,  // 运动 Sport
    TSMetaDataOpetionDailyActivity  = 1 << 8,  // 日常活动 Daily activity
    TSMetaDataOpetionAll            = (TSMetaDataOpetionHeartRate |
                                    TSMetaDataOpetionBloodOxygen |
                                    TSMetaDataOpetionBloodPressure |
                                    TSMetaDataOpetionStress |
                                    TSMetaDataOpetionSleep |
                                    TSMetaDataOpetionTemperature |
                                    TSMetaDataOpetionECG |
                                    TSMetaDataOpetionSport |
                                    TSMetaDataOpetionDailyActivity) // 全部 All
};



#endif /* TSMetaHealthDataDefines_h */
