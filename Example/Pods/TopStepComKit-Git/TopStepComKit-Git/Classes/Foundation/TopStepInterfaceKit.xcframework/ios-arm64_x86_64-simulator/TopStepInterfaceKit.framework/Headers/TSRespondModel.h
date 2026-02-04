//
//  TSRespondModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/1/20.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSRespondModel : TSKitBaseModel

/**
 * @brief Request ID
 * @chinese 请求ID
 *
 * @discussion
 * [EN]: The unique identifier of the request that this response corresponds to.
 *       Used to match the response with its original request.
 * [CN]: 此响应对应的请求的唯一标识符。
 *       用于将响应与其原始请求进行匹配。
 */
@property (nonatomic, copy) NSString *requestId;

/**
 * @brief Request name
 * @chinese 请求名称
 *
 * @discussion
 * [EN]: The name of the request that this response corresponds to.
 *       Used to identify the type or purpose of the request.
 * [CN]: 此响应对应的请求的名称。
 *       用于标识请求的类型或用途。
 */
@property (nonatomic, copy) NSString *requestName;

/**
 * @brief Application ID
 * @chinese 应用ID
 *
 * @discussion
 * [EN]: Identifier for the application that initiated the original request.
 * [CN]: 发起原始请求的应用的标识符。
 */
@property (nonatomic, copy) NSString *appId;

/**
 * @brief Response content
 * @chinese 响应内容
 *
 * @discussion
 * [EN]: Dictionary containing the response data.
 *       Key-value pairs represent the response field names and their corresponding values.
 * [CN]: 包含响应数据的字典。
 *       键值对表示响应字段名称及其对应的值。
 */
@property (nonatomic, strong) NSDictionary *responseContent;

/**
 * @brief Error code
 * @chinese 错误码
 *
 * @discussion
 * [EN]: Error code indicating the result of the request processing.
 *       A value of 0 typically indicates success, while non-zero values indicate various error conditions.
 * [CN]: 指示请求处理结果的错误码。
 *       值为0通常表示成功，非零值表示各种错误情况。
 */
@property (nonatomic, assign) NSInteger errorCode;

/**
 * @brief Error message
 * @chinese 错误信息
 *
 * @discussion
 * [EN]: Human-readable error message describing what went wrong.
 *       This property is nil when the request is successful.
 * [CN]: 描述错误原因的可读错误信息。
 *       当请求成功时，此属性为nil。
 */
@property (nonatomic, copy) NSString *errorMessage;

/**
 * @brief Device-side storage path for files
 * @chinese 文件存储的设备端路径
 *
 * @discussion
 * [EN]: The path where files are stored on the device.
 *       This is the remote path on the device side where response files are located.
 * [CN]: 文件在设备上存储的路径。
 *       这是设备端响应文件所在的远程路径。
 */
@property (nonatomic, copy) NSString *deviceStoragePath;

/**
 * @brief Collection of local file paths
 * @chinese 本地文件路径集合
 *
 * @discussion
 * [EN]: Array of local file paths that are part of the response.
 *       Each element in the array is a string representing a local file path.
 * [CN]: 作为响应一部分的本地文件路径数组。
 *       数组中的每个元素是一个表示本地文件路径的字符串。
 */
@property (nonatomic, strong) NSArray<NSString *> *localFilePaths;

@end

NS_ASSUME_NONNULL_END
