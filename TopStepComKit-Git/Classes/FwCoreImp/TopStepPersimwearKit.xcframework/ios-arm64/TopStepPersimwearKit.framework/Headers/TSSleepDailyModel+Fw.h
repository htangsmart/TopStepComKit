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
 * EN: Array of dictionaries containing sleep data from FW SDK with:
 * - ts: Timestamp in seconds
 * - d: Array or JSON string containing sleep stage items, each item has:
 *   - s: Start time in seconds
 *   - t: Sleep stage type (0=Awake, 1=Light, 2=Deep, 3=REM)
 *   - d: Duration in seconds
 * CN: 包含FW SDK睡眠数据的字典数组，包含：
 * - ts: 时间戳（秒）
 * - d: 包含睡眠阶段项的数组或JSON字符串，每个项包含：
 *   - s: 开始时间（秒）
 *   - t: 睡眠阶段类型（0=清醒, 1=浅睡, 2=深睡, 3=快速眼动）
 *   - d: 持续时间（秒）
 *
 * @return 
 * EN: Array of converted TSSleepDetailItem objects, nil if conversion fails
 * CN: 转换后的TSSleepDetailItem对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSSleepDetailItem *> *)sleepDetailItemsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;

@end

NS_ASSUME_NONNULL_END
