//
//  TSAIContext+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import "TSAIContext.h"

#import "TSAIAssistantProvider.h"
#import "TSAIAudioRecordProvider.h"
#import "TSAIAudioRouteDefines.h"
#import "TSAIDeviceBridge.h"
#import "TSAIProvider.h"
#import "TSAIQuestionAnswerProvider.h"

@class TSAIAudioRouteCoordinator;
@class TSAIConversationTranslationCoordinator;
@class TSAIInterpretationCoordinator;
@class TSAISessionOrchestrator;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal mutable state for Context lifecycle orchestration
 * @chinese Context 生命周期编排使用的内部可变状态
 */
@interface TSAIContext (Internal)

/**
 * @brief Internal route coordinator shared by audio feature adapters
 * @chinese 音频业务适配器共用的内部路由协调器
 */
@property (atomic, strong, readonly, nullable)
    TSAIAudioRouteCoordinator *audioRouteCoordinator;

/**
 * @brief Internal transaction kernel shared by device-coordinated adapters
 * @chinese 设备协同适配器共用的内部事务内核
 */
@property (atomic, strong, readonly, nullable)
    TSAISessionOrchestrator *sessionOrchestrator;

/**
 * @brief Configure and arm a device question-answer session
 * @chinese 配置并等待设备问答会话
 */
- (NSString *)tsai_startDeviceQuestionAnswerWithConfig:
        (TSAIQuestionAnswerConfig *)config
                                                 completion:
        (nullable TSAICompletionBlock)completion;

/** @brief Arm with a text observer @chinese 配置设备问答及文字观察回调 */
- (NSString *)tsai_startDeviceQuestionAnswerWithConfig:(TSAIQuestionAnswerConfig *)config
                                             onEvent:(nullable TSAIDeviceQuestionAnswerEventBlock)onEvent
                                          completion:(nullable TSAICompletionBlock)completion;

/** @brief Stop a configured device question-answer session @chinese 停止已配置的设备问答会话 */
- (void)tsai_stopDeviceQuestionAnswerWithTaskId:(NSString *)taskId;

/**
 * @brief Configure and arm a device voice-translation session
 * @chinese 配置并等待设备语音翻译会话
 */
- (NSString *)tsai_startDeviceVoiceTranslationWithConfig:
        (TSAIDeviceVoiceTranslationConfig *)config
                                                  completion:
        (nullable TSAICompletionBlock)completion;

/** @brief Stop a configured device voice-translation session @chinese 停止已配置的设备语音翻译会话 */
- (void)tsai_stopDeviceVoiceTranslationWithTaskId:(NSString *)taskId;

/**
 * @brief Return whether a coordinated voice-translation device session is reserved
 * @chinese 返回是否存在已预留的设备协同语音翻译会话
 * @return EN: YES while the matching single-round session is preparing or active. CN: 对应单轮会话处于准备中或活动中时返回 YES。
 */
- (BOOL)tsai_hasReservedVoiceTranslationDeviceSession;

/**
 * @brief Bind an interpreter task to the currently reserved voice-translation request
 * @chinese 将同传任务绑定到当前已预留的语音翻译请求
 * @param taskIdentifier EN: Interpreter task identifier. CN: 同传任务标识。
 * @param inputChannel EN: Effective input channel owned by the task. CN: 任务实际持有的输入通道。
 * @return EN: YES when the exact request owns the binding. CN: 精确请求成功取得绑定时返回 YES。
 */
- (BOOL)tsai_bindVoiceTranslationTaskIdentifier:(NSString *)taskIdentifier
                                    inputChannel:(TSAIAudioInputChannel)inputChannel;

/**
 * @brief Remove a coordinated voice-translation binding for one task
 * @chinese 移除指定任务的设备协同语音翻译绑定
 * @param taskIdentifier EN: Interpreter task identifier. CN: 同传任务标识。
 */
- (void)tsai_unbindVoiceTranslationTaskIdentifier:(NSString *)taskIdentifier;

/**
 * @brief Internal conversation-translation coordinator owned by this Context
 * @chinese 当前 Context 持有的内部对话翻译编排器
 */
@property (atomic, strong, readonly, nullable)
    TSAIConversationTranslationCoordinator *conversationTranslationCoordinator;

/**
 * @brief Whether device text downlink is suppressed for coordinated interpreter tasks
 * @chinese 设备协同同传任务是否暂停向设备下发原文/译文文本
 *
 * @discussion
 * [EN]: Set by the conversation-translation coordinator for modes in which the
 *       charging case does not take part in display (portable mode).
 * [CN]: 由对话翻译编排器在充电仓不参与显示的模式（便携交流）下置为 YES。
 */
@property (atomic, assign) BOOL tsai_deviceVoiceTranslationTextDownlinkSuppressed;

/**
 * @brief Internal session-level interpretation coordinator
 * @chinese 内部会话级同传编排器
 */
@property (atomic, strong, readonly, nullable)
    TSAIInterpretationCoordinator *interpretationCoordinator;

