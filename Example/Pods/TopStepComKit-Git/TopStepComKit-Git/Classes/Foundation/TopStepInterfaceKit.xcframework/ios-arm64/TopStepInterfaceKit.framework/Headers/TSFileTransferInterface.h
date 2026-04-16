//
//  TSFileTransferInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import "TSKitBaseInterface.h"
#import "TSFileTransferModel.h"

NS_ASSUME_NONNULL_BEGIN



/**
 * @brief File Transfer state type
 * @chinese 文件Transfer状态类型
 */
typedef NS_ENUM(NSInteger, TSFileTransferState) {
    eTSFileTransferStateIdle          = 0,  // 空闲/待机状态
    eTSFileTransferStateStart         = 1,  // 开始升级
    eTSFileTransferStateProgress      = 2,  // 升级中
    eTSFileTransferStateSuccess       = 3,  // 升级成功
    eTSFileTransferStateFailed        = 4,  // 升级失败
    eTSFileTransferStateCanceled      = 5,  // 升级取消
};

/**
 * @brief File Transfer progress callback
 * @chinese 文件Transfer进度回调
 * @param state
 * EN: Operation state
 *     - eTSFileTransferStateStart: Starting
 *     - eTSFileTransferStateProgress: Upgrading
 * CN: 操作状态
 *     - eTSFileTransferStateStart: 开始
 *     - eTSFileTransferStateProgress: 传输中
 *
 * @param progress
 * EN: Current upgrade progress (0-100)
 * CN: 当前升级进度（0-100）
 */
typedef void(^TSFileTransferProgressBlock)(TSFileTransferState state, NSInteger progress);

/**
 * @brief File Transfer success callback
 * @chinese 文件Transfer成功回调
 *
 * @param state
 * EN: Operation state when success occurs
 *     - eTSFileTransferStateSuccess: Upgrade completed successfully
 * CN: 成功时的操作状态
 *     - eTSFileTransferStateSuccess: 升级成功完成
 *
 * @discussion
 * EN: This callback is called when the firmware upgrade completes successfully.
 *     The upgrade process has finished and the device is ready for use.
 * CN: 当固件升级成功完成时调用此回调。
 *     升级过程已结束，设备可以正常使用。
 */
typedef void(^TSFileTransferSuccessBlock)(TSFileTransferState state);

/**
 * @brief File Transfer failure callback
 * @chinese 文件Transfer失败回调
 *
 * @param state
 * EN: Operation state when failure occurs
 *     - eTSFileTransferStateFailed: Upgrade failed
 *     - eTSFileTransferStateCanceled: Upgrade was canceled
 * CN: 失败时的操作状态
 *     - eTSFileTransferStateFailed: 升级失败
 *     - eTSFileTransferStateCanceled: 升级被取消
 *
 * @param error
 * EN: Error information describing the failure reason, nil if canceled
 * CN: 描述失败原因的错误信息，如果是取消操作则为nil
 *
 * @discussion
 * EN: This callback is called when the firmware upgrade fails or is canceled.
 *     The upgrade process has stopped and the device remains in its previous state.
 * CN: 当固件升级失败或被取消时调用此回调。
 *     升级过程已停止，设备保持在之前的状态。
 */
typedef void(^TSFileTransferFailureBlock)(TSFileTransferState state, NSError * _Nullable error);


/**
 * @brief File Transfer interface protocol
 * @chinese 文件Transfer接口协议
 *
 * @discussion
 * EN: This protocol defines all operations related to file Transfer upgrade, including:
 *     1. Start file upload
 *     2. Stop file upload
 *     3. Query current firmware version
 * CN: 该协议定义了与文件Transfer升级相关的所有操作，包括：
 *     1. 开始文件上传
 *     2. 停止文件上传
 *     3. 查询当前固件版本
 */
@protocol TSFileTransferInterface <TSKitBaseInterface>

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
 * EN: This method checks various conditions before starting Transfer upgrade:
 *     1. Device battery level
 *     2. File validity
 *     3. Version compatibility
 *     4. Device connection status
 *     5. Device upgrade status
 * CN: 此方法在开始Transfer升级前检查各种条件：
 *     1. 设备电量
 *     2. 文件有效性
 *     3. 版本兼容性
 *     4. 设备连接状态
 *     5. 设备升级状态
 */
- (void)checkFileTransferConditions:(TSFileTransferModel *)model completion:(void (^)(BOOL, NSError * _Nullable))completion;

/**
 * @brief Start firmware upgrade
 * @chinese 开始固件升级
 *
 * @param model
 * EN: File Transfer model containing upgrade information
 * CN: 包含升级信息的文件Transfer模型
 *
 * @param progress
 * EN: Progress callback, returns current upgrade progress (0-100)，called multiple times during the upgrade process
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
 * CN: 1. 升级过程中请勿断开设备连接
 *     2. 升级过程中请保持App在前台运行
 *     3. 升级前请确保设备电量在30%以上
 */
- (void)startFileTransfer:(TSFileTransferModel *)model
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
 * CN: 此方法将取消当前的固件升级过程。
 *     设备将保持在当前状态，升级将被中止。
 *     此操作一旦完成将无法撤销。
 */
- (void)cancelFileTransfer:(TSCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END
