//
//  TSMessageModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>
#import <FitCloudKit/FitCloudNotificationApps.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSMessageModel (Fit)

/**
 * @brief Convert TSMessageModel array to FitCloudKit notification app set
 * @chinese 将 TSMessageModel 数组转换为 FitCloudKit 通知应用集合
 *
 * @param messages
 * EN: Array of TSMessageModel to be converted
 * CN: 要转换的 TSMessageModel 数组
 *
 * @return
 * EN: Set of FitCloudNotificationApp constants representing the enabled message types
 * CN: 表示已启用消息类型的 FitCloudNotificationApp 常量集合
 *
 * @discussion
 * EN: Only enabled (enable == YES) message types are included in the result.
 * CN: 仅 enable == YES 的消息类型会被包含在结果中。
 */
+ (NSSet<FitCloudNotificationApp> *)notificationAppsFromMessages:(NSArray<TSMessageModel *> *)messages;

/**
 * @brief Convert FitCloudKit notification app set to TSMessageModel array
 * @chinese 将 FitCloudKit 通知应用集合转换为 TSMessageModel 数组
 *
 * @param apps
 * EN: Set of FitCloudNotificationApp constants to be converted
 * CN: 要转换的 FitCloudNotificationApp 常量集合
 *
 * @return
 * EN: Array of TSMessageModel representing the enabled message types
 * CN: 表示已启用消息类型的 TSMessageModel 数组
 */
+ (NSArray<TSMessageModel *> *)messagesFromNotificationApps:(nullable NSSet<FitCloudNotificationApp> *)apps;

@end

NS_ASSUME_NONNULL_END
