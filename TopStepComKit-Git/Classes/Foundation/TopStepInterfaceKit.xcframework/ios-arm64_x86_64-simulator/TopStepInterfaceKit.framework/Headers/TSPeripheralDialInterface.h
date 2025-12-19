//
//  TSPeripheralDialInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/18.
//
//  文件说明:
//  外设表盘管理接口，定义了表盘的推送、删除、切换、查询等操作，支持云端表盘和自定义表盘的管理

/**
 * @brief Important Note About Watch Face Models
 * @chinese 表盘模型重要说明
 *
 * @discussion
 * EN: TSDialModel Inheritance Structure:
 *     TSDialModel (Base Class)
 *     ├── TSFitDialModel: For Fit series devices
 *     ├── TSFwDialModel:  For Firmware series devices
 *     └── TSSJDialModel:  For SJ series devices
 *
 *     When using this interface:
 *     1. DO NOT use TSDialModel directly
 *     2. Choose the appropriate subclass based on your device type
 *     3. Example usage:
 *        For Fit series device:
 *        TSFitDialModel *fitDial = [[TSFitDialModel alloc] init];
 *        [interface pushCloudDial:fitDial completion:...];
 *
 * CN: TSDialModel 继承结构：
 *     TSDialModel (基类)
 *     ├── TSFitDialModel: 用于 中科 系列设备
 *     ├── TSFwDialModel:  用于 恒玄 系列设备
 *     └── TSSJDialModel:  用于 伸聚 系列设备
 *
 *     使用本接口时：
 *     1. 不要直接使用 TSDialModel
 *     2. 根据设备类型选择合适的子类
 *     3. 使用示例：
 *        对于 Fit 系列设备：
 *        TSFitDialModel *fitDial = [[TSFitDialModel alloc] init];
 *        [interface pushCloudDial:fitDial completion:...];
 */

#import "TSKitBaseInterface.h"
#import "TSDialModel.h"
#import "TSFitDialModel.h"
#import "TSFwDialModel.h"
#import "TSSJDialModel.h"
#import "TSDialDefines.h"
#import "TSCustomDial.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Watch face operation completion callback
 * @chinese 表盘操作完成回调
 *
 * @param result
 * EN: Operation result
 *     - TSDialPushResultProgress: Pushing
 *     - TSDialPushResultSuccess: Push successful
 *     - TSDialPushResultFailed: Push failed
 *     - TSDialPushResultCompleted: Push completed (regardless of success or failure)
 * CN: 操作结果
 *     - TSDialPushResultProgress: 推送中
 *     - TSDialPushResultSuccess: 推送成功
 *     - TSDialPushResultFailed: 推送失败
 *     - TSDialPushResultCompleted: 推送完成（无论成功失败）
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 操作失败时的错误信息，成功时为nil
 */
typedef void (^TSDialCompletionBlock)(TSDialPushResult result, NSError *_Nullable error);

/**
 * @brief Watch face push progress callback
 * @chinese 表盘推送进度回调
 *
 * @param progress
 * EN: Current push progress (0-100)
 * CN: 当前推送进度（0-100）
 */
typedef void(^TSDialProgressBlock)(TSDialPushResult result,NSInteger progress);

/**
 * @brief Watch face list callback
 * @chinese 表盘列表回调
 *
 * @param dials
 * EN: Array of watch face models, empty array if retrieval fails
 * CN: 表盘模型数组，获取失败时为空数组
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 获取失败时的错误信息，成功时为nil
 */
typedef void (^TSDialListBlock)(NSArray<TSDialModel *> *_Nullable dials, NSError *_Nullable error);

/**
 * @brief Watch face space information callback
 * @chinese 表盘空间信息回调
 *
 * @param remainSpace
 * EN: The remain space available for watch faces (in bytes)
 * CN: 表盘剩余可用空间（字节）
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 获取失败时的错误信息，成功时为nil
 */
typedef void (^TSDialSpaceBlock)(NSInteger remainSpace, NSError *_Nullable error);

