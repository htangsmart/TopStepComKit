//
//  TSAIConversationTranslationCoordinator+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAIConversationTranslationConfig.h"
#import "TSAIConversationTranslationDefines.h"
#import "TSAIStartEligibility.h"

@class TSAIContext;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal coordinator for two-party conversation translation
 * @chinese 双人对话翻译的内部编排器
 *
 * @discussion
 * [EN]: Owns one session at a time: the device product mode (0xB3), the
 *       per-turn device session (0x6F / 0x6E) and the interpreter task of each
 *       turn, and selects the audio route of every turn from the product mode.
 *       Device-initiated turns arrive through the handler override the
 *       coordinator installs on the Context. All state lives on the main thread.
 * [CN]: 同一时间只持有一次会话：设备产品模式（0xB3）、每轮设备会话（0x6F / 0x6E）
 *       与每轮同传任务，并根据产品模式为每轮选择音频路由。设备发起的轮次通过编排器安装在
 *       Context 上的处理器覆盖层进入。全部状态在主线程维护。
 */
@interface TSAIConversationTranslationCoordinator : NSObject

/**
 * @brief Create a coordinator bound to one Context
 * @chinese 创建绑定到指定 Context 的编排器
 * @param context EN: Owning Context. CN: 所属 Context。
 * @return EN: Idle coordinator. CN: 空闲的编排器。
 */
- (instancetype)initWithContext:(TSAIContext *)context NS_DESIGNATED_INITIALIZER;

/**
 * @brief Whether a session is active
 * @chinese 是否存在活动会话
 */
@property (nonatomic, assign, readonly) BOOL isSessionActive;

/**
 * @brief Evaluate whether a product mode can start now
 * @chinese 校验产品模式当前能否启动
 * @param mode EN: Product mode. CN: 产品模式。
 * @return EN: Eligibility. CN: 启动资格。
 */
- (TSAIStartEligibility *)eligibilityForMode:(TSAIConversationTranslationMode)mode;

/**
 * @brief Evaluate whether a configuration (mode plus endpoints) can start now
 * @chinese 校验配置（模式加收音/播报端）当前能否启动
 * @param config EN: Session configuration. CN: 会话配置。
 * @return EN: Eligibility. CN: 启动资格。
 */
- (TSAIStartEligibility *)eligibilityForConfig:(TSAIConversationTranslationConfig *)config;

/**
 * @brief Start a session
 * @chinese 启动会话
 * @param config EN: Session configuration. CN: 会话配置。
 * @param onSnapshot EN: Snapshot callback. CN: 快照回调。
 * @param onEvent EN: Event callback. CN: 事件回调。
 * @param completion EN: Session completion. CN: 会话结束回调。
 * @return EN: Session identifier, or nil when the session cannot start. CN: 会话标识；无法启动时为 nil。
 */
- (nullable NSString *)startWithConfig:(TSAIConversationTranslationConfig *)config
                            onSnapshot:(nullable TSAIConversationTranslationSnapshotBlock)onSnapshot
                               onEvent:(nullable TSAIConversationTranslationEventBlock)onEvent
                            completion:(nullable TSAIConversationTranslationCompletionBlock)completion;

/**
 * @brief Begin an App-initiated turn
 * @chinese 开始 App 发起的轮次
 * @param participant EN: Speaking participant. CN: 发言参与者。
 * @param sessionId EN: Session identifier. CN: 会话标识。
 */
- (void)beginTurnForParticipant:(TSAIConversationParticipant)participant
                      sessionId:(NSString *)sessionId;

/**
 * @brief End the current App-initiated turn
 * @chinese 结束当前 App 发起的轮次
 * @param sessionId EN: Session identifier. CN: 会话标识。
 */
- (void)endTurnWithSessionId:(NSString *)sessionId;

/**
 * @brief Stop the session on App request
 * @chinese App 主动结束会话
 * @param sessionId EN: Session identifier. CN: 会话标识。
 * @param completion EN: Device command result. CN: 设备命令结果。
 */
- (void)stopWithSessionId:(NSString *)sessionId
               completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Handle a device-side exit or interruption of the product mode
 * @chinese 处理设备侧退出或中断产品模式
 * @param reason EN: Device reason. CN: 设备原因。
 */
- (void)handleDeviceInterruptionWithReason:(TSAIDeviceInterruptionReason)reason;

/**
 * @brief Handle device disconnection; no device command is sent afterwards
 * @chinese 处理设备断开；之后不再向设备发送命令
 */
- (void)handleDeviceDisconnected;

/**
 * @brief End any session because the Context is going inactive
 * @chinese 因 Context 失活结束会话
 */
- (void)invalidate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
