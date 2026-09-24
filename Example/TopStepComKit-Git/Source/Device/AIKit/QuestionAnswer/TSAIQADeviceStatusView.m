//
//  TSAIQADeviceStatusView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQADeviceStatusView.h"

#import "TSAIQABadgeLabel.h"
#import "TSAIQATheme.h"

static const CGFloat kTSAIQAStatusSide = 16.0;
static const CGFloat kTSAIQAStatusRouteCardHeight = 128.0;
static const CGFloat kTSAIQAStatusTimelineHeight = 40.0;
static const CGFloat kTSAIQAStatusHeroHeight = 236.0;
static const CGFloat kTSAIQAStatusPulseSize = 128.0;
static const CGFloat kTSAIQAStatusCoreSize = 74.0;
static NSString * const kTSAIQAStatusRingAnimationKey = @"TSAIQAStatusRing";

@interface TSAIQADeviceStatusView ()

// 路由卡
@property (nonatomic, strong) UIView *routeCard;
@property (nonatomic, strong) UILabel *routeTitleLabel;
@property (nonatomic, strong) TSAIQABadgeLabel *routeBadge;
@property (nonatomic, strong) UIButton *inputRouteButton;
@property (nonatomic, strong) UIButton *outputRouteButton;
@property (nonatomic, strong) UILabel *routeHintLabel;

// 时间线
@property (nonatomic, strong) UIView *timelineView;
@property (nonatomic, strong) NSArray<UIView *> *timelineDots;
@property (nonatomic, strong) NSArray<UIView *> *timelineLines;
@property (nonatomic, strong) NSArray<UILabel *> *timelineLabels;

// 主视觉区
@property (nonatomic, strong) UIView *heroView;
@property (nonatomic, strong) UIView *pulseView;
@property (nonatomic, strong) NSArray<CAShapeLayer *> *ringLayers;
@property (nonatomic, strong) UIView *coreView;
@property (nonatomic, strong) UILabel *coreGlyphLabel;
@property (nonatomic, strong) UILabel *heroTitleLabel;
@property (nonatomic, strong) UILabel *heroSubtitleLabel;
@property (nonatomic, strong) UILabel *sessionLabel;

@end

