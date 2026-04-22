//
//  TSAutoMonitorBPConfigs+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/14.
//

#import "TSAutoMonitorBPConfigs.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSAutoMonitorBPConfigs (Fw)


- (NSDictionary *)settingParam;

/**
 * 将FW字典转换为TSAutoMonitorBloodPressureModel对象
 * @param fwDict FW返回的字典数据，包含基本监测设置和血压报警设置
 * @return TSAutoMonitorBloodPressureModel对象
 *
 * @discussion
 * fwDict结构：
 * {
 *   isEnabled: true,  // 是否开启
 *   start: 600,       // 开始时间（分钟）
 *   end: 900,         // 结束时间（分钟）
 *   interval: 10,     // 间隔时间（分钟）
 *   alarm: {          // 报警设置
 *     isEnabled: true,
 *     sbpMin: 50,     // 收缩压最小值（0表示不生效）
 *     sbpMax: 70,     // 收缩压最大值（0表示不生效）
 *     dbpMin: 50,     // 舒张压最小值（0表示不生效）
 *     dbpMax: 70      // 舒张压最大值（0表示不生效）
 *   }
 * }
 */
+ (TSAutoMonitorBPConfigs *)settingModelWithFwDict:(NSDictionary *)fwDict ;

@end

NS_ASSUME_NONNULL_END
