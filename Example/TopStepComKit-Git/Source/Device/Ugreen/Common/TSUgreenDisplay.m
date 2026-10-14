//
//  TSUgreenDisplay.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/14.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSUgreenDisplay.h"

#import <TopStepToolKit/TopStepToolKit.h>

#import "TSRootVC.h"
#import "TSDeviceCoordinator.h"
#import "TSHsdErrorText.h"

/** 0xRRGGBB → UIColor */
static UIColor *TSUgreenRGB(NSInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.f green:((hex >> 8) & 0xFF) / 255.f blue:(hex & 0xFF) / 255.f alpha:1.f];
}

/** 未上报屏幕信息时的示意尺寸与圆角 */
static const CGFloat kTSUgreenFallbackScreenSide = 360.f;
static const CGFloat kTSUgreenFallbackScreenRadius = 40.f;

#pragma mark - TSUgreenScreenSpec

@implementation TSUgreenScreenSpec

/** 由设备屏幕信息生成规格 */
+ (instancetype)specWithScreen:(nullable TSPeripheralScreen *)screen {
    TSUgreenScreenSpec *spec = [[self alloc] init];
    TSPeriphShape shape = screen ? screen.shape : eTSPeriphShapeUnknow;
    CGSize size = screen ? screen.screenSize : CGSizeZero;
    BOOL known = (shape != eTSPeriphShapeUnknow) && size.width > 0 && size.height > 0;
    spec->_known = known;
    spec->_shape = known ? shape : eTSPeriphShapeUnknow;
    spec->_size = known ? size : CGSizeMake(kTSUgreenFallbackScreenSide, kTSUgreenFallbackScreenSide);
    spec->_circle = known && shape == eTSPeriphShapeCircle;
    CGFloat half = MIN(spec->_size.width, spec->_size.height) / 2.f;
    if (!known) {
        spec->_cornerRadius = kTSUgreenFallbackScreenRadius;
    } else if (spec->_circle) {
        spec->_cornerRadius = half;
    } else {
        spec->_cornerRadius = MIN(MAX(screen.screenBorderRadius, 0), half);
    }
    return spec;
}

/** 当前连接设备的屏幕规格 */
+ (instancetype)currentSpec {
    return [self specWithScreen:[TopStepComKit sharedInstance].connectedPeripheral.screenInfo];
}

/** 规格文案 */
- (NSString *)specText {
    if (!self.known) { return TSLocalizedString(@"ugreen.spec.unknown"); }
    return [NSString stringWithFormat:TSLocalizedString(@"ugreen.spec.format"), [self ts_shapeName],
            self.size.width, self.size.height, self.cornerRadius];
}

/** 形状中文名 */
- (NSString *)ts_shapeName {
    switch (self.shape) {
        case eTSPeriphShapeCircle:              return TSLocalizedString(@"ugreen.shape.circle");
        case eTSPeriphShapeSquare:              return TSLocalizedString(@"ugreen.shape.square");
        case eTSPeriphShapeVerticalRectangle:   return TSLocalizedString(@"ugreen.shape.vertical");
        case eTSPeriphShapeTransverseRectangle: return TSLocalizedString(@"ugreen.shape.transverse");
        default:                                return TSLocalizedString(@"ugreen.shape.unknown");
    }
}

@end

#pragma mark - TSUgreenDisplay

@implementation TSUgreenDisplay

#pragma mark - 颜色

+ (UIColor *)hue { return TSAdaptiveColor(TSUgreenRGB(0x13A150), TSUgreenRGB(0x4FD58A)); }
+ (UIColor *)heroColor { return TSAdaptiveColor(TSUgreenRGB(0x141726), TSUgreenRGB(0x1A1E2C)); }
+ (UIColor *)heroColor2 { return TSAdaptiveColor(TSUgreenRGB(0x232846), TSUgreenRGB(0x262C48)); }
+ (UIColor *)heroInk2 { return TSUgreenRGB(0xA9AFC6); }
+ (UIColor *)glowGreen { return TSUgreenRGB(0x4FD58A); }

#pragma mark - 字段

/** 5 个字段 */
+ (NSArray<NSNumber *> *)allFields {
    return @[@(TSUgreenFieldDesktopMode), @(TSUgreenFieldTriplePress), @(TSUgreenFieldAlwaysOnPages),
             @(TSUgreenFieldLyricsTheme), @(TSUgreenFieldLyricsColor)];
}

