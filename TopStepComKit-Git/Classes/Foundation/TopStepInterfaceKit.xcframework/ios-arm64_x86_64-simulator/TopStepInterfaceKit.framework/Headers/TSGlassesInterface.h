//
//  TSGlassesInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/6/19.
//

#import "TSKitBaseInterface.h"
#import "TSGlassesMediaCount.h"
#import "TSGlassesStorageInfo.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Video preview status enumeration
 * @chinese 视频预览状态枚举
 */
typedef NS_ENUM(UInt8, TSVideoPreviewStatus) {
    TSVideoPreviewUnknown = 0,    /**< Unknown status / 未知状态 */
    TSVideoPreviewInactive = 1,   /**< Not active / 未进行 */
    TSVideoPreviewActive = 2      /**< Active / 进行中 */
};

/**
 * @brief Audio recording status enumeration
 * @chinese 录音状态枚举
 */
typedef NS_ENUM(UInt8, TSAudioRecordingStatus) {
    TSAudioRecordingUnknown = 0,    /**< Unknown status / 未知状态 */
    TSAudioRecordingInactive = 1,   /**< Not recording / 未进行 */
    TSAudioRecordingActive = 2      /**< Recording / 进行中 */
};

/**
 * @brief Video recording status enumeration
 * @chinese 视频录制状态枚举
 */
typedef NS_ENUM(UInt8, TSVideoRecordingStatus) {
    TSVideoRecordingUnknown = 0,    /**< Unknown status / 未知状态 */
    TSVideoRecordingInactive = 1,   /**< Not recording / 未进行 */
    TSVideoRecordingActive = 2      /**< Recording / 进行中 */
};

/**
 * @brief Block type for video preview status change notification
 * @chinese 视频预览状态变化通知的Block类型
 * 
 * @param status 
 * EN: New video preview status
 * CN: 新的视频预览状态
 */
typedef void (^_Nullable PreviewVideoStatusChangedBlock)(TSVideoPreviewStatus);

/**
 * @brief Block type for audio recording status change notification
 * @chinese 录音状态变化通知的Block类型
 * 
 * @param status 
 * EN: New audio recording status
 * CN: 新的录音状态
 */
typedef void (^_Nullable AudioRecordingStatusChangedBlock)(TSAudioRecordingStatus);

/**
 * @brief Block type for video recording status change notification
 * @chinese 视频录制状态变化通知的Block类型
 * 
 * @param status 
 * EN: New video recording status
 * CN: 新的视频录制状态
 */
typedef void (^_Nullable VideoRecordingStatusChangedBlock)(TSVideoRecordingStatus);

/**
 * @brief Block type for photo capture result notification
 * @chinese 拍照结果通知的Block类型
 * 
 * @param isSuccess 
 * EN: YES if photo capture succeeded, NO if failed
 * CN: 拍照成功返回YES，失败返回NO
 * 
 * @param error 
 * EN: Error object if photo capture failed, nil if successful
 * CN: 拍照失败时的错误对象，成功时为nil
 */
typedef void (^_Nullable PhotoCaptureResultBlock)(BOOL isSuccess , NSError * _Nullable error);

/**
 * @brief Block type for video data reception from device
 * @chinese 从设备接收视频数据的Block类型
 * 
 * @param videoData 
 * EN: Raw video data received from device
 * CN: 从设备接收到的原始视频数据
 * 
 * @discussion
 * EN: This block is called continuously as video data arrives from the device.
 *     The video data format depends on the device's video encoding settings.
 * CN: 当视频数据从设备到达时，此Block会被持续调用。
 *     视频数据格式取决于设备的视频编码设置。
 */
typedef void (^_Nullable DidReceiveVideoDataBlock)(NSData *videoData);

/**
 * @brief Block type for video preview completion notification
 * @chinese 视频预览完成通知的Block类型
 * 
 * @param error 
 * EN: Error object if video preview ended due to error, nil if normal end
 * CN: 如果视频预览因错误而结束则返回错误对象，正常结束时为nil
 * 
 * @discussion
 * EN: This block is called when video preview ends, either by user request
 *     or due to device-initiated termination (e.g., low battery, connection loss).
 * CN: 当视频预览结束时调用此Block，可能是用户请求停止或设备主动终止
 *     （例如：电量不足、连接丢失等）。
 */
typedef void (^_Nullable DidCompleteVideoPreviewBlock)(NSError * _Nullable error);

