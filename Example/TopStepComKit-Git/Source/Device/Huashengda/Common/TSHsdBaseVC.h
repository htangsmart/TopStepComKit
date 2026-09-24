//
//  TSHsdBaseVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"
#import "TSHsdDisplay.h"
#import "TSHsdViews.h"
#import "TSHsdDock.h"
#import "TSHsdSheet.h"
#import "TSHsdCallLog.h"
#import "TSHsdErrorText.h"
#import "TSHsdReadbackDiff.h"
#import "TSHsdLocalCache.h"
#import "UIViewController+TSToast.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Base class of every Huashengda page
 * @chinese 华盛达页面基类：与 HTML 原型同构的「积木」页面
 *
 * @discussion
 * [CN]: 页面 = 大标题（系统大标题）+ 标题下小标签（chips）+ 竖向积木（sec / card / foot / banner …）+ 浮动保存条。
 *       子类实现 buildBlocks 返回积木数组；任何状态变化后调用 render 整页重建（与原型的 render() 一致，
 *       文本输入例外：输入时只更新草稿与保存条，不重建）。
 *       统一提供：右上角「接口日志」（最近一次失败带红点）与「重新读取」、未保存修改时返回确认、
 *       读取 / 保存的调用日志封装、错误态与加载态积木、主线程切换。
 */
@interface TSHsdBaseVC : TSBaseVC

#pragma mark - 配置（子类在 initData 里设置）

/// 页面色相（§3.8）
@property (nonatomic, strong) UIColor *hue;
/// 标题下的小标签，第一枚为色相底（如 @"bit29"、@"0x5A 读 · 0x5B 写"）
@property (nonatomic, copy, nullable) NSArray<NSString *> *chips;
/// 是否使用浮动保存条
@property (nonatomic, assign) BOOL usesDock;
/// 是否显示右上角「重新读取」
@property (nonatomic, assign) BOOL showsReloadButton;

#pragma mark - 状态

@property (nonatomic, assign, getter=isDirty) BOOL dirty;
@property (nonatomic, assign, getter=isSaving) BOOL saving;
/// 校验不通过时保存按钮禁用（子类在 render 前更新）
@property (nonatomic, assign) BOOL invalid;
@property (nonatomic, strong, readonly) TSHsdDock *dock;
@property (nonatomic, strong, readonly) TSHsdStackView *stack;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly, nullable) id<TSHuashengdaInterface> hsd;
@property (nonatomic, readonly) BOOL connected;

#pragma mark - 子类实现

/// 返回页面积木（不含 chips 行）
- (NSArray<UIView *> *)buildBlocks;
/// 进入页面 / 点「重新读取」时调用
- (void)reload;
/// 点保存条主按钮时调用
- (void)save;
/// 保存条状态（默认：saving → 保存中；未连接 → 离线胶囊；dirty → 修改；否则隐藏）
- (TSHsdDockState)dockState;
/// 保存条主按钮文案（默认「保存到手表」）
- (NSString *)dockButtonTitle;
/// 保存条左侧小字（nil 用默认）
- (nullable NSString *)dockSmall;

#pragma mark - 渲染

/// 整页重建
- (void)render;
/// 只刷新保存条
- (void)refreshDock;

#pragma mark - 积木工厂（对应原型 sec / foot / banner / card / row …）

