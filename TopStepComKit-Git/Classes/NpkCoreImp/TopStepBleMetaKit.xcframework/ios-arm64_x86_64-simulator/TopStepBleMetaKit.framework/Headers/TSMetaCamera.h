//
//  TSMetaCamera.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/30.
//

#import "TSBusinessBase.h"

@class TSMetaH264Head;
@class TSMetaH264Data;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Camera action enumeration
 * @chinese 相机动作枚举
 * 
 * @discussion 
 * EN: Defines all possible camera actions that can be performed
 * CN: 定义所有可执行的相机动作
 */
typedef NS_ENUM(NSInteger, TSMetaCameraAction) {
    TSMetaCameraActionExitCamera = 0,        // 退出相机
    TSMetaCameraActionEnterCamera = 1,       // 进入相机
    TSMetaCameraActionTakePhoto = 2,         // 拍照
    TSMetaCameraActionSwitchBackCamera = 3,  // 切换后置摄像头
    TSMetaCameraActionSwitchFrontCamera = 4, // 切换前置摄像头
    TSMetaCameraActionFlashOff = 5,          // 闪光关
    TSMetaCameraActionFlashAuto = 6,         // 闪光自动
    TSMetaCameraActionFlashOn = 7            // 闪光开
};

/**
 * @brief Camera action callback
 * @chinese 相机动作回调
 * 
 * @discussion 
 * EN: Callback for camera actions with action parameter
 * CN: 带动作参数的相机动作回调
 */
typedef void (^TSMetaCameraActionBlock)(TSMetaCameraAction action);

/**
 * @brief Camera completion callback
 * @chinese 相机完成回调
 * 
 * @discussion 
 * EN: Completion callback for camera operations
 * CN: 相机操作的完成回调
 */
typedef void (^TSMetaCameraCompletionBlock)(BOOL isSuccess, NSError * _Nullable error);

@interface TSMetaCamera : TSBusinessBase

/**
 * @brief User controls camera with specific action
 * @chinese 用户控制相机执行特定动作
 * 
 * @param action 
 * EN: The camera action to perform. Currently only supports exit camera and enter camera actions.
 * CN: 要执行的相机动作。目前仅支持退出相机和进入相机动作。
 * 
 * @param completion 
 * EN: Callback when operation is completed
 * CN: 操作完成的回调
 * 
 * @discussion 
 * EN: App sends camera control command to peripheral device to perform specific camera action.
 *      Currently only supports TSMetaCameraActionExitCamera and TSMetaCameraActionEnterCamera.
 *      Other action types (take photo, switch camera, flash control) are not supported.
 * CN: App向设备发送相机控制命令，执行特定的相机动作。
 *      目前仅支持退出相机和进入相机动作。
 *      其他动作类型（拍照、切换摄像头、闪光控制）暂不支持。
 * 
 * @note
 * EN: Supported: ExitCamera (0), EnterCamera (1). Unsupported: TakePhoto, SwitchCamera, FlashControl.
 * CN: 支持：退出相机(0)、进入相机(1)。不支持：拍照、切换摄像头、闪光控制。
 */
+ (void)controlCameraWithAction:(TSMetaCameraAction)action completion:(nullable TSMetaCameraCompletionBlock)completion;

/**
 * @brief Register listener for device controlling App camera
 * @chinese 注册监听设备控制App相机
 * 
 * @param cameraControlActionBlock
 * EN: Callback when device controls App camera with specific action
 * CN: 当设备控制App相机时的回调，包含具体的动作
 * 
 * @discussion 
 * EN: When peripheral device actively controls App camera (e.g., by button press or gesture),
 *     cameraControlActionBlock will be called with the specific action to perform.
 *     This method supports all TSMetaCameraAction types, including take photo, switch camera, and flash control.
 * CN: 当外设主动控制App相机时（如按键或手势），cameraControlActionBlock会被调用，
 *     包含要执行的具体动作。此方法支持所有TSMetaCameraAction类型，
 *     包括拍照、切换摄像头和闪光控制等。
 * 
 * @note
 * EN: Supports all camera actions: ExitCamera, EnterCamera, TakePhoto, SwitchCamera, FlashControl.
 * CN: 支持所有相机动作：退出相机、进入相机、拍照、切换摄像头、闪光控制。
 */
