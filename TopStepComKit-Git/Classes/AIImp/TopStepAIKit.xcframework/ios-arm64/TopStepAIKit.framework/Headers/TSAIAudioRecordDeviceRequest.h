//
//  TSAIAudioRecordDeviceRequest.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"
#import "TSAudioRecordDefines.h"

@class TSAIStartRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device-initiated AI recording start request
 * @chinese 设备发起的 AI 录音启动请求
 *
 * @discussion
 * [EN]: Delivered to the App through `registerOnDeviceRequestStartAIAudioRecording:`.
 *       `inputChannel` tells which microphone the device selected: SCO means the
 *       earbuds microphone, Opus means the device microphone (AIBuds charging case) and BuiltInMic
 *       means the phone microphone. Exact transports provide sourceRequest;
 *       pass it through TSAIAudioRecordConfig.expectedDeviceRequest. Legacy callers
 *       keep using expectedDeviceRequestIdentifier.
 * [CN]: 通过 `registerOnDeviceRequestStartAIAudioRecording:` 送达 App。
 *       `inputChannel` 表示设备选择的麦克风：SCO 为耳机麦克风，Opus 为设备麦克风（AIBuds充电仓），
 *       BuiltInMic 为手机麦克风。精确传输启动时将sourceRequest填入
 *       TSAIAudioRecordConfig.expectedDeviceRequest；旧调用方保留expectedDeviceRequestIdentifier。
 */
@interface TSAIAudioRecordDeviceRequest : NSObject <NSCopying>

/**
 * @brief Identifier of the pending device request
 * @chinese 待处理设备请求的标识
 */
@property (nonatomic, copy, readonly) NSString *requestIdentifier;

/**
 * @brief Immutable original request carried by an exact device transport
 * @chinese 精确设备传输携带的不可变原始请求
 *
 * @discussion
 * [EN]: Use this object as TSAIAudioRecordConfig.expectedDeviceRequest when accepting the request.
 * [CN]: 接受请求时将此对象传入TSAIAudioRecordConfig.expectedDeviceRequest。
 *
 * @note
 * [EN]: Nil for the legacy identifier-only factory; copies preserve the original object.
 * [CN]: 旧的仅标识工厂返回nil；复制时保留原对象。
 */
@property (nonatomic, strong, readonly, nullable) TSAIStartRequest *sourceRequest;

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
 * [EN]: SCO = earbuds microphone, Opus = device microphone (AIBuds charging case), BuiltInMic = phone microphone.
 * [CN]: SCO = 耳机麦克风，Opus = 设备麦克风（AIBuds充电仓），BuiltInMic = 手机麦克风。
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

/**
 * @brief Create device details retaining the original immutable start request
 * @chinese 创建保留原不可变启动请求的设备详情
 *
 * @param request
 * EN: Original device recording request, including its scene and exact input route.
 * CN: 包含场景与精确输入路由的原设备录音请求。
 *
 * @return
 * EN: Immutable details whose sourceRequest is the supplied original object.
 * CN: sourceRequest为传入原对象的不可变详情。
 */
+ (instancetype)requestWithStartRequest:(TSAIStartRequest *)request;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
