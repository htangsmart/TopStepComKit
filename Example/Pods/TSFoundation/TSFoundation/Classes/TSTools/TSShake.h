//
//  TSShake.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TSShakeDirection) {
    eTSShakeDirectionUpDown,
    eTSShakeDirectionLeftRight,
};

@interface TSShake : NSObject

+ (void)shake;

+ (void)shake:(UIImpactFeedbackStyle)shakeStyle;

+ (void)audioShake;

+ (void)shakeView:(UIView *)shakeView;

+ (void)shakeView:(UIView *) view distance:(CGFloat)distance direction:(TSShakeDirection)direction duration:(CGFloat)duration repeatCount:(NSInteger)repeatCount;

@end

NS_ASSUME_NONNULL_END
