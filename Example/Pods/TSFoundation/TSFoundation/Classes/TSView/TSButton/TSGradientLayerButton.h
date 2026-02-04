//
//  TSGradientLayerButton.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSGradientLayerButton : UIButton


+(instancetype)defaultGradientLayerButton;

+(instancetype)defaultGradientLayerButtonWithAlpha:(CGFloat)alpha;

+ (instancetype)buttonWithBeginColor:(UIColor *)beginColor endColor:(UIColor *)endColor;

- (instancetype)initWithColors:(NSArray *)colors locations:(NSArray *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint cornerRadius:(CGFloat)cornerRadius;

- (void)setMaskLayer:(CAShapeLayer *)maskLayer;

- (void)reloadButtonWithBeginColor:(UIColor *)beginColor endColor:(UIColor *)endColor;

- (void)showGradientLayer:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
