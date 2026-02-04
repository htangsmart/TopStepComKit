//
//  UIView+TSView.m
//  JieliJianKang
//
//  Created by luigi on 2024/3/20.
//

#import "UIView+TSView.h"

CGFloat phoneScale375(CGFloat width) {
    
    CGFloat scale = [UIScreen mainScreen].bounds.size.width / 375.f;
    return ceilf(width * scale);
}

CGFloat padScale1180(CGFloat width) {
    
    CGFloat scale = [UIScreen mainScreen].bounds.size.width / 1180.f;
    return ceilf(width * scale);
}

@implementation UIView (TSView)
- (void)ts_addsubViews:(NSArray<UIView *> *)subViews {
    [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if ([obj isKindOfClass:UIView.class]) {
            
            [self addSubview:obj];
        }
    }];
}

#pragma mark - Radius
- (void)ts_setCornerRadius:(CGFloat)cornerRadius {
    [self ts_setCornerRadius:cornerRadius rectCornerType:UIRectCornerAllCorners onImage:YES];
}

- (void)ts_setCornerRadius:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType {
    [self ts_setCornerRadius:cornerRadius rectCornerType:rectCornerType onImage:YES];
}

- (void)ts_setCornerRadius:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType onImage:(BOOL)onImage {
    self.layer.cornerRadius  = cornerRadius;
    CACornerMask rectCornerCAType = (CACornerMask)rectCornerType;
    self.layer.maskedCorners = rectCornerCAType;
    self.layer.masksToBounds = YES;
}

- (CGFloat)ts_cornerRadius {
    return self.layer.cornerRadius;
}


#pragma mark - 渐变图层
- (void)ts_createGradientLayerWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations gradientDirection:(TSGradientDirection)direction {
        
    CAGradientLayer *gradientLayer = [self getGradientLayerWithColors:colors locations:locations direction:direction];
    gradientLayer.name = @"TSGradientLayer";
    
    [self.layer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.name isEqualToString:@"TSGradientLayer"]) {
            
            [obj removeFromSuperlayer];
            *stop = YES;
        }
    }];
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (CAGradientLayer *)getGradientLayerWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations direction:(TSGradientDirection)direction {
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    
    //  创建渐变色数组，需要转换为CGColor颜色
    NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:colors.count];
    [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [cgColors addObject:(__bridge id)obj.CGColor];
    }];
    gradientLayer.colors = cgColors;
    
    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    CGPoint startPoint = CGPointMake(0, 0.5);
    CGPoint endPoint = CGPointMake(1, 0.5);
    
    switch (direction) {
        case TSGradientDirectionLeftToRight:
            startPoint = CGPointMake(0, 0.5);
            endPoint = CGPointMake(1, 0.5);
            break;
        case TSGradientDirectionTopToBottom:
            startPoint = CGPointMake(0.5, 0);
            endPoint = CGPointMake(0.5, 1);
            break;
        case TSGradientDirectionLeftTopToRightBottom:
            startPoint = CGPointMake(0, 0);
            endPoint = CGPointMake(1, 1);
            break;
        case TSGradientDirectionLeftBottomToRightTop:
            startPoint = CGPointMake(1, 1);
            endPoint = CGPointMake(0, 0);
            break;
            
        default:
            break;
    }
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = locations;
    
    return gradientLayer;
}

#pragma mark - Frame
- (void)setSize:(CGSize)size
{
    self.frame = (CGRect){{self.frame.origin.x, self.frame.origin.y}, size};
}

- (void)setOrigin:(CGPoint)origin
{
    self.frame = (CGRect){origin, {self.frame.size.width, self.frame.size.height}};
}

- (void)setX:(CGFloat)x
{
    self.frame = (CGRect){{x, self.frame.origin.y}, self.frame.size};
}

- (void)setY:(CGFloat)y
{
    self.frame = (CGRect){{self.frame.origin.x, y}, self.frame.size};
}

- (void)setWidth:(CGFloat)width
{
    self.frame = (CGRect){self.frame.origin, {width, self.frame.size.height}};
}

- (void)setHeight:(CGFloat)height
{
    self.frame = (CGRect){self.frame.origin, {self.frame.size.width, height}};
}

- (void)setCenterX:(CGFloat)centerX
{
    self.center = CGPointMake(centerX, self.center.y);
}

- (void)setCenterY:(CGFloat)centerY
{
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGSize)size
{
    return self.frame.size;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return  self.frame.origin.y;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (CGFloat)centerY
{
    return self.center.y;
}
@end
