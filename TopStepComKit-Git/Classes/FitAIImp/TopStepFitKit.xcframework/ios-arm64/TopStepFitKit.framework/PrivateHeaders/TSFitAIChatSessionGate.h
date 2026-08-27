//
//  TSFitAIChatSessionGate.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/12.
//

#import <Foundation/Foundation.h>
#import <FitCloudKit/FitCloudKitDefines.h>

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
 * EN: Raw FitCloud AI-chat session event
 * CN: FitCloud 原始 AIChat 会话事件
 *
 * @param publishBlock
 * EN: Synchronous publisher invoked only when the event is accepted
 * CN: 仅当事件被接受时同步执行的发布回调
 */
- (void)processSessionEvent:(FitCloudAIChatSessionEvent)event
               publishBlock:(nullable void (^)(void))publishBlock;

/**
 * @brief Check whether current AI-chat audio can be published
 * @chinese 检查当前 AIChat 音频是否可以发布
 *
 * @return
 * EN: YES when the current session still accepts audio
 * CN: 当前会话仍接受音频时返回 YES
 */
- (BOOL)canPublishAudioData;

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
