//
//  TSAIDeviceBridge.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIContractDefines.h"
#import "TSAIDefines.h"
#import "TSAudioRecordDefines.h"

@class TSAIContext;
@class TSAIDeviceEarbudsStatus;
@class TSAIStartRequest;
@class TSAIQuestionAnswerPartialResult;
@class TSAIInterpreterContent;
@protocol TSAIDeviceBridgeEventSink;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Audio channel used by a device-side AI chat session
 * @chinese 设备侧 AI 对话会话使用的音频通道
 */
typedef NS_ENUM(NSInteger, TSAIDeviceBridgeChatAudioChannel) {
    TSAIDeviceBridgeChatAudioChannelUnknown = -1,
    TSAIDeviceBridgeChatAudioChannelSCO = 0,
    TSAIDeviceBridgeChatAudioChannelOpusInA2DPOut = 1,
    TSAIDeviceBridgeChatAudioChannelOpusInOpusOut = 2,
    TSAIDeviceBridgeChatAudioChannelPhoneMicrophone = 3,
};

/**
 * @brief Result type for writing question ASR text back to the device
 * @chinese 向设备回写问题 ASR 文本时使用的结果类型
 */
typedef NS_ENUM(NSInteger, TSAIDeviceQuestionASRResultType) {
    TSAIDeviceQuestionASRResultTypeUnknown = -1,
    TSAIDeviceQuestionASRResultTypeSuccess = 0,
    TSAIDeviceQuestionASRResultTypeCustomError = 1,
    TSAIDeviceQuestionASRResultTypeNetworkUnavailable = 2,
};

/**
 * @brief Result type for writing an AI answer back to the device
 * @chinese 向设备回写 AI 答案时使用的结果类型
 */
typedef NS_ENUM(NSInteger, TSAIDeviceQuestionAnswerResultType) {
    TSAIDeviceQuestionAnswerResultTypeCustomError = 0,
    TSAIDeviceQuestionAnswerResultTypeAnswer = 1,
    TSAIDeviceQuestionAnswerResultTypeNetworkUnavailable = 2,
    TSAIDeviceQuestionAnswerResultTypeUnknownError = 3,
};

/**
 * @brief Text type returned to a device voice-translation session
 * @chinese 回写设备语音翻译会话的文本类型
 */
typedef NS_ENUM(NSInteger, TSAIDeviceVoiceTranslationTextType) {
    TSAIDeviceVoiceTranslationTextTypeUnknown = -1,
    TSAIDeviceVoiceTranslationTextTypeOriginal = 0,
    TSAIDeviceVoiceTranslationTextTypeTranslated = 1,
};

/**
 * @brief Playback command requested by the device for translated speech
 * @chinese 设备请求的译文语音播放指令
 */
typedef NS_ENUM(NSInteger, TSAIDeviceVoicePlaybackState) {
    TSAIDeviceVoicePlaybackStateUnknown = -1,
    TSAIDeviceVoicePlaybackStateStopped = 0,
    TSAIDeviceVoicePlaybackStatePlaying = 1,
    TSAIDeviceVoicePlaybackStatePaused = 2,
    TSAIDeviceVoicePlaybackStateResumed = 3,
};

/**
 * @brief Root protocol bridging one device platform into AIKit
 * @chinese 将一个设备平台桥接到 AIKit 的根协议
 */
@protocol TSAIDeviceBridge <NSObject>

/**
 * @brief Stable platform identifier
 * @chinese 稳定的平台标识
 */
@property (nonatomic, copy, readonly) NSString *platformIdentifier;

/**
 * @brief Current device identifier
 * @chinese 当前设备标识
 */
@property (nonatomic, copy, readonly, nullable) NSString *deviceIdentifier;

/**
 * @brief Whether a device is connected
 * @chinese 当前是否已有设备连接
 * @return EN: YES when connected. CN: 设备已连接时返回 YES。
 */
- (BOOL)isDeviceConnected;

/**
 * @brief Activate event forwarding for one Context lifecycle
 * @chinese 为一次 Context 生命周期激活事件转发
 *
 * @param activationToken EN: Token identifying this activation. CN: 本次激活的标识。
 * @param eventSink EN: Sink receiving device events. CN: 接收设备事件的对象。
 * @param completion EN: Activation completion. CN: 激活完成回调。
 */
