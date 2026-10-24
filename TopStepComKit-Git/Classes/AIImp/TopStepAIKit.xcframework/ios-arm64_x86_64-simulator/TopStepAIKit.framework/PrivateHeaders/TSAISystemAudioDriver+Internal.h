//
//  TSAISystemAudioDriver+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"
#import "TSAIAudioSessionArbiter+Internal.h"

NS_ASSUME_NONNULL_BEGIN

/** 错误 userInfo 键：失败阶段（取值 kTSAIAudioFailurePhaseStart 表示异步启动失败，缺省为运行期） */
static NSString * const kTSAIAudioFailurePhaseKey = @"audioFailurePhase";
/** 失败阶段：异步启动失败 */
static NSString * const kTSAIAudioFailurePhaseStart = @"start";
/** 错误 userInfo 键：失败影响范围（input 表示输入失效，output 只影响播放） */
static NSString * const kTSAIAudioFailureScopeKey = @"audioFailureScope";
/** 失败范围：输入失效 */
static NSString * const kTSAIAudioFailureScopeInput = @"input";
/** 失败范围：只影响播放 */
static NSString * const kTSAIAudioFailureScopeOutput = @"output";

/**
 * @brief Who started the session that needs an audio driver
 * @chinese 需要音频驱动的会话由谁发起
 */
typedef NS_ENUM(NSInteger, TSAIAudioDriverOwner) {
    /// @brief The user started it in the App @chinese 用户在 App 中发起
    TSAIAudioDriverOwnerApp = 0,
    /// @brief The device started it (key press on the case / watch) @chinese 设备发起（充电仓 / 手表按键）
    TSAIAudioDriverOwnerDevice = 1,
};

/**
 * @brief Scope of one start of a system audio driver
 * @chinese 一次启动的作用域：所有操作只对本次启动有效，过期后一律无效
 *
 * @discussion
 * EN: Every begin returns a new lease. Invalidation (stop, same-owner re-begin, preemption,
 *     watchdog, runtime loss) happens atomically on the calling thread; afterwards every call
 *     on the lease is a no-op and no callback of the lease is delivered except the terminal one.
 * CN: 每次 begin 返回一个新租约。作废（stop、同 owner 重新 begin、被抢占、看门狗、运行期失效）
 *     在调用线程上原子完成；之后对该租约的一切调用都无效，除终态外不再投递任何回调。
 *     线程契约：
 *     - 本协议的方法可在任意线程调用，立即返回，不等待音频会话操作；
 *     - 播放终态 completion、stop 的 completion 都在主线程回调，每个只回调一次。
 */
@protocol TSAISystemAudioLease <NSObject>

/** @brief NO once the lease is invalid @chinese 作废即 NO（原子） */
@property (atomic, readonly, getter=isActive) BOOL active;

/**
 * @brief Append output PCM for one voice
 * @chinese 播放：入队执行器；播放终态在主线程回调，只一次
 *
 * @discussion
 * EN: Pass completion only with the final chunk. On an invalid lease the chunk is dropped and
 *     the completion ends with the lease's terminal error (Cancelled after stop).
 * CN: 仅在最终分片传入 completion。租约已作废时分片直接丢弃，completion 以租约的终态错误结束
 *     （stop 之后为 Cancelled）。
 */
- (void)appendPCMData:(NSData *)pcmData
              voiceId:(NSString *)voiceId
               isFinal:(BOOL)isFinal
            completion:(nullable void (^)(BOOL success, NSError * _Nullable error))completion;

/** @brief Interrupt current output @chinese 打断：记账里同步退场，对厂商的打断在执行器上执行 */
- (void)interruptOutput;

/**
 * @brief Stop this start
 * @chinese 停止：同步作废，执行器上拆除；拆除完成后在主线程回调
 *
 * @discussion
 * EN: Safe to call more than once and on an already invalid lease (the completion still runs
 *     after the teardown that is already scheduled).
 * CN: 可重复调用，也可对已作废的租约调用（completion 仍在已安排的拆除之后回调）。
 */
- (void)stopWithCompletion:(nullable dispatch_block_t)completion;

@end

