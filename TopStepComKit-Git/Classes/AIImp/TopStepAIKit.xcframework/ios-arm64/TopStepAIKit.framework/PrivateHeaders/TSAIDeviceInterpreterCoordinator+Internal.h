//
//  TSAIDeviceInterpreterCoordinator+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

#import "TSAIDeviceBridge.h"
#import "TSAIDeviceVoiceTranslationOutputSink.h"
#import "TSAIInterpreterProvider+Internal.h"

@class TSAIDeviceVoiceTranslationConfig;
@class TSAIAudioRouteCoordinator;
@class TSAIAudioRouteConfiguration;
@class TSAIStartRequest;
@protocol TSAISystemAudioDriver;
@protocol TSAISystemAudioDriver;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal coordinator for one device-initiated voice translation flow
 * @chinese 单轮设备发起语音翻译的内部编排器
 */
@interface TSAIDeviceInterpreterCoordinator : NSObject

/** App 侧 PCM 输出对象，仅弱引用 */
@property (nonatomic, weak, nullable) id<TSAIDeviceVoiceTranslationOutputSink> outputSink;

/** @brief Provider system-audio driver @chinese Provider 系统音频驱动 */
@property (nonatomic, strong, nullable) id<TSAISystemAudioDriver> systemAudioDriver;

/**
 * @brief Resolve the audio driver of each session from its effective route (Context selection point)
 * @chinese 每次会话按实际路由向 Context 选择点要驱动；为 nil 或返回 nil 时沿用 systemAudioDriver
 *
 * @discussion
 * EN: With the device-session earbuds switch off this returns the Provider driver (no behaviour
 *     change). Earbuds drivers start asynchronously; their start failure arrives as an audio error.
 * CN: 设备会话耳机开关关闭时返回 Provider 驱动（行为不变）。耳机驱动异步启动，启动失败按音频错误上报。
 */
@property (nonatomic, copy, nullable) id<TSAISystemAudioDriver> _Nullable (^audioDriverResolver)(
    TSAIAudioRouteConfiguration *route);

/** @brief Shared audio-route lease coordinator @chinese 共享音频路由占用协调器 */
@property (nonatomic, strong, nullable) TSAIAudioRouteCoordinator *audioRouteCoordinator;

/**
 * @brief Create a coordinator bound to one Provider and one device bridge
 * @chinese 创建绑定单个 Provider 与设备 Bridge 的编排器
 * @param interpreterProvider EN: One-shot device PCM Provider. CN: 设备整段 PCM Provider。
 * @param deviceBridge EN: Device text output bridge. CN: 设备文本下行 Bridge。
 * @return EN: A coordinator instance. CN: 编排器实例。
 */
- (instancetype)initWithInterpreterProvider:
        (id<TSAIDeviceInterpreterProvider>)interpreterProvider
                                deviceBridge:
        (id<TSAIDeviceVoiceTranslationBridge>)deviceBridge NS_DESIGNATED_INITIALIZER;

/**
 * @brief Freeze the configuration used by following device events
 * @chinese 冻结后续设备事件使用的会话配置
 * @param config EN: Per-session configuration. CN: 本次会话配置。
 * @param sessionIdentifier EN: Public session identifier. CN: 对外会话标识。
 */
- (void)prepareSessionWithConfig:(TSAIDeviceVoiceTranslationConfig *)config
               sessionIdentifier:(NSString *)sessionIdentifier;

/**
 * @brief Stop one prepared device session
 * @chinese 停止一个已准备的设备会话
 * @param sessionIdentifier EN: Public session identifier. CN: 对外会话标识。
 */
- (void)stopPreparedSessionWithIdentifier:(NSString *)sessionIdentifier;

/**
 * @brief Release the prepared session after its current round finishes naturally
 * @chinese 当前轮次自然完成后释放已准备会话
 * @param sessionIdentifier EN: Public session identifier. CN: 对外会话标识。
 * @param completion EN: Called after coordinator resources are released. CN: 协调器资源释放后调用。
 */
- (void)finishPreparedSessionAfterCurrentRoundWithIdentifier:(NSString *)sessionIdentifier
                                                   completion:(nullable dispatch_block_t)completion;

