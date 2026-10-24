//
//  TSAIEarbudsAudioEngine+Internal.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/15.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"
#import "TSAIAudioSessionArbiter+Internal.h"

@protocol TSAIAudioSessionControlling;
@protocol TSAIAudioSessionPort;

NS_ASSUME_NONNULL_BEGIN

/// 新记录了一个校验成功的耳机麦克风端口（内部通知，任意线程）
FOUNDATION_EXPORT NSNotificationName const TSAIEarbudsVerifiedPortsDidChangeNotification;

/**
 * @brief Runtime events of the earbuds audio engine
 * @chinese 耳机音频引擎的运行期事件
 */
typedef NS_ENUM(NSInteger, TSAIEarbudsAudioEngineEvent) {
    /// @brief The earbuds microphone is routed and capturing @chinese 耳机麦克风已生效并开始采集
    TSAIEarbudsAudioEngineEventReady = 0,
    /// @brief The input left the earbuds; waiting for them (silence is sent meanwhile) @chinese 输入离开耳机，等待恢复（期间上送静音）
    TSAIEarbudsAudioEngineEventRecovering = 1,
    /// @brief The earbuds microphone came back @chinese 耳机麦克风已恢复
    TSAIEarbudsAudioEngineEventRecovered = 2,
    /// @brief The system interrupted the session (call, Siri, ...) @chinese 被系统打断（来电、Siri 等）
    TSAIEarbudsAudioEngineEventInterrupted = 3,
    /// @brief The input is lost for good; the engine has stopped @chinese 输入最终丢失，引擎已停止
    TSAIEarbudsAudioEngineEventLost = 4,
};

/**
 * @brief State of the earbuds audio engine
 * @chinese 耳机音频引擎的状态
 */
typedef NS_ENUM(NSInteger, TSAIEarbudsAudioEngineState) {
    /// @brief Not started, or stopped @chinese 未启动或已停止
    TSAIEarbudsAudioEngineStateIdle = 0,
    /// @brief Configuring and activating the session @chinese 正在配置并激活会话
    TSAIEarbudsAudioEngineStateActivating = 1,
    /// @brief Waiting for the system to route the input to the earbuds @chinese 等待系统把输入切到耳机
    TSAIEarbudsAudioEngineStateWaitingForRoute = 2,
    /// @brief Capturing from the earbuds @chinese 正在从耳机采集
    TSAIEarbudsAudioEngineStateReady = 3,
    /// @brief Input left the earbuds, waiting within the grace period @chinese 输入离开耳机，宽限期内等待恢复
    TSAIEarbudsAudioEngineStateRecovering = 4,
    /// @brief Interrupted by the system @chinese 被系统打断
    TSAIEarbudsAudioEngineStateInterrupted = 5,
};

/**
 * @brief Capture / playback graph behind the engine (AVAudioEngine); replaceable in unit tests
 * @chinese 引擎背后的采集 / 播放图（AVAudioEngine）；单测可替换
 *
 * @discussion
 * EN: Called only on the engine queue (the audio session executor since P1b).
 * CN: 只在引擎队列调用（P1b 起即进程级音频会话执行器）。
 */
@protocol TSAIEarbudsAudioIO <NSObject>

/** @brief Hardware input sample rate (8000 for CVSD, 16000 for mSBC) @chinese 硬件输入采样率（CVSD 为 8000，mSBC 为 16000） */
@property (nonatomic, assign, readonly) double inputSampleRate;

/** @brief Whether voice processing is active @chinese 语音处理是否生效 */
@property (nonatomic, assign, readonly, getter=isVoiceProcessingEnabled) BOOL voiceProcessingEnabled;

/**
 * @brief Build and start the graph on the current route
 * @chinese 在当前路由上搭建并启动音频图
 *
 * @param pcmHandler
 * EN: 16 kHz mono Int16LE PCM, called on an audio thread
 * CN: 16 kHz 单声道 Int16LE PCM，在音频线程回调
 *
 * @param configurationChangeHandler
 * EN: Called on an arbitrary thread when the graph configuration changed
 * CN: 音频图配置变化时在任意线程回调
 */
- (BOOL)startWithPlaybackEnabled:(BOOL)playbackEnabled
          voiceProcessingEnabled:(BOOL)voiceProcessingEnabled
                      pcmHandler:(void (^)(NSData *pcmData))pcmHandler
      configurationChangeHandler:(void (^)(void))configurationChangeHandler
                           error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Schedule 16 kHz mono Int16LE PCM for playback
 * @chinese 排入一段 16 kHz 单声道 Int16LE PCM 待播放
 *
 * @param completion
 * EN: Called once on an arbitrary thread after the data played or playback stopped; not called when NO is returned
 * CN: 数据播完或播放被停止后在任意线程回调一次；返回 NO 时不回调
 */
