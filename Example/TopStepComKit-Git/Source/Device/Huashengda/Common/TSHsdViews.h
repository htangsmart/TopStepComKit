//
//  TSHsdViews.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>
#import "TSHsdWeekdayView.h"
#import "TSHsdTimelineView.h"

NS_ASSUME_NONNULL_BEGIN

/// 华盛达页面的积木：与 HTML 原型（prototypes/huashengda）的 DOM 结构一一对应。
/// 每个积木都是 frame 布局，通过 sizeThatFits: 报告「给定宽度下的高度」，由 TSHsdStackView 纵向排列。

#pragma mark - 纵向堆叠（.scroll）

@interface TSHsdStackView : UIView
/// 积木之间的默认间距（原型 gap 12）
@property (nonatomic, assign) CGFloat spacing;
/// 左右内边距（原型 padding 16）
@property (nonatomic, assign) CGFloat sideInset;
/// 顶部 / 底部内边距
@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign) CGFloat bottomInset;
- (void)setBlocks:(NSArray<UIView *> *)blocks;
- (void)addBlock:(UIView *)block;
- (void)removeAllBlocks;
@end

/// 积木可声明与上一块 / 下一块的特殊间距（sec 后 8、foot 前 8）
@interface UIView (TSHsdBlockSpacing)
@property (nonatomic, strong, nullable) NSNumber *hsd_spacingBefore;
@property (nonatomic, strong, nullable) NSNumber *hsd_spacingAfter;
@end

#pragma mark - 标题下的小标签行（.kick + .chip）

@interface TSHsdChipsRow : UIView
/// 第一枚为色相底，其余为灰底
@property (nonatomic, copy) NSArray<NSString *> *chips;
@property (nonatomic, strong) UIColor *hue;
@end

#pragma mark - 分组标题（.sec）/ 页脚（.foot）/ 说明条（.banner）

@interface TSHsdSecView : UIView
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *rightText;
/// 右侧胶囊操作按钮（可选）：设置 actionTitle 后显示在 rightText 右边
@property (nonatomic, copy, nullable) NSString *actionTitle;
@property (nonatomic, copy, nullable) NSString *actionSymbol;
@property (nonatomic, strong) UIColor *hue;
@property (nonatomic, copy, nullable) void (^onAction)(void);
/// 操作按钮（用于外部做图标动画等）
@property (nonatomic, strong, readonly) UIButton *actionButton;
@end

@interface TSHsdFootView : UIView
@property (nonatomic, copy) NSString *text;
@end

@interface TSHsdBannerView : UIView
@property (nonatomic, copy) NSString *text;
/// YES 为黄色注意条
@property (nonatomic, assign) BOOL warn;
@end

#pragma mark - 卡片（.card）

@interface TSHsdCardView : UIView
/// 卡片内的行，自上而下；行与行之间自动画分隔线（有图标的相邻行分隔线从 69 开始）
@property (nonatomic, copy) NSArray<UIView *> *rows;
/// 只读分组（.ro）：灰底、无阴影、行更紧凑
@property (nonatomic, assign) BOOL readOnlyStyle;
/// 金币卡等自定义背景（nil 用卡片色）
@property (nonatomic, strong, nullable) CAGradientLayer *gradient;
@end

#pragma mark - 行（.row）

@interface TSHsdRowView : UIView
/// 左侧图标块（SF Symbol 名）；为空则无图标
@property (nonatomic, copy, nullable) NSString *symbol;
/// 图标块色相（默认页面色相）；内容类图标（任务类型 / 游戏 / 应用）用 emoStyle
@property (nonatomic, strong, nullable) UIColor *iconColor;
/// 内容图标样式：灰底（.ico.emo）
@property (nonatomic, assign) BOOL emoStyle;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSAttributedString *attributedTitle;
@property (nonatomic, copy, nullable) NSString *subtitle;
/// 副标题下方的附加视图（状态点、工具结果等）
@property (nonatomic, strong, nullable) UIView *extraView;
/// 右侧控件（开关 / 时间胶囊 / 值 / 步进器 / 任意视图）
@property (nonatomic, strong, nullable) UIView *rightView;
/// 右侧箭头
@property (nonatomic, assign) BOOL showsChevron;
/// 整行可点
@property (nonatomic, copy, nullable) void (^onTap)(void);
/// 置灰（.off：整体 45%）
@property (nonatomic, assign) BOOL off;
/// 主体半透明（.dim：任务未启用）
@property (nonatomic, assign) BOOL dim;
/// 顶部对齐（.top-al）
@property (nonatomic, assign) BOOL topAligned;
/// 紧凑（.ro 内的行）
@property (nonatomic, assign) BOOL compact;
/// 是否有左侧图标（供卡片决定分隔线缩进）
@property (nonatomic, readonly) BOOL hasLead;
/// 页面色相（默认图标色）
@property (nonatomic, strong) UIColor *hue;
@end

