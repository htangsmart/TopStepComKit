//
//  TSUgreenViews.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/14.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSUgreenDisplay.h"

@class TSHsdCallLogEntry;

NS_ASSUME_NONNULL_BEGIN

/// 绿联定制页的积木：与 HTML 原型（prototypes/ugreen/index.html）的 DOM 一一对应。
/// 与华盛达积木一样用 frame 布局，通过 sizeThatFits: 报告「给定宽度下的高度」，由 TSHsdStackView 纵向排列。

#pragma mark - 设备外壳 + 屏幕（.dev / .scrbox / .scr）

/**
 * @brief Device bezel with a screen rendered in device pixels
 * @chinese 设备外壳 + 屏幕：屏幕内容按设备像素排版，再整体等比缩放到预览尺寸
 *
 * @discussion
 * [CN]: 缩放倍数 k = min(maxScale, maxScreenSize.width / 宽, maxScreenSize.height / 高)；
 *       字号与间距再乘 u = clamp(min(宽, 高) / 360, 0.55, 1.4)。圆屏的角标放顶部居中，避开被裁掉的四角。
 */
@interface TSUgreenDeviceView : UIView
/// 屏幕规格
@property (nonatomic, strong) TSUgreenScreenSpec *spec;
/// 屏幕内容
@property (nonatomic, assign) TSUgreenScreenContent content;
/// 歌词主题（content 为歌词时使用）
@property (nonatomic, assign) TSUgreenLyricsTheme theme;
/// 自定义主题的歌词颜色
@property (nonatomic, strong) UIColor *lyricsColor;
/// 屏幕上的角标文字（nil 不显示）
@property (nonatomic, copy, nullable) NSString *badgeText;
/// 角标是否为「常亮」绿色
@property (nonatomic, assign) BOOL badgeOn;
/// 三击提示浮层（nil 不显示；值为 TSUgreenTriplePressFunction）
@property (nonatomic, strong, nullable) NSNumber *overlayFunction;
/// 外壳宽度（预览 9，颜色面板 6）
@property (nonatomic, assign) CGFloat bezel;
/// 屏幕最大显示尺寸
@property (nonatomic, assign) CGSize maxScreenSize;
/// 最大缩放倍数
@property (nonatomic, assign) CGFloat maxScale;
/// 是否显示支架腿
@property (nonatomic, assign) BOOL showsLeg;
/// 按当前属性重建屏幕内容
- (void)reload;
/// 外壳尺寸（屏幕缩放后 + 两侧外壳）
- (CGSize)deviceSize;
@end

#pragma mark - 屏端预览卡（.pv）

@interface TSUgreenPreviewCard : UIView
/// 屏幕规格
@property (nonatomic, strong) TSUgreenScreenSpec *spec;
/// 预览所用的配置（草稿）
@property (nonatomic, strong) TSUgreenConfigModel *model;
/// 是否含未保存的修改（右上角标签）
@property (nonatomic, assign) BOOL dirty;
/// 当前视图
@property (nonatomic, assign) TSUgreenPreviewPage page;
/// 三击提示浮层（nil 不显示）
@property (nonatomic, strong, nullable) NSNumber *tripleOverlay;
/// 切换视图
@property (nonatomic, copy, nullable) void (^onSelectPage)(TSUgreenPreviewPage page);
/// 按当前属性刷新
- (void)reload;
@end

#pragma mark - 三击功能二选一（.choices）

@interface TSUgreenTripleChoiceView : UIView
/// 页面上选中的功能
@property (nonatomic, assign) TSUgreenTriplePressFunction selected;
/// 设备上的功能（与 selected 不同时，在设备值那张卡上标「设备上」）
@property (nonatomic, assign) TSUgreenTriplePressFunction deviceValue;
/// 页面色相
@property (nonatomic, strong) UIColor *hue;
/// 点选
@property (nonatomic, copy, nullable) void (^onSelect)(TSUgreenTriplePressFunction function);
/// 按当前属性刷新
- (void)reload;
@end

#pragma mark - 歌词：主题 + 颜色行 + 色板（.themes / .row / .pal）

@interface TSUgreenLyricsPanel : UIView
/// 页面上的主题
@property (nonatomic, assign) TSUgreenLyricsTheme theme;
/// 设备上的主题
@property (nonatomic, assign) TSUgreenLyricsTheme deviceTheme;
/// 页面上的颜色
@property (nonatomic, strong) UIColor *color;
/// 设备上的颜色
@property (nonatomic, strong) UIColor *deviceColor;
/// 页面色相
@property (nonatomic, strong) UIColor *hue;
/// 选主题
@property (nonatomic, copy, nullable) void (^onSelectTheme)(TSUgreenLyricsTheme theme);
/// 选色板颜色（#RRGGBB）
@property (nonatomic, copy, nullable) void (^onSelectColor)(NSString *hex);
/// 点颜色行或「更多颜色」
@property (nonatomic, copy, nullable) void (^onOpenColorSheet)(void);
/// 按当前属性刷新
- (void)reload;
@end

#pragma mark - 说明条（.banner，可带关闭按钮）

@interface TSUgreenNoticeBanner : UIView
/// 图标（SF Symbol）
@property (nonatomic, copy) NSString *symbol;
/// 文字，<b>…</b> 段加粗
@property (nonatomic, copy) NSString *text;
/// 黄色注意条
@property (nonatomic, assign) BOOL warn;
/// 页面色相（非 warn 时的底色与图标色）
@property (nonatomic, strong) UIColor *hue;
/// 关闭（nil 不显示关闭按钮）
@property (nonatomic, copy, nullable) void (^onClose)(void);
@end

#pragma mark - 设备回读值（.ro .rawdesc）

@interface TSUgreenCodeBlock : UIView
/// 等宽文字
@property (nonatomic, copy) NSString *text;
@end

#pragma mark - 已同步胶囊（.synced）

@interface TSUgreenSyncedPill : UIView
/// 文字
@property (nonatomic, copy) NSString *text;
@end

#pragma mark - 接口日志行（.lrow）

@interface TSUgreenLogRowView : UIView
/// 用一条调用记录配置
- (void)configureWithEntry:(TSHsdCallLogEntry *)entry;
@end

#pragma mark - 颜色面板：预览（.cprev）

@interface TSUgreenColorPreviewBlock : UIView
/// 屏幕规格
@property (nonatomic, strong) TSUgreenScreenSpec *spec;
/// 预览颜色
@property (nonatomic, strong) UIColor *color;
@end

#pragma mark - 颜色面板：12 色 + 色相滑杆 + HEX（.cgrid / .hue / .field）

@interface TSUgreenColorPickerBlock : UIView
/// 当前颜色（#RRGGBB）
@property (nonatomic, copy) NSString *hex;
/// 颜色变化（#RRGGBB）
@property (nonatomic, copy, nullable) void (^onChange)(NSString *hex);
/// 打开系统取色器（UIColorPickerViewController，supportsAlpha = NO），选中后同步到本面板
- (void)presentSystemPickerFrom:(UIViewController *)presenter;
@end

#pragma mark - 可点的页脚（.foot + 色相链接）

@interface TSUgreenLinkFootView : UIControl
/// 普通文字
@property (nonatomic, copy) NSString *text;
/// 色相链接文字（接在 text 后面）
@property (nonatomic, copy) NSString *linkText;
/// 链接颜色
@property (nonatomic, strong) UIColor *hue;
@end

NS_ASSUME_NONNULL_END