/**
 * @brief Smart glasses interface protocol
 * @chinese 智能眼镜接口协议
 * 
 * @discussion
 * EN: This protocol defines the interface for smart glasses functionality,
 *     including video preview, audio recording, and video recording features.
 * CN: 此协议定义了智能眼镜功能的接口，包括视频预览、录音和视频录制功能。
 */
@protocol TSGlassesInterface <TSKitBaseInterface>

/**
 * @brief Check if device supports video preview functionality
 * @chinese 检查设备是否支持视频预览功能
 * 
 * @return 
 * EN: YES if device supports video preview, NO otherwise
 * CN: 如果设备支持视频预览返回YES，否则返回NO
 */
- (BOOL)isSupportVideoPreview;

/**
 * @brief Start video preview on smart glasses
 * @chinese 在智能眼镜上开始视频预览
 * 
 * @param completion 
 * EN: Completion block called when operation finishes
 *     - isSuccess: YES if operation succeeded, NO if failed
 *     - error: Error object if operation failed, nil if successful
 * CN: 操作完成时调用的回调块
 *     - isSuccess: 操作成功返回YES，失败返回NO
 *     - error: 操作失败时的错误对象，成功时为nil
 * 
 * @param didReceiveData 
 * EN: Block called when video data is received from device
 *     - videoData: Raw video data from device
 * CN: 当接收到设备视频数据时调用的回调块
 *     - videoData: 来自设备的原始视频数据
 * 
 * @param completionHandler
 * EN: Block called when video preview ends (either by device or user)
 *     - error: Error object if video preview ended due to error, nil if normal end
 * CN: 当视频预览结束时调用的回调块（设备主动停止或用户停止）
 *     - error: 如果视频预览因错误而结束则返回错误对象，正常结束时为nil
 * 
 * @discussion
 * EN: This method will send start command to device and begin receiving video data.
 *     The completion block will be called first to indicate command result.
 *     The didReceiveData will be called continuously as video data arrives.
 *     The completionHandler will be called when video preview ends (device stops or user calls stopVideoPreview).
 *     Use stopVideoPreview to stop the video preview.
 * CN: 此方法将向设备发送开始指令并开始接收视频数据。
 *     completion回调会首先被调用以指示指令结果。
 *     didReceiveData会在视频数据到达时持续被调用。
 *     VideoPreviewCompletionBlock会在视频预览结束时被调用（设备停止或用户调用stopVideoPreview）。
 *     使用stopVideoPreview来停止视频预览。
 */
- (void)startVideoPreview:(TSCompletionBlock)completion
              didReceiveData:(DidReceiveVideoDataBlock)didReceiveData
              completionHandler:(DidCompleteVideoPreviewBlock)completionHandler;

/**
 * @brief Close video preview on smart glasses
 * @chinese 在智能眼镜上关闭视频预览
 * 
 * @param completion 
 * EN: Completion block called when operation finishes
 *     - isSuccess: YES if operation succeeded, NO if failed
 *     - error: Error object if operation failed, nil if successful
 * CN: 操作完成时调用的回调块
 *     - isSuccess: 操作成功返回YES，失败返回NO
 *     - error: 操作失败时的错误对象，成功时为nil
 */
- (void)stopVideoPreview:(TSCompletionBlock)completion;

/**
 * @brief Get current video preview status
 * @chinese 获取当前视频预览状态
 *
 * @param completion
 * EN: Completion block called when status retrieval finishes
 *     - status: Current video preview status (TSVideoPreviewStatus)
 *     - error: Error object if status retrieval failed, nil if successful
 * CN: 状态获取完成时调用的回调块
 *     - status: 当前视频预览状态 (TSVideoPreviewStatus)
 *     - error: 状态获取失败时的错误对象，成功时为nil
 */
- (void)getVideoPreviewStatus:(void(^)(TSVideoPreviewStatus status, NSError * _Nullable error))completion;

/**
 * @brief Register block to listen for video preview status changes
 * @chinese 注册视频预览状态变化监听Block
 *
 * @param statusChangedBlock
 * EN: Block called when video preview status changes
 *     - status: New video preview status (TSVideoPreviewStatus)
 * CN: 当视频预览状态变化时调用的Block
 *     - status: 新的视频预览状态 (TSVideoPreviewStatus)
 *
 * @discussion
 * EN: Call this method to register a block that will be called whenever the video preview status changes.
 *     Pass nil to remove the block.
 * CN: 调用此方法注册一个Block，当视频预览状态变化时会被调用。
 *     传入nil可移除监听。
 */
