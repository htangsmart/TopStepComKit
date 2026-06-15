//
//  TSHRVValueItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/05/29.
//

#import "TSHealthValueItem.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - TSHRVStatus

/**
 * @brief HRV status classification
 * @chinese HRV 状态分类
 *
 * @discussion
 * [EN]: Categorizes HRV reading against the user's personal baseline.
 *       Not a linear severity scale — it's a categorical assessment.
 *       Status is typically evaluated at the day level, not per single sample.
 * [CN]: 基于个人基线对 HRV 读数进行分类。不是线性严重程度刻度，而是分类评估。
 *       状态通常以"日"为单位评估，不针对单条样本。
 */
typedef NS_ENUM(NSUInteger, TSHRVStatus) {
    /** @brief No status / not assessed @chinese 无状态 / 未评估 */
    TSHRVStatusNone             = 0,
    /** @brief Poor — significantly below healthy range @chinese 差 — 显著低于健康范围 */
    TSHRVStatusPoor             = 1,
    /** @brief Low — below baseline lower bound @chinese 低 — 低于基线下限 */
    TSHRVStatusLow              = 2,
    /** @brief Imbalanced, skewed high — above baseline upper bound @chinese 不平衡偏高 — 高于基线上限 */
    TSHRVStatusImbalancedHigh   = 3,
    /** @brief Imbalanced, skewed low — between low and baseline lower @chinese 不平衡偏低 — 介于"低"与基线下限之间 */
    TSHRVStatusImbalancedLow    = 4,
    /** @brief Balanced — within healthy baseline range @chinese 平衡 — 处于健康基线范围内 */
    TSHRVStatusBalanced         = 5,
    /** @brief Data abnormal / invalid @chinese 数据异常 */
    TSHRVStatusInvalid          = 6,
};

#pragma mark - TSHRVValueItem

/**
 * @brief Single HRV (Heart Rate Variability) sample / segment
 * @chinese 单条心率变异性（HRV）测量或时段模型
 *
 * @discussion
 * [EN]: `hrvValue` is in milliseconds (RMSSD); inherits timing and `valueType`
 *       from `TSHealthValueItem`. DB field `value` maps to `hrvValue` in
 *       `valueItemFromDBDict:`.
 * [CN]: `hrvValue` 单位为毫秒（RMSSD 口径）；时间与 `valueType` 继承自
 *       `TSHealthValueItem`。库表字段 `value` 在 `valueItemFromDBDict:` 中
 *       映射为 `hrvValue`。
 */
@interface TSHRVValueItem : TSHealthValueItem <NSCopying>

/**
 * @brief HRV value
 * @chinese HRV 值
 *
 * @discussion
 * [EN]: Heart rate variability measured in milliseconds (RMSSD).
 *       Typical range: 10-200 ms. Higher generally indicates better autonomic
 *       nervous system balance.
 * [CN]: 以毫秒（ms）为单位测量的心率变异性，采用 RMSSD 口径。
 *       常见范围 10-200ms。一般数值越高代表自主神经平衡越好。
 */
@property (nonatomic, assign) UInt16 hrvValue;

/**
 * @brief Indicates if the measurement was initiated by the user
 * @chinese 指示测量是否为用户主动发起
 *
 * @discussion
 * [EN]: YES means the sample came from a user-initiated measurement; NO means
 *       it was produced by automatic monitoring.
 * [CN]: YES 表示该样本来自用户主动发起的测量；NO 表示来自自动监测。
 */
@property (nonatomic, assign) BOOL isUserInitiated;

/**
 * @brief Map one DB row to an HRV item
 * @chinese 将单条数据库字典转为 TSHRVValueItem
 *
 * @param dict
 * EN: Keys such as `value` (ms), `valueType`, `startTime`, `endTime`,
 *     `duration`, `isUserInitiated`.
 * CN: 字段含 `value`（毫秒）、`valueType`、`startTime`、`endTime`、
 *     `duration`、`isUserInitiated` 等。
 *
 * @return
 * EN: Configured item, or nil if `dict` is nil.
 * CN: 填充后的模型；`dict` 为 nil 时返回 nil。
 */
+ (nullable TSHRVValueItem *)valueItemFromDBDict:(NSDictionary *)dict;

/**
 * @brief Map multiple DB rows to HRV items
 * @chinese 将多条数据库字典转为 TSHRVValueItem 数组
 *
 * @param dicts
 * EN: Array of HRV detail rows (same field layout as `valueItemFromDBDict:`).
 * CN: HRV 明细行字典数组，字段布局与 `valueItemFromDBDict:` 一致。
 *
 * @return
 * EN: Non-nil array; empty if input is nil/empty; invalid rows skipped.
 * CN: 非 nil 数组；入参为空时返回空数组，无法解析的行被跳过。
 */
+ (NSArray<TSHRVValueItem *> *)valueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Compact one-line debug string
 * @chinese 单行调试字符串
 *
 * @return
 * EN: HRV value, time range, user-initiated flag.
 * CN: HRV 值、起止时间、是否主动测量。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
