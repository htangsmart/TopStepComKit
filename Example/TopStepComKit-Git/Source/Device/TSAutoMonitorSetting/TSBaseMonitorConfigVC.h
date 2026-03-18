//
//  TSBaseMonitorConfigVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRootVC.h"
#import "TSBaseVC.h"
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 自动监测配置页基类
 * 提供公共 UI（启用开关、监测计划、保存按钮）和交互工具（时间选择器、间隔选择器、数值输入）。
 * 子类只需实现 fetch/push 和额外的 alert section 即可。
 */
@interface TSBaseMonitorConfigVC : TSRootVC <UITableViewDelegate, UITableViewDataSource>

/// 监测计划（由基类管理）
@property (nonatomic, strong) TSMonitorSchedule *schedule;

/// 表格视图
@property (nonatomic, strong) UITableView *tableView;

/// 导航栏右侧保存按钮（无改动时灰色禁用，有改动后蓝色可点）
@property (nonatomic, strong) UIBarButtonItem *saveButton;

// ─── 子类调用 ───────────────────────────────────────────────

/// 有任意字段改动时调用，保存按钮高亮
- (void)ts_markDirty;

/// 停止加载状态（隐藏菊花、显示表格），fetch 失败时由子类手动调用
- (void)ts_stopLoading;

/// fetch 成功后调用（任意线程）
- (void)ts_configDidLoad;

/// push 成功后调用（任意线程）
- (void)ts_configDidSave;

/// push 失败后调用（任意线程）
- (void)ts_configSaveFailed:(nullable NSError *)error;

// ─── 子类必须实现 ─────────────────────────────────────────

/// 从设备获取配置
- (void)ts_fetchConfig;

/// 推送配置到设备
- (void)ts_pushConfig;

// ─── 子类实现额外 section（alert 配置）────────────────────

/// 额外 section 数量（默认 0）
- (NSInteger)ts_numberOfExtraSections;

/// 额外 section 标题
- (NSString *)ts_titleForExtraSection:(NSInteger)sectionIndex;

/// 额外 section 行数
- (NSInteger)ts_numberOfRowsInExtraSection:(NSInteger)sectionIndex;

/// 额外 section 的 cell
- (UITableViewCell *)ts_cellForExtraSection:(NSInteger)sectionIndex
                                        row:(NSInteger)row
                                  tableView:(UITableView *)tableView;

/// 额外 section 点击处理
- (void)ts_didSelectExtraSection:(NSInteger)sectionIndex row:(NSInteger)row;

// ─── 工具方法 ──────────────────────────────────────────────

/// 底部时间选择器（HH:mm），currentMinutes 为距零点的分钟数
- (void)ts_showTimePickerWithMinutes:(NSInteger)currentMinutes
                          completion:(void(^)(NSInteger newMinutes))completion;

/// 间隔选择器（5/10/15/20/30 分钟）
- (void)ts_showIntervalPickerWithCurrent:(NSInteger)current
                              completion:(void(^)(NSInteger newInterval))completion;

/// 数值输入框
- (void)ts_showNumberInputWithTitle:(NSString *)title
                          unitLabel:(NSString *)unit
                       currentValue:(NSInteger)value
                               minV:(NSInteger)minV
                               maxV:(NSInteger)maxV
                         completion:(void(^)(NSInteger newValue))completion;

/// 提示弹窗
- (void)ts_showAlertMsg:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
