//
//  TSAIKitRootHeroView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/20.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIKitRootHeroView.h"

static const CGFloat kHeroPadding         = 22.0;
static const CGFloat kHeroEyebrowHeight   = 14.0;
static const CGFloat kHeroEyebrowGap      = 12.0;
static const CGFloat kHeroTitleHeight     = 64.0;
static const CGFloat kHeroTitleGap        = 8.0;
static const CGFloat kHeroSubtitleHeight  = 36.0;
static const CGFloat kHeroSubtitleGap     = 18.0;
static const CGFloat kHeroButtonHeight    = 44.0;
static const CGFloat kHeroButtonGap       = 10.0;

@interface TSAIKitRootHeroView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIView *eyebrowDot;
@property (nonatomic, strong) UILabel *eyebrowLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *primaryButton;
@property (nonatomic, strong) UIButton *secondaryButton;

@end

@implementation TSAIKitRootHeroView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutHero];
}

#pragma mark - 公开方法

+ (CGFloat)heightForWidth:(CGFloat)width {
    return kHeroPadding
         + kHeroEyebrowHeight
         + kHeroEyebrowGap
         + kHeroTitleHeight
         + kHeroTitleGap
         + kHeroSubtitleHeight
         + kHeroSubtitleGap
         + kHeroButtonHeight
         + kHeroPadding;
}

#pragma mark - 私有方法 - 视图搭建 / 布局

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 24.0;
    self.clipsToBounds = YES;

    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.colors = @[
        (id)[UIColor colorWithRed:0x6E/255.0 green:0x92/255.0 blue:0xFF/255.0 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0x9C/255.0 green:0x6D/255.0 blue:0xFF/255.0 alpha:1.0].CGColor,
    ];
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 1);
    [self.layer insertSublayer:self.gradientLayer atIndex:0];

    [self addSubview:self.eyebrowDot];
    [self addSubview:self.eyebrowLabel];
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
    [self addSubview:self.primaryButton];
    [self addSubview:self.secondaryButton];
}

- (void)layoutHero {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat innerW = width - kHeroPadding * 2;

    self.gradientLayer.frame = self.bounds;

    CGFloat y = kHeroPadding;
    CGFloat dotSize = 6.0;
    self.eyebrowDot.frame = CGRectMake(kHeroPadding, y + (kHeroEyebrowHeight - dotSize) / 2.0,
                                       dotSize, dotSize);
    self.eyebrowDot.layer.cornerRadius = dotSize / 2.0;
    self.eyebrowLabel.frame = CGRectMake(CGRectGetMaxX(self.eyebrowDot.frame) + 6.0, y,
                                         innerW - dotSize - 6.0, kHeroEyebrowHeight);
    y += kHeroEyebrowHeight + kHeroEyebrowGap;

    self.titleLabel.frame = CGRectMake(kHeroPadding, y, innerW, kHeroTitleHeight);
    y += kHeroTitleHeight + kHeroTitleGap;

    self.subtitleLabel.frame = CGRectMake(kHeroPadding, y, innerW, kHeroSubtitleHeight);
    y += kHeroSubtitleHeight + kHeroSubtitleGap;

    CGFloat buttonWidth = (innerW - kHeroButtonGap) / 2.0;
    self.primaryButton.frame = CGRectMake(kHeroPadding, y, buttonWidth, kHeroButtonHeight);
    self.secondaryButton.frame = CGRectMake(kHeroPadding + buttonWidth + kHeroButtonGap, y,
                                            buttonWidth, kHeroButtonHeight);
    self.primaryButton.layer.cornerRadius = 12.0;
    self.secondaryButton.layer.cornerRadius = 12.0;
}

#pragma mark - 私有方法 - 事件

- (void)onPrimaryButtonTap {
    if (self.onPrimaryTap) self.onPrimaryTap();
}

- (void)onSecondaryButtonTap {
    if (self.onSecondaryTap) self.onSecondaryTap();
}