#pragma mark - 右侧控件

/// 时间胶囊（.timebox）
@interface TSHsdTimeBox : UIButton
@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, strong) UIColor *hue;
@property (nonatomic, copy, nullable) void (^onTap)(void);
@end

/// 数值胶囊（.valbox）：与时间胶囊同色系，文字为「数字 + 小号单位」的富文本；点击弹出数值滚轮
@interface TSHsdValueBox : UIButton
@property (nonatomic, strong) UIColor *hue;
/// 显示内容（数字粗体、单位小号），由调用方按 TSHsdValuePickConfig 生成
@property (nonatomic, copy, nullable) NSAttributedString *valueText;
@property (nonatomic, copy, nullable) void (^onTap)(void);
@end

/// 值文字（.val）
@interface TSHsdValueLabel : UILabel
@property (nonatomic, assign) BOOL mono;
@property (nonatomic, assign) BOOL rounded;
@end

/// 状态点 + 文字（.state）
@interface TSHsdStateLabel : UIView
- (void)setText:(NSString *)text color:(UIColor *)color;
@end

/// 药丸（.pill）
typedef NS_ENUM(NSInteger, TSHsdPillStyle) {
    TSHsdPillStylePlain = 0,
    TSHsdPillStyleHue,
    TSHsdPillStyleCoin,
};
@interface TSHsdPill : UIView
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy, nullable) NSString *symbol;
@property (nonatomic, assign) TSHsdPillStyle style;
@property (nonatomic, strong) UIColor *hue;
@end

/// 步进器（.stepper）
@interface TSHsdStepperView : UIView
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) NSInteger minValue;
@property (nonatomic, assign) NSInteger maxValue;
@property (nonatomic, assign) NSInteger step;
@property (nonatomic, copy, nullable) void (^onChange)(NSInteger value);
@end

/// 数字输入框 + 单位（.numbox）
@interface TSHsdNumBox : UIView
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) NSInteger minValue;
@property (nonatomic, assign) NSInteger maxValue;
@property (nonatomic, copy, nullable) NSString *unit;
/// 前缀文字（排名的「第」）
@property (nonatomic, copy, nullable) NSString *prefix;
@property (nonatomic, copy, nullable) void (^onChange)(NSInteger value);
@end

/// 分段（.seg）
@interface TSHsdSegItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *symbol;
/// 选中时的文字颜色（趋势三态用）
@property (nonatomic, strong, nullable) UIColor *onColor;
+ (instancetype)itemWithTitle:(NSString *)title symbol:(nullable NSString *)symbol;
@end

@interface TSHsdSegView : UIView
@property (nonatomic, copy) NSArray<TSHsdSegItem *> *items;
@property (nonatomic, assign) NSInteger selectedIndex;
/// 小号三态（.seg.tr3）
@property (nonatomic, assign) BOOL small;
/// 放在卡片内时四周留 12 / 16（.seg.in）
@property (nonatomic, assign) BOOL insetInCard;
@property (nonatomic, copy, nullable) void (^onChange)(NSInteger index);
@end

#pragma mark - 输入（.field）

@interface TSHsdFieldView : UIView
@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy, nullable) NSString *placeholder;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, assign) NSUInteger maxBytes;
@property (nonatomic, strong) UIColor *hue;
@property (nonatomic, readonly) BOOL overLimit;
@property (nonatomic, copy, nullable) void (^onChange)(NSString *text);
@end

#pragma mark - 时间对（.duo）

@interface TSHsdDuoTimeView : UIView
@property (nonatomic, assign) NSInteger startMinute;
@property (nonatomic, assign) NSInteger endMinute;
@property (nonatomic, strong) UIColor *hue;
@property (nonatomic, copy) NSString *startTitle;
@property (nonatomic, copy) NSString *endTitle;
@property (nonatomic, copy, nullable) void (^onTapStart)(void);
@property (nonatomic, copy, nullable) void (^onTapEnd)(void);
@end

#pragma mark - 按钮

