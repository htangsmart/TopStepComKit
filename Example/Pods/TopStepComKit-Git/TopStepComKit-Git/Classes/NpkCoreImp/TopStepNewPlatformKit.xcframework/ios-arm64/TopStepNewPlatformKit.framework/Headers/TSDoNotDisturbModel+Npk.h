//
//  TSDoNotDisturbModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/8/29.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/PbConfigParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSDoNotDisturbModel (Npk)

/**
 * @brief Convert TSMetaDndModel to TSDoNotDisturbModel
 * @chinese 将 TSMetaDndModel 转换为 TSDoNotDisturbModel
 *
 * @param metaModel 
 * EN: Source TSMetaDndModel object
 * CN: 源 TSMetaDndModel 对象
 *
 * @return 
 * EN: Converted TSDoNotDisturbModel object
 * CN: 转换后的 TSDoNotDisturbModel 对象
 */
+ (TSDoNotDisturbModel *)modelFromMetaDndModel:(TSMetaDndModel *)metaModel;

/**
 * @brief Convert TSDoNotDisturbModel to TSMetaDndModel
 * @chinese 将 TSDoNotDisturbModel 转换为 TSMetaDndModel
 *
 * @return 
 * EN: Converted TSMetaDndModel object
 * CN: 转换后的 TSMetaDndModel 对象
 */
- (TSMetaDndModel *)toMetaDndModel;

@end

NS_ASSUME_NONNULL_END
