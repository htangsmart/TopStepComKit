//
//  TSRequestModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/1/20.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSRequestModel : TSKitBaseModel

/**
 * @brief Request name
 * @chinese 请求名称
 *
 * @discussion
 * [EN]: The name of the request, used to identify the type or purpose of the request.
 * [CN]: 请求的名称，用于标识请求的类型或用途。
 */
@property (nonatomic, copy) NSString *requestName;

/**
 * @brief Request ID
 * @chinese 请求ID
 *
 * @discussion
 * [EN]: Unique identifier for the request, used to track and match requests and responses.
 * [CN]: 请求的唯一标识符，用于跟踪和匹配请求与响应。
 */
@property (nonatomic, copy) NSString *requestId;

/**
 * @brief Request URL
 * @chinese 请求URL
 *
 * @discussion
 * [EN]: The URL endpoint where the request should be sent or processed.
 * [CN]: 请求应发送或处理的目标URL端点。
 */
@property (nonatomic, copy) NSString *requestUrl;

/**
 * @brief Request parameters
 * @chinese 请求参数
 *
 * @discussion
 * [EN]: Dictionary containing all parameters for the request.
 *       Key-value pairs represent the parameter names and their corresponding values.
 * [CN]: 包含请求所有参数的字典。
 *       键值对表示参数名称及其对应的值。
 */
@property (nonatomic, strong) NSDictionary *parameters;

/**
 * @brief Application ID
 * @chinese 应用ID
 *
 * @discussion
 * [EN]: Identifier for the application that initiated the request.
 * [CN]: 发起请求的应用的标识符。
 */
@property (nonatomic, copy) NSString *appId;

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
 * @brief Collection of remote file paths on device
 * @chinese 设备端文件路径集合
 *
 * @discussion
 * [EN]: Array of remote file paths on the device that need to be downloaded.
 *       Files from these remote paths will be downloaded and stored to localFilePaths.
 *       Each element in the array is a string representing a remote file path on the device.
 * [CN]: 设备上需要下载的远程文件路径数组。
 *       这些远程路径的文件将被下载并存储到localFilePaths中。
 *       数组中的每个元素是一个表示设备端远程文件路径的字符串。
 */
@property (nonatomic, strong) NSArray<NSString *> *remoteFilePaths;

/**
 * @brief Collection of local file paths
 * @chinese 本地文件路径集合
 *
 * @discussion
 * [EN]: Array of local file paths that need to be transferred or processed.
 *       Files from remoteFilePaths will be downloaded and stored to these local paths.
 *       Each element in the array is a string representing a local file path.
 * [CN]: 需要传输或处理的本地文件路径数组。
 *       从remoteFilePaths下载的文件将存储到这些本地路径中。
 *       数组中的每个元素是一个表示本地文件路径的字符串。
 */
@property (nonatomic, strong) NSArray<NSString *> *localFilePaths;

@end

NS_ASSUME_NONNULL_END
