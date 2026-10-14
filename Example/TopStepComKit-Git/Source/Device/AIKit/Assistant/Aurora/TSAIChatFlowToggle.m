//
//  TSAIChatFlowToggle.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatFlowToggle.h"

#import "TSAIChatTheme.h"

// 高度 / 左右内边距 / 图标与文字间距 / 图标尺寸
static const CGFloat kToggleHeight = 30;
static const CGFloat kTogglePaddingX = 12;
static const CGFloat kToggleIconGap = 5;
static const CGFloat kToggleIconSize = 14;

@interface TSAIChatFlowToggle ()

// 渐变底（记录态显示）
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
// 图标
@property (nonatomic, strong) UIImageView *iconView;
// 文字
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TSAIChatFlowToggle

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = kToggleHeight / 2;
        self.layer.cornerCurve = kCACornerCurveContinuous;
        self.layer.borderWidth = 1;
        TSAIChatApplyCardShadow(self.layer);

        _gradientLayer = TSAIChatFlowGradientLayer();
        _gradientLayer.cornerRadius = kToggleHeight / 2;
        _gradientLayer.cornerCurve = kCACornerCurveContinuous;
        [self.layer addSublayer:_gradientLayer];

        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeCenter;
        _iconView.userInteractionEnabled = NO;
        [self addSubview:_iconView];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = TSAIChatFont(12, UIFontWeightBold);
        _titleLabel.userInteractionEnabled = NO;
        [self addSubview:_titleLabel];

        self.isAccessibilityElement = YES;
        self.accessibilityTraits = UIAccessibilityTraitButton;

        [self addTarget:self action:@selector(onTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(onPressed) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(onReleased)
       forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel | UIControlEventTouchDragExit];

        _currentStage = TSAIChatFlowStageOrb;
        [self applyStyleAnimated:NO];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat titleWidth = ceil([self.titleLabel sizeThatFits:CGSizeMake(200, kToggleHeight)].width);
    return CGSizeMake(kTogglePaddingX * 2 + kToggleIconSize + kToggleIconGap + titleWidth, kToggleHeight);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = CGRectGetHeight(self.bounds);
    self.iconView.frame = CGRectMake(kTogglePaddingX, (height - kToggleIconSize) / 2, kToggleIconSize, kToggleIconSize);
    CGFloat titleX = CGRectGetMaxX(self.iconView.frame) + kToggleIconGap;
    self.titleLabel.frame = CGRectMake(titleX, 0, CGRectGetWidth(self.bounds) - titleX - kTogglePaddingX, height);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.gradientLayer.frame = self.bounds;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:kToggleHeight / 2].CGPath;
    [CATransaction commit];
}

#pragma mark - 公开方法

+ (CGFloat)preferredHeight {
    return kToggleHeight;
}

- (void)setCurrentStage:(TSAIChatFlowStage)currentStage {
    [self setCurrentStage:currentStage animated:YES];
}

- (void)setCurrentStage:(TSAIChatFlowStage)stage animated:(BOOL)animated {
    if (_currentStage == stage) return;
    _currentStage = stage;
    [self applyStyleAnimated:animated];
}

#pragma mark - 私有方法

/// 点击后要切换到的主区
- (TSAIChatFlowStage)nextStage {
    return self.currentStage == TSAIChatFlowStageOrb ? TSAIChatFlowStageTranscript : TSAIChatFlowStageOrb;
}

/// 应用样式：光球态 = 磨砂胶囊「记录」；记录态 = 渐变胶囊「光球」
- (void)applyStyleAnimated:(BOOL)animated {
    BOOL showingTranscript = self.currentStage == TSAIChatFlowStageTranscript;
    NSString *title = showingTranscript ? @"光球" : @"记录";
    NSString *symbol = showingTranscript ? @"waveform" : @"list.bullet.rectangle";
    UIColor *inkColor = showingTranscript ? [UIColor whiteColor] : TSAIChatInkColor();
    UIColor *shadowColor = showingTranscript ? TSAIChatSkyColor() : TSAIChatHexColor(0x3B2E8A);

    void (^apply)(void) = ^{
        self.titleLabel.text = title;
        self.titleLabel.textColor = inkColor;
        self.iconView.image = TSAIChatSymbol(symbol, 11, UIImageSymbolWeightBold);
        self.iconView.tintColor = inkColor;
        self.backgroundColor = showingTranscript ? [UIColor clearColor] : TSAIChatGlassColor();
        self.layer.borderColor = (showingTranscript ? [UIColor colorWithWhite:1 alpha:0.35] : TSAIChatGlassLineColor()).CGColor;
        self.layer.shadowColor = shadowColor.CGColor;
        self.layer.shadowOpacity = showingTranscript ? 0.3 : 0.08;
        self.gradientLayer.hidden = !showingTranscript;
        self.accessibilityLabel = [NSString stringWithFormat:@"切换到%@", title];
    };

    if (animated && !TSAIChatReduceMotion()) {
        [UIView transitionWithView:self
                          duration:0.25
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                        animations:apply
                        completion:nil];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        apply();
        [CATransaction commit];
    }
}

#pragma mark - 事件

- (void)onTapped {
    TSAIChatFlowStage next = [self nextStage];
    if (self.onToggle) self.onToggle(next);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)onPressed {
    [UIView animateWithDuration:0.15 animations:^{
        self.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }];
}

- (void)onReleased {
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

@end
