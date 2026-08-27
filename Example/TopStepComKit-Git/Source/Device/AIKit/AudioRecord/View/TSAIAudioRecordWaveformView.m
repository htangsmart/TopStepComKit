//
//  TSAIAudioRecordWaveformView.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordWaveformView.h"

static const NSUInteger kTSAIAudioRecordWaveformBarCount = 69;
static const NSUInteger kTSAIAudioRecordWaveformHistoryCount = 35;

@interface TSAIAudioRecordWaveformView ()

// 标准化音量历史
@property (nonatomic, strong) NSMutableArray<NSNumber *> *levels;
// 是否正在显示录音波形
@property (nonatomic, assign) BOOL recordingActive;

@end

@implementation TSAIAudioRecordWaveformView

#pragma mark - 生命周期

/** 初始化波形视图 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _levels = [NSMutableArray array];
        self.backgroundColor = UIColor.clearColor;
        self.opaque = NO;
        for (NSUInteger barIndex = 0; barIndex < kTSAIAudioRecordWaveformHistoryCount; barIndex++) {
            [_levels addObject:@(0.05)];
        }
    }
    return self;
}

#pragma mark - 公开方法

/** 追加标准化音量 */
- (void)appendAudioLevel:(CGFloat)level {
    CGFloat clampedLevel = MIN(1.0, MAX(0.04, level));
    [self.levels addObject:@(clampedLevel)];
    if (self.levels.count > kTSAIAudioRecordWaveformHistoryCount) {
        [self.levels removeObjectAtIndex:0];
    }
    [self setNeedsDisplay];
}

/** 清空波形 */
- (void)resetWaveform {
    [self.levels removeAllObjects];
    for (NSUInteger barIndex = 0; barIndex < kTSAIAudioRecordWaveformHistoryCount; barIndex++) {
        [self.levels addObject:@(0.05)];
    }
    [self setNeedsDisplay];
}

/** 更新录音波形活跃状态 */
- (void)setRecordingActive:(BOOL)recordingActive {
    _recordingActive = recordingActive;
    [self setNeedsDisplay];
}

#pragma mark - 绘制

/** 绘制圆角音量柱 */
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context || self.levels.count == 0) {
        return;
    }
    CGFloat contentWidth = MIN(340.0, CGRectGetWidth(rect));
    CGFloat contentOriginX = (CGRectGetWidth(rect) - contentWidth) / 2.0;
    CGFloat barWidth = 2.0;
    CGFloat barSpacing = (contentWidth - barWidth * kTSAIAudioRecordWaveformBarCount) /
        (kTSAIAudioRecordWaveformBarCount - 1);
    CGFloat centerY = CGRectGetMidY(rect);
    CGFloat maximumHeight = MAX(8.0, CGRectGetHeight(rect) - 16.0);
    UIColor *inactiveColor = [UIColor colorWithRed:174.0 / 255.0
                                             green:179.0 / 255.0
                                              blue:197.0 / 255.0
                                             alpha:1.0];
    UIColor *activeColor = [UIColor colorWithRed:16.0 / 255.0
                                           green:20.0 / 255.0
                                            blue:45.0 / 255.0
                                           alpha:1.0];
    for (NSUInteger barIndex = 0; barIndex < kTSAIAudioRecordWaveformBarCount; barIndex++) {
        BOOL isHistoryBar = barIndex < kTSAIAudioRecordWaveformHistoryCount;
        CGFloat level = isHistoryBar ? self.levels[barIndex].doubleValue : 0.05;
        CGFloat barHeight = MAX(5.0, maximumHeight * level);
        CGRect barRect = CGRectMake(contentOriginX + barIndex * (barWidth + barSpacing),
                                    centerY - barHeight / 2.0,
                                    barWidth,
                                    barHeight);
        UIBezierPath *barPath = [UIBezierPath bezierPathWithRoundedRect:barRect
                                                          cornerRadius:barWidth / 2.0];
        UIColor *barColor = self.recordingActive && isHistoryBar ? activeColor : inactiveColor;
        CGContextSetFillColorWithColor(context, barColor.CGColor);
        CGContextAddPath(context, barPath.CGPath);
        CGContextFillPath(context);
    }

    UIColor *pageColor = [UIColor colorWithRed:250.0 / 255.0
                                         green:250.0 / 255.0
                                          blue:252.0 / 255.0
                                         alpha:1.0];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *leftColors = @[(id)pageColor.CGColor, (id)[pageColor colorWithAlphaComponent:0.0].CGColor];
    NSArray *rightColors = @[(id)[pageColor colorWithAlphaComponent:0.0].CGColor, (id)pageColor.CGColor];
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef leftGradient = CGGradientCreateWithColors(colorSpace,
                                                            (__bridge CFArrayRef)leftColors,
                                                            locations);
    CGGradientRef rightGradient = CGGradientCreateWithColors(colorSpace,
                                                             (__bridge CFArrayRef)rightColors,
                                                             locations);
    CGFloat fadeWidth = contentWidth * 0.14;
    CGContextSaveGState(context);
    CGContextAddRect(context, CGRectMake(contentOriginX, 0.0, fadeWidth, CGRectGetHeight(rect)));
    CGContextClip(context);
    CGContextDrawLinearGradient(context,
                                leftGradient,
                                CGPointMake(contentOriginX, 0.0),
                                CGPointMake(contentOriginX + fadeWidth, 0.0),
                                0);
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGContextAddRect(context,
                     CGRectMake(contentOriginX + contentWidth - fadeWidth,
                                0.0,
                                fadeWidth,
                                CGRectGetHeight(rect)));
    CGContextClip(context);
    CGContextDrawLinearGradient(context,
                                rightGradient,
                                CGPointMake(contentOriginX + contentWidth - fadeWidth, 0.0),
                                CGPointMake(contentOriginX + contentWidth, 0.0),
                                0);
    CGContextRestoreGState(context);
    CGGradientRelease(leftGradient);
    CGGradientRelease(rightGradient);
    CGColorSpaceRelease(colorSpace);

    CGFloat playheadX = CGRectGetMidX(rect);
    CGRect playheadRect = CGRectMake(playheadX - 1.0, 8.0, 2.0, CGRectGetHeight(rect) - 16.0);
    UIBezierPath *playheadPath = [UIBezierPath bezierPathWithRoundedRect:playheadRect cornerRadius:1.0];
    [activeColor setFill];
    [playheadPath fill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(playheadX - 3.0, 6.0, 6.0, 6.0)] fill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(playheadX - 3.0,
                                                       CGRectGetHeight(rect) - 12.0,
                                                       6.0,
                                                       6.0)] fill];
}

@end
