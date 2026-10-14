//
//  TSAIInterpreterTheme.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Design tokens and small UI helpers shared by the interpreter pages
 * @chinese 同传页面共用的设计 token 与小型 UI 工具
 *
 * @discussion
 * [EN]: Mirrors the HTML prototype's token sheet one-to-one (paper / ink /
 *       jade / cobalt …). The prototype commits to a single light look for
 *       the setup, language and report pages and a single dark look for the
 *       live page, so colors here are fixed and intentionally do not follow
 *       the system appearance. Also provides the 44pt round icon button, the
 *       bottom toast and the mm:ss formatter used by every page.
 * [CN]: 与 HTML 原型的 token 表一一对应（paper / ink / jade / cobalt …）。
 *       原型中准备页、语言页、报告页固定为浅色，同传中固定为深色，
 *       因此这里的颜色是固定值，刻意不跟随系统外观。同时提供 44pt 圆形
 *       图标按钮、底部 toast 与 mm:ss 格式化，供各页面共用。
 */
@interface TSAIInterpreterTheme : NSObject

#pragma mark - Colors

/// @brief Page background #EEF0F3 @chinese 页面底色 #EEF0F3
+ (UIColor *)paper;
/// @brief Card background #FFFFFF @chinese 卡片底色 #FFFFFF
+ (UIColor *)panel;
/// @brief Primary ink #15171A @chinese 主墨色 #15171A
+ (UIColor *)ink;
/// @brief Secondary ink #26292E (dark page chrome) @chinese 次墨色 #26292E（深色页控件）
+ (UIColor *)ink2;
/// @brief Tertiary ink #3B3F46 (dark page separators) @chinese 三级墨色 #3B3F46（深色页分隔线）
+ (UIColor *)ink3;
/// @brief Muted text #5B6472 @chinese 弱化文字 #5B6472
+ (UIColor *)muted;
/// @brief Hairline #E1E4E9 @chinese 细线 #E1E4E9
+ (UIColor *)line;
/// @brief Jade #0E7C6B (input / original) @chinese 翠绿 #0E7C6B（输入 / 原文）
+ (UIColor *)jade;
/// @brief Jade 50 #E6F4F1 @chinese 翠绿 50 #E6F4F1
+ (UIColor *)jade50;
/// @brief Jade 200 #7EE0CC @chinese 翠绿 200 #7EE0CC
+ (UIColor *)jade200;
/// @brief Jade 900 #1F3A33 @chinese 翠绿 900 #1F3A33
+ (UIColor *)jade900;
/// @brief Cobalt #2B4FD6 (output / translated) @chinese 钴蓝 #2B4FD6（输出 / 译文）
+ (UIColor *)cobalt;
/// @brief Cobalt 50 #EAEEFB @chinese 钴蓝 50 #EAEEFB
+ (UIColor *)cobalt50;
/// @brief Cobalt 200 #A9B8F5 @chinese 钴蓝 200 #A9B8F5
+ (UIColor *)cobalt200;
/// @brief Cobalt 900 #243267 @chinese 钴蓝 900 #243267
+ (UIColor *)cobalt900;
/// @brief Warning #B45309 @chinese 警示 #B45309
+ (UIColor *)warn;
/// @brief Danger #E5484D @chinese 危险 #E5484D
+ (UIColor *)danger;
/// @brief OK dot #34D399 @chinese 正常指示点 #34D399
+ (UIColor *)ok;
/// @brief Primary text on dark #F5F6F8 @chinese 深色页主文字 #F5F6F8
+ (UIColor *)textOnDark;
/// @brief Secondary text on dark #B9C0CA @chinese 深色页次文字 #B9C0CA
+ (UIColor *)textOnDark2;
/// @brief Disabled icon tint #9AA3AF @chinese 禁用图标色 #9AA3AF
+ (UIColor *)dim;
/// @brief Disabled icon background #F1F2F4 @chinese 禁用图标底色 #F1F2F4
+ (UIColor *)dimBackground;
/// @brief Sheet grabber #C9CED6 @chinese 抽屉抓手 #C9CED6
+ (UIColor *)grab;
/// @brief Sheet background #F5F6F8 @chinese 抽屉底色 #F5F6F8
+ (UIColor *)sheetBackground;
/// @brief Overlay rgba(0,0,0,.55) @chinese 遮罩 rgba(0,0,0,.55)
+ (UIColor *)overlay;

#pragma mark - Fonts

/**
 * @brief System font with weight, mapped from the prototype's 400 / 500 / 600 / 700
 * @chinese 系统字体，权重对应原型中的 400 / 500 / 600 / 700
 *
 * @param size
 * EN: Point size
 * CN: 字号
 *
 * @param weight
 * EN: CSS weight (400 / 500 / 600 / 700)
 * CN: CSS 字重（400 / 500 / 600 / 700）
 *
 * @return
 * EN: Font
 * CN: 字体
 */
+ (UIFont *)fontOfSize:(CGFloat)size cssWeight:(NSInteger)weight;

/**
 * @brief Monospaced-digit font for timers and counters
 * @chinese 定宽数字字体，用于计时与计数
 *
 * @param size
 * EN: Point size
 * CN: 字号
 *
 * @param weight
 * EN: CSS weight
 * CN: CSS 字重
 *
 * @return
 * EN: Font with tabular numbers
 * CN: 等宽数字字体
 */
