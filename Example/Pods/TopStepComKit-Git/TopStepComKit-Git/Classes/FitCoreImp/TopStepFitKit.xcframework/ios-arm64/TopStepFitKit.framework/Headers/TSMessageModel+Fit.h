//
//  TSMessageModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSMessageModel (Fit)

/**
 * @brief Convert FITCLOUDMN to TSMessageModel array
 * @chinese 将FITCLOUDMN转换为TSMessageModel数组
 * 
 * @param messageNotifications 
 * EN: FITCLOUDMN value containing enabled message notifications
 * CN: 包含已启用消息通知的FITCLOUDMN值
 * 
 * @return 
 * EN: Array of TSMessageModel objects, each representing an enabled notification type
 * CN: TSMessageModel对象数组，每个对象代表一个已启用的通知类型
 * 
 * @discussion 
 * EN: This method converts the FITCLOUDMN bit flags to an array of TSMessageModel objects.
 *     Each bit in FITCLOUDMN corresponds to a specific notification type.
 *     Only enabled notifications (bits set to 1) will be included in the result array.
 * CN: 此方法将FITCLOUDMN位标志转换为TSMessageModel对象数组。
 *     FITCLOUDMN中的每个位对应一个特定的通知类型。
 *     只有已启用的通知（位值为1）才会包含在结果数组中。
 */
+ (NSArray<TSMessageModel *> *)messageModelsFromFitCloudMessageNotifications:(FITCLOUDMN)messageNotifications;

/**
 * @brief Convert TSMessageModel array to FITCLOUDMN
 * @chinese 将TSMessageModel数组转换为FITCLOUDMN
 * 
 * @param messageModels 
 * EN: Array of TSMessageModel objects to be converted
 * CN: 需要转换的TSMessageModel对象数组
 * 
 * @return 
 * EN: FITCLOUDMN value representing the enabled notifications
 * CN: 表示已启用通知的FITCLOUDMN值
 * 
 * @discussion 
 * EN: This method converts an array of TSMessageModel objects to FITCLOUDMN bit flags.
 *     Only enabled models (enable = YES) will be included in the result.
 *     If the array is empty or nil, FITCLOUDMN_NONE will be returned.
 * CN: 此方法将TSMessageModel对象数组转换为FITCLOUDMN位标志。
 *     只有已启用的模型（enable = YES）才会包含在结果中。
 *     如果数组为空或nil，将返回FITCLOUDMN_NONE。
 */
+ (FITCLOUDMN)fitCloudMessageNotificationsFromMessageModels:(nullable NSArray<TSMessageModel *> *)messageModels;

@end

NS_ASSUME_NONNULL_END
