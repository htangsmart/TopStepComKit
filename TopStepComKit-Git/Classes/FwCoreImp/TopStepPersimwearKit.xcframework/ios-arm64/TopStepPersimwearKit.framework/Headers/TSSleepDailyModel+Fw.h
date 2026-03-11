//
//  TSSleepDailyModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/12/10.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepDailyModel (Fw)

/**
 * @brief Convert array of dictionaries to array of TSSleepDetailItem objects
 * @chinese 将字典数组转换为TSSleepDetailItem对象数组
 *
 * @param dictArray 
 * EN: Array of dictionaries containing structured sleep data from FW SDK.
 * Each dictionary has:
 * - ts: Day record timestamp in seconds (Unix time)
 * - d: Array of sleep stage item dictionaries, each item has:
 *   - s: Start time in seconds
 *   - t: Sleep stage type (0=Awake, 1=Light, 2=Deep, 3=REM)
 *   - d: Duration in seconds
 *   - in: Belonging date timestamp (00:00:00) calculated by firmware with 20:00 boundary
 * CN: 包含FW SDK结构化睡眠数据的字典数组。每个字典包含：
 * - ts: 当日记录时间戳（秒，Unix时间）
 * - d: 睡眠阶段字典数组，每个阶段字典包含：
 *   - s: 开始时间（秒）
 *   - t: 睡眠阶段类型（0=清醒, 1=浅睡, 2=深睡, 3=快速眼动）
 *   - d: 持续时间（秒）
 *   - in: 固件根据20:00跨天规则计算好的所属日期零点时间戳（00:00:00）
 *
 * @return 
 * EN: Array of converted TSSleepDetailItem objects, nil if conversion fails
 * CN: 转换后的TSSleepDetailItem对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSSleepDetailItem *> *)sleepDetailItemsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;

@end

NS_ASSUME_NONNULL_END
