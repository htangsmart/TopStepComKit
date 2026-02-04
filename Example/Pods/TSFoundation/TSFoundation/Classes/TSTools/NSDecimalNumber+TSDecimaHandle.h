//
//  NSDecimalNumber+TSDecimaHandle.h
//  TSFoundation
//
//  Created by luigi on 2024/7/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDecimalNumber (TSDecimaHandle)

/// 进行舍入操作
/// @param number 进行舍入的number
/// @param scale 舍入的精度（保留小数点后几位）
/// @param roudMode 舍入模式
/// 此方法每次计算都会创建一个NSDecimalNumberHandler，在大批量计算时可不用此方法而在计算前设置NSDecimalNumber的defaultBehavior进行计算提高效率
+ (NSDecimalNumber *)getDecimalByNumber:(NSNumber *)number scale:(short)scale roudMode:(NSRoundingMode)roudMode;

+ (NSDecimalNumber *)getDecimalByString:(NSString *)string scale:(short)scale roudMode:(NSRoundingMode)roudMode;

@end

NS_ASSUME_NONNULL_END
