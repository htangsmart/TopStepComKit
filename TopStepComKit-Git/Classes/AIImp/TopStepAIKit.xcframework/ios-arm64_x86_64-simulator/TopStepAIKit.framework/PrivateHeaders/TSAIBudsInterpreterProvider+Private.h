//
//  TSAIBudsInterpreterProvider+Private.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSAIBudsInterpreterProvider.h"

#import "../../../Core/Provider/TSAIInterpreterProvider+Internal.h"
#import "../../../Core/Provider/TSAISpeechProvider.h"
#import "../../../Core/Provider/TSAITranslateProvider.h"

@class TSAIBudsDeviceVoiceTranslationTask;
@class TSAIBudsSessionStore;

NS_ASSUME_NONNULL_BEGIN

@interface TSAIBudsInterpreterProvider ()

/** @brief Current device voice-translation task @chinese 当前设备整段语音翻译任务 */
@property (nonatomic, strong, nullable)
    TSAIBudsDeviceVoiceTranslationTask *deviceVoiceTranslationTask;
/** @brief Shared speech Provider @chinese 与 App 共用的语音 Provider */
@property (nonatomic, strong) id<TSAISpeechProvider> speechProvider;
/** @brief Shared translate Provider @chinese 与 App 共用的文本翻译 Provider */
@property (nonatomic, strong) id<TSAITranslateProvider> translateProvider;

@end

@interface TSAIBudsInterpreterProvider (Private)

/** @brief Session store owned by the current Context @chinese 当前 Context 持有的会话存储 */
@property (nonatomic, strong, readonly) TSAIBudsSessionStore *sessionStore;
/** @brief Lifecycle queue shared by interpreter task kinds @chinese 同传与设备翻译共用的生命周期串行队列 */
@property (nonatomic, strong, readonly) dispatch_queue_t lifecycleQueue;

/**
 * @brief Create the Provider with a Context-owned session store
 * @chinese 使用 Context 独立会话存储创建 Provider
 * @param sessionStore EN: Context-owned store. CN: Context 持有的会话存储。
 * @return EN: Provider instance. CN: Provider 实例。
 */
- (instancetype)initWithSessionStore:(TSAIBudsSessionStore *)sessionStore;

/**
 * @brief Create the Provider with shared capability Providers
 * @chinese 使用共享能力 Provider 创建同传 Provider
 * @param sessionStore EN: Context-owned store. CN: Context 持有的会话存储。
 * @param speechProvider EN: Shared speech Provider. CN: 共享语音 Provider。
 * @param translateProvider EN: Shared translate Provider. CN: 共享文本翻译 Provider。
 * @return EN: Provider instance. CN: Provider 实例。
 */
- (instancetype)initWithSessionStore:(TSAIBudsSessionStore *)sessionStore
                       speechProvider:(id<TSAISpeechProvider>)speechProvider
                    translateProvider:(id<TSAITranslateProvider>)translateProvider;

/** @brief Whether App interpretation is active @chinese 当前是否存在 App 主动发起的同传任务 @return EN: Active state. CN: 活跃状态。 */
- (BOOL)tsai_hasActiveSimultaneousInterpretation;

/** @brief Execute synchronously on the lifecycle queue @chinese 在生命周期串行队列同步执行 @param block EN: Work block. CN: 工作块。 */
- (void)executeSynchronouslyOnLifecycleQueue:(dispatch_block_t)block;

/** @brief Whether execution is on the lifecycle queue @chinese 判断当前是否处于生命周期串行队列 @return EN: Queue state. CN: 队列状态。 */
- (BOOL)isExecutingOnLifecycleQueue;

/** @brief Cancel all device voice-translation tasks @chinese 取消所有设备整段语音翻译任务 */
- (void)tsai_cancelAllDeviceVoiceTranslationTasks;

@end

@interface TSAIBudsInterpreterProvider (DeviceVoiceTranslation)
    <TSAIDeviceInterpreterProvider>
@end

NS_ASSUME_NONNULL_END