+ (void)registerAppCameraeControledByDevice:(nullable TSMetaCameraActionBlock)cameraControlActionBlock;

/**
 * @brief Check if device supports video preview functionality
 * @chinese 检查设备是否支持视频预览功能
 * 
 * @return
 * EN: YES if device supports video preview, NO otherwise
 * CN: 如果设备支持视频预览返回YES，否则返回NO
 * 
 * @discussion
 * EN: This method checks whether the currently connected device supports video preview functionality.
 *     Video preview allows the device to stream live video data to the app.
 *     The result is determined by checking the device's capability information.
 * CN: 此方法检查当前连接的设备是否支持视频预览功能。
 *     视频预览允许设备向应用流式传输实时视频数据。
 *     结果通过检查设备的能力信息来确定。
 * 
 * @note
 * EN: This method requires an active connection to a peripheral device.
 *     If no device is connected, this method returns NO.
 * CN: 此方法需要与外设设备的活跃连接。
 *     如果没有设备连接，此方法返回NO。
 */
+ (BOOL)isSupportVideoPreview;

/**
 * @brief Start video preview with H264 parameters
 * @chinese 开始视频预览（携带H264参数）
 * 
 * @param h264Head
 * EN: H264 video stream header information containing fps, width, height, and other parameters.
 *     This parameter specifies the video stream configuration for the preview.
 * CN: H264视频流头部信息，包含帧率、宽度、高度等参数。
 *     此参数指定预览的视频流配置。
 * 
 * @param completion
 * EN: Completion callback block that indicates whether the operation succeeded or failed.
 *     - isSuccess: YES if operation succeeded, NO if failed
 *     - error: Error object if operation failed, nil if successful
 * CN: 完成回调块，指示操作是否成功。
 *     - isSuccess: 操作成功返回YES，失败返回NO
 *     - error: 操作失败时的错误对象，成功时为nil
 * 
 * @discussion
 * EN: This method starts video preview on the connected device with the specified H264 parameters.
 *     The device will begin streaming live video data to the app according to the configuration
 *     specified in h264Head (frame rate, resolution, etc.).
 *     
 *     After successfully starting video preview, the app should be ready to receive
 *     H264 video data frames from the device. Use stopVideoPreviewWithCompletion: to stop the preview.
 * CN: 此方法在已连接的设备上使用指定的H264参数开始视频预览。
 *     设备将根据h264Head中指定的配置（帧率、分辨率等）开始向应用流式传输实时视频数据。
 *     
 *     成功开始视频预览后，应用应该准备好接收来自设备的H264视频数据帧。
 *     使用stopVideoPreviewWithCompletion:来停止预览。
 * 
 * @note
 * EN: - This method requires an active connection to a peripheral device.
 *     - The device must support video preview functionality (check with isSupportVideoPreview).
 *     - If video preview is already active, calling this method may return an error.
 *     - The h264Head parameter must contain valid video stream configuration.
 *     - Use stopVideoPreviewWithCompletion: to properly stop the video preview.
 * CN: - 此方法需要与外设设备的活跃连接。
 *     - 设备必须支持视频预览功能（使用isSupportVideoPreview检查）。
 *     - 如果视频预览已经激活，调用此方法可能会返回错误。
 *     - h264Head参数必须包含有效的视频流配置。
 *     - 使用stopVideoPreviewWithCompletion:来正确停止视频预览。
 */
+ (void)startVideoPreviewWithH264Head:(TSMetaH264Head *)h264Head
                            completion:(nullable TSMetaCameraCompletionBlock)completion;

