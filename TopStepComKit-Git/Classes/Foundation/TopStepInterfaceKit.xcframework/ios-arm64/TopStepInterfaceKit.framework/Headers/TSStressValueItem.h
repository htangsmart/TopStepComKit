//
//  TSStressValueItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSHealthValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Single stress sample / segment model
 * @chinese 单条压力测量或时段模型
 *
 * @discussion
 * [EN]: Inherits time range and `valueType` from `TSHealthValueItem`; `stressValue` is the scalar level.
 * DB mapping uses key `value` for the numeric field when converting with `valueItemFromDBDict:`.
 *
 * [CN]: 继承 `TSHealthValueItem` 的时间范围与 `valueType`；`stressValue` 为压力水平标量。
 * 与库表互转时数值字段对应 `value` 键。
 */
@interface TSStressValueItem : TSHealthValueItem <NSCopying>

/**
 * @brief Stress level value
 * @chinese 压力水平值
 *
 * @discussion
 * [EN]: The stress level value measured on a scale, typically from 0 to 100.
 * [CN]: 通常在0到100的范围内测量的压力水平值。
 */
@property (nonatomic, assign) UInt8 stressValue;

/**
 * @brief Indicates if the measurement was initiated by the user
 * @chinese 指示测量是否为用户主动发起
 *
 * @discussion
 * [EN]: A boolean value indicating whether the measurement was taken as initiated by the user.
 * [CN]: 布尔值，指示测量是否为用户主动发起的测量。
 */
@property (nonatomic, assign) BOOL isUserInitiated;

/**
 * @brief Map multiple DB rows to value items
 * @chinese 将多条数据库字典转为 TSStressValueItem 数组
 *
 * @param dicts
 * EN: Array of row dictionaries compatible with `valueItemFromDBDict:`.
 * CN: 与 `valueItemFromDBDict:` 字段约定一致的字典数组。
 *
 * @return
 * EN: Non-nil array; empty if `dicts` is nil or empty; invalid rows skipped.
 * CN: 非 nil 数组；入参为空时返回空数组，无法解析的行被跳过。
 */
+ (NSArray<TSStressValueItem *> *)valueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Map one DB row to a value item
 * @chinese 将单条数据库字典转为 TSStressValueItem
 *
 * @param dict
 * EN: Row fields such as `value`, `valueType`, `startTime`, `endTime`, `duration`, `isUserInitiated`.
 * CN: 行字段，如 `value`、`valueType`、`startTime`、`endTime`、`duration`、`isUserInitiated`。
 *
 * @return
 * EN: Populated item, or nil if `dict` is nil.
 * CN: 填充后的模型；`dict` 为 nil 时返回 nil。
 */
+ (nullable TSStressValueItem *)valueItemFromDBDict:(NSDictionary *)dict;

/**
 * @brief One-line debug description
 * @chinese 单行调试描述
 *
 * @return
 * EN: String with class, stress value, timestamp, and user-initiated flag.
 * CN: 含类名、压力值、时间与是否主动测量的字符串。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
