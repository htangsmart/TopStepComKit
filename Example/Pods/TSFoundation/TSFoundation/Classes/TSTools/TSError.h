//
//  TSError.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/2.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, TSErrorCode) {
    eTSErrorCorrect = 0,
    eTSErrorError,
    eTSErrorUnknow ,
};

@interface TSError : NSObject

@property (nonatomic,assign) NSInteger errorCode;

@property (nonatomic,strong) NSString * errorMsg;

+ (TSError *)errorWithCode:(TSErrorCode)errorCode errorMsg:(NSString *)errorMsg;

@end