/** 字段中文名 */
+ (NSString *)fieldName:(TSUgreenField)field {
    switch (field) {
        case TSUgreenFieldDesktopMode:   return TSLocalizedString(@"ugreen.field.desk");
        case TSUgreenFieldTriplePress:   return TSLocalizedString(@"ugreen.field.triple");
        case TSUgreenFieldAlwaysOnPages: return TSLocalizedString(@"ugreen.field.aon");
        case TSUgreenFieldLyricsTheme:   return TSLocalizedString(@"ugreen.field.theme");
        case TSUgreenFieldLyricsColor:   return TSLocalizedString(@"ugreen.field.color");
    }
    return @"";
}

/** SDK 属性名 */
+ (NSString *)sdkFieldName:(TSUgreenField)field {
    switch (field) {
        case TSUgreenFieldDesktopMode:   return @"desktopModeEnabled";
        case TSUgreenFieldTriplePress:   return @"triplePressFunction";
        case TSUgreenFieldAlwaysOnPages: return @"alwaysOnPages";
        case TSUgreenFieldLyricsTheme:   return @"lyricsTheme";
        case TSUgreenFieldLyricsColor:   return @"lyricsColor";
    }
    return @"";
}

/** 比较用取值 */
+ (NSString *)compareValueOfField:(TSUgreenField)field model:(TSUgreenConfigModel *)model {
    switch (field) {
        case TSUgreenFieldDesktopMode:   return model.isDesktopModeEnabled ? @"1" : @"0";
        case TSUgreenFieldTriplePress:   return [NSString stringWithFormat:@"%ld", (long)model.triplePressFunction];
        case TSUgreenFieldAlwaysOnPages: return [NSString stringWithFormat:@"%lu", (unsigned long)model.alwaysOnPages];
        case TSUgreenFieldLyricsTheme:   return [NSString stringWithFormat:@"%ld", (long)model.lyricsTheme];
        case TSUgreenFieldLyricsColor:   return [self hexRGBAOfColor:model.lyricsColor];
    }
    return @"";
}

/** 展示用取值 */
+ (NSString *)displayValueOfField:(TSUgreenField)field model:(TSUgreenConfigModel *)model {
    switch (field) {
        case TSUgreenFieldDesktopMode:
            return model.isDesktopModeEnabled ? TSLocalizedString(@"ugreen.value.on") : TSLocalizedString(@"ugreen.value.off");
        case TSUgreenFieldTriplePress:   return [self tripleName:model.triplePressFunction];
        case TSUgreenFieldAlwaysOnPages: return [self alwaysOnPagesText:model.alwaysOnPages];
        case TSUgreenFieldLyricsTheme:   return [self themeName:model.lyricsTheme];
        case TSUgreenFieldLyricsColor:   return [self hexRGBAOfColor:model.lyricsColor];
    }
    return @"";
}

/** 差异表里的 SDK 取值 */
+ (NSString *)sdkValueOfField:(TSUgreenField)field model:(TSUgreenConfigModel *)model {
    switch (field) {
        case TSUgreenFieldDesktopMode:   return model.isDesktopModeEnabled ? @"YES" : @"NO";
        case TSUgreenFieldTriplePress:
            return [NSString stringWithFormat:@"%ld (%@)", (long)model.triplePressFunction, [self tripleEnumName:model.triplePressFunction]];
        case TSUgreenFieldAlwaysOnPages: return [NSString stringWithFormat:@"0x%02lX", (unsigned long)model.alwaysOnPages];
        case TSUgreenFieldLyricsTheme:
            return [NSString stringWithFormat:@"%ld (%@)", (long)model.lyricsTheme, [self themeEnumName:model.lyricsTheme]];
        case TSUgreenFieldLyricsColor:   return [self hexRGBAOfColor:model.lyricsColor];
    }
    return @"";
}

/** 变化了的字段 */
+ (NSArray<NSNumber *> *)changedFieldsFrom:(TSUgreenConfigModel *)from to:(TSUgreenConfigModel *)to {
    NSMutableArray<NSNumber *> *fields = [NSMutableArray array];
    for (NSNumber *field in [self allFields]) {
        TSUgreenField f = field.integerValue;
        if (![[self compareValueOfField:f model:from] isEqualToString:[self compareValueOfField:f model:to]]) {
            [fields addObject:field];
        }
    }
    return fields;
}

