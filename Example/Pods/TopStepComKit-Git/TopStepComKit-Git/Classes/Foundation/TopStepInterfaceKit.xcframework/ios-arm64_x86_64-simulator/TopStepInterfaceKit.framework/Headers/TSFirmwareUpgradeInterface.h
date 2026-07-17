//
//  TSFirmwareUpgradeInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/27.
//

#import "TSKitBaseInterface.h"
#import "TSFileTransferModel.h"
#import "TSFileTransferDefines.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Firmware Upgrade interface protocol
 * @chinese 固件升级接口协议
 *
 * @discussion
 * EN: This protocol defines all operations related to firmware upgrade, including:
 *     1. Check upgrade conditions
 *     2. Start firmware upgrade
 *     3. Cancel firmware upgrade
 * CN: 该协议定义了与固件升级相关的所有操作，包括：
 *     1. 检查升级条件
 *     2. 开始固件升级
 *     3. 取消固件升级
 */
@protocol TSFirmwareUpgradeInterface <TSKitBaseInterface>

/**
 * @brief Check if device can be upgraded
 * @chinese 检查设备是否可以升级
 *
 * @param model
 * EN: Firmware upgrade model containing upgrade information
 * CN: 包含升级信息的固件升级模型
 *
 * @param completion
 * EN: Completion callback
 *     - canUpgrade: Whether the device can be upgraded
 *     - error: Error information if check fails
 * CN: 检查完成的回调
 *     - canUpgrade: 设备是否可以升级
 *     - error: 检查失败时的错误信息
 *
 * @discussion
 * EN: This method checks various conditions before starting firmware upgrade:
 *     1. Device battery level
 *     2. Firmware file validity
 *     3. Version compatibility
 *     4. Device connection status
 *     5. Device upgrade status
 * CN: 此方法在开始固件升级前检查各种条件：
 *     1. 设备电量
 *     2. 固件文件有效性
 *     3. 版本兼容性
 *     4. 设备连接状态
 *     5. 设备升级状态
 */
- (void)checkFirmwareUpgradeConditions:(TSFileTransferModel *)model completion:(void (^)(BOOL canUpgrade, NSError * _Nullable error))completion;

/**
 * @brief Start firmware upgrade
 * @chinese 开始固件升级
 *
 * @param model
 * EN: Firmware upgrade model containing upgrade information
 * CN: 包含升级信息的固件升级模型
 *
 * @param progress
 * EN: Progress callback, returns current upgrade progress (0-100), called multiple times during the upgrade process
 * CN: 进度回调，返回当前升级进度（0-100），在升级过程中会被多次调用
 *
 * @param success
 * EN: Success callback, called when upgrade completes successfully
 * CN: 成功回调，当升级成功完成时调用
 *
 * @param failure
 * EN: Failure callback, called when upgrade fails or is canceled
 * CN: 失败回调，当升级失败或被取消时调用
 *
 * @discussion
 * EN: This method starts the firmware upgrade process. The progress callback will be called
 *     multiple times during the upgrade to report current progress. The success callback
 *     will be called once when upgrade completes successfully, and the failure callback
 *     will be called if upgrade fails or is canceled.
 * CN: 此方法开始固件升级过程。进度回调在升级过程中会被多次调用来报告当前进度。
 *     成功回调在升级成功完成时会被调用一次，失败回调在升级失败或被取消时会被调用。
 *
 * @note
 * EN: 1. Do not disconnect the device during upgrade
 *     2. Keep the App in foreground during upgrade
 *     3. Keep the device battery level above 30%
 *     4. Do not power off the device during upgrade
 * CN: 1. 升级过程中请勿断开设备连接
 *     2. 升级过程中请保持App在前台运行
 *     3. 升级前请确保设备电量在30%以上
 *     4. 升级过程中请勿关闭设备电源
 */
- (void)startFirmwareUpgrade:(TSFileTransferModel *)model
                     progress:(nullable TSFileTransferProgressBlock)progress
                      success:(nullable TSFileTransferSuccessBlock)success
                      failure:(nullable TSFileTransferFailureBlock)failure;

/**
 * @brief Cancel firmware upgrade
 * @chinese 取消固件升级
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the cancellation was successful
 *     - error: Error information if cancellation failed
 * CN: 完成回调
 *     - success: 取消是否成功
 *     - error: 取消失败时的错误信息
 *
 * @discussion
 * EN: This method will cancel the current firmware upgrade process.
 *     The device will remain in its current state and the upgrade will be aborted.
 *     This operation cannot be undone once completed.
 *     Note: Canceling during critical upgrade phases may leave the device in an unstable state.
 * CN: 此方法将取消当前的固件升级过程。
 *     设备将保持在当前状态，升级将被中止。
 *     此操作一旦完成将无法撤销。
 *     注意：在关键升级阶段取消可能会使设备处于不稳定状态。
 */
- (void)cancelFirmwareUpgrade:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