/**
 * @brief Peripheral watch face management interface
 * @chinese 外设表盘管理接口
 *
 * @discussion
 * EN: This interface defines all operations related to watch face management, including:
 *     1. Push/Delete watch faces
 *     2. Switch current watch face
 *     3. Get watch face information
 *     4. Monitor watch face changes
 *
 * CN: 该接口定义了与表盘管理相关的所有操作，包括：
 *     1. 推送/删除表盘
 *     2. 切换当前表盘
 *     3. 获取表盘信息
 *     4. 监听表盘变化
 */
@protocol TSPeripheralDialInterface <TSKitBaseInterface>

/**
 * @brief Get current watch face information
 * @chinese 获取当前表盘信息
 *
 * @param completion
 * EN: Completion callback with current watch face model
 * CN: 完成回调，返回当前表盘模型
 *
 * @discussion
 * EN: This method retrieves information about the currently active watch face.
 * CN: 此方法获取当前正在使用的表盘信息。
 */
- (void)fetchCurrentDial:(void (^)(TSDialModel *_Nullable dial,
                                 NSError *_Nullable error))completion;

/**
 * @brief Fetch all watch face information
 * @chinese 获取所有表盘信息
 *
 * @param completion
 * EN: Completion callback with array of all watch face models
 * CN: 完成回调，返回所有表盘模型数组
 *
 * @discussion
 * EN: This method retrieves information about all watch faces on the device.
 *     Including local, custom and cloud watch faces.
 * CN: 此方法获取设备上所有表盘的信息。
 *     包括本地表盘、自定义表盘和云端表盘。
 */
- (void)fetchAllDials:(TSDialListBlock)completion;

/**
 * @brief Switch current watch face
 * @chinese 切换当前表盘
 *
 * @param dialId
 * EN: Watch face identifier to switch to
 * CN: 要切换的表盘标识符
 *
 * @param completion
 * EN: Completion callback
 * CN: 完成回调
 *
 * @discussion
 * EN: This method switches the device's current watch face.
 *     The watch face must already exist on the device.
 *     The dialId parameter should be a valid watch face identifier.
 * CN: 此方法切换设备当前显示的表盘。
 *     表盘必须已经存在于设备中。
 *     dialId 参数应该是有效的表盘标识符。
 */
- (void)switchToDial:(NSString *)dialId
          completion:(nullable void(^)(BOOL success, NSError *_Nullable error))completion;

/**
 * @brief Push watch face to device by file path
 * @chinese 通过文件路径推送表盘到设备
 *
 * @param dialFilePath
 * EN: Local file path of the complete watch face file to push.
 *     The file must be a complete and valid watch face package file.
 * CN: 要推送的完整表盘文件的本地文件路径。
 *     文件必须是完整且有效的表盘包文件。
 *
 * @param progressBlock
 * EN: Progress callback, returns current push progress (0-100)
 * CN: 进度回调，返回当前推送进度（0-100）
 *
 * @param completion
 * EN: Completion callback, called multiple times during the push process:
 *     1. When push succeeds (result = Success, error = nil)
 *     2. When push fails (result = Failed, error = error info)
 *     3. When push completes (result = Completed, error = last error if failed)
 * CN: 完成回调，在推送过程中会被多次调用：
 *     1. 推送成功时（result = Success，error = nil）
 *     2. 推送失败时（result = Failed，error = 错误信息）
 *     3. 推送完成时（result = Completed，error = 失败时的最后错误）
 *
 * @discussion
 * EN: This method pushes a watch face file to the device.
 *     Important: The file at dialFilePath must be a complete and valid watch face package file.
 *     The file should contain all necessary resources and configurations for the watch face.
 *     Incomplete or corrupted files may cause push failures or device errors.
 * CN: 此方法将表盘文件推送到设备。
 *     重要：dialFilePath 指向的文件必须是完整且有效的表盘包文件。
 *     文件应包含表盘所需的所有资源和配置。
 *     不完整或损坏的文件可能导致推送失败或设备错误。
 */
- (void)pushDialWithPath:(NSString *)dialFilePath
           progressBlock:(nullable TSDialProgressBlock)progressBlock
              completion:(nullable TSDialCompletionBlock)completion;

