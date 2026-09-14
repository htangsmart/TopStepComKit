//
//  TSFitAIChatSessionGate.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/12.
//

#import <Foundation/Foundation.h>

#import "TSFitAIEventListener.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Gate for deduplicating AI-chat session events and trailing audio
 * @chinese AIChat 会话事件去重与尾包控制门禁
 *
 * @discussion
 * [EN]: Keeps the current session boundary and allows trailing audio during
 *       a short termination grace period.
 * [CN]: 维护当前会话边界，并在终止后的短暂宽限期内允许尾包音频继续投递。
 */
@interface TSFitAIChatSessionGate : NSObject

/**
 * @brief Process an AI-chat session event
 * @chinese 处理一个 AIChat 会话事件
 *
 * @param event
 * EN: Normalized Fit AI-chat session event
 * CN: 归一化后的 Fit AIChat 会话事件
 *
 * @param publishBlock
 * EN: Synchronous publisher invoked only when the event is accepted
 * CN: 仅当事件被接受时同步执行的发布回调
 */
- (void)processSessionEvent:(TSFitAIChatSessionEvent)event
               publishBlock:(nullable void (^)(void))publishBlock;

/**
 * @brief Begin an App-origin AI-chat session boundary
 * @chinese 开始一个 App 发起的 AIChat 会话边界
 *
 * @param sessionIdentifier
 * EN: Stable identifier of the App-origin request
 * CN: App 发起请求的稳定标识
 */
- (void)beginAppSessionWithIdentifier:(NSString *)sessionIdentifier;

/**
 * @brief Confirm an App-origin AI-chat session boundary
 * @chinese 确认一个 App 发起的 AIChat 会话边界已打开
 *
 * @param sessionIdentifier
 * EN: Stable identifier of the App-origin request
 * CN: App 发起请求的稳定标识
 */
- (void)confirmAppSessionWithIdentifier:(NSString *)sessionIdentifier;

/**
 * @brief Close a matching App-origin AI-chat session boundary
 * @chinese 关闭一个匹配的 App 发起 AIChat 会话边界
 *
 * @param sessionIdentifier
 * EN: Stable identifier of the App-origin request
 * CN: App 发起请求的稳定标识
 */
- (void)closeAppSessionWithIdentifier:(NSString *)sessionIdentifier;

/**
 * @brief Decide whether current AI-chat audio can be published
 * @chinese 判断当前 AIChat 音频是否可以发布
 *
 * @param opusByteCount
 * EN: Number of Opus bytes in the callback
 * CN: 当前回调中的 Opus 字节数
 *
 * @param pcmByteCount
 * EN: Number of decoded PCM bytes in the callback
 * CN: 当前回调中的解码 PCM 字节数
 *
 * @return
 * EN: YES when the current session still accepts audio
 * CN: 当前会话仍接受音频时返回 YES
 */
- (BOOL)shouldPublishAudioWithOpusByteCount:(NSUInteger)opusByteCount
                               pcmByteCount:(NSUInteger)pcmByteCount;

/**
 * @brief Close the current AI-chat session boundary
 * @chinese 关闭当前 AIChat 会话边界
 *
 * @discussion
 * [EN]: Stops accepting audio from the previous session while allowing a
 *       later initiation event to open a new session.
 * [CN]: 停止接收旧会话音频，同时允许后续启动事件打开新会话。
 */
- (void)close;

/**
 * @brief Reset the AI-chat session boundary
 * @chinese 重置 AIChat 会话边界
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
