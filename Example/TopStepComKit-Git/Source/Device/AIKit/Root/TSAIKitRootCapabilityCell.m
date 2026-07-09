//
//  TSAIKitRootCapabilityCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/20.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIKitRootCapabilityCell.h"

#import "TSAIKitRootCapability.h"
#import "TSAIKitRootIconView.h"

@interface TSAIKitRootCapabilityCell ()

/// 阴影载体（不裁剪），承载 cardView 的圆角阴影
@property (nonatomic, strong) UIView *shadowView;
/// 卡片背景容器（裁剪圆角，光晕和内容都在内部）
@property (nonatomic, strong) UIView *cardView;
/// 右上角光晕载体
@property (nonatomic, strong) UIView *glowView;
/// 径向渐变 layer，从中心 tint 渐变到透明，呈现淡淡光晕
@property (nonatomic, strong) CAGradientLayer *glowLayer;
/// 图标背景方块
@property (nonatomic, strong) UIView *iconBackground;
/// 矢量图标
@property (nonatomic, strong) TSAIKitRootIconView *iconView;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;
/// 副标题
@property (nonatomic, strong) UILabel *subtitleLabel;
/// 右下角箭头容器
@property (nonatomic, strong) UIView *arrowBackground;
/// 箭头图形
@property (nonatomic, strong) CAShapeLayer *arrowLayer;
/// 当前绑定的模型
@property (nonatomic, strong) TSAIKitRootCapability *capability;

@end

@implementation TSAIKitRootCapabilityCell

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
    [self layoutCard];
}

#pragma mark - 公开方法

- (void)bindCapability:(TSAIKitRootCapability *)capability {
    self.capability = capability;
    self.titleLabel.text = capability.title;
    self.subtitleLabel.text = capability.subtitle;

    self.iconView.iconType = capability.iconType;
    self.iconView.tintColor = capability.tintColor;

    UIColor *softTint = [capability.tintColor colorWithAlphaComponent:0.10];
    self.iconBackground.backgroundColor = softTint;
    self.arrowBackground.backgroundColor = softTint;
    self.arrowLayer.strokeColor = capability.tintColor.CGColor;

    self.glowLayer.colors = @[
        (id)[capability.tintColor colorWithAlphaComponent:0.32].CGColor,
        (id)[capability.tintColor colorWithAlphaComponent:0.16].CGColor,
        (id)[capability.tintColor colorWithAlphaComponent:0.0].CGColor,
    ];

    [self setNeedsLayout];
}

#pragma mark - 私有方法 - 视图搭建

- (void)setupViews {
    self.contentView.backgroundColor = [UIColor clearColor];

    [self.contentView addSubview:self.shadowView];
    [self.shadowView addSubview:self.cardView];

    [self.cardView addSubview:self.glowView];
    [self.glowView.layer addSublayer:self.glowLayer];
    [self.cardView addSubview:self.iconBackground];
    [self.iconBackground addSubview:self.iconView];
    [self.cardView addSubview:self.titleLabel];
    [self.cardView addSubview:self.subtitleLabel];
    [self.cardView addSubview:self.arrowBackground];
    [self.arrowBackground.layer addSublayer:self.arrowLayer];
}

#pragma mark - 私有方法 - 布局

- (void)layoutCard {
    self.shadowView.frame = self.contentView.bounds;
    self.cardView.frame = self.shadowView.bounds;
    self.shadowView.layer.shadowPath =
        [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds cornerRadius:18.0].CGPath;

    BOOL isFull = (self.capability.widthStyle == TSAIKitRootCapabilityWidthFull);
    if (isFull) {
        [self layoutFullWidth];
    } else {
        [self layoutHalfWidth];
    }
    [self updateArrowPath];
}

/// 半宽（2 列网格）布局：图标在左上，文字在下方，箭头右下
- (void)layoutHalfWidth {
    CGFloat width = CGRectGetWidth(self.cardView.bounds);
    CGFloat height = CGRectGetHeight(self.cardView.bounds);
    CGFloat padding = 16.0;

    [self positionGlowAtTopRightWithCardSize:CGSizeMake(width, height)];

    CGFloat iconSize = 40.0;
    self.iconBackground.frame = CGRectMake(padding, padding, iconSize, iconSize);
    self.iconView.frame = CGRectInset(self.iconBackground.bounds, 9, 9);

    CGFloat arrowSize = 24.0;
    self.arrowBackground.frame = CGRectMake(width - padding - arrowSize,
                                            height - padding - arrowSize,
                                            arrowSize, arrowSize);

    CGFloat textX = padding;
    CGFloat textW = width - padding * 2;
    CGFloat titleY = CGRectGetMaxY(self.iconBackground.frame) + 12.0;
    self.titleLabel.frame = CGRectMake(textX, titleY, textW, 20.0);
    self.subtitleLabel.frame = CGRectMake(textX, CGRectGetMaxY(self.titleLabel.frame) + 2.0,
                                          textW - arrowSize - 6.0, 32.0);
}

