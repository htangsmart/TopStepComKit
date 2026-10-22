//
//  TSMetaFileTransfer.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/30.
//

#import "TSBusinessBase.h"
#import "PbStreamParam.pbobjc.h"
#import <TopStepBleMetaKit/TSFileTransferDefines.h>

NS_ASSUME_NONNULL_BEGIN


@interface TSMetaFileTransfer : TSBusinessBase


+ (void)checkIfCanSendFileWithPath:(NSString *)filePath
                            folder:(NSString *)folder
                        completion:(void (^)(BOOL isScuccess, NSError * _Nullable error))completion;

/**
 * @brief Start fetch file data from device (Facade API)
 * @chinese 开始从设备接收文件数据（外观层接口）
 *
 * @param filePath
 * EN: The TSMetaFilePath on device to receive
 * CN: 设备端目标文件路径
 *
 * @param progress
 * EN: Transfer progress callback (0.0 - 100.0), called multiple times during transfer
 * CN: 传输进度回调（0.0 - 100.0），在传输过程中会被多次调用
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
 * EN: This method starts receiving a file from the device. The progress callback will be
 *     called multiple times during the transfer to report current progress. The success
 *     callback will be called once when transfer completes successfully, and the failure
 *     callback will be called if transfer fails.
 * CN: 此方法开始从设备接收文件。进度回调在传输过程中会被多次调用来报告当前进度。
 *     成功回调在传输成功完成时会被调用一次，失败回调在传输失败时会被调用。
 *
 * @note
 * EN: Only one file transfer operation can be active at a time
 * CN: 同时只能有一个文件传输操作处于活跃状态
 */
+ (void)fetchFileWithPath:(TSMetaFilePath *)filePath
                 progress:(TSFileTransferProgressCallback _Nullable)progress
                  success:(TSReceiveFileSuccessCallback)success
                  failure:(TSReceiveFileFailureCallback)failure;


/**
 * @brief Start send file to device (Facade API)
 * @chinese 开始向设备发送文件（外观层接口）
 *
 * @param filePath
 * EN: Local file path to send
 * CN: 要发送的本地文件路径
 *
 * @param remoteFolder
 * EN: Target folder on device (e.g. "music", "dials_push", "ota")
 * CN: 设备端目标文件夹（如 "music"、"dials_push"、"ota"）
 *
 * @param fileName
 * EN: Target file name on device (e.g. "song.mp3", "12345.tar")
 * CN: 设备端目标文件名（如 "song.mp3"、"12345.tar"）
 *
 * @param progress
 * EN: Transfer progress callback (0.0 - 100.0), called multiple times during transfer
 * CN: 传输进度回调（0.0 - 100.0），在传输过程中会被多次调用
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
 * EN: This method starts sending a local file to the device. The remote path is constructed
 *     internally as "remoteFolder/fileName". The progress callback will be called multiple
 *     times during the transfer to report current progress.
 * CN: 此方法开始向设备发送本地文件。远程路径由内部拼接为 "remoteFolder/fileName"。
 *     进度回调在传输过程中会被多次调用来报告当前进度。
 *
 * @note
 * EN: Only one file transfer operation can be active at a time
 * CN: 同时只能有一个文件传输操作处于活跃状态
 */
+ (void)sendFileWithLocalPath:(NSString *)filePath
                 remoteFolder:(NSString *)remoteFolder
                     fileName:(NSString *)fileName
                     progress:(TSFileTransferProgressCallback _Nullable)progress
                      success:(TSSendFileSuccessCallback)success
                      failure:(TSSendFileFailureCallback)failure;

/**
 * @brief Cancel current file transfer operation
 * @chinese 取消当前文件传输操作
 *
 * @param completion
 * EN: Completion callback with success flag and error information
 * CN: 完成回调，包含成功标志和错误信息
 *
 * @discussion
 * EN: This method cancels the current file transfer operation (either sending or receiving).
 *     The transfer process will be stopped and the device will remain in its current state.
 *     This operation cannot be undone once completed.
 * CN: 此方法取消当前的文件传输操作（发送或接收）。传输过程将被停止，设备将保持在当前状态。
 *     此操作一旦完成将无法撤销。
 *
 * @note
 * EN: If no transfer operation is currently active, this method will return success immediately
 * CN: 如果当前没有活跃的传输操作，此方法将立即返回成功
 */
+ (void)cancelFileTransferWithCompletion:(TSMetaCompletionBlock)completion;

/** @brief Start PB upload and return its preparation identity for scoped cancellation.
 * @chinese 开始 PB 上传并返回准备身份，仅用于所属任务取消；沿用原电量、空间和协议流程。
 * @param filePath EN: Local input. CN: 本地输入。
 * @param remoteFolder EN: Device folder. CN: 设备目录。
 * @param fileName EN: Device filename. CN: 设备文件名。
 * @param progress EN: Progress. CN: 进度。
 * @param success EN: Protocol success. CN: 协议成功。
 * @param failure EN: Failure. CN: 失败。
 * @return EN: Preparation identity or nil if rejected. CN: 准备身份，拒绝时为 nil。
 */
+ (nullable NSNumber *)beginSendingFileAtPath:(NSString *)filePath
                                 remoteFolder:(NSString *)remoteFolder
                                     fileName:(NSString *)fileName
                                     progress:(nullable TSFileTransferProgressCallback)progress
                                      success:(TSSendFileSuccessCallback)success
                                      failure:(TSSendFileFailureCallback)failure;
/** @brief Cancel only when the PB preparation identity still owns the sender.
 * @chinese 仅当 PB 准备身份仍持有发送器时取消，不影响其他任务。
 * @param token EN: Returned preparation identity. CN: 返回的准备身份。
 * @param completion EN: Cancellation result. CN: 取消结果。
 */
+ (void)cancelFileTransferWithPrepareToken:(NSNumber *)token completion:(TSMetaCompletionBlock)completion;


+ (void)getAvailableSpaceForPath:(TSMetaFilePath *)filePath
                      completion:(void(^)(TSMetaDirSpace * _Nullable dirSpace, NSError * _Nullable error))completion ;

@end

NS_ASSUME_NONNULL_END
