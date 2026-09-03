//
//  TSAIContext.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIContextConfiguration.h"
#import "TSAIFeatureInterface.h"
#import "TSAIAssistantInterface.h"
#import "TSAIInterpreterInterface.h"
#import "TSAIImageGenerationInterface.h"
#import "TSAIQuestionAnswerInterface.h"
#import "TSAIAudioRoutingInterface.h"
#import "TSAISpeechInterface.h"
#import "TSAITranslateInterface.h"
#import "TSAudioRecordInterface.h"

@protocol TSAIDeviceVoiceTranslationOutputSink;
@protocol TSAIDeviceQuestionAnswerOutputSink;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Runtime scope for one platform and one AI provider
 * @chinese 一个平台与一个 AI Provider 对应的运行时作用域
 */
@interface TSAIContext : NSObject <TSAIFeatureInterface>

/**
 * @brief Unique identifier of this Context instance
 * @chinese 当前 Context 实例的唯一标识
 */
@property (nonatomic, copy, readonly) NSString *contextIdentifier;

/**
 * @brief Platform identifier configured for this Context
 * @chinese 当前 Context 配置的平台标识
 */
@property (nonatomic, copy, readonly) NSString *platformIdentifier;

/**
 * @brief Current Context lifecycle state
 * @chinese 当前 Context 生命周期状态
 */
@property (atomic, assign, readonly) TSAIContextState state;

/**
 * @brief Current provider authorization state
 * @chinese 当前 Provider 鉴权状态
 */
@property (atomic, assign, readonly) TSAIAuthorizationState authorizationState;

/**
 * @brief Assistant capability bound to this Context
 * @chinese 绑定到当前 Context 的 AI 助手能力
 */
@property (atomic, strong, readonly, nullable) id<TSAIAssistantInterface> assistant;

/**
 * @brief Question-answer capability bound to this Context
 * @chinese 绑定到当前 Context 的 AI 问答能力
 */
@property (atomic, strong, readonly, nullable) id<TSAIQuestionAnswerInterface> questionAnswer;

/**
 * @brief Translation capability bound to this Context
 * @chinese 绑定到当前 Context 的 AI 翻译能力
 */
@property (atomic, strong, readonly, nullable) id<TSAITranslateInterface> translate;

/**
 * @brief Speech capability bound to this Context
 * @chinese 绑定到当前 Context 的 AI 语音能力
 */
@property (atomic, strong, readonly, nullable) id<TSAISpeechInterface> speech;

/**
 * @brief Interpretation capability bound to this Context
 * @chinese 绑定到当前 Context 的 AI 同声传译能力
 */
@property (atomic, strong, readonly, nullable) id<TSAIInterpreterInterface> interpreter;

/**
 * @brief Audio recording capability bound to this Context
 * @chinese 绑定到当前 Context 的 AI 录音能力
 */
@property (atomic, strong, readonly, nullable) id<TSAudioRecordInterface> audioRecord;

/**
 * @brief Image generation capability bound to this Context
 * @chinese 绑定到当前 Context 的图片生成能力
 */
@property (atomic, strong, readonly, nullable)
    id<TSAIImageGenerationInterface> imageGeneration;

/**
 * @brief Read-only audio-route discovery for this Context
 * @chinese 当前 Context 的只读音频路由发现接口
 */
@property (atomic, strong, readonly, nullable) id<TSAIAudioRoutingInterface> audioRouting;

/**
 * @brief Create an inactive Context from configuration
 * @chinese 根据配置创建未激活的 Context
 *
 * @param configuration
 * EN: Context configuration
 * CN: Context 配置
 *
 * @return
 * EN: A new inactive Context
 * CN: 新的未激活 Context
 */
- (instancetype)initWithConfiguration:(TSAIContextConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

/**
 * @brief Return whether every requested AI feature is available in this Context
 * @chinese 返回当前 Context 是否支持全部指定 AI 功能
 *
 * @param features
 * EN: One or more standardized AI features
 * CN: 一个或多个标准 AI 功能
 *
 * @return
 * EN: YES when the bound Provider supports every feature and each required
 *     Context route is established
 * CN: 绑定 Provider 支持全部功能且必要 Context 路由已建立时返回 YES
 */
- (BOOL)supportsAIFeatures:(TSAIFeatureOptions)features;

/**
 * @brief Register a Context state callback
 * @chinese 注册 Context 状态回调
 *
 * @param stateBlock
 * EN: Callback invoked when the Context state changes; nil clears it
 * CN: Context 状态变化时调用的回调，传 nil 表示清除
 */
- (void)registerStateDidChange:(nullable void (^)(TSAIContextState state))stateBlock;

/**
 * @brief Register an authorization state callback
 * @chinese 注册鉴权状态回调
 *
 * @param stateBlock
 * EN: Callback invoked when authorization state changes; nil clears it
 * CN: 鉴权状态变化时调用的回调，传 nil 表示清除
 */
- (void)registerAuthorizationStateDidChange:
    (nullable void (^)(TSAIAuthorizationState state))stateBlock;

/**
 * @brief Register the App-side PCM output for device-initiated translation
 * @chinese 注册设备发起翻译的 App 侧 PCM 输出对象
 *
 * @param outputSink
 * EN: Weakly held native output sink; nil unregisters it
 * CN: 弱引用保存的原生输出对象；传 nil 表示注销
 */
- (void)registerDeviceVoiceTranslationOutputSink:
    (nullable id<TSAIDeviceVoiceTranslationOutputSink>)outputSink;

/**
 * @brief Register the App-side player for device-initiated question answering
 * @chinese 注册设备发起 AI 问答的 App 侧播放器
 *
 * @param outputSink
 * EN: Weakly held native playback sink; nil unregisters it
 * CN: 弱引用保存的原生播放对象；传 nil 表示注销
 */
- (void)registerQuestionAnswerOutputSink:
    (nullable id<TSAIDeviceQuestionAnswerOutputSink>)outputSink
    NS_SWIFT_NAME(registerQuestionAnswerOutputSink(_:));

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
