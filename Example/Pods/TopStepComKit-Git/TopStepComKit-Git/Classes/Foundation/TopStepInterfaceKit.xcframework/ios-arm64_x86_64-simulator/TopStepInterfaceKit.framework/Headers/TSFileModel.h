//
//  TSFileModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/27.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief File model
 * @chinese 文件模型
 *
 * @discussion 
 * EN: This is a generic file model that contains basic file information (path and size).
 *     It can be used for various file operations such as file transfer, log fetching, etc.
 * CN: 这是一个通用的文件模型，包含基本的文件信息（路径和大小）。
 *     可用于各种文件操作，如文件传输、日志获取等。
 */
@interface TSFileModel : TSKitBaseModel

/**
 * @brief File path
 * @chinese 文件路径
 *
 * @discussion 
 * EN: The path of the file. Can be a local file path or a remote file path.
 *     For file transfer, this is typically a local file path.
 *     For log fetching, this is typically a remote file path on the device.
 * CN: 文件的路径。可以是本地文件路径或远程文件路径。
 *     对于文件传输，通常是本地文件路径。
 *     对于日志获取，通常是设备上的远程文件路径。
 */
@property (nonatomic, copy) NSString *path;

/**
 * @brief File size in bytes
 * @chinese 文件大小（字节）
 *
 * @discussion 
 * EN: The size of the file in bytes. 
 *     This property is optional and may be 0 if the size is unknown or not yet determined.
 *     For file transfer, this can be set before transfer to indicate expected file size.
 *     For log fetching, this is typically set after fetching the log list from the device.
 * CN: 文件的大小（字节）。
 *     此属性是可选的，如果大小未知或尚未确定，可能为0。
 *     对于文件传输，可以在传输前设置以指示预期文件大小。
 *     对于日志获取，通常在从设备获取日志列表后设置。
 */
@property (nonatomic, assign) NSUInteger size;

/**
 * @brief Create a file model with file path
 * @chinese 使用文件路径创建文件模型
 * 
 * @param path 
 * EN: File path (local or remote)
 * CN: 文件路径（本地或远程）
 *
 * @return 
 * EN: A new file model instance
 * CN: 新的文件模型实例
 */
+ (instancetype)modelWithPath:(NSString *)path;

/**
 * @brief Create a file model with file path and size
 * @chinese 使用文件路径和大小创建文件模型
 * 
 * @param path 
 * EN: File path (local or remote)
 * CN: 文件路径（本地或远程）
 *
 * @param size 
 * EN: File size in bytes
 * CN: 文件大小（字节）
 *
 * @return 
 * EN: A new file model instance
 * CN: 新的文件模型实例
 */
+ (instancetype)modelWithPath:(NSString *)path size:(NSUInteger)size;

@end

NS_ASSUME_NONNULL_END

