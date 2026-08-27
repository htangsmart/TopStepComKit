//
//  TSAIBudsCapabilityProvider+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import "TSAIBudsAssistantProvider.h"
#import "TSAIBudsAudioRecordProvider.h"
#import "TSAIBudsInterpreterProvider.h"
#import "TSAIBudsSpeechProvider.h"
#import "TSAIBudsTranslateProvider.h"

@class TSAIBudsSessionStore;
@class TSAIBudsManager;
@protocol TSAIDeviceBridge;

NS_ASSUME_NONNULL_BEGIN

@interface TSAIBudsAssistantProvider (Internal)

/** @brief Platform bridge used for audio-record capabilities and commands @chinese 用于录音能力与命令的平台 Bridge */
@property (nonatomic, strong, nullable) id<TSAIDeviceBridge> supportDeviceBridge;

/**
 * @brief Create an assistant provider with a Context-owned session store
 * @chinese 使用 Context 持有的会话存储创建助手 Provider
 *
 * @param sessionStore
 * EN: Session store owned by the same Context
 * CN: 同一 Context 持有的会话存储
 *
 * @return
 * EN: A new assistant provider
 * CN: 新的助手 Provider
 */
- (instancetype)initWithSessionStore:(TSAIBudsSessionStore *)sessionStore;

@end

@interface TSAIBudsSpeechProvider (Internal)

/** @brief Platform bridge used for support queries @chinese 用于查询支持度的平台 Bridge */
@property (nonatomic, strong, nullable) id<TSAIDeviceBridge> supportDeviceBridge;

/**
 * @brief Create a speech provider with a Context-owned session store
 * @chinese 使用 Context 持有的会话存储创建语音 Provider
 *
 * @param sessionStore
 * EN: Session store owned by the same Context
 * CN: 同一 Context 持有的会话存储
 *
 * @return
 * EN: A new speech provider
 * CN: 新的语音 Provider
 */
- (instancetype)initWithSessionStore:(TSAIBudsSessionStore *)sessionStore;

/**
 * @brief Create a speech provider with shared Manager and session store
 * @chinese 使用共享 Manager 与会话存储创建语音 Provider
 */
- (instancetype)initWithManager:(TSAIBudsManager *)manager
                   sessionStore:(TSAIBudsSessionStore *)sessionStore;

@end

@interface TSAIBudsInterpreterProvider (Internal)

/** @brief Platform bridge used for support queries @chinese 用于查询支持度的平台 Bridge */
@property (nonatomic, strong, nullable) id<TSAIDeviceBridge> supportDeviceBridge;

/**
 * @brief Create an interpreter provider with a Context-owned session store
 * @chinese 使用 Context 持有的会话存储创建同传 Provider
 *
 * @param sessionStore
 * EN: Session store owned by the same Context
 * CN: 同一 Context 持有的会话存储
 *
 * @return
 * EN: A new interpreter provider
 * CN: 新的同传 Provider
 */
- (instancetype)initWithSessionStore:(TSAIBudsSessionStore *)sessionStore;

/**
 * @brief Create an interpreter Provider with shared speech and translate Providers
 * @chinese 使用共享语音与文本翻译 Provider 创建同传 Provider
 * @param sessionStore EN: Context-owned store. CN: Context 持有的会话存储。
 * @param speechProvider EN: Shared speech Provider. CN: 共享语音 Provider。
 * @param translateProvider EN: Shared translate Provider. CN: 共享文本翻译 Provider。
 * @return EN: Provider instance. CN: Provider 实例。
 */
- (instancetype)initWithSessionStore:(TSAIBudsSessionStore *)sessionStore
                       speechProvider:(id<TSAISpeechProvider>)speechProvider
                    translateProvider:(id<TSAITranslateProvider>)translateProvider;

@end

@interface TSAIBudsAudioRecordProvider (Internal)

/** @brief Platform bridge used for support queries @chinese 用于查询支持度的平台 Bridge */
@property (nonatomic, strong, nullable) id<TSAIDeviceBridge> supportDeviceBridge;

/**
 * @brief Create an audio record provider with a Context-owned session store
 * @chinese 使用 Context 持有的会话存储创建录音 Provider
 *
 * @param sessionStore
 * EN: Session store owned by the same Context
 * CN: 同一 Context 持有的会话存储
 *
 * @return
 * EN: A new audio record provider
 * CN: 新的录音 Provider
 */
- (instancetype)initWithSessionStore:(TSAIBudsSessionStore *)sessionStore;

@end

@interface TSAIBudsTranslateProvider (Internal)

/** @brief Platform bridge used for support queries @chinese 用于查询支持度的平台 Bridge */
@property (nonatomic, strong, nullable) id<TSAIDeviceBridge> supportDeviceBridge;

@end

NS_ASSUME_NONNULL_END