- (BOOL)schedulePlaybackPCMData:(NSData *)pcmData completion:(void (^)(void))completion;

/** @brief Stop playback; scheduled data is dropped and its completions fire @chinese 停止播放：丢弃已排队数据并触发其回调 */
- (void)stopPlayback;

/** @brief Tear the graph down @chinese 拆除音频图 */
- (void)stop;

@end

/**
 * @brief Start configuration of the earbuds audio engine
 * @chinese 耳机音频引擎的启动配置
 */
@interface TSAIEarbudsAudioEngineConfiguration : NSObject <NSCopying>

/** @brief Owner name for logs and the arbiter @chinese 使用者名称（日志与仲裁用） */
@property (nonatomic, copy) NSString *owner;

/** @brief Claim priority, default App @chinese 持有优先级，默认 App */
@property (nonatomic, assign) TSAIAudioSessionClaimPriority priority;

/** @brief Also play through the earbuds, default NO @chinese 是否同时经耳机播放，默认 NO */
@property (nonatomic, assign) BOOL playbackEnabled;

/** @brief Enable voice processing (VoiceChat mode), default NO @chinese 是否开启语音处理（VoiceChat 模式），默认 NO */
@property (nonatomic, assign) BOOL voiceProcessingEnabled;

/** @brief How long to wait for the earbuds route at start, default 2 s @chinese 启动时等待耳机路由的时长，默认 2 秒 */
@property (nonatomic, assign) NSTimeInterval routeWaitTimeout;

/** @brief Grace period after the earbuds left, default 5 s @chinese 耳机离开后的宽限期，默认 5 秒 */
@property (nonatomic, assign) NSTimeInterval reconnectGracePeriod;

/** @brief How long an interruption may last, default 10 s @chinese 系统打断最长等待时长，默认 10 秒 */
@property (nonatomic, assign) NSTimeInterval interruptionGracePeriod;

@end

/**
 * @brief Which HFP port to use, and why none could be chosen
 * @chinese 选哪个 HFP 端口，以及选不出时的原因
 */
@interface TSAIEarbudsPortSelection : NSObject

/** @brief Chosen port, nil when none @chinese 选中的端口，没有时为 nil */
@property (nonatomic, strong, readonly, nullable) id<TSAIAudioSessionPort> port;

/** @brief Whether the port address matched the headset in the route @chinese 端口地址是否与路由中的耳机一致 */
@property (nonatomic, assign, readonly, getter=isAddressMatched) BOOL addressMatched;

/** @brief Number of HFP ports offered @chinese 系统提供的 HFP 端口数 */
@property (nonatomic, assign, readonly) NSUInteger hfpPortCount;

/** @brief Why no port was chosen (NeverSeen / ForeignHeadset) @chinese 选不出端口的原因（NeverSeen / ForeignHeadset） */
@property (nonatomic, assign, readonly) TSAIEarbudsMicrophoneFailureReason failureReason;

/**
 * @brief Choose the HFP port
 * @chinese 选择 HFP 端口
 *
 * @discussion
 * EN: Prefers the port whose UID address equals the headset address. A single HFP port is used
 *     (unconfirmed) only when the headset address is unknown or the port UID carries no address;
 *     otherwise unmatched ports fail with ForeignHeadset.
 * CN: 优先选 UID 地址与耳机地址相同的端口。只有一个 HFP 端口时，仅在耳机地址未知或端口 UID 不含地址时
 *     选用（未确认）；其余匹配不上的情况失败，原因为 ForeignHeadset（多半是车载等其他设备）。
 *
 * @param inputs
 * EN: Available inputs
 * CN: 可用输入
 *
 * @param headsetAddress
 * EN: Address of the headset in the route (from A2DP / HFP port UIDs), nil when unknown
 * CN: 路由中耳机的地址（取自 A2DP / HFP 端口 UID），未知时为 nil
 */
