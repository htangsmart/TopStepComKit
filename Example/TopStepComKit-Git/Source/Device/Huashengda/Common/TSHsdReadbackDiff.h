//
//  TSHsdReadbackDiff.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 一处差异：字段、下发值、回读值
@interface TSHsdDiffItem : NSObject
@property (nonatomic, copy) NSString *field;
@property (nonatomic, copy) NSString *sent;
@property (nonatomic, copy) NSString *read;
+ (instancetype)itemWithField:(NSString *)field sent:(NSString *)sent read:(NSString *)read;
@end

/**
 * @brief set → get readback comparison
 * @chinese 下发模型与回读模型逐字段比对（产品方案 §3.2）
 *
 * @discussion
 * [CN]: 任务、习惯按 taskId / habitId 对齐，不按数组下标；手表维护的字段
 *       （任务 state，习惯 state / reachGoalDays / maxReachGoalDays / latestAchieveGoal* / achieveGoalRepeat）不计入差异。
 */
@interface TSHsdReadbackDiff : NSObject

+ (NSArray<TSHsdDiffItem *> *)diffParental:(TSHsdParentalModeModel *)sent read:(nullable TSHsdParentalModeModel *)read;
/// 进阶版家长模式：功能项按 function 对齐；每项比对 enabled / mode / 时段数与每个时段的开始、结束、重复
+ (NSArray<TSHsdDiffItem *> *)diffParentalControl:(TSHsdParentalControlModel *)sent read:(nullable TSHsdParentalControlModel *)read;
+ (NSArray<TSHsdDiffItem *> *)diffClassroom:(TSHsdClassroomModeModel *)sent read:(nullable TSHsdClassroomModeModel *)read;
+ (NSArray<TSHsdDiffItem *> *)diffTaskInfo:(TSHsdTaskInfoModel *)sent read:(nullable TSHsdTaskInfoModel *)read;
+ (NSArray<TSHsdDiffItem *> *)diffHabits:(NSArray<TSHsdHabitModel *> *)sent read:(nullable NSArray<TSHsdHabitModel *> *)read;

/// 差异面板：列出「字段 / 下发 / 回读」，页面以回读值为准
+ (void)presentDiff:(NSArray<TSHsdDiffItem *> *)items from:(UIViewController *)presenter;

@end

NS_ASSUME_NONNULL_END
