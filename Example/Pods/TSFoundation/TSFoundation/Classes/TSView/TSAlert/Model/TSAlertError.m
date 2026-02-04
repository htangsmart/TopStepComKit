//
//  TSAlertError.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import "TSAlertError.h"

@implementation TSAlertError

- (instancetype)initWithError:(BOOL)isError errorCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg
{
    self = [super init];
    if (self) {
        _isError = isError;
        _errorCode = errorCode;
        _errorMsg = errorMsg;
    }
    return self;
}
@end
