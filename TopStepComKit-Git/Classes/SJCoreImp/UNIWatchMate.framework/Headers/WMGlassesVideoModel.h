//
//  WMWatchVideoModel.h
//  UNIWatchMate
//
//  Created by abel on 2024/5/8.
//

#ifndef WMWatchVideoModel_h
#define WMWatchVideoModel_h


#endif /* WMWatchVideoModel_h */
#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"
#import <AVFoundation/AVFoundation.h>
#import "WmGlassesMediaCount.h"
#import "WmGlassesStorageInfo.h"


NS_ASSUME_NONNULL_BEGIN
@protocol WMGlassesVideoAppDelegate <NSObject, AVCaptureVideoDataOutputSampleBufferDelegate>

//通过调用 startPreviewSet、startRecordSet、startRecordVideoSet、 deviceTakePhoto等方法获得的result
//只是说明设备是否正常收到命令了,真正的结果都是WMGlassesVideoAppDelegate中的方法通过设备端下发给APP端的

/// 设备端录音状态通知 （Device recording status notification）
/// - result :  0 ：关， 1 ：开，2：忙 （0: off, 1: on, 2: busy）
- (void)watchOpenOrCloseRecord:(NSInteger)result ;
/// 设备端录像状态通知 （Notification of recording status on the device）
/// - result :  0 ：关， 1 ：开，2：忙 （0: off, 1: on, 2: busy）
- (void)watchOpenOrCloseRecordVideo:(NSInteger)result;
/// 设备端预览状态通知 （Preview status notification on the device）
/// - result :  0 ：关， 1 ：开，2：忙 （0: off, 1: on, 2: busy）
- (void)watchClosePreview:(NSInteger)result;
/// 设备端拍照结果通知 （Notification of the photo result on the device）
/// - result : 1 byte: 0 : 失败  1：成功 2：忙 (1 byte: 0: failed 1: succeeded 2: busy)
- (void)watchTakePhoto:(NSInteger)result;

@end

@interface WMGlassesVideoModel : NSObject<WMSupportProtocol>

@property (nonatomic, weak) id<WMGlassesVideoAppDelegate> delegate;


/// 是否支持视频预览 （Whether to support video preview）
- (BOOL)isSupportVideoPreview;

/// 接收手表发送过来的视频 （Receive video from the watch）
- (RACSignal<NSData *> *)monitorVideo;

/// APP打开/关闭预览（APP Turn on/off the camera）
///result:    0 : 成功1：失败
- (RACSignal<NSNumber *> *)startPreviewSet:(BOOL)start;

/// 手机获取设备预览状态 （Phone Gets device preview status）
/// result:  0 : 正在预览 1：未预览
- (RACSignal<NSNumber *> *)devicePreviewState;

/// APP打开/关闭录音 （APP Turn on/off the record）
/// result 0 : 成功 1：失败
- (RACSignal<NSNumber *> *)startRecordSet:(BOOL)start;

/// 手机获取设备录音状态 （The mobile phone obtains the recording status of the device）
/// 1 : 正在录音 0：未录音
- (RACSignal<NSNumber *> *)deviceRecordState;

/// APP打开/关闭录像 （APP Turn on/off the record video）
///  result : 0 : 成功 1：失败
- (RACSignal<NSNumber *> *)startRecordVideoSet:(BOOL)start;

/// 手机获取设备录像状态 （The mobile phone obtains the recording status of the device）
///   result :1 : 正在录音 0：未录音
- (RACSignal<NSNumber *> *)deviceRecordVideoState;

/// APP请求设备拍照（The APP requests the device to take a photo）
///  result: 0 : 成功 1：失败
- (RACSignal<NSNumber *> *)deviceTakePhoto;

/// 设备媒体数量（Device media quantity）
- (RACSignal<WmGlassesMediaCount *> *)deviceMediaCount;

/// 设备存储（Device storage）
- (RACSignal<WmGlassesStorageInfo *> *)deviceStoreageInfo;

@end

NS_ASSUME_NONNULL_END