/**
 * @brief Whether device (Opus) TTS output streams as it arrives instead of after completion
 * @chinese 设备（Opus）TTS 输出是否边收边播，而非会话结束后再播
 *
 * @discussion
 * [EN]: Set by the interpretation session for continuous interpretation;
 *       device-initiated single-round translation keeps the suspended default.
 * [CN]: 由同传会话为连续同传设置；设备发起的单轮翻译保持默认的挂起行为。
 */
@property (atomic, assign) BOOL tsai_deviceVoiceTranslationOutputStreamingEnabled;

/**
 * @brief Install an SDK-internal override for one device session use case
 * @chinese 为一个设备会话用例安装 SDK 内部的处理器覆盖层
 *
 * @discussion
 * [EN]: The override shadows the App/base registration until popped; requests
 *       already bound to the base registration keep it. Only one override per
 *       use case is kept; pushing again replaces it.
 * [CN]: 覆盖层在弹出前遮蔽 App/基础注册；已绑定基础注册的请求不受影响。
 *       每个用例只保留一个覆盖层，再次安装即替换。
 *
 * @param useCase EN: Generic device session use case. CN: 通用设备会话用例。
 * @param prepareHandler EN: Local preparation handler. CN: 本地准备处理器。
 * @param activationHandler EN: Activation handler. CN: 激活处理器。
 * @param inputCompletionHandler EN: Natural input completion handler. CN: 输入自然完成处理器。
 * @param terminationHandler EN: Idempotent termination handler. CN: 幂等终止处理器。
 * @param requiresBusinessCompletion EN: Whether the override retains the business lease. CN: 覆盖层是否保留业务租约。
 */
- (void)tsai_pushDeviceAISessionHandlerOverrideForUseCase:(TSAIUseCase)useCase
                                           prepareHandler:(TSAIDeviceAISessionPrepareHandler)prepareHandler
                                        activationHandler:(TSAIDeviceAISessionActivationHandler)activationHandler
                                   inputCompletionHandler:(TSAIDeviceAISessionInputCompletionHandler)inputCompletionHandler
                                       terminationHandler:(TSAIDeviceAISessionTerminationHandler)terminationHandler
                               requiresBusinessCompletion:(BOOL)requiresBusinessCompletion;

/**
 * @brief Remove the SDK-internal override for one device session use case
 * @chinese 移除一个设备会话用例的 SDK 内部处理器覆盖层
 * @param useCase EN: Generic device session use case. CN: 通用设备会话用例。
 */
- (void)tsai_popDeviceAISessionHandlerOverrideForUseCase:(TSAIUseCase)useCase;

/**
 * @brief Enter the device conversation-translation product mode, preferring the language-aware bridge method
 * @chinese 进入设备对话翻译产品模式，优先使用携带语言的 Bridge 方法
 * @param mode EN: Product mode. CN: 产品模式。
 * @param selfLanguage EN: Local user language. CN: 本机用户语言。
 * @param peerLanguage EN: Peer language. CN: 对方语言。
 * @param completion EN: Device command result on the main thread. CN: 主线程回调设备命令结果。
 */
- (void)tsai_startDeviceConversationTranslationWithMode:(TSAIConversationTranslationMode)mode
                                           selfLanguage:(TSAILanguage)selfLanguage
                                           peerLanguage:(TSAILanguage)peerLanguage
                                             completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Activation token accepted by this Context
 * @chinese 当前 Context 接受的激活标识
 */
@property (nonatomic, copy, readonly, nullable) NSString *activationToken;

/**
 * @brief Root Provider bound to this Context
 * @chinese 绑定到当前 Context 的根 Provider
 */
@property (nonatomic, strong, readonly, nullable) id<TSAIProvider> provider;

/**
 * @brief DeviceBridge bound to this Context
 * @chinese 绑定到当前 Context 的 DeviceBridge
 */
@property (nonatomic, strong, readonly, nullable) id<TSAIDeviceBridge> deviceBridge;

/**
 * @brief Device voice-translation bridge used by the internal coordinator
 * @chinese 内部编排器使用的设备语音翻译 Bridge
 */
@property (nonatomic, strong, readonly, nullable)
    id<TSAIDeviceVoiceTranslationBridge> deviceVoiceTranslationBridge;

/**
 * @brief Device question-answer bridge used by the internal coordinator
 * @chinese 内部编排器使用的设备 AI 问答 Bridge
 */
@property (nonatomic, strong, readonly, nullable)
    id<TSAIDeviceQuestionAnswerBridge> deviceQuestionAnswerBridge;

/**
 * @brief Assistant Provider used by internal device events
 * @chinese 内部设备事件使用的 AI 助手 Provider
 */
@property (nonatomic, strong, readonly, nullable) id<TSAIAssistantProvider> assistantProvider;

/**
 * @brief Question-answer Provider used by the internal device coordinator
 * @chinese 内部设备编排器使用的 AI 问答 Provider
 */
@property (nonatomic, strong, readonly, nullable)
    id<TSAIQuestionAnswerProvider> questionAnswerProvider;

