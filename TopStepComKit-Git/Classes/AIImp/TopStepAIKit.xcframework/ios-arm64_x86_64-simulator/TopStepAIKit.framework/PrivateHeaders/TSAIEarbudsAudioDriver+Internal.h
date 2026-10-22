//
//  TSAIEarbudsAudioDriver+Internal.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/16.
//

#import <Foundation/Foundation.h>

#import "TSAIEarbudsAudioEngine+Internal.h"
#import "TSAIFeatureDefines.h"
#import "TSAISystemAudioDriver+Internal.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief System audio driver for the Bluetooth earbuds microphone, backed by TSAIEarbudsAudioEngine
 * @chinese 蓝牙耳机麦克风的系统音频驱动，基于 TSAIEarbudsAudioEngine
 *
 * @discussion
 * EN: SCO input only. Output SCO / SystemDefault plays through the same engine; None and Opus
 *     capture only (Opus output stays with the device PCM router). Start is asynchronous only:
 *     the synchronous start returns NO (NotSupported, requiresAsyncStart). One instance per session.
 * CN: 只支持 SCO 输入。输出为 SCO / SystemDefault 时经同一引擎播放；None 与 Opus 只采集
 *     （Opus 输出仍由设备 PCM Router 负责）。只支持异步启动：同步启动返回 NO
 *     （NotSupported，requiresAsyncStart）。每个会话一个实例。
 *     - 播放：逐语音完成回调，最终分片播完才回调成功；interruptOutput 以 Cancelled 结束排队的语音，
 *       此后同一 voiceId 的迟到分片直接丢弃。voiceId 由调用方保证唯一。
 *     - 运行期输入最终丢失：errorOccurred 回调 1023，userInfo.audioFailureScope = input。
 *     - 租约 API：prefersAsynchronousStart 恒为 YES；begin 返回的租约就是驱动本身（每个会话一个实例），
 *       不发 inputLive，InputReady 以 completion（HFP 就绪）为准。
 *     - 停止（P1b）：stop / stopWithCompletion: 在调用线程上同步作废，引擎在音频会话执行器上拆除，不阻塞调用线程；
 *       stopWithCompletion: 的回调在拆除完成后。dealloc 中的停止同样不会死锁。
 *     回调均在主线程。
 */
@interface TSAIEarbudsAudioDriver : NSObject <TSAISystemAudioDriver, TSAISystemAudioLease>

/** @brief Runtime input events (Ready / Recovering / Recovered / Interrupted) on the main queue @chinese 运行期输入事件（主线程） */
@property (nonatomic, copy, nullable) void (^inputEventHandler)(TSAIEarbudsAudioEngineEvent event);

/** @brief Grace period after the earbuds left, default 5 s; set before start @chinese 耳机离开后的宽限期，默认 5 秒；启动前设置 */
@property (nonatomic, assign) NSTimeInterval reconnectGracePeriod;

/**
 * @brief Request system voice processing (echo cancellation), default NO; set before start
 * @chinese 请求系统语音处理（回声消除），默认 NO；启动前设置
 *
 * @discussion
 * EN: Used when earbuds playback runs together with barge-in. Falls back to plain capture when unavailable.
 * CN: 耳机播放且允许插话时使用；系统不支持时退回普通采集，不报错。
 */
@property (nonatomic, assign) BOOL voiceProcessingRequested;

/**
 * @brief Replace captured PCM with silence while playing (plus a short tail), default NO
 * @chinese 播放期间（含短暂尾音）把采集数据替换为等长静音，默认 NO
 *
 * @discussion
 * EN: Uplink gating against self-interruption when barge-in is not wanted. The stream keeps flowing.
 * CN: 不需要插话时用于防止被自己的回答打断；数据流不断，只是内容为静音。
 */
@property (atomic, assign) BOOL suppressesInputDuringPlayback;

/**
 * @brief Feature reported in TSAIEarbudsMicrophoneInputDidChangeNotification
 * @chinese 运行期通知（TSAIEarbudsMicrophoneInputDidChangeNotification）中的功能
 */
@property (atomic, assign) TSAIFeatureOptions notificationFeature;

/**
 * @brief Task identifier reported in the runtime notification (route session id when there is no task)
 * @chinese 运行期通知中的任务标识（没有任务时为路由会话标识）
 */
@property (atomic, copy, nullable) NSString *notificationTaskIdentifier;

/** @brief Hardware input sample rate while capturing @chinese 采集中的硬件输入采样率 */
@property (nonatomic, assign, readonly) double inputSampleRate;

/** @brief UID of the earbuds microphone in use @chinese 正在使用的耳机麦克风端口 UID */
@property (nonatomic, copy, readonly, nullable) NSString *inputPortUID;

/**
 * @brief Driver over a new engine
 * @chinese 使用新引擎的驱动
 *
 * @param owner
 * EN: Owner name for logs and the arbiter
 * CN: 使用者名称（日志与仲裁用）
 *
 * @param priority
 * EN: Claim priority
 * CN: 持有优先级
 */
- (instancetype)initWithOwner:(NSString *)owner priority:(TSAIAudioSessionClaimPriority)priority;

/**
 * @brief Driver over the given engine (unit tests)
 * @chinese 使用指定引擎的驱动（单测用）
 */
- (instancetype)initWithEngine:(TSAIEarbudsAudioEngine *)engine
                         owner:(NSString *)owner
                      priority:(TSAIAudioSessionClaimPriority)priority NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