- (void)activateWithActivationToken:(NSString *)activationToken
                          eventSink:(id<TSAIDeviceBridgeEventSink>)eventSink
                         completion:(TSAICompletionBlock)completion;

/**
 * @brief Deactivate event forwarding
 * @chinese 停用事件转发
 * @param completion EN: Deactivation completion. CN: 停用完成回调。
 */
- (void)deactivateWithCompletion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Send raw provider authentication data to the device
 * @chinese 向设备发送 Provider 原始鉴权数据
 * @param data EN: Raw authentication data. CN: 原始鉴权数据。
 * @param completion EN: Send completion. Once called, the transport must
 *                    guarantee the command can no longer reach the device.
 *                    CN: 发送完成回调；回调后传输层必须保证该命令不会再到达设备。
 */
- (void)sendAuthenticationDataToDevice:(NSData *)data
                            completion:(nullable TSAICompletionBlock)completion;

@end

/**
 * @brief Optional physical-device identity used for vendor authorization
 * @chinese 厂商鉴权使用的可选物理设备身份
 */
@protocol TSAIDeviceIdentityBridge <TSAIDeviceBridge>

/**
 * @brief MAC address of the verified connected device
 * @chinese 已校验连接设备的 MAC 地址
 * @discussion
 * [EN]: This is a hardware MAC, never a CoreBluetooth UUID.
 * [CN]: 此值为硬件 MAC，不能使用 CoreBluetooth UUID 代替。
 * @note
 * [EN]: Nil when the identity is not ready; formatting is preserved.
 * [CN]: 身份尚未就绪时为 nil；保留设备原有格式。
 */
@property (nonatomic, copy, readonly, nullable) NSString *deviceMACAddress;

/**
 * @brief Known audio port names belonging to the current device
 * @chinese 当前设备已知的音频端口名称
 * @discussion
 * [EN]: Providers use these names to guard against unintended device output.
 * [CN]: Provider 使用这些名称检查意外切换到设备的系统音频输出。
 * @note
 * [EN]: An empty list does not prove that no device audio port exists.
 * [CN]: 空列表不能证明设备没有系统音频端口。
 */
@property (nonatomic, copy, readonly) NSArray<NSString *> *deviceAudioOutputPortNames;

@end

/**
 * @brief Configure chat routing before device events are activated
 * @chinese 在激活设备事件前配置对话播放路由
 */
@protocol TSAIDeviceChatPlaybackRouting <TSAIDeviceBridge>
/**
 * @brief Select system-managed chat output for a native-playing Provider
 * @chinese 为原生播放 Provider 选择跟随系统的对话输出
 * @param enabled
 * EN: YES for native playback; explicit bridge output settings remain authoritative.
 * CN: YES 表示原生播放；Bridge 显式输出配置仍具有优先级。
 */
- (void)configureProviderManagedChatPlayback:(BOOL)enabled;
@end

/**
 * @brief Optional SDK-owned business lifecycle, independent of App UI
 * @chinese 可选的 SDK 内部业务生命周期，与 App 页面无关
 */
@protocol TSAIDeviceBusinessLifecycle <TSAIDeviceBridge>
/**
 * @brief Bind business handlers before the Context becomes active
 * @chinese 在 Context 激活前同步绑定业务处理器；实现方只能弱持有 Context
 * @param context EN: Owning Context. CN: 所属 Context。
 */
- (void)bindBusinessServicesToContext:(TSAIContext *)context;
/**
 * @brief Invalidate business callbacks before Provider shutdown
 * @chinese 在 Provider 关闭前同步使业务回调失效并取消客户端任务
 * @param context EN: Context being torn down. CN: 正在释放的 Context。
 */
- (void)unbindBusinessServicesFromContext:(TSAIContext *)context;
@end

/**
 * @brief Optional device data-channel PCM output capability
 * @chinese 可选的设备数据通道 PCM 输出能力
 *
 * @discussion
 * [EN]: AIKit uses this bridge only for an explicitly resolved Opus output
 *       route. The payload format is fixed to signed Int16 little-endian PCM.
 * [CN]: AIKit 仅在明确解析为 Opus 输出路由时使用此 Bridge。
 *       数据格式固定为有符号 Int16 小端 PCM。
 */