/**
 * @brief Push custom watch face to device
 * @chinese 推送自定义表盘到外设
 *
 * @param customDial
 * EN: Custom watch face model to push
 * CN: 要推送的自定义表盘模型
 *
 * @param progressBlock
 * EN: Progress callback, returns current push progress (0-100)
 * CN: 进度回调，返回当前推送进度（0-100）
 *
 * @param completion
 * EN: Completion callback, called multiple times during the push process:
 *     1. When push succeeds (result = Success, error = nil)
 *     2. When push fails (result = Failed, error = error info)
 *     3. When push completes (result = Completed, error = last error if failed)
 * CN: 完成回调，在推送过程中会被多次调用：
 *     1. 推送成功时（result = Success，error = nil）
 *     2. 推送失败时（result = Failed，error = 错误信息）
 *     3. 推送完成时（result = Completed，error = 失败时的最后错误）
 *
 * @discussion
 * EN: This method pushes a custom watch face to the device.
 *     The watch face must be of type eDialTypeCustomer.
 *     The file at dial.filePath must exist and be valid.
 *     Progress callback will be called multiple times during the push process.
 * CN: 此方法将自定义表盘推送到设备。
 *     表盘类型必须是eDialTypeCustomer。
 *     dial.filePath指向的文件必须存在且有效。
 *     在推送过程中进度回调会被多次调用。
 */
- (void)pushCustomDial:(TSCustomDial *)customDial
         progressBlock:(nullable TSDialProgressBlock)progressBlock
            completion:(nullable TSDialCompletionBlock)completion;

/**
 * @brief Delete watch face
 * @chinese 删除表盘
 *
 * @param dialId
 * EN: Watch face identifier to delete
 * CN: 要删除的表盘标识符
 *
 * @param completion
 * EN: Completion callback
 * CN: 完成回调
 *
 * @discussion
 * EN: This method deletes a watch face from the device by its identifier.
 *     The watch face must exist on the device .
 *     Built-in watch faces cannot be deleted.
 * CN: 此方法通过标识符从设备删除表盘。
 *     表盘必须存在于设备上
 *     内置表盘不能删除。
 */
- (void)deleteCustomDial:(NSString *)dialId
              completion:(nullable void(^)(BOOL success, NSError *_Nullable error))completion;

- (void)deleteCloudDial:(NSString *)dialId
             completion:(nullable void(^)(BOOL success, NSError *_Nullable error))completion;

/**
 * @brief Fetch watch face remaining storage space
 * @chinese 获取表盘剩余存储空间
 *
 * @param completion
 * EN: Completion callback with remaining space information
 *     - totalSpace: Total storage space capacity (in bytes)
 *     - usedSpace: Used storage space (in bytes), remaining space = totalSpace - usedSpace
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调，返回剩余空间信息
 *     - totalSpace: 存储空间总容量（字节）
 *     - usedSpace: 已使用存储空间（字节），剩余空间 = totalSpace - usedSpace
 *     - error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: This method retrieves the remaining storage space for watch faces on the device.
 *     The remaining space can be calculated by (totalSpace - usedSpace).
 *     Use this method to check if there's enough space before pushing new watch faces.
 * CN: 此方法获取设备上表盘的剩余存储空间。
 *     剩余空间可以通过（totalSpace - usedSpace）计算得出。
 *     在推送新表盘前，使用此方法检查是否有足够的剩余空间。
 */
- (void)fetchWatchFaceRemainingStorageSpace:(nullable TSDialSpaceBlock)completion;

/**
 * @brief Register watch face deletion listener
 * @chinese 注册表盘被删除监听
 *
 * @param completion
 * EN: Callback when a watch face is deleted
 * CN: 表盘被删除时的回调
 *
 * @discussion
 * EN: This callback will be triggered when a watch face is deleted from the device.
 *     The callback provides information about the deleted watch face.
 * CN: 当设备中的表盘被删除时，此回调会被触发。
 *     回调提供被删除表盘的信息。
 */
- (void)registerDialDidDeletedBlock:(void (^)(TSDialModel *_Nullable dial))completion;