- (void)registerVideoPreviewStatusChangedBlock:(PreviewVideoStatusChangedBlock)statusChangedBlock;

/**
 * @brief Start audio recording on smart glasses
 * @chinese 在智能眼镜上开始录音
 * 
 * @param completion 
 * EN: Completion block called when operation finishes
 *     - isSuccess: YES if operation succeeded, NO if failed
 *     - error: Error object if operation failed, nil if successful
 * CN: 操作完成时调用的回调块
 *     - isSuccess: 操作成功返回YES，失败返回NO
 *     - error: 操作失败时的错误对象，成功时为nil
 */
- (void)startAudioRecording:(TSCompletionBlock)completion;

/**
 * @brief Stop audio recording on smart glasses
 * @chinese 在智能眼镜上停止录音
 * 
 * @param completion 
 * EN: Completion block called when operation finishes
 *     - isSuccess: YES if operation succeeded, NO if failed
 *     - error: Error object if operation failed, nil if successful
 * CN: 操作完成时调用的回调块
 *     - isSuccess: 操作成功返回YES，失败返回NO
 *     - error: 操作失败时的错误对象，成功时为nil
 */
- (void)stopAudioRecording:(TSCompletionBlock)completion;

/**
 * @brief Get current audio recording status
 * @chinese 获取当前录音状态
 *
 * @param completion
 * EN: Completion block called when status retrieval finishes
 *     - status: Current audio recording status (TSAudioRecordingStatus)
 *     - error: Error object if status retrieval failed, nil if successful
 * CN: 状态获取完成时调用的回调块
 *     - status: 当前录音状态 (TSAudioRecordingStatus)
 *     - error: 状态获取失败时的错误对象，成功时为nil
 */
- (void)getAudioRecordingStatus:(void(^)(TSAudioRecordingStatus status, NSError * _Nullable error))completion;

/**
 * @brief Register block to listen for audio recording status changes
 * @chinese 注册录音状态变化监听Block
 *
 * @param statusChangedBlock
 * EN: Block called when audio recording status changes
 *     - status: New audio recording status (TSAudioRecordingStatus)
 * CN: 当录音状态变化时调用的Block
 *     - status: 新的录音状态 (TSAudioRecordingStatus)
 *
 * @discussion
 * EN: Call this method to register a block that will be called whenever the audio recording status changes.
 *     Pass nil to remove the block.
 * CN: 调用此方法注册一个Block，当录音状态变化时会被调用。
 *     传入nil可移除监听。
 */
- (void)registerAudioRecordingStatusChangedBlock:(AudioRecordingStatusChangedBlock)statusChangedBlock;

/**
 * @brief Start video recording on smart glasses
 * @chinese 在智能眼镜上开始视频录制
 * 
 * @param completion 
 * EN: Completion block called when operation finishes
 *     - isSuccess: YES if operation succeeded, NO if failed
 *     - error: Error object if operation failed, nil if successful
 * CN: 操作完成时调用的回调块
 *     - isSuccess: 操作成功返回YES，失败返回NO
 *     - error: 操作失败时的错误对象，成功时为nil
 */
- (void)startVideoRecording:(TSCompletionBlock)completion;

/**
 * @brief Stop video recording on smart glasses
 * @chinese 在智能眼镜上停止视频录制
 * 
 * @param completion 
 * EN: Completion block called when operation finishes
 *     - isSuccess: YES if operation succeeded, NO if failed
 *     - error: Error object if operation failed, nil if successful
 * CN: 操作完成时调用的回调块
 *     - isSuccess: 操作成功返回YES，失败返回NO
 *     - error: 操作失败时的错误对象，成功时为nil
 */
- (void)stopVideoRecording:(TSCompletionBlock)completion;

/**
 * @brief Get current video recording status
 * @chinese 获取当前视频录制状态
 *
 * @param completion
 * EN: Completion block called when status retrieval finishes
 *     - status: Current video recording status (TSVideoRecordingStatus)
 *     - error: Error object if status retrieval failed, nil if successful
 * CN: 状态获取完成时调用的回调块
 *     - status: 当前视频录制状态 (TSVideoRecordingStatus)
 *     - error: 状态获取失败时的错误对象，成功时为nil
 */
- (void)getVideoRecordingStatus:(void(^)(TSVideoRecordingStatus status, NSError * _Nullable error))completion;

