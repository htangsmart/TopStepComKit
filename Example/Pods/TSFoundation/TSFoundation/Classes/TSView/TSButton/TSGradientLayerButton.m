//
//  TSGradientLayerButton.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/23.
//

#import "TSGradientLayerButton.h"

@interface TSGradientLayerButton ()

@property (nonatomic,strong) CAGradientLayer * gradientLayer;

@end


@implementation TSGradientLayerButton

+(instancetype)defaultGradientLayerButton{
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.layer.cornerRadius = 24;
//    [button setBackgroundColor:TSHEXCOLOR(#0072DB)];
//    return button;
    
//    UIColor *beginColor = [UIColor colorWithRed:36/255.0 green:255/255.0 blue:189/255.0 alpha:1.0f];
//    UIColor *endColor = [UIColor colorWithRed:70/255.0 green:186/255.0 blue:255/255.0 alpha:1.0f];
    return [TSGradientLayerButton buttonWithBeginColor:TSHEXCOLOR(#0072DB) endColor:TSHEXCOLOR(#0072DB)];
}


+(instancetype)defaultGradientLayerButtonWithAlpha:(CGFloat)alpha{
    
    UIColor *beginColor = [UIColor colorWithRed:36/255.0 green:255/255.0 blue:189/255.0 alpha:alpha];
    UIColor *endColor = [UIColor colorWithRed:70/255.0 green:186/255.0 blue:255/255.0 alpha:alpha];
    return [TSGradientLayerButton buttonWithBeginColor:beginColor endColor:endColor];
}

+ (instancetype)buttonWithBeginColor:(UIColor *)beginColor endColor:(UIColor *)endColor{
    return [[TSGradientLayerButton alloc]initWithColors:@[(__bridge id)beginColor.CGColor, (__bridge id)endColor.CGColor] locations:@[@0.0, @1.0] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1.0, 0) cornerRadius:24];
}

- (instancetype)initWithColors:(NSArray *)colors locations:(NSArray *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint cornerRadius:(CGFloat)cornerRadius{
   
    self = [super init];
    
    if (self) {
        self.gradientLayer.colors     = colors;
        self.gradientLayer.locations  = locations;
        self.gradientLayer.startPoint = startPoint;
        self.gradientLayer.endPoint   = endPoint;
        self.gradientLayer.cornerRadius = cornerRadius;

        [self.layer addSublayer:self.gradientLayer];
    }
    return self;
}

- (void)reloadButtonWithColors:(NSArray *)colors locations:(NSArray *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint cornerRadius:(CGFloat)cornerRadius{
   
    self.gradientLayer.colors     = colors;
    self.gradientLayer.locations  = locations;
    self.gradientLayer.startPoint = startPoint;
    self.gradientLayer.endPoint   = endPoint;
    self.gradientLayer.cornerRadius = cornerRadius;
}

- (void)reloadButtonWithBeginColor:(UIColor *)beginColor endColor:(UIColor *)endColor{
    [self reloadButtonWithColors:@[(__bridge id)beginColor.CGColor, (__bridge id)endColor.CGColor] locations:@[@0.0, @1.0] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1.0, 0) cornerRadius:CGRectGetHeight(self.frame)/2.0f];
}

- (void)reloadButtonWithColors:(NSArray *)colors{
    if (colors && colors.count>0) {
        [self reloadButtonWithColors:colors locations:@[@0.0, @1.0] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1.0, 0) cornerRadius:CGRectGetHeight(self.frame)/2.0f];
    }
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.gradientLayer.frame  = CGRectMake(0, 0,  CGRectGetWidth(frame), CGRectGetHeight(frame));
    self.gradientLayer.cornerRadius = CGRectGetHeight(frame)/2.0f;
}

- (void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
    [self reloadButtonWithColors:[self newColorArrayWithAlpha:enabled?1.0f:0.5f]];
}

- (void)showGradientLayer:(BOOL)isShow{
    self.gradientLayer.hidden = !isShow;
}

- (NSArray *)newColorArrayWithAlpha:(CGFloat)alpha{
    NSMutableArray *colorArray = [NSMutableArray new];
    for (int i  = 0; i<self.gradientLayer.colors.count; i++) {
        CGColorRef colorRef = (__bridge CGColorRef)[self.gradientLayer.colors objectAtIndex:i];
        [colorArray addObject:(__bridge id)CGColorCreateCopyWithAlpha(colorRef, alpha)];
    }
    return colorArray;
}

- (void)setMaskLayer:(CAShapeLayer *)maskLayer{
    if (_gradientLayer) {
        _gradientLayer.mask = maskLayer;
    }
}

- (CAGradientLayer *)gradientLayer{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
    }
    return _gradientLayer;
}


@end
