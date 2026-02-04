//
//  TSColorPickerVC.h
//  TSFoundation
//
//  Created by 磐石 on 2024/8/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSColorPickerVC : UIViewController

@property (nonatomic,strong) UIColor * pickColor;

- (instancetype)initWithPickColorBlock:(void(^)(UIColor * pickColor))pickColorBlock displayView:(UIView *)displayView;

@end

NS_ASSUME_NONNULL_END
