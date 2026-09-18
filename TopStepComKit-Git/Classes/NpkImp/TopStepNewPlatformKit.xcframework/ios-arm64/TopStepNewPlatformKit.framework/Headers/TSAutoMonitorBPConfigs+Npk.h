//
//  TSAutoMonitorBPConfigs+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/4.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSMetaBloodPressureConfig;

@interface TSAutoMonitorBPConfigs (Npk)

/**
 * @brief 转换为底层血压监测配置
 * @chinese 将 TSAutoMonitorBPConfigs 转为 TSMetaBloodPressureConfig
 */
- (TSMetaBloodPressureConfig *)toMetaBloodPressureConfig;

/**
 * @brief 自底层血压监测配置生成血压配置
 * @chinese 将 TSMetaBloodPressureConfig 转为 TSAutoMonitorBPConfigs
 */
+ (TSAutoMonitorBPConfigs *)configsFromMetaBloodPressureConfig:(TSMetaBloodPressureConfig *)meta;

@end

NS_ASSUME_NONNULL_END
