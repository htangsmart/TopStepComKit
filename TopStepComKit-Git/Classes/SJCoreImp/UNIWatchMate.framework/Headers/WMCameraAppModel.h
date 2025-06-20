//
//  WMCameraAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WMCameraPosition) {
    WMCameraPositionFront = 0,   /// 前置摄像头 （Front camera）
    WMCameraPositionRear     /// 后置摄像头 （Rear camera）
};

typedef NS_ENUM(NSInteger, WMCameraFlashMode) {
    WMCameraFlashModeOn = 0,     /// 闪光灯开启 （Flash on）
    WMCameraFlashModeOff,    /// 闪光灯关闭 （Flash off）
    WMCameraFlashModeAuto    /// 闪光灯自动 （Flash auto）
};

@protocol WMCameraAppDelegate <NSObject, AVCaptureVideoDataOutputSampleBufferDelegate>

/// 手表端开关相机 （Switch the camera at the watch end）
/// - Parameter isOpen: YES打开相机；（YES Turn on the camera）
/// - Parameter result: 否执行成功 （Whether the execution is successful）
- (void)watchOpenOrCloseCamera:(BOOL)isOpen result:(void(^)(BOOL))result;

/// 手表端切换摄像头 （Switch the camera on the watch）
/// - Parameter position: WMCameraPosition；
/// - Parameter result: 否执行成功（Whether the execution is successful）
- (void)watchSwitchCameraPosition:(WMCameraPosition)position result:(void(^)(BOOL))result;

/// 手表端切换闪光灯 （Watch side switch flash）
/// - Parameter flash: WMCameraFlashMode；
/// - Parameter result: 是否执行成功 （Whether the execution is successful）
- (void)watchSwitchCameraflash:(WMCameraFlashMode)flash result:(void(^)(BOOL))result;

/// 手表端点击拍照；（Click on the watch side to take a photo;）
/// - Parameter result: 否执行成功 （No Successfully executed）
- (void)watchSwitchCameraCaptureResult:(void(^)(BOOL))result;

@end

@interface WMCameraAppModel : NSObject<WMSupportProtocol>

/// 手表端控制相机代理，需要实现 （Watch side control camera agent, need to implement）
@property (nonatomic, weak) id<WMCameraAppDelegate> delegate;

/// APP切换摄像头 （APP switch camera）
/// - Parameter position: WMCameraPosition
- (RACSignal<NSNumber *> *)configPosition:(WMCameraPosition)position;

/// APP切换闪光灯 （APP Switch flash）
/// - Parameter flash: WMCameraFlashMode
- (RACSignal<NSNumber *> *)configFlash:(WMCameraFlashMode)flash;

/// APP打开/关闭相机 （APP Turn on/off the camera）
/// - Parameter isOpen: BOOL 是否打开成功 （Whether successfully opened）
- (RACSignal<NSNumber *> *)openOrCloseCamera:(BOOL)isOpen;

/// 是否支持视频预览 （Whether to support video preview）
- (BOOL)isSupportVideoPreview;

/// 开启视频预览，（视频预览前需要先打开相机）; 停止/不允许时回调Error （Open the video preview (the camera needs to be opened before the video preview); Callback Error when stopped/disallowed）
- (RACSignal<NSNumber *> *)videoPreviewBegin;

/// 发送视频数据给设备 （Send video data to the device）
/// - Parameters:
///   - buffer: AVCaptureVideoDataOutputSampleBufferDelegate， 视频数据回调 （Video data callback）
///   - isBack: 是否为后置摄像 （Whether it is a rear camera）
- (void)sendVideo:(CMSampleBufferRef)buffer CameraPosition:(BOOL)isBack;

/// 关闭视频预览 （Turn off Video preview）
- (void)videoPreviewEnd;

@end

NS_ASSUME_NONNULL_END
