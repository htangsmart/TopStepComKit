//
//  TSLockPasswordValidator.m
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/3/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSLockPasswordValidator.h"

@implementation TSLockPasswordValidator

/**
 * 校验并返回规范化密码（1–6 位数字），不合法返回 nil
 */
+ (nullable NSString *)validatedPasswordFromRawInput:(NSString *)raw {
    if (!raw || raw.length == 0) return nil;
    NSCharacterSet *digitSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inputSet = [NSCharacterSet characterSetWithCharactersInString:raw];
    if (![digitSet isSupersetOfSet:inputSet] || raw.length > 6) return nil;
    return raw.length <= 6 ? raw : [raw substringToIndex:6];
}

@end
