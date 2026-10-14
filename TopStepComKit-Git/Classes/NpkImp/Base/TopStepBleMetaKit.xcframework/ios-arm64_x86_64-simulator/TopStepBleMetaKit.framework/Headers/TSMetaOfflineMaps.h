//
//  TSMetaOfflineMaps.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2026/7/8.
//

#import "TSBusinessBase.h"
#import "TSCommandDefines.h"
#import "PbSettingParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 离线地图授权信息回调（返回 TSMetaOfflineMapAuthInfo）
 * @chinese 获取离线地图授权信息时的回调，返回协议层授权模型或错误
 */
typedef void(^TSMetaOfflineMapAuthCompletionBlock)(TSMetaOfflineMapAuthInfo * _Nullable authInfo, NSError * _Nullable error);

@interface TSMetaOfflineMaps : TSBusinessBase

/**
 * @brief 请求离线地图授权信息
 * @chinese 从设备获取离线地图授权信息（0x68，App 阻塞指令）。
 *          App 发送时无数据，Device 回复时携带 TSMetaOfflineMapAuthInfo。
 *          若 device 字段为空，表示设备未授权。
 */
+ (void)fetchOfflineMapAuthInfoWithCompletion:(nullable TSMetaOfflineMapAuthCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
