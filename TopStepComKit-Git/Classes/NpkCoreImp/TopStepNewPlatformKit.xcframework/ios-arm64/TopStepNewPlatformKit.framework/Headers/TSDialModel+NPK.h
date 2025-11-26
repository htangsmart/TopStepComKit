//
//  TSDialModel+NPK.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/11/14.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSMetaDialItem;
@class TSMetaDialList;

NS_ASSUME_NONNULL_BEGIN

@interface TSDialModel (NPK)

/**
 * @brief Convert TSMetaDialItem to TSDialModel
 * @chinese 将 TSMetaDialItem 转换为 TSDialModel
 *
 * @param dialItem
 * EN: TSMetaDialItem object from device
 * CN: 设备返回的 TSMetaDialItem 对象
 *
 * @return
 * EN: Converted TSDialModel object, nil if conversion fails
 * CN: 转换后的 TSDialModel 对象，转换失败时返回 nil
 *
 * @discussion
 * [EN]: Converts a single TSMetaDialItem to TSDialModel.
 *       dialId is converted to NSString format.
 *       dialType is determined by isBuiltin flag.
 *       isCurrent is set from isSelect flag.
 * [CN]: 将单个 TSMetaDialItem 转换为 TSDialModel。
 *       dialId 转换为 NSString 格式。
 *       dialType 根据 isBuiltin 标志确定。
 *       isCurrent 从 isSelect 标志设置。
 */
+ (nullable TSDialModel *)modelFromMetaDialItem:(TSMetaDialItem *)dialItem;

/**
 * @brief Convert TSMetaDialList to TSDialModel array
 * @chinese 将 TSMetaDialList 转换为 TSDialModel 数组
 *
 * @param dialList
 * EN: TSMetaDialList object from device
 * CN: 设备返回的 TSMetaDialList 对象
 *
 * @return
 * EN: Array of TSDialModel objects, empty array if conversion fails
 * CN: TSDialModel 对象数组，转换失败时返回空数组
 *
 * @discussion
 * [EN]: Converts TSMetaDialList to an array of TSDialModel objects.
 *       Each item in the list is converted using modelFromMetaDialItem:.
 *       Invalid items are skipped during conversion.
 * [CN]: 将 TSMetaDialList 转换为 TSDialModel 对象数组。
 *       列表中的每个项目使用 modelFromMetaDialItem: 转换。
 *       转换过程中会跳过无效项目。
 */
+ (NSArray<TSDialModel *> *)modelsFromMetaDialList:(TSMetaDialList *)dialList;

@end

NS_ASSUME_NONNULL_END
