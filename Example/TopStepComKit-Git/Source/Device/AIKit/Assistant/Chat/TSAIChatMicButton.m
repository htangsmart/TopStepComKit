//
//  TSAIChatMicButton.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatMicButton.h"
#import "TSRootVC.h"

static NSString *const kRippleAnimKey = @"ts.ripple";
static NSString *const kThinkingAnimKey = @"ts.thinking";

@interface TSAIChatMicButton ()

// 主图标（🎤 表情）
@property (nonatomic, strong) UILabel *iconLabel;
// Listening 态的两个波纹层
@property (nonatomic, strong) CAShapeLayer *rippleLayerOuter;
@property (nonatomic, strong) CAShapeLayer *rippleLayerInner;
// Thinking 态的三点容器
@property (nonatomic, strong) UIView *thinkingDotsView;
@property (nonatomic, strong) NSArray<UIView *> *thinkingDots;
// Speaking 态的波形条容器
@property (nonatomic, strong) UIView *waveBarsView;
@property (nonatomic, strong) NSArray<UIView *> *waveBars;

@end

@implementation TSAIChatMicButton

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        [self addTarget:self
                 action:@selector(onSelfTapped)
       forControlEvents:UIControlEventTouchUpInside];
        self.micState = TSAIChatMicButtonStateIdle;
    }
    return self;
}

#pragma mark - 公开方法

- (void)setMicState:(TSAIChatMicButtonState)micState {
    _micState = micState;
    [self refreshAppearanceForState:micState];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat side = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.layer.cornerRadius = side / 2.f;

    self.iconLabel.frame = self.bounds;

    // ripple 层使用与按钮同尺寸的圆形 path
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    self.rippleLayerOuter.path = circlePath.CGPath;
    self.rippleLayerInner.path = circlePath.CGPath;
    self.rippleLayerOuter.frame = self.bounds;
    self.rippleLayerInner.frame = self.bounds;

    [self layoutThinkingDots];
    [self layoutWaveBars];
}

#pragma mark - 私有方法

/// 初始化所有子视图，按状态显示/隐藏
- (void)setupSubviews {
    self.layer.masksToBounds = NO;

    self.rippleLayerOuter = [self makeRippleLayer];
    self.rippleLayerInner = [self makeRippleLayer];
    [self.layer addSublayer:self.rippleLayerOuter];
    [self.layer addSublayer:self.rippleLayerInner];

    [self addSubview:self.iconLabel];
    [self addSubview:self.thinkingDotsView];
    [self addSubview:self.waveBarsView];
}

/// 构造一层波纹 CAShapeLayer（白色细描边）
- (CAShapeLayer *)makeRippleLayer {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7f].CGColor;
    layer.lineWidth = 2.f;
    layer.opacity = 0.f;
    return layer;
}

/// 布局 Thinking 三点
- (void)layoutThinkingDots {
    if (self.thinkingDots.count == 0) return;
    CGFloat dotSize = 8.f;
    CGFloat gap = 6.f;
    CGFloat totalW = dotSize * self.thinkingDots.count + gap * (self.thinkingDots.count - 1);
    self.thinkingDotsView.frame = CGRectMake((CGRectGetWidth(self.bounds) - totalW) / 2.f,
                                              (CGRectGetHeight(self.bounds) - dotSize) / 2.f,
                                              totalW, dotSize);
    CGFloat x = 0;
    for (UIView *dot in self.thinkingDots) {
        dot.frame = CGRectMake(x, 0, dotSize, dotSize);
        dot.layer.cornerRadius = dotSize / 2.f;
        x += dotSize + gap;
    }
}

/// 布局 Speaking 波形条
- (void)layoutWaveBars {
    if (self.waveBars.count == 0) return;
    CGFloat barWidth = 4.f;
    CGFloat gap = 4.f;
    CGFloat totalW = barWidth * self.waveBars.count + gap * (self.waveBars.count - 1);
    CGFloat containerH = 36.f;
    self.waveBarsView.frame = CGRectMake((CGRectGetWidth(self.bounds) - totalW) / 2.f,
                                          (CGRectGetHeight(self.bounds) - containerH) / 2.f,
                                          totalW, containerH);
    CGFloat x = 0;
    CGFloat presetH[5] = {14.f, 24.f, 32.f, 22.f, 16.f};
    for (NSUInteger i = 0; i < self.waveBars.count; i++) {
        UIView *bar = self.waveBars[i];
        CGFloat h = presetH[i % 5];
        bar.frame = CGRectMake(x, (containerH - h) / 2.f, barWidth, h);
        bar.layer.cornerRadius = barWidth / 2.f;
        x += barWidth + gap;
    }
}

