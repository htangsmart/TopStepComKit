//
//  MZPayAuthError.h
//  MZPayAuthSDKDemo
//
//  Created by locke on 2022/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MZAuthType) {
    
    MZAuthTypePay = 1,///< 双支付
    MZAuthTypeVoiceOffline,///< 离线语音
};


/// 支付鉴权结果
typedef NS_ENUM(NSInteger, MZPayAuthResult) {
    
    MZPayAuthSuccess = 0x01,///< 成功
    
    MZPayAuthFailure = 0x02,///< 失败
    
    MZPayAuthUnknown = 0xFF,///< 未知错误
};


/// 鉴权失败(MZPayAuthFailure)的错误码
typedef NS_ENUM(NSInteger, MZPayAuthErrorCode) {
    
    /// SDK端错误码
    MZErrorCodeUnknown                   = 1000,///< 未知错误
    MZErrorCodeDeviceError               = 1001,///< 传入设备错误
    MZErrorCodeSDKAccessAppBundleIdError = 1002,///< 获取不到AppBundle id
    MZErrorCodeSDKAccessAppVersionError  = 1003,///< 获取不到App version
    MZErrorCodeTimeout                   = 1004,///< 超时
    
    /// 服务端错误码
    MZErrorCodeDeviceInfoError                = 4000,///< 设备上传的信息错误
    MZErrorCodeDeviceInfoDiffFromDeviceError  = 4100,///< 设备信息校验错误
    MZErrorCodeDeviceInfoDiffFromServiceError = 4200,///< 设备信息与服务器的不一致
    MZErrorCodeFailedToFindDevice             = 4301,///< 未知设备
    MZErrorCodeDeviceInfoDecryptError         = 4302,///< 固件信息解密失败
    MZErrorCodeServiceException               = 4305,///< 异常
    
    
};

@interface MZPayAuthError : NSObject

/// 鉴权类型
@property (nonatomic, assign) MZAuthType type;

/// 鉴权结果
@property (nonatomic, assign) MZPayAuthResult result;

/// 具体的错误码
/// 只有当result == MZPayAuthFailure时 这个字段才有效
@property (nonatomic, assign) MZPayAuthErrorCode errorCode;

+ (instancetype)errorWithType:(MZAuthType)type result:(MZPayAuthResult)result code:(MZPayAuthErrorCode)code;

@end

NS_ASSUME_NONNULL_END

