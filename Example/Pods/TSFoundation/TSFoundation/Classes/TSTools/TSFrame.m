//
//  TSFrame.m
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/26.
//

#import "TSFrame.h"
//#import "FwDevInfoAbility.h"
@implementation TSFrame


+ (CGFloat)watchWidth{
    
//    CGFloat watchWidth = [[FwSdk share].devInfoAbility getExistDevInfo].screenWidth;
//    if (watchWidth>0) {
//        return watchWidth;
//    }
    return 466;
}


+ (CGFloat)watchHeight{
//    CGFloat watchHeight = [[FwSdk share].devInfoAbility getExistDevInfo].screenHeight;
//    if (watchHeight>0) {
//        return watchHeight;
//    }
    return 466;
}


+ (CGFloat)watchScaleW_H{
    
    return [TSFrame watchWidth]/[TSFrame watchHeight];
}

+ (CGFloat)watchScaleH_W{
    
    return [TSFrame watchHeight]/[TSFrame watchWidth];
}

+ (CGFloat)safeAreaTop {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;//44
    }
    return 0.0;
}

+ (CGFloat)safeAreaBottom {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;//34
    }
    return 0.0;
}

+ (CGFloat)screenScale{
    return  [[UIScreen mainScreen] scale];
}

+ (CGFloat)screenWidth{
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight{
    return [UIScreen mainScreen].bounds.size.height;
}
@end
