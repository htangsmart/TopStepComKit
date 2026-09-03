//
//  TSAIProvider.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIContextDefines.h"
#import "TSAIContractDefines.h"
#import "TSAIFeatureInterface.h"

@protocol TSAIAssistantProvider;
@protocol TSAIAudioRecordProvider;
@protocol TSAIDeviceBridge;
@protocol TSAIInterpreterProvider;
@protocol TSAIImageGenerationProvider;
@protocol TSAIQuestionAnswerProvider;
@protocol TSAISpeechProvider;
@protocol TSAISystemAudioDriver;
@protocol TSAITranslateProvider;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TSAIProviderAuthorizationStateDidChangeHandler)(TSAIAuthorizationState state);

/**
 * @brief Root protocol for an AI provider implementation
 * @chinese AI Provider 实现的根协议
 */
@protocol TSAIProvider <TSAIFeatureInterface>

/**
 * @brief Stable identifier of this provider product
 * @chinese 当前 Provider 产品的稳定标识
 */
@property (nonatomic, copy, readonly) NSString *providerIdentifier;

/**
 * @brief Current authorization state maintained by the provider
 * @chinese Provider 当前维护的鉴权状态
 */
@property (atomic, assign, readonly) TSAIAuthorizationState authorizationState;

/**
 * @brief Callback invoked when provider authorization state changes
 * @chinese Provider 鉴权状态变化时调用的回调
 */
@property (atomic, copy, nullable) TSAIProviderAuthorizationStateDidChangeHandler authorizationStateDidChangeHandler;

/**
 * @brief Initialize the provider for one Context
 * @chinese 为一个 Context 初始化 Provider
 *
 * @param configuration
 * EN: Provider-specific configuration, or nil when not required
 * CN: Provider 专属配置，不需要时为 nil
 *
 * @param deviceBridge
 * EN: Device bridge bound to the same Context
 * CN: 绑定到同一 Context 的设备桥接器
 *
 * @param completion
 * EN: Completion called when initialization finishes
 * CN: 初始化完成时调用的回调
 */
- (void)initializeWithConfiguration:(nullable id)configuration
                       deviceBridge:(id<TSAIDeviceBridge>)deviceBridge
                         completion:(TSAICompletionBlock)completion;

/**
 * @brief Shut down this provider and release Context-owned resources
 * @chinese 关闭当前 Provider 并释放 Context 持有的资源
 *
 * @param completion
 * EN: Completion called after shutdown, or nil when no notification is needed
 * CN: 关闭完成后的回调，不需要通知时为 nil
 */
- (void)shutdownWithCompletion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Handle a device connection
 * @chinese 处理设备连接事件
 *
 * @param deviceIdentifier
 * EN: Current device identifier, or nil when unavailable
 * CN: 当前设备标识，不可用时为 nil
 */
- (void)handleDeviceConnectedWithIdentifier:(nullable NSString *)deviceIdentifier;

/**
 * @brief Handle a device disconnection
 * @chinese 处理设备断开事件
 */
- (void)handleDeviceDisconnected;

/**
 * @brief Handle raw authentication data received from the device
 * @chinese 处理设备上报的原始鉴权数据
 *
 * @param data
 * EN: Raw authentication data
 * CN: 原始鉴权数据
 */
- (void)handleAuthenticationDataReceivedFromDevice:(NSData *)data;

/**
 * @brief Return the assistant capability provider
 * @chinese 返回 AI 助手能力 Provider
 * @return EN: Capability provider, or nil if unavailable. CN: 能力 Provider；不可用时为 nil。
 */
- (nullable id<TSAIAssistantProvider>)assistantProvider;

/**
 * @brief Return the translation capability provider
 * @chinese 返回 AI 翻译能力 Provider
 * @return EN: Capability provider, or nil if unavailable. CN: 能力 Provider；不可用时为 nil。
 */
- (nullable id<TSAITranslateProvider>)translateProvider;

/**
 * @brief Return the speech capability provider
 * @chinese 返回 AI 语音能力 Provider
 * @return EN: Capability provider, or nil if unavailable. CN: 能力 Provider；不可用时为 nil。
 */
- (nullable id<TSAISpeechProvider>)speechProvider;

/**
 * @brief Return the interpretation capability provider
 * @chinese 返回 AI 同传能力 Provider
 * @return EN: Capability provider, or nil if unavailable. CN: 能力 Provider；不可用时为 nil。
 */
- (nullable id<TSAIInterpreterProvider>)interpreterProvider;

/**
 * @brief Return the audio recording capability provider
 * @chinese 返回 AI 录音能力 Provider
 * @return EN: Capability provider, or nil if unavailable. CN: 能力 Provider；不可用时为 nil。
 */
- (nullable id<TSAIAudioRecordProvider>)audioRecordProvider;

@optional
/**
 * @brief Return the provider system-audio driver
 * @chinese 返回 Provider 的系统音频驱动
 * @return EN: Internal system-audio driver, or nil if unavailable. CN: 内部系统音频驱动；不可用时为 nil。
 */
- (nullable id<TSAISystemAudioDriver>)systemAudioDriver;

/**
 * @brief Return the question-answer capability provider
 * @chinese 返回 AI 问答能力 Provider
 * @return EN: Capability provider, or nil if unavailable. CN: 能力 Provider；不可用时为 nil。
 */
- (nullable id<TSAIQuestionAnswerProvider>)questionAnswerProvider;

/**
 * @brief Return the image generation capability provider
 * @chinese 返回图片生成能力 Provider
 * @return EN: Capability provider, or nil if unavailable. CN: 能力 Provider；不可用时为 nil。
 */
- (nullable id<TSAIImageGenerationProvider>)imageGenerationProvider;

@end

NS_ASSUME_NONNULL_END
