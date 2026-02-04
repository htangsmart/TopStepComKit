//
//  TSColorPicker.h
//  TSFoundation
//
//  Created by 磐石 on 2024/8/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSColorPicker : NSObject

+ (void)presentColorPickerOnVC:(UIViewController *)superVC complete:(void(^)(UIColor * pickColor))complete;
+ (void)presentColorPickerOnVC:(UIViewController *)superVC displayView:(UIView *)displayView complete:(void(^)(UIColor * pickColor))complete;

@end

NS_ASSUME_NONNULL_END
