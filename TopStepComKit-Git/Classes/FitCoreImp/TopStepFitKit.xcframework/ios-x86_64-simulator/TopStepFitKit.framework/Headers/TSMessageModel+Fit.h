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
 * @brief Convert TSMessageModel array to FITCLOUDMN
 * @chinese 将TSMessageModel数组转换为FITCLOUDMN
 *
 * @param messages 
 * EN: Array of TSMessageModel to be converted
 * CN: 要转换的TSMessageModel数组
 *
 * @return 
 * EN: FITCLOUDMN value representing the enabled message types
 * CN: 表示已启用消息类型的FITCLOUDMN值
 *
 * @discussion
 * EN: This method converts an array of TSMessageModel to a FITCLOUDMN value.
 *     Only enabled message types will be included in the result.
 * CN: 此方法将TSMessageModel数组转换为FITCLOUDMN值。
 *     只有已启用的消息类型会被包含在结果中。
 */
+ (FITCLOUDMN)fitCloudMNFromMessages:(NSArray<TSMessageModel *> *)messages;

/**
 * @brief Convert FITCLOUDMN to TSMessageModel array
 * @chinese 将FITCLOUDMN转换为TSMessageModel数组
 *
 * @param fitCloudMN 
 * EN: FITCLOUDMN value to be converted
 * CN: 要转换的FITCLOUDMN值
 *
 * @return 
 * EN: Array of TSMessageModel representing the enabled message types
 * CN: 表示已启用消息类型的TSMessageModel数组
 *
 * @discussion
 * EN: This method converts a FITCLOUDMN value to an array of TSMessageModel.
 *     Each enabled message type will be represented by a TSMessageModel instance.
 * CN: 此方法将FITCLOUDMN值转换为TSMessageModel数组。
 *     每个已启用的消息类型将由一个TSMessageModel实例表示。
 */
+ (NSArray<TSMessageModel *> *)messagesFromFitCloudMN:(FITCLOUDMN)fitCloudMN;

@end

NS_ASSUME_NONNULL_END
