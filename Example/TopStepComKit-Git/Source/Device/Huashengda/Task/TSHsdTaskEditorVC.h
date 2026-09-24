//
//  TSHsdTaskEditorVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Task editor (third level)
 * @chinese 任务编辑页：顶部手表示意实时预览；类型 / 标签 / 描述 / 时间 / 重复 / 金币 / 启用；手表维护字段只读
 *
 * @discussion
 * [CN]: 「完成」只把草稿交回列表页（onDone），真正下发在列表页的保存条。类型选择复用闹钟页的 TSAlarmTypePickerVC。
 */
@interface TSHsdTaskEditorVC : TSHsdBaseVC

/// 要编辑的任务；nil 为新建（页面自建默认值，taskId 由 nextTaskId 提供）
@property (nonatomic, strong, nullable) TSHsdTaskModel *task;
/// 新建时分配的 taskId（现有最大值 + 1）
@property (nonatomic, assign) NSInteger nextTaskId;
/// 设备支持的类型集合（fetchSupportedAlarmTypes:），nil 视为全部可选
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *supportedTypes;
/// 点「完成」
@property (nonatomic, copy, nullable) void (^onDone)(TSHsdTaskModel *task);
/// 点「删除任务」（仅编辑已有任务时出现）
@property (nonatomic, copy, nullable) void (^onDelete)(void);

@end

NS_ASSUME_NONNULL_END
