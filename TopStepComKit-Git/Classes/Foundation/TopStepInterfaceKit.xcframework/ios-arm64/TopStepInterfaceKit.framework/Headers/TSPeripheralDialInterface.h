//
//  TSPeripheralDialInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/18.
//
//  文件说明:
//  外设表盘管理接口，定义了表盘的推送、删除、切换、查询等操作，支持云端表盘和自定义表盘的管理
//  该接口提供了完整的表盘生命周期管理功能，包括表盘信息的获取、推送、删除、切换以及变化监听等

/**
 * @brief Peripheral watch face management interface
 * @chinese 外设表盘管理接口
 *
 * @discussion
 * [EN]: This interface defines all operations related to watch face management for peripheral devices,
 *       including push, delete, switch, query, and change monitoring. It supports management of
 *       built-in watch faces, cloud watch faces, and custom watch faces.
 *
 *       Key features:
 *       1. Watch face information management: fetch current watch face, fetch all watch faces
 *       2. Watch face operations: push cloud/custom watch faces, delete watch faces, switch watch faces
 *       3. Storage management: query remaining storage space for watch faces
 *       4. Change monitoring: register callbacks to monitor watch face changes
 *       5. Device capability queries: check support for slideshow/video watch faces, get limits
 *       6. Preview generation: generate watch face preview images
 *
 * [CN]: 该接口定义了外设设备表盘管理的所有操作，包括推送、删除、切换、查询和变化监听。
 *       支持内置表盘、云端表盘和自定义表盘的管理。
 *
 *       主要功能：
 *       1. 表盘信息管理：获取当前表盘、获取所有表盘
 *       2. 表盘操作：推送云端/自定义表盘、删除表盘、切换表盘
 *       3. 存储管理：查询表盘剩余存储空间
 *       4. 变化监听：注册回调监听表盘变化
 *       5. 设备能力查询：检查是否支持幻灯片/视频表盘，获取限制信息
 *       6. 预览图生成：生成表盘预览图
 *
 * @note
 * [EN]: Important Note About Watch Face Models:
 *
 *       There are two different watch face models with different purposes:
 *
 *       1. TSDialModel - General watch face information model
 *          - Used for: Representing watch face information on the device
 *          - Used in: fetchCurrentDial, fetchAllDials, switchToDial, deleteDial, pushCloudDial
 *          - Contains: Basic information (dialId, dialName, dialType, filePath, etc.)
 *          - Example:
 *            TSDialModel *dial = [[TSDialModel alloc] init];
 *            dial.dialId = @"dial_001";
 *            dial.dialName = @"My Watch Face";
 *            dial.dialType = eTSDialTypeCloud;
 *            [interface switchToDial:dial completion:...];
 *
 *       2. TSCustomDial - Custom watch face creation model
 *          - Used for: Creating and pushing custom watch faces
 *          - Used in: pushCustomDial
 *          - Contains: Detailed resources (templateFilePath, previewImageItem, resourceItems, etc.)
 *          - Example:
 *            TSCustomDial *customDial = [[TSCustomDial alloc] init];
 *            customDial.dialId = @"custom_001";
 *            customDial.dialType = eTSCustomDialSingleImage;
 *            customDial.templateFilePath = @"/path/to/template.bin";
 *            customDial.resourceItems = @[...];
 *            [interface pushCustomDial:customDial completion:...];
 *
 *       Summary:
 *       - Use TSDialModel for device watch face information and cloud watch face operations
 *       - Use TSCustomDial for creating and pushing custom watch faces
 *
 * [CN]: 表盘模型重要说明：
 *
 *       有两种不同的表盘模型，用途不同：
 *
 *       1. TSDialModel - 通用表盘信息模型
 *          - 用途：表示设备上的表盘信息
 *          - 使用场景：fetchCurrentDial、fetchAllDials、switchToDial、deleteDial、pushCloudDial
 *          - 包含：基本信息（dialId、dialName、dialType、filePath等）
 *          - 示例：
 *            TSDialModel *dial = [[TSDialModel alloc] init];
 *            dial.dialId = @"dial_001";
 *            dial.dialName = @"我的表盘";
 *            dial.dialType = eTSDialTypeCloud;
 *            [interface switchToDial:dial completion:...];
 *
 *       2. TSCustomDial - 自定义表盘创建模型
 *          - 用途：创建和推送自定义表盘
 *          - 使用场景：pushCustomDial
 *          - 包含：详细资源信息（templateFilePath、previewImageItem、resourceItems等）
 *          - 示例：
 *            TSCustomDial *customDial = [[TSCustomDial alloc] init];
 *            customDial.dialId = @"custom_001";
 *            customDial.dialType = eTSCustomDialSingleImage;
 *            customDial.templateFilePath = @"/path/to/template.bin";
 *            customDial.resourceItems = @[...];
 *            [interface pushCustomDial:customDial completion:...];
 *
 *       总结：
 *       - 使用 TSDialModel 处理设备表盘信息和云端表盘操作
 *       - 使用 TSCustomDial 创建和推送自定义表盘
 */

