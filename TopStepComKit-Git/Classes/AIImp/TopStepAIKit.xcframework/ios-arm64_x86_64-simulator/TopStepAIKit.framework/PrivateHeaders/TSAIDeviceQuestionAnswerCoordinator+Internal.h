//
//  TSAIDeviceQuestionAnswerCoordinator+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/13.
//

#import <Foundation/Foundation.h>

#import "TSAIDeviceBridge.h"
#import "TSAIDeviceQuestionAnswerOutputSink.h"
#import "TSAIQuestionAnswerProvider.h"
#import "TSAIQuestionAnswerDefines.h"
#import "TSAISpeechProvider.h"

@class TSAIAudioRouteCoordinator;
@class TSAIAudioRouteConfiguration;
@class TSAIStartRequest;
@protocol TSAISystemAudioDriver;
@protocol TSAISystemAudioDriver;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal coordinator for device-initiated AI question-answer
 * @chinese 设备发起 AI 问答的内部编排器
 */
@interface TSAIDeviceQuestionAnswerCoordinator : NSObject

/**
 * @brief App-side complete-audio playback sink
 * @chinese App 侧完整音频播放输出对象
 */
@property (nonatomic, weak, nullable) id<TSAIDeviceQuestionAnswerOutputSink> outputSink;

/**
 * @brief Provider system-audio driver used by explicit system routes
 * @chinese 显式系统路由使用的 Provider 系统音频驱动
 */
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

/**
 * @brief Shared audio-route lease coordinator
 * @chinese 共享音频路由占用协调器
 */
@property (nonatomic, strong, nullable) TSAIAudioRouteCoordinator *audioRouteCoordinator;

/**
 * @brief Create a coordinator bound to AI providers and one device bridge
 * @chinese 创建绑定 AI Provider 与设备 Bridge 的编排器
 * @param speechProvider EN: Provider for PCM ASR and TTS. CN: PCM ASR 与 TTS Provider。
 * @param questionAnswerProvider EN: Provider for streaming question answering. CN: 流式问答 Provider。
 * @param deviceBridge EN: Device question-answer transport. CN: 设备问答传输 Bridge。
 * @return EN: A coordinator instance. CN: 编排器实例。
 */
- (instancetype)initWithSpeechProvider:(id<TSAISpeechProvider>)speechProvider
                questionAnswerProvider:(id<TSAIQuestionAnswerProvider>)questionAnswerProvider
                          deviceBridge:(id<TSAIDeviceQuestionAnswerBridge>)deviceBridge
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Freeze the configuration used by following device events
 * @chinese 冻结后续设备事件使用的会话配置
 * @param config EN: Per-session question-answer configuration. CN: 本次问答配置。
 * @param sessionIdentifier EN: Public session identifier. CN: 对外会话标识。
 */
- (void)prepareSessionWithConfig:(TSAIQuestionAnswerConfig *)config
               sessionIdentifier:(NSString *)sessionIdentifier;

/** @brief Prepare with a text observer @chinese 准备会话并绑定文字观察 */
- (void)prepareSessionWithConfig:(TSAIQuestionAnswerConfig *)config
              sessionIdentifier:(NSString *)sessionIdentifier
                        onEvent:(nullable TSAIDeviceQuestionAnswerEventBlock)onEvent;

/**
 * @brief Prepare a device question-answer session bound to its original request
 * @chinese 准备绑定原始请求的设备问答会话
 * @param config
 * EN: Configuration copied for this session.
 * CN: 为本次会话复制的配置。
 * @param sessionIdentifier
 * EN: Unique public session identifier.
 * CN: 唯一公开会话标识。
 * @param request
 * EN: Exact immutable original request; nil preserves legacy event semantics.
 * CN: 原始不可变请求对象；nil 保留旧事件语义。
 * @param onEvent
 * EN: Optional ordered main-queue text observer.
 * CN: 可选的主队列有序文字观察者。
 */
- (void)prepareSessionWithConfig:(TSAIQuestionAnswerConfig *)config
              sessionIdentifier:(NSString *)sessionIdentifier
                        request:(nullable TSAIStartRequest *)request
                        onEvent:(nullable TSAIDeviceQuestionAnswerEventBlock)onEvent;

