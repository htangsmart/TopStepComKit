//
//  TSAIInterpreterVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI simultaneous-interpretation test VC
 * @chinese AI 同声传译测试页
 *
 * @discussion
 * [EN]: Tests `TSAIInterpreterInterface` — a long-running end-to-end voice
 *       pipeline ASR -> MT -> (optional) TTS driven by device-microphone
 *       audio. Each VAD-segmented utterance streams back as original text +
 *       streaming translation (+ optional translation TTS audio).
 *
 *       Layout (top to bottom):
 *         - Language bar: source ⇄ target pills (Auto allowed on source)
 *         - Status strip: idle / running indicator + taskId
 *         - Settings card: TTS / autoPlay / speakerId
 *         - Transcript table: one cell per utterance, dual rows (orig / trans)
 *         - Log view: events + completion
 *         - Mic button: Start / Stop (no cancel — interpretation has only stop)
 * [CN]: 用于测试 `TSAIInterpreterInterface`——由设备麦克风音频驱动的端到端
 *       ASR -> MT -> 可选 TTS 长会话管线。每段 VAD 切出的 utterance 流式
 *       回传原文与译文（及可选译文 TTS 音频）。
 *
 *       页面布局（自上而下）：
 *         - 语言条：源 ⇄ 目标语言胶囊（源支持 Auto）
 *         - 状态条：idle / running 指示 + taskId
 *         - 设置卡：TTS / 自动播放 / speakerId
 *         - 字幕表：每段 utterance 一个 cell，原文 / 译文双行
 *         - 日志区：事件 + completion
 *         - 麦克风按钮：Start / Stop（同传只有 stop，无 cancel）
 */
@interface TSAIInterpreterVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
