//
//  TSHsdDisplay.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdDisplay.h"
#import "TSRootVC.h"

static const NSInteger kTSHsdAppMax  = 47;   // TSHsdWatchApp 最大值
static const NSInteger kTSHsdGameMax = 24;   // TSHsdGameType 最大值

/// 生成 "prefix.N" 的本地化键并取值；找不到（返回键本身）时回退 fallback
static NSString *TSHsdLocalizedIndexed(NSString *prefix, NSInteger index, NSString *fallback) {
    NSString *key = [NSString stringWithFormat:@"%@.%ld", prefix, (long)index];
    NSString *value = TSLocalizedString(key);
    if (!value.length || [value isEqualToString:key]) { return fallback; }
    return value;
}

static NSString *TSHsdUnknown(NSInteger value) {
    return [NSString stringWithFormat:TSLocalizedString(@"hsd.unknown_type_format"), (long)value];
}

static UIColor *TSHsdRGB(NSInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.f green:((hex >> 8) & 0xFF) / 255.f blue:(hex & 0xFF) / 255.f alpha:1.f];
}

@implementation TSHsdDisplay

#pragma mark - 枚举名称

+ (NSString *)appName:(NSInteger)type {
    if (type < 0 || type > kTSHsdAppMax) { return TSHsdUnknown(type); }
    return TSHsdLocalizedIndexed(@"hsd.app", type, TSHsdUnknown(type));
}

+ (NSString *)gameName:(NSInteger)type {
    if (type < 0 || type > kTSHsdGameMax) { return TSHsdUnknown(type); }
    return TSHsdLocalizedIndexed(@"hsd.gametype", type, TSHsdUnknown(type));
}

+ (NSString *)habitTypeName:(TSHsdHabitType)type {
    if (type < TSHsdHabitTypeCustom || type > TSHsdHabitTypeSleep) { return TSHsdUnknown(type); }
    return TSHsdLocalizedIndexed(@"hsd.habit.type", type, TSHsdUnknown(type));
}

+ (NSString *)habitStateName:(TSHsdHabitState)state {
    if (state < TSHsdHabitStateInit || state > TSHsdHabitStateDeleted) { return TSHsdUnknown(state); }
    return TSHsdLocalizedIndexed(@"hsd.habit.state", state, TSHsdUnknown(state));
}

+ (NSString *)taskStateName:(TSHsdTaskState)state {
    if (state < TSHsdTaskStateNotStarted || state > TSHsdTaskStateCompleted) { return TSHsdUnknown(state); }
    return TSHsdLocalizedIndexed(@"hsd.task.state", state, TSHsdUnknown(state));
}

+ (NSString *)trendName:(TSHsdRankingTrend)trend {
    if (trend < TSHsdRankingTrendDown || trend > TSHsdRankingTrendUp) { return TSHsdUnknown(trend); }
    return TSHsdLocalizedIndexed(@"hsd.trend", trend, TSHsdUnknown(trend));
}

+ (NSString *)associatedFunctionName:(TSHsdHabitAssociatedFunction)function {
    if (function < TSHsdHabitAssociatedFunctionNone || function > TSHsdHabitAssociatedFunctionSport) { return TSHsdUnknown(function); }
    return TSHsdLocalizedIndexed(@"hsd.habit.assoc", function, TSHsdUnknown(function));
}

+ (NSString *)parentalFunctionName:(TSHsdParentalControlFunction)function {
    if (function < TSHsdParentalControlFunctionModifyDial || function > TSHsdParentalControlFunctionModifyAlarm) { return TSHsdUnknown(function); }
    return TSHsdLocalizedIndexed(@"hsd.pc.func", function, TSHsdUnknown(function));
}

+ (NSString *)parentalControlModeName:(TSHsdParentalControlMode)mode {
    if (mode < TSHsdParentalControlModeDisableInPeriod || mode > TSHsdParentalControlModeAllowInPeriod) { return TSHsdUnknown(mode); }
    return TSHsdLocalizedIndexed(@"hsd.pc.mode", mode, TSHsdUnknown(mode));
}

