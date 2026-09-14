//
//  TSWristWakeUpModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/8/29.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/PbConfigParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWristWakeUpModel (Npk)

/**
 * @brief Convert TSMetaRaiseWakeupModel to TSWristWakeUpModel
 * @chinese 将 TSMetaRaiseWakeupModel 转换为 TSWristWakeUpModel
 *
 * @param metaModel 
 * EN: Source TSMetaRaiseWakeupModel object
 * CN: 源 TSMetaRaiseWakeupModel 对象
 *
 * @return 
 * EN: Converted TSWristWakeUpModel object
 * CN: 转换后的 TSWristWakeUpModel 对象
 */
+ (TSWristWakeUpModel *)modelFromMetaRaiseWakeupModel:(TSMetaRaiseWakeupModel *)metaModel;

/**
 * @brief Convert TSWristWakeUpModel to TSMetaRaiseWakeupModel
 * @chinese 将 TSWristWakeUpModel 转换为 TSMetaRaiseWakeupModel
 *
 * @return 
 * EN: Converted TSMetaRaiseWakeupModel object
 * CN: 转换后的 TSMetaRaiseWakeupModel 对象
 */
- (TSMetaRaiseWakeupModel *)toMetaRaiseWakeupModel;

@end

NS_ASSUME_NONNULL_END
