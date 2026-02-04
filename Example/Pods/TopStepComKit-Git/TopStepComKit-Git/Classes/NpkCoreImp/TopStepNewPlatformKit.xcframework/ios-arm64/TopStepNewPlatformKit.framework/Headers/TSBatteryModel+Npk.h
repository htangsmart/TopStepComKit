//
//  TSBatteryModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/8/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSMetaBatteryModel;

@interface TSBatteryModel (Npk)

/**
 * @brief Convert TSMetaBatteryModel to TSBatteryModel
 * @chinese 将 TSMetaBatteryModel 转换为 TSBatteryModel
 *
 * @param metaModel
 * EN: Source battery model from Meta layer
 * CN: 来自 Meta 层的电池模型
 *
 * @return
 * EN: Converted TSBatteryModel instance, or nil if input is nil
 * CN: 转换后的 TSBatteryModel 实例；若入参为 nil 则返回 nil
 *
 * @discussion
 * [EN]: Mapping rules
 *       - charging == YES -> TSBatteryStateCharging
 *       - percentage >= 100 and not charging -> TSBatteryStateFull
 *       - else -> TSBatteryStateUnConnectNoCharging
 * [CN]: 映射规则
 *       - charging 为 YES -> TSBatteryStateCharging
 *       - 不在充电且电量 >= 100 -> TSBatteryStateFull
 *       - 其他情况 -> TSBatteryStateUnConnectNoCharging
 */
 + (nullable TSBatteryModel *)npkModelFromMetaBattery:(nullable TSMetaBatteryModel *)metaModel;

@end
