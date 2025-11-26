//
//  TSMetaFileSender.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/10.
//

#import "TSBusinessBase.h"
#import "TSFileTransferDefines.h"
#import "PbStreamParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief File sender for sending files to device
 * @chinese 文件发送器，用于向设备发送文件
 *
 * @discussion
 * [EN]: TSMetaFileSender is a singleton class responsible for sending files to the device.
 *       It handles file header transmission, data frame slicing, progress tracking,
 *       error handling and retry mechanism.
 * [CN]: TSMetaFileSender 是一个单例类，负责向设备发送文件。
 *       它处理文件头传输、数据帧切片、进度跟踪、错误处理和重试机制。
 */
@interface TSMetaFileSender : TSBusinessBase

/**
 * @brief Current file transfer status
 * @chinese 当前文件传输状态
 *
 * @discussion
 * [EN]: Represents the current state of file transfer operation.
 *       Possible values: Idle, Start, InProgress, Success, Failed, Canceled
 * [CN]: 表示当前文件传输操作的状态。
 *       可能的值：空闲、开始、进行中、成功、失败、已取消
 */
@property (nonatomic, assign) TSFileTransferStatus state;

/**
 * @brief Retry count for failed data frame transmission
 * @chinese 数据帧传输失败的重试次数
 *
 * @discussion
 * [EN]: Tracks the number of retry attempts for current data frame.
 *       Maximum retry count is defined by kMaxFileFrameRetryCount.
 * [CN]: 跟踪当前数据帧的重试次数。
 *       最大重试次数由 kMaxFileFrameRetryCount 定义。
 */
@property (nonatomic, assign) NSInteger retryCount;

/**
 * @brief Progress callback block
 * @chinese 进度回调块
 *
 * @discussion
 * [EN]: Called multiple times during file transfer to report progress (0.0 - 1.0).
 *       Parameters: transfer status and progress percentage.
 * [CN]: 在文件传输过程中多次调用以报告进度（0.0 - 1.0）。
 *       参数：传输状态和进度百分比。
 */
@property (nonatomic, copy, nullable) TSFileTransferProgressCallback progressBlock;

/**
 * @brief Success callback block
 * @chinese 成功回调块
 *
 * @discussion
 * [EN]: Called once when file transfer completes successfully.
 *       Parameter: final transfer status (Success).
 * [CN]: 文件传输成功完成时调用一次。
 *       参数：最终传输状态（成功）。
 */
@property (nonatomic, copy, nullable) TSSendFileSuccessCallback transferSuccessBlock;

/**
 * @brief Failure callback block
 * @chinese 失败回调块
 *
 * @discussion
 * [EN]: Called when file transfer fails or is canceled.
 *       Parameters: transfer status (Failed/Canceled) and error information.
 * [CN]: 文件传输失败或被取消时调用。
 *       参数：传输状态（失败/已取消）和错误信息。
 */
@property (nonatomic, copy, nullable) TSSendFileFailureCallback transferFailureBlock;

/**
 * @brief Get shared instance of file sender
 * @chinese 获取文件发送器的共享实例
 *
 * @return Singleton instance of TSMetaFileSender
 * @chinese 返回 TSMetaFileSender 的单例实例
 *
 * @discussion
 * [EN]: Returns the singleton instance. Only one file transfer operation
 *       can be active at a time.
 * [CN]: 返回单例实例。同一时间只能有一个文件传输操作处于活跃状态。
 */
+ (instancetype)sharedInstance ;

/**
 * @brief Start sending file to device
 * @chinese 开始向设备发送文件
 *
 * @param filePath
 * EN: Local file path to send
 * CN: 要发送的本地文件路径
 *
 * @param toPath
 * EN: Target path on device to save the file
 * CN: 设备端保存文件的目标路径
 *
 * @param progress
 * EN: Transfer progress callback (0.0 - 1.0), called multiple times during transfer
 * CN: 传输进度回调（0.0 - 1.0），在传输过程中会被多次调用
 *
 * @param success
 * EN: Success callback, called when file transfer completes successfully
 * CN: 成功回调，当文件传输成功完成时调用
 *
 * @param failure
 * EN: Failure callback, called when file transfer fails
 * CN: 失败回调，当文件传输失败时调用
 *
 * @discussion
 * [EN]: This method starts sending a local file to the device. The process includes:
 *       1. Reading local file data and calculating CRC32
 *       2. Sending file header to device
 *       3. Slicing file data into frames based on device's package size
 *       4. Sending data frames with progress tracking
 *       5. Handling device responses and retrying failed frames
 *       6. Sending completion signal when all data is sent
 * [CN]: 此方法开始向设备发送本地文件。过程包括：
 *       1. 读取本地文件数据并计算 CRC32
 *       2. 向设备发送文件头
 *       3. 根据设备的包大小将文件数据切片为帧
 *       4. 发送数据帧并跟踪进度
 *       5. 处理设备响应并重试失败的帧
 *       6. 所有数据发送完成后发送完成信号
 *
 * @note
 * EN: Ensure no other file transfer is in progress before calling this method
 * CN: 调用此方法前请确保没有其他文件传输正在进行
 */
- (void)startSendFileWithLocalPath:(NSString *)filePath
                            toPath:(NSString *)toPath
                          progress:(TSFileTransferProgressCallback _Nullable)progress
                           success:(TSSendFileSuccessCallback)success
                           failure:(TSSendFileFailureCallback)failure;

/**
 * @brief Cancel current file sending operation
 * @chinese 取消当前文件发送操作
 *
 * @discussion
 * [EN]: Cancels the ongoing file transfer operation.
 *       Sets transfer state to Canceled.
 * [CN]: 取消正在进行的文件传输操作。
 *       将传输状态设置为已取消。
 *
 * @note
 * EN: This only changes the local state. To notify device, use TSMetaFileTransfer cancelFileTransferWithCompletion:
 * CN: 这只会改变本地状态。要通知设备，请使用 TSMetaFileTransfer cancelFileTransferWithCompletion:
 */
- (void)cancel;

/**
 * @brief Reset sender to idle state
 * @chinese 重置发送器到空闲状态
 *
 * @discussion
 * [EN]: Resets the sender to idle state and clears all callback blocks.
 *       Call this method after transfer completes or fails to prepare for next transfer.
 * [CN]: 将发送器重置为空闲状态并清除所有回调块。
 *       在传输完成或失败后调用此方法以准备下一次传输。
 */
- (void)resetToIdle;

/**
 * @brief Check if file transfer is in progress
 * @chinese 检查文件传输是否正在进行
 *
 * @return
 * EN: YES if transfer is in Start or InProgress state, NO otherwise
 * CN: 如果传输处于开始或进行中状态返回 YES，否则返回 NO
 *
 * @discussion
 * [EN]: Use this method to check if sender is busy before starting a new transfer.
 * [CN]: 在开始新传输之前使用此方法检查发送器是否忙碌。
 */
- (BOOL)isTransfering;



@end

NS_ASSUME_NONNULL_END