@protocol TSAIDevicePCMOutputBridge <TSAIDeviceBridge>

/**
 * @brief Whether device data-channel PCM playback is currently available
 * @chinese 设备数据通道 PCM 播放当前是否可用
 * @return EN: YES when a playback session can be started. CN: 可启动播放会话时返回 YES。
 */
- (BOOL)isDevicePCMOutputAvailable;

/**
 * @brief Whether device-side echo cancellation is available for this route
 * @chinese 当前路由是否具备设备侧回声消除
 * @return EN: Device-side AEC state. CN: 设备侧 AEC 状态。
 */
- (BOOL)isDeviceSideEchoCancellationAvailable;

/**
 * @brief Start one PCM output session
 * @chinese 启动一个 PCM 输出会话
 * @param taskId EN: AI session identifier. CN: AI 会话标识。
 * @param sampleRate EN: PCM sample rate. CN: PCM 采样率。
 * @param channelCount EN: PCM channel count. CN: PCM 声道数。
 * @param bitsPerSample EN: PCM bits per sample. CN: PCM 位深。
 * @param completion EN: Start completion. CN: 启动完成回调。
 */
- (void)startPCMOutputForTaskId:(NSString *)taskId
                     sampleRate:(NSUInteger)sampleRate
                   channelCount:(NSUInteger)channelCount
                  bitsPerSample:(NSUInteger)bitsPerSample
                     completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Append ordered PCM data
 * @chinese 追加有序 PCM 数据
 * @param pcmData EN: Signed Int16LE PCM bytes. CN: 有符号 Int16LE PCM 数据。
 * @param taskId EN: AI session identifier. CN: AI 会话标识。
 * @param completion EN: Append completion. CN: 追加完成回调。
 */
- (void)appendPCMOutputData:(NSData *)pcmData
                     taskId:(NSString *)taskId
                  completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Finish one PCM output session
 * @chinese 正常结束一个 PCM 输出会话
 * @param taskId EN: AI session identifier. CN: AI 会话标识。
 * @param completion EN: Main-thread finish completion, invoked exactly once
 *                    for success, failure, invalid state, disconnection, or timeout.
 *                    CN: 主线程结束回调；成功、失败、状态非法、断连或超时均保证调用一次。
 */
- (void)finishPCMOutputForTaskId:(NSString *)taskId
                      completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Cancel one PCM output session
 * @chinese 取消一个 PCM 输出会话
 * @param taskId EN: AI session identifier. CN: AI 会话标识。
 * @param completion EN: Main-thread cancel completion. CN: 主线程取消回调。
 */
- (void)cancelPCMOutputForTaskId:(NSString *)taskId
                      completion:(nullable TSAICompletionBlock)completion;

@end

/**
 * @brief Device bridge capability for device-initiated AI question-answer
 * @chinese 设备发起 AI 问答的设备桥接能力
 */
@protocol TSAIDeviceQuestionAnswerBridge <TSAIDeviceBridge>

/**
 * @brief Whether the connected device supports AI question-answer
 * @chinese 当前连接设备是否支持 AI 问答
 * @return EN: YES when supported. CN: 支持时返回 YES。
 */
- (BOOL)isQuestionAnswerSupported;

/**
 * @brief Send the final question ASR result to the device
 * @chinese 向设备发送最终的问题 ASR 结果
 * @param text EN: Recognized question or custom error text. CN: 识别问题或自定义错误文本。
 * @param resultType EN: Normalized ASR result type. CN: 标准化 ASR 结果类型。
 * @param completion EN: Transport completion. CN: 传输完成回调。
 */
- (void)sendQuestionASRText:(nullable NSString *)text
                 resultType:(TSAIDeviceQuestionASRResultType)resultType
                 completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Send a cumulative AI answer snapshot to the device
 * @chinese 向设备发送 AI 答案累计快照
 * @param text EN: Cumulative answer or custom error text. CN: 累计答案或自定义错误文本。
 * @param isFinal EN: Whether this is the terminal snapshot. CN: 是否为终态快照。
 * @param resultType EN: Normalized answer result type. CN: 标准化答案结果类型。
 * @param completion EN: Transport completion. CN: 传输完成回调。
 */
