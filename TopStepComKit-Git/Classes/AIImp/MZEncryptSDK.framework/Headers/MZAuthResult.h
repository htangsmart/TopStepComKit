//
//  MZAuthResult.h
//  MZEncryptSDK
//
//  Created by ymz on 2025/1/8.
//

#import <Foundation/Foundation.h>
#import "MZPayAuthError.h"

NS_ASSUME_NONNULL_BEGIN

@interface MZAuthResult : NSObject

/// 双支付校验结果(payAuthResult == nil 表示该次校验不包含双支付，原因是设备不支持)
@property (nonatomic, strong, nullable) MZPayAuthError *payAuthResult;

/// 离线语音校验结果(voiceOfflineAuthResult == nil 表示该次校验不包含离线语音，原因是设备不支持)
@property (nonatomic, strong, nullable) MZPayAuthError *voiceOfflineAuthResult;

@end

NS_ASSUME_NONNULL_END
