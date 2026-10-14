//
//  TSAIAudioRecordDeviceRequest.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"
#import "TSAudioRecordDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device-initiated AI recording start request
 * @chinese 设备发起的 AI 录音启动请求
 *
 * @discussion
 * [EN]: Delivered to the App through `registerOnDeviceRequestStartAIAudioRecording:`.
 *       `inputChannel` tells which microphone the device selected: SCO means the
 *       earbuds microphone, Opus means the charging-case microphone and BuiltInMic
 *       means the phone microphone. Pass `requestIdentifier` back through
 *       `TSAIAudioRecordConfig.expectedDeviceRequestIdentifier` when starting.
 * [CN]: 通过 `registerOnDeviceRequestStartAIAudioRecording:` 送达 App。
 *       `inputChannel` 表示设备选择的麦克风：SCO 为耳机麦克风，Opus 为充电仓麦克风，
 *       BuiltInMic 为手机麦克风。启动时把 `requestIdentifier` 回填到
 *       `TSAIAudioRecordConfig.expectedDeviceRequestIdentifier`。
 */
@interface TSAIAudioRecordDeviceRequest : NSObject <NSCopying>

/**
 * @brief Identifier of the pending device request
 * @chinese 待处理设备请求的标识
 */
@property (nonatomic, copy, readonly) NSString *requestIdentifier;

/**
 * @brief Recording scene requested by the device
 * @chinese 设备请求的录音场景
 */
@property (nonatomic, assign, readonly) TSAIAudioRecordScene scene;

/**
 * @brief Input channel selected by the device
 * @chinese 设备选择的输入通道
 *
 * @discussion
 * [EN]: SCO = earbuds microphone, Opus = charging-case microphone, BuiltInMic = phone microphone.
 * [CN]: SCO = 耳机麦克风，Opus = 充电仓麦克风，BuiltInMic = 手机麦克风。
 */
@property (nonatomic, assign, readonly) TSAIAudioInputChannel inputChannel;

/**
 * @brief Create a device start request
 * @chinese 创建设备启动请求
 *
 * @param requestIdentifier
 * EN: Identifier of the pending device request
 * CN: 待处理设备请求的标识
 *
 * @param scene
 * EN: Requested recording scene
 * CN: 请求的录音场景
 *
 * @param inputChannel
 * EN: Input channel selected by the device
 * CN: 设备选择的输入通道
 *
 * @return
 * EN: Immutable request instance
 * CN: 不可变的请求对象
 */
+ (instancetype)requestWithIdentifier:(NSString *)requestIdentifier
                                scene:(TSAIAudioRecordScene)scene
                         inputChannel:(TSAIAudioInputChannel)inputChannel;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
