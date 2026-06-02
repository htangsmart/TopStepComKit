//
//  TSAIChatVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI voice chat test VC
 * @chinese AI 语音对话测试页
 *
 * @discussion
 * [EN]: Tests `TSAIAssistantInterface` voice-chat session — a long-running
 *       end-to-end voice conversation driven by device-microphone audio,
 *       VAD-segmented into multiple Q&A rounds. Verifies streaming content
 *       (question / answer text, TTS audio chunks, recognized intents),
 *       session-level events and the final report.
 * [CN]: 用于测试 `TSAIAssistantInterface` 的语音对话会话——由设备麦克风音频
 *       驱动的端到端长会话，由 VAD 自动断句产生多轮问答。验证流式 content
 *       （问题 / 回答文本、TTS 音频片段、识别到的意图）、会话级事件与最终
 *       报告。
 */
@interface TSAIChatVC : TSBaseVC

/**
 * @brief Start an AI chat session triggered by the connected device
 * @chinese 由已连接设备触发启动 AI 对话会话
 *
 * @discussion
 * [EN]: Called by the host VC when it receives `TSAIChatDeviceEventRequestStart`.
 *       Forces the view hierarchy to load if needed, then starts the session
 *       via `TSAIAssistantInterface startChatWithConfig:`. Safe to call when
 *       a session is already running (the call becomes a no-op).
 * [CN]: 当宿主页面收到 `TSAIChatDeviceEventRequestStart` 时调用。
 *       会先保证视图加载完毕，再通过 `TSAIAssistantInterface startChatWithConfig:`
 *       启动会话。若已有会话进行中，调用无副作用。
 */
- (void)startSessionFromDevice;

/**
 * @brief Stop the running AI chat session triggered by the connected device
 * @chinese 由已连接设备触发结束当前 AI 对话会话
 *
 * @discussion
 * [EN]: Called by the host VC when it receives `TSAIChatDeviceEventRequestEnd`
 *       or `TSAIChatDeviceEventInterrupted`. Internally calls
 *       `stopChatWithTaskId:` with the current taskId. No-op if no session
 *       is running.
 * [CN]: 当宿主页面收到 `TSAIChatDeviceEventRequestEnd` 或
 *       `TSAIChatDeviceEventInterrupted` 时调用，内部以当前 taskId 调用
 *       `stopChatWithTaskId:`。若无进行中的会话则无副作用。
 */
- (void)stopSessionFromDevice;

@end

NS_ASSUME_NONNULL_END
