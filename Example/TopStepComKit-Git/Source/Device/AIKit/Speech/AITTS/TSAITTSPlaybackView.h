//
//  TSAITTSPlaybackView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Playback display modes for the TTS test screen
 * @chinese TTS 测试页结果区的展示模式
 */
typedef NS_ENUM(NSInteger, TSAITTSPlaybackMode) {
    /// 空态：尚未合成或合成中（显示提示文字）
    TSAITTSPlaybackModeEmpty   = 0,
    /// 已合成：展示元信息 + 「▶ 播放」按钮
    TSAITTSPlaybackModeReady   = 1,
    /// 播放中：波形动效 + 进度条 + 「⏸ 暂停」「⏹ 停止」
    TSAITTSPlaybackModePlaying = 2,
    /// 已暂停：进度条停留 + 「▶ 继续」「⏹ 停止」
    TSAITTSPlaybackModePaused  = 3,
    /// 错误展示（失败 / 已取消）：彩色错误条
    TSAITTSPlaybackModeError   = 4,
};

@class TSAITTSPlaybackView;

/**
 * @brief Playback view delegate
 * @chinese 播放视图委托
 *
 * @discussion
 * [EN]: All callbacks are invoked on the main thread. The host VC is
 *       responsible for state transitions; the view itself only emits intent.
 * [CN]: 所有回调都在主线程触发。状态切换由宿主 VC 负责，视图自身只发出意图。
 */
@protocol TSAITTSPlaybackViewDelegate <NSObject>

/// 用户点击「▶ 播放」（仅 Ready）
- (void)playbackViewDidRequestPlay:(TSAITTSPlaybackView *)view;
/// 用户点击「⏸ 暂停」（仅 Playing）
- (void)playbackViewDidRequestPause:(TSAITTSPlaybackView *)view;
/// 用户点击「▶ 继续」（仅 Paused）
- (void)playbackViewDidRequestResume:(TSAITTSPlaybackView *)view;
/// 用户点击「⏹ 停止」
- (void)playbackViewDidRequestStop:(TSAITTSPlaybackView *)view;
/// 音频播放自然结束（AVAudioPlayer 完成回调）
- (void)playbackViewDidFinishPlayback:(TSAITTSPlaybackView *)view successfully:(BOOL)flag;

@end

/**
 * @brief TTS test screen result + playback view
 * @chinese TTS 测试页的结果展示 + 音频播放视图
 *
 * @discussion
 * [EN]: Encapsulates result metadata, animated waveform, progress bar,
 *       play/pause/stop buttons, error banner, and the underlying
 *       AVAudioPlayer (auto-wraps raw PCM into a WAV container before
 *       playback). The host VC drives mode transitions; this view manages
 *       its own subviews and player lifecycle.
 * [CN]: 封装合成结果元信息、波形动效、进度条、播放/暂停/停止按钮、错误条
 *       以及底层 AVAudioPlayer（裸 PCM 自动包成 WAV 后再播放）。宿主 VC
 *       驱动模式切换，视图自管子视图与播放器生命周期。
 */
@interface TSAITTSPlaybackView : UIView

/// 委托
@property (nonatomic, weak, nullable) id<TSAITTSPlaybackViewDelegate> delegate;
/// 当前模式（外部只读，使用 configureWith… / showError… 方法切换）
@property (nonatomic, assign, readonly) TSAITTSPlaybackMode mode;

/**
 * @brief Reset to empty mode with the given hint
 * @chinese 重置到空态并展示指定提示文案
 */
- (void)showEmptyWithHint:(NSString *)hint;

/**
 * @brief Switch to Ready mode and display the synthesis result metadata
 * @chinese 切到 Ready 模式并展示合成结果元信息
 *
 * @param result
 * EN: Synthesized audio result; must not be nil
 * CN: 合成结果，不可为 nil
 *
 * @param synthesizeDurationMs
 * EN: Client-side measured synthesize duration in milliseconds
 * CN: 客户端测得的合成耗时（毫秒）
 */
- (void)showReadyWithResult:(TSAITTSResult *)result synthesizeDurationMs:(NSTimeInterval)synthesizeDurationMs;

/**
 * @brief Switch to Error mode (failed or cancelled)
 * @chinese 切到错误模式（失败或已取消）
 *
 * @param title       面板标题（如「合成失败」「已取消」）
 * @param detail      详细描述（含 domain / code / msg）
 * @param accentColor 错误条主题色（失败用 Danger，取消用 Warning）
 */
- (void)showErrorWithTitle:(NSString *)title detail:(NSString *)detail accentColor:(UIColor *)accentColor;

/**
 * @brief Start playback of the current result
 * @chinese 开始播放当前结果
 *
 * @return EN: NO if no audio is loaded or format is unsupported  CN: 若无音频或格式不支持则返回 NO
 */
- (BOOL)startPlayback;

/**
 * @brief Pause playback (no-op if not playing)
 * @chinese 暂停播放（非播放中调用无效）
 */
- (void)pausePlayback;

/**
 * @brief Resume playback (no-op if not paused)
 * @chinese 继续播放（非暂停中调用无效）
 */
- (void)resumePlayback;

/**
 * @brief Stop playback and tear down the underlying player
 * @chinese 停止播放并释放底层播放器
 */
- (void)stopPlayback;

@end

NS_ASSUME_NONNULL_END
