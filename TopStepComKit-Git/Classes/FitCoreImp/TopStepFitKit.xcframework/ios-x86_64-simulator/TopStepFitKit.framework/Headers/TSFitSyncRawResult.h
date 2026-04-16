//
//  TSFitSyncRawResult.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/25.
//

#import <Foundation/Foundation.h>

@class FitCloudManualSyncRecordObject;
@class FitCloudRestingHRValue;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Raw result from device data synchronization
 * @chinese 设备数据同步的原始结果
 *
 * 封装所有数据源的同步结果，后续新增数据源只需加属性，completion 签名不变。
 */
@interface TSFitSyncRawResult : NSObject

/**
 * @brief Records from manualSyncDataWithOption
 * @chinese manualSyncDataWithOption 返回的全量同步记录
 */
@property (nonatomic, copy, nullable) NSArray<FitCloudManualSyncRecordObject *> *records;

/**
 * @brief Resting heart rate values from queryRestingHRWithCompletion
 * @chinese queryRestingHRWithCompletion 返回的静息心率数据
 */
@property (nonatomic, copy, nullable) NSArray<FitCloudRestingHRValue *> *restingHRValues;

@end

NS_ASSUME_NONNULL_END
