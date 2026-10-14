//
//  TSUgreenDisplay.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/14.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 绿联配置的 5 个字段，与 TSUgreenConfigModel 的属性一一对应
typedef NS_ENUM(NSInteger, TSUgreenField) {
    /// desktopModeEnabled
    TSUgreenFieldDesktopMode = 0,
    /// triplePressFunction
    TSUgreenFieldTriplePress,
    /// alwaysOnPages
    TSUgreenFieldAlwaysOnPages,
    /// lyricsTheme
    TSUgreenFieldLyricsTheme,
    /// lyricsColor
    TSUgreenFieldLyricsColor,
};

/// 屏端预览的四个视图（原型 .pvtabs）
typedef NS_ENUM(NSInteger, TSUgreenPreviewPage) {
    TSUgreenPreviewPageLyrics = 0,
    TSUgreenPreviewPageMusic,
    TSUgreenPreviewPageStatus,
    TSUgreenPreviewPageStand,
};

/// 屏幕里画的内容
typedef NS_ENUM(NSInteger, TSUgreenScreenContent) {
    TSUgreenScreenContentLyrics = 0,
    TSUgreenScreenContentMusic,
    TSUgreenScreenContentStatus,
};

/**
 * @brief Normalized device screen spec
 * @chinese 设备屏幕规格：由 TSPeripheral.screenInfo 归一化得到（原型 scrInfo()）
 *
 * @discussion
 * [CN]: 形状、像素尺寸、圆角都以设备上报为准；圆屏圆角取短边一半，其余圆角不超过短边一半。
 *       设备没上报（形状未知或尺寸为 0）时退回 360×360、圆角 40 的 1:1 示意，known 为 NO。
 */
@interface TSUgreenScreenSpec : NSObject

/// 形状（未上报为 eTSPeriphShapeUnknow）
@property (nonatomic, assign, readonly) TSPeriphShape shape;
/// 像素尺寸（未上报时为 360×360）
@property (nonatomic, assign, readonly) CGSize size;
/// 像素圆角（圆屏为短边一半）
@property (nonatomic, assign, readonly) CGFloat cornerRadius;
/// 设备是否上报了有效屏幕信息
@property (nonatomic, assign, readonly, getter=isKnown) BOOL known;
/// 是否圆屏
@property (nonatomic, assign, readonly, getter=isCircle) BOOL circle;

/// 由设备屏幕信息生成（nil 视为未上报）
+ (instancetype)specWithScreen:(nullable TSPeripheralScreen *)screen;
/// 当前连接设备的屏幕规格
+ (instancetype)currentSpec;
/// 预览下方的规格文案，如「screenInfo：圆形 360×360px · 圆角 180」
- (NSString *)specText;

@end

/**
 * @brief Display helpers for the UGREEN page
 * @chinese 绿联定制页的展示工具：色相、字段与枚举文案、颜色换算、主题配色、错误文案
 */
@interface TSUgreenDisplay : NSObject

#pragma mark - 颜色

/// 页面色相（浅色 #13A150 / 深色 #4FD58A）
+ (UIColor *)hue;
/// 预览卡深色底的两端（原型 --hero / --hero-2）
+ (UIColor *)heroColor;
+ (UIColor *)heroColor2;
/// 预览卡上的次要文字（原型 --hero-ink2）
+ (UIColor *)heroInk2;
/// 预览卡上的亮绿（标签点、常亮角标）
+ (UIColor *)glowGreen;

#pragma mark - 字段

/// 5 个字段（按页面顺序）
+ (NSArray<NSNumber *> *)allFields;
/// 字段中文名：桌搭模式 / 三击功能 / 常亮页面 / 歌词主题 / 歌词颜色
+ (NSString *)fieldName:(TSUgreenField)field;
/// SDK 属性名：desktopModeEnabled …
+ (NSString *)sdkFieldName:(TSUgreenField)field;
/// 用于比较的字段取值（颜色按 #RRGGBBAA 比较，避免浮点误差）
+ (NSString *)compareValueOfField:(TSUgreenField)field model:(TSUgreenConfigModel *)model;
/// 给用户看的取值：开 / 现场录音 / 音乐控制页、状态页 / 深海 / #7CF2B0FF
+ (NSString *)displayValueOfField:(TSUgreenField)field model:(TSUgreenConfigModel *)model;
/// 差异表里的 SDK 取值：YES / 1 (VoiceAssistant) / 0x03 / 2 (Aurora) / #7CF2B0FF
+ (NSString *)sdkValueOfField:(TSUgreenField)field model:(TSUgreenConfigModel *)model;
/// 从 from 到 to 变化了的字段
+ (NSArray<NSNumber *> *)changedFieldsFrom:(TSUgreenConfigModel *)from to:(TSUgreenConfigModel *)to;
/// 把 source 的某个字段拷到 target
+ (void)copyField:(TSUgreenField)field from:(TSUgreenConfigModel *)source to:(TSUgreenConfigModel *)target;

