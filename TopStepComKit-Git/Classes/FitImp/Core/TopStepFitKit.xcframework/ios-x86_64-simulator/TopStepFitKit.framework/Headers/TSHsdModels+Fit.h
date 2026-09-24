//
//  TSHsdModels+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/9/23.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Convert TSAlarmRepeat to FitCloud weekday bits
 * @chinese TSAlarmRepeat 转 FitCloud 星期位
 *
 * @discussion
 * [EN]: FITCLOUDREPEAT / FITCLOUDTASKCYCLE / FITCLOUDHABITCYCLE share TSAlarmRepeat's layout (bit0 = Monday … bit6 = Sunday),
 *       so the conversion is a plain mask.
 * [CN]: FITCLOUDREPEAT / FITCLOUDTASKCYCLE / FITCLOUDHABITCYCLE 与 TSAlarmRepeat 位定义一致（bit0=周一 … bit6=周日），直接掩码转换。
 */
static inline Byte TSFitHsdWeekBitsFromRepeat(TSAlarmRepeat repeat) { return (Byte)(repeat & 0x7F); }

/**
 * @brief Convert FitCloud weekday bits to TSAlarmRepeat
 * @chinese FitCloud 星期位转 TSAlarmRepeat
 */
static inline TSAlarmRepeat TSFitHsdRepeatFromWeekBits(Byte bits) { return (TSAlarmRepeat)(bits & 0x7F); }

#pragma mark - Parental Mode

/**
 * @brief Conversion between TSHsdParentalModeModel and FitCloudParentControlSettingsModel
 * @chinese TSHsdParentalModeModel 与 FitCloudParentControlSettingsModel 互转
 */
@interface TSHsdParentalModeModel (Fit)

/**
 * @brief Create a model from FitCloud parent control settings
 * @chinese 由 FitCloud 家长模式设置创建模型
 *
 * @param settings
 * EN: FitCloud parent control settings
 * CN: FitCloud 家长模式设置
 *
 * @return
 * EN: Converted model
 * CN: 转换后的模型
 */
+ (instancetype)modelWithFitCloudParentControlSettings:(FitCloudParentControlSettingsModel *)settings;

/**
 * @brief Convert to FitCloud parent control settings
 * @chinese 转换为 FitCloud 家长模式设置
 *
 * @return
 * EN: FitCloud parent control settings
 * CN: FitCloud 家长模式设置
 */
- (FitCloudParentControlSettingsModel *)toFitCloudParentControlSettings;

@end

#pragma mark - Classroom Mode

/**
 * @brief Conversion between TSHsdClassroomModeModel and FitCloudClassroomModeSettingsModel
 * @chinese TSHsdClassroomModeModel 与 FitCloudClassroomModeSettingsModel 互转
 */
@interface TSHsdClassroomModeModel (Fit)

/**
 * @brief Create a model from FitCloud classroom mode settings
 * @chinese 由 FitCloud 课堂模式设置创建模型
 *
 * @param settings
 * EN: FitCloud classroom mode settings
 * CN: FitCloud 课堂模式设置
 *
 * @return
 * EN: Converted model
 * CN: 转换后的模型
 */
+ (instancetype)modelWithFitCloudClassroomModeSettings:(FitCloudClassroomModeSettingsModel *)settings;

/**
 * @brief Convert to FitCloud classroom mode settings
 * @chinese 转换为 FitCloud 课堂模式设置
 *
 * @return
 * EN: FitCloud classroom mode settings
 * CN: FitCloud 课堂模式设置
 */
- (FitCloudClassroomModeSettingsModel *)toFitCloudClassroomModeSettings;

@end

#pragma mark - Task

/**
 * @brief Conversion between TSHsdTaskModel and FitCloudTaskModel
 * @chinese TSHsdTaskModel 与 FitCloudTaskModel 互转
 */
@interface TSHsdTaskModel (Fit)

/**
 * @brief Create a model from a FitCloud task
 * @chinese 由 FitCloud 任务创建模型
 *
 * @param task
 * EN: FitCloud task
 * CN: FitCloud 任务
 *
 * @return
 * EN: Converted model
 * CN: 转换后的模型
 */
+ (instancetype)modelWithFitCloudTask:(FitCloudTaskModel *)task;

/**
 * @brief Convert to a FitCloud task
 * @chinese 转换为 FitCloud 任务
 *
 * @return
 * EN: FitCloud task
 * CN: FitCloud 任务
 *
 * @discussion
 * [EN]: Call doesModelHasError and fitValidationError first; out-of-range values are truncated by the Byte fields.
 * [CN]: 调用前应先通过 doesModelHasError 与 fitValidationError 校验，越界值会被 Byte 字段截断。
 */
- (FitCloudTaskModel *)toFitCloudTask;

