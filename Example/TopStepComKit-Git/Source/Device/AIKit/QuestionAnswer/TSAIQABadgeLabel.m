//
//  TSAIQABadgeLabel.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQABadgeLabel.h"

#import "TSAIQATheme.h"

static const CGFloat kTSAIQABadgeHeight = 22.0;
static const CGFloat kTSAIQABadgeDotSize = 6.0;
static NSString * const kTSAIQABadgeBlinkKey = @"TSAIQABadgeBlink";

@interface TSAIQABadgeLabel ()

// 前置圆点
@property (nonatomic, strong) UIView *dotView;
// 文字
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation TSAIQABadgeLabel

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 7.0;
        self.layer.masksToBounds = YES;
        [self addSubview:self.dotView];
        [self addSubview:self.textLabel];
        [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                              forAxis:UILayoutConstraintAxisHorizontal];
        self.style = TSAIQABadgeStyleIdle;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = CGRectGetHeight(self.bounds);
    self.dotView.frame = CGRectMake(8.0, (height - kTSAIQABadgeDotSize) / 2.0,
                                    kTSAIQABadgeDotSize, kTSAIQABadgeDotSize);
    CGFloat textX = CGRectGetMaxX(self.dotView.frame) + 5.0;
    self.textLabel.frame = CGRectMake(textX, 0, CGRectGetWidth(self.bounds) - textX - 8.0, height);
}

- (CGSize)intrinsicContentSize {
    CGSize textSize = [self.textLabel.text ?: @"" sizeWithAttributes:@{NSFontAttributeName: self.textLabel.font}];
    return CGSizeMake(ceil(textSize.width) + 8.0 + kTSAIQABadgeDotSize + 5.0 + 8.0, kTSAIQABadgeHeight);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self intrinsicContentSize];
}

#pragma mark - 公开方法

- (void)applyText:(NSString *)text style:(TSAIQABadgeStyle)style {
    self.text = text;
    self.style = style;
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    self.textLabel.text = text;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setStyle:(TSAIQABadgeStyle)style {
    _style = style;
    UIColor *foreground = TSAIQATextTertiaryColor();
    UIColor *background = [UIColor colorWithWhite:0 alpha:0.04];
    switch (style) {
        case TSAIQABadgeStyleLive:
            foreground = TSAIQADeepTintColor();
            background = TSAIQASoftTintColor();
            break;
        case TSAIQABadgeStyleSuccess:
            foreground = TSAIQASuccessColor();
            background = [TSAIQASuccessColor() colorWithAlphaComponent:0.10];
            break;
        case TSAIQABadgeStyleDanger:
            foreground = TSAIQADangerColor();
            background = [TSAIQADangerColor() colorWithAlphaComponent:0.10];
            break;
        case TSAIQABadgeStyleWarning:
            foreground = [UIColor colorWithRed:0xA8 / 255.0 green:0x6E / 255.0 blue:0 alpha:1.0];
            background = [UIColor colorWithRed:1.0 green:0xB0 / 255.0 blue:0x20 / 255.0 alpha:0.14];
            break;
        case TSAIQABadgeStyleIdle:
        default:
            break;
    }
    self.backgroundColor = background;
    self.textLabel.textColor = foreground;
    self.dotView.backgroundColor = foreground;
    [self updateBlinkAnimation];
}

#pragma mark - 私有方法

/// 进行中样式让圆点呼吸闪烁
- (void)updateBlinkAnimation {
    [self.dotView.layer removeAnimationForKey:kTSAIQABadgeBlinkKey];
    if (self.style != TSAIQABadgeStyleLive) {
        return;
    }
    CABasicAnimation *blink = [CABasicAnimation animationWithKeyPath:@"opacity"];
    blink.fromValue = @1.0;
    blink.toValue = @0.25;
    blink.duration = 0.5;
    blink.autoreverses = YES;
    blink.repeatCount = HUGE_VALF;
    [self.dotView.layer addAnimation:blink forKey:kTSAIQABadgeBlinkKey];
}

#pragma mark - 属性（懒加载）

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [[UIView alloc] init];
        _dotView.layer.cornerRadius = kTSAIQABadgeDotSize / 2.0;
    }
    return _dotView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:10.5 weight:UIFontWeightBold];
    }
    return _textLabel;
}

@end
