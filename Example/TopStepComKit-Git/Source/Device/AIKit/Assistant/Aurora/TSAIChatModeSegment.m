//
//  TSAIChatModeSegment.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatModeSegment.h"

#import "TSAIChatTheme.h"

@interface TSAIChatModeSegment ()

// 滑块
@property (nonatomic, strong) UIView *thumbView;
// 滑块渐变
@property (nonatomic, strong) CAGradientLayer *thumbGradient;
// 两个按钮（图标 + 文字）
@property (nonatomic, strong) NSArray<UIButton *> *buttons;

@end

@implementation TSAIChatModeSegment

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.56];
        self.layer.cornerRadius = 20;
        self.layer.cornerCurve = kCACornerCurveContinuous;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.75].CGColor;

        _thumbView = [[UIView alloc] init];
        _thumbView.layer.cornerRadius = 16;
        _thumbView.layer.cornerCurve = kCACornerCurveContinuous;
        _thumbView.layer.shadowOffset = CGSizeMake(0, 6);
        _thumbView.layer.shadowRadius = 8;
        _thumbView.layer.shadowOpacity = 0.25;
        _thumbGradient = [CAGradientLayer layer];
        _thumbGradient.startPoint = CGPointMake(0, 0.2);
        _thumbGradient.endPoint = CGPointMake(1, 0.8);
        _thumbGradient.cornerRadius = 16;
        [_thumbView.layer addSublayer:_thumbGradient];
        [self addSubview:_thumbView];

        UIButton *chatButton = [self makeButtonWithTitle:@"AI 对话" symbol:@"bubble.left.fill" tag:TSAIChatPageModeChat];
        UIButton *flowButton = [self makeButtonWithTitle:@"AI 畅聊" symbol:@"waveform" tag:TSAIChatPageModeFlow];
        _buttons = @[chatButton, flowButton];
        [self addSubview:chatButton];
        [self addSubview:flowButton];

        _selectedMode = TSAIChatPageModeChat;
        [self applySelectionAnimated:NO];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat segmentWidth = (width - 8) / 2;
    for (NSInteger index = 0; index < self.buttons.count; index++) {
        self.buttons[index].frame = CGRectMake(4 + segmentWidth * index, 4, segmentWidth, 32);
    }
    [self placeThumb];
    self.thumbGradient.frame = self.thumbView.bounds;
}

#pragma mark - 公开方法

+ (CGFloat)preferredHeight {
    return 40;
}

- (void)setSelectedMode:(TSAIChatPageMode)selectedMode {
    [self setSelectedMode:selectedMode animated:YES];
}

- (void)setSelectedMode:(TSAIChatPageMode)mode animated:(BOOL)animated {
    _selectedMode = mode;
    [self applySelectionAnimated:animated];
}

#pragma mark - 私有方法

/// 创建分段按钮：图标 14 + 文字 13.5/700，间距 6
- (UIButton *)makeButtonWithTitle:(NSString *)title symbol:(NSString *)symbol tag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = tag;
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = TSAIChatFont(13.5, UIFontWeightBold);
    [button setImage:TSAIChatSymbol(symbol, 12, UIImageSymbolWeightBold) forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 3);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, -3);
    button.adjustsImageWhenHighlighted = NO;
    [button addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

/// 滑块位置
- (void)placeThumb {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat segmentWidth = (width - 8) / 2;
    self.thumbView.frame = CGRectMake(4 + segmentWidth * self.selectedMode, 4, segmentWidth, 32);
}

/// 应用选中态：滑块位移 .35s spring，渐变与阴影色同步过渡，文字色 .25s
- (void)applySelectionAnimated:(BOOL)animated {
    BOOL isFlow = self.selectedMode == TSAIChatPageModeFlow;
    NSArray *colors = isFlow
        ? @[(id)TSAIChatSkyColor().CGColor, (id)TSAIChatMintColor().CGColor]
        : @[(id)TSAIChatVioletColor().CGColor, (id)TSAIChatSkyColor().CGColor];
    UIColor *shadowColor = isFlow ? TSAIChatSkyColor() : TSAIChatVioletColor();

    [CATransaction begin];
    [CATransaction setAnimationDuration:animated ? 0.35 : 0];
    self.thumbGradient.colors = colors;
    self.thumbView.layer.shadowColor = shadowColor.CGColor;
    [CATransaction commit];

    void (^moveThumb)(void) = ^{ [self placeThumb]; };
    if (animated && !TSAIChatReduceMotion()) {
        [UIView animateWithDuration:0.35
                              delay:0
             usingSpringWithDamping:0.62
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:moveThumb
                         completion:nil];
    } else {
        moveThumb();
    }

    [UIView transitionWithView:self
                      duration:animated ? 0.25 : 0
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                    animations:^{
        for (UIButton *button in self.buttons) {
            UIColor *color = button.tag == self.selectedMode ? [UIColor whiteColor] : TSAIChatInk2Color();
            [button setTitleColor:color forState:UIControlStateNormal];
            button.tintColor = color;
        }
    }
                    completion:nil];
}

#pragma mark - 事件

- (void)onButtonTapped:(UIButton *)button {
    if (self.locked) {
        TSAIChatPageMode lockedMode = (TSAIChatPageMode)button.tag;
        if (self.onLockedSelect && lockedMode != self.selectedMode) {
            self.onLockedSelect(lockedMode);
        } else if (self.onLockedTap) {
            self.onLockedTap();
        }
        return;
    }
    TSAIChatPageMode mode = (TSAIChatPageMode)button.tag;
    if (mode == self.selectedMode) return;
    [self setSelectedMode:mode animated:YES];
    if (self.onSelect) self.onSelect(mode);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
