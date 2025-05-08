//
//  TSFileOTAInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import "TSKitBaseInterface.h"
#import "TSFileOTAModel.h"

NS_ASSUME_NONNULL_BEGIN



/**
 * @brief File OTA result type
 * @chinese 文件OTA结果类型
 */
typedef NS_ENUM(NSInteger, TSFileOTAResult) {
    // 升级中
    TSFileOTAResultProgress = 0,
    /// 升级成功
    TSFileOTAResultSuccess ,
    /// 升级失败
    TSFileOTAResultFailed,
    /// 升级完成（无论成功失败）
    TSFileOTAResultCompleted
};

/**
 * @brief File OTA progress callback
 * @chinese 文件OTA进度回调
 * @param result
 * EN: Operation result
 *     - TSFileOTAResultProgress:Upgrading
 *     - TSFileOTAResultSuccess: Upgrade successful
 *     - TSFileOTAResultFailed: Upgrade failed
 *     - TSFileOTAResultCompleted: Upgrade completed (regardless of success or failure)
 * CN: 操作结果
 *     -TSFileOTAResultProgress:升级中
 *     - TSFileOTAResultSuccess: 升级成功
 *     - TSFileOTAResultFailed: 升级失败
 *     - TSFileOTAResultCompleted: 升级完成（无论成功失败）
 *
 * @param progress
 * EN: Current upgrade progress (0-100)
 * CN: 当前升级进度（0-100）
 */
typedef void(^TSFileOTAProgressBlock)(TSFileOTAResult result, NSInteger progress);

/**
 * @brief File OTA completion callback
 * @chinese 文件OTA完成回调
 * 
 * @param result 
 * EN: Operation result
 *     - TSFileOTAResultProgress:Upgrading
 *     - TSFileOTAResultSuccess: Upgrade successful
 *     - TSFileOTAResultFailed: Upgrade failed
 *     - TSFileOTAResultCompleted: Upgrade completed (regardless of success or failure)
 * CN: 操作结果
 *     -TSFileOTAResultProgress:升级中
 *     - TSFileOTAResultSuccess: 升级成功
 *     - TSFileOTAResultFailed: 升级失败
 *     - TSFileOTAResultCompleted: 升级完成（无论成功失败）
 * 
 * @param error 
 * EN: Error information if failed, nil if successful
 * CN: 操作失败时的错误信息，成功时为nil
 * 
 * @discussion
 * EN: The completion callback will be called multiple times:
 *     1. When upgrade succeeds (result = Success, error = nil)
 *     2. When upgrade fails (result = Failed, error = error info)
 *     3. When upgrade completes (result = Completed, error = last error if failed)
 * CN: 完成回调会被多次调用：
 *     1. 升级成功时（result = Success，error = nil）
 *     2. 升级失败时（result = Failed，error = 错误信息）
 *     3. 升级完成时（result = Completed，error = 失败时的最后错误）
 */
typedef void(^TSFileOTACompletionBlock)(TSFileOTAResult result, NSError * _Nullable error);

/**
 * @brief File OTA interface protocol
 * @chinese 文件OTA接口协议
 * 
 * @discussion 
 * EN: This protocol defines all operations related to file OTA upgrade, including:
 *     1. Start file upload
 *     2. Stop file upload
 *     3. Query current firmware version
 * CN: 该协议定义了与文件OTA升级相关的所有操作，包括：
 *     1. 开始文件上传
 *     2. 停止文件上传
 *     3. 查询当前固件版本
 */
@protocol TSFileOTAInterface <TSKitBaseInterface>

/**
 * @brief Check if device can be upgraded
 * @chinese 检查设备是否可以升级
 *
 * @param completion
 * EN: Completion callback
 *     - canUpgrade: Whether the device can be upgraded
 * CN: 检查完成的回调
 *     - canUpgrade: 设备是否可以升级
 *
 * @discussion 
 * EN: This method checks various conditions before starting OTA upgrade:
 *     1. Device battery level
 *     2. File validity
 *     3. Version compatibility
 *     4. Device connection status
 *     5. Device upgrade status
 * CN: 此方法在开始OTA升级前检查各种条件：
 *     1. 设备电量
 *     2. 文件有效性
 *     3. 版本兼容性
 *     4. 设备连接状态
 *     5. 设备升级状态
 */
- (void)checkCanUpgrade:(TSFileOTAModel *)model completion:(void (^)(BOOL, NSError * _Nullable))completion;

/**
 * @brief Start file OTA upgrade
 * @chinese 开始文件OTA升级
 * 
 * @param model 
 * EN: File OTA model containing upgrade information
 * CN: 包含升级信息的文件OTA模型
 * 
 * @param progressBlock
 * EN: Progress callback, returns current upgrade progress (0-100)，called multiple times during the upgrade process
 * CN: 进度回调，返回当前升级进度（0-100），在升级过程中会被多次调用
 * 
 * @param completion 
 * EN: Completion callback, called multiple times during the upgrade process
 * CN: 完成回调，在升级过程中会被多次调用
 * 
 * @discussion 
 * EN: This method will handle the entire file upload process, including:
 *     1. Verify file
 *     2. Upload file
 *     3. Install firmware
 * CN: 此方法将处理整个文件上传过程，包括：
 *     1. 验证文件
 *     2. 上传文件
 *     3. 安装固件
 * 
 * @note 
 * EN: 1. Do not disconnect the device during upgrade
 *     2. Keep the App in foreground during upgrade
 *     3. Keep the device battery level above 30%
 * CN: 1. 升级过程中请勿断开设备连接
 *     2. 升级过程中请保持App在前台运行
 *     3. 升级前请确保设备电量在30%以上
 */
- (void)startFileOTAUpgrade:(TSFileOTAModel *)model
                progressBlock:(nullable TSFileOTAProgressBlock)progressBlock
                completion:(nullable TSFileOTACompletionBlock)completion;

/**
 * @brief Stop file OTA upgrade
 * @chinese 停止文件OTA升级
 * 
 * @discussion 
 * EN: This method will stop the current file upload process.
 *     The device will remain in its current state.
 * CN: 此方法将停止当前的文件上传过程。
 *     设备将保持在当前状态。
 */
- (void)stopFileOTAUpgrade:(TSCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END
