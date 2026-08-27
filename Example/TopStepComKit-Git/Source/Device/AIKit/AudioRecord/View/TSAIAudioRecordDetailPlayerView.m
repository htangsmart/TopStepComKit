//
//  TSAIAudioRecordDetailPlayerView.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordDetailPlayerView.h"

#import <QuartzCore/QuartzCore.h>

@interface TSAIAudioRecordDetailPlayerView ()

// 详情页主渐变
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
// 右上径向高光
@property (nonatomic, strong) CAGradientLayer *highlightLayer;

@end


@implementation TSAIAudioRecordDetailPlayerView

#pragma mark - 生命周期

/** 初始化详情播放卡片 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.layer.shadowColor = [UIColor colorWithRed:79.0 / 255.0
                                                 green:123.0 / 255.0
                                                  blue:255.0 / 255.0
                                                 alpha:1.0].CGColor;
        self.layer.shadowOpacity = 0.22;
        self.layer.shadowRadius = 17.0;
        self.layer.shadowOffset = CGSizeMake(0.0, 8.0);
        [self.layer addSublayer:self.gradientLayer];
        [self.gradientLayer addSublayer:self.highlightLayer];
    }
    return self;
}

/** 更新渐变、高光和阴影尺寸 */
- (void)layoutSubviews {
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
    self.highlightLayer.frame = self.bounds;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                      cornerRadius:22.0].CGPath;
}

#pragma mark - 属性懒加载 Getter

/** 创建 HTML 使用的蓝紫渐变 */
- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors = @[
            (id)[UIColor colorWithRed:79.0 / 255.0 green:123.0 / 255.0 blue:255.0 / 255.0 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:149.0 / 255.0 green:107.0 / 255.0 blue:255.0 / 255.0 alpha:1.0].CGColor,
        ];
        _gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        _gradientLayer.endPoint = CGPointMake(1.0, 1.0);
        _gradientLayer.cornerRadius = 22.0;
        _gradientLayer.masksToBounds = YES;
    }
    return _gradientLayer;
}

/** 创建 HTML 右上角径向高光 */
- (CAGradientLayer *)highlightLayer {
    if (!_highlightLayer) {
        _highlightLayer = [CAGradientLayer layer];
        _highlightLayer.type = kCAGradientLayerRadial;
        _highlightLayer.colors = @[
            (id)[UIColor colorWithWhite:1.0 alpha:0.18].CGColor,
            (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
        ];
        _highlightLayer.startPoint = CGPointMake(0.95, 0.0);
        _highlightLayer.endPoint = CGPointMake(0.63, 0.32);
    }
    return _highlightLayer;
}

@end
