//
//  TSAIChatMicButton.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Mic button visual state
 * @chinese 麦克风按钮视觉状态
 */
typedef NS_ENUM(NSInteger, TSAIChatMicButtonState) {
    /// 空闲（灰底，静态）/ Idle: gray, static
    TSAIChatMicButtonStateIdle      = 0,
    /// 聆听中（蓝底 + 同心圆波纹） / Listening: blue + concentric ripples
    TSAIChatMicButtonStateListening = 1,
    /// 思考中（紫底 + 三点闪烁） / Thinking: purple + 3-dot blinking
    TSAIChatMicButtonStateThinking  = 2,
    /// 回复中（绿底 + 波形） / Speaking: green + wave bars
    TSAIChatMicButtonStateSpeaking  = 3,
};

/**
 * @brief Round mic button driving the AI chat session lifecycle
 * @chinese 驱动 AI 对话会话生命周期的圆形麦克风按钮
 *
 * @discussion
 * [EN]: A 96pt circular button with four visual states matching the chat
 *       state machine. Tapping issues a `tapBlock` callback so the host VC
 *       can decide between start / stop based on session state.
 * [CN]: 96pt 圆形按钮，与对话状态机一一对应的四种视觉。
 *       点击时触发 `tapBlock`，由宿主 VC 根据当前会话状态决定 start / stop。
 */
@interface TSAIChatMicButton : UIControl

/**
 * @brief Current visual state
 * @chinese 当前视觉状态
 */
@property (nonatomic, assign) TSAIChatMicButtonState micState;

/**
 * @brief Tap callback
 * @chinese 点击回调
 */
@property (nonatomic, copy, nullable) void(^onTap)(void);

@end

NS_ASSUME_NONNULL_END