#pragma mark - 属性（懒加载）

- (UIView *)eyebrowDot {
    if (!_eyebrowDot) {
        _eyebrowDot = [[UIView alloc] init];
        _eyebrowDot.backgroundColor = [UIColor colorWithRed:0xB7/255.0 green:0xF5/255.0 blue:0xC0/255.0 alpha:1.0];
        _eyebrowDot.layer.shadowColor = _eyebrowDot.backgroundColor.CGColor;
        _eyebrowDot.layer.shadowOpacity = 1.0;
        _eyebrowDot.layer.shadowRadius = 4.0;
        _eyebrowDot.layer.shadowOffset = CGSizeZero;
    }
    return _eyebrowDot;
}

- (UILabel *)eyebrowLabel {
    if (!_eyebrowLabel) {
        _eyebrowLabel = [[UILabel alloc] init];
        _eyebrowLabel.font = [UIFont systemFontOfSize:11.0 weight:UIFontWeightHeavy];
        _eyebrowLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
        NSDictionary *attrs = @{ NSKernAttributeName: @(1.5) };
        _eyebrowLabel.attributedText = [[NSAttributedString alloc] initWithString:@"TOPSTEPCOMKIT · AI"
                                                                       attributes:attrs];
    }
    return _eyebrowLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:24.0 weight:UIFontWeightBold];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 2;
        _titleLabel.text = @"All AI capabilities,\nin one playground.";
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:13.0];
        _subtitleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        _subtitleLabel.numberOfLines = 2;
        _subtitleLabel.text = @"流式对话、同传、语音、翻译——四大能力域全协议覆盖，点选即测。";
    }
    return _subtitleLabel;
}

- (UIButton *)primaryButton {
    if (!_primaryButton) {
        _primaryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _primaryButton.backgroundColor = [UIColor whiteColor];
        [_primaryButton setTitle:@"Voice Chat" forState:UIControlStateNormal];
        UIColor *primaryTint = [UIColor colorWithRed:0x4F/255.0 green:0x7B/255.0 blue:0xFF/255.0 alpha:1.0];
        [_primaryButton setTitleColor:primaryTint forState:UIControlStateNormal];
        _primaryButton.tintColor = primaryTint;
        _primaryButton.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
        [self decorateButton:_primaryButton withSystemImageName:@"sparkles"];
        _primaryButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _primaryButton.layer.shadowOpacity = 0.12;
        _primaryButton.layer.shadowOffset = CGSizeMake(0, 6);
        _primaryButton.layer.shadowRadius = 12.0;
        [_primaryButton addTarget:self action:@selector(onPrimaryButtonTap)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _primaryButton;
}

- (UIButton *)secondaryButton {
    if (!_secondaryButton) {
        _secondaryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _secondaryButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
        [_secondaryButton setTitle:@"同传" forState:UIControlStateNormal];
        [_secondaryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _secondaryButton.tintColor = [UIColor whiteColor];
        _secondaryButton.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
        [self decorateButton:_secondaryButton withSystemImageName:@"globe"];
        _secondaryButton.layer.borderWidth = 1.0;
        _secondaryButton.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25].CGColor;
        [_secondaryButton addTarget:self action:@selector(onSecondaryButtonTap)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    return _secondaryButton;
}

#pragma mark - 私有方法 - 工具

/// 给按钮加 SF Symbol 图标，并在图标与文字之间留 6pt 间距
- (void)decorateButton:(UIButton *)button withSystemImageName:(NSString *)imageName {
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config =
            [UIImageSymbolConfiguration configurationWithPointSize:14.0 weight:UIImageSymbolWeightSemibold];
        UIImage *image = [UIImage systemImageNamed:imageName withConfiguration:config];
        [button setImage:image forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -3.0, 0, 3.0);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 3.0, 0, -3.0);
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 3.0, 0, 3.0);
    }
}

@end
