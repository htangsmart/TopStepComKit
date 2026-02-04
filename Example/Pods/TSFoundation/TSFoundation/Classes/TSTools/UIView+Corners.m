//
//  UIView+Corners.m
//  TSFoundation
//
//  Created by 磐石 on 2024/8/3.
//

#import "UIView+Corners.h"

@implementation UIView (Corners)


- (void)setupCornerRoundWithCornerRadii:(CGSize)size {
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}


/**
 *  设置部分圆角(绝对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii {
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    self.layer.mask = shape;
}


/**
 *  设置部分圆角(相对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 *  @param rect    需要设置的圆角view的rect
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii
                 viewRect:(CGRect)rect {
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    self.layer.mask = shape;
}

- (void)setCornerWithLeftTopCorner:(CGFloat)leftTop
                    rightTopCorner:(CGFloat)rigtTop
                  bottomLeftCorner:(CGFloat)bottemLeft
                 bottomRightCorner:(CGFloat)bottemRight{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    maskPath.lineWidth = 1.0;
    maskPath.lineCapStyle = kCGLineCapRound;
    maskPath.lineJoinStyle = kCGLineJoinRound;
    [maskPath moveToPoint:CGPointMake(bottemRight, height)]; //左下角
    [maskPath addLineToPoint:CGPointMake(width - bottemRight, height)];
    
    [maskPath addQuadCurveToPoint:CGPointMake(width, height- bottemRight) controlPoint:CGPointMake(width, height)]; //右下角的圆弧
    [maskPath addLineToPoint:CGPointMake(width, rigtTop)]; //右边直线
    
    [maskPath addQuadCurveToPoint:CGPointMake(width - rigtTop, 0) controlPoint:CGPointMake(width, 0)]; //右上角圆弧
    [maskPath addLineToPoint:CGPointMake(leftTop, 0)]; //顶部直线
    
    [maskPath addQuadCurveToPoint:CGPointMake(0, leftTop) controlPoint:CGPointMake(0, 0)]; //左上角圆弧
    [maskPath addLineToPoint:CGPointMake(0, height - bottemLeft)]; //左边直线
    [maskPath addQuadCurveToPoint:CGPointMake(bottemLeft, height) controlPoint:CGPointMake(0, height)]; //左下角圆弧

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}






@end