/** 拷贝一个字段 */
+ (void)copyField:(TSUgreenField)field from:(TSUgreenConfigModel *)source to:(TSUgreenConfigModel *)target {
    switch (field) {
        case TSUgreenFieldDesktopMode:   target.desktopModeEnabled = source.isDesktopModeEnabled; break;
        case TSUgreenFieldTriplePress:   target.triplePressFunction = source.triplePressFunction; break;
        case TSUgreenFieldAlwaysOnPages: target.alwaysOnPages = source.alwaysOnPages; break;
        case TSUgreenFieldLyricsTheme:   target.lyricsTheme = source.lyricsTheme; break;
        case TSUgreenFieldLyricsColor:   target.lyricsColor = source.lyricsColor ?: [UIColor whiteColor]; break;
    }
}

#pragma mark - 枚举

/** 三击功能名 */
+ (NSString *)tripleName:(TSUgreenTriplePressFunction)function {
    switch (function) {
        case TSUgreenTriplePressFunctionOnSiteRecording: return TSLocalizedString(@"ugreen.triple.recording");
        case TSUgreenTriplePressFunctionVoiceAssistant:  return TSLocalizedString(@"ugreen.triple.assistant");
    }
    return [NSString stringWithFormat:TSLocalizedString(@"ugreen.unknown_format"), (long)function];
}

/** 三击功能说明 */
+ (NSString *)tripleDescription:(TSUgreenTriplePressFunction)function {
    switch (function) {
        case TSUgreenTriplePressFunctionOnSiteRecording: return TSLocalizedString(@"ugreen.triple.recording.sub");
        case TSUgreenTriplePressFunctionVoiceAssistant:  return TSLocalizedString(@"ugreen.triple.assistant.sub");
    }
    return @"";
}

/** 三击功能图标 */
+ (NSString *)tripleSymbol:(TSUgreenTriplePressFunction)function {
    return function == TSUgreenTriplePressFunctionVoiceAssistant ? @"sparkles" : @"waveform";
}

/** 三击功能枚举名 */
+ (NSString *)tripleEnumName:(TSUgreenTriplePressFunction)function {
    switch (function) {
        case TSUgreenTriplePressFunctionOnSiteRecording: return @"OnSiteRecording";
        case TSUgreenTriplePressFunctionVoiceAssistant:  return @"VoiceAssistant";
    }
    return @"Unknown";
}

/** 全部三击功能 */
+ (NSArray<NSNumber *> *)allTripleFunctions {
    return @[@(TSUgreenTriplePressFunctionOnSiteRecording), @(TSUgreenTriplePressFunctionVoiceAssistant)];
}

/** 歌词主题名 */
+ (NSString *)themeName:(TSUgreenLyricsTheme)theme {
    switch (theme) {
        case TSUgreenLyricsThemeCustom:    return TSLocalizedString(@"ugreen.theme.custom");
        case TSUgreenLyricsThemeDeepSea:   return TSLocalizedString(@"ugreen.theme.deep_sea");
        case TSUgreenLyricsThemeAurora:    return TSLocalizedString(@"ugreen.theme.aurora");
        case TSUgreenLyricsThemeStarrySky: return TSLocalizedString(@"ugreen.theme.starry_sky");
        case TSUgreenLyricsThemeVitality:  return TSLocalizedString(@"ugreen.theme.vitality");
    }
    return [NSString stringWithFormat:TSLocalizedString(@"ugreen.unknown_format"), (long)theme];
}

/** 歌词主题枚举名 */
+ (NSString *)themeEnumName:(TSUgreenLyricsTheme)theme {
    switch (theme) {
        case TSUgreenLyricsThemeCustom:    return @"Custom";
        case TSUgreenLyricsThemeDeepSea:   return @"DeepSea";
        case TSUgreenLyricsThemeAurora:    return @"Aurora";
        case TSUgreenLyricsThemeStarrySky: return @"StarrySky";
        case TSUgreenLyricsThemeVitality:  return @"Vitality";
    }
    return @"Unknown";
}

/** 全部歌词主题 */
+ (NSArray<NSNumber *> *)allThemes {
    return @[@(TSUgreenLyricsThemeCustom), @(TSUgreenLyricsThemeDeepSea), @(TSUgreenLyricsThemeAurora),
             @(TSUgreenLyricsThemeStarrySky), @(TSUgreenLyricsThemeVitality)];
}

