//
//  TSAIAudioRecordSessionCoordinator.h
//  TopStepComKit-Git_Example
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRecordSessionState.h"

@class TSAIAudioRecordConfig;
@class TSAIAudioRecordDraft;
@class TSAIContext;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSNotificationName const TSAIAudioRecordSessionDidRequestPresentationNotification;
FOUNDATION_EXTERN NSNotificationName const TSAIAudioRecordSessionDidChangeNotification;
FOUNDATION_EXTERN NSNotificationName const TSAIAudioRecordSessionDidReceiveResultNotification;
FOUNDATION_EXTERN NSNotificationName const TSAIAudioRecordSessionDidCompleteNotification;

FOUNDATION_EXTERN NSString * const TSAIAudioRecordSessionStateUserInfoKey;
FOUNDATION_EXTERN NSString * const TSAIAudioRecordSessionDraftUserInfoKey;
FOUNDATION_EXTERN NSString * const TSAIAudioRecordSessionErrorUserInfoKey;
FOUNDATION_EXTERN NSString * const TSAIAudioRecordSessionAudioLevelUserInfoKey;

/**
 * @brief Microphone that supplies audio to one AI recording
 * @chinese 一次 AI 录音的拾音方式
 *
 * @discussion
 * [EN]: Device is the charging-case microphone (Opus over BLE, captured by the device).
 *       BluetoothHeadset is the earbuds microphone (SCO) and Phone is the phone microphone;
 *       for App-initiated sessions both are captured by the App and pushed to the SDK.
 *       They map to `TSAIAudioInputChannel` Opus / SCO / BuiltInMic.
 * [CN]: Device 为充电仓麦克风（设备采集，BLE Opus 上传）；BluetoothHeadset 为耳机麦克风（SCO），
 *       Phone 为手机麦克风，App 发起时两者由 App 自行采集后推送给 SDK。
 *       三者分别对应 `TSAIAudioInputChannel` 的 Opus / SCO / BuiltInMic。
 */
typedef NS_ENUM(NSInteger, TSAIAudioRecordPickupSource) {
    /// @brief Charging-case microphone (Opus) @chinese 充电仓麦克风（Opus）
    TSAIAudioRecordPickupSourceDevice = 0,
    /// @brief Phone built-in microphone (BuiltInMic) @chinese 手机麦克风（BuiltInMic）
    TSAIAudioRecordPickupSourcePhone,
    /// @brief Earbuds microphone over Bluetooth HFP (SCO) @chinese 耳机麦克风（SCO）
    TSAIAudioRecordPickupSourceBluetoothHeadset,
};

/// @brief Process-wide coordinator for App- and device-initiated AI audio recording.
/// @chinese App 与设备发起的 AI 录音进程级协调器。
@interface TSAIAudioRecordSessionCoordinator : NSObject <NSCopying, NSMutableCopying>

/// @brief Returns the shared recording coordinator.
/// @chinese 返回共享录音协调器。
+ (instancetype)sharedInstance;

/// @brief Snapshot of the current session state.
/// @chinese 当前会话状态快照。
@property (nonatomic, strong, readonly) TSAIAudioRecordSessionState *sessionState;

/// @brief Current in-memory recording draft.
/// @chinese 当前内存录音草稿。
@property (nonatomic, strong, nullable, readonly) TSAIAudioRecordDraft *currentDraft;

/// @brief Configuration used by the next App-initiated recording.
/// @chinese 下一次 App 主动录音使用的配置；设备主动请求固定使用设备音频输入。
@property (nonatomic, strong, readonly) TSAIAudioRecordConfig *preferredConfig;

/// @brief Pickup source of the current or latest session.
/// @chinese 当前或最近一次会话使用的拾音方式；设备发起的录音固定为设备麦克风。
@property (nonatomic, assign, readonly) TSAIAudioRecordPickupSource currentPickupSource;
/// @brief Latest recording or persistence error.
/// @chinese 最近一次录音或持久化错误。
@property (nonatomic, strong, nullable, readonly) NSError *lastError;

/// @brief Binds an active AI context and registers device callbacks.
/// @chinese 绑定已激活 AI Context，并注册设备回调。
/// @param context Active context. / 已激活的 Context。
- (void)bindActiveContext:(TSAIContext *)context;

