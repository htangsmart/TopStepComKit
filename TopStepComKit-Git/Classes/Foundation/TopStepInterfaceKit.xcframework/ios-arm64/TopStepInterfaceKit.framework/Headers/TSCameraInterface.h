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
#import <AVFoundation/AVFoundation.h>

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
 *     The data must be H264 encoded video data returned by encodeYUVToH264WithYData:uData:vData:screenW:screenH:orientation:isBack: method.
 *     Do not pass other types of data or data from other sources.
 * CN: 视频数据帧，包含实际的视频帧字节。
 *     数据必须是通过encodeYUVToH264WithYData:uData:vData:screenW:screenH:orientation:isBack:方法返回的H264编码视频数据。
 *     不要传递其他类型的数据或来自其他来源的数据。
 *
 */
- (void)sendVideoPreviewData:(NSData *)videoData;

/**
 * @brief Send video preview data frame to device using CMSampleBuffer
 * @chinese 使用CMSampleBuffer向设备发送视频预览数据帧
 * 
 * @param sampleBuffer
 * EN: CMSampleBuffer containing video frame data from AVFoundation capture session.
 *     The sample buffer should contain video data in a format that can be converted to YUV.
 *     Typically obtained from AVCaptureVideoDataOutputSampleBufferDelegate callback.
 * CN: 包含来自AVFoundation捕获会话的视频帧数据的CMSampleBuffer。
 *     采样缓冲区应包含可转换为YUV格式的视频数据。
 *     通常从AVCaptureVideoDataOutputSampleBufferDelegate回调中获取。
 *
 * @param isBack
 * EN: YES if using back camera, NO if using front camera.
 *     This parameter is used to determine the correct encoding orientation and settings.
 * CN: 使用后置摄像头返回YES，使用前置摄像头返回NO。
 *     此参数用于确定正确的编码方向和设置。
 */
- (void)sendVideoPreviewSampleBuffer:(CMSampleBufferRef)sampleBuffer isBack:(BOOL)isBack;

/**
 * @brief Convert YUV video data to H264 format
 * @chinese 将YUV视频数据转换为H264格式
 * 
 * @param yData
 * EN: Y plane data (luminance data) of the video frame
 * CN: 视频帧的Y平面数据（亮度数据）
 * 
 * @param uData
 * EN: U plane data (chrominance data) of the video frame
 * CN: 视频帧的U平面数据（色度数据）
 * 
 * @param vData
 * EN: V plane data (chrominance data) of the video frame. Can be nil for some YUV formats.
 * CN: 视频帧的V平面数据（色度数据）。对于某些YUV格式可以为nil。
 * 
 * @param screenW
 * EN: Screen width in pixels
 * CN: 屏幕宽度（像素）
 * 
 * @param screenH
 * EN: Screen height in pixels
 * CN: 屏幕高度（像素）
 * 
 * @param orientation
 * EN: Device orientation value (0=Portrait, 1=PortraitUpsideDown, 2=LandscapeLeft, 3=LandscapeRight)
 * CN: 设备方向值（0=竖屏，1=倒置竖屏，2=左横屏，3=右横屏）
 * 
 * @param isBack
 * EN: YES if using back camera, NO if using front camera
 * CN: 使用后置摄像头返回YES，使用前置摄像头返回NO
 * 
 * @return
 * EN: H264 encoded video data. Returns nil if encoding fails or parameters are invalid.
 * CN: H264编码后的视频数据。如果编码失败或参数无效，返回nil。
 * 
 * @discussion
 * EN: This method converts raw YUV video data to H264 encoded format using the h264encoder framework.
 *     The method handles the conversion of YUV420 format video frames to H264 compressed data,
 *     which can then be sent to the connected device via sendVideoPreviewData:completion:.
 *     
 *     The YUV data should be in YUV420 format (I420 or NV12). The method uses the XEncoder
 *     from h264encoder framework to perform the encoding.
 *     
 *     This method should be called for each video frame that needs to be encoded and sent to the device.
 * CN: 此方法使用h264encoder框架将原始YUV视频数据转换为H264编码格式。
 *     该方法处理YUV420格式视频帧到H264压缩数据的转换，
 *     然后可以通过sendVideoPreviewData:completion:发送到已连接的设备。
 *     
 *     YUV数据应为YUV420格式（I420或NV12）。该方法使用h264encoder框架中的XEncoder进行编码。
 *     
 *     对于需要编码并发送到设备的每个视频帧，都应调用此方法。
 * 
 */
- (nullable NSData *)encodeYUVToH264WithYData:(NSData *)yData
                                        uData:(NSData *)uData
                                        vData:(nullable NSData *)vData
                                      screenW:(NSInteger)screenW
                                      screenH:(NSInteger)screenH
                                  orientation:(NSInteger)orientation
                                       isBack:(BOOL)isBack;

@end

NS_ASSUME_NONNULL_END
