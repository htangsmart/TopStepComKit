//
//  WMNavigaionAppModel.h
//  UNIWatchMate
//
//  Created by abel on 2024/3/12.
//


#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol WMNavigaionAppDelegate <NSObject, AVCaptureVideoDataOutputSampleBufferDelegate>

/// 手表端开关导航 （Watch end switch navigation）
/// - Parameter isOpen: YES打开导航；（YES Opens navigation;）
/// - Parameter result: 否执行成功 （No Successfully executed）
- (void)watchOpenOrCloseNavigation:(BOOL)isOpen result:(void(^)(BOOL))result;


@end

@interface WMNavigationAppModel : NSObject<WMSupportProtocol>

/// 手表端控制导航代理，需要实现 （Watch side control navigation agent, need to implement）
@property (nonatomic, weak) id<WMNavigaionAppDelegate> delegate;


/// APP打开/关闭导航 （APP Open/close navigation）
/// - Parameter isOpen: BOOL 是否打开成功 （Whether successfully opened）
- (RACSignal<NSNumber *> *)openOrCloseNavigation:(BOOL)isOpen;

/// 是否支持视频预览 （Whether to support video preview）
- (BOOL)isSupportVideoPreview;

/// 开启视频预览，（视频预览前需要先打开导航）; 停止/不允许时回调Error （Open the video preview, (you need to open the navigation before the video preview); Callback Error when stopped/disallowed）
- (RACSignal<NSNumber *> *)videoPreviewBegin;

/// 发送视频数据给设备 （Send video data to the device）
/// - Parameters:
///   - buffer: AVCaptureVideoDataOutputSampleBufferDelegate， 视频数据回调 （Video data callback）
- (void)sendVideo:(NSData*)buffer width: (int)width height: (int)height ;

/// 关闭视频预览 （Turn off Video preview）
- (void)videoPreviewEnd;

@end

NS_ASSUME_NONNULL_END
