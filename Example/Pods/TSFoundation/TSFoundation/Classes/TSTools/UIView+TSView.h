//
//  UIView+TSView.h
//  JieliJianKang
//
//  Created by luigi on 2024/3/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 将375宽度的设计图上的长度转换成当前屏幕的宽度的长度
extern CGFloat phoneScale375(CGFloat width);
/// 将1180宽度的设计图上的长度转换成当前屏幕的宽度的长度
extern CGFloat padScale1180(CGFloat width);

@interface UIView (TSView)

- (void)ts_addsubViews:(NSArray<UIView *> *)subViews;

#pragma mark - Radius
- (CGFloat)ts_cornerRadius;
- (void)ts_setCornerRadius:(CGFloat)cornerRadius;
- (void)ts_setCornerRadius:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType;
- (void)ts_setCornerRadius:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType onImage:(BOOL)onImage;

#pragma mark - 渐变图层
typedef NS_ENUM(NSUInteger ,TSGradientDirection){//渐变方向
    TSGradientDirectionLeftToRight,
    TSGradientDirectionLeftTopToRightBottom,
    TSGradientDirectionLeftBottomToRightTop,
    TSGradientDirectionTopToBottom,
};

/**
 * 绘制渐变色图层
 * @param colors 渐变颜色数组
 * @param locations 变更颜色位置数组 取值0-1之间
 * @param direction 渐变方向
 */
- (void)ts_createGradientLayerWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations gradientDirection:(TSGradientDirection)direction;

- (CAGradientLayer *)getGradientLayerWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations direction:(TSGradientDirection)direction;
#pragma mark - Frame
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGPoint origin;

@property (nonatomic, assign) CGFloat x;

@property (nonatomic, assign) CGFloat y;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat centerX;

@property (nonatomic, assign) CGFloat centerY;

@end

NS_ASSUME_NONNULL_END
