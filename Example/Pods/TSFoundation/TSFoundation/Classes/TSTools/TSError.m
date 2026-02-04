//
//  TSError.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/2.
//

#import "TSError.h"

@implementation TSError

+ (TSError *)errorWithCode:(TSErrorCode)errorCode errorMsg:(NSString *)errorMsg{
    TSError *error = [[TSError alloc]init];
    error.errorCode = errorCode;
    error.errorMsg = errorMsg;
    return error;
}

@end