/**
 * @brief FitCloud-specific validation
 * @chinese FitCloud 特有的校验
 *
 * @return
 * EN: Parameter error when taskId / coins / type exceed the Byte range of FitCloudTaskModel, otherwise nil
 * CN: taskId / coins / type 超出 FitCloudTaskModel 的 Byte 范围时返回参数错误，否则为 nil
 */
- (nullable NSError *)fitValidationError;

@end

#pragma mark - Habit

/**
 * @brief Conversion between TSHsdHabitModel and FitCloudHabitObject
 * @chinese TSHsdHabitModel 与 FitCloudHabitObject 互转
 */
@interface TSHsdHabitModel (Fit)

/**
 * @brief Create a model from a FitCloud habit
 * @chinese 由 FitCloud 习惯创建模型
 *
 * @param habit
 * EN: FitCloud habit
 * CN: FitCloud 习惯
 *
 * @param habitId
 * EN: Habit id to assign (FitCloud habits carry no id; the list position is used)
 * CN: 要赋予的习惯 ID（FitCloud 习惯没有 ID，使用列表位置）
 *
 * @return
 * EN: Converted model
 * CN: 转换后的模型
 */
+ (instancetype)modelWithFitCloudHabit:(FitCloudHabitObject *)habit habitId:(NSInteger)habitId;

/**
 * @brief Convert to a FitCloud habit
 * @chinese 转换为 FitCloud 习惯
 *
 * @param error
 * EN: Set when FitCloudKit rejects the habit
 * CN: FitCloudKit 拒绝创建时写入错误
 *
 * @return
 * EN: FitCloud habit, nil if FitCloudKit rejects it
 * CN: FitCloud 习惯，FitCloudKit 拒绝创建时为 nil
 */
- (nullable FitCloudHabitObject *)toFitCloudHabitWithError:(NSError *_Nullable *_Nullable)error;

/**
 * @brief FitCloud-specific validation
 * @chinese FitCloud 特有的校验
 *
 * @return
 * EN: Parameter error when a field exceeds FitCloudHabitObject's UInt8 / UInt16 range, otherwise nil
 * CN: 字段超出 FitCloudHabitObject 的 UInt8 / UInt16 范围时返回参数错误，否则为 nil
 */
- (nullable NSError *)fitValidationError;

@end

#pragma mark - Usage

/**
 * @brief Build daily usage models from FitCloud statistics
 * @chinese 由 FitCloud 统计数据构建每日使用统计模型
 */
@interface TSHsdDailyUsageModel (Fit)

/**
 * @brief Convert FitCloud app usage statistics
 * @chinese 转换 FitCloud 应用使用统计
 *
 * @param statistics
 * EN: FitCloud app usage statistics, nil treated as empty
 * CN: FitCloud 应用使用统计，nil 视为空
 *
 * @return
 * EN: One model per day, newest first, days[i].dayOffset == i
 * CN: 每天一个模型，按日期由新到旧，days[i].dayOffset == i
 */
+ (NSArray<TSHsdDailyUsageModel *> *)modelsWithFitCloudAppUsageStatistics:(nullable FitCloudAppUsageCountStatisticsModel *)statistics;

/**
 * @brief Convert FitCloud game play statistics
 * @chinese 转换 FitCloud 游戏游玩统计
 *
 * @param statistics
 * EN: FitCloud game play statistics, nil treated as empty
 * CN: FitCloud 游戏游玩统计，nil 视为空
 *
 * @return
 * EN: One model per day, newest first, days[i].dayOffset == i
 * CN: 每天一个模型，按日期由新到旧，days[i].dayOffset == i
 */
+ (NSArray<TSHsdDailyUsageModel *> *)modelsWithFitCloudGamePlayStatistics:(nullable FitCloudGamePlayCountStatisticsModel *)statistics;

@end

#pragma mark - Game

/**
 * @brief Conversion from FitCloudGameItemObject
 * @chinese 由 FitCloudGameItemObject 转换
 */
@interface TSHsdGameRecordModel (Fit)

/**
 * @brief Create a model from a FitCloud game record
 * @chinese 由 FitCloud 游戏记录创建模型
 *
 * @param item
 * EN: FitCloud game record
 * CN: FitCloud 游戏记录
 *
 * @return
 * EN: Converted model
 * CN: 转换后的模型
 */
+ (instancetype)modelWithFitCloudGameItem:(FitCloudGameItemObject *)item;

@end

/**
 * @brief Conversion to FitCloudGameRankingTrend
 * @chinese 转换为 FitCloudGameRankingTrend
 */
@interface TSHsdGameRankingTrendModel (Fit)

/**
 * @brief Convert to a FitCloud game ranking trend
 * @chinese 转换为 FitCloud 游戏排名趋势
 *
 * @return
 * EN: FitCloud game ranking trend
 * CN: FitCloud 游戏排名趋势
 */
- (FitCloudGameRankingTrend *)toFitCloudGameRankingTrend;

@end

NS_ASSUME_NONNULL_END
