//
//  TSNetworkManager.h
//  TopStepComKit
//
//  Created by 磐石 on 2025/3/25.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN
//
//@interface TSNetworkManager : NSObject
//
//@end
//
//NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Network error codes
 * @chinese 网络错误码
 */
typedef NS_ENUM(NSInteger, TSNetworkErrorCode) {
    /**
     * @brief Invalid URL error
     * @chinese 无效的URL错误
     */
    TSNetworkErrorInvalidURL = 1001,
    
    /**
     * @brief Network unavailable error
     * @chinese 网络不可用错误
     */
    TSNetworkErrorNoNetwork = 1002,
    
    /**
     * @brief Request timeout error
     * @chinese 请求超时错误
     */
    TSNetworkErrorTimeout = 1003,
    
    /**
     * @brief JSON serialization error
     * @chinese JSON序列化错误
     */
    TSNetworkErrorJSONSerialization = 1004,
    
    /**
     * @brief JSON deserialization error
     * @chinese JSON反序列化错误
     */
    TSNetworkErrorJSONDeserialization = 1005,
    
    /**
     * @brief HTTP error (status code not in 2xx)
     * @chinese HTTP错误（状态码不在2xx范围内）
     */
    TSNetworkErrorHTTPError = 1006,
    
    /**
     * @brief Unknown error
     * @chinese 未知错误
     */
    TSNetworkErrorUnknown = 9999
};

/**
 * @brief Network error domain
 * @chinese 网络错误域
 */
extern NSString * const TSNetworkErrorDomain;

/**
 * @brief Network request completion block
 * @chinese 网络请求完成回调
 *
 * @param responseObject
 * EN: Response data object, could be NSDictionary, NSArray, etc.
 * CN: 响应数据对象，可能是NSDictionary、NSArray等
 *
 * @param error
 * EN: Error object if request failed, nil if successful
 * CN: 如果请求失败则为错误对象，成功则为nil
 */
typedef void(^TSNetworkCompletionBlock)(id _Nullable responseObject, NSError * _Nullable error);

/**
 * @brief Network Manager for handling API requests
 * @chinese 用于处理API请求的网络管理器
 */
@interface TSNetworkManager : NSObject

/**
 * @brief Shared instance of the network manager
 * @chinese 网络管理器的共享实例
 *
 * @return
 * EN: Singleton instance of TSNetworkManager
 * CN: TSNetworkManager的单例实例
 */
+ (instancetype)sharedManager;

/**
 * @brief Send POST request with JSON parameters
 * @chinese 发送带有JSON参数的POST请求
 *
 * @param urlString
 * EN: The URL string for the request
 * CN: 请求的URL字符串
 *
 * @param parameters
 * EN: Parameters to be sent in JSON format
 * CN: 以JSON格式发送的参数
 *
 * @param headers
 * EN: Additional headers for the request, can be nil
 * CN: 请求的附加头信息，可以为nil
 *
 * @param completion
 * EN: Completion block called when request finishes
 * CN: 请求完成时调用的完成块
 */
- (void)postJSONRequestWithURL:(NSString *)urlString
                    parameters:(NSDictionary *)parameters
                       headers:(nullable NSDictionary *)headers
                    completion:(TSNetworkCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END

