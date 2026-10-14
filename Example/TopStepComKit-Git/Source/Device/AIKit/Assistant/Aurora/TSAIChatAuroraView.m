//
//  TSAIChatAuroraView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatAuroraView.h"

static const CGFloat kTSAIChatAuroraBlobSize = 320.0;

@interface TSAIChatAuroraView ()

// 三团柔光（径向渐变）
@property (nonatomic, strong) NSArray<CAGradientLayer *> *blobLayers;
// 上次布局的尺寸，用于避免重复重排
@property (nonatomic, assign) CGSize laidOutSize;

@end

@implementation TSAIChatAuroraView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.clipsToBounds = YES;
        self.backgroundColor = TSAIChatPaperColor();
        NSMutableArray *layers = [NSMutableArray array];
        for (NSInteger index = 0; index < 3; index++) {
            CAGradientLayer *blob = [CAGradientLayer layer];
            blob.type = kCAGradientLayerRadial;
            blob.startPoint = CGPointMake(0.5, 0.5);
            blob.endPoint = CGPointMake(1, 1);
            blob.locations = @[@0, @0.45, @1];
            blob.opacity = 0.9;
            blob.bounds = CGRectMake(0, 0, kTSAIChatAuroraBlobSize, kTSAIChatAuroraBlobSize);
            blob.cornerRadius = kTSAIChatAuroraBlobSize / 2;
            [self.layer addSublayer:blob];
            [layers addObject:blob];
        }
        _blobLayers = layers;
        _tone = TSAIChatToneIdle;
        [self applyColorsAnimated:NO];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGSizeEqualToSize(self.laidOutSize, self.bounds.size)) return;
    self.laidOutSize = self.bounds.size;
    [self layoutBlobs];
    [self restartDrift];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        [self restartDrift];
    }
}

#pragma mark - 公开方法

- (void)setTone:(TSAIChatTone)tone {
    [self setTone:tone animated:YES];
}

- (void)setTone:(TSAIChatTone)tone animated:(BOOL)animated {
    if (_tone == tone) return;
    _tone = tone;
    [self applyColorsAnimated:animated];
}

#pragma mark - 私有方法

/// 三团柔光初始位置：(-80,-60) / (200,right-140) / (bottom-60,20)
- (void)layoutBlobs {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat half = kTSAIChatAuroraBlobSize / 2;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.blobLayers[0].position = CGPointMake(-60 + half, -80 + half);
    self.blobLayers[1].position = CGPointMake(width + 140 - half, 200 + half);
    self.blobLayers[2].position = CGPointMake(20 + half, height + 60 - half);
    [CATransaction commit];
}

/// 漂移动画：0% → 50% 位移 → 100% 回原位，ease-in-out 无限
- (void)restartDrift {
    CGVector offsets[3] = { {60, 90}, {-90, -60}, {70, -80} };
    NSTimeInterval durations[3] = { 18, 22, 20 };
    for (NSInteger index = 0; index < 3; index++) {
        CAGradientLayer *blob = self.blobLayers[index];
        [blob removeAnimationForKey:@"tsai.drift"];
        if (TSAIChatReduceMotion()) continue;
        CAKeyframeAnimation *drift = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation"];
        drift.values = @[[NSValue valueWithCGSize:CGSizeZero],
                         [NSValue valueWithCGSize:CGSizeMake(offsets[index].dx, offsets[index].dy)],
                         [NSValue valueWithCGSize:CGSizeZero]];
        drift.keyTimes = @[@0, @0.5, @1];
        drift.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        drift.duration = durations[index];
        drift.repeatCount = HUGE_VALF;
        [blob addAnimation:drift forKey:@"tsai.drift"];
    }
}

/// 按气色取三团颜色并 1.2s 渐变
- (void)applyColorsAnimated:(BOOL)animated {
    NSArray<UIColor *> *colors = [self colorsForTone:self.tone];
    [CATransaction begin];
    [CATransaction setAnimationDuration:animated && !TSAIChatReduceMotion() ? 1.2 : 0];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    for (NSInteger index = 0; index < 3; index++) {
        UIColor *color = colors[index];
        CAGradientLayer *blob = self.blobLayers[index];
        NSArray *newColors = @[(id)color.CGColor,
                               (id)[color colorWithAlphaComponent:0.55].CGColor,
                               (id)[color colorWithAlphaComponent:0].CGColor];
        if (animated && !TSAIChatReduceMotion()) {
            CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"colors"];
            fade.fromValue = blob.presentationLayer.colors ?: blob.colors;
            fade.toValue = newColors;
            fade.duration = 1.2;
            fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [blob addAnimation:fade forKey:@"tsai.colors"];
        }
        blob.colors = newColors;
    }
    [CATransaction commit];
}

/// 气色配色表（规范 §2.1）
- (NSArray<UIColor *> *)colorsForTone:(TSAIChatTone)tone {
    switch (tone) {
        case TSAIChatToneRecording:
            return @[TSAIChatHexColor(0xA9C8FF), TSAIChatHexColor(0x9FE1FF), TSAIChatHexColor(0xD5CCFF)];
        case TSAIChatToneThinking:
            return @[TSAIChatHexColor(0xFFD9A8), TSAIChatHexColor(0xFFE9C2), TSAIChatHexColor(0xE2D5FF)];
        case TSAIChatToneSpeaking:
            return @[TSAIChatHexColor(0xB7F0DF), TSAIChatHexColor(0xBFE9FF), TSAIChatHexColor(0xDDD3FF)];
        case TSAIChatToneError:
            return @[TSAIChatHexColor(0xFFC1CF), TSAIChatHexColor(0xFFD9E2), TSAIChatHexColor(0xE9DDFF)];
        case TSAIChatToneIdle:
        default:
            return @[TSAIChatHexColor(0xC9B8FF), TSAIChatHexColor(0xB6E3FF), TSAIChatHexColor(0xC6F4E6)];
    }
}

@end