/**
 * @brief Register watch face change listener
 * @chinese 注册表盘改变监听
 *
 * @param completion
 * EN: Callback when the current watch face changes
 * CN: 当前表盘改变时的回调
 *
 * @discussion
 * EN: This callback will be triggered when the device's current watch face changes.
 *     The callback provides information about the new watch face.
 * CN: 当设备当前表盘发生改变时，此回调会被触发。
 *     回调提供新表盘的信息。
 */
- (void)registerDialDidChangedBlock:(void (^)(TSDialModel * _Nullable dial))completion;

/**
 * @brief Cancel ongoing watch face push operation
 * @chinese 取消正在进行的表盘推送操作
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the cancellation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调
 *     - success: 取消操作是否成功
 *     - error: 取消失败时的错误信息，成功时为nil
 */
- (void)cancelPushDial:(TSCompletionBlock)completion;

/**
 * @brief Get maximum number of built-in watch faces
 * @chinese 获取内置表盘的最大数量
 *
 * @return
 * [EN]: The maximum number of built-in watch faces supported by the device
 * [CN]: 设备支持的内置表盘最大数量
 *
 * @discussion
 * [EN]: This method returns the maximum number of built-in watch faces that can be stored on the device.
 * Built-in watch faces are pre-installed and cannot be deleted.
 * This limit varies by device model and firmware version.
 *
 * [CN]: 此方法返回设备可以存储的内置表盘最大数量。
 * 内置表盘是预装的，不能被删除。
 * 此限制因设备型号和固件版本而异。
 */
- (NSInteger)maxInnerDialCount;

/**
 * @brief Get maximum number of supported cloud watch faces
 * @chinese 获取支持的云端表盘最大数量
 *
 * @return
 * [EN]: The maximum number of cloud watch faces that can be stored on the device
 * [CN]: 设备可以存储的云端表盘最大数量
 */
- (NSInteger)maxCanPushDialCount;

/**
 * @brief Check if device supports slideshow watch face (also known as photo album watch
 * face allows displaying multiple photos on a single watch face with automatic or manual switching.)
 * @chinese 检查设备是否支持幻灯片表盘（也称为相册表盘，允许在单个表盘上显示多张照片）
 *
 * @return
 * [EN]: YES if device supports slideshow watch face, NO otherwise
 * [CN]: 如果设备支持幻灯片表盘返回 YES，否则返回 NO
 *
 * @note
 * [EN]: This feature may not be available on all device models.
 *       Check this property before implementing slideshow-related features.
 * [CN]: 此功能可能并非所有设备型号都支持。
 *       在实现幻灯片相关功能前请检查此属性。
 */
- (BOOL)isSupportSlideshowDial;

/**
 * @brief Check if device supports video watch face
 * @chinese 检查设备是否支持视频表盘
 *
 * @return
 * [EN]: YES if device supports video watch face, NO otherwise
 * [CN]: 如果设备支持视频表盘返回 YES，否则返回 NO
 *
 */
- (BOOL)isSupportVideoDial;

/**
 * @brief Get maximum video duration for video watch face
 * @chinese 获取视频表盘的最大视频时长
 *
 * @return
 * [EN]: Maximum video duration in seconds (typically 30 seconds or less).
 *       Returns 0 if device does not support video watch face.
 * [CN]: 最大视频时长（秒），通常在30秒以内。
 *       如果设备不支持视频表盘，返回0。
 *
 * @note
 * [EN]: - Returns 0 if device does not support video watch face (check with isSupportVideoDial first).
 *       - The actual maximum duration may vary slightly based on video encoding and file size.
 *       - It's recommended to keep video duration slightly below the maximum limit for better performance.
 * [CN]: - 如果设备不支持视频表盘，返回0（请先使用isSupportVideoDial检查）。
 *       - 实际最大时长可能因视频编码和文件大小而略有不同。
 *       - 建议将视频时长保持在最大限制以下，以获得更好的性能。
 */
- (NSInteger)maxVideoDialDuration;


