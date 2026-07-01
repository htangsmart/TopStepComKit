//
//  TSAutoMonitorConfigs+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/24.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudHTMSingleObject;
@class FitCloudHTMObject;
@class FitCloudHRVMonitorConfigModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSAutoMonitorConfigs (Fit)

#pragma mark - Single HTM (新接口)

+ (TSAutoMonitorConfigs *)temperatureConfigsWithTMSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmObjects;

+ (TSAutoMonitorConfigs *)bloodOxygenConfigsWithTMSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmObjects;

+ (TSAutoMonitorConfigs *)stressConfigsWithTMSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmObjects;


+ (FitCloudHTMSingleObject *)fitHtmSingleObjectWithBloodOxygenConfigs:(TSAutoMonitorConfigs *)configs;

+ (FitCloudHTMSingleObject *)fitHtmSingleObjectWithStressConfigs:(TSAutoMonitorConfigs *)configs;

+ (FitCloudHTMSingleObject *)fitHtmSingleObjectWithTemperatureConfigs:(TSAutoMonitorConfigs *)configs;

#pragma mark - HTM Object (旧接口)

/**
 * @brief Convert FitCloudHTMObject to TSAutoMonitorConfigs
 * @chinese 将FitCloudHTMObject转换为TSAutoMonitorConfigs
 *
 * @param htmObject
 * EN: FitCloudHTMObject to be converted
 * CN: 需要转换的FitCloudHTMObject对象
 *
 * @return
 * EN: Converted TSAutoMonitorConfigs object, nil if conversion fails
 * CN: 转换后的TSAutoMonitorConfigs对象，转换失败时返回nil
 */
+ (nullable TSAutoMonitorConfigs *)configsWithHTMObject:(nullable FitCloudHTMObject *)htmObject;

/**
 * @brief Convert TSAutoMonitorConfigs to FitCloudHTMObject
 * @chinese 将TSAutoMonitorConfigs转换为FitCloudHTMObject
 *
 * @param configs
 * EN: TSAutoMonitorConfigs to be converted
 * CN: 需要转换的TSAutoMonitorConfigs对象
 *
 * @return
 * EN: Converted FitCloudHTMObject, nil if conversion fails
 * CN: 转换后的FitCloudHTMObject对象，转换失败时返回nil
 */
+ (nullable FitCloudHTMObject *)fitHtmObjectWithConfigs:(nullable TSAutoMonitorConfigs *)configs;

#pragma mark - HRV (心率变异性)

/**
 * @brief Convert FitCloudHRVMonitorConfigModel to TSAutoMonitorConfigs
 * @chinese 将 FitCloud HRV 配置模型转换为 TSAutoMonitorConfigs
 *
 * @param model
 * [EN]: FitCloudHRVMonitorConfigModel returned by FitCloudKit query API.
 * [CN]: FitCloudKit query 接口回调的 HRV 配置模型。
 *
 * @return
 * [EN]: Converted TSAutoMonitorConfigs (alert is left nil — HRV has no
 *       threshold-based alert on Fit side). Returns nil if input is nil.
 * [CN]: 转换后的 TSAutoMonitorConfigs（alert 留 nil——Fit 端 HRV 无阈值
 *       告警概念）。入参为 nil 时返回 nil。
 */
+ (nullable TSAutoMonitorConfigs *)hrvConfigsWithFitModel:(nullable FitCloudHRVMonitorConfigModel *)model;

/**
 * @brief Convert TSAutoMonitorConfigs to FitCloudHRVMonitorConfigModel
 * @chinese 将 TSAutoMonitorConfigs 转换为 FitCloud HRV 配置模型
 *
 * @param configs
 * [EN]: Source configuration. Only `schedule` is mapped; `alert` is ignored
 *       because Fit-side HRV has no alert field.
 * [CN]: 源配置。仅 `schedule` 参与映射；`alert` 被忽略，因为 Fit 端 HRV
 *       没有对应的告警字段。
 *
 * @return
 * [EN]: FitCloudHRVMonitorConfigModel ready for setHRVTimingMonitor:.
 *       Returns nil if input is nil.
 * [CN]: 可直接传给 setHRVTimingMonitor: 的 FitCloud 模型。入参为 nil
 *       时返回 nil。
 */
+ (nullable FitCloudHRVMonitorConfigModel *)fitHRVModelWithConfigs:(nullable TSAutoMonitorConfigs *)configs;

@end

NS_ASSUME_NONNULL_END
