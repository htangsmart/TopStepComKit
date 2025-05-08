//
//  TSAllDataModel.h
//  iOSDFULibrary
//
//  Created by 磐石 on 2025/4/20.
//

#import <Foundation/Foundation.h>

#import "TSHRValueModel.h"
#import "TSBOValueModel.h"
#import "TSBPValueModel.h"
#import "TSStressValueModel.h"
#import "TSSleepModel.h"
#import "TSTemperatureValueModel.h"
#import "TSElectrocardioModel.h"

#import "TSDailyActivityValueModel.h"
#import "TSSportModel.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Comprehensive health data container model
 * @chinese 综合健康数据容器模型
 *
 * @discussion
 * [EN]: This class serves as a central container for all health data types synchronized from the device.
 * It includes collections of various health metrics (heart rate, blood oxygen, etc.) along with any
 * associated error information. Used for bulk data synchronization and comprehensive health analysis.
 * 
 * [CN]: 该类作为从设备同步的所有健康数据类型的中央容器。
 * 它包含各种健康指标(心率、血氧等)的集合以及任何相关的错误信息。
 * 用于批量数据同步和综合健康分析。
 */
@interface TSAllDataModel : NSObject

/**
 * @brief Collection of heart rate measurements
 * @chinese 心率测量集合
 *
 * @discussion
 * [EN]: Array of heart rate measurements synchronized from the device.
 * Each entry contains a timestamp and heart rate value in BPM.
 * 
 * [CN]: 从设备同步的心率测量数组。
 * 每个条目包含时间戳和以BPM为单位的心率值。
 */
@property (nonatomic, strong) NSArray<TSHRValueModel *> * allHeartRates;

/**
 * @brief Error information for heart rate data synchronization
 * @chinese 心率数据同步的错误信息
 *
 * @discussion
 * [EN]: Contains error details if heart rate data synchronization failed.
 * Nil if synchronization was successful.
 * 
 * [CN]: 如果心率数据同步失败，则包含错误详情。
 * 如果同步成功，则为nil。
 */
@property (nonatomic, strong) NSError * heartRateError;

/**
 * @brief Collection of blood oxygen measurements
 * @chinese 血氧测量集合
 *
 * @discussion
 * [EN]: Array of blood oxygen measurements synchronized from the device.
 * Each entry contains a timestamp and SpO2 percentage value.
 * 
 * [CN]: 从设备同步的血氧测量数组。
 * 每个条目包含时间戳和SpO2百分比值。
 */
@property (nonatomic, strong) NSArray<TSBOValueModel *> * allBloodOxygens;

/**
 * @brief Error information for blood oxygen data synchronization
 * @chinese 血氧数据同步的错误信息
 *
 * @discussion
 * [EN]: Contains error details if blood oxygen data synchronization failed.
 * Nil if synchronization was successful.
 * 
 * [CN]: 如果血氧数据同步失败，则包含错误详情。
 * 如果同步成功，则为nil。
 */
@property (nonatomic, strong) NSError * bloodOxygensError;

/**
 * @brief Collection of blood pressure measurements
 * @chinese 血压测量集合
 *
 * @discussion
 * [EN]: Array of blood pressure measurements synchronized from the device.
 * Each entry contains a timestamp, systolic and diastolic values in mmHg.
 * 
 * [CN]: 从设备同步的血压测量数组。
 * 每个条目包含时间戳、收缩压和舒张压值(mmHg)。
 */
@property (nonatomic, strong) NSArray<TSBPValueModel *> * allBloodPressures;

/**
 * @brief Error information for blood pressure data synchronization
 * @chinese 血压数据同步的错误信息
 *
 * @discussion
 * [EN]: Contains error details if blood pressure data synchronization failed.
 * Nil if synchronization was successful.
 * 
 * [CN]: 如果血压数据同步失败，则包含错误详情。
 * 如果同步成功，则为nil。
 */
@property (nonatomic, strong) NSError * bloodPressuresError;

/**
 * @brief Collection of stress measurements
 * @chinese 压力测量集合
 *
 * @discussion
 * [EN]: Array of stress level measurements synchronized from the device.
 * Each entry contains a timestamp and stress level value.
 * 
 * [CN]: 从设备同步的压力水平测量数组。
 * 每个条目包含时间戳和压力水平值。
 */
@property (nonatomic, strong) NSArray<TSStressValueModel *> * allStresses;

/**
 * @brief Error information for stress data synchronization
 * @chinese 压力数据同步的错误信息
 *
 * @discussion
 * [EN]: Contains error details if stress data synchronization failed.
 * Nil if synchronization was successful.
 * 
 * [CN]: 如果压力数据同步失败，则包含错误详情。
 * 如果同步成功，则为nil。
 */
