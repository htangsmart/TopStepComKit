//
//  TSFirmwareKeyService.h
//  NetworkRequestSystem
//
//  Created by Developer on 2023/10/01.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Firmware key error codes
 * @chinese 固件密钥错误码
 */
typedef NS_ENUM(NSInteger, TSFirmwareKeyErrorCode) {
    /**
     * @brief Missing required parameters
     * @chinese 缺少必需参数
     */
    TSFirmwareKeyErrorMissingParameters = 2001,
    
    /**
     * @brief API error
     * @chinese API错误
     */
    TSFirmwareKeyErrorAPIError = 2002,
    
    /**
     * @brief Key not found in response
     * @chinese 响应中未找到密钥
     */
    TSFirmwareKeyErrorKeyNotFound = 2003,
    
    /**
     * @brief Invalid response format
     * @chinese 无效的响应格式
     */
    TSFirmwareKeyErrorInvalidFormat = 2004
};

/**
 * @brief Firmware key error domain
 * @chinese 固件密钥错误域
 */
extern NSString * const TSFirmwareKeyErrorDomain;

/**
 * @brief Firmware key request completion block
 * @chinese 固件密钥请求完成回调
 *
 * @param key
 * EN: The firmware key string if successful, nil if failed
 * CN: 如果成功则为固件密钥字符串，失败则为nil
 *
 * @param error
 * EN: Error object if request failed, nil if successful
 * CN: 如果请求失败则为错误对象，成功则为nil
 */
typedef void(^TSFirmwareKeyCompletionBlock)(NSString * _Nullable key, NSError * _Nullable error);

/**
 * @brief Service for firmware key related API requests
 * @chinese 用于固件密钥相关API请求的服务
 */
@interface TSFirmwareKeyService : NSObject

/**
 * @brief Shared instance of the firmware key service
 * @chinese 固件密钥服务的共享实例
 *
 * @return
 * EN: Singleton instance of TSFirmwareKeyService
 * CN: TSFirmwareKeyService的单例实例
 */
+ (instancetype)sharedService;

/**
 * @brief Get firmware key from server
 * @chinese 从服务器获取固件密钥
 *
 * @param clientID
 * EN: Client ID for authentication
 * CN: 用于认证的客户端ID
 *
 * @param clientSecret
 * EN: Client secret for authentication
 * CN: 用于认证的客户端密钥
 *
 * @param deviceID
 * EN: Device ID for which the key is requested
 * CN: 请求密钥的设备ID
 *
 * @param completion
 * EN: Completion block called when request finishes
 * CN: 请求完成时调用的完成块
 */
- (void)getFirmwareKeyWithClientID:(NSString *)clientID
                      clientSecret:(NSString *)clientSecret
                          deviceID:(NSString *)deviceID
                        completion:(TSFirmwareKeyCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END 