- (void)sendQuestionAnswerText:(nullable NSString *)text
                       isFinal:(BOOL)isFinal
                    resultType:(TSAIDeviceQuestionAnswerResultType)resultType
                    completion:(nullable TSAICompletionBlock)completion;

@optional

/**
 * @brief Close result production for the original question-answer request
 * @chinese 关闭原问答请求的结果生产
 * @param request
 * EN: Exact original request whose transport begins asynchronous cancellation.
 * CN: 开始异步取消传输的原始请求对象。
 * @discussion
 * [EN]: This signal does not prove drain completion; the normal exact end path still awaits local barriers.
 * [CN]: 此信号不代表排空完成；正常精确结束路径仍须等待本地屏障。
 */
- (void)cancelQuestionAnswerForRequest:(TSAIStartRequest *)request;

/**
 * @brief Require device confirmation of the recognized question
 * @chinese 要求设备确认已识别的问题
 * @param request
 * EN: Exact original device-coordinated request.
 * CN: 原始设备协同请求对象。
 * @return
 * EN: YES to wait after successful ASR delivery; omission preserves the legacy immediate-answer flow.
 * CN: YES 表示成功回写 ASR 后等待确认；未实现时保留旧的直接回答流程。
 */
- (BOOL)requiresQuestionAnswerConfirmationForRequest:(TSAIStartRequest *)request;

/**
 * @brief Provide the local confirmation waiting interval
 * @chinese 提供本地确认等待时限
 * @param request
 * EN: Exact original request whose policy is frozen when device input begins.
 * CN: 设备输入开始时冻结策略的原始请求对象。
 * @return
 * EN: Seconds; absent or invalid values use 60 seconds, clamped locally to one through 300 seconds.
 * CN: 秒数；缺省或非法值采用 60 秒，本地限制在 1 至 300 秒。
 */
- (NSTimeInterval)questionAnswerConfirmationTimeoutForRequest:(TSAIStartRequest *)request;

/**
 * @brief Send final ASR text for one exact request without implicit retries
 * @chinese 为精确请求发送最终 ASR 文本，不隐式重试
 * @param text
 * EN: Copied recognized question or error description.
 * CN: 复制的问题全文或错误说明。
 * @param resultType
 * EN: Normalized ASR result type.
 * CN: 标准化 ASR 结果类型。
 * @param request
 * EN: Exact original request, never resolved through current use case.
 * CN: 原始请求对象，不通过当前业务类型重新查找。
 * @param completion
 * EN: Called once after local delivery or failure; local completion does not prove device display.
 * CN: 本地交付或失败后回调一次；本地完成不代表设备显示成功。
 */
- (void)sendQuestionASRText:(nullable NSString *)text
                resultType:(TSAIDeviceQuestionASRResultType)resultType
                   request:(TSAIStartRequest *)request
                completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Send one cumulative answer snapshot for an exact request
 * @chinese 为精确请求发送一份累计答案快照
 * @param partialResult
 * EN: fullText and isFinal are copied as values; taskId does not establish device ownership.
 * CN: 复制 fullText 和 isFinal 的值；taskId 不作为设备归属依据。
 * @param resultType
 * EN: Normalized answer result type.
 * CN: 标准化答案结果类型。
 * @param request
 * EN: Exact original request.
 * CN: 原始请求对象。
 * @param completion
 * EN: Called once after local delivery or failure, without coordinator retries.
 * CN: 本地交付或失败后回调一次，协调器不重试。
 */
- (void)sendQuestionAnswerPartialResult:(TSAIQuestionAnswerPartialResult *)partialResult
                            resultType:(TSAIDeviceQuestionAnswerResultType)resultType
                               request:(TSAIStartRequest *)request
                            completion:(nullable TSAICompletionBlock)completion;

@end

/**
 * @brief Device bridge capability for AI chat
 * @chinese AI 对话设备桥接能力
 */
@protocol TSAIAssistantDeviceBridge <TSAIDeviceBridge>

/** @brief Whether AI summary is supported @chinese 是否支持 AI 总结 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isAISummarySupported;

/** @brief Whether AI chat is supported @chinese 是否支持 AI 对话 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isAIChatSupported;

/** @brief Current AI chat audio channel @chinese 当前 AI 对话音频通道 @return EN: Audio channel. CN: 音频通道。 */
- (TSAIDeviceBridgeChatAudioChannel)aiChatAudioChannel;

