//
//  TSSleepDetailItem+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/9.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSMetaSleepDay;

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepDetailItem (Npk)

/**
 * 将 TSMetaSleepDay 转换为与 TSSleepTable 字段一致的字典数组
 * userID/macAddress 由调用方传入
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromMetaSleepDay:(TSMetaSleepDay *)sleepDay;

/**
 * 将 TSMetaSleepDay 数组转换为与 TSSleepTable 字段一致的字典数组
 * @chinese 将 TSMetaSleepDay 数组转换为字典数组
 *
 * @param sleepDayArray TSMetaSleepDay 数组
 *        EN: Array of TSMetaSleepDay objects to be converted
 *        CN: 需要转换的 TSMetaSleepDay 对象数组
 *
 * @return 字典数组，每个字典对应一个睡眠数据项
 *        EN: Array of dictionaries, each dictionary corresponds to a sleep data item
 *        CN: 字典数组，每个字典对应一个睡眠数据项
 *
 * @discussion
 * [EN]: Converts an array of TSMetaSleepDay objects to an array of dictionaries.
 *       Each TSMetaSleepDay is converted using dictionaryArrayFromMetaSleepDay:,
 *       and all results are merged into a single array.
 * [CN]: 将 TSMetaSleepDay 对象数组转换为字典数组。
 *       每个 TSMetaSleepDay 使用 dictionaryArrayFromMetaSleepDay: 方法转换，
 *       所有结果合并成一个数组。
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromMetaSleepDayArray:(NSArray<TSMetaSleepDay *> *)sleepDayArray;


@end

NS_ASSUME_NONNULL_END
