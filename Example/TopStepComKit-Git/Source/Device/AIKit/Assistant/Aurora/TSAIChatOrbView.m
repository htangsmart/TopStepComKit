//
//  TSAIChatOrbView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatOrbView.h"

#import <CoreImage/CoreImage.h>

#import "TSAIChatTheme.h"

static NSString * const kTSAIChatOrbMorphKey = @"tsai.orb.morph";
static NSString * const kTSAIChatOrbBobKey = @"tsai.orb.bob";

@interface TSAIChatOrbView ()

// 直径
@property (nonatomic, assign) CGFloat diameter;
// 是否迷你版
@property (nonatomic, assign) BOOL mini;
// 辉光层（外扩 20，模糊后的圆锥渐变图，9s 旋转）
@property (nonatomic, strong, nullable) CALayer *glowLayer;
// 球体容器（承载外阴影）
@property (nonatomic, strong) CALayer *bodyLayer;
// 球体裁剪层（mask 形变）
@property (nonatomic, strong) CALayer *clipLayer;
// 形变 mask
@property (nonatomic, strong) CAShapeLayer *morphMask;
// 圆锥渐变层（before，6s 旋转）
@property (nonatomic, strong) CAGradientLayer *conicLayer;
// 高光层（after）
@property (nonatomic, strong, nullable) CAGradientLayer *highlightLayer;
// 内阴影近似层
@property (nonatomic, strong, nullable) CAGradientLayer *innerShadowLayer;
// 去色遮罩（ended）
@property (nonatomic, strong, nullable) CALayer *desaturateLayer;

@end

@implementation TSAIChatOrbView

#pragma mark - 生命周期

- (instancetype)initWithDiameter:(CGFloat)diameter {
    self = [super initWithFrame:CGRectMake(0, 0, diameter, diameter)];
    if (self) {
        _diameter = diameter;
        _mini = diameter <= 24;
        _state = TSAIChatOrbStateIdle;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        if (_mini) {
            [self buildMini];
        } else {
            [self buildFull];
        }
        [self restartAnimations];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithDiameter:CGRectGetWidth(frame) > 0 ? CGRectGetWidth(frame) : 150];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.diameter, self.diameter);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self intrinsicContentSize];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        [self restartAnimations];
    }
}

#pragma mark - 公开方法

- (void)setState:(TSAIChatOrbState)state {
    [self setState:state animated:YES];
}

- (void)setState:(TSAIChatOrbState)state animated:(BOOL)animated {
    _state = state;
    if (self.mini) return;
    [self restartAnimations];
    CGFloat scale = 1;
    CGFloat alpha = 1;
    switch (state) {
        case TSAIChatOrbStateConnecting: scale = 0.7; alpha = 0.6; break;
        case TSAIChatOrbStateHearing:    scale = 1.18; break;
        case TSAIChatOrbStateThinking:   scale = 0.82; break;
        case TSAIChatOrbStateEnded:      scale = 0.7; alpha = 0.5; break;
        default: break;
    }
    self.desaturateLayer.opacity = state == TSAIChatOrbStateEnded ? 0.8 : 0;
    void (^apply)(void) = ^{
        self.transform = CGAffineTransformMakeScale(scale, scale);
        self.alpha = alpha;
    };
    if (!animated || TSAIChatReduceMotion()) {
        apply();
        return;
    }
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.62
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:apply
                     completion:nil];
}

- (void)restartAnimations {
    if (self.mini) {
        TSAIChatAddSpin(self.conicLayer, 5);
        return;
    }
    NSTimeInterval morphDuration = 7;
    NSTimeInterval spinDuration = 6;
    BOOL bob = NO;
    switch (self.state) {
        case TSAIChatOrbStateHearing:  morphDuration = 1.4; break;
        case TSAIChatOrbStateThinking: spinDuration = 1.2; break;
        case TSAIChatOrbStateSpeaking: morphDuration = 2.2; bob = YES; break;
        default: break;
    }
    if (self.glowLayer) {
        TSAIChatAddSpin(self.glowLayer, 9);
    }
    TSAIChatAddSpin(self.conicLayer, spinDuration);
    [self addMorphWithDuration:morphDuration];
    [self.bodyLayer removeAnimationForKey:kTSAIChatOrbBobKey];
    if (bob && !TSAIChatReduceMotion()) {
        CABasicAnimation *bobAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        bobAnimation.fromValue = @1;
        bobAnimation.toValue = @1.08;
        bobAnimation.duration = 0.5;
        bobAnimation.autoreverses = YES;
        bobAnimation.repeatCount = HUGE_VALF;
        bobAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.bodyLayer addAnimation:bobAnimation forKey:kTSAIChatOrbBobKey];
    }
}