- (TSHsdSecView *)sec:(NSString *)title right:(nullable NSString *)right;
- (TSHsdFootView *)foot:(NSString *)text;
- (TSHsdBannerView *)banner:(NSString *)text warn:(BOOL)warn;
- (TSHsdCardView *)card:(NSArray<UIView *> *)rows;
- (TSHsdCardView *)readOnlyGroup:(NSArray<UIView *> *)rows;
- (TSHsdRowView *)row;
/// 带图标的开关行
- (TSHsdRowView *)switchRowWithSymbol:(nullable NSString *)symbol color:(nullable UIColor *)color title:(NSString *)title subtitle:(nullable NSString *)subtitle on:(BOOL)on onToggle:(void (^)(BOOL on))onToggle;
/// 标题 + 右侧值 + 箭头
- (TSHsdRowView *)valueRowWithSymbol:(nullable NSString *)symbol color:(nullable UIColor *)color title:(NSString *)title value:(nullable NSString *)value onTap:(nullable void (^)(void))onTap;
/// 标题 + 时间胶囊
- (TSHsdRowView *)timeRowWithTitle:(NSString *)title minute:(NSInteger)minute onPick:(void (^)(NSInteger minute))onPick;
/// 标题 + 数值胶囊；点胶囊弹出数值滚轮（config.title 为空时用 title）
- (TSHsdRowView *)pickRowWithTitle:(NSString *)title subtitle:(nullable NSString *)subtitle config:(TSHsdValuePickConfig *)config value:(NSInteger)value onPick:(void (^)(NSInteger value))onPick;
/// 标题 + 数字输入 + 单位
- (TSHsdRowView *)numRowWithTitle:(NSString *)title subtitle:(nullable NSString *)subtitle value:(NSInteger)value unit:(NSString *)unit min:(NSInteger)min max:(NSInteger)max onChange:(void (^)(NSInteger value))onChange;
/// 字节计数输入
- (TSHsdFieldView *)fieldWithLabel:(NSString *)label text:(nullable NSString *)text maxBytes:(NSUInteger)maxBytes placeholder:(nullable NSString *)placeholder onChange:(void (^)(NSString *text))onChange;
/// 星期键 + 快捷键
- (TSHsdWeekdayView *)weekdays:(TSAlarmRepeat)repeat presets:(NSArray<TSHsdWeekdayPreset *> *)presets onChange:(void (^)(TSAlarmRepeat repeat))onChange;
/// 24 小时时间轴
- (TSHsdTimelineView *)timelineFrom:(NSInteger)start to:(NSInteger)end caption:(NSString *)caption;
/// 时间对
- (TSHsdDuoTimeView *)duoStart:(NSInteger)start end:(NSInteger)end onStart:(void (^)(NSInteger minute))onStart onEnd:(void (^)(NSInteger minute))onEnd;
/// 状态点
- (TSHsdStateLabel *)stateLabel:(NSString *)text color:(UIColor *)color;
/// 加载态积木
- (TSHsdLoadingView *)loadingBlock:(nullable NSString *)text;
/// 空态积木（放进 card）
- (TSHsdEmptyView *)emptyWithSymbol:(NSString *)symbol title:(NSString *)title text:(nullable NSString *)text code:(nullable NSString *)code;
/// 错误态积木（读取失败 / 分包不连续 + 重试）
- (TSHsdCardView *)errorBlock:(nullable NSError *)error retry:(nullable void (^)(void))retry;
/// 弹出底部时间面板
- (void)pickTime:(NSString *)title minute:(NSInteger)minute onPick:(void (^)(NSInteger minute))onPick;

#pragma mark - 工具

- (TSHsdCallLogEntry *)beginCall:(NSString *)method params:(nullable NSString *)params;
- (void)finishCall:(TSHsdCallLogEntry *)entry success:(BOOL)success error:(nullable NSError *)error result:(nullable NSString *)result;
- (void)toast:(NSString *)message;
- (void)confirmTitle:(NSString *)title message:(nullable NSString *)message confirmTitle:(NSString *)confirmTitle destructive:(BOOL)destructive handler:(void (^)(void))handler;
/// 多按钮询问：buttons 中最后一个为主按钮；回调选中的下标（0 = 取消）
- (void)askTitle:(NSString *)title message:(nullable NSString *)message buttons:(NSArray<NSString *> *)buttons destructiveIndex:(NSInteger)destructiveIndex handler:(void (^)(NSInteger index))handler;
- (void)alertError:(nullable NSError *)error title:(nullable NSString *)title;
- (void)onMain:(void (^)(void))block;
- (void)dismissKeyboard;
/// 返回上一页（有未保存修改时先确认）；自定义左按钮可直接调用
- (void)handleBack;

@end

NS_ASSUME_NONNULL_END