/**
 * @brief Register block to listen for video recording status changes
 * @chinese 注册录像状态变化监听Block
 *
 * @param statusChangedBlock
 * EN: Block called when video recording status changes
 *     - status: New video recording status (TSVideoRecordingStatus)
 * CN: 当录像状态变化时调用的Block
 *     - status: 新的录像状态 (TSVideoRecordingStatus)
 *
 * @discussion
 * EN: Call this method to register a block that will be called whenever the video recording status changes.
 *     Pass nil to remove the block.
 * CN: 调用此方法注册一个Block，当录像状态变化时会被调用。
 *     传入nil可移除监听。
 */
- (void)registerVideoRecordingStatusChangedBlock:(VideoRecordingStatusChangedBlock)statusChangedBlock;

/**
 * @brief Take a photo with smart glasses
 * @chinese 使用智能眼镜拍照
 * 
 * @param completion 
 * EN: Completion block called when photo capture finishes
 *     - isSuccess: YES if photo capture succeeded, NO if failed
 *     - error: Error object if photo capture failed, nil if successful
 * CN: 拍照完成时调用的回调块
 *     - isSuccess: 拍照成功返回YES，失败返回NO
 *     - error: 拍照失败时的错误对象，成功时为nil
 * 
 * @discussion
 * EN: This method triggers the smart glasses to capture a single photo.
 *     The captured photo will be saved to the device's storage.
 * CN: 此方法触发智能眼镜拍摄单张照片。
 *     拍摄的照片将保存到设备存储中。
 */
- (void)takePhoto:(TSCompletionBlock)completion;

/**
 * @brief Register block to listen for photo capture result notification
 * @chinese 注册拍照结果通知监听Block
 *
 * @param resultBlock
 * EN: Block called when photo capture result is available
 *     - isSuccess: YES if photo capture succeeded, NO if failed
 *     - error: Error object if photo capture failed, nil if successful
 * CN: 当拍照结果可用时调用的Block
 *     - isSuccess: 拍照成功返回YES，失败返回NO
 *     - error: 拍照失败时的错误对象，成功时为nil
 *
 * @discussion
 * EN: Call this method to register a block that will be called whenever a photo capture result is available.
 *     Pass nil to remove the block.
 * CN: 调用此方法注册一个Block，当有拍照结果时会被调用。
 *     传入nil可移除监听。
 */
- (void)registerPhotoCaptureResultBlock:(PhotoCaptureResultBlock)resultBlock;

/**
 * @brief Get media file count on smart glasses device
 * @chinese 获取智能眼镜设备上的媒体文件数量
 * 
 * @param completion 
 * EN: Completion block called when count retrieval finishes
 *     - mediaCount: Media count model containing counts for different file types
 *     - error: Error object if count retrieval failed, nil if successful
 * CN: 数量获取完成时调用的回调块
 *     - mediaCount: 包含不同文件类型数量的媒体数量模型
 *     - error: 数量获取失败时的错误对象，成功时为nil
 * 
 * @discussion
 * EN: This method retrieves the count of different types of media files
 *     (videos, audio recordings, music, photos) stored on the device.
 * CN: 此方法获取设备上存储的不同类型媒体文件（视频、录音、音乐、照片）的数量。
 */
- (void)getMediaCount:(void(^)(TSGlassesMediaCount * _Nullable mediaCount, NSError * _Nullable error))completion;

/**
 * @brief Get storage information of smart glasses device
 * @chinese 获取智能眼镜设备的存储信息
 * 
 * @param completion 
 * EN: Completion block called when storage information retrieval finishes
 *     - storageInfo: Storage information model containing total and available space
 *     - error: Error object if storage information retrieval failed, nil if successful
 * CN: 存储信息获取完成时调用的回调块
 *     - storageInfo: 包含总空间和可用空间的存储信息模型
 *     - error: 存储信息获取失败时的错误对象，成功时为nil
 * 
 * @discussion
 * EN: This method retrieves the storage information of the smart glasses device,
 *     including total storage space and available storage space in bytes.
 *     The storage information can be used to check available space before
 *     recording videos or taking photos.
 * CN: 此方法获取智能眼镜设备的存储信息，包括总存储空间和可用存储空间（字节）。
 *     存储信息可用于在录制视频或拍照前检查可用空间。
 */
- (void)getStorageInfo:(void(^)(TSGlassesStorageInfo * _Nullable storageInfo, NSError * _Nullable error))completion;




@end

NS_ASSUME_NONNULL_END