/** @brief Report successful chat initiation @chinese 回报对话启动成功 @param completion EN: Report completion. CN: 回报完成回调。 */
- (void)reportAIChatSessionInitiateSuccess:(TSAICompletionBlock)completion;

/** @brief Report failed or terminated chat @chinese 回报对话启动失败或已终止 @param completion EN: Report completion. CN: 回报完成回调。 */
- (void)reportAIChatSessionInitiateFailedOrTerminated:(TSAICompletionBlock)completion;
@end

/**
 * @brief Device bridge capability for speech services
 * @chinese AI 语音服务设备桥接能力
 */
@protocol TSAISpeechDeviceBridge <TSAIDeviceBridge>

/** @brief Whether speech services are supported @chinese 是否支持 AI 语音服务 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isSpeechSupported;

/** @brief Whether device-microphone speech recognition is supported @chinese 是否支持设备麦克风语音识别 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isDeviceMicSpeechSupported;

/** @brief Whether offline speech recognition is supported @chinese 是否支持离线语音识别 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isOfflineSpeechSupported;

@end

/**
 * @brief Device bridge capability for text translation
 * @chinese AI 文本翻译设备桥接能力
 */
@protocol TSAITranslateDeviceBridge <TSAIDeviceBridge>

/** @brief Whether text translation is supported @chinese 是否支持 AI 文本翻译 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isTranslationSupported;

@end

/**
 * @brief Device bridge capability for AI interpretation
 * @chinese AI 同声传译设备桥接能力
 */
@protocol TSAIInterpreterDeviceBridge <TSAIDeviceBridge>

/**
 * @brief Whether AI interpretation is supported
 * @chinese 是否支持 AI 同声传译
 * @return EN: Support state. CN: 支持状态。
 */
- (BOOL)isInterpreterSupported;

@end

/**
 * @brief Device bridge capability for watch-initiated voice translation
 * @chinese 手表发起语音翻译的设备桥接能力
 */
@protocol TSAIDeviceVoiceTranslationBridge <TSAIInterpreterDeviceBridge>

/**
 * @brief Whether the connected device supports watch-initiated voice translation
 * @chinese 当前连接设备是否支持手表发起语音翻译
 * @return EN: Support state. CN: 支持状态。
 */
- (BOOL)isSupport;

/**
 * @brief Send an original or translated text snapshot to the device
 * @chinese 向设备发送原文或译文累计快照
 * @param text EN: Cumulative text snapshot. CN: 累计文本快照。
 * @param isFinal EN: Whether the current text snapshot is definitive for its
 *                text type and utterance. CN: 当前类型与句段的文本快照是否已定稿。
 * @param textType EN: Original or translated text type. CN: 原文或译文类型。
 * @param completion EN: Send completion. CN: 发送完成回调。
 */
- (void)sendVoiceTranslationText:(NSString *)text
                         isFinal:(BOOL)isFinal
                        textType:(TSAIDeviceVoiceTranslationTextType)textType
                      completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Report AI authentication failure to the current device
 * @chinese 向当前设备回报 AI 鉴权失败
 * @param completion EN: Report completion. CN: 上报完成回调。
 */
- (void)reportAIAuthenticationFailedWithCompletion:
    (nullable TSAICompletionBlock)completion;

@optional

/**
 * @brief Opt in to original-request device voice translation
 * @chinese 显式启用绑定原请求的设备语音翻译
 *
 * @return
 * EN: YES to require exact request input and local text-delivery completion; omission preserves legacy behavior.
 * CN: YES表示要求精确请求输入及文本本地发送终态；未实现时保留旧行为。
 */
- (BOOL)usesRequestScopedVoiceTranslation;

