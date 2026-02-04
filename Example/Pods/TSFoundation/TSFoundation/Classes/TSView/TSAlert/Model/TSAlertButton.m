//
//  TSAlertButton.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import "TSAlertButton.h"
#import "TSFont.h"
#import "TSColor.h"
#import "TSToast.h"

@implementation TSAlertButton


+ (TSAlertButton *)alertButtonWithAction:(TSAlertAction *)buttonAction{
    
    TSAlertButton *alertButton = [TSAlertButton buttonWithType:UIButtonTypeCustom];
    alertButton.buttonAction = buttonAction;

    [alertButton setTitle:buttonAction.actionString forState:UIControlStateNormal];
    alertButton.titleLabel.font = buttonAction.actionFont;
    [alertButton setTitleColor:buttonAction.actionStringCorlor forState:UIControlStateNormal];
    
    if (buttonAction.isGradientColor) {
        [alertButton addGradientLayer];
    }else{
        [alertButton setBackgroundColor:buttonAction.actionBackCorlor];
    }
    if (buttonAction.actionCornerRadius>0) {
        alertButton.layer.cornerRadius = buttonAction.actionCornerRadius;
    }
    
    return alertButton;
}



- (void)reSizeGradientLayerBounds{
    for (CAGradientLayer *subLayer in self.layer.sublayers) {
        subLayer.frame = self.bounds;;
    }
}

- (void)addGradientLayer{
    if (_buttonAction.isGradientColor) {
        [self.layer addSublayer:self.gradientLayer];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
}

- (CAGradientLayer *)gradientLayer{
    if (!_gradientLayer) {
        UIColor *beginColor = _buttonAction.gradientBeginCorlor;
        UIColor *endColor = _buttonAction.gradientEndCorlor;
        _gradientLayer = [CAGradientLayer layer];
        if (beginColor && endColor) {
            _gradientLayer.colors     = @[(__bridge id)beginColor.CGColor, (__bridge id)endColor.CGColor];
            _gradientLayer.locations  = @[@0.0, @1.0];
            _gradientLayer.startPoint = CGPointMake(0, 0);
            _gradientLayer.endPoint   = CGPointMake(1.0, 0);
            _gradientLayer.frame      = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            _gradientLayer.cornerRadius = _buttonAction.actionCornerRadius;
        }
    }
    return _gradientLayer;
}



@end
