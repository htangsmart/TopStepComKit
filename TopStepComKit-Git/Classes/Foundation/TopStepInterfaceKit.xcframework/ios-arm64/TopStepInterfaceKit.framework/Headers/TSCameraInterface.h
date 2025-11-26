//
//  TSCameraInterface.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/12.
//  Copyright © 2025 TopStep. All rights reserved.
//

/**
 * @brief Camera Control Interface
 * @chinese 相机控制接口
 * 
 * @discussion 
 * EN: This interface defines the camera control protocol between App and peripheral devices.
 *     It provides methods for camera mode control and photo capture functionality.
 *     Mainly used for implementing remote camera control between App and smart devices (e.g., smartwatches).
 * 
 * CN: 该接口定义了App与外设之间的相机控制协议。
 *     提供相机模式控制和照片拍摄功能的方法。
 *     主要用于实现App与智能设备（如智能手表）之间的远程相机控制功能。
 */

#import "TSKitBaseInterface.h"
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Camera action enumeration
 * @chinese 相机动作枚举
 * 
 * @discussion 
 * EN: Defines all possible camera actions that can be performed
 * CN: 定义所有可执行的相机动作
 */
typedef NS_ENUM(NSInteger, TSCameraAction) {
    TSCameraActionExitCamera = 0,        // 退出相机
    TSCameraActionEnterCamera = 1,       // 进入相机
    TSCameraActionTakePhoto = 2,         // 拍照
    TSCameraActionSwitchBackCamera = 3,  // 切换后置摄像头
    TSCameraActionSwitchFrontCamera = 4, // 切换前置摄像头
    TSCameraActionFlashOff = 5,          // 闪光关
    TSCameraActionFlashAuto = 6,         // 闪光自动
    TSCameraActionFlashOn = 7            // 闪光开
};

/**
 * @brief Camera action callback
 * @chinese 相机动作回调
 * 
 * @discussion 
 * EN: Callback for camera actions with action parameter
 * CN: 带动作参数的相机动作回调
 */
typedef void (^TSCameraActionBlock)(TSCameraAction action);

/**
 * @brief Camera control interface protocol
 * @chinese 相机控制接口协议
 * 
 * @discussion 
 * EN: This protocol defines all interaction methods between App and peripheral device regarding camera control.
 *     Used for implementing remote camera control between App and smart devices (e.g., smartwatches).
 * CN: 该协议定义了App与外设之间关于相机控制的所有交互方法。
 *     主要用于实现App与智能设备（如智能手表）之间的远程相机控制功能。
 */
@protocol TSCameraInterface <TSKitBaseInterface>

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
 *      Currently only supports TSCameraActionExitCamera and TSCameraActionEnterCamera.
 *      Other action types (take photo, switch camera, flash control) are not supported.
 * CN: App向设备发送相机控制命令，执行特定的相机动作。
 *      目前仅支持退出相机和进入相机动作。
 *      其他动作类型（拍照、切换摄像头、闪光控制）暂不支持。
 * 
 * @note
 * EN: Supported: ExitCamera (0), EnterCamera (1). Unsupported: TakePhoto, SwitchCamera, FlashControl.
 * CN: 支持：退出相机(0)、进入相机(1)。不支持：拍照、切换摄像头、闪光控制。
 */
- (void)controlCameraWithAction:(TSCameraAction)action completion:(TSCompletionBlock)completion;

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
 *     This method supports all TSCameraAction types, including take photo, switch camera, and flash control.
 * CN: 当外设主动控制App相机时（如按键或手势），cameraControlActionBlock会被调用，
 *     包含要执行的具体动作。此方法支持所有TSCameraAction类型，
 *     包括拍照、切换摄像头和闪光控制等。
 * 
 * @note
 * EN: Supports all camera actions: ExitCamera, EnterCamera, TakePhoto, SwitchCamera, FlashControl.
 * CN: 支持所有相机动作：退出相机、进入相机、拍照、切换摄像头、闪光控制。
 */
