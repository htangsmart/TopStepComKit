//
//  TSPredicate.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/15.
//

#import "TSPredicate.h"

@implementation TSPredicate

+ (BOOL)isCorrectNum:(NSString *)numString{
    if ( numString == nil || numString.length <= 0) {return NO;}
    if ([numString hasPrefix:@"0"]) {return NO;}
    NSString *regex = @"^[1-9]*[0-9][0-9]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:numString];

}


@end
