//
//  TSAIChatBannerView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatBannerView.h"

#import "TSAIChatTheme.h"

@interface TSAIChatBannerView ()

// 背景渐变（warn / err）
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
// 图标
@property (nonatomic, strong) UIImageView *iconView;
// 文案
@property (nonatomic, strong) UILabel *textLabel;
// 动作按钮
@property (nonatomic, strong) UIButton *actionButton;
// 动作回调
@property (nonatomic, copy, nullable) void (^actionHandler)(void);
// 自动收起定时器
@property (nonatomic, strong, nullable) NSTimer *dismissTimer;
// 是否显示中
@property (nonatomic, assign, readwrite) BOOL isShowing;

@end

@implementation TSAIChatBannerView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 18;
        self.layer.cornerCurve = kCACornerCurveContinuous;
        self.layer.masksToBounds = NO;
        TSAIChatApplyFloatShadow(self.layer);
        self.alpha = 0;
        self.hidden = YES;

        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.startPoint = CGPointMake(0, 0.2);
        _gradientLayer.endPoint = CGPointMake(1, 0.8);
        _gradientLayer.cornerRadius = 18;
        _gradientLayer.cornerCurve = kCACornerCurveContinuous;
        [self.layer addSublayer:_gradientLayer];

        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.tintColor = [UIColor whiteColor];
        [self addSubview:_iconView];

        _textLabel = [[UILabel alloc] init];
        _textLabel.font = TSAIChatFont(13, UIFontWeightMedium);
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.numberOfLines = 2;
        [self addSubview:_textLabel];

        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _actionButton.titleLabel.font = TSAIChatFont(13, UIFontWeightBold);
        [_actionButton setTitleColor:TSAIChatHexColor(0xB8E8FF) forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(onActionTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_actionButton];
    }
    return self;
}

- (void)dealloc {
    [_dismissTimer invalidate];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    self.iconView.frame = CGRectMake(14, (height - 16) / 2, 16, 16);
    CGFloat actionWidth = 0;
    if (!self.actionButton.hidden) {
        actionWidth = ceil([self.actionButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, height)].width) + 8;
        self.actionButton.frame = CGRectMake(width - 14 - actionWidth, 0, actionWidth, height);
        actionWidth += 10;
    }
    CGFloat textX = 14 + 16 + 10;
    self.textLabel.frame = CGRectMake(textX, 11, width - textX - 14 - actionWidth, height - 22);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat actionWidth = self.actionButton.hidden
        ? 0
        : ceil([self.actionButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, 40)].width) + 18;
    CGFloat textWidth = size.width - 14 - 16 - 10 - 14 - actionWidth;
    CGFloat textHeight = ceil([self.textLabel sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height);
    return CGSizeMake(size.width, MAX(40, textHeight + 22));
}

#pragma mark - 公开方法

- (void)showText:(NSString *)text
          symbol:(NSString *)symbol
           style:(TSAIChatBannerStyle)style
     actionTitle:(NSString *)actionTitle
          action:(void (^)(void))action
        duration:(NSTimeInterval)duration {
    [self.dismissTimer invalidate];
    self.dismissTimer = nil;

    self.textLabel.text = text;
    self.iconView.image = TSAIChatSymbol(symbol, 14, UIImageSymbolWeightSemibold);
    self.actionHandler = action;
    self.actionButton.hidden = actionTitle.length == 0;
    [self.actionButton setTitle:actionTitle forState:UIControlStateNormal];

    switch (style) {
        case TSAIChatBannerStyleWarn:
            self.gradientLayer.colors = @[(id)[TSAIChatHexColor(0x6B4A00) colorWithAlphaComponent:0.94].CGColor,
                                          (id)[TSAIChatHexColor(0x3A2A05) colorWithAlphaComponent:0.94].CGColor];
            break;
        case TSAIChatBannerStyleError:
            self.gradientLayer.colors = @[(id)[TSAIChatHexColor(0x7A1E33) colorWithAlphaComponent:0.94].CGColor,
                                          (id)[TSAIChatHexColor(0x3A1220) colorWithAlphaComponent:0.94].CGColor];
            break;
        case TSAIChatBannerStyleInfo:
        default:
            self.gradientLayer.colors = @[(id)[TSAIChatInkColor() colorWithAlphaComponent:0.94].CGColor,
                                          (id)[TSAIChatInkColor() colorWithAlphaComponent:0.94].CGColor];
            break;
    }

    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];
    [self setNeedsLayout];

    BOOL wasShowing = self.isShowing;
    self.isShowing = YES;
    self.hidden = NO;
    if (!wasShowing) {
        if (TSAIChatReduceMotion()) {
            self.alpha = 1;
            self.transform = CGAffineTransformIdentity;
        } else {
            self.alpha = 0;
            self.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.96, 0.96),
                                                     CGAffineTransformMakeTranslation(0, -16));
            [UIView animateWithDuration:0.35
                                  delay:0
                 usingSpringWithDamping:0.62
                  initialSpringVelocity:0.8
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                self.alpha = 1;
                self.transform = CGAffineTransformIdentity;
            }
                             completion:nil];
        }
    }
    if (duration > 0) {
        self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                             target:self
                                                           selector:@selector(dismiss)
                                                           userInfo:nil
                                                            repeats:NO];
    }
}

- (void)dismiss {
    [self.dismissTimer invalidate];
    self.dismissTimer = nil;
    if (!self.isShowing) return;
    self.isShowing = NO;
    [UIView animateWithDuration:TSAIChatReduceMotion() ? 0 : 0.25
                     animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeTranslation(0, -10);
    }
                     completion:^(BOOL finished) {
        if (!self.isShowing) {
            self.hidden = YES;
            self.transform = CGAffineTransformIdentity;
        }
    }];
}

#pragma mark - 事件

- (void)onActionTapped {
    void (^handler)(void) = self.actionHandler;
    [self dismiss];
    if (handler) handler();
}

@end
