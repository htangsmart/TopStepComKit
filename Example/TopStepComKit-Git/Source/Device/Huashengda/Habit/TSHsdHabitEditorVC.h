//
//  TSHsdHabitEditorVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Habit editor (third level)
 * @chinese 习惯编辑页：类型分段 / 名称 / 计划（时间、时长、任务天数）/ 重复 / 提醒 / 关联功能；手表维护字段只读灰底
 *
 * @discussion
 * [CN]: 切到预置类型时清空标签；只读字段保存时原值带回。数值范围为 Demo 约定（§4.4）。
 */
@interface TSHsdHabitEditorVC : TSHsdBaseVC

/// 要编辑的习惯；nil 为新建
@property (nonatomic, strong, nullable) TSHsdHabitModel *habit;
/// 新建时分配的 habitId
@property (nonatomic, assign) NSInteger nextHabitId;
@property (nonatomic, copy, nullable) void (^onDone)(TSHsdHabitModel *habit);
@property (nonatomic, copy, nullable) void (^onDelete)(void);

@end

NS_ASSUME_NONNULL_END
