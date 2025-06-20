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


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Watch face push result type
 * @chinese 表盘推送结果类型
 */
typedef NS_ENUM(NSInteger, TSDialPushResult) {
    /// 推送中
    eTSDialPushResultProgress = 0,
    /// 推送成功
    eTSDialPushResultSuccess,
    /// 推送失败
    eTSDialPushResultFailed,
    /// 安装中
    eTSDialPushResultOnInstalling,
    /// 安装成功
    eTSDialPushResultOnInstallSuccess,
    /// 安装失败
    eTSDialPushResultOnInstallFailed,
    /// 推送完成（无论成功失败）
    eTSDialPushResultCompleted
};

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
 * @brief Push cloud watch face to device
 * @chinese 推送云端表盘到外设
 *
 * @param dial
 * EN: Cloud watch face model to push
 * CN: 要推送的云端表盘模型
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
 * EN: This method pushes a cloud watch face to the device.
 *     The watch face must be of type eDialTypeCloud.
 *     The file at dial.filePath must exist and be valid.
 *     Progress callback will be called multiple times during the push process.
 * CN: 此方法将云端表盘推送到设备。
 *     表盘类型必须是eDialTypeCloud。
 *     dial.filePath指向的文件必须存在且有效。
 *     在推送过程中进度回调会被多次调用。
 */
- (void)pushCloudDial:(TSDialModel *)dial
        progressBlock:(nullable TSDialProgressBlock)progressBlock
           completion:(nullable TSDialCompletionBlock)completion;

/**
 * @brief Push custom watch face to device
 * @chinese 推送自定义表盘到外设
 *
 * @param dial
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
- (void)pushCustomDial:(TSDialModel *)dial
         progressBlock:(nullable TSDialProgressBlock)progressBlock
            completion:(nullable TSDialCompletionBlock)completion;

/**
 * @brief Delete cloud watch face
 * @chinese 删除云端表盘
 *
 * @param dial
 * EN: Cloud watch face model to delete
 * CN: 要删除的云端表盘模型
 *
 * @param completion
 * EN: Completion callback
 * CN: 完成回调
 *
 * @discussion
 * EN: This method deletes a cloud watch face from the device.
 *     The watch face must be of type eDialTypeCloud.
 * CN: 此方法从设备删除云端表盘。
 *     表盘类型必须是eDialTypeCloud。
 */
- (void)deleteCloudDial:(TSDialModel *)dial
             completion:(nullable void(^)(BOOL success, NSError *_Nullable error))completion;

/**
 * @brief Delete custom watch face
 * @chinese 删除自定义表盘
 *
 * @param dial
 * EN: Custom watch face model to delete
 * CN: 要删除的自定义表盘模型
 *
 * @param completion
 * EN: Completion callback
 * CN: 完成回调
 *
 * @discussion
 * EN: This method deletes a custom watch face from the device.
 *     The watch face must be of type eDialTypeCustomer.
 * CN: 此方法从设备删除自定义表盘。
 *     表盘类型必须是eDialTypeCustomer。
 */
- (void)deleteCustomDial:(TSDialModel *)dial
              completion:(nullable void(^)(BOOL success, NSError *_Nullable error))completion;

/**
 * @brief Switch current watch face
 * @chinese 切换当前表盘
 *
 * @param dial
 * EN: Watch face model to switch to
 * CN: 要切换的表盘模型
 *
 * @param completion
 * EN: Completion callback
 * CN: 完成回调
 *
 * @discussion
 * EN: This method switches the device's current watch face.
 *     The watch face must already exist on the device.
 * CN: 此方法切换设备当前显示的表盘。
 *     表盘必须已经存在于设备中。
 */
- (void)switchToDial:(TSDialModel *)dial
          completion:(nullable void(^)(BOOL success, NSError *_Nullable error))completion;

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
- (void)getCurrentDial:(void (^)(TSDialModel *_Nullable dial,
                                 NSError *_Nullable error))completion;

/**
 * @brief Get all watch face information
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
- (void)getAllDials:(TSDialListBlock)completion;

/**
 * @brief Get watch face remaining storage space
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
- (void)getWatchFaceRemainingStorageSpaceWithCompletion:(nullable TSDialSpaceBlock)completion;

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
 * @param dial
 * EN: Watch face model being pushed that needs to be cancelled
 * CN: 需要取消推送的表盘模型
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the cancellation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调
 *     - success: 取消操作是否成功
 *     - error: 取消失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: This method cancels an ongoing watch face push operation.
 *     Features:
 *     1. Only affects the specified watch face
 *     2. Can be called at any time during push
 *     3. Will clean up any temporary files
 *     4. May take a moment to complete cancellation
 *
 * CN: 此方法取消正在进行的表盘推送操作。
 *     特点：
 *     1. 只影响指定的表盘
 *     2. 可以在推送过程中任何时候调用
 *     3. 会清理所有临时文件
 *     4. 取消操作可能需要一定时间完成
 */
- (void)cancelPushDial:(TSDialModel *)dial completion:(TSCompletionBlock)completion;

/**
 * @brief Get supported widgets list from peripheral device (Fw series only)
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
 *
 * @discussion
 * [EN]: This method returns the maximum number of cloud watch faces that can be stored on the device.
 * Cloud watch faces can be downloaded and installed from the cloud server.
 * This limit is determined by:
 * 1. Device storage capacity
 * 2. Device model specifications
 * 3. Firmware version
 * Use this value to manage cloud watch face installations and prevent exceeding device limits.
 *
 * [CN]: 此方法返回设备可以存储的云端表盘最大数量。
 * 云端表盘可以从云服务器下载并安装。
 * 此限制取决于：
 * 1. 设备存储容量
 * 2. 设备型号规格
 * 3. 固件版本
 * 使用此值来管理云端表盘安装，防止超出设备限制。
 */
- (NSInteger)supportMaxCloudDial;



@end



NS_ASSUME_NONNULL_END
