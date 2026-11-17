//
//  TSAutoMonitorBPConfigs+Fit.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/3.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface TSAutoMonitorBPConfigs (Fit)

/**
 * @brief Build blood pressure configuration from individual monitoring settings.
 * @chinese 根据独立监测设置生成血压配置。
 *
 * @param htmSingleObjects
 * EN: Individual monitoring settings returned by FitCloud.
 * CN: FitCloud 返回的独立监测设置。
 *
 * @param fitAlarm
 * EN: Optional blood pressure alarm settings.
 * CN: 可选的血压预警设置。
 *
 * @return
 * EN: The configuration, or nil when the blood pressure entry is missing.
 * CN: 血压配置，缺少血压项时返回 nil。
 */
+ (nullable TSAutoMonitorBPConfigs *)configWithHTMSingleObjects:(nullable NSArray<FitCloudHTMSingleObject *> *)htmSingleObjects
                                                        alarm:(nullable FitCloudBPAlarmObject *)fitAlarm;

/**
 * @brief Build blood pressure configuration from common monitoring settings.
 * @chinese 根据通用监测设置生成血压配置。
 *
 * @param htmObject
 * EN: Common monitoring settings returned by FitCloud.
 * CN: FitCloud 返回的通用监测设置。
 *
 * @param fitAlarm
 * EN: Optional blood pressure alarm settings.
 * CN: 可选的血压预警设置。
 *
 * @return
 * EN: The configuration, or nil when monitoring settings are missing.
 * CN: 血压配置，缺少监测设置时返回 nil。
 */
+ (nullable TSAutoMonitorBPConfigs *)configWithHtmObject:(nullable FitCloudHTMObject *)htmObject
                                                  alarm:(nullable FitCloudBPAlarmObject *)fitAlarm;

/**
 * @brief Apply blood pressure alarm settings.
 * @chinese 更新血压预警设置。
 *
 * @param fitAlarm
 * EN: Blood pressure alarm settings, or nil to clear the alarm field.
 * CN: 血压预警设置，传 nil 清除预警字段。
 */
- (void)applyFitBPAlarm:(nullable FitCloudBPAlarmObject *)fitAlarm;

/**
 * @brief Encode the blood pressure alarm settings for FitCloud.
 * @chinese 将血压预警设置转换为 FitCloud 指令对象。
 *
 * @param configs
 * EN: The blood pressure configuration to encode.
 * CN: 待转换的血压配置。
 *
 * @return
 * EN: The FitCloud alarm object, or nil when any threshold exceeds UInt8.
 * CN: FitCloud 预警对象，任一阈值超出 UInt8 时返回 nil。
 */
+ (nullable FitCloudBPAlarmObject *)fitHrAlarmObjectWihtConfigs:(TSAutoMonitorBPConfigs *)configs;

+ (FitCloudHTMObject *)fitHtmObjectWihtConfigs:(TSAutoMonitorBPConfigs *)configs ;

+ (FitCloudHTMSingleObject *)fitHtmSingleObjectWihtConfigs:(TSAutoMonitorBPConfigs *)configs ;

@end

NS_ASSUME_NONNULL_END