/// 主按钮（.cta）
@interface TSHsdCTAButton : UIButton
@property (nonatomic, assign) BOOL soft;
/// 白底卡片样式（底部面板里的次要按钮，面板底色为灰时使用）
@property (nonatomic, assign) BOOL raised;
@property (nonatomic, assign) BOOL small;
@property (nonatomic, copy, nullable) NSString *symbol;
@property (nonatomic, copy, nullable) void (^onTap)(void);
- (void)setTitle:(NSString *)title symbol:(nullable NSString *)symbol;
@end

/// 虚线添加按钮（.ghost-add）
@interface TSHsdGhostAddButton : UIControl
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *small;
@property (nonatomic, copy, nullable) NSString *symbol;
@property (nonatomic, copy, nullable) void (^onTap)(void);
@end

/// 危险链接（.danger-link）
@interface TSHsdDangerLink : UIControl
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) void (^onTap)(void);
@end

#pragma mark - 空态 / 加载 / 错误

@interface TSHsdEmptyView : UIView
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, strong) UIColor *hue;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSString *code;
@property (nonatomic, copy, nullable) NSString *actionTitle;
@property (nonatomic, copy, nullable) NSString *actionSymbol;
@property (nonatomic, copy, nullable) void (^onAction)(void);
@end

@interface TSHsdLoadingView : UIView
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, strong) UIColor *hue;
@end

#pragma mark - 手表预览（.wpv）

@interface TSHsdWatchPreview : UIView
@property (nonatomic, strong) UIColor *hue;
/// 状态栏左 / 右文字（右侧可高亮）
@property (nonatomic, copy, nullable) NSString *topLeft;
@property (nonatomic, copy, nullable) NSString *topRight;
@property (nonatomic, assign) BOOL topRightHighlighted;
/// 任务样式：大图标 + 名称 + 副文 + 金币
@property (nonatomic, copy, nullable) NSString *bigSymbol;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *meta;
@property (nonatomic, copy, nullable) NSString *coinText;
/// ICE 样式：若干行标签（为空显示占位）
@property (nonatomic, copy, nullable) NSArray<NSString *> *lines;
@property (nonatomic, copy, nullable) NSString *linesPlaceholder;
@end

#pragma mark - 小部件

/// 过去一周达成的 7 个小格（.wk）
@interface TSHsdWeekDots : UIView
@property (nonatomic, assign) TSAlarmRepeat mask;
@property (nonatomic, strong) UIColor *hue;
@end

/// 进度条（.prog）
@interface TSHsdProgressBar : UIView
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIColor *hue;
@end

/// 进度环 + 中心图标（.ringp）
@interface TSHsdRingView : UIView
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIColor *hue;
@property (nonatomic, copy, nullable) NSString *symbol;
@end

/// 图标块（.ico）
@interface TSHsdIconBlock : UIView
@property (nonatomic, copy, nullable) NSString *symbol;
@property (nonatomic, strong) UIColor *tint;
/// 灰底内容图标
@property (nonatomic, assign) BOOL emoStyle;
/// 尺寸：40（默认）/ 48（lg）/ 30（sm）
@property (nonatomic, assign) CGFloat side;
@end

/// 横向滚动的胶囊 / 卡片选择条（日期条 .days、游戏条 .games）
@interface TSHsdHScrollPicker : UIView
/// 每项：主文字 + 小字（可空）+ 小圆点颜色（可空）
- (void)setItemsWithTitles:(NSArray<NSString *> *)titles
                    smalls:(nullable NSArray<NSString *> *)smalls
                 dotColors:(nullable NSArray<UIColor *> *)dotColors
                   symbols:(nullable NSArray<NSString *> *)symbols;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) UIColor *hue;
/// 游戏条样式（居中图标 + 文字，选中描边）；否则为日期条样式（左对齐，选中实心）
@property (nonatomic, assign) BOOL tileStyle;
@property (nonatomic, copy, nullable) void (^onChange)(NSInteger index);
@end

#pragma mark - 工具函数

/// 12.5 号 ink2 的富文本，其中 <b> 段落用 ink 650 加粗（对应原型 p b）
NSAttributedString *TSHsdRich(NSString *text, UIFont *font, UIColor *color, UIColor *boldColor);
/// SF Symbol 图片（iOS 13+，否则 nil）
UIImage *_Nullable TSHsdSymbol(NSString *name, CGFloat pointSize, UIImageSymbolWeight weight);

NS_ASSUME_NONNULL_END
