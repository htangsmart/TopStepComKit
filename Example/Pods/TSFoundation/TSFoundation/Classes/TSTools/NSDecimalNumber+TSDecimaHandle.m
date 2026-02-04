//
//  NSDecimalNumber+TSDecimaHandle.m
//  TSFoundation
//
//  Created by luigi on 2024/7/17.
//

#import "NSDecimalNumber+TSDecimaHandle.h"

@implementation NSDecimalNumber (TSDecimaHandle)

+ (NSDecimalNumber *)getDecimalByNumber:(NSNumber *)number scale:(short)scale roudMode:(NSRoundingMode)roudMode {
    
    return [self getDecimalByString:[number isKindOfClass:NSNumber.class] ? number.stringValue : @"0" scale:scale roudMode:roudMode];
}

+ (NSDecimalNumber *)getDecimalByString:(NSString *)string scale:(short)scale roudMode:(NSRoundingMode)roudMode {
    
    NSDecimalNumberHandler *handler = [[NSDecimalNumberHandler alloc] initWithRoundingMode:roudMode scale:scale raiseOnExactness:false raiseOnOverflow:false raiseOnUnderflow:false raiseOnDivideByZero:false];
    NSDecimalNumber *decimal = TSSTRING_ISEMPTY(string) ? [NSDecimalNumber zero] : [[NSDecimalNumber alloc] initWithString:string];
    [decimal decimalNumberByRoundingAccordingToBehavior:handler];
    return [decimal decimalNumberByRoundingAccordingToBehavior:handler];
}
@end