+ (UIFont *)tabularFontOfSize:(CGFloat)size cssWeight:(NSInteger)weight;

#pragma mark - Controls

/**
 * @brief 44pt round icon button (`.iconbtn` in the prototype)
 * @chinese 44pt 圆形图标按钮（原型中的 `.iconbtn`）
 *
 * @param symbolName
 * EN: SF Symbol name
 * CN: SF Symbol 名称
 *
 * @param background
 * EN: Fill color
 * CN: 填充色
 *
 * @param tint
 * EN: Icon color
 * CN: 图标颜色
 *
 * @param target
 * EN: Action target
 * CN: 事件接收者
 *
 * @param action
 * EN: Action selector
 * CN: 事件方法
 *
 * @return
 * EN: Configured button, frame still zero
 * CN: 已配置的按钮，frame 仍为零
 */
+ (UIButton *)iconButtonWithSymbol:(NSString *)symbolName
                        background:(UIColor *)background
                              tint:(UIColor *)tint
                            target:(id)target
                            action:(SEL)action;

/**
 * @brief Round button of arbitrary size with a symbol image
 * @chinese 任意尺寸的圆形符号按钮
 *
 * @param symbolName
 * EN: SF Symbol name
 * CN: SF Symbol 名称
 *
 * @param pointSize
 * EN: Symbol point size
 * CN: 符号字号
 *
 * @param background
 * EN: Fill color
 * CN: 填充色
 *
 * @param tint
 * EN: Icon color
 * CN: 图标颜色
 *
 * @param target
 * EN: Action target
 * CN: 事件接收者
 *
 * @param action
 * EN: Action selector
 * CN: 事件方法
 *
 * @return
 * EN: Configured button; caller sets frame and cornerRadius
 * CN: 已配置的按钮；调用方设置 frame 与 cornerRadius
 */
+ (UIButton *)roundButtonWithSymbol:(NSString *)symbolName
                          pointSize:(CGFloat)pointSize
                         background:(UIColor *)background
                               tint:(UIColor *)tint
                             target:(id)target
                             action:(SEL)action;

/**
 * @brief 56pt pill call-to-action (`.cta` in the prototype)
 * @chinese 56pt 胶囊主按钮（原型中的 `.cta`）
 *
 * @param title
 * EN: Button title
 * CN: 按钮文字
 *
 * @param symbolName
 * EN: Optional leading SF Symbol
 * CN: 可选的前置 SF Symbol
 *
 * @param background
 * EN: Fill color
 * CN: 填充色
 *
 * @param tint
 * EN: Title / icon color
 * CN: 文字 / 图标颜色
 *
 * @param weight
 * EN: CSS weight of the title
 * CN: 文字 CSS 字重
 *
 * @param target
 * EN: Action target
 * CN: 事件接收者
 *
 * @param action
 * EN: Action selector
 * CN: 事件方法
 *
 * @return
 * EN: Configured button, frame still zero
 * CN: 已配置的按钮，frame 仍为零
 */
+ (UIButton *)ctaButtonWithTitle:(NSString *)title
                          symbol:(nullable NSString *)symbolName
                      background:(UIColor *)background
                            tint:(UIColor *)tint
                       cssWeight:(NSInteger)weight
                          target:(id)target
                          action:(SEL)action;

/**
 * @brief Small SF Symbol image view used inline in labels rows
 * @chinese 行内小图标
 *
 * @param symbolName
 * EN: SF Symbol name
 * CN: SF Symbol 名称
 *
 * @param pointSize
 * EN: Symbol point size
 * CN: 符号字号
 *
 * @param tint
 * EN: Icon color
 * CN: 图标颜色
 *
 * @return
 * EN: Image view sized to its intrinsic content
 * CN: 已按内容尺寸设置好的图片视图
 */
+ (UIImageView *)symbolViewNamed:(NSString *)symbolName
                       pointSize:(CGFloat)pointSize
                            tint:(UIColor *)tint;

#pragma mark - Toast

/**
 * @brief Show the prototype's dark bottom toast for 1.8 s
 * @chinese 显示原型中的深色底部 toast，持续 1.8 秒
 *
 * @param message
 * EN: Text to show
 * CN: 提示文字
 *
 * @param view
 * EN: Host view; the toast is centered horizontally 120pt above its bottom
 * CN: 宿主视图；toast 水平居中，距底部 120pt
 */
+ (void)showToast:(NSString *)message inView:(UIView *)view;

#pragma mark - Formatting

/**
 * @brief mm:ss for an elapsed interval
 * @chinese 将时长格式化为 mm:ss
 *
 * @param seconds
 * EN: Elapsed seconds; negative values are clamped to zero
 * CN: 已经过的秒数；负数按 0 处理
 *
 * @return
 * EN: Zero-padded "mm:ss"
 * CN: 补零后的 "mm:ss"
 */
+ (NSString *)elapsedString:(NSTimeInterval)seconds;

#pragma mark - Navigation

/**
 * @brief Whether a view controller is one of the interpreter pages that draw their own top bar
 * @chinese 判断控制器是否为自绘顶栏的同传页面
 *
 * @param viewController
 * EN: Any view controller
 * CN: 任意控制器
 *
 * @return
 * EN: YES for setup / live / report pages
 * CN: 准备页 / 同传中 / 报告页返回 YES
 */
+ (BOOL)isInterpreterPage:(nullable UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
