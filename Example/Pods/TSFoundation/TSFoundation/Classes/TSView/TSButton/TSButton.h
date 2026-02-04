//
//  TSButton.h
//  JieliJianKang
//
//  Created by luigi on 2024/3/26.
//

#import <UIKit/UIKit.h>
#import "UIView+TSView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSButton : UIButton
@property (nonatomic) CGSize touchSize;//扩大按钮点击范围
/**
 图片位置
 */
@property (nonatomic, assign) UIRectEdge imagePosition;

+ (instancetype)defaultGradientLayerButton;
/**
 * 绘制渐变色图层
 * @param colors 渐变颜色数组
 * @param locations 变更颜色位置数组 取值0-1之间
 * @param direction 渐变方向
 */
+ (instancetype)createGradientLayerButtonWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations gradientDirection:(TSGradientDirection)direction;
@end

NS_ASSUME_NONNULL_END