- (void)registerAppCameraeControledByDevice:(nullable TSCameraActionBlock)cameraControlActionBlock;

/**
 * @brief Check if device supports video preview functionality
 * @chinese 检查设备是否支持拍照视频预览功能
 * 
 * @return
 * EN: YES if device supports video preview, NO otherwise
 * CN: 如果设备支持视频预览返回YES，否则返回NO
 * 
 * @discussion
 * EN: This method checks whether the currently connected device supports video preview functionality.
 *     Video preview allows the device to stream live video data to the app during camera mode.
 *     The result is determined by checking the device's capability information.
 * CN: 此方法检查当前连接的设备是否支持拍照视频预览功能。
 *     视频预览允许设备在相机模式下向应用流式传输实时视频数据。
 *     结果通过检查设备的能力信息来确定。
 * 
 * @note
 * EN: This method requires an active connection to a peripheral device.
 *     If no device is connected, this method returns NO.
 *     Video preview is typically supported by smart glasses or devices with camera capabilities.
 * CN: 此方法需要与外设设备的活跃连接。
 *     如果没有设备连接，此方法返回NO。
 *     视频预览通常由智能眼镜或具有相机功能的设备支持。
 */
- (BOOL)isSupportVideoPreview;

/**
 * @brief Get video preview size for the connected device
 * @chinese 获取已连接设备的视频预览尺寸
 * 
 * @return
 * EN: CGSize representing the video preview dimensions (width x height) in pixels.
 *     Returns CGSizeZero if device is not connected or preview size is not available.
 * CN: 表示视频预览尺寸（宽 x 高）的CGSize，单位像素。
 *     如果设备未连接或预览尺寸不可用，返回CGSizeZero。
 * 
 * @discussion
 * EN: This method retrieves the video preview size from the connected device's dial information.
 *     The preview size represents the dimensions of the video stream that will be received
 *     from the device during video preview mode. This information is useful for setting up
 *     the video display UI with the correct aspect ratio and dimensions.
 * CN: 此方法从已连接设备的表盘信息中获取视频预览尺寸。
 *     预览尺寸表示在视频预览模式下将从设备接收的视频流的尺寸。
 *     此信息对于设置具有正确宽高比和尺寸的视频显示UI很有用。
 * 
 * @note
 * EN: - This method requires an active connection to a peripheral device.
 *     - The preview size is typically smaller than the device's actual screen size.
 *     - Returns CGSizeZero if device is not connected or dial information is not available.
 *     - The size is in pixels and represents the video stream dimensions.
 * CN: - 此方法需要与外设设备的活跃连接。
 *     - 预览尺寸通常小于设备的实际屏幕尺寸。
 *     - 如果设备未连接或表盘信息不可用，返回CGSizeZero。
 *     - 尺寸以像素为单位，表示视频流的尺寸。
 */
- (CGSize)videoPreviewSize;

/**
 * @brief Start video preview
 * @chinese 开始视频预览
 * 
 * @param fps
 * EN: Frame rate per second for video preview (frames per second).
 *     Common values: 15, 24, 30, 60. Use 0 or negative value to use device default.
 * CN: 视频预览的帧率（每秒帧数）。
 *     常用值：15、24、30、60。使用0或负值表示使用设备默认值。
 *
 * @param completion
 * EN: Completion block called when operation finishes
 *     - isSuccess: YES if operation succeeded, NO if failed
 *     - error: Error object if operation failed, nil if successful
 * CN: 操作完成时调用的回调块
 *     - isSuccess: 操作成功返回YES，失败返回NO
 *     - error: 操作失败时的错误对象，成功时为nil
 */
- (void)startVideoPreviewWithFps:(NSInteger)fps completion:(TSCompletionBlock)completion;

/**
 * @brief Stop video preview
 * @chinese 结束视频预览
 * 
 * @param completion
 * EN: Completion block called when operation finishes
 *     - isSuccess: YES if operation succeeded, NO if failed
 *     - error: Error object if operation failed, nil if successful
 * CN: 操作完成时调用的回调块
 *     - isSuccess: 操作成功返回YES，失败返回NO
 *     - error: 操作失败时的错误对象，成功时为nil
 */
