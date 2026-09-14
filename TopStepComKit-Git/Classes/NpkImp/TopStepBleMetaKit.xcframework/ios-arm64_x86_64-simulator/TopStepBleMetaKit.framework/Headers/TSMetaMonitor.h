//
//  TSMetaMonitor.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/3.
//

#import "TSBusinessBase.h"
#import "PbConfigParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSMetaHeartRateConfigCompletion)(TSMetaHeartRateConfig * _Nullable config, NSError * _Nullable error);
typedef void(^TSMetaBloodPressureConfigCompletion)(TSMetaBloodPressureConfig * _Nullable config, NSError * _Nullable error);
typedef void(^TSMetaBloodOxygenConfigCompletion)(TSMetaBloodOxygenConfig * _Nullable config, NSError * _Nullable error);
typedef void(^TSMetaStressConfigCompletion)(TSMetaStressConfig * _Nullable config, NSError * _Nullable error);

@interface TSMetaMonitor : TSBusinessBase

/**
 * @brief 获取心率监测配置信息
 * @chinese 获取心率监测配置信息
 *
 * @param completion
 * [EN]: Completion callback returning heart rate monitor config and error info.
 * [CN]: 完成回调，返回心率监测配置与错误信息。
 *
 * @discussion
 * [EN]: Reads the device-side heart rate monitoring configuration, including
 *       base monitor (enable/start/end/interval), exercise and resting alarms,
 *       and max HR threshold if supported.
 * [CN]: 读取设备端的心率监测配置，包括基础监测（开关/开始/结束/间隔）、
 *       运动与静息报警、以及最大心率阈值（若设备支持）。
 *
 * @note
 * [EN]: The returned fields depend on device capability and firmware version.
 * [CN]: 返回字段取决于设备能力与固件版本。
 */
+ (void)fetchHeartRateConfigWithCompletion:(nullable TSMetaHeartRateConfigCompletion)completion;

/**
 * @brief 推送心率监测配置信息
 * @chinese 推送心率监测配置信息
 *
 * @param config
 * [EN]: Heart rate monitor configuration to push to the device.
 * [CN]: 要推送到设备的心率监测配置。
 *
 * @param completion
 * [EN]: Completion callback indicating whether the operation succeeded and error info.
 * [CN]: 完成回调，指示操作是否成功与错误信息。
 */
+ (void)pushHeartRateConfig:(TSMetaHeartRateConfig *)config
                 completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief Register heart rate configuration change notification
 * @chinese 注册心率监测配置变化通知
 *
 * @param completion
 * [EN]: Completion callback returning updated heart rate config and error info.
 * [CN]: 完成回调，返回变更后的心率监测配置与错误信息。
 */
+ (void)registerHeartRateConfigDidChanged:(void(^)(TSMetaHeartRateConfig * _Nullable config, NSError * _Nullable error))completion;

/**
 * @brief 获取血压监测配置信息
 * @chinese 获取血压监测配置信息
 *
 * @param completion
 * [EN]: Completion callback returning blood pressure monitor config and error info.
 * [CN]: 完成回调，返回血压监测配置与错误信息。
 */
+ (void)fetchBloodPressureConfigWithCompletion:(nullable TSMetaBloodPressureConfigCompletion)completion;

/**
 * @brief 推送血压监测配置信息
 * @chinese 推送血压监测配置信息
 *
 * @param config
 * [EN]: Blood pressure monitor configuration to push to the device.
 * [CN]: 要推送到设备的血压监测配置。
 *
 * @param completion
 * [EN]: Completion callback indicating whether the operation succeeded and error info.
 * [CN]: 完成回调，指示操作是否成功与错误信息。
 */
+ (void)pushBloodPressureConfig:(TSMetaBloodPressureConfig *)config
                    completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief Register blood pressure configuration change notification
 * @chinese 注册血压监测配置变化通知
 *
 * @param completion
 * [EN]: Completion callback returning updated blood pressure config and error info.
 * [CN]: 完成回调，返回变更后的血压监测配置与错误信息。
 */
+ (void)registerBloodPressureConfigDidChanged:(void(^)(TSMetaBloodPressureConfig * _Nullable config, NSError * _Nullable error))completion;

/**
 * @brief 获取血氧监测配置信息
 * @chinese 获取血氧监测配置信息
 *
 * @param completion
 * [EN]: Completion callback returning blood oxygen monitor config and error info.
 * [CN]: 完成回调，返回血氧监测配置与错误信息。
 */
+ (void)fetchBloodOxygenConfigWithCompletion:(nullable TSMetaBloodOxygenConfigCompletion)completion;

/**
 * @brief 推送血氧监测配置信息
 * @chinese 推送血氧监测配置信息
 *
 * @param config
 * [EN]: Blood oxygen monitor configuration to push to the device.
 * [CN]: 要推送到设备的血氧监测配置。
 *
 * @param completion
 * [EN]: Completion callback indicating whether the operation succeeded and error info.
 * [CN]: 完成回调，指示操作是否成功与错误信息。
 */
+ (void)pushBloodOxygenConfig:(TSMetaBloodOxygenConfig *)config
                   completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief Register blood oxygen configuration change notification
 * @chinese 注册血氧监测配置变化通知
 *
 * @param completion
 * [EN]: Completion callback returning updated blood oxygen config and error info.
 * [CN]: 完成回调，返回变更后的血氧监测配置与错误信息。
 */
+ (void)registerBloodOxygenConfigDidChanged:(void(^)(TSMetaBloodOxygenConfig * _Nullable config, NSError * _Nullable error))completion;

/**
 * @brief 获取压力监测配置信息
 * @chinese 获取压力监测配置信息
 *
 * @param completion
 * [EN]: Completion callback returning stress monitor config and error info.
 * [CN]: 完成回调，返回压力监测配置与错误信息。
 */
+ (void)fetchStressConfigWithCompletion:(nullable TSMetaStressConfigCompletion)completion;

/**
 * @brief 推送压力监测配置信息
 * @chinese 推送压力监测配置信息
 *
 * @param config
 * [EN]: Stress monitor configuration to push to the device.
 * [CN]: 要推送到设备的压力监测配置。
 *
 * @param completion
 * [EN]: Completion callback indicating whether the operation succeeded and error info.
 * [CN]: 完成回调，指示操作是否成功与错误信息。
 */
+ (void)pushStressConfig:(TSMetaStressConfig *)config
              completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief Register stress configuration change notification
 * @chinese 注册压力监测配置变化通知
 *
 * @param completion
 * [EN]: Completion callback returning updated stress config and error info.
 * [CN]: 完成回调，返回变更后的压力监测配置与错误信息。
 */
+ (void)registerStressConfigDidChanged:(void(^)(TSMetaStressConfig * _Nullable config, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
