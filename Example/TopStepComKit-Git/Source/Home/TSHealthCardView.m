//
//  TSHealthCardView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHealthCardView.h"
#import "TSBaseVC.h"

@interface TSHealthCardView ()

// 渐变背景层
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
// 图标
@property (nonatomic, strong) UIImageView *iconView;
// 标题（指标名）
@property (nonatomic, strong) UILabel     *titleLabel;
// 数值
@property (nonatomic, strong) UILabel     *valueLabel;
// 单位/副标题
@property (nonatomic, strong) UILabel     *unitLabel;

@end

@implementation TSHealthCardView

+ (instancetype)cardWithIconName:(NSString *)iconName
                       iconColor:(UIColor *)iconColor
                           title:(NSString *)title
                           value:(NSString *)value {
    TSHealthCardView *card = [[TSHealthCardView alloc] initWithFrame:CGRectZero];
    card.iconName  = iconName;
    card.iconColor = iconColor;
    card.titleText = title;
    card.valueText = value;
    card.enabled   = YES;
    return card;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self ts_setupViews];
        [self ts_setupGesture];
    }
    return self;
}

#pragma mark - 设置视图

- (void)ts_setupViews {
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = TSRadius_LG;
    self.clipsToBounds = YES;

    // 渐变背景层
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.cornerRadius = TSRadius_LG;
    [self.layer insertSublayer:self.gradientLayer atIndex:0];

    // 图标（右上角，半透明大图标）
    self.iconView = [[UIImageView alloc] init];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    [self addSubview:self.iconView];

    // 标题标签（左上角）
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    self.titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    [self addSubview:self.titleLabel];

    // 数值标签（左下，大字号）
    self.valueLabel = [[UILabel alloc] init];
    self.valueLabel.font = [UIFont systemFontOfSize:28.f weight:UIFontWeightBold];
    self.valueLabel.textColor = [UIColor whiteColor];
    self.valueLabel.adjustsFontSizeToFitWidth = YES;
    self.valueLabel.minimumScaleFactor = 0.6f;
    [self addSubview:self.valueLabel];

    // 单位标签（数值下方）
    self.unitLabel = [[UILabel alloc] init];
    self.unitLabel.font = [UIFont systemFontOfSize:11.f weight:UIFontWeightRegular];
    self.unitLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    [self addSubview:self.unitLabel];
}

- (void)ts_setupGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(ts_handleTap)];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
}

- (void)ts_handleTap {
    if (!self.enabled) {
        [self ts_showUnsupportedToast];
        return;
    }
    if (self.onTap) {
        self.onTap();
    }
}

- (void)ts_showUnsupportedToast {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (!window) return;

    UILabel *toast = [[UILabel alloc] init];

    // 根据禁用原因显示不同提示
    if (self.disableReason == 0) {
        toast.text = @"设备未连接";
    } else {
        toast.text = [NSString stringWithFormat:@"当前设备不支持%@", self.titleText];
    }

    toast.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightMedium];
    toast.textColor = [UIColor whiteColor];
    toast.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
    toast.textAlignment = NSTextAlignmentCenter;
    toast.layer.cornerRadius = 18.f;
    toast.clipsToBounds = YES;
    toast.numberOfLines = 1;

    CGFloat padding = 20.f;
    CGSize textSize = [toast.text sizeWithAttributes:@{NSFontAttributeName: toast.font}];
    CGFloat toastW = textSize.width + padding * 2;
    CGFloat toastH = 36.f;
    toast.frame = CGRectMake((window.bounds.size.width - toastW) / 2,
                             window.bounds.size.height - 120.f,
                             toastW, toastH);
    toast.alpha = 0;
    [window addSubview:toast];

    [UIView animateWithDuration:0.2 animations:^{
        toast.alpha = 1.0;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                toast.alpha = 0;
            } completion:^(BOOL f) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - 属性 setter

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    [self ts_applyEnabledState];
}

- (void)setIconName:(NSString *)iconName {
    _iconName = iconName;
    [self ts_updateIcon];
}

