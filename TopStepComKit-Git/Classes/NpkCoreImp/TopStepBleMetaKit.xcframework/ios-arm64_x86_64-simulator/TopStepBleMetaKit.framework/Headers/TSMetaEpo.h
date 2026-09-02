//
//  TSMetaEpo.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2026/7/9.
//

#import "TSBusinessBase.h"
#import "TSCommandDefines.h"
#import "PbSettingParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief EPO time info callback (returns TSMetaEpoTimeInfo)
 * @chinese 获取 EPO 时间信息的回调，返回协议层时间模型或错误
 *
 * @param timeInfo
 * EN: The EPO time info from device, or nil on failure
 * CN: 设备返回的 EPO 时间信息，失败时为 nil
 *
 * @param error
 * EN: Error info, nil on success
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSMetaEpoTimeCompletionBlock)(TSMetaEpoTimeInfo * _Nullable timeInfo, NSError * _Nullable error);

/**
 * @brief EPO(GNSS ephemeris) management class
 * @chinese EPO(GNSS 星历) 管理类
 *
 * @discussion
 * [EN]: EPO(Extended Prediction Orbit) is used to speed up the device GPS positioning.
 *       This class provides the device-side EPO commands: fetch/clear EPO info on device.
 * [CN]: EPO(扩展预测轨道，GNSS 星历) 用于加速设备 GPS 定位。
 *       本类提供设备侧 EPO 指令：获取/清除设备 EPO 信息。
 */
@interface TSMetaEpo : TSBusinessBase

/**
 * @brief Fetch EPO time info from device
 * @chinese 获取设备 EPO 时间信息
 *
 * @discussion
 * [EN]: 0x6B, App blocking GET command. App sends no payload, device replies with TSMetaEpoTimeInfo
 *       (validTime / updateTime, both are seconds since 2000).
 * [CN]: 0x6B，App 阻塞 GET 指令。App 发送时无数据，Device 回复携带 TSMetaEpoTimeInfo
 *       (validTime 有效时间 / updateTime 更新时间，均为距 2000 年的秒数)。
 *
 * @param completion
 * EN: Completion callback with EPO time info or error
 * CN: 完成回调，返回 EPO 时间信息或错误
 */
+ (void)fetchEpoTimeInfoWithCompletion:(nullable TSMetaEpoTimeCompletionBlock)completion;

/**
 * @brief Clear EPO info on device
 * @chinese 清除设备 EPO 信息
 *
 * @discussion
 * [EN]: 0x6C, App blocking SET command. App sends no payload, device replies with a common response.
 * [CN]: 0x6C，App 阻塞 SET 指令。App 发送时无数据，Device 回复携带 _CommonResponse。
 *
 * @param completion
 * EN: Completion callback with success status and error info
 * CN: 完成回调，包含成功状态和错误信息
 */
+ (void)clearEpoInfoWithCompletion:(nullable TSMetaCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