/** 常亮页面文案 */
+ (NSString *)alwaysOnPagesText:(TSUgreenAlwaysOnPage)pages {
    NSMutableArray<NSString *> *names = [NSMutableArray array];
    if (pages & TSUgreenAlwaysOnPageMusicControl) { [names addObject:TSLocalizedString(@"ugreen.page.music")]; }
    if (pages & TSUgreenAlwaysOnPageStatus) { [names addObject:TSLocalizedString(@"ugreen.page.status")]; }
    return names.count ? [names componentsJoinedByString:TSLocalizedString(@"ugreen.list_separator")] : TSLocalizedString(@"ugreen.page.none");
}

#pragma mark - 主题配色

/** 主题当前行颜色 */
+ (UIColor *)themeAccent:(TSUgreenLyricsTheme)theme customColor:(UIColor *)customColor {
    switch (theme) {
        case TSUgreenLyricsThemeDeepSea:   return TSUgreenRGB(0x8FE3FF);
        case TSUgreenLyricsThemeAurora:    return TSUgreenRGB(0xB8FFE2);
        case TSUgreenLyricsThemeStarrySky: return TSUgreenRGB(0xFFE7A3);
        case TSUgreenLyricsThemeVitality:  return TSUgreenRGB(0xFFF6C8);
        case TSUgreenLyricsThemeCustom:
        default:                           return customColor ?: [UIColor whiteColor];
    }
}

/** 主题非当前行颜色 */
+ (UIColor *)themeDimText:(TSUgreenLyricsTheme)theme {
    return [[UIColor whiteColor] colorWithAlphaComponent:theme == TSUgreenLyricsThemeVitality ? 0.65f : 0.36f];
}

/** 套主题底色：渐变 + 星点 */
+ (void)applyTheme:(TSUgreenLyricsTheme)theme toLayer:(CALayer *)layer starScale:(CGFloat)starScale {
    layer.backgroundColor = [UIColor blackColor].CGColor;
    NSArray<UIColor *> *colors = nil;
    NSArray<NSNumber *> *locations = nil;
    CGFloat angle = 180.f;
    switch (theme) {
        case TSUgreenLyricsThemeDeepSea:
            colors = @[TSUgreenRGB(0x051A3D), TSUgreenRGB(0x0A4F86), TSUgreenRGB(0x0D78AD)];
            locations = @[@0, @0.65, @1];
            angle = 165.f;
            break;
        case TSUgreenLyricsThemeAurora:
            colors = @[TSUgreenRGB(0x052523), TSUgreenRGB(0x11735A), TSUgreenRGB(0x5A3FB5)];
            locations = @[@0, @0.48, @1];
            angle = 160.f;
            break;
        case TSUgreenLyricsThemeStarrySky:
            colors = @[TSUgreenRGB(0x090C2B), TSUgreenRGB(0x2B1C5F)];
            locations = @[@0, @1];
            angle = 170.f;
            break;
        case TSUgreenLyricsThemeVitality:
            colors = @[TSUgreenRGB(0xFF8A3D), TSUgreenRGB(0xFF4F7B), TSUgreenRGB(0xB23FD0)];
            locations = @[@0, @0.58, @1];
            angle = 150.f;
            break;
        case TSUgreenLyricsThemeCustom:
        default:
            return;
    }
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = layer.bounds;
    NSMutableArray *cgColors = [NSMutableArray array];
    for (UIColor *color in colors) { [cgColors addObject:(__bridge id)color.CGColor]; }
    gradient.colors = cgColors;
    gradient.locations = locations;
    [self applyCSSAngle:angle toGradient:gradient];
    [layer insertSublayer:gradient atIndex:0];
    if (theme != TSUgreenLyricsThemeStarrySky) { return; }
    // 星空：几颗不同大小、不同亮度的星点（位置为比例，半径乘 starScale）
    static const CGFloat stars[6][4] = {
        {0.18f, 0.28f, 1.4f, 0.80f}, {0.72f, 0.18f, 1.2f, 0.73f}, {0.86f, 0.66f, 1.6f, 0.87f},
        {0.32f, 0.82f, 1.1f, 0.60f}, {0.56f, 0.22f, 1.2f, 0.53f}, {0.12f, 0.60f, 1.0f, 0.60f},
    };
    CGSize size = layer.bounds.size;
    for (NSUInteger i = 0; i < 6; i++) {
        CGFloat r = stars[i][2] * starScale;
        CALayer *star = [CALayer layer];
        star.frame = CGRectMake(stars[i][0] * size.width - r, stars[i][1] * size.height - r, r * 2, r * 2);
        star.cornerRadius = r;
        star.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:stars[i][3]].CGColor;
        [gradient addSublayer:star];
    }
}