/**
 * @brief Send a full original or translated snapshot for its owning request
 * @chinese 向所属原请求发送完整原文或译文快照
 *
 * @param content
 * EN: Immutable text snapshot; isTextFinal closes the entire text type for the round, not one utterance.
 * CN: 不可变文本快照；isTextFinal结束本轮整个文本类型，不是单个句段。
 *
 * @param request
 * EN: Exact original immutable request; matching identifiers do not transfer ownership.
 * CN: 精确的原始不可变请求；相同标识不转移归属。
 *
 * @param completion
 * EN: Optional local delivery result, once on the main queue; it does not acknowledge firmware display.
 * CN: 可选本地发送结果，在主队列回调一次，不代表固件已显示。
 *
 * @discussion
 * [EN]: The caller does not crop text, add an ACK watchdog, or retry after a local failure.
 *       A transport may coalesce partials; success can mean a newer snapshot took over. Final waits for actual delivery.
 * [CN]: 调用方不裁剪文本、不增加业务ACK看门狗，也不在本地失败后重试。
 *       传输层可合并partial；成功也可表示由更新快照接管。最终定稿仍等待实际发送。
 */
- (void)sendVoiceTranslationContent:(TSAIInterpreterContent *)content
                            request:(TSAIStartRequest *)request
                         completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Seal production belonging to the original translation request
 * @chinese 封闭原翻译请求所属的数据生产
 *
 * @param request
 * EN: Exact original request being cancelled; the session end still waits for actual transport drain.
 * CN: 被取消的精确原请求；会话结束仍须等待真实传输排空。
 */
- (void)cancelVoiceTranslationForRequest:(TSAIStartRequest *)request;

@end

/**
 * @brief Device bridge capability for AI recording
 * @chinese AI 录音设备桥接能力
 */
@protocol TSAIAudioRecordDeviceBridge <TSAIDeviceBridge>

/** @brief Whether AI recording is supported @chinese 是否支持 AI 录音 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isAIAudioRecordingSupported;

/** @brief Whether call recording is supported @chinese 是否支持通话录音 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isCallAudioRecordingSupported;

/** @brief Whether normal recording is supported @chinese 是否支持普通录音 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isNormalAudioRecordingSupported;

/**
 * @brief Report successful AI recording start
 * @chinese 回报 AI 录音启动成功
 * @param scene EN: Active recording scene. CN: 当前录音场景。
 * @param completion EN: Report completion. CN: 回报完成回调。
 */
- (void)reportAIAudioRecordingStartSuccessWithScene:(TSAIAudioRecordScene)scene
                                         completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Report that AI recording stopped
 * @chinese 回报 AI 录音已停止
 * @param completion EN: Report completion. CN: 回报完成回调。
 */
- (void)reportAIAudioRecordingStoppedWithCompletion:(nullable TSAICompletionBlock)completion;

@optional

/**
 * @brief Opt in to request-scoped device recording lifecycle events
 * @chinese 显式启用携带原请求的设备录音生命周期事件
 *
 * @return
 * EN: YES for exact recording input and termination. Omission preserves legacy behavior.
 * CN: YES表示使用精确录音输入和终止；未实现时保留旧行为。
 */
- (BOOL)usesRequestScopedAudioRecording;

/**
 * @brief Close only the original recording input while preserving ordered EOF delivery
 * @chinese 仅关闭原录音输入并保留有序EOF交付
 *
 * @param request
 * EN: Exact immutable recording request.
 * CN: 精确的不可变录音请求。
 *
 * @param completion
 * EN: Called once for the local input-close request; Provider completion follows the ordered input event.
 * CN: 本地关麦请求完成回调一次；Provider结束须经有序输入事件触发。
 */
- (void)finishAudioRecordingInputForRequest:(TSAIStartRequest *)request
                               completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Stop production for the exact recording before its end barrier
 * @chinese 在结束屏障前停止精确录音请求的数据生产
 *
 * @param request
 * EN: Original request; this signal alone does not prove transport drain.
 * CN: 原请求；此信号本身不证明传输已经排空。
 */
- (void)cancelAudioRecordingForRequest:(TSAIStartRequest *)request;

/**
 * @brief Whether the device declares pause/resume support for AI recording
 * @chinese 设备是否声明支持 AI 录音暂停/继续
 * @return EN: Support state from the device capability snapshot. CN: 来自设备能力快照的支持状态。
 */
- (BOOL)isAIAudioRecordingPauseResumeSupported;

/**
 * @brief Whether the device declares that it displays AI recording transcripts
 * @chinese 设备是否声明需要并显示 AI 录音转写文本
 * @return EN: Support state from the device capability snapshot. CN: 来自设备能力快照的支持状态。
 */
