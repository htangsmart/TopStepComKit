//
//  TSSJAutoMonitor.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <TopStepSJWatchKit/TopStepSJWatchKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface TSSJAutoMonitor : TSSJKitBase

/**
 * @brief 获取自动监测设置
 * @chinese 获取自动监测设置
 *
 * @param completion
 * EN: Completion block that returns the auto monitor setting model and an error if any.
 * CN: 完成块，返回自动监测设置模型和可能的错误。
 */
+ (void)getAutoMonitorSettingCompletion:(void (^)(TSAutoMonitorConfigs * _Nullable, NSError * _Nullable))completion;

/**
 * @brief 设置自动监测设置
 * @chinese 设置自动监测设置
 *
 * @param setting
 * EN: The auto monitor setting model to be set.
 * CN: 要设置的自动监测设置模型。
 *
 * @param completion
 * EN: Completion block that indicates the success or failure of the operation.
 * CN: 完成块，指示操作的成功或失败。
 */
+ (void)setAutoMonitorSetting:(nonnull TSAutoMonitorConfigs *)setting completion:(nonnull TSCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END
