//
//  TSAIConversationTranslationEvent.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAIConversationTranslationDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Discrete event inside a conversation-translation session
 * @chinese 对话翻译会话中的离散事件
 *
 * @discussion
 * [EN]: Events complement snapshots: a snapshot tells what the session looks
 *       like now, an event tells that something happened once (a rejected
 *       press, a failed turn). Delivered on the main thread.
 * [CN]: 事件是快照的补充：快照描述会话现状，事件描述一次性发生的事情（按下被拒绝、
 *       一轮失败）。在主线程下发。
 */
@interface TSAIConversationTranslationEvent : NSObject

/**
 * @brief Event type
 * @chinese 事件类型
 */
@property (nonatomic, assign, readonly) TSAIConversationTranslationEventType eventType;

/**
 * @brief Participant the event refers to; None when not applicable
 * @chinese 事件涉及的参与者；不适用时为 None
 */
@property (nonatomic, assign, readonly) TSAIConversationParticipant participant;

/**
 * @brief Side that triggered the event; Invalid when not applicable
 * @chinese 触发事件的一方；不适用时为 Invalid
 */
@property (nonatomic, assign, readonly) TSAISessionInitiator initiator;

/**
 * @brief Turn the event refers to; nil when not applicable
 * @chinese 事件涉及的轮次标识；不适用时为 nil
 */
@property (nonatomic, copy, readonly, nullable) NSString *turnId;

/**
 * @brief Error carried by failure events
 * @chinese 失败事件携带的错误
 */
@property (nonatomic, strong, readonly, nullable) NSError *error;

/**
 * @brief Create an event
 * @chinese 创建事件
 *
 * @param eventType EN: Event type. CN: 事件类型。
 * @param participant EN: Related participant. CN: 相关参与者。
 * @param initiator EN: Triggering side. CN: 触发方。
 * @param turnId EN: Related turn. CN: 相关轮次。
 * @param error EN: Failure error. CN: 失败错误。
 *
 * @return
 * EN: Immutable event
 * CN: 不可变事件
 */
+ (instancetype)eventWithType:(TSAIConversationTranslationEventType)eventType
                  participant:(TSAIConversationParticipant)participant
                    initiator:(TSAISessionInitiator)initiator
                       turnId:(nullable NSString *)turnId
                        error:(nullable NSError *)error;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