+ (NSString *)dateSourceName:(TSHsdUsageDateSource)source {
    return source == TSHsdUsageDateSourceDevice ? TSLocalizedString(@"hsd.usage.source.device") : TSLocalizedString(@"hsd.usage.source.inferred");
}

#pragma mark - 图标

+ (NSString *)symbolForHabitType:(TSHsdHabitType)type {
    switch (type) {
        case TSHsdHabitTypeSport: return @"figure.run";
        case TSHsdHabitTypeStudy: return @"book.fill";
        case TSHsdHabitTypeSleep: return @"moon.zzz.fill";
        case TSHsdHabitTypeCustom:
        default: return @"star.fill";
    }
}

+ (NSString *)symbolForParentalFunction:(TSHsdParentalControlFunction)function {
    switch (function) {
        case TSHsdParentalControlFunctionModifyDial: return @"paintpalette.fill";
        case TSHsdParentalControlFunctionEnterGame: return @"gamecontroller.fill";
        case TSHsdParentalControlFunctionEnterCalculator: return @"plus.slash.minus";
        case TSHsdParentalControlFunctionEnterTask: return @"checklist";
        case TSHsdParentalControlFunctionEnterDateTime: return @"clock";
        case TSHsdParentalControlFunctionEnterMusic: return @"music.note";
        case TSHsdParentalControlFunctionEnterSettings: return @"slider.horizontal.3";
        case TSHsdParentalControlFunctionModifyAlarm: return @"alarm";
        default: return @"shield.fill";
    }
}

+ (NSString *)symbolForGameType:(NSInteger)type {
    static NSArray<NSString *> *symbols = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        symbols = @[@"pawprint.fill", @"square.grid.2x2.fill", @"circle.hexagongrid.fill", @"puzzlepiece.fill", @"airplane",
                    @"car.fill", @"arrow.triangle.turn.up.right.diamond.fill", @"sportscourt.fill", @"plus.slash.minus", @"square.stack.3d.up.fill",
                    @"number.square.fill", @"questionmark.circle.fill", @"arrow.up.circle.fill", @"square.stack.fill", @"point.topleft.down.curvedto.point.bottomright.up",
                    @"scribble", @"24.circle.fill", @"arrow.up.arrow.down.circle.fill", @"circle.grid.cross.fill", @"target",
                    @"soccerball", @"square.fill.on.square.fill", @"circle.grid.3x3.fill", @"bird.fill", @"square.grid.3x3.fill"];
    });
    if (type < 0 || type >= (NSInteger)symbols.count) { return @"gamecontroller.fill"; }
    return symbols[type];
}

+ (NSString *)symbolForApp:(NSInteger)type {
    static NSArray<NSString *> *symbols = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        symbols = @[@"circle.dashed", @"chart.bar.fill", @"heart.fill", @"alarm.fill", @"gamecontroller.fill", @"bed.double.fill",
                    @"calendar", @"cross.case.fill", @"leaf.fill", @"figure.walk", @"waveform.path.ecg", @"drop.fill",
                    @"plus.slash.minus", @"cloud.sun.fill", @"stopwatch.fill", @"music.note", @"sun.max.fill", @"clock.fill",
                    @"paintpalette.fill", @"timer", @"hand.raised.fill", @"globe", @"moon.fill", @"iphone.radiowaves.left.and.right",
                    @"stethoscope", @"ruler.fill", @"calendar.badge.clock", @"clock.arrow.circlepath", @"battery.100", @"cup.and.saucer.fill",
                    @"figure.seated.side", @"hand.point.left.fill", @"power", @"timer.square", @"book.fill", @"qrcode",
                    @"lock.fill", @"phone.fill", @"person.2.fill", @"phone.arrow.up.right", @"mic.fill", @"figure.run",
                    @"bell.badge.fill", @"heart.circle.fill", @"wind", @"camera.fill", @"iphone", @"arrow.down.square.fill"];
    });
    if (type < 0 || type >= (NSInteger)symbols.count) { return @"app.fill"; }
    return symbols[type];
}

