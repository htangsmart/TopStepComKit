//
//  TSAIInterpreterTheme.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterTheme.h"

/// 由 0xRRGGBB 构造颜色
static UIColor *TSAIIColorHex(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

/// toast 的 tag，用于替换上一条
static const NSInteger kTSAIIToastTag = 0x7A5701;

@implementation TSAIInterpreterTheme

#pragma mark - 颜色

+ (UIColor *)paper { return TSAIIColorHex(0xEEF0F3); }
+ (UIColor *)panel { return [UIColor whiteColor]; }
+ (UIColor *)ink { return TSAIIColorHex(0x15171A); }
+ (UIColor *)ink2 { return TSAIIColorHex(0x26292E); }
+ (UIColor *)ink3 { return TSAIIColorHex(0x3B3F46); }
+ (UIColor *)muted { return TSAIIColorHex(0x5B6472); }
+ (UIColor *)line { return TSAIIColorHex(0xE1E4E9); }
+ (UIColor *)jade { return TSAIIColorHex(0x0E7C6B); }
+ (UIColor *)jade50 { return TSAIIColorHex(0xE6F4F1); }
+ (UIColor *)jade200 { return TSAIIColorHex(0x7EE0CC); }
+ (UIColor *)jade900 { return TSAIIColorHex(0x1F3A33); }
+ (UIColor *)cobalt { return TSAIIColorHex(0x2B4FD6); }
+ (UIColor *)cobalt50 { return TSAIIColorHex(0xEAEEFB); }
+ (UIColor *)cobalt200 { return TSAIIColorHex(0xA9B8F5); }
+ (UIColor *)cobalt900 { return TSAIIColorHex(0x243267); }
+ (UIColor *)warn { return TSAIIColorHex(0xB45309); }
+ (UIColor *)danger { return TSAIIColorHex(0xE5484D); }
+ (UIColor *)ok { return TSAIIColorHex(0x34D399); }
+ (UIColor *)textOnDark { return TSAIIColorHex(0xF5F6F8); }
+ (UIColor *)textOnDark2 { return TSAIIColorHex(0xB9C0CA); }
+ (UIColor *)dim { return TSAIIColorHex(0x9AA3AF); }
+ (UIColor *)dimBackground { return TSAIIColorHex(0xF1F2F4); }
+ (UIColor *)grab { return TSAIIColorHex(0xC9CED6); }
+ (UIColor *)sheetBackground { return TSAIIColorHex(0xF5F6F8); }
+ (UIColor *)overlay { return [UIColor colorWithWhite:0 alpha:0.55]; }

#pragma mark - 字体

+ (UIFontWeight)uiWeightForCSSWeight:(NSInteger)weight {
    if (weight >= 700) return UIFontWeightBold;
    if (weight >= 600) return UIFontWeightSemibold;
    if (weight >= 500) return UIFontWeightMedium;
    return UIFontWeightRegular;
}

+ (UIFont *)fontOfSize:(CGFloat)size cssWeight:(NSInteger)weight {
    return [UIFont systemFontOfSize:size weight:[self uiWeightForCSSWeight:weight]];
}

+ (UIFont *)tabularFontOfSize:(CGFloat)size cssWeight:(NSInteger)weight {
    return [UIFont monospacedDigitSystemFontOfSize:size weight:[self uiWeightForCSSWeight:weight]];
}

#pragma mark - 控件

+ (UIButton *)iconButtonWithSymbol:(NSString *)symbolName
                        background:(UIColor *)background
                              tint:(UIColor *)tint
                            target:(id)target
                            action:(SEL)action {
    UIButton *button = [self roundButtonWithSymbol:symbolName
                                         pointSize:20.0
                                        background:background
                                              tint:tint
                                            target:target
                                            action:action];
    button.frame = CGRectMake(0, 0, 44.0, 44.0);
    button.layer.cornerRadius = 22.0;
    return button;
}

+ (UIButton *)roundButtonWithSymbol:(NSString *)symbolName
                          pointSize:(CGFloat)pointSize
                         background:(UIColor *)background
                               tint:(UIColor *)tint
                             target:(id)target
                             action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = background;
    button.tintColor = tint;
    button.clipsToBounds = YES;
    UIImageSymbolConfiguration *cfg =
        [UIImageSymbolConfiguration configurationWithPointSize:pointSize weight:UIImageSymbolWeightMedium];
    UIImage *image = [[UIImage systemImageNamed:symbolName withConfiguration:cfg]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *)ctaButtonWithTitle:(NSString *)title
                          symbol:(NSString *)symbolName
                      background:(UIColor *)background
                            tint:(UIColor *)tint
                       cssWeight:(NSInteger)weight
                          target:(id)target
                          action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButtonConfiguration *cfg = [UIButtonConfiguration plainButtonConfiguration];
    UIBackgroundConfiguration *bg = cfg.background;
    bg.backgroundColor = background;
    cfg.background = bg;
    cfg.cornerStyle = UIButtonConfigurationCornerStyleCapsule;
    cfg.baseForegroundColor = tint;
    cfg.imagePadding = 10.0;
    cfg.contentInsets = NSDirectionalEdgeInsetsMake(0, 16.0, 0, 16.0);
    if (symbolName.length > 0) {
        UIImageSymbolConfiguration *symbolCfg =
            [UIImageSymbolConfiguration configurationWithPointSize:18.0 weight:UIImageSymbolWeightSemibold];
        cfg.image = [[UIImage systemImageNamed:symbolName withConfiguration:symbolCfg]
            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    cfg.attributedTitle = [[NSAttributedString alloc]
        initWithString:title
            attributes:@{ NSFontAttributeName: [self fontOfSize:17.0 cssWeight:weight],
                          NSForegroundColorAttributeName: tint }];
    button.configuration = cfg;
    // 固定文字与图标颜色，避免配置在高亮 / 禁用时自动换色；禁用态由调用方按原型用 alpha 表达。
    button.configurationUpdateHandler = ^(UIButton *b) {
        UIButtonConfiguration *updated = b.configuration;
        updated.baseForegroundColor = tint;
        UIBackgroundConfiguration *updatedBg = updated.background;
        updatedBg.backgroundColor = background;
        updated.background = updatedBg;
        b.configuration = updated;
    };
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIImageView *)symbolViewNamed:(NSString *)symbolName pointSize:(CGFloat)pointSize tint:(UIColor *)tint {
    UIImageSymbolConfiguration *cfg =
        [UIImageSymbolConfiguration configurationWithPointSize:pointSize weight:UIImageSymbolWeightMedium];
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:symbolName withConfiguration:cfg]];
    view.tintColor = tint;
    view.contentMode = UIViewContentModeCenter;
    [view sizeToFit];
    return view;
}

