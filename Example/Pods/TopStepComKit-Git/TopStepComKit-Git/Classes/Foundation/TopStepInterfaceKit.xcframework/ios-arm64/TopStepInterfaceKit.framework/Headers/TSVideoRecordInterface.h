//
//  TSVideoRecordInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/4/30.
//

#import "TSKitBaseInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Video recording maximum duration result callback
 * @chinese 录像最大时长结果回调
 *
 * @param maximumDuration
 * EN: Maximum video recording duration in minutes, valid range is 1~12
 * CN: 最大录像时长，单位分钟，有效范围 1~12
 *
 * @param error
 * EN: Error information, nil when successful
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSCameraMaxVideoRecordDurationBlock)(NSUInteger maximumDuration, NSError * _Nullable error);

/**
 * @brief AI photo result callback
 * @chinese AI 拍照结果回调
 *
 * @param photoData
 * EN: Original photo data returned by device, jpeg format
 * CN: 设备返回的原始照片数据，jpeg 格式
 *
 * @param enhancedPhotoData
 * EN: Enhanced photo data returned by device, jpeg format
 * CN: 设备返回的增强照片数据，jpeg 格式
 *
 * @param error
 * EN: Error information, nil when successful
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSCameraAIPhotoResultHandler)(NSData * _Nullable photoData,
                                            NSData * _Nullable enhancedPhotoData,
                                            NSError * _Nullable error);

/**
 * @brief Camera interface
 * @chinese 相机功能接口
 *
 * @discussion
 * EN: This interface defines camera related operations, including photo capture
 *     in normal or AI mode and video recording with configurable maximum duration.
 * CN: 该接口定义了与相机相关的操作，包括普通或 AI 模式拍照，以及支持设置最大时长的录像功能。
 */
@protocol TSVideoRecordInterface <TSKitBaseInterface>

/**
 * @brief Set maximum video recording duration
 * @chinese 设置最大录像时长
 *
 * @param maximumDuration
 * EN: Maximum video recording duration in minutes, valid range is 1~12
 * CN: 最大录像时长，单位分钟，有效范围 1~12
 *
 * @param completion
 * EN: Callback invoked when the setting command finishes
 * CN: 设置命令完成时回调
 */
- (void)setMaxVideoRecordDuration:(NSUInteger)maximumDuration
                       completion:(TSCompletionBlock)completion;

/**
 * @brief Get maximum video recording duration
 * @chinese 获取最大录像时长
 *
 * @param completion
 * EN: Callback invoked when the query finishes
 * CN: 查询完成时回调
 */
- (void)getMaxVideoRecordDuration:(nullable TSCameraMaxVideoRecordDurationBlock)completion;

/**
 * @brief Take a normal photo
 * @chinese 普通拍照
 *
 * @param completion
 * EN: Callback invoked when the capture command finishes
 * CN: 拍照命令完成时回调
 */
- (void)takeNormalPhotoWithCompletion:(TSCompletionBlock)completion;

/**
 * @brief Take an AI photo
 * @chinese AI 拍照
 *
 * @param completion
 * EN: Callback invoked when the capture command finishes
 * CN: 拍照命令完成时回调
 *
 * @param resultHandler
 * EN: Callback invoked when device returns AI photo result data
 * CN: 设备返回 AI 拍照结果数据时回调
 */
- (void)takeAIPhotoWithCompletion:(TSCompletionBlock)completion
                    resultHandler:(nullable TSCameraAIPhotoResultHandler)resultHandler;

/**
 * @brief Start video recording
 * @chinese 开始录像
 *
 * @param completion
 * EN: Callback invoked when the start command finishes.
 *     After the command succeeds, the device starts recording and stores the video file on the device.
 *     Use the file interface to retrieve the recorded video file later.
 * CN: 开始录像命令完成时回调。
 *     命令成功后，设备会开始录像，并将视频文件保存在设备端。
 *     录像文件需要后续通过文件接口获取。
 */
- (void)startVideoRecording:(TSCompletionBlock)completion;

/**
 * @brief Stop video recording
 * @chinese 停止录像
 *
 * @param completion
 * EN: Callback invoked when the stop command finishes
 * CN: 停止录像命令完成时回调
 */
- (void)stopVideoRecording:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