#import "TSKitBaseInterface.h"
#import "TSDialModel.h"
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
 * @brief Widget list callback for Fw series devices
 * @chinese Fw系列设备挂件列表回调
 *
 * @param widgets
 * EN: Dictionary containing widget information, including background widgets and functional widgets.
 *     Returns nil if retrieval fails or device does not support widgets.
 * CN: 包含挂件信息的字典，包括背景挂件和功能挂件。
 *     获取失败或设备不支持挂件时返回nil。
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 获取失败时的错误信息，成功时为nil
 */
typedef void (^TSDialWidgetsBlock)(NSDictionary *_Nullable widgets, NSError *_Nullable error);

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
- (void)switchToDial:(TSDialModel *)dial
          completion:(nullable void(^)(BOOL isSuccess, NSError *_Nullable error))completion;

/**
 * @brief Generate custom watch face ID
 * @chinese 生成自定义表盘ID
 *
 * @param dialType
 * EN: Custom watch face type
 *     - eTSCustomDialSingleImage (1): Single image-based custom watch face
 *     - eTSCustomDialMultipleImage (2): Multiple images-based custom watch face
 *     - eTSCustomDialVideo (3): Video-based custom watch face
 * CN: 自定义表盘类型
 *     - eTSCustomDialSingleImage (1): 单图片自定义表盘
 *     - eTSCustomDialMultipleImage (2): 多图片自定义表盘
 *     - eTSCustomDialVideo (3): 视频自定义表盘
 *
 * @return
 * EN: Generated unique watch face ID string.
 * CN: 生成的唯一表盘ID字符串
 */
- (nonnull NSString *)generateCustomDialIdWithType:(TSCustomDialType)dialType;