- (void)setIconColor:(UIColor *)iconColor {
    _iconColor = iconColor;

    // 根据主色生成渐变（深色 → 浅色）
    CGFloat h, s, b, a;
    [iconColor getHue:&h saturation:&s brightness:&b alpha:&a];
    UIColor *lightColor = [UIColor colorWithHue:h saturation:MAX(s - 0.1f, 0) brightness:MIN(b + 0.15f, 1.0f) alpha:a];
    UIColor *darkColor  = [UIColor colorWithHue:h saturation:MIN(s + 0.1f, 1.0f) brightness:MAX(b - 0.1f, 0) alpha:a];

    self.gradientLayer.colors = @[
        (__bridge id)lightColor.CGColor,
        (__bridge id)darkColor.CGColor
    ];
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint   = CGPointMake(1, 1);

    [self ts_applyEnabledState];
}

- (void)setTitleText:(NSString *)titleText {
    _titleText = titleText;
    self.titleLabel.text = titleText;
}

- (void)setValueText:(NSString *)valueText {
    _valueText = valueText;

    // 解析数值和单位
    if ([valueText containsString:@"bpm"]) {
        self.valueLabel.text = [valueText stringByReplacingOccurrencesOfString:@" bpm" withString:@""];
        self.unitLabel.text = @"次/分钟";
    } else if ([valueText containsString:@"%"]) {
        self.valueLabel.text = valueText;
        self.unitLabel.text = @"血氧饱和度";
    } else if ([valueText containsString:@"/"]) {
        // 血压
        self.valueLabel.text = valueText;
        self.unitLabel.text = @"mmHg";
    } else if ([valueText containsString:@"h"] && [valueText containsString:@"m"]) {
        // 睡眠时长
        self.valueLabel.text = valueText;
        self.unitLabel.text = @"睡眠时长";
    } else if ([valueText containsString:@"步"]) {
        self.valueLabel.text = [valueText stringByReplacingOccurrencesOfString:@" 步" withString:@""];
        self.unitLabel.text = @"步";
    } else if ([valueText containsString:@"°C"]) {
        self.valueLabel.text = valueText;
        self.unitLabel.text = @"体温";
    } else if ([valueText containsString:@"次"]) {
        self.valueLabel.text = [valueText stringByReplacingOccurrencesOfString:@" 次" withString:@""];
        self.unitLabel.text = @"心电记录";
    } else {
        // 压力等其他
        self.valueLabel.text = valueText;
        self.unitLabel.text = @"";
    }
}

#pragma mark - 内部更新

- (void)ts_updateIcon {
    if (!_iconName.length) return;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration
                                           configurationWithPointSize:20
                                                              weight:UIImageSymbolWeightMedium];
        self.iconView.image = [UIImage systemImageNamed:_iconName withConfiguration:cfg];
    } else {
        self.iconView.image = [UIImage imageNamed:_iconName];
    }
}

- (void)ts_applyEnabledState {
    if (_enabled) {
        self.alpha = 1.0f;
    } else {
        self.alpha = 0.5f;
        self.valueLabel.text = @"--";
        self.unitLabel.text = @"不支持";
    }
    // 始终允许交互，点击时根据 enabled 判断是显示 toast 还是跳转
    self.userInteractionEnabled = YES;
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);

    // 更新渐变层 frame
    self.gradientLayer.frame = self.bounds;

    // 图标（右上角，大图标，半透明）
    CGFloat iconSize = 48.f;
    self.iconView.frame = CGRectMake(w - iconSize - 12.f, 12.f, iconSize, iconSize);

    // 标题（左上角）
    self.titleLabel.frame = CGRectMake(16.f, 16.f, w - iconSize - 32.f, 18.f);

    // 数值（左下，大字号）
    CGFloat valueH = 32.f;
    CGFloat valueY = h - valueH - 28.f;
    self.valueLabel.frame = CGRectMake(16.f, valueY, w - 32.f, valueH);

    // 单位（数值下方）
    self.unitLabel.frame = CGRectMake(16.f, CGRectGetMaxY(self.valueLabel.frame) + 2.f, w - 32.f, 14.f);
}

@end