/**
 * @brief Begin input for the exact prepared request
 * @chinese 为精确的已准备请求开始输入
 * @param request
 * EN: Original request object; other objects are ignored.
 * CN: 原始请求对象；忽略其他对象。
 */
- (void)beginInputForRequest:(TSAIStartRequest *)request;

/**
 * @brief Append standard PCM to the original request
 * @chinese 向原始请求追加标准 PCM
 * @param pcmData
 * EN: Copied 16 kHz mono Int16LE incremental PCM.
 * CN: 复制的 16 kHz 单声道 Int16LE 增量 PCM。
 * @param request
 * EN: Original request object.
 * CN: 原始请求对象。
 */
- (void)appendPCMData:(NSData *)pcmData request:(TSAIStartRequest *)request;

/**
 * @brief Finish the exact input while retaining its answer reservation
 * @chinese 结束精确输入并保留回答占位
 * @param request
 * EN: Original request object; repeated completion does not submit ASR twice.
 * CN: 原始请求对象；重复完成不会再次提交 ASR。
 */
- (void)finishInputForRequest:(TSAIStartRequest *)request;

/**
 * @brief Confirm the question belonging to the original request
 * @chinese 确认原始请求所属的问题
 * @param request
 * EN: Original request; confirmation is accepted only after final ASR delivery starts.
 * CN: 原始请求；仅最终 ASR 回写开始后接纳确认。
 */
- (void)confirmRequest:(TSAIStartRequest *)request;

/**
 * @brief Cancel the exact prepared request and invalidate its callbacks
 * @chinese 取消精确的已准备请求并使其回调失效
 * @param request
 * EN: Original request object.
 * CN: 原始请求对象。
 * @param error
 * EN: Original terminal error, or nil for caller cancellation.
 * CN: 原终态错误；调用方取消可传 nil。
 */
- (void)endRequest:(TSAIStartRequest *)request error:(nullable NSError *)error;

/**
 * @brief Await the exact question, confirmation, answer and output lifecycle
 * @chinese 等待精确问题、确认、回答与输出生命周期结束
 * @param request
 * EN: Original request whose input has completed.
 * CN: 已完成输入的原始请求。
 * @param completion
 * EN: Called once on the coordinator queue after release, with failure/cancellation or nil on success.
 * CN: 释放后在协调器队列回调一次；失败或取消返回错误，成功返回 nil。
 */
- (void)finishPreparedSessionForRequest:(TSAIStartRequest *)request
                           completion:(nullable void (^)(NSError * _Nullable error))completion;

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

/** @brief Enter the device question-answer scene @chinese 进入设备问答场景 */
- (void)handleDeviceQuestionAnswerDidEnter;

/** @brief Exit and cancel the device question-answer scene @chinese 退出并取消设备问答场景 */
- (void)handleDeviceQuestionAnswerDidExit;

/** @brief Begin a new question voice input @chinese 开始新一轮问题语音输入 */
- (void)handleDeviceQuestionAnswerVoiceDidBegin;

/**
 * @brief Append incremental question audio
 * @chinese 追加问题增量音频
 * @param opusData EN: Incremental Opus data, currently ignored. CN: 增量 Opus 数据，当前忽略。
 * @param pcmData EN: Incremental 16 kHz mono Int16LE PCM. CN: 增量 16 kHz 单声道 Int16LE PCM。
 */
- (void)handleDeviceQuestionAnswerOpusData:(nullable NSData *)opusData
                                    pcmData:(nullable NSData *)pcmData;

/** @brief Stop the current voice input and start one-shot ASR @chinese 结束当前语音输入并启动一次性 ASR */
- (void)handleDeviceQuestionAnswerVoiceDidStop;

/**
 * @brief Handle a reserved device confirmation event
 * @chinese 处理预留的设备确认事件
 * @discussion EN: The current no-confirmation flow intentionally ignores it.
 *             CN: 当前免确认流程会主动忽略此事件。
 */
- (void)handleDeviceQuestionAnswerDidConfirm;

/** @brief Cancel all work and invalidate late callbacks @chinese 取消全部任务并使迟到回调失效 */
- (void)invalidate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
