//
//  TSSleepModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import <Foundation/Foundation.h>

#import "TSSleepConcreteModel.h"
#import "TSSleepNapModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Complete daily sleep data model
 * @chinese 完整的每日睡眠数据模型
 *
 * @discussion
 * [EN]: This class represents a complete 24-hour sleep record, including:
 * - Night sleep (20:00-09:00): Main sleep period
 * - Daytime naps (09:00-20:00): Optional nap periods
 *
 * Sleep data processing rules:
 * 1. With nap support:
 *    - Sleep sensor active 24 hours
 *    - Night sleep: 20:00-09:00
 *    - Daytime naps: 09:00-20:00
 *    - Valid nap criteria: 20min < duration <= 3h
 *
 * 2. Without nap support:
 *    - Sleep sensor active only 20:00-12:00
 *    - All sleep treated as night sleep
 *    - No nap records
 *
 * [CN]: 该类表示一个完整的24小时睡眠记录，包含：
 * - 夜间睡眠（20:00-09:00）：主要睡眠时段
 * - 日间小睡（09:00-20:00）：可选的小睡时段
 *
 * 睡眠数据处理规则：
 * 1. 支持小睡时：
 *    - 睡眠传感器全天开启
 *    - 夜间睡眠：20:00-09:00
 *    - 日间小睡：09:00-20:00
 *    - 有效小睡标准：20分钟 < 时长 <= 3小时
 *
 * 2. 不支持小睡时：
 *    - 睡眠传感器仅在20:00-12:00开启
 *    - 所有睡眠均视为夜间睡眠
 *    - 不记录小睡数据
 */
@interface TSSleepModel: NSObject

/**
 * @brief Night sleep data model
 * @chinese 夜间睡眠数据模型
 *
 * @discussion
 * [EN]: Contains detailed night sleep data:
 * - For devices with nap support: 20:00-09:00
 * - For devices without nap support: 20:00-12:00
 *
 * Data includes:
 * - Sleep summary (duration, quality score, stage distribution)
 * - Detailed sleep stage records
 * - Sleep efficiency analysis
 *
 * Note: Time range varies based on device capabilities
 *
 * [CN]: 包含详细的夜间睡眠数据：
 * - 支持小睡的设备：20:00-09:00
 * - 不支持小睡的设备：20:00-12:00
 *
 * 数据包括：
 * - 睡眠汇总（时长、质量评分、阶段分布）
 * - 详细的睡眠阶段记录
 * - 睡眠效率分析
 *
 * 注意：时间范围根据设备功能有所不同
 */
@property (nonatomic, strong) TSSleepConcreteModel *nightSleepModel;

/**
 * @brief Daytime nap data model
 * @chinese 日间小睡数据模型
 *
 * @discussion
 * [EN]: Contains daytime nap data:
 * - For devices with nap support: 09:00-20:00
 * - For devices without nap support: nil
 *
 * When supported, includes:
 * - Summary of all valid naps
 * - Individual nap records
 * - Nap analysis and patterns
 *
 * Valid nap criteria:
 * - Duration: 20min < nap <= 3h
 * - Wake intervals >= 30min separate naps
 *
 * [CN]: 包含日间小睡数据：
 * - 支持小睡的设备：09:00-20:00
 * - 不支持小睡的设备：nil
 *
 * 支持时包含：
 * - 所有有效小睡的汇总
 * - 独立的小睡记录
 * - 小睡分析和模式
 *
 * 有效小睡标准：
 * - 时长：20分钟 < 小睡 <= 3小时
 * - 清醒间隔 >= 30分钟视为不同小睡
 */
@property (nonatomic, strong) TSSleepNapModel *dayTimeSleepModel;

@end

NS_ASSUME_NONNULL_END