/**
 * @brief Stop video preview
 * @chinese 结束视频预览
 * 
 * @param completion
 * EN: Completion callback block that indicates whether the operation succeeded or failed.
 *     - isSuccess: YES if operation succeeded, NO if failed
 *     - error: Error object if operation failed, nil if successful
 * CN: 完成回调块，指示操作是否成功。
 *     - isSuccess: 操作成功返回YES，失败返回NO
 *     - error: 操作失败时的错误对象，成功时为nil
 * 
 * @discussion
 * EN: This method stops video preview on the connected device. The device will stop
 *     streaming video data to the app. The completion block is called to indicate
 *     whether the operation succeeded or failed.
 *     
 *     After successfully stopping video preview, the app should stop processing
 *     any incoming video data and clean up related resources.
 * CN: 此方法在已连接的设备上停止视频预览。设备将停止向应用流式传输视频数据。
 *     完成回调块被调用以指示操作是否成功。
 *     
 *     成功停止视频预览后，应用应该停止处理任何传入的视频数据并清理相关资源。
 * 
 * @note
 * EN: - This method requires an active connection to a peripheral device.
 *     - If video preview is not active, calling this method may return an error or succeed silently.
 *     - Always call this method to properly clean up video preview resources.
 *     - The device may also stop video preview on its own (e.g., low battery, connection loss).
 * CN: - 此方法需要与外设设备的活跃连接。
 *     - 如果视频预览未激活，调用此方法可能会返回错误或静默成功。
 *     - 始终调用此方法以正确清理视频预览资源。
 *     - 设备也可能自行停止视频预览（例如：电量不足、连接丢失）。
 */
+ (void)stopVideoPreviewWithCompletion:(nullable TSMetaCameraCompletionBlock)completion;

/**
 * @brief Send H264 video data frame to device
 * @chinese 向设备发送H264视频数据帧
 * 
 * @param h264Data
 * EN: H264 video data frame containing the actual video data bytes.
 *     The data_p property contains the video frame data (maximum 960 bytes).
 *     This parameter is used to send individual video frames during video streaming.
 * CN: H264视频数据帧，包含实际的视频数据字节。
 *     data_p属性包含视频帧数据（最大960字节）。
 *     此参数用于在视频流传输期间发送单个视频帧。
 * 
 * @param completion
 * EN: Completion callback block that indicates whether the operation succeeded or failed.
 *     - isSuccess: YES if operation succeeded, NO if failed
 *     - error: Error object if operation failed, nil if successful
 * CN: 完成回调块，指示操作是否成功。
 *     - isSuccess: 操作成功返回YES，失败返回NO
 *     - error: 操作失败时的错误对象，成功时为nil
 * 
 * @discussion
 * EN: This method sends a single H264 video data frame to the connected device.
 *     This is typically called repeatedly during video streaming to send continuous
 *     video frames. The method uses a no-response command for efficient transmission,
 *     as video frames are sent at high frequency and don't require individual acknowledgments.
 *     
 *     The video data should be properly encoded H264 frame data. The maximum size
 *     for each frame is 960 bytes as specified in the protocol.
 *     
 *     This method should be called after successfully starting video preview with
 *     startVideoPreviewWithH264Head:completion:.
 * CN: 此方法向已连接的设备发送单个H264视频数据帧。
 *     通常在视频流传输期间重复调用此方法以发送连续的视频帧。
 *     该方法使用无响应命令以提高传输效率，因为视频帧以高频率发送，不需要单独的确认。
 *     
 *     视频数据应该是正确编码的H264帧数据。每帧的最大大小为协议中指定的960字节。
 *     
 *     此方法应在成功使用startVideoPreviewWithH264Head:completion:开始视频预览后调用。
 * 
 * @note
 * EN: - This method requires an active connection to a peripheral device.
 *     - Video preview must be started first using startVideoPreviewWithH264Head:completion:.
 *     - The h264Data parameter must contain valid H264 frame data.
 *     - Maximum frame size is 960 bytes. Larger frames should be split into multiple calls.
 *     - This method uses no-response command for efficiency, so completion callback indicates
 *       only whether the command was successfully sent, not whether the device processed it.
 *     - For high-frequency streaming, consider calling this method on a background queue.
 * CN: - 此方法需要与外设设备的活跃连接。
 *     - 必须首先使用startVideoPreviewWithH264Head:completion:开始视频预览。
 *     - h264Data参数必须包含有效的H264帧数据。
 *     - 最大帧大小为960字节。较大的帧应拆分为多次调用。
 *     - 此方法使用无响应命令以提高效率，因此完成回调仅指示命令是否成功发送，
 *       而不指示设备是否处理了它。
 *     - 对于高频流传输，考虑在后台队列上调用此方法。
 */
+ (void)sendVideoDataFrame:(NSData *)h264Datas
                completion:(nullable TSMetaCameraCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
