//
//  TSAIAudioRecordGradientView.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordGradientView.h"

#import <QuartzCore/QuartzCore.h>

@interface TSAIAudioRecordGradientView ()

// 主渐变层
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
// 右上高光层
@property (nonatomic, strong) CAGradientLayer *highlightLayer;
// 右下装饰圆环
@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end


@implementation TSAIAudioRecordGradientView

#pragma mark - 生命周期

/** 初始化完成态渐变头图 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.layer.shadowColor = [UIColor colorWithRed:79.0 / 255.0
                                                 green:123.0 / 255.0
                                                  blue:255.0 / 255.0
                                                 alpha:1.0].CGColor;
        self.layer.shadowOpacity = 0.22;
        self.layer.shadowRadius = 15.0;
        self.layer.shadowOffset = CGSizeMake(0.0, 7.0);
        [self.layer addSublayer:self.gradientLayer];
        [self.gradientLayer addSublayer:self.highlightLayer];
        [self.gradientLayer addSublayer:self.circleLayer];
    }
    return self;
}

/** 更新渐变与装饰图层尺寸 */
- (void)layoutSubviews {
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
    self.highlightLayer.frame = self.bounds;
    self.circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(
        CGRectGetWidth(self.bounds) - 116.0,
        CGRectGetHeight(self.bounds) - 106.0,
        140.0,
        140.0)].CGPath;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                      cornerRadius:22.0].CGPath;
}

#pragma mark - 属性懒加载 Getter

/** 创建主渐变层 */
- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors = @[
            (id)[UIColor colorWithRed:81.0 / 255.0 green:111.0 / 255.0 blue:255.0 / 255.0 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:148.0 / 255.0 green:112.0 / 255.0 blue:255.0 / 255.0 alpha:1.0].CGColor
        ];
        _gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        _gradientLayer.endPoint = CGPointMake(1.0, 1.0);
        _gradientLayer.cornerRadius = 22.0;
        _gradientLayer.masksToBounds = YES;
    }
    return _gradientLayer;
}

/** 创建右上径向高光 */
- (CAGradientLayer *)highlightLayer {
    if (!_highlightLayer) {
        _highlightLayer = [CAGradientLayer layer];
        _highlightLayer.type = kCAGradientLayerRadial;
        _highlightLayer.colors = @[
            (id)[UIColor colorWithWhite:1.0 alpha:0.24].CGColor,
            (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor
        ];
        _highlightLayer.startPoint = CGPointMake(0.92, 0.08);
        _highlightLayer.endPoint = CGPointMake(0.62, 0.38);
    }
    return _highlightLayer;
}

/** 创建右下装饰圆环 */
- (CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.fillColor = UIColor.clearColor.CGColor;
        _circleLayer.strokeColor = [UIColor colorWithWhite:1.0 alpha:0.20].CGColor;
        _circleLayer.lineWidth = 1.0;
    }
    return _circleLayer;
}

@end