/** CSS 线性渐变角度 → 起止点 */
+ (void)applyCSSAngle:(CGFloat)degrees toGradient:(CAGradientLayer *)gradient {
    CGFloat rad = degrees * M_PI / 180.f;
    CGFloat dx = 0.5f * sin(rad), dy = 0.5f * cos(rad);
    gradient.startPoint = CGPointMake(0.5f - dx, 0.5f + dy);
    gradient.endPoint = CGPointMake(0.5f + dx, 0.5f - dy);
}

#pragma mark - 颜色换算

/** 取 sRGB 分量（0–1） */
+ (void)ts_components:(UIColor *)color r:(CGFloat *)r g:(CGFloat *)g b:(CGFloat *)b a:(CGFloat *)a {
    CGFloat rr = 1, gg = 1, bb = 1, aa = 1;
    if (![color getRed:&rr green:&gg blue:&bb alpha:&aa]) {
        CGFloat white = 1;
        if ([color getWhite:&white alpha:&aa]) { rr = gg = bb = white; }
    }
    *r = MIN(MAX(rr, 0), 1); *g = MIN(MAX(gg, 0), 1); *b = MIN(MAX(bb, 0), 1); *a = MIN(MAX(aa, 0), 1);
}

+ (NSString *)hexRGBAOfColor:(UIColor *)color {
    CGFloat r, g, b, a;
    [self ts_components:color ?: [UIColor whiteColor] r:&r g:&g b:&b a:&a];
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX", lround(r * 255), lround(g * 255), lround(b * 255), lround(a * 255)];
}

+ (NSString *)hexRGBOfColor:(UIColor *)color {
    return [[self hexRGBAOfColor:color] substringToIndex:7];
}

+ (nullable UIColor *)colorFromHex:(NSString *)hex {
    NSString *text = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([text hasPrefix:@"#"]) { text = [text substringFromIndex:1]; }
    if (text.length != 6 && text.length != 8) { return nil; }
    NSCharacterSet *invalid = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if ([text rangeOfCharacterFromSet:invalid].location != NSNotFound) { return nil; }
    unsigned long long value = 0;
    [[NSScanner scannerWithString:text] scanHexLongLong:&value];
    if (text.length == 6) { value = (value << 8) | 0xFF; }
    return [UIColor colorWithRed:((value >> 24) & 0xFF) / 255.f green:((value >> 16) & 0xFF) / 255.f
                            blue:((value >> 8) & 0xFF) / 255.f alpha:(value & 0xFF) / 255.f];
}

+ (NSArray<NSString *> *)paletteHexes {
    return @[@"#FFFFFF", @"#7CF2B0", @"#4AD8FF", @"#8C9BFF", @"#FF8AD8", @"#FF6B6B", @"#FFB547", @"#FFE45C"];
}

+ (NSArray<NSString *> *)gridHexes {
    return @[@"#FFFFFF", @"#FFE45C", @"#FFB547", @"#FF8A5B", @"#FF6B6B", @"#FF8AD8",
             @"#C58CFF", @"#8C9BFF", @"#4AD8FF", @"#4FE3C1", @"#7CF2B0", @"#B9F25A"];
}

/** hsl(hue, 90%, 66%)，分量取整到 0–255，保证 HEX 往返一致 */
+ (UIColor *)colorWithHueDegrees:(CGFloat)degrees {
    CGFloat s = 0.9f, l = 0.66f;
    CGFloat a = s * MIN(l, 1 - l);
    CGFloat channel[3];
    const CGFloat ns[3] = {0, 8, 4};
    for (NSUInteger i = 0; i < 3; i++) {
        CGFloat k = fmod(ns[i] + degrees / 30.f, 12.f);
        CGFloat value = l - a * MAX(-1.f, MIN(MIN(k - 3.f, 9.f - k), 1.f));
        channel[i] = round(value * 255.f) / 255.f;
    }
    return [UIColor colorWithRed:channel[0] green:channel[1] blue:channel[2] alpha:1.f];
}

