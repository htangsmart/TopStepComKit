//
//  TSMessageModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/2/26.
//

#import "TSMessageModel.h"
#import <SJWatchLib/SJWatchLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSMessageModel (SJ)

/**
 * @brief Convert WMMessageModel to TSMessageModel array
 * @chinese 将WMMessageModel转换为TSMessageModel数组
 *
 * @param wmModel 
 * EN: WMMessageModel to be converted
 * CN: 要转换的WMMessageModel对象
 *
 * @return 
 * EN: Array of TSMessageModel representing the enabled message types
 * CN: 表示已启用消息类型的TSMessageModel数组
 *
 * @discussion
 * EN: This method converts a WMMessageModel to an array of TSMessageModel.
 *     Each enabled message type will be represented by a TSMessageModel instance.
 * CN: 此方法将WMMessageModel转换为TSMessageModel数组。
 *     每个已启用的消息类型将由一个TSMessageModel实例表示。
 */
+ (NSArray<TSMessageModel *> *)messageModelsFromWMModel:(WMMessageModel *)wmModel;

/**
 * @brief Convert TSMessageModel array to WMMessageModel
 * @chinese 将TSMessageModel数组转换为WMMessageModel
 *
 * @param messages 
 * EN: Array of TSMessageModel to be converted
 * CN: 要转换的TSMessageModel数组
 *
 * @return 
 * EN: WMMessageModel representing the enabled message types
 * CN: 表示已启用消息类型的WMMessageModel对象
 *
 * @discussion
 * EN: This method converts an array of TSMessageModel to a WMMessageModel.
 *     Only enabled message types will be included in the result.
 * CN: 此方法将TSMessageModel数组转换为WMMessageModel。
 *     只有已启用的消息类型会被包含在结果中。
 */
+ (WMMessageModel *)wmModelFromMessages:(NSArray<TSMessageModel *> *)messages;

@end

NS_ASSUME_NONNULL_END