+ (instancetype)selectionFromInputs:(NSArray<id<TSAIAudioSessionPort>> *)inputs
                     headsetAddress:(nullable NSString *)headsetAddress;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * @brief The single AIKit engine for the Bluetooth earbuds microphone (HFP)
 * @chinese AIKit 唯一的蓝牙耳机麦克风（HFP）引擎
 *
 * @discussion
 * EN: Captures the earbuds microphone as 16 kHz mono Int16LE PCM, optionally plays through the
 *     earbuds on the same graph. Start is asynchronous only. It never prompts for the microphone
 *     permission and never deactivates the session itself (the arbiter does), with one exception:
 *     while starting, when another connected Bluetooth device (e.g. a watch with Bluetooth calling)
 *     keeps the call audio, it re-activates the session once to take the route, only when it is the
 *     sole holder and the App is in the foreground.
 * CN: 以 16 kHz 单声道 Int16LE PCM 采集耳机麦克风，可在同一音频图上经耳机播放。只支持异步启动。
 *     不弹麦克风授权窗，也不自行释放会话（由仲裁者负责）；唯一例外：启动时通话音频被另一台已连接的
 *     蓝牙设备（如支持蓝牙通话的手表）占用，且本引擎是唯一持有者、App 在前台时，重新激活一次会话争取路由。
 *     - 启动：权限 → 仲裁持有 → PlayAndRecord + AllowBluetooth → 激活 → 按 UID 地址选 HFP 并设为首选输入
 *       → 等 routeWaitTimeout，期间 HFP 一出现就再设 → 确认输入是 HFP 后才搭音频图 → Ready。
 *       通话音频被另一台蓝牙设备占用时，持续 routeKickDelay（或等待到期时）重新激活一次会话并重新计时，
 *       因此最长约为 2 × routeWaitTimeout；仍不切则 1022 + OtherDeviceActive，并带该设备名称。
 *       失败：1021（权限）/ 1022（耳机麦不可用，带原因）/ 1007（被占用）/ 1023（启动中被更高优先级抢占）；
 *       启动中 stop 回调 1008。等待路由期间已上送静音帧。
 *     - 运行期：耳机断开或入仓进入 Recovering，宽限期内每 0.5 秒重选；系统打断进入 Interrupted，
 *       结束且 shouldResume 时恢复；HFP 仍在但路由被切走时只重选一次，短时间内再被切走即以 1023 结束；
 *       会话被进程内其他组件改写时有限次重新声明。Recovering / Interrupted 期间每 100 ms 上送一帧静音，
 *       输入离开耳机后采到的数据一律丢弃。
 *     公开方法可在任意线程调用、立即返回；start 回调与事件在主线程，播放回调在引擎队列。
 *     线程（P1b）：引擎直接使用进程级音频会话执行器的队列，会话写操作与音频图启停都在执行器上，
 *     与手机麦驱动的启停、仲裁者的会话恢复全序；stop 不再同步等待。
 */
@interface TSAIEarbudsAudioEngine : NSObject

/** @brief Current state @chinese 当前状态 */
@property (atomic, assign, readonly) TSAIEarbudsAudioEngineState state;

/** @brief Hardware input sample rate while capturing, 0 otherwise @chinese 采集中的硬件输入采样率，否则为 0 */
@property (atomic, assign, readonly) double inputSampleRate;

/** @brief UID of the earbuds microphone in use @chinese 正在使用的耳机麦克风端口 UID */
@property (atomic, copy, readonly, nullable) NSString *inputPortUID;

/** @brief Whether voice processing is active @chinese 语音处理是否生效 */
@property (atomic, assign, readonly, getter=isVoiceProcessingEnabled) BOOL voiceProcessingEnabled;

/** @brief Route check interval while starting, default 0.1 s (tests shorten it) @chinese 启动等待期间的检查间隔，默认 0.1 秒（单测可缩短） */
@property (nonatomic, assign) NSTimeInterval routeCheckInterval;

/** @brief Re-select interval while recovering, default 0.5 s @chinese 恢复期间的重选间隔，默认 0.5 秒 */
@property (nonatomic, assign) NSTimeInterval recoveryPollInterval;

/**
 * @brief How long another Bluetooth device may hold the call audio while starting before the session is
 *        re-activated once to take it, default 1 s (tests shorten it)
 * @chinese 启动时通话音频被另一台蓝牙设备占用多久后重新激活一次会话争取路由，默认 1 秒（单测可缩短）
 */
@property (nonatomic, assign) NSTimeInterval routeKickDelay;

/** @brief Second route switch within this window ends the session, default 10 s @chinese 在该时间窗内第二次被切走路由即结束，默认 10 秒 */
@property (nonatomic, assign) NSTimeInterval userRouteChangeWindow;

/**
 * @brief Engine over the shared session and arbiter
 * @chinese 作用于共享会话与仲裁者的引擎
 */
- (instancetype)init;

/**
 * @brief Engine with injected dependencies (unit tests)
 * @chinese 注入依赖的引擎（单测用）
 */
- (instancetype)initWithAudioSession:(id<TSAIAudioSessionControlling>)audioSession
                             arbiter:(TSAIAudioSessionArbiter *)arbiter
                           ioFactory:(id<TSAIEarbudsAudioIO> (^)(void))ioFactory NS_DESIGNATED_INITIALIZER;