@implementation TSAIQADeviceStatusView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _inputRouteTitle = @"自动";
        _outputRouteTitle = @"自动";
        _heroMode = TSAIQADeviceHeroModeIdle;
        [self setupViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat contentWidth = width - kTSAIQAStatusSide * 2;
    CGFloat y = 12.0;

    // 路由卡
    self.routeCard.frame = CGRectMake(kTSAIQAStatusSide, y, contentWidth, kTSAIQAStatusRouteCardHeight);
    self.routeTitleLabel.frame = CGRectMake(14.0, 12.0, 120.0, 22.0);
    CGSize badgeSize = [self.routeBadge intrinsicContentSize];
    self.routeBadge.frame = CGRectMake(contentWidth - 14.0 - badgeSize.width, 12.0, badgeSize.width, badgeSize.height);
    CGFloat buttonWidth = (contentWidth - 28.0 - 8.0) / 2.0;
    self.inputRouteButton.frame = CGRectMake(14.0, 42.0, buttonWidth, 46.0);
    self.outputRouteButton.frame = CGRectMake(14.0 + buttonWidth + 8.0, 42.0, buttonWidth, 46.0);
    [self layoutRouteButton:self.inputRouteButton];
    [self layoutRouteButton:self.outputRouteButton];
    self.routeHintLabel.frame = CGRectMake(14.0, 94.0, contentWidth - 28.0, 28.0);
    y += kTSAIQAStatusRouteCardHeight + 10.0;

    // 时间线
    self.timelineView.frame = CGRectMake(kTSAIQAStatusSide, y, contentWidth, kTSAIQAStatusTimelineHeight);
    NSUInteger count = self.timelineDots.count;
    CGFloat slot = contentWidth / count;
    for (NSUInteger index = 0; index < count; index++) {
        CGFloat centerX = slot * index + slot / 2.0;
        UIView *dot = self.timelineDots[index];
        dot.frame = CGRectMake(centerX - 6.0, 6.0, 12.0, 12.0);
        UILabel *label = self.timelineLabels[index];
        label.frame = CGRectMake(centerX - slot / 2.0, 22.0, slot, 14.0);
        if (index < self.timelineLines.count) {
            UIView *line = self.timelineLines[index];
            line.frame = CGRectMake(centerX + 6.0, 11.0, slot - 12.0, 2.0);
        }
    }
    y += kTSAIQAStatusTimelineHeight + 8.0;

    // 主视觉区
    self.heroView.frame = CGRectMake(kTSAIQAStatusSide, y, contentWidth, kTSAIQAStatusHeroHeight);
    self.pulseView.frame = CGRectMake((contentWidth - kTSAIQAStatusPulseSize) / 2.0, 14.0,
                                      kTSAIQAStatusPulseSize, kTSAIQAStatusPulseSize);
    for (CAShapeLayer *ring in self.ringLayers) {
        ring.frame = self.pulseView.bounds;
        ring.path = [UIBezierPath bezierPathWithOvalInRect:self.pulseView.bounds].CGPath;
    }
    self.coreView.frame = CGRectMake((kTSAIQAStatusPulseSize - kTSAIQAStatusCoreSize) / 2.0,
                                     (kTSAIQAStatusPulseSize - kTSAIQAStatusCoreSize) / 2.0,
                                     kTSAIQAStatusCoreSize, kTSAIQAStatusCoreSize);
    self.coreGlyphLabel.frame = self.coreView.bounds;
    CGFloat heroY = 14.0 + kTSAIQAStatusPulseSize + 12.0;
    self.heroTitleLabel.frame = CGRectMake(10.0, heroY, contentWidth - 20.0, 24.0);
    self.heroSubtitleLabel.frame = CGRectMake(24.0, heroY + 28.0, contentWidth - 48.0, 36.0);
    self.sessionLabel.frame = CGRectMake(10.0, heroY + 68.0, contentWidth - 20.0, 14.0);
}

#pragma mark - 公开方法

+ (CGFloat)heightForWidth:(CGFloat)width heroMode:(TSAIQADeviceHeroMode)heroMode {
    (void)width;
    CGFloat height = 12.0 + kTSAIQAStatusRouteCardHeight + 10.0 + kTSAIQAStatusTimelineHeight + 8.0;
    if (heroMode != TSAIQADeviceHeroModeHidden) {
        height += kTSAIQAStatusHeroHeight;
    }
    return height + 4.0;
}

/** 按当前属性重绘 */
- (void)refresh {
    [self refreshRouteCard];
    [self refreshTimeline];
    [self refreshHero];
    [self setNeedsLayout];
}

#pragma mark - 私有方法 - 构建