+ (nullable UIImage *)symbolImage:(NSString *)name pointSize:(CGFloat)pointSize weight:(UIImageSymbolWeight)weight {
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:pointSize weight:weight];
    UIImage *image = [UIImage systemImageNamed:name withConfiguration:config];
    if (!image) {
        image = [UIImage systemImageNamed:@"questionmark.circle" withConfiguration:config];
    }
    return image;
}

#pragma mark - 格式化

+ (NSString *)timeStringForMinute:(NSInteger)minute {
    if (minute < 0 || minute >= TSHsdMinutesPerDay) {
        return [NSString stringWithFormat:@"%ld", (long)minute];
    }
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(minute / 60), (long)(minute % 60)];
}

+ (NSString *)durationStringForMinutes:(NSInteger)minutes {
    if (minutes < 0) { minutes = 0; }
    NSInteger hours = minutes / 60;
    NSInteger mins = minutes % 60;
    if (hours > 0 && mins > 0) {
        return [NSString stringWithFormat:TSLocalizedString(@"hsd.duration.hm_format"), (long)hours, (long)mins];
    }
    if (hours > 0) {
        return [NSString stringWithFormat:TSLocalizedString(@"hsd.duration.h_format"), (long)hours];
    }
    return [NSString stringWithFormat:TSLocalizedString(@"hsd.duration.m_format"), (long)mins];
}

+ (NSString *)repeatString:(TSAlarmRepeat)repeat {
    if (repeat == TSAlarmRepeatNone) { return TSLocalizedString(@"repeat.once"); }
    if (repeat == TSAlarmRepeatEveryday) { return TSLocalizedString(@"repeat.everyday"); }
    if (repeat == TSAlarmRepeatWorkday) { return TSLocalizedString(@"repeat.weekday"); }
    if (repeat == TSAlarmRepeatWeekend) { return TSLocalizedString(@"repeat.weekend"); }

    NSArray<NSString *> *keys = @[@"weekday.mon", @"weekday.tue", @"weekday.wed", @"weekday.thu", @"weekday.fri", @"weekday.sat", @"weekday.sun"];
    NSMutableArray<NSString *> *days = [NSMutableArray array];
    for (NSInteger i = 0; i < 7; i++) {
        if (repeat & (1 << i)) { [days addObject:TSLocalizedString(keys[i])]; }
    }
    return [days componentsJoinedByString:@" "];
}

+ (NSUInteger)utf8Length:(nullable NSString *)string {
    return [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)byteCountString:(nullable NSString *)string max:(NSUInteger)max {
    return [NSString stringWithFormat:@"%lu / %lu B", (unsigned long)[self utf8Length:string], (unsigned long)max];
}

+ (NSDateFormatter *)ts_formatterWithFormat:(NSString *)format {
    static NSMutableDictionary<NSString *, NSDateFormatter *> *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ cache = [NSMutableDictionary dictionary]; });
    NSDateFormatter *formatter = cache[format];
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = format;
        cache[format] = formatter;
    }
    return formatter;
}

+ (NSString *)clockString:(nullable NSDate *)date {
    if (!date) { return @"--:--"; }
    return [[self ts_formatterWithFormat:@"HH:mm"] stringFromDate:date];
}

+ (NSString *)shortDateString:(nullable NSDate *)date {
    if (!date) { return @"--"; }
    return [[self ts_formatterWithFormat:@"M/d"] stringFromDate:date];
}

+ (NSString *)fullDateString:(nullable NSDate *)date {
    if (!date) { return @"--"; }
    return [[self ts_formatterWithFormat:@"yyyy-MM-dd HH:mm"] stringFromDate:date];
}

+ (NSString *)dayLabelForOffset:(NSInteger)offset date:(nullable NSDate *)date {
    if (offset == 0) { return TSLocalizedString(@"hsd.usage.today"); }
    if (offset == 1) { return TSLocalizedString(@"hsd.usage.yesterday"); }
    if (date) { return [self shortDateString:date]; }
    return [NSString stringWithFormat:@"-%ld d", (long)offset];
}

