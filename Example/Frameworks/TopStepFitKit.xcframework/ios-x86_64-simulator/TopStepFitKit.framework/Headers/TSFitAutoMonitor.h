//
//  TSFitAutoMonitor.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/24.
//

#import "TSFitKitBase.h"
#import "TSAutoMonitorConfigs+Fit.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitAutoMonitor : TSFitKitBase

/**
 * @brief 获取自动监测设置
 * @chinese 获取自动监测设置
 * 
 * @param completion 
 * EN: Completion block that returns the auto monitor setting model and an error if any.
 * CN: 完成块，返回自动监测设置模型和可能的错误。
 */
+ (void)getAutoMonitorConfigsWithType:(TSMonitorType)monitorType completion:(void (^)(TSAutoMonitorConfigs * _Nullable, NSError * _Nullable))completion;

/**
 * @brief 设置自动监测设置
 * @chinese 设置自动监测设置
 * 
 * @param configs
 * EN: The auto monitor setting model to be set.
 * CN: 要设置的自动监测设置模型。
 * 
 * @param completion 
 * EN: Completion block that indicates the success or failure of the operation.
 * CN: 完成块，指示操作的成功或失败。
 */
+ (void)setAutoMonitorSetting:(nonnull TSAutoMonitorConfigs *)configs completion:(nonnull TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