+ (CGFloat)hueDegreesOfColor:(UIColor *)color {
    CGFloat r, g, b, a;
    [self ts_components:color r:&r g:&g b:&b a:&a];
    CGFloat mx = MAX(r, MAX(g, b)), mn = MIN(r, MIN(g, b)), d = mx - mn;
    if (d <= 0) { return 0; }
    CGFloat h;
    if (mx == r) {
        h = fmod((g - b) / d, 6.f);
    } else if (mx == g) {
        h = (b - r) / d + 2.f;
    } else {
        h = (r - g) / d + 4.f;
    }
    h = round(h * 60.f);
    return h < 0 ? h + 360.f : h;
}

#pragma mark - 文案与错误

+ (NSString *)platformName {
    switch ([TSDeviceCoordinator sharedInstance].snapshot.activeSDKType) {
        case eTSSDKTypeFIT:  return @"FitCloud";
        case eTSSDKTypeTPB:  return @"NPK";
        case eTSSDKTypeFW:   return @"Persimwear";
        case eTSSDKTypeSJ:   return @"SJWatch";
        case eTSSDKTypeCRP:  return @"CRP";
        case eTSSDKTypeUTE:  return @"UTE";
        case eTSSDKTypeBuds: return @"Buds";
        default:             return @"Unknown";
    }
}

/** 错误类别 → 本地化键前缀 */
+ (NSString *)ts_errorKey:(nullable NSError *)error {
    if (!error) { return @"ugreen.error.unknown"; }
    switch (error.code) {
        case eTSErrorNotSupport:              return @"ugreen.error.not_support";
        case eTSErrorTimeoutError:            return @"ugreen.error.timeout";
        case eTSErrorDataSetFailed:           return @"ugreen.error.set_failed";
        case eTSErrorDataGetFailed:           return @"ugreen.error.get_failed";
        case eTSErrorUnConnected:
        case eTSErrorConnectionReset:
        case eTSErrorTransmissionInterrupted: return @"ugreen.error.disconnected";
        case eTSErrorIsBusy:
        case eTSErrorNotReady:                return @"ugreen.error.busy";
        case eTSErrorInvalidParam:
        case eTSErrorParamError:
        case eTSErrorInvalidTypeError:
        case eTSErrorParamSizeError:          return @"ugreen.error.invalid";
        default:                              return @"ugreen.error.unknown";
    }
}

+ (NSString *)errorTitle:(nullable NSError *)error {
    return TSLocalizedString([[self ts_errorKey:error] stringByAppendingString:@".title"]);
}

+ (NSString *)errorText:(nullable NSError *)error {
    NSString *key = [self ts_errorKey:error];
    // 参数错误与未知错误用 SDK 的原始描述，其余用固定说明
    if ([key isEqualToString:@"ugreen.error.invalid"] || [key isEqualToString:@"ugreen.error.unknown"]) {
        if (error.localizedDescription.length) { return error.localizedDescription; }
    }
    return TSLocalizedString([key stringByAppendingString:@".text"]);
}

+ (NSString *)errorCode:(nullable NSError *)error {
    if (!error) { return @""; }
    NSString *domain = error.domain.length ? error.domain : @"-";
    return [NSString stringWithFormat:@"%@ · %@ (%ld)", domain, [TSHsdErrorText codeNameForCode:error.code], (long)error.code];
}

+ (NSString *)errorShortName:(nullable NSError *)error {
    return error ? [TSHsdErrorText codeNameForCode:error.code] : @"UNKNOWN";
}

+ (NSString *)clockSecondsString:(NSDate *)date {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm:ss";
    });
    return [formatter stringFromDate:date];
}

+ (NSString *)clockString:(NSDate *)date {
    return [[self clockSecondsString:date] substringToIndex:5];
}

+ (UIImage *)dotImageWithColor:(UIColor *)color diameter:(CGFloat)diameter {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(diameter, diameter)];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [color setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, diameter, diameter)] fill];
    }];
}

+ (NSAttributedString *)title:(NSString *)title font:(UIFont *)font color:(UIColor *)color modifiedDotColor:(nullable UIColor *)dotColor {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:title ?: @""
                                                                             attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: color}];
    if (!dotColor || !title.length) { return text; }
    // 标题与圆点间距 7（原型 .mod margin-left 7）
    [text addAttribute:NSKernAttributeName value:@7 range:NSMakeRange(title.length - 1, 1)];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [self dotImageWithColor:dotColor diameter:7.f];
    attachment.bounds = CGRectMake(0, (font.capHeight - 7.f) / 2.f, 7.f, 7.f);
    [text appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    return text;
}

@end
