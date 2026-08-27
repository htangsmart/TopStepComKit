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
 *       报告。会话由进程级协调器管理，页面不拥有会话生命周期。
 */
@interface TSAIChatVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
