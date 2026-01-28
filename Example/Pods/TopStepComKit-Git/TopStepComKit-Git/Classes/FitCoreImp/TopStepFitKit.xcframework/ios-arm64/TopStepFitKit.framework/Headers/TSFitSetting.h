//
//  TSFitSetting.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/20.
//

/**
 * TSFitSetting
 * 设备设置管理类，负责处理设备的各种设置项，包括佩戴习惯、提醒、亮屏等功能
 * 该类实现了TSSettingInterface协议中定义的所有设置相关方法
 */
#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitSetting : TSFitKitBase<TSSettingInterface>

@end

NS_ASSUME_NONNULL_END