/**
 * @brief Push cloud watch face to device
 * @chinese 推送云端表盘到外设
 *
 * @param dial
 * EN: Cloud watch face model to push. The dial must have valid dialId and dialType (should be eTSDialTypeCloud).
 *     The dialId should correspond to a watch face available in the cloud service.
 *     The filePath property may be used to specify a local cached file path if available.
 * CN: 要推送的云端表盘模型。表盘必须具有有效的dialId和dialType（应为eTSDialTypeCloud）。
 *     dialId应对应云端服务中可用的表盘。
 *     如果可用，filePath属性可用于指定本地缓存的文件路径。
 *
 * @param progressBlock
 * EN: Progress callback, called during the push process to report current progress.
 *     The callback receives:
 *     - result: Current push status (TSDialPushResultProgress, TSDialPushResultSuccess, etc.)
 *     - progress: Current push progress value (0-100)
 *     This parameter is optional and can be nil if progress updates are not needed.
 * CN: 进度回调，在推送过程中调用以报告当前进度。
 *     回调接收：
 *     - result: 当前推送状态（TSDialPushResultProgress、TSDialPushResultSuccess等）
 *     - progress: 当前推送进度值（0-100）
 *     此参数是可选的，如果不需要进度更新可以为nil。
 *
 * @param completion
 * EN: Completion callback, called multiple times during the push process:
 *     1. When push succeeds (result = TSDialPushResultSuccess, error = nil)
 *     2. When push fails (result = TSDialPushResultFailed, error = error info)
 *     3. When push completes (result = TSDialPushResultCompleted, error = last error if failed)
 *     This parameter is optional and can be nil if completion handling is not needed.
 * CN: 完成回调，在推送过程中会被多次调用：
 *     1. 推送成功时（result = TSDialPushResultSuccess，error = nil）
 *     2. 推送失败时（result = TSDialPushResultFailed，error = 错误信息）
 *     3. 推送完成时（result = TSDialPushResultCompleted，error = 失败时的最后错误）
 *     此参数是可选的，如果不需要完成处理可以为nil。
 *
 */
- (void)installDownloadedCloudDial:(TSDialModel *)dial
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
- (void)installCustomDial:(TSCustomDial *)customDial
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
- (void)deleteDial:(TSDialModel *)dial
        completion:(nullable void(^)(BOOL isSuccess, NSError *_Nullable error))completion;


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
 * @brief Register callback block for watch face change notification
 * @chinese 注册表盘变化通知回调
 *
 * @param completion
 * EN: Callback block that will be invoked when the watch face changes.
 *     The block receives an array of all watch face models currently on the device.
 *     - allDials: Array of all watch face models, nil if retrieval fails or device is disconnected
 * CN: 当表盘发生变化时将被调用的回调块。
 *     回调块接收设备上当前所有表盘模型的数组。
 *     - allDials: 所有表盘模型的数组，获取失败或设备断开连接时为nil
 *
 * @discussion
 * EN: This method registers a callback to monitor watch face changes on the device.
 *     The callback will be triggered when:
 *     1. User switches to a different watch face
 *     2. A new watch face is pushed to the device
 *     3. A watch face is deleted from the device
 *     4. Device reports watch face changes through notifications
 *
 *     Important notes:
 *     - The callback is executed on the main thread
 *     - Only one callback can be registered at a time (new registration replaces the previous one)
 *     - The callback may be called multiple times during the device connection lifecycle
 *     - If allDials is nil, it indicates that the watch face information could not be retrieved
 *
 * CN: 此方法注册一个回调来监听设备上的表盘变化。
 *     回调将在以下情况触发：
 *     1. 用户切换到不同的表盘
 *     2. 新表盘被推送到设备
 *     3. 表盘从设备上被删除
 *     4. 设备通过通知报告表盘变化
 *
 *     重要说明：
 *     - 回调在主线程上执行
 *     - 同时只能注册一个回调（新的注册会替换之前的回调）
 *     - 在设备连接生命周期内，回调可能被多次调用
 *     - 如果allDials为nil，表示无法获取表盘信息
 */
- (void)registerDialDidChangedBlock:(void (^)(NSArray<TSDialModel *> *_Nullable allDials))completion;

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
 *     - widgets: Array of widget information dictionaries
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调，包含以下参数：
 *     - widgets: 挂件信息字典数组
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
- (void)requestSupportWidgetsFromPeripheralCompletion:(TSDialWidgetsBlock)completion;

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
 * @param timePosition
 * EN: Position where the time image should be placed on the background image
 * CN: 时间图片在背景图片上放置的位置
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
 */
- (void)previewImageWith:(UIImage *)originImage timeImage:(UIImage *)timeImage timePosition:(TSDialTimePosition)timePosition maxKBSize:(CGFloat)maxKBSize completion:(void (^)(UIImage *_Nullable previewImage, NSError * _Nullable error))completion;


@end



NS_ASSUME_NONNULL_END
