//
//  TSAlertButton.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import <UIKit/UIKit.h>
#import "TSAlertAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSAlertButton : UIButton

@property (nonatomic,strong) TSAlertAction * buttonAction;

@property (nonatomic,strong) CAGradientLayer * gradientLayer;

+ (TSAlertButton *)alertButtonWithAction:(TSAlertAction *)buttonAction ;

- (void)addGradientLayer;

- (void)reSizeGradientLayerBounds;


@end

NS_ASSUME_NONNULL_END