/// 根据状态更新背景色、图标、动画
- (void)refreshAppearanceForState:(TSAIChatMicButtonState)state {
    // 先全部停止 / 清理动画与子视图显隐
    [self stopRippleAnimation];
    [self stopThinkingAnimation];
    [self stopWaveAnimation];
    self.thinkingDotsView.hidden = YES;
    self.waveBarsView.hidden = YES;
    self.iconLabel.hidden = NO;

    switch (state) {
        case TSAIChatMicButtonStateIdle:
            self.backgroundColor = [UIColor colorWithRed:148/255.f green:163/255.f blue:184/255.f alpha:1.f]; // slate-400
            self.iconLabel.text = @"🎤";
            break;
        case TSAIChatMicButtonStateListening:
            self.backgroundColor = TSColor_Primary;
            self.iconLabel.text = @"🎤";
            [self startRippleAnimation];
            break;
        case TSAIChatMicButtonStateThinking:
            self.backgroundColor = TSColor_Purple;
            self.iconLabel.hidden = YES;
            self.thinkingDotsView.hidden = NO;
            [self startThinkingAnimation];
            break;
        case TSAIChatMicButtonStateSpeaking:
            self.backgroundColor = TSColor_Success;
            self.iconLabel.hidden = YES;
            self.waveBarsView.hidden = NO;
            [self startWaveAnimation];
            break;
    }
}

#pragma mark - 动画：波纹

- (void)startRippleAnimation {
    [self runRippleOnLayer:self.rippleLayerOuter beginTime:0];
    [self runRippleOnLayer:self.rippleLayerInner beginTime:0.8];
}

- (void)runRippleOnLayer:(CAShapeLayer *)layer beginTime:(CFTimeInterval)offset {
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @(1.0);
    scale.toValue = @(1.6);

    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue = @(1.0);
    opacity.toValue = @(0.0);

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[scale, opacity];
    group.duration = 1.6;
    group.beginTime = CACurrentMediaTime() + offset;
    group.repeatCount = HUGE_VALF;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [layer addAnimation:group forKey:kRippleAnimKey];
}

- (void)stopRippleAnimation {
    [self.rippleLayerOuter removeAnimationForKey:kRippleAnimKey];
    [self.rippleLayerInner removeAnimationForKey:kRippleAnimKey];
    self.rippleLayerOuter.opacity = 0.f;
    self.rippleLayerInner.opacity = 0.f;
}

#pragma mark - 动画：思考三点

- (void)startThinkingAnimation {
    for (NSUInteger i = 0; i < self.thinkingDots.count; i++) {
        UIView *dot = self.thinkingDots[i];
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        anim.fromValue = @(0.6);
        anim.toValue = @(1.3);
        anim.duration = 0.6;
        anim.beginTime = CACurrentMediaTime() + i * 0.2;
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VALF;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [dot.layer addAnimation:anim forKey:kThinkingAnimKey];
    }
}

- (void)stopThinkingAnimation {
    for (UIView *dot in self.thinkingDots) {
        [dot.layer removeAnimationForKey:kThinkingAnimKey];
    }
}

#pragma mark - 动画：波形条

- (void)startWaveAnimation {
    for (NSUInteger i = 0; i < self.waveBars.count; i++) {
        UIView *bar = self.waveBars[i];
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
        anim.fromValue = @(0.4);
        anim.toValue = @(1.4);
        anim.duration = 0.5 + (i % 3) * 0.1;
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VALF;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [bar.layer addAnimation:anim forKey:@"ts.wave"];
    }
}

- (void)stopWaveAnimation {
    for (UIView *bar in self.waveBars) {
        [bar.layer removeAnimationForKey:@"ts.wave"];
    }
}

#pragma mark - 事件

- (void)onSelfTapped {
    if (self.onTap) self.onTap();
}

#pragma mark - 属性（懒加载）

- (UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [[UILabel alloc] init];
        _iconLabel.font = [UIFont systemFontOfSize:36.f];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.userInteractionEnabled = NO;
    }
    return _iconLabel;
}

- (UIView *)thinkingDotsView {
    if (!_thinkingDotsView) {
        _thinkingDotsView = [[UIView alloc] init];
        _thinkingDotsView.userInteractionEnabled = NO;
        NSMutableArray *dots = [NSMutableArray array];
        for (NSUInteger i = 0; i < 3; i++) {
            UIView *dot = [[UIView alloc] init];
            dot.backgroundColor = [UIColor whiteColor];
            [_thinkingDotsView addSubview:dot];
            [dots addObject:dot];
        }
        self.thinkingDots = [dots copy];
    }
    return _thinkingDotsView;
}

- (UIView *)waveBarsView {
    if (!_waveBarsView) {
        _waveBarsView = [[UIView alloc] init];
        _waveBarsView.userInteractionEnabled = NO;
        NSMutableArray *bars = [NSMutableArray array];
        for (NSUInteger i = 0; i < 5; i++) {
            UIView *bar = [[UIView alloc] init];
            bar.backgroundColor = [UIColor whiteColor];
            [_waveBarsView addSubview:bar];
            [bars addObject:bar];
        }
        self.waveBars = [bars copy];
    }
    return _waveBarsView;
}

@end