/** 组装视图层级 */
- (void)setupViews {
    [self addSubview:self.routeCard];
    [self.routeCard addSubview:self.routeTitleLabel];
    [self.routeCard addSubview:self.routeBadge];
    [self.routeCard addSubview:self.inputRouteButton];
    [self.routeCard addSubview:self.outputRouteButton];
    [self.routeCard addSubview:self.routeHintLabel];

    [self addSubview:self.timelineView];
    NSArray<NSString *> *titles = @[@"未启动", @"已就绪", @"提问", @"回答", @"完成"];
    NSMutableArray *dots = [NSMutableArray array];
    NSMutableArray *lines = [NSMutableArray array];
    NSMutableArray *labels = [NSMutableArray array];
    for (NSUInteger index = 0; index < titles.count; index++) {
        if (index < titles.count - 1) {
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = [UIColor colorWithRed:0xDC / 255.0 green:0xDF / 255.0 blue:0xEA / 255.0 alpha:1.0];
            [self.timelineView addSubview:line];
            [lines addObject:line];
        }
        UIView *dot = [[UIView alloc] init];
        dot.layer.cornerRadius = 6.0;
        dot.layer.borderWidth = 3.0;
        dot.layer.borderColor = TSAIQAPageBackgroundColor().CGColor;
        [self.timelineView addSubview:dot];
        [dots addObject:dot];

        UILabel *label = [[UILabel alloc] init];
        label.text = titles[index];
        label.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightSemibold];
        label.textAlignment = NSTextAlignmentCenter;
        [self.timelineView addSubview:label];
        [labels addObject:label];
    }
    self.timelineDots = dots;
    self.timelineLines = lines;
    self.timelineLabels = labels;

    [self addSubview:self.heroView];
    [self.heroView addSubview:self.pulseView];
    NSMutableArray *rings = [NSMutableArray array];
    for (NSUInteger index = 0; index < 3; index++) {
        CAShapeLayer *ring = [CAShapeLayer layer];
        ring.fillColor = [UIColor clearColor].CGColor;
        ring.strokeColor = TSAIQATintColor().CGColor;
        ring.lineWidth = 1.5;
        ring.opacity = 0;
        [self.pulseView.layer addSublayer:ring];
        [rings addObject:ring];
    }
    self.ringLayers = rings;
    [self.pulseView addSubview:self.coreView];
    [self.coreView addSubview:self.coreGlyphLabel];
    [self.heroView addSubview:self.heroTitleLabel];
    [self.heroView addSubview:self.heroSubtitleLabel];
    [self.heroView addSubview:self.sessionLabel];
}

