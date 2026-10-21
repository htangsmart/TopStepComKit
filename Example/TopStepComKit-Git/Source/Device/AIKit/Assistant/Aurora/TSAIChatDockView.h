//
//  TSAIChatDockView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Bottom capsule of chat mode: hint line + text field + send + press-to-talk mic (spec §3.3)
 * @chinese 对话模式底部胶囊：提示行 + 输入框 + 发送 + 按住说话麦克风（规范 §3.3）
 *
 * @discussion
 * [EN]: While recording (spec §3.4 v1.3) the capsule morphs in place: the text
 *       field and send button fade out, a red dot + timer + 26-bar waveform fade
 *       in, and a cancel target floats 84pt above the mic. The mic never moves
 *       and is never covered. The recording bar has two looks: preparing (pressed,
 *       the microphone is not capturing yet: gentle breathing waveform, timer held
 *       at 00:00) and listening (after InputReady: live waveform, running timer).
 * [CN]: 录音时（规范 §3.4 v1.3）胶囊原位变形：输入框与发送键淡出，红点 + 计时 +
 *       26 根波形淡入，麦克风上方 84pt 浮出取消靶点。麦克风键位置不变、不被遮挡。
 *       录音条有两种样式：准备中（已按下、麦克风还没出数据：波形平缓呼吸，计时停在
 *       00:00）与正在听（InputReady 之后：波形跳动、开始计时）。
 */
@interface TSAIChatDockView : UIView

/** @brief Busy: input disabled, mic grey, hint in violet @chinese 忙碌：输入禁用、麦克风置灰、提示行紫色 */
@property (nonatomic, assign) BOOL busy;

/** @brief Hint text (empty hides) @chinese 提示行文案（空则隐藏） */
@property (nonatomic, copy, nullable) NSString *hintText;

/** @brief Idle pulse ring around the mic (only when idle and no rounds) @chinese 麦克风空闲脉冲（仅空闲且无记录时） */
@property (nonatomic, assign) BOOL pulseEnabled;

/** @brief Text field @chinese 输入框 */
@property (nonatomic, strong, readonly) UITextField *textField;

/** @brief Whether the capsule is in the recording state (preparing or listening) @chinese 胶囊是否处于录音态（准备中或正在听） */
@property (nonatomic, assign, readonly) BOOL isRecording;

/**
 * @brief Whether the recording bar is in the preparing look
 * @chinese 录音条是否处于「准备中」样式
 *
 * @discussion
 * [EN]: YES from -enterPreparingWithCancelTarget:hint: until -enterListeningWithHint: or -exitRecording.
 * [CN]: 从 -enterPreparingWithCancelTarget:hint: 起，到 -enterListeningWithHint: 或 -exitRecording 为止为 YES。
 */
@property (nonatomic, assign, readonly) BOOL isPreparing;

/** @brief Elapsed seconds shown by the recording timer @chinese 录音计时显示的秒数 */
@property (nonatomic, assign) NSTimeInterval recordingElapsed;

/** @brief Cancel state (rose tint, 「松开取消」) @chinese 取消态（玫红，「松开取消」） */
@property (nonatomic, assign) BOOL recordingCancelling;

/** @brief Optional input level 0–1 driving the waveform; < 0 simulates @chinese 可选的输入电平 0–1 驱动波形；< 0 用模拟 */
@property (nonatomic, assign) CGFloat inputLevel;

/** @brief Called with trimmed text on return / send @chinese 回车或点发送时回调去除首尾空白的文本 */
@property (nonatomic, copy, nullable) void (^onSend)(NSString *text);

/** @brief Press began on the mic @chinese 麦克风按下 */
@property (nonatomic, copy, nullable) void (^onPressBegan)(void);

/** @brief Finger moved; `cancelling` = lifted more than 70pt @chinese 手指移动；`cancelling` = 上滑超过 70pt */
@property (nonatomic, copy, nullable) void (^onPressMoved)(BOOL cancelling);

/** @brief Press ended; `cancelled` when released in the cancel zone @chinese 松开；取消区松开时 `cancelled` 为 YES */
@property (nonatomic, copy, nullable) void (^onPressEnded)(BOOL cancelled);

/** @brief Content height without the safe-area inset @chinese 不含安全区的内容高度 */
+ (CGFloat)contentHeight;

/**
 * @brief Morph the capsule into the recording bar, preparing look (pressed, microphone not capturing yet)
 * @chinese 胶囊原位进入录音态的「准备中」样式（已按下，麦克风还没出数据）
 *
 * @discussion
 * [EN]: Light haptic, press animation of the mic, the recording bar pops in. The waveform only
 *       breathes gently and the timer stays at 00:00. Call -enterListeningWithHint: once the SDK
 *       reports InputReady. Ignored while already recording.
 * [CN]: 轻触感、麦克风按下动画、录音条弹入。波形只平缓呼吸，计时停在 00:00。SDK 报告 InputReady 后
 *       调用 -enterListeningWithHint:。已在录音态时忽略。
 *
 * @param showCancelTarget
 * EN: Show the cancel target above the mic
 * CN: 是否在麦克风上方显示取消靶点
 *
 * @param hint
 * EN: Hint line text, e.g. 「准备中…」
 * CN: 提示行文案，如「准备中…」
 */
- (void)enterPreparingWithCancelTarget:(BOOL)showCancelTarget hint:(NSString *)hint;

/**
 * @brief Switch the recording bar from preparing to listening
 * @chinese 录音条从「准备中」切到「正在听」
 *
 * @discussion
 * [EN]: Selection haptic; the red dot blinks, the waveform starts moving and the timer runs from 00:00
 *       (the caller updates recordingElapsed). Ignored when not preparing.
 * [CN]: 选择触感；红点开始闪烁、波形开始跳动、计时从 00:00 开始（由调用方更新 recordingElapsed）。
 *       不在「准备中」时忽略。
 *
 * @param hint
 * EN: Hint line text
 * CN: 提示行文案
 */
- (void)enterListeningWithHint:(NSString *)hint;

/**
 * @brief Restore the capsule to the input state
 * @chinese 胶囊恢复输入态
 */
- (void)exitRecording;

/**
 * @brief Restart the pulse animation after returning to a window
 * @chinese 回到窗口后重启脉冲动画
 */
- (void)restartAnimations;

@end

NS_ASSUME_NONNULL_END
