//
//  TSAIContext+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import "TSAIContext.h"

#import "TSAIAssistantProvider.h"
#import "TSAIAudioRecordProvider.h"
#import "TSAIDeviceBridge.h"
#import "TSAIProvider.h"
#import "TSAIQuestionAnswerProvider.h"

@class TSAIAudioRouteCoordinator;

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
@property (nonatomic, strong, readonly, nullable)
    TSAIAudioRouteCoordinator *audioRouteCoordinator;

/**
 * @brief Configure and arm a device question-answer session
 * @chinese 配置并等待设备问答会话
 */
- (NSString *)tsai_startDeviceQuestionAnswerWithConfig:
        (TSAIQuestionAnswerConfig *)config
                                                 completion:
        (nullable TSAICompletionBlock)completion;

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