/// 全宽（横跨整行）布局：图标左 + 文字中 + 箭头右，单行排布
- (void)layoutFullWidth {
    CGFloat width = CGRectGetWidth(self.cardView.bounds);
    CGFloat height = CGRectGetHeight(self.cardView.bounds);
    CGFloat padding = 16.0;

    [self positionGlowAtTopRightWithCardSize:CGSizeMake(width, height)];

    CGFloat iconSize = 44.0;
    self.iconBackground.frame = CGRectMake(padding, (height - iconSize) / 2.0, iconSize, iconSize);
    self.iconView.frame = CGRectInset(self.iconBackground.bounds, 10, 10);

    CGFloat arrowSize = 24.0;
    self.arrowBackground.frame = CGRectMake(width - padding - arrowSize,
                                            (height - arrowSize) / 2.0,
                                            arrowSize, arrowSize);

    CGFloat textX = CGRectGetMaxX(self.iconBackground.frame) + 14.0;
    CGFloat textW = CGRectGetMinX(self.arrowBackground.frame) - 10.0 - textX;
    CGFloat titleH = 20.0;
    CGFloat subH = 16.0;
    CGFloat textBlockH = titleH + 2.0 + subH;
    CGFloat titleY = (height - textBlockH) / 2.0;

    self.titleLabel.frame = CGRectMake(textX, titleY, textW, titleH);
    self.subtitleLabel.frame = CGRectMake(textX, CGRectGetMaxY(self.titleLabel.frame) + 2.0,
                                          textW, subH);
    self.subtitleLabel.numberOfLines = 1;
}

/// 把光晕摆到右上角，渐变中心略超出卡片右上，呈现向内淡出的弥散感
- (void)positionGlowAtTopRightWithCardSize:(CGSize)cardSize {
    CGFloat glowSize = MAX(cardSize.width, cardSize.height) * 1.4;
    self.glowView.frame = CGRectMake(cardSize.width - glowSize * 0.4,
                                     -glowSize * 0.55,
                                     glowSize, glowSize);
    self.glowLayer.frame = self.glowView.bounds;
}

- (void)updateArrowPath {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat w = CGRectGetWidth(self.arrowBackground.bounds);
    CGFloat h = CGRectGetHeight(self.arrowBackground.bounds);
    [path moveToPoint:CGPointMake(w * 0.40, h * 0.30)];
    [path addLineToPoint:CGPointMake(w * 0.62, h * 0.50)];
    [path addLineToPoint:CGPointMake(w * 0.40, h * 0.70)];

    self.arrowLayer.frame = self.arrowBackground.bounds;
    self.arrowLayer.path = path.CGPath;
    self.arrowLayer.lineWidth = 1.8;
}

#pragma mark - 属性（懒加载）

- (UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor = [UIColor clearColor];
        _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        _shadowView.layer.shadowOpacity = 0.06;
        _shadowView.layer.shadowOffset = CGSizeMake(0, 6);
        _shadowView.layer.shadowRadius = 12.0;
    }
    return _shadowView;
}

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = [UIColor whiteColor];
        _cardView.layer.cornerRadius = 18.0;
        _cardView.layer.borderWidth = 1.0;
        _cardView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.06].CGColor;
        _cardView.clipsToBounds = YES;
    }
    return _cardView;
}

- (UIView *)glowView {
    if (!_glowView) {
        _glowView = [[UIView alloc] init];
        _glowView.backgroundColor = [UIColor clearColor];
        _glowView.userInteractionEnabled = NO;
    }
    return _glowView;
}

- (CAGradientLayer *)glowLayer {
    if (!_glowLayer) {
        _glowLayer = [CAGradientLayer layer];
        _glowLayer.type = kCAGradientLayerRadial;
        _glowLayer.startPoint = CGPointMake(0.5, 0.5);
        _glowLayer.endPoint = CGPointMake(1.0, 1.0);
        _glowLayer.locations = @[ @0.0, @0.45, @1.0 ];
    }
    return _glowLayer;
}

- (UIView *)iconBackground {
    if (!_iconBackground) {
        _iconBackground = [[UIView alloc] init];
        _iconBackground.layer.cornerRadius = 12.0;
    }
    return _iconBackground;
}

- (TSAIKitRootIconView *)iconView {
    if (!_iconView) {
        _iconView = [[TSAIKitRootIconView alloc] init];
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
        _titleLabel.textColor = [UIColor colorWithRed:0x0E/255.0 green:0x13/255.0 blue:0x30/255.0 alpha:1.0];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:11.0];
        _subtitleLabel.textColor = [UIColor colorWithRed:0x4A/255.0 green:0x51/255.0 blue:0x70/255.0 alpha:1.0];
        _subtitleLabel.numberOfLines = 2;
    }
    return _subtitleLabel;
}

- (UIView *)arrowBackground {
    if (!_arrowBackground) {
        _arrowBackground = [[UIView alloc] init];
        _arrowBackground.layer.cornerRadius = 12.0;
    }
    return _arrowBackground;
}

- (CAShapeLayer *)arrowLayer {
    if (!_arrowLayer) {
        _arrowLayer = [CAShapeLayer layer];
        _arrowLayer.fillColor = [UIColor clearColor].CGColor;
        _arrowLayer.lineCap = kCALineCapRound;
        _arrowLayer.lineJoin = kCALineJoinRound;
    }
    return _arrowLayer;
}

@end
