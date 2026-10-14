//
//  TSHsdWeekdayView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdWeekdayView.h"
#import "TSHsdDisplay.h"
#import "TSRootVC.h"

@implementation TSHsdWeekdayPreset

+ (instancetype)presetWithTitle:(NSString *)title value:(TSAlarmRepeat)value {
    TSHsdWeekdayPreset *preset = [[TSHsdWeekdayPreset alloc] init];
    preset.title = title;
    preset.value = value;
    return preset;
}

+ (NSArray<TSHsdWeekdayPreset *> *)classroomPresets {
    return @[[self presetWithTitle:TSLocalizedString(@"repeat.weekday") value:TSAlarmRepeatWorkday],
             [self presetWithTitle:TSLocalizedString(@"repeat.everyday") value:TSAlarmRepeatEveryday],
             [self presetWithTitle:TSLocalizedString(@"repeat.weekend") value:TSAlarmRepeatWeekend]];
}

+ (NSArray<TSHsdWeekdayPreset *> *)taskPresets {
    return @[[self presetWithTitle:TSLocalizedString(@"repeat.once") value:TSAlarmRepeatNone],
             [self presetWithTitle:TSLocalizedString(@"repeat.weekday") value:TSAlarmRepeatWorkday],
             [self presetWithTitle:TSLocalizedString(@"repeat.everyday") value:TSAlarmRepeatEveryday]];
}

@end

@interface TSHsdWeekdayView ()
@property (nonatomic, strong) NSArray<UIButton *> *dayButtons;
@property (nonatomic, strong) NSMutableArray<UIButton *> *presetButtons;
@end

@implementation TSHsdWeekdayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];
    _presetButtons = [NSMutableArray array];

    NSArray<NSString *> *keys = @[@"weekday.mon.short", @"weekday.tue.short", @"weekday.wed.short", @"weekday.thu.short",
                                  @"weekday.fri.short", @"weekday.sat.short", @"weekday.sun.short"];
    NSMutableArray<UIButton *> *days = [NSMutableArray array];
    for (NSInteger i = 0; i < 7; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightSemibold];
        [button setTitle:TSLocalizedString(keys[i]) forState:UIControlStateNormal];
        button.layer.cornerRadius = 19.f;
        [button addTarget:self action:@selector(ts_dayTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [days addObject:button];
    }
    self.dayButtons = [days copy];
    [self ts_apply];
    return self;
}

- (void)setPresets:(nullable NSArray<TSHsdWeekdayPreset *> *)presets {
    _presets = [presets copy];
    for (UIButton *button in self.presetButtons) { [button removeFromSuperview]; }
    [self.presetButtons removeAllObjects];
    [presets enumerateObjectsUsingBlock:^(TSHsdWeekdayPreset *preset, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = idx;
        button.titleLabel.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightSemibold];
        [button setTitle:preset.title forState:UIControlStateNormal];
        button.layer.cornerRadius = 13.f;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 12.f, 0, 12.f);
        [button addTarget:self action:@selector(ts_presetTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.presetButtons addObject:button];
    }];
    [self ts_apply];
}

- (void)setRepeat:(TSAlarmRepeat)repeat { _repeat = repeat; [self ts_apply]; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_apply]; }

- (void)ts_apply {
    for (NSInteger i = 0; i < 7; i++) {
        UIButton *button = self.dayButtons[i];
        BOOL on = (self.repeat & (1 << i)) != 0;
        button.backgroundColor = on ? self.hue : [TSHsdDisplay fill];
        [button setTitleColor:on ? [UIColor whiteColor] : [TSHsdDisplay textSecondary] forState:UIControlStateNormal];
        button.layer.shadowColor = self.hue.CGColor;
        button.layer.shadowOpacity = on ? 0.35f : 0;
        button.layer.shadowRadius = 5.f;
        button.layer.shadowOffset = CGSizeMake(0, 4.f);
    }
    [self.presetButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        BOOL on = self.repeat == self.presets[idx].value;
        button.backgroundColor = on ? [TSHsdDisplay tint12:self.hue] : [TSHsdDisplay fill];
        [button setTitleColor:on ? self.hue : [TSHsdDisplay textSecondary] forState:UIControlStateNormal];
    }];
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat h = 16.f + 38.f + 12.f;
    if (self.presets.count) { h += 26.f + 16.f; }
    return CGSizeMake(size.width, h);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width - 32.f;
    CGFloat gap = (w - 38.f * 7) / 6.f;
    for (NSInteger i = 0; i < 7; i++) {
        self.dayButtons[i].frame = CGRectMake(16.f + i * (38.f + gap), 16.f, 38.f, 38.f);
    }
    CGFloat x = 16.f;
    for (UIButton *button in self.presetButtons) {
        [button sizeToFit];
        CGFloat bw = ceil(button.bounds.size.width);
        button.frame = CGRectMake(x, 66.f, bw, 26.f);
        x += bw + 6.f;
    }
}

- (void)ts_dayTapped:(UIButton *)sender {
    _repeat ^= (1 << sender.tag);
    [self ts_apply];
    if (self.onChange) { self.onChange(self.repeat); }
}

- (void)ts_presetTapped:(UIButton *)sender {
    _repeat = self.presets[sender.tag].value;
    [self ts_apply];
    if (self.onChange) { self.onChange(self.repeat); }
}

@end