+ (UIFont *)roundedFontOfSize:(CGFloat)size weight:(UIFontWeight)weight {
    UIFont *base = [UIFont systemFontOfSize:size weight:weight];
    if (@available(iOS 13.0, *)) {
        UIFontDescriptor *descriptor = [base.fontDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded];
        if (descriptor) { return [UIFont fontWithDescriptor:descriptor size:size]; }
    }
    return base;
}

+ (UIFont *)monoFontOfSize:(CGFloat)size {
    return [UIFont monospacedSystemFontOfSize:size weight:UIFontWeightRegular];
}

#pragma mark - 颜色

+ (UIColor *)hueParental  { return TSAdaptiveColor(TSHsdRGB(0x4353E0), TSHsdRGB(0x8794FF)); }
+ (UIColor *)hueClassroom { return TSAdaptiveColor(TSHsdRGB(0x1B8FD6), TSHsdRGB(0x4DB5F5)); }
+ (UIColor *)hueTask      { return TSAdaptiveColor(TSHsdRGB(0xE89B12), TSHsdRGB(0xF5B740)); }
+ (UIColor *)hueHabit     { return TSAdaptiveColor(TSHsdRGB(0x11936B), TSHsdRGB(0x3CCB9B)); }
+ (UIColor *)hueUsage     { return TSAdaptiveColor(TSHsdRGB(0x8450E0), TSHsdRGB(0xB08CFF)); }
+ (UIColor *)hueGame      { return TSAdaptiveColor(TSHsdRGB(0xD9447E), TSHsdRGB(0xF472A8)); }
+ (UIColor *)hueIce       { return TSAdaptiveColor(TSHsdRGB(0xE2533B), TSHsdRGB(0xFF7B63)); }
+ (UIColor *)hueTools     { return TSAdaptiveColor(TSHsdRGB(0x5F6478), TSHsdRGB(0xA2A8BC)); }
+ (UIColor *)statusGood   { return TSAdaptiveColor(TSHsdRGB(0x11936B), TSHsdRGB(0x3CCB9B)); }
+ (UIColor *)statusWarn   { return TSAdaptiveColor(TSHsdRGB(0xB86F00), TSHsdRGB(0xF2B13C)); }
+ (UIColor *)statusBad    { return TSAdaptiveColor(TSHsdRGB(0xD7402B), TSHsdRGB(0xFF6B57)); }
+ (UIColor *)ink          { return TSAdaptiveColor(TSHsdRGB(0x141726), TSHsdRGB(0xF3F5FB)); }
+ (UIColor *)textSecondary{ return TSAdaptiveColor(TSHsdRGB(0x5F6478), TSHsdRGB(0xA2A8BC)); }
+ (UIColor *)textTertiary { return TSAdaptiveColor(TSHsdRGB(0x9BA0B3), TSHsdRGB(0x6C7288)); }
+ (UIColor *)fill         { return TSAdaptiveColor(TSHsdRGB(0xEEF0F6), TSHsdRGB(0x1F2330)); }
+ (UIColor *)card         { return TSAdaptiveColor([UIColor whiteColor], TSHsdRGB(0x161923)); }

+ (UIColor *)tint12:(UIColor *)hue {
    return [hue colorWithAlphaComponent:0.12];
}

+ (UIColor *)colorForTaskState:(TSHsdTaskState)state {
    switch (state) {
        case TSHsdTaskStateOngoing: return [self statusWarn];
        case TSHsdTaskStateCompleted: return [self statusGood];
        case TSHsdTaskStateNotStarted:
        default: return [self textTertiary];
    }
}

+ (UIColor *)colorForHabitState:(TSHsdHabitState)state {
    switch (state) {
        case TSHsdHabitStateOngoing: return [self hueHabit];
        case TSHsdHabitStateCompleted: return [self statusGood];
        case TSHsdHabitStateOverdue: return [self statusWarn];
        case TSHsdHabitStateClosed:
        case TSHsdHabitStateDeleted: return [self statusBad];
        case TSHsdHabitStateInit:
        default: return [self textTertiary];
    }
}

@end