/**
 * @brief Audio recording Provider used by internal device events
 * @chinese 内部设备事件使用的 AI 录音 Provider
 */
@property (nonatomic, strong, readonly, nullable) id<TSAIAudioRecordProvider> audioRecordProvider;

/**
 * @brief Prepare the internal dependencies for one activation
 * @chinese 为一次激活准备内部依赖
 *
 * @param activationToken
 * EN: Unique token for this activation
 * CN: 本次激活的唯一标识
 *
 * @param provider
 * EN: Root Provider created for this Context
 * CN: 为当前 Context 创建的根 Provider
 *
 * @param deviceBridge
 * EN: DeviceBridge created for this Context
 * CN: 为当前 Context 创建的 DeviceBridge
 */
- (void)tsai_prepareWithActivationToken:(NSString *)activationToken
                               provider:(id<TSAIProvider>)provider
                           deviceBridge:(id<TSAIDeviceBridge>)deviceBridge;

/**
 * @brief Start routing connection and authentication events to the initialized Provider
 * @chinese 开始向已初始化的 Provider 转发连接与鉴权事件
 */
- (void)tsai_activateProviderEventRouting;

/**
 * @brief Invalidate the current activation token
 * @chinese 使当前激活标识立即失效
 */
- (void)tsai_invalidateActivation;

/**
 * @brief Clear lifecycle dependencies while retaining public adapters
 * @chinese 清空生命周期依赖并保留公开适配器
 */
- (void)tsai_clearBindings;

/**
 * @brief Return whether this Context currently accepts public operations
 * @chinese 返回当前 Context 是否接受公开能力调用
 *
 * @return
 * EN: YES only while the activation token is valid and state is Active
 * CN: 仅激活标识有效且状态为 Active 时返回 YES
 */
- (BOOL)tsai_isActive;

/**
 * @brief Return the root Provider only while this Context is active
 * @chinese 仅在当前 Context 激活时返回根 Provider
 *
 * @return
 * EN: Active root Provider, or nil when inactive or unavailable
 * CN: 激活中的根 Provider；未激活或不可用时返回 nil
 */
- (nullable id<TSAIProvider>)tsai_activeProvider;

/**
 * @brief Return the DeviceBridge only while this Context is active
 * @chinese 仅在当前 Context 激活时返回 DeviceBridge
 *
 * @return
 * EN: Active DeviceBridge, or nil when inactive
 * CN: 激活中的 DeviceBridge；未激活时返回 nil
 */
- (nullable id<TSAIDeviceBridge>)tsai_activeDeviceBridge;

/**
 * @brief Update whether App has registered a handler for a device-origin use case
 * @chinese 更新 App 是否已注册设备发起用例的处理器
 * @param available EN: Whether the handler is available. CN: 处理器是否可用。
 * @param useCase EN: Device-origin use case. CN: 设备发起的业务用例。
 */
- (void)tsai_setDeviceStartHandlerAvailable:(BOOL)available
                                  forUseCase:(TSAIUseCase)useCase;

/**
 * @brief Update lifecycle state
 * @chinese 更新生命周期状态
 *
 * @param state
 * EN: New lifecycle state
 * CN: 新的生命周期状态
 */
- (void)tsai_updateState:(TSAIContextState)state;

/**
 * @brief Update authorization state
 * @chinese 更新鉴权状态
 *
 * @param authorizationState
 * EN: New authorization state
 * CN: 新的鉴权状态
 */
- (void)tsai_updateAuthorizationState:(TSAIAuthorizationState)authorizationState;

/**
 * @brief Bind public-facing capability adapters to this Context
 * @chinese 绑定当前 Context 对外能力适配器
 *
 * @param assistant
 * EN: Assistant capability adapter
 * CN: AI 助手能力适配器
 *
 * @param questionAnswer
 * EN: Question-answer capability adapter
 * CN: AI 问答能力适配器
 *
 * @param translate
 * EN: Translation capability adapter
 * CN: 翻译能力适配器
 *
 * @param speech
 * EN: Speech capability adapter
 * CN: 语音能力适配器
 *
 * @param interpreter
 * EN: Interpreter capability adapter
 * CN: 同传能力适配器
 *
 * @param audioRecord
 * EN: Audio recording capability adapter
 * CN: 录音能力适配器
 *
 * @param imageGeneration
 * EN: Image generation capability adapter
 * CN: 图片生成能力适配器
 */
- (void)tsai_bindAssistant:(nullable id<TSAIAssistantInterface>)assistant
            questionAnswer:(nullable id<TSAIQuestionAnswerInterface>)questionAnswer
                 translate:(nullable id<TSAITranslateInterface>)translate
                    speech:(nullable id<TSAISpeechInterface>)speech
               interpreter:(nullable id<TSAIInterpreterInterface>)interpreter
               audioRecord:(nullable id<TSAudioRecordInterface>)audioRecord
           imageGeneration:(nullable id<TSAIImageGenerationInterface>)imageGeneration;

@end

NS_ASSUME_NONNULL_END