/**
 * @brief Internal system capture and playback driver
 * @chinese 内部系统采音与播放驱动
 *
 * @discussion
 * EN: Thread contract of the lease API (prefersAsynchronousStart == YES):
 *     - preflight and begin may be called on any thread, return immediately and never touch
 *       the audio session; all session writes and vendor engine start / stop run on the
 *       process-wide audio session executor;
 *     - completion, errorOccurred, inputLive and playback terminal callbacks run on the main
 *       queue, once each; pcmDataReceived runs on an audio thread and must not block.
 *     The unscoped methods below are kept for compatibility and act on the current start.
 * CN: 租约 API（prefersAsynchronousStart == YES）的线程契约：
 *     - preflight 与 begin 可在任意线程调用，立即返回，不读写音频会话；所有会话写操作与
 *       厂商音频引擎的启停都在进程级音频会话执行器上执行；
 *     - completion、errorOccurred、inputLive 与播放终态回调都在主线程，每个只回调一次；
 *       pcmDataReceived 在音频线程回调，不得阻塞。
 *     下面不带作用域的方法只为兼容保留，作用于「当前这次启动」。
 */
@protocol TSAISystemAudioDriver <NSObject>

/** @brief Whether the driver is available @chinese 驱动当前是否可用 */
@property (nonatomic, assign, readonly) BOOL isAvailable;

/** @brief Whether system voice processing is active @chinese 系统语音处理当前是否生效 */
@property (nonatomic, assign, readonly) BOOL isVoiceProcessingEnabled;

/**
 * @brief Start the system audio path for one complete route
 * @chinese 为一条完整路由启动系统音频链路
 * @param inputChannel EN: Effective input channel. CN: 生效输入通道。
 * @param outputChannel EN: Effective output channel. CN: 生效输出通道。
 * @param pcmHandler EN: Captured 16 kHz mono Int16LE PCM callback. CN: 采集到的 16 kHz 单声道 Int16LE PCM 回调。
 * @param errorHandler EN: Runtime audio-path error callback. CN: 音频链路运行时错误回调。userInfo.audioFailureScope 为 output 时仅影响播放，input 表示输入失效。
 * @param error EN: Start or route-validation error. CN: 启动或路由校验错误。
 * @return EN: YES after the route is active. CN: 路由激活后返回 YES。
 */
- (BOOL)startWithInputChannel:(TSAIAudioInputChannel)inputChannel
                outputChannel:(TSAIAudioOutputChannel)outputChannel
              pcmDataReceived:(nullable void (^)(NSData *pcmData))pcmHandler
                 errorOccurred:(nullable void (^)(NSError *error))errorHandler
                        error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Append output PCM for one voice
 * @chinese 为一段语音追加输出 PCM
 * @discussion EN: Pass completion only with the final chunk. The callback
 *             reports the real playback terminal state, not enqueue success.
 *             CN: 仅在最终分片传入 completion；该回调表示真实播放终态，
 *             而不是数据入队成功。
 */
- (void)appendPCMData:(NSData *)pcmData
              voiceId:(NSString *)voiceId
               isFinal:(BOOL)isFinal
            completion:(nullable void (^)(BOOL success, NSError * _Nullable error))completion;

/** @brief Interrupt current output @chinese 仅中断当前输出，不停止仍有效的系统采集 */
- (void)interruptOutput;

/** @brief Stop capture and playback @chinese 停止采音与播放 */
- (void)stop;

@optional

/**
 * @brief Whether callers use the asynchronous lease API
 * @chinese 是否走异步启动（耳机驱动恒为 YES；手机麦驱动受回退开关控制）；替代所有 selector 判断
 *
 * @discussion
 * EN: YES: callers use preflight + begin and operate on the returned lease. NO: callers use the
 *     synchronous start and the unscoped methods (the fallback switch keeps the old inline path).
 * CN: YES 时调用方使用 preflight + begin，并通过返回的租约操作；NO 时使用同步启动与不带作用域的方法
 *     （回退开关打开时保持旧的内联路径）。
 */
@property (nonatomic, assign, readonly) BOOL prefersAsynchronousStart;

/**
 * @brief Cheap synchronous checks before an asynchronous start
 * @chinese 异步启动前的同步预检
 *
 * @discussion
 * EN: Route support, microphone permission and microphone ownership, without touching the
 *     session. Lets callers fail before starting cloud work.
 * CN: 检查路由是否支持、麦克风权限与占用，不改动会话；便于调用方在启动云端任务前失败。
 */
- (nullable NSError *)preflightErrorForInputChannel:(TSAIAudioInputChannel)inputChannel
                                      outputChannel:(TSAIAudioOutputChannel)outputChannel;

