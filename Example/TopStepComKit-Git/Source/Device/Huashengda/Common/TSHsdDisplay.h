//
//  TSHsdDisplay.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Display helpers for Huashengda pages
 * @chinese 华盛达页面的展示工具：枚举 → 本地化名称 / 图标 / 颜色，时间与字节数格式化，页面色相
 *
 * @discussion
 * [CN]: 所有枚举名称走 Localizable.strings（hsd.app.N / hsd.gametype.N / hsd.habit.type.N …），
 *       超出已知范围的取值统一显示「未知类型 (N)」，不会崩溃。
 */
@interface TSHsdDisplay : NSObject

#pragma mark - 枚举名称

/// TSHsdWatchApp → 名称（0–47），越界显示「未知类型 (N)」
+ (NSString *)appName:(NSInteger)type;
/// TSHsdGameType → 名称（0–24），越界显示「未知类型 (N)」
+ (NSString *)gameName:(NSInteger)type;
/// TSHsdHabitType → 名称
+ (NSString *)habitTypeName:(TSHsdHabitType)type;
/// TSHsdHabitState → 名称
+ (NSString *)habitStateName:(TSHsdHabitState)state;
/// TSHsdTaskState → 名称
+ (NSString *)taskStateName:(TSHsdTaskState)state;
/// TSHsdRankingTrend → 名称
+ (NSString *)trendName:(TSHsdRankingTrend)trend;
/// TSHsdHabitAssociatedFunction → 名称
+ (NSString *)associatedFunctionName:(TSHsdHabitAssociatedFunction)function;
/// TSHsdUsageDateSource → 短标签（设备 / 推算）
+ (NSString *)dateSourceName:(TSHsdUsageDateSource)source;
/// TSHsdParentalControlFunction → 名称（家长模式进阶版的受控动作）
+ (NSString *)parentalFunctionName:(TSHsdParentalControlFunction)function;
/// TSHsdParentalControlMode → 名称（时段内禁用 / 时段内允许）
+ (NSString *)parentalControlModeName:(TSHsdParentalControlMode)mode;

#pragma mark - 图标

/// 家长模式受控动作的 SF Symbol
+ (NSString *)symbolForParentalFunction:(TSHsdParentalControlFunction)function;
/// 习惯类型的 SF Symbol
+ (NSString *)symbolForHabitType:(TSHsdHabitType)type;
/// 游戏类型的 SF Symbol（近似映射）
+ (NSString *)symbolForGameType:(NSInteger)type;
/// 应用类型的 SF Symbol（近似映射）
+ (NSString *)symbolForApp:(NSInteger)type;
/// 按名称取 SF Symbol，iOS 13 以下返回 nil
+ (nullable UIImage *)symbolImage:(NSString *)name pointSize:(CGFloat)pointSize weight:(UIImageSymbolWeight)weight API_AVAILABLE(ios(13.0));

#pragma mark - 格式化

/// 分钟偏移 → "HH:mm"（越界时原样显示数字）
+ (NSString *)timeStringForMinute:(NSInteger)minute;
/// 分钟数 → "2 小时 30 分钟" 之类的时长文案
+ (NSString *)durationStringForMinutes:(NSInteger)minutes;
/// 重复位 → "每天 / 工作日 / 周末 / 周一 周三 / 仅一次"
+ (NSString *)repeatString:(TSAlarmRepeat)repeat;
/// UTF-8 字节数
+ (NSUInteger)utf8Length:(nullable NSString *)string;
/// "n / max 字节"
+ (NSString *)byteCountString:(nullable NSString *)string max:(NSUInteger)max;
/// "HH:mm"
+ (NSString *)clockString:(nullable NSDate *)date;
/// "M/d"
+ (NSString *)shortDateString:(nullable NSDate *)date;
/// "yyyy-MM-dd HH:mm"
+ (NSString *)fullDateString:(nullable NSDate *)date;
/// 使用统计日期键：0 → 今天，1 → 昨天，其余 M/d
+ (NSString *)dayLabelForOffset:(NSInteger)offset date:(nullable NSDate *)date;
/// 数字字体（SF Pro Rounded，iOS 13+；以下回退系统字体）
+ (UIFont *)roundedFontOfSize:(CGFloat)size weight:(UIFontWeight)weight;
/// 等宽字体（bit 位、指令码、日志）
+ (UIFont *)monoFontOfSize:(CGFloat)size;

#pragma mark - 颜色（§3.8 视觉规范）

+ (UIColor *)hueParental;
+ (UIColor *)hueClassroom;
+ (UIColor *)hueTask;
+ (UIColor *)hueHabit;
+ (UIColor *)hueUsage;
+ (UIColor *)hueGame;
+ (UIColor *)hueIce;
+ (UIColor *)hueTools;
+ (UIColor *)statusGood;
+ (UIColor *)statusWarn;
+ (UIColor *)statusBad;
/// 墨色：主按钮 / 一级文字
+ (UIColor *)ink;
/// 二级文字
+ (UIColor *)textSecondary;
/// 三级文字
+ (UIColor *)textTertiary;
/// 填充：输入框、轨道
+ (UIColor *)fill;
/// 卡片
+ (UIColor *)card;
/// 12% 透明度的色相底（图标块）
+ (UIColor *)tint12:(UIColor *)hue;
/// 任务状态色
+ (UIColor *)colorForTaskState:(TSHsdTaskState)state;
/// 习惯状态色
+ (UIColor *)colorForHabitState:(TSHsdHabitState)state;

@end

NS_ASSUME_NONNULL_END