#pragma mark - 私有方法 - 构建

/// 迷你版：圆锥渐变 + 圆形裁剪
- (void)buildMini {
    CGFloat size = self.diameter;
    self.clipLayer = [CALayer layer];
    self.clipLayer.frame = CGRectMake(0, 0, size, size);
    self.clipLayer.cornerRadius = size / 2;
    self.clipLayer.masksToBounds = YES;
    [self.layer addSublayer:self.clipLayer];

    self.conicLayer = TSAIChatOrbConicGradientLayer();
    self.conicLayer.frame = CGRectMake(-size * 0.2, -size * 0.2, size * 1.4, size * 1.4);
    [self.clipLayer addSublayer:self.conicLayer];
}

/// 150 版：glow / body(阴影) / clip(mask 形变) / conic / 内阴影 / 高光
- (void)buildFull {
    CGFloat size = self.diameter;
    CGFloat glowSize = size + 40;
    CGFloat orbSize = size - 20;
    CGFloat orbInset = 10;

    // glow：模糊后的圆锥渐变图
    self.glowLayer = [CALayer layer];
    self.glowLayer.frame = CGRectMake(-20, -20, glowSize, glowSize);
    self.glowLayer.contents = (id)[self blurredGlowImageWithSize:glowSize].CGImage;
    self.glowLayer.opacity = 0.55;
    [self.layer addSublayer:self.glowLayer];

    // body：承载外阴影 (0,16) blur40 violet α.20
    self.bodyLayer = [CALayer layer];
    self.bodyLayer.frame = CGRectMake(orbInset, orbInset, orbSize, orbSize);
    self.bodyLayer.shadowColor = TSAIChatVioletColor().CGColor;
    self.bodyLayer.shadowOpacity = 0.20;
    self.bodyLayer.shadowOffset = CGSizeMake(0, 16);
    self.bodyLayer.shadowRadius = 20;
    self.bodyLayer.shadowPath = [self morphPathAtIndex:0 size:orbSize].CGPath;
    [self.layer addSublayer:self.bodyLayer];

    // clip：mask 形变
    self.clipLayer = [CALayer layer];
    self.clipLayer.frame = self.bodyLayer.bounds;
    self.morphMask = [CAShapeLayer layer];
    self.morphMask.frame = self.clipLayer.bounds;
    self.morphMask.path = [self morphPathAtIndex:0 size:orbSize].CGPath;
    self.clipLayer.mask = self.morphMask;
    [self.bodyLayer addSublayer:self.clipLayer];

    // before：圆锥渐变，超出 40%
    self.conicLayer = TSAIChatOrbConicGradientLayer();
    self.conicLayer.frame = CGRectMake(-orbSize * 0.2, -orbSize * 0.2, orbSize * 1.4, orbSize * 1.4);
    [self.clipLayer addSublayer:self.conicLayer];

    // 内阴影近似：底部白 α.38 向上淡出
    self.innerShadowLayer = [CAGradientLayer layer];
    self.innerShadowLayer.frame = self.clipLayer.bounds;
    self.innerShadowLayer.colors = @[(id)[UIColor colorWithWhite:1 alpha:0].CGColor,
                                     (id)[UIColor colorWithWhite:1 alpha:0.38].CGColor];
    self.innerShadowLayer.locations = @[@0.62, @1];
    self.innerShadowLayer.startPoint = CGPointMake(0.5, 0);
    self.innerShadowLayer.endPoint = CGPointMake(0.5, 1);
    [self.clipLayer addSublayer:self.innerShadowLayer];

    // after：径向高光，中心 (35%,30%) 白 α.69 → 55% 处透明
    self.highlightLayer = [CAGradientLayer layer];
    self.highlightLayer.type = kCAGradientLayerRadial;
    self.highlightLayer.frame = self.clipLayer.bounds;
    self.highlightLayer.colors = @[(id)[UIColor colorWithWhite:1 alpha:0.69].CGColor,
                                   (id)[UIColor colorWithWhite:1 alpha:0].CGColor];
    self.highlightLayer.locations = @[@0, @0.55];
    self.highlightLayer.startPoint = CGPointMake(0.35, 0.30);
    self.highlightLayer.endPoint = CGPointMake(0.35 + 1.0, 0.30 + 1.0);
    [self.clipLayer addSublayer:self.highlightLayer];

    // ended 去色遮罩
    self.desaturateLayer = [CALayer layer];
    self.desaturateLayer.frame = self.clipLayer.bounds;
    self.desaturateLayer.backgroundColor = TSAIChatHexColor(0xB9B7C9).CGColor;
    self.desaturateLayer.opacity = 0;
    [self.clipLayer addSublayer:self.desaturateLayer];
}