/**
 * @brief Synchronous pre-checks including the lease priority
 * @chinese 同步预检：路由支持 · 权限（缓存）· 租约优先级；不读写会话
 *
 * @discussion
 * EN: Returns TSAIErrorCodeBusy when another owner of the same or higher priority holds the
 *     driver. An App request may preempt a device one; the same owner may replace its own lease.
 * CN: 其他 owner 以同级或更高优先级持有时返回 TSAIErrorCodeBusy。App 可以抢占设备发起的使用方；
 *     同一 owner 重新 begin 替换自己的旧租约。
 *
 * @param owner
 * EN: Feature name plus route session identifier, e.g. chat#chat-route.xxx
 * CN: 功能名 + 路由会话标识，例如 chat#chat-route.xxx
 */
- (nullable NSError *)preflightErrorForInputChannel:(TSAIAudioInputChannel)inputChannel
                                      outputChannel:(TSAIAudioOutputChannel)outputChannel
                                              owner:(NSString *)owner
                                           priority:(TSAIAudioSessionClaimPriority)priority;

/**
 * @brief Start the audio path asynchronously and return the lease at once
 * @chinese 异步启动，立即返回租约
 *
 * @discussion
 * EN: - completion: main queue, exactly once. success means the route is validated and the
 *       engine works. Stop or a same-owner re-begin ends it with Cancelled; a preemption before
 *       the start finished ends it with 1023 (reason Preempted). Start failures carry
 *       audioFailurePhase = start and audioFailureScope = input / output (playback-only: output).
 *     - inputLive: main queue, at most once, when the first captured buffer arrives (only for
 *       routes with input). It may arrive before completion.
 *     - errorOccurred: main queue, runtime failures after a successful start, including
 *       1023 Preempted / Interrupted / MediaServicesReset. Never delivered together with a
 *       failed completion for the same cause.
 *     - pcmDataReceived: audio thread; must not block.
 * CN: - completion：主线程，只一次。success 表示路由已校验、引擎在工作。被 stop 或同 owner 重新 begin 时
 *       为 Cancelled；启动完成前被抢占时为 1023（reason = Preempted）。启动失败的错误带
 *       audioFailurePhase = start 与 audioFailureScope = input / output（仅播放链路一律为 output）。
 *     - inputLive：主线程，最多一次，首个采音缓冲到达时（仅需要输入的路由）；可能早于 completion。
 *     - errorOccurred：主线程，启动成功之后的运行期失效，包括 1023 Preempted / Interrupted /
 *       MediaServicesReset；与失败的 completion 不会因同一原因重复投递。
 *     - pcmDataReceived：音频线程，不得阻塞。
 */
- (id<TSAISystemAudioLease>)beginWithInputChannel:(TSAIAudioInputChannel)inputChannel
                                    outputChannel:(TSAIAudioOutputChannel)outputChannel
                                            owner:(NSString *)owner
                                         priority:(TSAIAudioSessionClaimPriority)priority
                                  pcmDataReceived:(nullable void (^)(NSData *pcmData))pcmHandler
                                        inputLive:(nullable dispatch_block_t)inputLive
                                    errorOccurred:(nullable void (^)(NSError *error))errorHandler
                                       completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

/**
 * @brief Start the audio path asynchronously
 * @chinese 异步启动音频链路
 *
 * @discussion
 * EN: Drivers that can only start asynchronously (the earbuds driver) return NO from the
 *     synchronous start with TSAIErrorCodeNotSupported and userInfo requiresAsyncStart = YES.
 *     Kept for compatibility; callers check prefersAsynchronousStart and use the lease API.
 * CN: 只能异步启动的驱动（耳机驱动）的同步启动直接返回 NO，错误为 TSAIErrorCodeNotSupported，
 *     userInfo 带 requiresAsyncStart = YES。仅为兼容保留；调用方按 prefersAsynchronousStart 判断并使用租约 API。
 *
 * @param completion
 * EN: Called once on the main queue when the route is active or the start failed / was cancelled
 * CN: 路由生效、启动失败或被取消时在主线程回调一次
 */
- (void)startWithInputChannel:(TSAIAudioInputChannel)inputChannel
                outputChannel:(TSAIAudioOutputChannel)outputChannel
              pcmDataReceived:(nullable void (^)(NSData *pcmData))pcmHandler
                errorOccurred:(nullable void (^)(NSError *error))errorHandler
                   completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

/**
 * @brief Wait until every scheduled output buffer has played
 * @chinese 等待所有已排队的输出播完
 *
 * @param completion
 * EN: Called once on the main queue; drained is NO on timeout or stop
 * CN: 在主线程回调一次；超时或停止时 drained 为 NO
 */
- (void)drainOutputWithTimeout:(NSTimeInterval)timeout completion:(void (^)(BOOL drained))completion;

@end

NS_ASSUME_NONNULL_END