- (BOOL)isAIAudioRecordingTranscriptDisplaySupported;

/**
 * @brief Ask the device to pause the active AI recording
 * @chinese 请求设备暂停当前 AI 录音
 * @param recordingPosition EN: App-side effective recording position in seconds (paused time excluded),
 *                          shown by the device. CN: App 侧有效录音位置（秒，不含暂停），供设备显示。
 * @param completion EN: Device acknowledgement; the SDK pauses locally only after success.
 *                   CN: 设备应答；SDK 仅在成功后才切换本地暂停态。
 */
- (void)pauseAIAudioRecordingAtPosition:(NSTimeInterval)recordingPosition
                              completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Ask the device to resume the paused AI recording
 * @chinese 请求设备继续已暂停的 AI 录音
 * @param recordingPosition EN: App-side effective recording position in seconds. CN: App 侧有效录音位置（秒）。
 * @param completion EN: Device acknowledgement; the SDK resumes locally only after success.
 *                   CN: 设备应答；SDK 仅在成功后才切换本地继续态。
 */
- (void)resumeAIAudioRecordingAtPosition:(NSTimeInterval)recordingPosition
                               completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Send one AI recording transcript sentence to the device screen
 * @chinese 向设备屏幕下发一句 AI 录音转写文本
 * @param text EN: Latest text of the sentence. CN: 该句最新文本。
 * @param isFinal EN: Whether the sentence is final. CN: 该句是否已定稿。
 * @param completion EN: Device acknowledgement; the completion is the ACK. CN: 设备应答，即 ACK。
 */
- (void)sendAIAudioRecordingTranscriptText:(NSString *)text
                                   isFinal:(BOOL)isFinal
                                completion:(nullable TSAICompletionBlock)completion;
@end

/**
 * @brief Companion Bluetooth earbuds of the device (optional)
 * @chinese 设备的配套蓝牙耳机（可选能力）
 *
 * @discussion
 * EN: For products made of a BLE charging case plus independent classic-Bluetooth earbuds.
 *     AIKit captures the earbuds microphone on the phone (HFP) for App-started sessions whenever
 *     a Bluetooth headset is on the audio route; it does not require this protocol. When the
 *     device can report the wearing state (isEarbudsStatusAvailable), it is also used
 *     (both earbuds in the case → NotConnected).
 * CN: 适用于「BLE 充电仓 + 独立经典蓝牙耳机」的产品。只要音频路由上有蓝牙耳机，AIKit 就可在
 *     手机上经 HFP 采集耳机麦克风（App 发起的会话），不依赖本协议。设备能上报佩戴状态时
 *     （isEarbudsStatusAvailable），额外参考该状态（两只都在仓内 → NotConnected）。
 */
@protocol TSAIDeviceEarbudsBridge <TSAIDeviceBridge>

/**
 * @brief Whether the connected device can report the wearing state of the earbuds
 * @chinese 已连接设备能否上报耳机佩戴状态
 *
 * @return
 * EN: YES only while connected and the device supports the earbuds status APIs. It does not
 *     decide whether the earbuds microphone can be used.
 * CN: 仅在已连接且设备支持耳机状态相关接口时返回 YES。不决定耳机麦能否使用。
 */
- (BOOL)isEarbudsStatusAvailable;

@optional

/**
 * @brief Query the current wear state of the earbuds
 * @chinese 查询耳机当前的佩戴状态
 *
 * @param completion
 * EN: Called once on the main queue
 * CN: 在主线程回调一次
 */
- (void)queryEarbudsStatusWithCompletion:(void (^)(TSAIDeviceEarbudsStatus * _Nullable status,
                                                   NSError * _Nullable error))completion;

/**
 * @brief Observe wear-state changes reported by the case
 * @chinese 监听充电仓上报的佩戴状态变化
 *
 * @param handler
 * EN: Called on the main queue; nil removes the handler
 * CN: 在主线程回调；传 nil 移除
 */
- (void)setEarbudsStatusDidChangeHandler:(nullable void (^)(TSAIDeviceEarbudsStatus *status))handler;

@end

NS_ASSUME_NONNULL_END
