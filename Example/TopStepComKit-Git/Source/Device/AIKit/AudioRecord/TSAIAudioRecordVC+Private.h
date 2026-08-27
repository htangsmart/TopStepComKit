//
//  TSAIAudioRecordVC+Private.h
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordVC.h"

@class TSAIAudioRecordConfig;
@class TSAIAudioRecordTranscriptView;
@class TSAIAudioRecordWaveformView;

NS_ASSUME_NONNULL_BEGIN

@interface TSAIAudioRecordVC ()

/** @brief Page scroll container. @chinese 页面滚动容器。 */
@property (nonatomic, strong) UIScrollView *scrollView;
/** @brief Vertical content stack. @chinese 纵向内容栈。 */
@property (nonatomic, strong) UIStackView *contentStackView;
/** @brief Session status card. @chinese 会话状态卡。 */
@property (nonatomic, strong) UIView *sessionCard;
/** @brief Device connection badge. @chinese 设备连接提示。 */
@property (nonatomic, strong) UILabel *deviceBadgeLabel;
/** @brief Current status title. @chinese 当前状态标题。 */
@property (nonatomic, strong) UILabel *statusLabel;
/** @brief Pulsing recording-state dot. @chinese 录音状态脉冲圆点。 */
@property (nonatomic, strong) UIView *recordingPulseView;
/** @brief Recording timer. @chinese 录音计时。 */
@property (nonatomic, strong) UILabel *timerLabel;
/** @brief Live waveform view. @chinese 实时波形视图。 */
@property (nonatomic, strong) TSAIAudioRecordWaveformView *waveformView;
/** @brief Recording source guidance text. @chinese 录音声源引导文案。 */
@property (nonatomic, strong) UILabel *recordHintLabel;
/** @brief Live transcript card. @chinese 实时转写卡。 */
@property (nonatomic, strong) UIView *transcriptCard;
/** @brief Responsive live transcript height. @chinese 响应式实时转写高度。 */
@property (nonatomic, strong) NSLayoutConstraint *transcriptCardHeightConstraint;
/** @brief Live structured transcript list. @chinese 实时结构化转写列表。 */
@property (nonatomic, strong) TSAIAudioRecordTranscriptView *transcriptView;
/** @brief Completed result card. @chinese 完成结果卡。 */
@property (nonatomic, strong) UIView *resultCard;
/** @brief Completed duration metric. @chinese 完成时长指标。 */
@property (nonatomic, strong) UILabel *durationMetricLabel;
/** @brief Completed transcript metric. @chinese 完成转写指标。 */
@property (nonatomic, strong) UILabel *transcriptMetricLabel;
/** @brief Completed speaker metric. @chinese 完成说话人指标。 */
@property (nonatomic, strong) UILabel *speakerMetricLabel;
/** @brief Result type segment control. @chinese 结果类型切换。 */
@property (nonatomic, strong) UISegmentedControl *resultSegmentControl;
/** @brief Result tab selection indicator. @chinese 结果标签选中指示条。 */
@property (nonatomic, strong) UIView *resultSelectionIndicator;
/** @brief Completed structured transcript list. @chinese 完成态结构化转写列表。 */
@property (nonatomic, strong) TSAIAudioRecordTranscriptView *resultTranscriptView;
/** @brief Completed session event text. @chinese 完成态会话事件文本。 */
@property (nonatomic, strong) UITextView *resultTextView;
/** @brief Bottom action bar. @chinese 底部操作栏。 */
@property (nonatomic, strong) UIView *bottomBar;
/** @brief Bottom bar height constraint. @chinese 底部操作栏高度约束。 */
@property (nonatomic, strong) NSLayoutConstraint *bottomBarHeightConstraint;
/** @brief Primary recording button. @chinese 录音主按钮。 */
@property (nonatomic, strong) UIButton *recordButton;
/** @brief Solid recording-button center. @chinese 录音按钮红色实心区域。 */
@property (nonatomic, strong) UIView *recordButtonFillView;
/** @brief Stop glyph shown while recording. @chinese 录音中展示的停止图形。 */
@property (nonatomic, strong) UIView *recordStopView;
/** @brief Primary action hint. @chinese 主操作说明。 */
@property (nonatomic, strong) UILabel *actionHintLabel;
/** @brief Bottom language selector. @chinese 底部语言选择器。 */
@property (nonatomic, strong) UIButton *bottomLanguageButton;
/** @brief Bottom recording metadata. @chinese 底部录音元数据。 */
@property (nonatomic, strong) UILabel *sideMetaLabel;
/** @brief Finalizing overlay. @chinese 最终结果整理遮罩。 */
@property (nonatomic, strong) UIView *finalizingOverlay;
/** @brief Finalizing activity indicator. @chinese 最终结果整理动画。 */
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
/** @brief Finalizing text. @chinese 最终结果整理文案。 */
@property (nonatomic, strong) UILabel *finalizingLabel;
/** @brief Recording help bottom-sheet overlay. @chinese 录音说明底部弹层遮罩。 */
@property (nonatomic, strong) UIView *recordingHelpOverlay;
/** @brief Recording help bottom sheet. @chinese 录音说明底部弹层。 */
@property (nonatomic, strong) UIView *recordingHelpSheet;
/** @brief Current page configuration. @chinese 当前页面配置。 */
@property (nonatomic, strong) TSAIAudioRecordConfig *config;
/** @brief Recording timer source. @chinese 录音计时器。 */
@property (nonatomic, strong, nullable) NSTimer *timer;
/** @brief Opens history after the active recording is saved. @chinese 当前录音保存后打开历史记录。 */
@property (nonatomic, assign) BOOL shouldOpenHistoryAfterStop;
/// @brief Returns to the previous page. @chinese 返回上一级页面。
- (void)handleBack;
/// @brief Presents the recording help sheet. @chinese 展示录音说明弹层。
- (void)handleShowRecordingHelp;
/// @brief Dismisses the recording help sheet. @chinese 关闭录音说明弹层。
- (void)handleCloseRecordingHelp;
/// @brief Opens recording history. @chinese 打开历史录音。
- (void)handleOpenRecordingHistory;
/// @brief Presents speech language selection. @chinese 展示语音语言选择。
- (void)handleLanguageSelection;
/// @brief Refreshes the selected result type. @chinese 刷新选中的结果类型。
- (void)handleResultSegmentChanged;
/// @brief Returns a completed session to ready state. @chinese 将完成会话恢复为准备状态。
- (void)handleRecordAgain;
/// @brief Finishes the page flow. @chinese 完成页面流程。
- (void)handleDone;
/// @brief Handles the primary recording action. @chinese 处理录音主操作。
- (void)handleRecordButton;
/// @brief Applies the pressed recording-button transform. @chinese 应用录音按钮按下形变。
- (void)handleRecordButtonTouchDown;
/// @brief Restores the recording-button transform. @chinese 恢复录音按钮形变。
- (void)handleRecordButtonTouchUp;

@end

NS_ASSUME_NONNULL_END