/**
 * @brief Fetch supported widgets list from peripheral device (Fw series only)
 * @chinese 获取外设所支持的挂件列表（仅Fw系列设备有效）
 *
 * @param completion
 * EN: Completion callback with following parameters:
 *     - result: Dictionary containing widget information
 *              Key: Widget identifier
 *              Value: Widget configuration parameters
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调，包含以下参数：
 *     - result: 包含挂件信息的字典
 *              键：挂件标识符
 *              值：挂件配置参数
 *     - error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: This method retrieves the list of supported widgets from Fw series devices.
 *     Important notes:
 *     1. Only available for Fw series devices
 *     2. Returns nil for unsupported devices
 *     3. Widget information includes:
 *        - Widget type and capabilities
 *        - Supported parameters
 *        - Display position constraints
 *        - Update frequency limits
 *
 * CN: 此方法获取Fw系列设备支持的挂件列表。
 *     重要说明：
 *     1. 仅适用于Fw系列设备
 *     2. 对不支持的设备返回nil
 *     3. 挂件信息包括：
 *        - 挂件类型和功能
 *        - 支持的参数
 *        - 显示位置约束
 *        - 更新频率限制
 */
- (void)requestSupportWidgetsFromPeripheralCompletion:(void(^)(NSDictionary *_Nullable result,NSError *_Nullable error))completion;

/**
 * @brief Generate watch face preview image by compositing time image onto background image
 * @chinese 通过将时间图片合成到背景图片上生成表盘预览图
 *
 * @param originImage
 * EN: Background image for the watch face (the base image)
 * CN: 表盘的背景图片（基础图片）
 *
 * @param timeImage
 * EN: Time display image to be composited onto the background image
 * CN: 要合成到背景图片上的时间显示图片
 *
 * @param timeRect
 * EN: Rectangle area where the time image should be placed on the background image
 *     The coordinates are relative to the originImage's coordinate system
 * CN: 时间图片在背景图片上放置的矩形区域
 *     坐标相对于originImage的坐标系
 *
 * @param maxKBSize
 * EN: Maximum file size for the preview image in kilobytes (KB)
 *     The generated preview image will be compressed to meet this size limit
 * CN: 预览图的最大文件大小（单位：KB）
 *     生成的预览图将被压缩以满足此大小限制
 *
 * @param completion
 * EN: Completion callback with the following parameters:
 *     - previewImage: Generated preview image, nil if generation fails
 *     - error: Error information if generation fails, nil if successful
 * CN: 完成回调，包含以下参数：
 *     - previewImage: 生成的预览图，生成失败时为nil
 *     - error: 生成失败时的错误信息，成功时为nil
 *
 * @discussion
 * [EN]: This method generates a preview image for a watch face by:
 *       1. Compositing the time image onto the background image at the specified position (timeRect)
 *       2. Compressing the result to meet the specified maximum file size (maxKBSize)
 *       3. Returning the final preview image through the completion callback
 *       
 *       The preview image can be used for displaying watch face thumbnails in the user interface.
 *       The compression algorithm ensures the image quality while meeting the size constraint.
 *       
 *       Important notes:
 *       - Both originImage and timeImage must be valid UIImage objects
 *       - timeRect must be within the bounds of originImage
 *       - If maxKBSize is 0 or negative, the image will not be compressed
 *       - The method is asynchronous and will call the completion block on the main thread
 * [CN]: 此方法通过以下步骤生成表盘预览图：
 *       1. 将时间图片合成到背景图片的指定位置（timeRect）
 *       2. 将结果压缩以满足指定的最大文件大小（maxKBSize）
 *       3. 通过完成回调返回最终的预览图
 *       
 *       预览图可用于在用户界面中显示表盘缩略图。
 *       压缩算法在满足大小限制的同时确保图像质量。
 *       
 *       重要说明：
 *       - originImage和timeImage都必须是有效的UIImage对象
 *       - timeRect必须在originImage的边界内
 *       - 如果maxKBSize为0或负数，图片将不会被压缩
 *       - 该方法是异步的，将在主线程上调用完成回调
 */
- (void)previewImageWith:(UIImage *)originImage timeImage:(UIImage *)timeImage timeRect:(CGRect)timeRect maxKBSize:(CGFloat)maxKBSize completion:(void (^)(UIImage *_Nullable previewImage, NSError * _Nullable error))completion;


@end



NS_ASSUME_NONNULL_END
