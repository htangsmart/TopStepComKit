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
 *       and is never covered.
 * [CN]: 录音时（规范 §3.4 v1.3）胶囊原位变形：输入框与发送键淡出，红点 + 计时 +
 *       26 根波形淡入，麦克风上方 84pt 浮出取消靶点。麦克风键位置不变、不被遮挡。
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

/** @brief Whether the capsule is in the recording state @chinese 胶囊是否处于录音态 */
@property (nonatomic, assign, readonly) BOOL isRecording;

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
 * @brief Morph the capsule into the recording bar
 * @chinese 胶囊原位进入录音态
 * @param showCancelTarget EN: Show the cancel target (NO for headset-driven rounds). CN: 是否显示取消靶点（耳机唤醒为 NO）。
 * @param hint EN: Hint line text. CN: 提示行文案。
 */
- (void)enterRecordingWithCancelTarget:(BOOL)showCancelTarget hint:(NSString *)hint;

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
