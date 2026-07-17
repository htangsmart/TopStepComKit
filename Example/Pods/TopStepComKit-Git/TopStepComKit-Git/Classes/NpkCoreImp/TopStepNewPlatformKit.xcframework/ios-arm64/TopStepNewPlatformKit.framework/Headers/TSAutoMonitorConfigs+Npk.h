//
//  TSAutoMonitorConfigs+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/3.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSMetaBloodOxygenConfig;
@class TSMetaStressConfig;

@interface TSAutoMonitorConfigs (Npk)

/**
 * @brief 转换为底层血氧监测配置
 * @chinese 将 TSAutoMonitorConfigs 转为 TSMetaBloodOxygenConfig
 */
- (TSMetaBloodOxygenConfig *)toMetaBloodOxygenConfig;

/**
 * @brief 自底层血氧监测配置生成通用配置
 * @chinese 将 TSMetaBloodOxygenConfig 转为 TSAutoMonitorConfigs
 */
+ (TSAutoMonitorConfigs *)configsFromMetaBloodOxygenConfig:(TSMetaBloodOxygenConfig *)meta;

/**
 * @brief 转换为底层压力监测配置
 * @chinese 将 TSAutoMonitorConfigs 转为 TSMetaStressConfig
 */
- (TSMetaStressConfig *)toMetaStressConfig;

/**
 * @brief 自底层压力监测配置生成通用配置
 * @chinese 将 TSMetaStressConfig 转为 TSAutoMonitorConfigs
 */
+ (TSAutoMonitorConfigs *)configsFromMetaStressConfig:(TSMetaStressConfig *)meta;

@end

NS_ASSUME_NONNULL_END