- (void)stopVideoPreviewCompletion:(TSCompletionBlock)completion;

/**
 * @brief Send video preview data frame to device
 * @chinese 向设备发送视频预览数据帧
 * 
 * @param videoData
 * EN: Video data frame containing the actual video frame bytes.
 *     The data should be properly encoded H264 frame data.
 * CN: 视频数据帧，包含实际的视频帧字节。
 *     数据应该是正确编码的H264帧数据。
 * 
 * @param completion
 * EN: Optional completion block that indicates whether the operation succeeded or failed.
 *     - isSuccess: YES if operation succeeded, NO if failed
 *     - error: Error object if operation failed, nil if successful
 *     This parameter can be nil if you don't need to handle the result for each frame.
 *     For high-frequency streaming (e.g., 30fps, 60fps), you may want to pass nil
 *     to avoid performance overhead from callbacks on every frame.
 * CN: 可选的完成回调块，指示操作是否成功。
 *     - isSuccess: 操作成功返回YES，失败返回NO
 *     - error: 操作失败时的错误对象，成功时为nil
 *     如果不需要处理每个帧的结果，此参数可以为nil。
 *     对于高频流传输（例如30fps、60fps），可以传递nil以避免每个帧回调的性能开销。
 * 
 * @discussion
 * EN: This method sends a single video data frame to the connected device during video preview.
 *     This is typically called repeatedly during video streaming to send continuous video frames.
 *     The method uses a no-response command for efficient transmission, as video frames are sent
 *     at high frequency and don't require individual acknowledgments.
 *     
 *     The video data should be properly encoded H264 frame data.
 *     
 *     This method should be called after successfully starting video preview with
 *     startVideoPreviewWithFps:completion:.
 *     
 *     Note: The completion callback is optional. For high-frequency streaming scenarios,
 *     you may want to pass nil to avoid performance overhead. However, if you need error
 *     handling or flow control, you should provide a completion block.
 * CN: 此方法在视频预览期间向已连接的设备发送单个视频数据帧。
 *     通常在视频流传输期间重复调用此方法以发送连续的视频帧。
 *     该方法使用无响应命令以提高传输效率，因为视频帧以高频率发送，不需要单独的确认。
 *     
 *     视频数据应该是正确编码的H264帧数据。
 *     
 *     此方法应在成功使用startVideoPreviewWithFps:completion:开始视频预览后调用。
 *     
 *     注意：完成回调是可选的。对于高频流传输场景，可以传递nil以避免性能开销。
 *     但是，如果您需要错误处理或流控制，应该提供完成回调块。
 * 
 * @note
 * EN: - This method requires an active connection to a peripheral device.
 *     - Video preview must be started first using startVideoPreviewWithFps:completion:.
 *     - The videoData parameter must contain valid H264 frame data.
 *     - The completion parameter is optional. Pass nil for high-frequency streaming to avoid
 *       performance overhead, or provide a block if you need error handling.
 *     - This method uses no-response command for efficiency, so completion callback indicates
 *       only whether the command was successfully sent, not whether the device processed it.
 *     - For high-frequency streaming, consider calling this method on a background queue.
 * CN: - 此方法需要与外设设备的活跃连接。
 *     - 必须首先使用startVideoPreviewWithFps:completion:开始视频预览。
 *     - videoData参数必须包含有效的H264帧数据。
 *     - completion参数是可选的。对于高频流传输可以传递nil以避免性能开销，
 *       如果需要错误处理则提供回调块。
 *     - 此方法使用无响应命令以提高效率，因此完成回调仅指示命令是否成功发送，
 *       而不指示设备是否处理了它。
 *     - 对于高频流传输，考虑在后台队列上调用此方法。
 */
- (void)sendVideoPreviewData:(NSData *)videoData
                  completion:(nullable TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