#pragma mark - 枚举

/// 三击功能名：现场录音 / 语音助手
+ (NSString *)tripleName:(TSUgreenTriplePressFunction)function;
/// 三击功能说明：三击开始录音 / 三击唤起 AI 助手
+ (NSString *)tripleDescription:(TSUgreenTriplePressFunction)function;
/// 三击功能的 SF Symbol
+ (NSString *)tripleSymbol:(TSUgreenTriplePressFunction)function;
/// 三击功能的枚举英文名（OnSiteRecording / VoiceAssistant）
+ (NSString *)tripleEnumName:(TSUgreenTriplePressFunction)function;
/// 全部三击功能
+ (NSArray<NSNumber *> *)allTripleFunctions;
/// 歌词主题名：自定义 / 深海 / 极光 / 星空 / 活力
+ (NSString *)themeName:(TSUgreenLyricsTheme)theme;
/// 歌词主题枚举英文名（Custom / DeepSea …）
+ (NSString *)themeEnumName:(TSUgreenLyricsTheme)theme;
/// 全部歌词主题
+ (NSArray<NSNumber *> *)allThemes;
/// 常亮页面文案：音乐控制页、状态页 / 无
+ (NSString *)alwaysOnPagesText:(TSUgreenAlwaysOnPage)pages;

#pragma mark - 歌词主题配色（示意，实际以设备内置为准）

/// 主题当前行颜色；自定义主题返回 customColor
+ (UIColor *)themeAccent:(TSUgreenLyricsTheme)theme customColor:(UIColor *)customColor;
/// 主题非当前行颜色
+ (UIColor *)themeDimText:(TSUgreenLyricsTheme)theme;
/// 给图层套上主题底色（渐变 + 星空的星点），scale 为星点半径倍数
+ (void)applyTheme:(TSUgreenLyricsTheme)theme toLayer:(CALayer *)layer starScale:(CGFloat)starScale;
/// 按 CSS 线性渐变角度设置起止点（0° 向上、90° 向右）
+ (void)applyCSSAngle:(CGFloat)degrees toGradient:(CAGradientLayer *)gradient;

#pragma mark - 颜色换算

/// #RRGGBBAA
+ (NSString *)hexRGBAOfColor:(UIColor *)color;
/// #RRGGBB
+ (NSString *)hexRGBOfColor:(UIColor *)color;
/// 解析 RRGGBB / RRGGBBAA（可带 #），失败返回 nil
+ (nullable UIColor *)colorFromHex:(NSString *)hex;
/// 行内色板 8 色（#RRGGBB）
+ (NSArray<NSString *> *)paletteHexes;
/// 颜色面板 12 色（#RRGGBB）
+ (NSArray<NSString *> *)gridHexes;
/// 色相滑杆对应的颜色：hsl(hue, 90%, 66%)
+ (UIColor *)colorWithHueDegrees:(CGFloat)degrees;
/// 颜色的色相（0–359）
+ (CGFloat)hueDegreesOfColor:(UIColor *)color;

#pragma mark - 文案与错误

/// 当前 SDK 平台名（FitCloud / NPK / Persimwear …）
+ (NSString *)platformName;
/// 错误标题：当前设备不支持 / 设备没有响应 / 设备拒绝了这次设置 …
+ (NSString *)errorTitle:(nullable NSError *)error;
/// 错误说明
+ (NSString *)errorText:(nullable NSError *)error;
/// 错误小字：domain · NAME (code)
+ (NSString *)errorCode:(nullable NSError *)error;
/// 错误码名：NOTSUPPORT / TIMEOUT …
+ (NSString *)errorShortName:(nullable NSError *)error;
/// HH:mm:ss
+ (NSString *)clockSecondsString:(NSDate *)date;
/// HH:mm
+ (NSString *)clockString:(NSDate *)date;
/// 一个 hue 色的 7pt 小圆点图片（「已修改」标记）
+ (UIImage *)dotImageWithColor:(UIColor *)color diameter:(CGFloat)diameter;
/// 标题后带「已修改」小圆点的富文本
+ (NSAttributedString *)title:(NSString *)title font:(UIFont *)font color:(UIColor *)color modifiedDotColor:(nullable UIColor *)dotColor;

@end

NS_ASSUME_NONNULL_END
