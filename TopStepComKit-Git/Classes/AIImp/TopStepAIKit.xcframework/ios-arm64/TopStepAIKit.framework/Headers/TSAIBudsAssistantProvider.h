//
//  TSAIBudsAssistantProvider.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/23.
//

#import <Foundation/Foundation.h>
#import "TSAIAssistantProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AIBuds implementation of assistant capability
 * @chinese AIBuds 助手能力实现
 */
@interface TSAIBudsAssistantProvider : NSObject <TSAIAssistantProvider>

/**
 * @brief Receive device-side AI chat session event
 * @chinese 接收设备侧 AI 对话会话事件
 *
 * @param eventNumber
 * EN: NSNumber wrapped AIBudsAIChatSessionEvent value
 * CN: NSNumber 包装的 AIBudsAIChatSessionEvent 事件值
 */
- (void)didReceiveAiChatSessionEvent:(NSNumber *)eventNumber;

/**
 * @brief Notify AI audio chat voice data
 * @chinese 通知 AI 对话语音数据
 *
 * @param opusData
 * EN: Opus data
 * CN: Opus 数据
 *
 * @param pcmData
 * EN: PCM data
 * CN: PCM 数据
 */
- (void)onAIChatDeltaOpusVoiceDataWithParams:(NSData * _Nullable)opusData
                                     pcmData:(NSData * _Nullable)pcmData;



@end

NS_ASSUME_NONNULL_END