@property (nonatomic, strong) NSError * stressesError;

/**
 * @brief Collection of sleep records
 * @chinese 睡眠记录集合
 *
 * @discussion
 * [EN]: Array of sleep records synchronized from the device.
 * Each entry contains detailed sleep stage data and sleep quality metrics.
 * 
 * [CN]: 从设备同步的睡眠记录数组。
 * 每个条目包含详细的睡眠阶段数据和睡眠质量指标。
 */
@property (nonatomic, strong) NSArray<TSSleepModel *> * allSleeps;

/**
 * @brief Error information for sleep data synchronization
 * @chinese 睡眠数据同步的错误信息
 *
 * @discussion
 * [EN]: Contains error details if sleep data synchronization failed.
 * Nil if synchronization was successful.
 * 
 * [CN]: 如果睡眠数据同步失败，则包含错误详情。
 * 如果同步成功，则为nil。
 */
@property (nonatomic, strong) NSError * sleepsError;

/**
 * @brief Collection of temperature measurements
 * @chinese 体温测量集合
 *
 * @discussion
 * [EN]: Array of temperature measurements synchronized from the device.
 * Each entry contains a timestamp and temperature values in Celsius.
 * 
 * [CN]: 从设备同步的体温测量数组。
 * 每个条目包含时间戳和摄氏度温度值。
 */
@property (nonatomic, strong) NSArray<TSTemperatureValueModel *> * allTemperatures;

/**
 * @brief Error information for temperature data synchronization
 * @chinese 体温数据同步的错误信息
 *
 * @discussion
 * [EN]: Contains error details if temperature data synchronization failed.
 * Nil if synchronization was successful.
 * 
 * [CN]: 如果体温数据同步失败，则包含错误详情。
 * 如果同步成功，则为nil。
 */
@property (nonatomic, strong) NSError * temperaturesError;

/**
 * @brief Collection of electrocardiogram (ECG) records
 * @chinese 心电图记录集合
 *
 * @discussion
 * [EN]: Array of ECG records synchronized from the device.
 * Each entry contains waveform data and cardiac analysis metrics.
 * 
 * [CN]: 从设备同步的心电图记录数组。
 * 每个条目包含波形数据和心脏分析指标。
 */
@property (nonatomic, strong) NSArray<TSElectrocardioModel *> * allElectrocardios;

/**
 * @brief Error information for ECG data synchronization
 * @chinese 心电图数据同步的错误信息
 *
 * @discussion
 * [EN]: Contains error details if ECG data synchronization failed.
 * Nil if synchronization was successful.
 * 
 * [CN]: 如果心电图数据同步失败，则包含错误详情。
 * 如果同步成功，则为nil。
 */
@property (nonatomic, strong) NSError * electrocardiosError;

/**
 * @brief Collection of daily activity records
 * @chinese 每日活动记录集合
 *
 * @discussion
 * [EN]: Array of daily activity records synchronized from the device.
 * Each entry contains steps, distance, calories, and activity duration metrics.
 * 
 * [CN]: 从设备同步的每日活动记录数组。
 * 每个条目包含步数、距离、卡路里和活动持续时间指标。
 */
@property (nonatomic, strong) NSArray<TSDailyActivityValueModel *> * allDailyActivities;

/**
 * @brief Error information for daily activity data synchronization
 * @chinese 每日活动数据同步的错误信息
 *
 * @discussion
 * [EN]: Contains error details if daily activity data synchronization failed.
 * Nil if synchronization was successful.
 * 
 * [CN]: 如果每日活动数据同步失败，则包含错误详情。
 * 如果同步成功，则为nil。
 */
@property (nonatomic, strong) NSError * dailyActivitiesError;

/**
 * @brief Collection of sport workout records
 * @chinese 运动锻炼记录集合
 *
 * @discussion
 * [EN]: Array of sport workout records synchronized from the device.
 * Each entry contains detailed metrics for specific workout sessions.
 * 
 * [CN]: 从设备同步的运动锻炼记录数组。
 * 每个条目包含特定锻炼会话的详细指标。
 */
@property (nonatomic, strong) NSArray<TSSportModel *> * allSports;

/**
 * @brief Error information for sport data synchronization
 * @chinese 运动数据同步的错误信息
 *
 * @discussion
 * [EN]: Contains error details if sport data synchronization failed.
 * Nil if synchronization was successful.
 * 
 * [CN]: 如果运动数据同步失败，则包含错误详情。
 * 如果同步成功，则为nil。
 */
@property (nonatomic, strong) NSError * sportError;

@end

NS_ASSUME_NONNULL_END