/**
 * @brief Start capturing from the earbuds microphone
 * @chinese 开始从耳机麦克风采集
 *
 * @param configuration
 * EN: Start configuration
 * CN: 启动配置
 *
 * @param pcmHandler
 * EN: 16 kHz mono Int16LE PCM (silence while waiting / recovering), called on an internal thread.
 *     Never call -stop from inside it.
 * CN: 16 kHz 单声道 Int16LE PCM（等待路由 / 恢复期间为静音），在内部线程回调；不要在回调内调用 -stop。
 *
 * @param eventHandler
 * EN: Runtime events on the main queue; Lost carries a 1023 error and means the engine stopped
 * CN: 运行期事件，主线程回调；Lost 带 1023 错误，表示引擎已停止
 *
 * @param completion
 * EN: Called once on the main queue: nil when Ready, otherwise the start error
 * CN: 在主线程回调一次：Ready 时为 nil，否则为启动错误
 */
- (void)startWithConfiguration:(TSAIEarbudsAudioEngineConfiguration *)configuration
                    pcmHandler:(void (^)(NSData *pcmData))pcmHandler
                  eventHandler:(nullable void (^)(TSAIEarbudsAudioEngineEvent event, NSError * _Nullable error))eventHandler
                    completion:(void (^)(NSError * _Nullable error))completion;

/**
 * @brief Cheap synchronous checks before starting (no session change)
 * @chinese 启动前的同步预检（不改动会话）
 *
 * @discussion
 * EN: Microphone permission (1021) and whether the earbuds microphone is held at the same or a
 *     higher priority (1007). Lets callers fail before starting cloud work.
 * CN: 检查麦克风权限（1021）与耳机麦克风是否已被同级或更高优先级占用（1007），
 *     便于调用方在启动云端任务前失败。
 *
 * @return
 * EN: The error a start would report, or nil
 * CN: 启动会报告的错误；可以启动时为 nil
 */
- (nullable NSError *)preflightErrorForPriority:(TSAIAudioSessionClaimPriority)priority;

/**
 * @brief Schedule 16 kHz mono Int16LE PCM for playback through the earbuds
 * @chinese 排入一段 16 kHz 单声道 Int16LE PCM 经耳机播放
 *
 * @param completion
 * EN: Called once on the engine queue: YES when played back, NO when dropped (not Ready,
 *     playback disabled, interrupted or route lost)
 * CN: 在引擎队列回调一次：播完为 YES；被丢弃（未就绪、未启用播放、被打断或路由丢失）为 NO
 */
- (void)schedulePlaybackPCMData:(NSData *)pcmData completion:(nullable void (^)(BOOL played))completion;

/** @brief Drop scheduled playback; capture continues @chinese 丢弃已排队的播放，采集继续 */
- (void)interruptPlayback;

/**
 * @brief Stop and release the claim (idempotent, asynchronous)
 * @chinese 停止并释放持有（幂等、异步）
 *
 * @discussion
 * EN: Invalidates on the calling thread at once: a queued start ends with Cancelled, Ready / events already
 *     queued for the main queue are dropped, captured data is no longer forwarded. The teardown (audio graph,
 *     claim release, session restore by the arbiter) runs on the audio session executor, inline when already
 *     on it, so stopping from dealloc or from a callback never deadlocks. A start issued afterwards runs after it.
 *     Until the teardown and the session restore finished, the lease registry is not idle
 *     (TSAIAudioSessionDidBecomeIdleNotification comes after them).
 * CN: 在调用线程上立即作废：排队中的启动以 Cancelled 结束，已排到主线程的就绪 / 事件不再投递，采集数据不再转发。
 *     拆除（音频图、释放持有、仲裁者恢复会话）在音频会话执行器上进行，已在执行器上时内联执行，
 *     因此在 dealloc 或回调里停止都不会死锁；之后发起的启动排在拆除之后。
 *     拆除与会话恢复完成之前，租约登记不算空闲（TSAIAudioSessionDidBecomeIdleNotification 在它们之后发出）。
 */
- (void)stop;

/**
 * @brief UID of an earbuds microphone port verified on this phone for the given headset address
 * @chinese 这台手机上曾为该耳机地址校验成功的耳机麦克风端口 UID
 *
 * @discussion
 * EN: Recorded when a start reaches Ready on a port whose address matched the headset address
 *     taken from the route before activation (so another device such as a watch is never recorded);
 *     kept across launches (last 16).
 * CN: 启动到达 Ready、且端口地址与激活前从原有路由取得的耳机地址匹配时记录（避免把手表等其他设备记成耳机）；
 *     跨启动保存（最近 16 个）。
 */
+ (nullable NSString *)verifiedPortUIDForHeadsetAddress:(nullable NSString *)address;

@end

NS_ASSUME_NONNULL_END
