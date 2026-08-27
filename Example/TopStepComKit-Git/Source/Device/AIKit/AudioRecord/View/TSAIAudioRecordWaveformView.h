//
//  TSAIAudioRecordWaveformView.h
//  TopStepComKit-Git_Example
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// @brief Lightweight audio-level waveform used by the AI recording Demo.
/// @chinese AI 录音 Demo 使用的轻量音量波形。
@interface TSAIAudioRecordWaveformView : UIView

/// @brief Appends one normalized audio level in the range 0...1.
/// @chinese 追加一个 0...1 范围的标准化音量。
/// @param level Normalized audio level. / 标准化音量。
- (void)appendAudioLevel:(CGFloat)level;

/// @brief Clears the waveform history.
/// @chinese 清空波形历史。
- (void)resetWaveform;

/// @brief Updates whether the waveform should render active recording levels.
/// @chinese 更新波形是否展示录音中的活跃音量。
/// @param recordingActive Whether recording is active. / 是否正在录音。
- (void)setRecordingActive:(BOOL)recordingActive;

@end

NS_ASSUME_NONNULL_END
