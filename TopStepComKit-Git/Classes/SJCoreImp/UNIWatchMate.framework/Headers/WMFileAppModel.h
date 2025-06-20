//
//  WMFileAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMProgressModel.h"
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, WMFileType) {
    // 升级文件 （Upgrade file）
    WMActivityTypeOTA,
    // 表盘文件 （Dial file）
    WMActivityTypeDIAL,
    // 音乐文件 （Music file）
    WMActivityTypeMUSIC,
    // 电子书文件 （Ebook file）
    WMActivityTypeTXT,
    // 视频文件 （Video file）
    WMActivityTypeVIDEO
};

typedef NS_ENUM(NSInteger, WMCustomDialType) {
    WMCustomDialTypePointer,
    WMCustomDialTypeImage,
    WMCustomDialTypeVideo,
};

@interface WMCustomDialModel : NSObject

@property (nonatomic, strong, nullable) NSString *dialId;

@property (nonatomic, strong, nullable) UIImage *backgroundImage;

@property (nonatomic, strong, nullable) UIImage *textImage;

@property (nonatomic, strong, nullable) UIColor *textColor;

@property (nonatomic, strong, nullable) NSURL *videoUrl;

@property (nonatomic, strong, nullable) NSDictionary *param;

@property (nonatomic, assign) WMCustomDialType type;

@end

@interface WMFileAppModel : NSObject<WMSupportProtocol>

/// 传输单个文件 （Transfer a single file）
/// @param file 文件本地地址的NSURL对象 （File local address of the NSURL object）
/// @param type 文件的类型，WMFileType枚举定义了支持的类型 （The WMFileType enumeration defines the supported types）
/// @return 返回一个RACSignal对象，包含WMProgressModel，用于追踪传输进度 （Returns a RACSignal object containing the WMProgressModel to track the progress of the transfer）
- (RACSignal<WMProgressModel *> *)startTransferFile:(NSURL *)file fileType:(WMFileType)type;

/// 传输多个文件 （Transfer multiple files）
/// @param files 包含多个文件本地地址的NSURL对象数组 （An array of NSURL objects containing multiple file local addresses）
/// @param type 文件的类型，WMFileType枚举定义了支持的类型 （The WMFileType enumeration defines the supported types）
/// @return 返回一个RACSignal对象，包含WMProgressModel，用于追踪多个文件的传输进度 （Returns a RACSignal object containing the WMProgressModel to track the progress of multiple files）
- (RACSignal<WMProgressModel *> *)startTransferMultipleFile:(NSArray<NSURL*> *)files fileType:(WMFileType)type;

/// 传输自定义表盘 （Transfer a custom watch face）
/// @param customDialModel 自定义表盘模型对象，包含表盘相关的数据 （Custom dial model objects that contain dial related data）
/// @return 返回一个RACSignal对象，包含WMProgressModel，用于追踪表盘传输进度 （Returns a RACSignal object containing the WMProgressModel to track the progress of the dial transfer）
- (RACSignal<WMProgressModel *> *)startTransferCustomDial:(WMCustomDialModel *)customDialModel;

/// 是否支持多文件传输 （Whether to support multiple file transfer）
/// @return 返回一个BOOL值，表示是否支持多文件传输 （Returns a BOOL value indicating whether multiple file transfers are supported）
- (BOOL)isSupportMultiple;

/// 取消文件传输 （Cancel file transfer）
/// @discussion 调用此方法将取消当前的文件传输操作 （Calling this method cancels the current file transfer operation）
- (void)cancelTransfer;

/// 读取文件 （Read file）
- (void)readWatchFile:(NSInteger)fileId completion:(void (^)(NSInteger progress, NSData * _Nullable data, NSString * _Nullable fileName, NSError * _Nullable error))completion;

/// 设备剩余内存（type 0总剩余，1表盘剩余，2音乐剩余） （Device remaining memory (type 0 total remaining, 1 dial remaining, 2 music remaining)）
- (RACSignal<NSNumber *> *)freeMemoryType:(NSInteger)type;

@end

NS_ASSUME_NONNULL_END
