//
//  TSAIConversationTranslationSnapshot.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAIConversationTranslationDefines.h"
#import "TSAIConversationTranslationTurn.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable snapshot of a conversation-translation session
 * @chinese 对话翻译会话的不可变快照
 *
 * @discussion
 * [EN]: Delivered on the main thread whenever state or any turn changes. The App
 *       re-renders from the snapshot and keeps no session state of its own.
 * [CN]: 状态或任意轮次变化时在主线程下发。App 只根据快照重绘，不自行维护会话状态。
 */
@interface TSAIConversationTranslationSnapshot : NSObject <NSCopying>

/**
 * @brief Session identifier returned by `startWithConfig:...`
 * @chinese `startWithConfig:...` 返回的会话标识
 */
@property (nonatomic, copy, readonly) NSString *sessionId;

/**
 * @brief Product mode of the session
 * @chinese 会话的产品模式
 */
@property (nonatomic, assign, readonly) TSAIConversationTranslationMode mode;

/**
 * @brief Current session state
 * @chinese 当前会话状态
 */
@property (nonatomic, assign, readonly) TSAIConversationTranslationState state;

/**
 * @brief Participant currently speaking or being translated; None when idle
 * @chinese 当前正在发言或翻译的参与者；空闲时为 None
 */
@property (nonatomic, assign, readonly) TSAIConversationParticipant activeParticipant;

/**
 * @brief All turns in chronological order, including the active one
 * @chinese 按时间顺序排列的全部轮次，含进行中的一轮
 */
@property (nonatomic, copy, readonly) NSArray<TSAIConversationTranslationTurn *> *turns;

/**
 * @brief Create an immutable snapshot
 * @chinese 创建不可变快照
 *
 * @param sessionId EN: Session identifier. CN: 会话标识。
 * @param mode EN: Product mode. CN: 产品模式。
 * @param state EN: Session state. CN: 会话状态。
 * @param activeParticipant EN: Active participant. CN: 当前参与者。
 * @param turns EN: Turns in order. CN: 按序轮次。
 *
 * @return
 * EN: Immutable snapshot
 * CN: 不可变快照
 */
+ (instancetype)snapshotWithSessionId:(NSString *)sessionId
                                 mode:(TSAIConversationTranslationMode)mode
                                state:(TSAIConversationTranslationState)state
                    activeParticipant:(TSAIConversationParticipant)activeParticipant
                                turns:(NSArray<TSAIConversationTranslationTurn *> *)turns;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
