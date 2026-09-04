//
//  TSAIAssistantProvider+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Optional external-PCM input implemented by a chat Provider
 * @chinese Chat Provider 可选实现的外部 PCM 输入
 */
@protocol TSAIExternalPCMChatProvider <NSObject>

/**
 * @brief Append 16 kHz mono Int16LE PCM to the active chat
 * @chinese 向活动对话追加 16 kHz 单声道 Int16LE PCM
 */
- (void)appendExternalPCMData:(NSData *)pcmData;

@end

/**
 * @brief Internal rollback hook for pending device-origin chat preparation
 * @chinese 设备发起 Chat pending 准备的内部回滚钩子
 */
@protocol TSAIDeviceChatPreparationManaging <NSObject>

/**
 * @brief Reset pending input without stopping an active chat task
 * @chinese 清理 pending 输入，但不得停止活动 Chat 任务
 */
- (void)resetPendingDeviceChatPreparation;

@end

NS_ASSUME_NONNULL_END
