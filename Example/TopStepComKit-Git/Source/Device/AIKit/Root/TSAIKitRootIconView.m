//
//  TSAIKitRootIconView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/20.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIKitRootIconView.h"

static const CGFloat kIconCanvasSize = 24.0;

@interface TSAIKitRootIconView ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) NSMutableArray<CATextLayer *> *textLayers;
@end

@implementation TSAIKitRootIconView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _textLayers = [NSMutableArray array];

        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.lineCap = kCALineCapRound;
        _shapeLayer.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:_shapeLayer];
    }
    return self;
}

- (void)setIconType:(TSAIKitRootCapabilityIcon)iconType {
    _iconType = iconType;
    [self setNeedsLayout];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self applyTint];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self redraw];
}

- (void)applyTint {
    self.shapeLayer.strokeColor = self.tintColor.CGColor;
    for (CATextLayer *textLayer in self.textLayers) {
        textLayer.foregroundColor = self.tintColor.CGColor;
    }
}

#pragma mark - 私有方法 - 绘制

- (void)redraw {
    CGFloat scale = MIN(self.bounds.size.width, self.bounds.size.height) / kIconCanvasSize;
    if (scale <= 0) return;

    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);

    UIBezierPath *path = [self pathForIconType:self.iconType];
    [path applyTransform:transform];

    self.shapeLayer.frame = self.bounds;
    self.shapeLayer.path = path.CGPath;
    self.shapeLayer.lineWidth = 1.8 * scale;

    for (CATextLayer *textLayer in self.textLayers) {
        [textLayer removeFromSuperlayer];
    }
    [self.textLayers removeAllObjects];

    if (self.iconType == TSAIKitRootCapabilityIconInterpreter) {
        [self addBilingualGlyphsWithScale:scale];
    } else if (self.iconType == TSAIKitRootCapabilityIconTranslate) {
        [self addTranslateGlyphsWithScale:scale];
    }

    [self applyTint];
}