/// 预渲染辉光：圆锥渐变 → CIGaussianBlur(28)
- (UIImage *)blurredGlowImageWithSize:(CGFloat)size {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.type = kCAGradientLayerConic;
    gradient.colors = @[(id)TSAIChatVioletColor().CGColor,
                        (id)TSAIChatSkyColor().CGColor,
                        (id)TSAIChatMintColor().CGColor,
                        (id)TSAIChatPeachColor().CGColor,
                        (id)TSAIChatVioletColor().CGColor];
    gradient.startPoint = CGPointMake(0.5, 0.5);
    gradient.endPoint = CGPointMake(1, 0.5);
    CGFloat inset = 28;
    gradient.frame = CGRectMake(inset, inset, size - inset * 2, size - inset * 2);
    gradient.cornerRadius = (size - inset * 2) / 2;
    gradient.masksToBounds = YES;

    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(size, size)];
    UIImage *sharp = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGContextTranslateCTM(context.CGContext, inset, inset);
        [gradient renderInContext:context.CGContext];
    }];
    CIImage *input = [CIImage imageWithCGImage:sharp.CGImage];
    CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blur setValue:input forKey:kCIInputImageKey];
    [blur setValue:@(inset * 0.5 * sharp.scale) forKey:kCIInputRadiusKey];
    CIImage *output = [blur.outputImage imageByCroppingToRect:input.extent];
    if (!output) return sharp;
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:output fromRect:input.extent];
    if (!cgImage) return sharp;
    UIImage *result = [UIImage imageWithCGImage:cgImage scale:sharp.scale orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return result;
}

#pragma mark - 私有方法 - 形变

/// 形变动画：三组圆角路径往返插值
- (void)addMorphWithDuration:(NSTimeInterval)duration {
    [self.morphMask removeAnimationForKey:kTSAIChatOrbMorphKey];
    if (TSAIChatReduceMotion()) return;
    CGFloat size = CGRectGetWidth(self.morphMask.bounds);
    CAKeyframeAnimation *morph = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    morph.values = @[(id)[self morphPathAtIndex:0 size:size].CGPath,
                     (id)[self morphPathAtIndex:1 size:size].CGPath,
                     (id)[self morphPathAtIndex:2 size:size].CGPath,
                     (id)[self morphPathAtIndex:0 size:size].CGPath];
    morph.keyTimes = @[@0, @0.33, @0.66, @1];
    CAMediaTimingFunction *ease = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    morph.timingFunctions = @[ease, ease, ease];
    morph.duration = duration;
    morph.repeatCount = HUGE_VALF;
    [self.morphMask addAnimation:morph forKey:kTSAIChatOrbMorphKey];
}

/// 三组 border-radius 关键帧（水平 TL TR BR BL / 垂直 TL TR BR BL，百分比）
- (UIBezierPath *)morphPathAtIndex:(NSInteger)index size:(CGFloat)size {
    static const CGFloat frames[3][8] = {
        {58, 42, 46, 54, 52, 48, 52, 48},
        {44, 56, 58, 42, 46, 60, 40, 54},
        {52, 48, 40, 60, 58, 42, 58, 42},
    };
    const CGFloat *radius = frames[MAX(0, MIN(2, index))];
    CGFloat w = size, h = size;
    CGFloat tlx = w * radius[0] / 100, trx = w * radius[1] / 100, brx = w * radius[2] / 100, blx = w * radius[3] / 100;
    CGFloat tly = h * radius[4] / 100, try_ = h * radius[5] / 100, bry = h * radius[6] / 100, bly = h * radius[7] / 100;
    const CGFloat k = 0.5522847498;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(tlx, 0)];
    [path addLineToPoint:CGPointMake(w - trx, 0)];
    [path addCurveToPoint:CGPointMake(w, try_)
            controlPoint1:CGPointMake(w - trx + trx * k, 0)
            controlPoint2:CGPointMake(w, try_ - try_ * k)];
    [path addLineToPoint:CGPointMake(w, h - bry)];
    [path addCurveToPoint:CGPointMake(w - brx, h)
            controlPoint1:CGPointMake(w, h - bry + bry * k)
            controlPoint2:CGPointMake(w - brx + brx * k, h)];
    [path addLineToPoint:CGPointMake(blx, h)];
    [path addCurveToPoint:CGPointMake(0, h - bly)
            controlPoint1:CGPointMake(blx - blx * k, h)
            controlPoint2:CGPointMake(0, h - bly + bly * k)];
    [path addLineToPoint:CGPointMake(0, tly)];
    [path addCurveToPoint:CGPointMake(tlx, 0)
            controlPoint1:CGPointMake(0, tly - tly * k)
            controlPoint2:CGPointMake(tlx - tlx * k, 0)];
    [path closePath];
    return path;
}

@end
