//
//  TSHRValueItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import <Foundation/Foundation.h>
#import "TSHealthValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Single heart rate sample / segment
 * @chinese 单条心率测量或时段模型
 *
 * @discussion
 * [EN]: `hrValue` is BPM; inherits timing and `valueType` from `TSHealthValueItem`.
 * DB field `value` maps to `hrValue` in `valueItemFromDBDict:`.
 *
 * [CN]: `hrValue` 为每分钟心跳数；时间与 `valueType` 继承自 `TSHealthValueItem`。
 * 库表字段 `value` 在 `valueItemFromDBDict:` 中映射为 `hrValue`。
 */
@interface TSHRValueItem : TSHealthValueItem <NSCopying>

/**
 * @brief Heart rate value
 * @chinese 心率值
 * 
 * @discussion
 * [EN]: The heart rate value measured in beats per minute (BPM).
 * [CN]: 以每分钟心跳次数（BPM）为单位测量的心率值。
 */
@property (nonatomic,assign) UInt8 hrValue;

/**
 * @brief Indicates if the measurement was initiated by the user
 * @chinese 指示测量是否为用户主动发起
 * 
 * @discussion
 * [EN]: A boolean value indicating whether the measurement was taken as initiated by the user.
 * [CN]: 布尔值，指示测量是否为用户主动发起的测量。
 */
@property (nonatomic,assign) BOOL isUserInitiated;


/**
 * @brief Map one DB row to a heart rate item
 * @chinese 将单条数据库字典转为 TSHRValueItem
 *
 * @param dict
 * EN: Keys such as `value` (BPM), `valueType`, `startTime`, `endTime`, `duration`, `isUserInitiated`.
 * CN: 字段含 `value`（BPM）、`valueType`、`startTime`、`endTime`、`duration`、`isUserInitiated` 等。
 *
 * @return
 * EN: Configured item, or nil if `dict` is nil.
 * CN: 填充后的模型；`dict` 为 nil 时返回 nil。
 */
+ (nullable TSHRValueItem *)valueItemFromDBDict:(NSDictionary *)dict;

/**
 * @brief Map multiple DB rows to heart rate items
 * @chinese 将多条数据库字典转为 TSHRValueItem 数组
 *
 * @param dicts
 * EN: Array of HR detail rows.
 * CN: 心率明细行字典数组。
 *
 * @return
 * EN: Non-nil array; empty if input nil/empty; invalid rows skipped.
 * CN: 非 nil 数组；入参为空时返回空数组。
 */
+ (NSArray<TSHRValueItem *> *)valueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Map sport heart-rate table rows (passive samples)
 * @chinese 将运动心率表行转为 TSHRValueItem（被动采集）
 *
 * @param dicts
 * EN: Rows from sport HR storage (same field layout as `valueItemFromDBDict:`).
 * CN: 运动心率表行，字段布局与 `valueItemFromDBDict:` 一致。
 *
 * @return
 * EN: Items with `isUserInitiated` forced to NO and `valueType` to `TSItemValueTypeNormal`.
 * CN: 结果项中 `isUserInitiated` 置 NO，`valueType` 置为普通数据。
 */
+ (NSArray<TSHRValueItem *> *)sportValueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Compact one-line debug string
 * @chinese 单行调试字符串
 *
 * @return
 * EN: HR value, value-type label, time range, duration, user-initiated flag.
 * CN: 心率值、类型标签、起止时间、时长、是否主动测量。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