- (UIBezierPath *)pathForIconType:(TSAIKitRootCapabilityIcon)iconType {
    UIBezierPath *path = [UIBezierPath bezierPath];
    switch (iconType) {
        case TSAIKitRootCapabilityIconSummary: {
            // 段落 + 钟表
            [path moveToPoint:CGPointMake(4, 6)];     [path addLineToPoint:CGPointMake(16, 6)];
            [path moveToPoint:CGPointMake(4, 10)];    [path addLineToPoint:CGPointMake(20, 10)];
            [path moveToPoint:CGPointMake(4, 14)];    [path addLineToPoint:CGPointMake(14, 14)];
            [path moveToPoint:CGPointMake(4, 18)];    [path addLineToPoint:CGPointMake(11, 18)];
            UIBezierPath *clock = [UIBezierPath bezierPathWithArcCenter:CGPointMake(19, 17)
                                                                radius:3.5
                                                            startAngle:0
                                                              endAngle:M_PI * 2
                                                             clockwise:YES];
            [path appendPath:clock];
            [path moveToPoint:CGPointMake(19, 15.5)];
            [path addLineToPoint:CGPointMake(19, 18.5)];
            [path addLineToPoint:CGPointMake(20.5, 19.3)];
            break;
        }
        case TSAIKitRootCapabilityIconVoiceChat: {
            // 对话气泡 + 内嵌波形
            [path moveToPoint:CGPointMake(4, 5)];
            [path addLineToPoint:CGPointMake(20, 5)];
            [path addLineToPoint:CGPointMake(20, 15)];
            [path addLineToPoint:CGPointMake(8, 15)];
            [path addLineToPoint:CGPointMake(4, 19)];
            [path addLineToPoint:CGPointMake(4, 5)];
            [path closePath];
            [path moveToPoint:CGPointMake(9, 10)];   [path addLineToPoint:CGPointMake(9, 10.01)];
            [path moveToPoint:CGPointMake(12, 8)];    [path addLineToPoint:CGPointMake(12, 12)];
            [path moveToPoint:CGPointMake(15, 9)];    [path addLineToPoint:CGPointMake(15, 11)];
            [path moveToPoint:CGPointMake(18, 10)];   [path addLineToPoint:CGPointMake(18, 10.01)];
            break;
        }
        case TSAIKitRootCapabilityIconInterpreter: {
            // 双向循环弧 + 中英角标（角标在 redraw 中追加）
            [path moveToPoint:CGPointMake(3, 8)];
            [path addCurveToPoint:CGPointMake(8, 3)
                    controlPoint1:CGPointMake(3, 5)
                    controlPoint2:CGPointMake(5, 3)];
            [path addLineToPoint:CGPointMake(10, 3)];
            [path moveToPoint:CGPointMake(7, 5)];
            [path addLineToPoint:CGPointMake(4, 8)];
            [path addLineToPoint:CGPointMake(7, 11)];
            [path moveToPoint:CGPointMake(21, 16)];
            [path addCurveToPoint:CGPointMake(16, 21)
                    controlPoint1:CGPointMake(21, 19)
                    controlPoint2:CGPointMake(19, 21)];
            [path addLineToPoint:CGPointMake(14, 21)];
            [path moveToPoint:CGPointMake(17, 19)];
            [path addLineToPoint:CGPointMake(20, 16)];
            [path addLineToPoint:CGPointMake(17, 13)];
            break;
        }
        case TSAIKitRootCapabilityIconTTS: {
            // 文字 + 喇叭
            [path moveToPoint:CGPointMake(3, 6)];   [path addLineToPoint:CGPointMake(10, 6)];
            [path moveToPoint:CGPointMake(3, 10)];  [path addLineToPoint:CGPointMake(8, 10)];
            [path moveToPoint:CGPointMake(3, 14)];  [path addLineToPoint:CGPointMake(9, 14)];
            [path moveToPoint:CGPointMake(13, 8)];
            [path addLineToPoint:CGPointMake(18, 5)];
            [path addLineToPoint:CGPointMake(18, 19)];
            [path addLineToPoint:CGPointMake(13, 16)];
            [path addLineToPoint:CGPointMake(11, 16)];
            [path addLineToPoint:CGPointMake(11, 8)];
            [path closePath];
            [path moveToPoint:CGPointMake(20, 9)];
            [path addCurveToPoint:CGPointMake(20, 15)
                    controlPoint1:CGPointMake(21.5, 10.5)
                    controlPoint2:CGPointMake(21.5, 13.5)];
            break;
        }
        case TSAIKitRootCapabilityIconASRFile: {
            // 文件 + 内嵌波形
            [path moveToPoint:CGPointMake(6, 3)];
            [path addLineToPoint:CGPointMake(14, 3)];
            [path addLineToPoint:CGPointMake(18, 7)];
            [path addLineToPoint:CGPointMake(18, 21)];
            [path addLineToPoint:CGPointMake(6, 21)];
            [path closePath];
            [path moveToPoint:CGPointMake(14, 3)];
            [path addLineToPoint:CGPointMake(14, 7)];
            [path addLineToPoint:CGPointMake(18, 7)];
            [path moveToPoint:CGPointMake(9, 14)];     [path addLineToPoint:CGPointMake(9, 16)];
            [path moveToPoint:CGPointMake(11.5, 12)];  [path addLineToPoint:CGPointMake(11.5, 18)];
            [path moveToPoint:CGPointMake(14, 13)];    [path addLineToPoint:CGPointMake(14, 17)];
            [path moveToPoint:CGPointMake(16.5, 14.5)];[path addLineToPoint:CGPointMake(16.5, 15.5)];
            break;
        }
        case TSAIKitRootCapabilityIconASRMic: {
            // 麦克风
            UIBezierPath *capsule = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(9, 3, 6, 11)
                                                              cornerRadius:3.0];
            [path appendPath:capsule];
            [path moveToPoint:CGPointMake(5, 11)];
            [path addCurveToPoint:CGPointMake(19, 11)
                    controlPoint1:CGPointMake(5, 18)
                    controlPoint2:CGPointMake(19, 18)];
            [path moveToPoint:CGPointMake(12, 18)];
            [path addLineToPoint:CGPointMake(12, 21)];
            [path moveToPoint:CGPointMake(9, 21)];
            [path addLineToPoint:CGPointMake(15, 21)];
            break;
        }
        case TSAIKitRootCapabilityIconTranslate: {
            // A ↔ 文（角标在 redraw 中追加）
            [path moveToPoint:CGPointMake(3, 5)];     [path addLineToPoint:CGPointMake(10, 5)];
            [path moveToPoint:CGPointMake(6.5, 5)];
            [path addLineToPoint:CGPointMake(6.5, 7)];
            [path addCurveToPoint:CGPointMake(3, 12)
                    controlPoint1:CGPointMake(6.5, 10)
                    controlPoint2:CGPointMake(4.5, 12)];
            [path moveToPoint:CGPointMake(3, 8)];
            [path addCurveToPoint:CGPointMake(8, 12)
                    controlPoint1:CGPointMake(3, 10)
                    controlPoint2:CGPointMake(5.5, 12)];
            [path moveToPoint:CGPointMake(10, 19)];
            [path addLineToPoint:CGPointMake(14, 10)];
            [path addLineToPoint:CGPointMake(18, 19)];
            [path moveToPoint:CGPointMake(11.5, 16)];
            [path addLineToPoint:CGPointMake(16.5, 16)];
            break;
        }
    }
    return path;
}

- (void)addBilingualGlyphsWithScale:(CGFloat)scale {
    [self addGlyph:@"A" atCanvasPoint:CGPointMake(7.5, 13) scale:scale];
    [self addGlyph:@"中" atCanvasPoint:CGPointMake(14.5, 8) scale:scale];
}

- (void)addTranslateGlyphsWithScale:(CGFloat)scale {
    // 仅给主路径补一个识别度——副字符 "文" 用文本层标在右上
    [self addGlyph:@"文" atCanvasPoint:CGPointMake(20, 7) scale:scale];
}

- (void)addGlyph:(NSString *)glyph atCanvasPoint:(CGPoint)point scale:(CGFloat)scale {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = glyph;
    textLayer.font = (__bridge CFTypeRef)[UIFont systemFontOfSize:7 weight:UIFontWeightBold];
    textLayer.fontSize = 7 * scale;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.alignmentMode = kCAAlignmentCenter;

    CGFloat side = 7 * scale;
    textLayer.frame = CGRectMake(point.x * scale - side / 2,
                                 point.y * scale - side / 2,
                                 side, side);
    [self.layer addSublayer:textLayer];
    [self.textLayers addObject:textLayer];
}

@end
