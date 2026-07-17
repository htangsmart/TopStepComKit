//
//  TSAutoMonitorHRConfigs+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/4.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSMetaHeartRateConfig;

@interface TSAutoMonitorHRConfigs (Npk)

/**
 * @brief 转换为底层心率监测配置
 * @chinese 将 TSAutoMonitorHRConfigs 转为 TSMetaHeartRateConfig
 */
- (TSMetaHeartRateConfig *)toMetaHeartRateConfig;

/**
 * @brief 自底层心率监测配置生成心率配置
 * @chinese 将 TSMetaHeartRateConfig 转为 TSAutoMonitorHRConfigs
 */
+ (TSAutoMonitorHRConfigs *)configsFromMetaHeartRateConfig:(TSMetaHeartRateConfig *)meta;

@end

NS_ASSUME_NONNULL_END
