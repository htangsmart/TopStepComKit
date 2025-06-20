//
//  WMPeripheral.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMDeviceInfoModel.h"
#import "WMSettingsModel.h"
#import "WMAppsModel.h"
#import "WMDatasSyncModel.h"
#import "WMConnectModel.h"
@class WMPeripheralTargetModel;

NS_ASSUME_NONNULL_BEGIN

@protocol WMCustomDataDelegate <NSObject>
// 接受到自定义数据回调
- (void)devicePushData:(NSData *)data;
- (void)devicePushDataNeedReply:(NSData *)data result:(void(^)(BOOL))result;

@end

@protocol WMAiAssistantDelegate

/**
 * @brief 设备发送图片和音频数据到APP
 * @param imageData 图片数据，可以为空
 * @param pcmData PCM格式的音频数据，可以为空
 * @discussion 同时发送图片和音频数据到智能眼镜进行处理
 */
- (void)glassesSendDataWithImageData:(nullable NSData *)imageData pcmData:(nullable NSData *)pcmData;

/**
 * @brief 设备发送音频数据到APP
 * @param pcmData PCM格式的音频数据
 * @discussion 仅发送音频数据到智能眼镜进行处理
 */
- (void)glassesSendAudioWithPcmData:(NSData *)pcmData;

/**
 * @brief 设备发送图片数据到APP
 * @param imageData 图片数据，可以为空
 * @discussion 仅发送图片数据到智能眼镜进行处理
 */
- (void)glassesSendImageWithImageData:(nullable NSData *)imageData;

/**
 * @brief 设备打开AI助手功能
 * @discussion 激活智能眼镜的AI助手功能
 */
- (void)openAiAssistant;

/**
 * @brief 设备关闭AI助手功能
 * @discussion 停用智能眼镜的AI助手功能
 */
- (void)closeAiAssistant;

@end

@interface WMPeripheral : NSObject

/// 连接的目标设备 (The connected target device)
@property (nonatomic, strong) WMPeripheralTargetModel *target;
/// 设备连接 (Device connection)
@property (nonatomic, strong) WMConnectModel *connect;
/// 设备信息 (Device information)
@property (nonatomic, strong) WMDeviceInfoModel *infoModel;
/// 功能设置 (Function setting)
@property (nonatomic, strong) WMSettingsModel *settings;
/// 设备应用 (Equipment application)
@property (nonatomic, strong) WMAppsModel *apps;
/// 数据同步 (Data synchronization)
@property (nonatomic, strong) WMDatasSyncModel *datasSync;

@property (nonatomic, weak) id<WMAiAssistantDelegate> aiAssistantDelegate;
/// 自定义数据
@property (nonatomic, weak) id<WMCustomDataDelegate> customDataDelegate;

// 外设uuid
- (NSString * _Nullable)uuidString;

// 外设信号强度
- (NSNumber * _Nullable)rssi;

/// 发送自定义数据，未连接会报错
- (RACSignal<NSNumber *> *)sendCustomDataNeedReply:(NSData *)data;

/// 发送自定义数据，不报错
- (void)sendCustomData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
