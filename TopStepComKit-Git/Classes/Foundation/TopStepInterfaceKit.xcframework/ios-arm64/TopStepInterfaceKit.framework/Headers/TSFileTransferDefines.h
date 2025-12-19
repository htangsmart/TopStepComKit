//
//  TSFileTransferDefines.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief File Transfer state type
 * @chinese 文件传输状态类型
 */
typedef NS_ENUM(NSInteger, TSFileTransferStatus) {
    eTSFileTransferStatusIdle          = 0,  // 空闲/待机状态
    eTSFileTransferStatusStart         = 1,  // 开始传输
    eTSFileTransferStatusProgress      = 2,  // 传输中
    eTSFileTransferStatusSuccess       = 3,  // 传输成功
    eTSFileTransferStatusFailed        = 4,  // 传输失败
    eTSFileTransferStatusCanceled      = 5,  // 传输取消
};

/**
 * @brief File Transfer progress callback
 * @chinese 文件传输进度回调
 * @param state
 * EN: Operation state
 *     - eTSFileTransferStatusStart: Starting
 *     - eTSFileTransferStatusProgress: Transferring
 * CN: 操作状态
 *     - eTSFileTransferStatusStart: 开始
 *     - eTSFileTransferStatusProgress: 传输中
 *
 * @param progress
 * EN: Current transfer progress (0-100)
 * CN: 当前传输进度（0-100）
 */
typedef void(^TSFileTransferProgressBlock)(TSFileTransferStatus state, NSInteger progress);

/**
 * @brief File Transfer success callback
 * @chinese 文件传输成功回调
 *
 * @param state
 * EN: Operation state when success occurs
 *     - eTSFileTransferStatusSuccess: Transfer completed successfully
 * CN: 成功时的操作状态
 *     - eTSFileTransferStatusSuccess: 传输成功完成
 *
 * @discussion
 * EN: This callback is called when the file transfer completes successfully.
 *     The transfer process has finished.
 *     For single file transfers, filePath contains the local path of the transferred file.
 *     For batch operations, filePath may be nil.
 * CN: 当文件传输成功完成时调用此回调。
 *     传输过程已结束。
 *     对于单个文件传输，filePath 包含传输文件的本地路径。
 *     对于批量操作，filePath 可能为 nil。
 */
typedef void(^TSFileTransferSuccessBlock)(TSFileTransferStatus state);

/**
 * @brief File Transfer failure callback
 * @chinese 文件传输失败回调
 *
 * @param state
 * EN: Operation state when failure occurs
 *     - eTSFileTransferStatusFailed: Transfer failed
 *     - eTSFileTransferStatusCanceled: Transfer was canceled
 * CN: 失败时的操作状态
 *     - eTSFileTransferStatusFailed: 传输失败
 *     - eTSFileTransferStatusCanceled: 传输被取消
 *
 * @param error
 * EN: Error information describing the failure reason, nil if canceled
 * CN: 描述失败原因的错误信息，如果是取消操作则为nil
 *
 * @discussion
 * EN: This callback is called when the file transfer fails or is canceled.
 *     The transfer process has stopped.
 * CN: 当文件传输失败或被取消时调用此回调。
 *     传输过程已停止。
 */
typedef void(^TSFileTransferFailureBlock)(TSFileTransferStatus state, NSError * _Nullable error);

NS_ASSUME_NONNULL_END
