//
//  TSAIAudioRecordPlaybackWaveformView.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordPlaybackWaveformView.h"

static const NSUInteger kTSAIAudioRecordPlaybackWaveformBarCount = 34;
static const CGFloat kTSAIAudioRecordPlaybackWaveformHeights[] = {
    12.0, 25.0, 18.0, 34.0, 22.0, 41.0, 17.0, 28.0, 39.0, 21.0,
    31.0, 14.0, 36.0, 24.0, 43.0, 19.0, 29.0, 37.0, 16.0, 33.0,
    23.0, 40.0, 18.0, 28.0, 35.0, 15.0, 30.0, 20.0, 38.0, 24.0,
    32.0, 17.0, 27.0, 21.0,
};

@implementation TSAIAudioRecordPlaybackWaveformView

#pragma mark - 生命周期

/** 初始化详情页波形 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.opaque = NO;
    }
    return self;
}

#pragma mark - 绘制

/** 绘制 HTML 详情页定义的固定波形 */
- (void)drawRect:(CGRect)rect {
    CGFloat barWidth = 3.0;
    CGFloat barSpacing = 3.0;
    CGFloat centerY = CGRectGetMidY(rect);
    for (NSUInteger barIndex = 0;
         barIndex < kTSAIAudioRecordPlaybackWaveformBarCount;
         barIndex++) {
        CGFloat barHeight = kTSAIAudioRecordPlaybackWaveformHeights[barIndex];
        CGRect barRect = CGRectMake(barIndex * (barWidth + barSpacing),
                                    centerY - barHeight / 2.0,
                                    barWidth,
                                    barHeight);
        UIColor *barColor = [UIColor colorWithWhite:1.0 alpha:0.72];
        [barColor setFill];
        [[UIBezierPath bezierPathWithRoundedRect:barRect cornerRadius:1.0] fill];
    }
}

@end