/**
 * @brief Prepare one exact scene3 translation without starting device capture
 * @chinese 准备一个精确scene3翻译请求，不开启设备采集
 *
 * @param config
 * EN: Frozen explicit App languages and Opus input with None or SystemDefault output.
 * CN: 冻结的App显式语种，以及Opus输入、None或SystemDefault输出。
 *
 * @param sessionIdentifier
 * EN: Original local route/session identifier.
 * CN: 原本地路由及会话标识。
 *
 * @param request
 * EN: Exact immutable standard voice-translation request.
 * CN: 精确不可变的标准语音翻译原请求。
 *
 * @param completion
 * EN: Main-queue preparation result, once; success means local output is ready for capture.
 * CN: 主队列准备结果，回调一次；成功表示本地输出已准备好，可以采集。
 *
 * @return
 * EN: YES only when the original local operation was reserved synchronously; this does not mean output is ready.
 * CN: 仅当原本地操作已同步占位成功时返回YES；不代表输出已经就绪。
 */
- (BOOL)prepareSessionWithConfig:(TSAIDeviceVoiceTranslationConfig *)config
               sessionIdentifier:(NSString *)sessionIdentifier
                          request:(TSAIStartRequest *)request
                       completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Accept ordered PCM within the original request's finite input budget
 * @chinese 在原请求的有限输入预算内接收保序PCM
 *
 * @param pcmData
 * EN: 16 kHz mono Int16LE PCM; accepted queued and buffered input together is limited to 2 MiB.
 * CN: 16kHz单声道Int16LE PCM；已接纳的排队和缓冲输入合计不超过2MiB。
 *
 * @param request
 * EN: Exact original immutable request.
 * CN: 精确的原始不可变请求。
 */
- (void)appendPCMData:(NSData *)pcmData request:(TSAIStartRequest *)request;

/**
 * @brief End original input after all accepted PCM and start one-shot translation once
 * @chinese 在全部已接纳PCM之后结束原输入，仅启动一次整段翻译
 *
 * @param request
 * EN: Exact request whose input reached EOF; duplicate EOF is ignored.
 * CN: 输入到达EOF的精确原请求；重复EOF被忽略。
 */
- (void)finishInputForRequest:(TSAIStartRequest *)request;

/**
 * @brief Observe the original round's complete local terminal barrier
 * @chinese 订阅原轮次完整本地终态屏障
 *
 * @param request
 * EN: Exact request; register after prepare and before opening capture so overflow can be observed.
 * CN: 精确原请求；prepare后、开流前登记，以便观察溢出终态。
 *
 * @param completion
 * EN: Main-queue terminal error, once after Provider, text and audio release; registration does not end input.
 * CN: Provider、文字与音频释放后在主队列回调一次终态错误；登记不会结束输入。
 */
- (void)finishPreparedSessionForRequest:(TSAIStartRequest *)request
                            completion:(nullable void (^)(NSError * _Nullable error))completion;

/**
 * @brief Cancel only the original request and await real local release
 * @chinese 仅取消原请求并等待真实本地释放
 *
 * @param request
 * EN: Exact original immutable request.
 * CN: 精确的原始不可变请求。
 *
 * @param error
 * EN: Original cancellation or failure reason.
 * CN: 原取消或失败原因。
 *
 * @param completion
 * EN: Main-queue release result; a five-second failure preserves the unknown operation's reservation.
 * CN: 主队列释放结果；五秒后失败仍保留未知操作占位。
 */
- (void)cancelRequest:(TSAIStartRequest *)request
                 error:(NSError *)error
            completion:(nullable TSAICompletionBlock)completion;

/** @brief Begin a device round @chinese 开始设备翻译轮次 */
- (void)handleDeviceVoiceTranslationDidBegin;

/**
 * @brief Handle incremental device audio
 * @chinese 处理设备增量音频
 */
- (void)handleDeviceVoiceTranslationOpusData:(nullable NSData *)opusData
                                      pcmData:(nullable NSData *)pcmData
                               sourceLanguage:(TSAILanguage)sourceLanguage
                               targetLanguage:(TSAILanguage)targetLanguage;

/**
 * @brief Handle the device capture stop event
 * @chinese 处理设备采音停止事件
 */
- (void)handleDeviceVoiceTranslationDidStopWithOpusData:(nullable NSData *)opusData
                                                 pcmData:(nullable NSData *)pcmData
                                          sourceLanguage:(TSAILanguage)sourceLanguage
                                          targetLanguage:(TSAILanguage)targetLanguage;

/** @brief Apply a device playback command @chinese 执行设备播放指令 */
- (void)handleDeviceVoiceTranslationPlaybackState:
    (TSAIDeviceVoicePlaybackState)state;

/** @brief Invalidate all active and replayable tasks @chinese 使当前及可重播任务全部失效 */
- (void)invalidate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
