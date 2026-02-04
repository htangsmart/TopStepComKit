//
//  TSAlertError.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSAlertError : NSObject


@property (nonatomic,assign) BOOL isError;
@property (nonatomic,assign) NSInteger errorCode;
@property (nonatomic,strong) NSString * errorMsg;

- (instancetype)initWithError:(BOOL)isError errorCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg;

@end

NS_ASSUME_NONNULL_END