/** 创建一个路由按钮：上小标题、下粗体值、右侧箭头 */
- (UIButton *)makeRouteButtonWithCaption:(NSString *)caption kind:(TSAIQARouteKind)kind {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = TSAIQAPageBackgroundColor();
    button.layer.cornerRadius = 12.0;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = TSAIQALineColor().CGColor;
    button.tag = kind;

    UILabel *captionLabel = [[UILabel alloc] init];
    captionLabel.tag = 11;
    captionLabel.text = caption;
    captionLabel.font = [UIFont systemFontOfSize:10.0];
    captionLabel.textColor = TSAIQATextTertiaryColor();
    [button addSubview:captionLabel];

    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.tag = 12;
    valueLabel.font = [UIFont systemFontOfSize:12.5 weight:UIFontWeightBold];
    valueLabel.textColor = TSAIQATextPrimaryColor();
    valueLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [button addSubview:valueLabel];

    UILabel *chevron = [[UILabel alloc] init];
    chevron.tag = 13;
    chevron.text = @"›";
    chevron.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold];
    chevron.textColor = TSAIQATextTertiaryColor();
    chevron.textAlignment = NSTextAlignmentCenter;
    [button addSubview:chevron];

    [button addTarget:self action:@selector(onRouteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

/** 布局路由按钮内部标签 */
- (void)layoutRouteButton:(UIButton *)button {
    CGFloat width = CGRectGetWidth(button.bounds);
    [button viewWithTag:11].frame = CGRectMake(10.0, 7.0, width - 40.0, 13.0);
    [button viewWithTag:12].frame = CGRectMake(10.0, 22.0, width - 40.0, 17.0);
    [button viewWithTag:13].frame = CGRectMake(width - 26.0, 0, 20.0, CGRectGetHeight(button.bounds));
}

#pragma mark - 私有方法 - 刷新

/** 刷新路由卡 */
- (void)refreshRouteCard {
    ((UILabel *)[self.inputRouteButton viewWithTag:12]).text = self.inputRouteTitle;
    ((UILabel *)[self.outputRouteButton viewWithTag:12]).text = self.outputRouteTitle;
    self.inputRouteButton.alpha = self.routeLocked ? 0.6 : 1.0;
    self.outputRouteButton.alpha = self.routeLocked ? 0.6 : 1.0;
    if (self.routeLocked) {
        [self.routeBadge applyText:@"会话中锁定" style:TSAIQABadgeStyleLive];
    } else {
        [self.routeBadge applyText:@"可配置" style:TSAIQABadgeStyleSuccess];
    }
    self.routeHintLabel.text = self.routeHint;
}

/** 刷新时间线 */
- (void)refreshTimeline {
    UIColor *inactive = [UIColor colorWithRed:0xDC / 255.0 green:0xDF / 255.0 blue:0xEA / 255.0 alpha:1.0];
    for (NSUInteger index = 0; index < self.timelineDots.count; index++) {
        UIView *dot = self.timelineDots[index];
        UILabel *label = self.timelineLabels[index];
        BOOL done = ((NSInteger)index < self.timelineStep);
        BOOL current = ((NSInteger)index == self.timelineStep);
        dot.layer.shadowOpacity = 0;
        if (current && self.timelineFailed) {
            dot.backgroundColor = TSAIQADangerColor();
            label.textColor = TSAIQADangerColor();
        } else if (current) {
            dot.backgroundColor = TSAIQATintColor();
            dot.layer.shadowColor = TSAIQATintColor().CGColor;
            dot.layer.shadowOpacity = 0.35;
            dot.layer.shadowRadius = 4.0;
            dot.layer.shadowOffset = CGSizeZero;
            label.textColor = TSAIQADeepTintColor();
        } else if (done) {
            dot.backgroundColor = TSAIQATintColor();
            label.textColor = TSAIQATextTertiaryColor();
        } else {
            dot.backgroundColor = inactive;
            label.textColor = TSAIQATextTertiaryColor();
        }
        if (index < self.timelineLines.count) {
            self.timelineLines[index].backgroundColor = done ? TSAIQATintColor() : inactive;
        }
    }
}

/** 刷新主视觉区 */
- (void)refreshHero {
    self.heroView.hidden = (self.heroMode == TSAIQADeviceHeroModeHidden);
    self.heroTitleLabel.text = self.heroTitle;
    self.heroSubtitleLabel.text = self.heroSubtitle;
    self.sessionLabel.text = self.sessionIdentifier.length > 0
        ? [NSString stringWithFormat:@"session %@", self.sessionIdentifier]
        : @"";
    BOOL listening = (self.heroMode == TSAIQADeviceHeroModeListening);
    self.coreView.backgroundColor = listening
        ? TSAIQATintColor()
        : [UIColor colorWithRed:0xDC / 255.0 green:0xDF / 255.0 blue:0xEA / 255.0 alpha:1.0];
    self.coreView.layer.shadowOpacity = listening ? 0.28 : 0;
    [self updateRingAnimationsListening:listening];
}

/** 就绪时播放脉冲环动画 */
- (void)updateRingAnimationsListening:(BOOL)listening {
    [self.ringLayers enumerateObjectsUsingBlock:^(CAShapeLayer *ring, NSUInteger index, BOOL *stop) {
        [ring removeAnimationForKey:kTSAIQAStatusRingAnimationKey];
        ring.opacity = 0;
        if (!listening) {
            return;
        }
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.fromValue = @0.55;
        scale.toValue = @1.15;
        CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fade.fromValue = @0.5;
        fade.toValue = @0.0;
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[scale, fade];
        group.duration = 2.4;
        group.beginTime = CACurrentMediaTime() + index * 0.8;
        group.repeatCount = HUGE_VALF;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [ring addAnimation:group forKey:kTSAIQAStatusRingAnimationKey];
    }];
}

#pragma mark - 事件

/** 点击路由按钮 */
- (void)onRouteButtonTapped:(UIButton *)sender {
    [self.delegate deviceStatusView:self didTapRoute:(TSAIQARouteKind)sender.tag];
}

#pragma mark - 属性（懒加载）

- (UIView *)routeCard {
    if (!_routeCard) {
        _routeCard = [[UIView alloc] init];
        _routeCard.backgroundColor = [UIColor whiteColor];
        _routeCard.layer.cornerRadius = 18.0;
        _routeCard.layer.borderWidth = 1.0;
        _routeCard.layer.borderColor = TSAIQALineColor().CGColor;
        TSAIQAApplyCardShadow(_routeCard.layer);
    }
    return _routeCard;
}

- (UILabel *)routeTitleLabel {
    if (!_routeTitleLabel) {
        _routeTitleLabel = [[UILabel alloc] init];
        _routeTitleLabel.text = @"音频路由";
        _routeTitleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightBold];
        _routeTitleLabel.textColor = TSAIQATextPrimaryColor();
    }
    return _routeTitleLabel;
}

- (TSAIQABadgeLabel *)routeBadge {
    if (!_routeBadge) {
        _routeBadge = [[TSAIQABadgeLabel alloc] init];
    }
    return _routeBadge;
}

- (UIButton *)inputRouteButton {
    if (!_inputRouteButton) {
        _inputRouteButton = [self makeRouteButtonWithCaption:@"拾音 · input" kind:TSAIQARouteKindInput];
    }
    return _inputRouteButton;
}

- (UIButton *)outputRouteButton {
    if (!_outputRouteButton) {
        _outputRouteButton = [self makeRouteButtonWithCaption:@"内容播放 · output" kind:TSAIQARouteKindOutput];
    }
    return _outputRouteButton;
}

- (UILabel *)routeHintLabel {
    if (!_routeHintLabel) {
        _routeHintLabel = [[UILabel alloc] init];
        _routeHintLabel.font = [UIFont systemFontOfSize:10.5];
        _routeHintLabel.textColor = TSAIQATextTertiaryColor();
        _routeHintLabel.numberOfLines = 2;
    }
    return _routeHintLabel;
}

- (UIView *)timelineView {
    if (!_timelineView) {
        _timelineView = [[UIView alloc] init];
    }
    return _timelineView;
}

- (UIView *)heroView {
    if (!_heroView) {
        _heroView = [[UIView alloc] init];
    }
    return _heroView;
}

- (UIView *)pulseView {
    if (!_pulseView) {
        _pulseView = [[UIView alloc] init];
    }
    return _pulseView;
}

- (UIView *)coreView {
    if (!_coreView) {
        _coreView = [[UIView alloc] init];
        _coreView.layer.cornerRadius = kTSAIQAStatusCoreSize / 2.0;
        _coreView.layer.shadowColor = TSAIQATintColor().CGColor;
        _coreView.layer.shadowRadius = 15.0;
        _coreView.layer.shadowOffset = CGSizeMake(0, 14.0);
    }
    return _coreView;
}

- (UILabel *)coreGlyphLabel {
    if (!_coreGlyphLabel) {
        _coreGlyphLabel = [[UILabel alloc] init];
        _coreGlyphLabel.text = @"⌾";
        _coreGlyphLabel.font = [UIFont systemFontOfSize:34.0 weight:UIFontWeightMedium];
        _coreGlyphLabel.textColor = [UIColor whiteColor];
        _coreGlyphLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _coreGlyphLabel;
}

- (UILabel *)heroTitleLabel {
    if (!_heroTitleLabel) {
        _heroTitleLabel = [[UILabel alloc] init];
        _heroTitleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
        _heroTitleLabel.textColor = TSAIQATextPrimaryColor();
        _heroTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _heroTitleLabel;
}

- (UILabel *)heroSubtitleLabel {
    if (!_heroSubtitleLabel) {
        _heroSubtitleLabel = [[UILabel alloc] init];
        _heroSubtitleLabel.font = [UIFont systemFontOfSize:12.5];
        _heroSubtitleLabel.textColor = TSAIQATextSecondaryColor();
        _heroSubtitleLabel.textAlignment = NSTextAlignmentCenter;
        _heroSubtitleLabel.numberOfLines = 2;
    }
    return _heroSubtitleLabel;
}

- (UILabel *)sessionLabel {
    if (!_sessionLabel) {
        _sessionLabel = [[UILabel alloc] init];
        _sessionLabel.font = TSAIQAMonoFont(10.5);
        _sessionLabel.textColor = TSAIQATextTertiaryColor();
        _sessionLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _sessionLabel;
}

@end