/// @brief Unbinds a context that is no longer usable.
/// @chinese 解绑已不可用的 Context。
/// @param context Context to unbind. / 要解绑的 Context。
- (void)unbindContext:(TSAIContext *)context;

/// @brief Updates the configuration used by the next App-initiated recording.
/// @chinese 更新下一次 App 主动录音使用的配置；设备主动请求固定使用设备音频输入。
/// @param config Preferred recording configuration. / 首选录音配置。
- (void)updatePreferredConfig:(TSAIAudioRecordConfig *)config;

/// @brief Starts an App-initiated AI recording session.
/// @chinese 启动 App 发起的 AI 录音会话。
/// @param config Recording configuration. / 录音配置。
/// @param completion Start result callback. / 启动结果回调。
- (void)startRecordingWithConfig:(TSAIAudioRecordConfig *)config
                      completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

/**
 * @brief Starts an App-initiated AI recording with an explicit pickup source
 * @chinese 使用指定拾音方式启动 App 发起的 AI 录音
 *
 * @param config
 * EN: Recording configuration; inputSource is overwritten by the pickup source
 * CN: 录音配置；其 inputSource 会按拾音方式覆盖
 *
 * @param pickupSource
 * EN: Device, phone or Bluetooth headset microphone. Phone and headset request
 *     microphone permission and are captured by the App.
 * CN: 设备、手机或蓝牙耳机麦克风。选择手机或耳机时会请求麦克风权限并由 App 采集。
 *
 * @param completion
 * EN: Start result on the main thread
 * CN: 在主线程回调启动结果
 */
- (void)startRecordingWithConfig:(TSAIAudioRecordConfig *)config
                    pickupSource:(TSAIAudioRecordPickupSource)pickupSource
                      completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

/**
 * @brief Returns whether a pickup source can be chosen now
 * @chinese 返回某种拾音方式当前是否可选
 *
 * @param pickupSource
 * EN: Pickup source to check
 * CN: 需要检查的拾音方式
 *
 * @param reason
 * EN: User-facing reason when unavailable
 * CN: 不可用时返回给用户的原因
 *
 * @return
 * EN: YES when the source can be used for the next App-initiated recording
 * CN: 下一次 App 发起录音可使用该方式时返回 YES
 */
- (BOOL)isPickupSourceAvailable:(TSAIAudioRecordPickupSource)pickupSource
                         reason:(NSString * _Nullable * _Nullable)reason;

/// @brief Requests the current recording session to stop.
/// @chinese 请求停止当前录音会话。
- (void)stopRecording;

/**
 * @brief Pause the recording session
 * @chinese 暂停当前录音会话
 *
 * @param completion
 * EN: Main-thread result; fails when the session is not recording
 * CN: 主线程回调；会话不在录音中时失败
 */
- (void)pauseRecordingWithCompletion:(nullable void (^)(BOOL success, NSError * _Nullable error))completion;

/**
 * @brief Resume the paused recording session
 * @chinese 继续已暂停的录音会话
 *
 * @param completion
 * EN: Main-thread result; fails when the session is not paused
 * CN: 主线程回调；会话未暂停时失败
 */
- (void)resumeRecordingWithCompletion:(nullable void (^)(BOOL success, NSError * _Nullable error))completion;

/**
 * @brief Whether the connected device pauses and resumes in sync with the App
 * @chinese 已连接设备是否与 App 同步暂停/继续
 *
 * @return
 * EN: YES when the SDK reports device pause/resume support
 * CN: SDK 报告设备支持暂停/继续时返回 YES
 */
- (BOOL)isDevicePauseResumeSupported;

/// @brief Clears a terminal result and returns the Demo to its ready state.
/// @chinese 清除终态结果并让 Demo 返回准备状态。
- (void)prepareForNewSession;

/**
 * @brief Return whether the recording interface is ready to receive a start action
 * @chinese 返回录音接口当前是否可接收启动操作
 * @return
 * EN: YES when the active Context and recording Adapter are ready.
 * CN: 活动 Context 与录音 Adapter 就绪时返回 YES。
 */
- (BOOL)isRecordingInterfaceReady;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