#pragma mark - Toast

+ (void)showToast:(NSString *)message inView:(UIView *)view {
    if (view == nil || message.length == 0) return;
    [[view viewWithTag:kTSAIIToastTag] removeFromSuperview];
    UILabel *toast = [[UILabel alloc] init];
    toast.tag = kTSAIIToastTag;
    toast.text = message;
    toast.font = [self fontOfSize:13.0 cssWeight:400];
    toast.textColor = [UIColor whiteColor];
    toast.backgroundColor = [[self ink] colorWithAlphaComponent:0.92];
    toast.textAlignment = NSTextAlignmentCenter;
    toast.lineBreakMode = NSLineBreakByTruncatingTail;
    toast.layer.cornerRadius = 20.0;
    toast.clipsToBounds = YES;
    CGFloat maxW = CGRectGetWidth(view.bounds) * 0.85;
    CGSize textSize = [toast sizeThatFits:CGSizeMake(maxW - 32.0, CGFLOAT_MAX)];
    CGFloat w = MIN(maxW, textSize.width + 32.0);
    CGFloat h = 40.0;
    toast.frame = CGRectMake((CGRectGetWidth(view.bounds) - w) / 2.0,
                             CGRectGetHeight(view.bounds) - 120.0 - h,
                             w, h);
    toast.alpha = 0;
    [view addSubview:toast];
    [UIView animateWithDuration:0.15 animations:^{ toast.alpha = 1.0; }];
    __weak UILabel *weakToast = toast;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UILabel *strongToast = weakToast;
        if (strongToast == nil) return;
        [UIView animateWithDuration:0.2 animations:^{ strongToast.alpha = 0; } completion:^(BOOL finished) {
            [strongToast removeFromSuperview];
        }];
    });
}

#pragma mark - 格式化

+ (NSString *)elapsedString:(NSTimeInterval)seconds {
    NSInteger total = (NSInteger)MAX(0, floor(seconds));
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(total / 60), (long)(total % 60)];
}

#pragma mark - 导航

+ (BOOL)isInterpreterPage:(UIViewController *)viewController {
    if (viewController == nil) return NO;
    NSString *name = NSStringFromClass([viewController class]);
    return [name isEqualToString:@"TSAIInterpreterSetupVC"]
        || [name isEqualToString:@"TSAIInterpreterVC"]
        || [name isEqualToString:@"TSAIInterpreterReportVC"];
}

@end
