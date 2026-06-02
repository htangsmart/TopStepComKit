//
//  TSAIASRDeviceMicVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIASRDeviceMicVC.h"

#import <AVFoundation/AVFoundation.h>

#import "TSAILogView.h"

#pragma mark - 状态机

typedef NS_ENUM(NSInteger, TSAIASRDMicState) {
    TSAIASRDMicStateIdle = 0,
    TSAIASRDMicStateStarting,
    TSAIASRDMicStateRecognizing,
    TSAIASRDMicStateStopping,
    TSAIASRDMicStateCancelling,
    TSAIASRDMicStateFinished,
    TSAIASRDMicStateCancelled,
    TSAIASRDMicStateFailed,
    TSAIASRDMicStateUnsupported,
};

@interface TSAIASRDeviceMicVC () <AVAudioPlayerDelegate>

#pragma mark - 状态
/// 当前状态
@property (nonatomic, assign) TSAIASRDMicState currentState;
/// 当前进行中的任务 ID（nil 表示空闲）
@property (nonatomic, copy, nullable) NSString *currentTaskId;
/// SDK 句柄
@property (nonatomic, strong, nullable) id<TSAISpeechInterface> speech;

#pragma mark - 配置
/// 已选语言（默认未选）
@property (nonatomic, assign) TSAILanguage selectedLanguage;
/// 已选场景（默认 Unknown）
@property (nonatomic, assign) TSAIASRScene selectedScene;
/// 离线降级开关
@property (nonatomic, assign) BOOL offlineFallbackEnabled;
/// 已选录音格式（默认 MP3）
@property (nonatomic, assign) TSAIAudioFormat selectedAudioFormat;

#pragma mark - 会话状态
/// 已稳定文本（isSentenceFinal=YES 的句子拼接）
@property (nonatomic, copy) NSString *finalizedText;
/// 当前句仍在修订的尾巴（isSentenceFinal=NO 时的累计 - 已稳定）
@property (nonatomic, copy) NSString *pendingText;
/// 上一次 partial 的累积全文，用于推导 pendingText
@property (nonatomic, copy) NSString *lastCumulativeText;
/// 上一次 partial 是否已稳定，用于决定下一次进入新句
@property (nonatomic, assign) BOOL lastPartialFinal;
/// 已收到的 partial 计数（仅日志）
@property (nonatomic, assign) NSUInteger partialCount;
/// 任务开始时间（墙钟）
@property (nonatomic, strong, nullable) NSDate *taskStartDate;
/// 计时定时器，用于刷新 meta 行
@property (nonatomic, strong, nullable) NSTimer *elapsedTimer;
/// 最近一次完成的最终结果（仅 Finished 状态有意义）
@property (nonatomic, strong, nullable) TSAIASRDeviceMicResult *lastResult;
/// 最近一次的错误（Failed / Cancelled 状态有意义）
@property (nonatomic, strong, nullable) NSError *lastError;

#pragma mark - 顶部状态条
@property (nonatomic, strong) UIView *deviceBar;
@property (nonatomic, strong) UIView *deviceDot;
@property (nonatomic, strong) UILabel *deviceLabel;
@property (nonatomic, strong) UIView *stateBadge;
@property (nonatomic, strong) UILabel *stateBadgeLabel;

#pragma mark - 配置卡
@property (nonatomic, strong) UIView *configCard;
@property (nonatomic, strong) UILabel *configTitleLabel;
@property (nonatomic, strong) UILabel *langTitleLabel;
@property (nonatomic, strong) UIButton *langButton;
@property (nonatomic, strong) UILabel *sceneTitleLabel;
@property (nonatomic, strong) UIButton *sceneButton;
@property (nonatomic, strong) UILabel *offlineTitleLabel;
@property (nonatomic, strong) UISwitch *offlineSwitch;
@property (nonatomic, strong) UILabel *formatTitleLabel;
@property (nonatomic, strong) UIButton *formatButton;

#pragma mark - Meta + 按钮
@property (nonatomic, strong) UILabel *metaLabel;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *cancelButton;

#pragma mark - 流式区
@property (nonatomic, strong) UIView *streamCard;
@property (nonatomic, strong) UILabel *streamTitleLabel;
@property (nonatomic, strong) UITextView *streamTextView;
@property (nonatomic, strong) UIView *recPulseDot;

#pragma mark - 最终结果区
@property (nonatomic, strong) UIView *resultCard;
@property (nonatomic, strong) UILabel *resultTitleLabel;
@property (nonatomic, strong) UILabel *resultTextLabel;
@property (nonatomic, strong) UILabel *resultMetaLabel;
@property (nonatomic, strong) UIView *playerRow;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIView *playProgressTrack;
@property (nonatomic, strong) UIView *playProgressFill;
@property (nonatomic, strong) UILabel *playTimeLabel;
@property (nonatomic, strong) UILabel *playFileMetaLabel;

#pragma mark - 日志
@property (nonatomic, strong) TSAILogView *logView;

#pragma mark - 滚动容器
@property (nonatomic, strong) UIScrollView *contentScrollView;

#pragma mark - 回放
@property (nonatomic, strong, nullable) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong, nullable) CADisplayLink *playProgressLink;

@end

@implementation TSAIASRDeviceMicVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"ai_asr_dmic.title");
    self.speech = [[TopStepComKit sharedInstance] aiSpeech];
    self.selectedLanguage = TSAILanguageUnknown;
    self.selectedScene = TSAIASRSceneUnknown;
    self.offlineFallbackEnabled = NO;
    self.selectedAudioFormat = TSAIAudioFormatMp3;
    self.finalizedText = @"";
    self.pendingText = @"";
    self.lastCumulativeText = @"";
    self.currentState = (self.speech && [self.speech isSupport])
        ? TSAIASRDMicStateIdle : TSAIASRDMicStateUnsupported;
}

- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;
    [self.view addSubview:self.contentScrollView];

    [self.contentScrollView addSubview:self.deviceBar];
    [self.deviceBar addSubview:self.deviceDot];
    [self.deviceBar addSubview:self.deviceLabel];
    [self.deviceBar addSubview:self.stateBadge];
    [self.stateBadge addSubview:self.stateBadgeLabel];

    [self.contentScrollView addSubview:self.configCard];
    [self.configCard addSubview:self.configTitleLabel];
    [self.configCard addSubview:self.langTitleLabel];
    [self.configCard addSubview:self.langButton];
    [self.configCard addSubview:self.sceneTitleLabel];
    [self.configCard addSubview:self.sceneButton];
    [self.configCard addSubview:self.offlineTitleLabel];
    [self.configCard addSubview:self.offlineSwitch];
    [self.configCard addSubview:self.formatTitleLabel];
    [self.configCard addSubview:self.formatButton];

    [self.contentScrollView addSubview:self.metaLabel];
    [self.contentScrollView addSubview:self.startButton];
    [self.contentScrollView addSubview:self.stopButton];
    [self.contentScrollView addSubview:self.cancelButton];

    [self.contentScrollView addSubview:self.streamCard];
    [self.streamCard addSubview:self.streamTitleLabel];
    [self.streamCard addSubview:self.streamTextView];
    [self.streamCard addSubview:self.recPulseDot];

    [self.contentScrollView addSubview:self.resultCard];
    [self.resultCard addSubview:self.resultTitleLabel];
    [self.resultCard addSubview:self.resultTextLabel];
    [self.resultCard addSubview:self.resultMetaLabel];
    [self.resultCard addSubview:self.playerRow];
    [self.playerRow addSubview:self.playButton];
    [self.playerRow addSubview:self.playProgressTrack];
    [self.playProgressTrack addSubview:self.playProgressFill];
    [self.playerRow addSubview:self.playTimeLabel];
    [self.playerRow addSubview:self.playFileMetaLabel];

    [self.contentScrollView addSubview:self.logView];

    [self refreshConfigDisplay];
    [self refreshStateDependentUI];
    [self renderStream];
}

- (void)layoutViews {
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;

    CGFloat fullW = CGRectGetWidth(self.view.bounds);
    CGFloat fullH = CGRectGetHeight(self.view.bounds);

    self.contentScrollView.frame = CGRectMake(0, topOffset, fullW, fullH - topOffset - bottomInset);

    CGFloat margin = TSSpacing_MD;
    CGFloat gap = TSSpacing_SM;
    CGFloat contentW = fullW - margin * 2;

    CGFloat y = margin;

    // 顶部状态条
    CGFloat barH = 44.f;
    self.deviceBar.frame = CGRectMake(margin, y, contentW, barH);
    self.deviceDot.frame = CGRectMake(12, (barH - 8) / 2.f, 8, 8);
    self.deviceDot.layer.cornerRadius = 4.f;
    CGFloat badgeW = 110.f, badgeH = 22.f;
    self.stateBadge.frame = CGRectMake(contentW - badgeW - 12, (barH - badgeH) / 2.f, badgeW, badgeH);
    self.stateBadge.layer.cornerRadius = badgeH / 2.f;
    self.stateBadgeLabel.frame = self.stateBadge.bounds;
    self.deviceLabel.frame = CGRectMake(28, 0, contentW - badgeW - 40, barH);
    y = CGRectGetMaxY(self.deviceBar.frame) + gap;

    // 配置卡（标题 + 4 行）
    CGFloat rowH = 44.f;
    CGFloat configHeaderH = 24.f;
    CGFloat configCardH = configHeaderH + rowH * 4 + 8.f;
    self.configCard.frame = CGRectMake(margin, y, contentW, configCardH);
    CGFloat cardW = contentW;
    CGFloat pad = 12.f;
    self.configTitleLabel.frame = CGRectMake(pad, 6, cardW - pad * 2, configHeaderH - 6);

    CGFloat lblW = 96.f;
    CGFloat ctrlPad = 12.f;
    CGFloat rowY = configHeaderH + 4.f;
    self.langTitleLabel.frame = CGRectMake(pad, rowY, lblW, rowH);
    self.langButton.frame = CGRectMake(pad + lblW, rowY + 6, cardW - pad * 2 - lblW, rowH - 12);
    rowY += rowH;

    self.sceneTitleLabel.frame = CGRectMake(pad, rowY, lblW, rowH);
    self.sceneButton.frame = CGRectMake(pad + lblW, rowY + 6, cardW - pad * 2 - lblW, rowH - 12);
    rowY += rowH;

    self.offlineTitleLabel.frame = CGRectMake(pad, rowY, lblW, rowH);
    CGSize switchSize = self.offlineSwitch.intrinsicContentSize;
    self.offlineSwitch.frame = CGRectMake(cardW - pad - switchSize.width,
                                           rowY + (rowH - switchSize.height) / 2.f,
                                           switchSize.width, switchSize.height);
    rowY += rowH;

    self.formatTitleLabel.frame = CGRectMake(pad, rowY, lblW, rowH);
    self.formatButton.frame = CGRectMake(pad + lblW, rowY + 6, cardW - pad * 2 - lblW, rowH - 12);

    y = CGRectGetMaxY(self.configCard.frame) + gap;

    // Meta 行
    self.metaLabel.frame = CGRectMake(margin + 4, y, contentW - 8, 18);
    y = CGRectGetMaxY(self.metaLabel.frame) + 6;

    // 三按钮：Start | Stop | Cancel（1.4 : 1 : 1）
    CGFloat btnH = 44.f;
    CGFloat unit = (contentW - gap * 2) / 3.4f;
    CGFloat startW = unit * 1.4f;
    CGFloat sideW = unit;
    self.startButton.frame = CGRectMake(margin, y, startW, btnH);
    self.stopButton.frame = CGRectMake(CGRectGetMaxX(self.startButton.frame) + gap, y, sideW, btnH);
    self.cancelButton.frame = CGRectMake(CGRectGetMaxX(self.stopButton.frame) + gap, y, sideW, btnH);
    y = CGRectGetMaxY(self.startButton.frame) + gap;
    (void)ctrlPad;

    // 流式区
    CGFloat streamH = 180.f;
    self.streamCard.frame = CGRectMake(margin, y, contentW, streamH);
    self.streamTitleLabel.frame = CGRectMake(pad, 8, contentW - pad * 2 - 24, 18);
    self.recPulseDot.frame = CGRectMake(contentW - pad - 10, 12, 10, 10);
    self.recPulseDot.layer.cornerRadius = 5.f;
    self.streamTextView.frame = CGRectMake(pad, 30, contentW - pad * 2, streamH - 30 - 8);
    y = CGRectGetMaxY(self.streamCard.frame) + gap;

    // 最终结果卡（仅 Finished 显示）
    if (!self.resultCard.hidden) {
        CGFloat resultPad = 12.f;
        CGFloat metaH = 80.f;
        CGFloat playerH = 56.f;
        CGFloat textH = MAX(60.f, [self heightForResultText]);
        CGFloat resultH = 26.f + textH + 8.f + metaH + 8.f + playerH + resultPad * 2;
        self.resultCard.frame = CGRectMake(margin, y, contentW, resultH);
        self.resultTitleLabel.frame = CGRectMake(resultPad, resultPad, contentW - resultPad * 2, 22);
        self.resultTextLabel.frame = CGRectMake(resultPad,
                                                 CGRectGetMaxY(self.resultTitleLabel.frame) + 4,
                                                 contentW - resultPad * 2,
                                                 textH);
        self.resultMetaLabel.frame = CGRectMake(resultPad,
                                                 CGRectGetMaxY(self.resultTextLabel.frame) + 8,
                                                 contentW - resultPad * 2,
                                                 metaH);
        self.playerRow.frame = CGRectMake(resultPad,
                                          CGRectGetMaxY(self.resultMetaLabel.frame) + 8,
                                          contentW - resultPad * 2,
                                          playerH);
        CGFloat playerW = CGRectGetWidth(self.playerRow.bounds);
        self.playButton.frame = CGRectMake(0, 12, 32, 32);
        self.playButton.layer.cornerRadius = 16.f;
        CGFloat barLeft = 44.f;
        self.playProgressTrack.frame = CGRectMake(barLeft, 18, playerW - barLeft, 4);
        self.playProgressTrack.layer.cornerRadius = 2.f;
        self.playProgressFill.frame = CGRectMake(0, 0, 0, 4);
        self.playTimeLabel.frame = CGRectMake(barLeft, 24, 100, 16);
        self.playFileMetaLabel.frame = CGRectMake(barLeft + 100, 24, playerW - barLeft - 100, 16);
        y = CGRectGetMaxY(self.resultCard.frame) + gap;
    }

    // 日志
    CGFloat logH = 180.f;
    self.logView.frame = CGRectMake(margin, y, contentW, logH);
    y = CGRectGetMaxY(self.logView.frame) + margin;

    self.contentScrollView.contentSize = CGSizeMake(fullW, y);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.currentTaskId.length > 0 && self.speech) {
        [self.logView appendLineWithFormat:@"viewWillDisappear: auto-cancel taskId=%@", self.currentTaskId];
        [self.speech cancelRecognitionWithTaskId:self.currentTaskId];
    }
    [self stopAudioPlayback];
    [self.elapsedTimer invalidate];
    self.elapsedTimer = nil;
}

- (void)dealloc {
    if (_currentTaskId.length > 0 && _speech) {
        [_speech cancelRecognitionWithTaskId:_currentTaskId];
    }
    [_elapsedTimer invalidate];
    [_audioPlayer stop];
    [_playProgressLink invalidate];
}

#pragma mark - 公开方法 / 状态机

- (void)setCurrentState:(TSAIASRDMicState)currentState {
    _currentState = currentState;
    [self refreshStateDependentUI];
}

#pragma mark - 私有方法 - UI 状态刷新

/// 根据当前状态刷新所有 UI 元素
- (void)refreshStateDependentUI {
    [self refreshStateBadge];
    [self refreshButtons];
    [self refreshConfigEditable];
    [self refreshMetaLabel];
    [self refreshDeviceBar];
    [self refreshRecPulse];
}

/// 状态徽章颜色与文案
- (void)refreshStateBadge {
    NSString *text = nil;
    UIColor *fg = TSColor_TextSecondary;
    UIColor *bg = [TSColor_TextSecondary colorWithAlphaComponent:0.15f];
    switch (self.currentState) {
        case TSAIASRDMicStateIdle:
            text = TSLocalizedString(@"ai_asr_dmic.state.idle");
            break;
        case TSAIASRDMicStateStarting:
            text = TSLocalizedString(@"ai_asr_dmic.state.starting");
            fg = TSColor_Primary; bg = [TSColor_Primary colorWithAlphaComponent:0.15f];
            break;
        case TSAIASRDMicStateRecognizing:
            text = TSLocalizedString(@"ai_asr_dmic.state.recognizing");
            fg = TSColor_Primary; bg = [TSColor_Primary colorWithAlphaComponent:0.15f];
            break;
        case TSAIASRDMicStateStopping:
            text = TSLocalizedString(@"ai_asr_dmic.state.stopping");
            fg = TSColor_Warning; bg = [TSColor_Warning colorWithAlphaComponent:0.15f];
            break;
        case TSAIASRDMicStateCancelling:
            text = TSLocalizedString(@"ai_asr_dmic.state.cancelling");
            fg = TSColor_Warning; bg = [TSColor_Warning colorWithAlphaComponent:0.15f];
            break;
        case TSAIASRDMicStateFinished:
            text = TSLocalizedString(@"ai_asr_dmic.state.finished");
            fg = TSColor_Success; bg = [TSColor_Success colorWithAlphaComponent:0.15f];
            break;
        case TSAIASRDMicStateCancelled:
            text = TSLocalizedString(@"ai_asr_dmic.state.cancelled");
            fg = TSColor_Warning; bg = [TSColor_Warning colorWithAlphaComponent:0.15f];
            break;
        case TSAIASRDMicStateFailed:
            text = TSLocalizedString(@"ai_asr_dmic.state.failed");
            fg = TSColor_Danger; bg = [TSColor_Danger colorWithAlphaComponent:0.15f];
            break;
        case TSAIASRDMicStateUnsupported:
            text = TSLocalizedString(@"ai_asr_dmic.state.unsupported");
            break;
    }
    self.stateBadgeLabel.text = text;
    self.stateBadgeLabel.textColor = fg;
    self.stateBadge.backgroundColor = bg;
}

/// 三按钮 enabled/loading 状态
- (void)refreshButtons {
    BOOL editable = [self isConfigEditableState];
    BOOL recognizing = (self.currentState == TSAIASRDMicStateRecognizing);
    BOOL starting = (self.currentState == TSAIASRDMicStateStarting);
    BOOL stopping = (self.currentState == TSAIASRDMicStateStopping);
    BOOL cancelling = (self.currentState == TSAIASRDMicStateCancelling);
    BOOL unsupp = (self.currentState == TSAIASRDMicStateUnsupported);
    BOOL hasLang = (self.selectedLanguage != TSAILanguageUnknown
                    && self.selectedLanguage != TSAILanguageAuto);

    BOOL canStart = editable && hasLang && !unsupp;
    self.startButton.enabled = canStart;
    self.startButton.alpha = canStart ? 1.f : 0.4f;

    self.stopButton.enabled = recognizing;
    self.stopButton.alpha = (recognizing || stopping) ? 1.f : 0.4f;

    BOOL canCancel = (starting || recognizing);
    self.cancelButton.enabled = canCancel;
    self.cancelButton.alpha = (canCancel || cancelling) ? 1.f : 0.4f;
}

/// 配置卡是否可编辑
- (void)refreshConfigEditable {
    BOOL editable = [self isConfigEditableState]
                    && self.currentState != TSAIASRDMicStateUnsupported;
    self.langButton.enabled = editable;
    self.sceneButton.enabled = editable;
    self.formatButton.enabled = editable;
    self.offlineSwitch.enabled = editable;
    self.configCard.alpha = editable ? 1.f : 0.5f;
}

/// 当前状态是否允许编辑配置
- (BOOL)isConfigEditableState {
    switch (self.currentState) {
        case TSAIASRDMicStateIdle:
        case TSAIASRDMicStateFinished:
        case TSAIASRDMicStateCancelled:
        case TSAIASRDMicStateFailed:
            return YES;
        default:
            return NO;
    }
}

/// Meta 行：状态文案 + taskId（短码）+ 计时
- (void)refreshMetaLabel {
    NSString *shortId = [self shortIdForTaskId:self.currentTaskId];
    NSString *taskFmt = [NSString stringWithFormat:TSLocalizedString(@"ai_asr_dmic.taskid_fmt"), shortId];
    NSString *elapsed = self.taskStartDate
        ? [self formatElapsedSeconds:-[self.taskStartDate timeIntervalSinceNow]]
        : @"00:00";

    NSString *text = nil;
    UIColor *color = TSColor_TextSecondary;
    switch (self.currentState) {
        case TSAIASRDMicStateIdle:
            text = TSLocalizedString(@"ai_asr_dmic.meta_idle");
            break;
        case TSAIASRDMicStateStarting:
            text = [NSString stringWithFormat:TSLocalizedString(@"ai_asr_dmic.meta_starting_fmt"), taskFmt];
            color = TSColor_Primary;
            break;
        case TSAIASRDMicStateRecognizing:
            text = [NSString stringWithFormat:TSLocalizedString(@"ai_asr_dmic.meta_recognizing_fmt"),
                      taskFmt, elapsed];
            color = TSColor_Primary;
            break;
        case TSAIASRDMicStateStopping:
            text = [NSString stringWithFormat:TSLocalizedString(@"ai_asr_dmic.meta_stopping_fmt"), taskFmt];
            color = TSColor_Warning;
            break;
        case TSAIASRDMicStateCancelling:
            text = [NSString stringWithFormat:TSLocalizedString(@"ai_asr_dmic.meta_cancelling_fmt"), taskFmt];
            color = TSColor_Warning;
            break;
        case TSAIASRDMicStateFinished:
            text = TSLocalizedString(@"ai_asr_dmic.meta_finished");
            break;
        case TSAIASRDMicStateCancelled:
            text = TSLocalizedString(@"ai_asr_dmic.meta_cancelled");
            color = TSColor_Warning;
            break;
        case TSAIASRDMicStateFailed:
            text = TSLocalizedString(@"ai_asr_dmic.meta_failed");
            color = TSColor_Danger;
            break;
        case TSAIASRDMicStateUnsupported:
            text = TSLocalizedString(@"ai_asr_dmic.meta_unsupported");
            color = TSColor_Danger;
            break;
    }
    self.metaLabel.text = text;
    self.metaLabel.textColor = color;
}

/// 顶部设备状态条：颜色点随支持状态变化
- (void)refreshDeviceBar {
    if (self.currentState == TSAIASRDMicStateUnsupported) {
        self.deviceDot.backgroundColor = TSColor_TextSecondary;
        self.deviceLabel.text = TSLocalizedString(@"ai_asr_dmic.toast_unsupported");
        self.deviceLabel.textColor = TSColor_Danger;
    } else {
        self.deviceDot.backgroundColor = TSColor_Success;
        self.deviceLabel.text = @"AI Speech ready";
        self.deviceLabel.textColor = TSColor_TextPrimary;
    }
}

/// 流式区右上角的录音脉冲点
- (void)refreshRecPulse {
    BOOL show = (self.currentState == TSAIASRDMicStateRecognizing);
    self.recPulseDot.hidden = !show;
    if (show) {
        [self startPulseAnimation];
    } else {
        [self.recPulseDot.layer removeAllAnimations];
    }
}

/// 红点呼吸动画
- (void)startPulseAnimation {
    [self.recPulseDot.layer removeAllAnimations];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.fromValue = @1.0;
    anim.toValue = @0.3;
    anim.duration = 0.6;
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    [self.recPulseDot.layer addAnimation:anim forKey:@"pulse"];
}

/// 配置卡按钮文案
- (void)refreshConfigDisplay {
    [self.langButton setTitle:[self displayNameForLanguage:self.selectedLanguage]
                      forState:UIControlStateNormal];
    UIColor *langBorder = (self.selectedLanguage == TSAILanguageUnknown
                           || self.selectedLanguage == TSAILanguageAuto)
        ? TSColor_Danger : TSColor_Separator;
    self.langButton.layer.borderColor = langBorder.CGColor;

    [self.sceneButton setTitle:[self displayNameForScene:self.selectedScene]
                       forState:UIControlStateNormal];
    [self.formatButton setTitle:[self displayNameForAudioFormat:self.selectedAudioFormat]
                        forState:UIControlStateNormal];
    self.offlineSwitch.on = self.offlineFallbackEnabled;
}

/// 流式区渲染：已稳定 + 修订中（不同颜色与字重）；错误/取消用专门样式
- (void)renderStream {
    self.streamTitleLabel.text = TSLocalizedString(@"ai_asr_dmic.section_stream");

    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];

    if (self.currentState == TSAIASRDMicStateIdle) {
        [attr appendAttributedString:[self placeholderAttrText:TSLocalizedString(@"ai_asr_dmic.stream_placeholder")]];
        self.streamTextView.attributedText = attr;
        return;
    }

    if (self.currentState == TSAIASRDMicStateFailed && self.lastError) {
        BOOL interrupted = self.lastResult.isStoppedByInterruption;
        NSString *titleKey = interrupted ? @"ai_asr_dmic.title_interrupted"
                                          : @"ai_asr_dmic.title_failed";
        [attr appendAttributedString:[self errorTitleAttrText:TSLocalizedString(titleKey)]];
        [attr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        NSString *detail = [NSString stringWithFormat:TSLocalizedString(@"ai_asr_dmic.error_fmt"),
                              self.lastError.domain ?: @"-",
                              (long)self.lastError.code,
                              self.lastError.localizedDescription ?: @"-"];
        [attr appendAttributedString:[self errorDetailAttrText:detail]];
        if (self.finalizedText.length > 0) {
            NSString *line = [NSString stringWithFormat:@"\n%@",
                              [NSString stringWithFormat:TSLocalizedString(@"ai_asr_dmic.stream_interrupted_partial_fmt"),
                                  self.finalizedText]];
            [attr appendAttributedString:[self interruptedPartialAttrText:line]];
        }
        self.streamTextView.attributedText = attr;
        return;
    }

    if (self.currentState == TSAIASRDMicStateCancelled) {
        [attr appendAttributedString:[self cancelTitleAttrText:TSLocalizedString(@"ai_asr_dmic.stream_cancelled")]];
        self.streamTextView.attributedText = attr;
        return;
    }

    // Starting / Recognizing / Stopping / Finished
    if (self.finalizedText.length == 0
        && self.pendingText.length == 0
        && self.currentState == TSAIASRDMicStateStarting) {
        [attr appendAttributedString:[self placeholderAttrText:TSLocalizedString(@"ai_asr_dmic.stream_starting")]];
        self.streamTextView.attributedText = attr;
        return;
    }

    if (self.finalizedText.length > 0) {
        [attr appendAttributedString:[self stableAttrText:self.finalizedText]];
    }
    if (self.pendingText.length > 0) {
        if (self.finalizedText.length > 0) {
            [attr appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        }
        [attr appendAttributedString:[self pendingAttrText:self.pendingText]];
    }

    self.streamTextView.attributedText = attr;
    NSRange end = NSMakeRange(attr.length, 0);
    [self.streamTextView scrollRangeToVisible:end];
}

/// 富文本片段：已稳定句（深色 17pt 常规）
- (NSAttributedString *)stableAttrText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:17.f weight:UIFontWeightRegular],
        NSForegroundColorAttributeName: TSColor_TextPrimary
    }];
}

/// 富文本片段：当前修订中（浅色斜体）
- (NSAttributedString *)pendingAttrText:(NSString *)text {
    UIFontDescriptor *desc = [[UIFont systemFontOfSize:17.f weight:UIFontWeightRegular].fontDescriptor
                              fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    UIFont *italic = [UIFont fontWithDescriptor:desc size:17.f] ?: [UIFont italicSystemFontOfSize:17.f];
    return [[NSAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: italic,
        NSForegroundColorAttributeName: TSColor_TextSecondary
    }];
}

/// 富文本片段：占位文案
- (NSAttributedString *)placeholderAttrText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: TSFont_Body,
        NSForegroundColorAttributeName: TSColor_TextSecondary
    }];
}

/// 富文本片段：错误标题
- (NSAttributedString *)errorTitleAttrText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:[@"⚠ " stringByAppendingString:text] attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:15.f weight:UIFontWeightSemibold],
        NSForegroundColorAttributeName: TSColor_Danger
    }];
}

/// 富文本片段：错误详情（红色 monospaced，与标题同色）
- (NSAttributedString *)errorDetailAttrText:(NSString *)text {
    UIFont *monoFont = [self monospacedFontOfSize:12.f];
    return [[NSAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: monoFont,
        NSForegroundColorAttributeName: TSColor_Danger
    }];
}

/// 富文本片段：中断场景下的"截至中断已识别"文本（灰色 caption，不属于错误信息本身）
- (NSAttributedString *)interruptedPartialAttrText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: TSFont_Caption,
        NSForegroundColorAttributeName: TSColor_TextSecondary
    }];
}

/// monospaced 字体（iOS 13+ 用系统等宽，否则降级到 Menlo）
- (UIFont *)monospacedFontOfSize:(CGFloat)size {
    if (@available(iOS 13.0, *)) {
        return [UIFont monospacedSystemFontOfSize:size weight:UIFontWeightRegular];
    }
    return [UIFont fontWithName:@"Menlo" size:size] ?: [UIFont systemFontOfSize:size];
}

/// 富文本片段：取消标题
- (NSAttributedString *)cancelTitleAttrText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:15.f weight:UIFontWeightSemibold],
        NSForegroundColorAttributeName: TSColor_Warning
    }];
}

/// 渲染最终结果卡（仅 Finished 状态显示）
- (void)renderResultCard {
    BOOL show = (self.currentState == TSAIASRDMicStateFinished && self.lastResult != nil);
    self.resultCard.hidden = !show;
    if (!show) {
        [self.view setNeedsLayout];
        return;
    }
    TSAIASRDeviceMicResult *r = self.lastResult;
    self.resultTitleLabel.text = TSLocalizedString(@"ai_asr_dmic.section_result");
    self.resultTextLabel.text = r.text;

    NSString *durationStr = [NSString stringWithFormat:TSLocalizedString(@"ai_asr_dmic.result.duration_fmt"), r.duration];
    NSString *routeStr = r.isOfflineRecognition
        ? TSLocalizedString(@"ai_asr_dmic.result.route_offline")
        : TSLocalizedString(@"ai_asr_dmic.result.route_online");
    NSString *interruptStr = r.isStoppedByInterruption
        ? TSLocalizedString(@"ai_asr_dmic.result.interrupt_yes")
        : TSLocalizedString(@"ai_asr_dmic.result.interrupt_no");

    NSString *meta = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@ %@\n%@ %@\n%@ %@ → %@",
                       TSLocalizedString(@"ai_asr_dmic.result.duration"), durationStr,
                       TSLocalizedString(@"ai_asr_dmic.result.scene"), [self displayNameForScene:r.scene],
                       TSLocalizedString(@"ai_asr_dmic.result.route"), routeStr,
                       TSLocalizedString(@"ai_asr_dmic.result.interrupt"), interruptStr,
                       TSLocalizedString(@"ai_asr_dmic.result.session_start"),
                       [self timeStringForDate:r.sessionStartTime],
                       [self timeStringForDate:r.sessionEndTime]];
    self.resultMetaLabel.text = meta;

    if (r.recordedAudioFileURL) {
        NSError *attrErr = nil;
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:r.recordedAudioFileURL.path
                                                                                error:&attrErr];
        unsigned long long bytes = attrs ? [attrs[NSFileSize] unsignedLongLongValue] : 0;
        self.playFileMetaLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_asr_dmic.result.file_fmt"),
                                         [self displayNameForAudioFormat:r.recordedAudioFormat],
                                         [self readableSize:bytes]];
        self.playButton.enabled = YES;
        self.playButton.alpha = 1.f;
    } else {
        self.playFileMetaLabel.text = TSLocalizedString(@"ai_asr_dmic.result.file_none");
        self.playButton.enabled = NO;
        self.playButton.alpha = 0.4f;
    }
    self.playTimeLabel.text = [NSString stringWithFormat:@"00:00 / %@",
                                 [self formatElapsedSeconds:r.duration]];
    self.playProgressFill.frame = CGRectMake(0, 0, 0, 4);

    [self.view setNeedsLayout];
}

/// 计算结果文本动态高度
- (CGFloat)heightForResultText {
    NSString *text = self.lastResult.text ?: @"";
    if (text.length == 0) return 24.f;
    CGFloat w = CGRectGetWidth(self.view.bounds) - TSSpacing_MD * 2 - 24.f;
    if (w <= 0) w = 320.f;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(w, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{ NSFontAttributeName: TSFont_Body }
                                       context:nil];
    return MIN(MAX(24.f, ceil(CGRectGetHeight(rect))), 140.f);
}

#pragma mark - 私有方法 - 业务

/// Start 按钮：发起识别请求
- (void)onStartTap {
    if (self.currentState == TSAIASRDMicStateUnsupported) return;
    if (!self.speech) {
        [self.logView appendLine:TSLocalizedString(@"ai_asr_dmic.toast_unavailable")];
        return;
    }
    if (self.selectedLanguage == TSAILanguageUnknown
        || self.selectedLanguage == TSAILanguageAuto) {
        [self.logView appendLine:TSLocalizedString(@"ai_asr_dmic.toast_no_language")];
        return;
    }

    [self resetSessionState];
    [self stopAudioPlayback];
    self.lastResult = nil;
    self.lastError = nil;
    self.taskStartDate = [NSDate date];

    TSAIASRDeviceMicConfig *config = [TSAIASRDeviceMicConfig configWithLanguage:self.selectedLanguage];
    config.scene = self.selectedScene;
    config.offlineFallbackEnabled = self.offlineFallbackEnabled;
    config.outputAudioFormat = self.selectedAudioFormat;

    [self.logView appendLineWithFormat:@"▶ start lang=%@ scene=%@ offline=%@ fmt=%@",
        [self displayNameForLanguage:self.selectedLanguage],
        [self displayNameForScene:self.selectedScene],
        self.offlineFallbackEnabled ? @"Y" : @"N",
        [self displayNameForAudioFormat:self.selectedAudioFormat]];

    self.currentState = TSAIASRDMicStateStarting;
    [self renderStream];

    __weak typeof(self) weakSelf = self;
    NSString *taskId = [self.speech recognizeSpeechWithDeviceMicConfig:config
                                                       onPartialResult:^(TSAIASRPartialResult *partial) {
        [weakSelf handlePartialResult:partial];
    }
                                                            completion:^(TSAIASRDeviceMicResult * _Nullable result, NSError * _Nullable error) {
        [weakSelf handleCompletionWithResult:result error:error];
    }];

    self.currentTaskId = taskId;
    [self.logView appendLineWithFormat:@"  taskId=%@", taskId];
    [self startElapsedTimer];
    [self refreshStateDependentUI];
}

/// Stop 按钮：冲刷已缓冲音频，等 completion 下发最终结果
- (void)onStopTap {
    if (self.currentState != TSAIASRDMicStateRecognizing) return;
    if (self.currentTaskId.length == 0 || !self.speech) return;

    [self.logView appendLineWithFormat:@"▶ stop requested taskId=%@", self.currentTaskId];
    self.currentState = TSAIASRDMicStateStopping;
    [self.speech stopDeviceMicRecognitionWithTaskId:self.currentTaskId];
}

/// Cancel 按钮：丢弃当前结果，completion 会以取消错误下发
- (void)onCancelTap {
    if (self.currentState != TSAIASRDMicStateStarting
        && self.currentState != TSAIASRDMicStateRecognizing) return;
    if (self.currentTaskId.length == 0 || !self.speech) return;

    [self.logView appendLineWithFormat:@"▶ cancel requested taskId=%@", self.currentTaskId];
    self.currentState = TSAIASRDMicStateCancelling;
    [self.speech cancelRecognitionWithTaskId:self.currentTaskId];
}

#pragma mark - 私有方法 - SDK 回调

/// 处理 partial：根据 isSentenceFinal 切分 finalized / pending
- (void)handlePartialResult:(TSAIASRPartialResult *)partial {
    if (![partial.taskId isEqualToString:self.currentTaskId]) return;

    self.partialCount += 1;

    NSString *cumulative = partial.text ?: @"";
    // 推导新句的尾巴：用累积文本减去已稳定文本前缀
    NSString *tail = cumulative;
    if (self.finalizedText.length > 0
        && cumulative.length >= self.finalizedText.length
        && [cumulative hasPrefix:self.finalizedText]) {
        tail = [cumulative substringFromIndex:self.finalizedText.length];
        // 去掉句间分隔的空白
        tail = [tail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }

    if (partial.isSentenceFinal) {
        // 句子封板：把当前累积全文（含本句）整体作为已稳定文本
        self.finalizedText = cumulative;
        self.pendingText = @"";
    } else {
        self.pendingText = tail;
    }
    self.lastCumulativeText = cumulative;
    self.lastPartialFinal = partial.isSentenceFinal;

    // 进入 Recognizing 的标志：首个 partial 到达
    if (self.currentState == TSAIASRDMicStateStarting) {
        self.currentState = TSAIASRDMicStateRecognizing;
    }

    [self.logView appendLineWithFormat:@"  partial #%lu s#%ld f#%ld final=%@ len=%lu",
        (unsigned long)self.partialCount,
        (long)partial.sentenceNo,
        (long)partial.fragmentNo,
        partial.isSentenceFinal ? @"Y" : @"N",
        (unsigned long)cumulative.length];

    [self renderStream];
}

/// 处理 completion：成功 / 失败 / 取消统一收尾
- (void)handleCompletionWithResult:(TSAIASRDeviceMicResult * _Nullable)result
                              error:(NSError * _Nullable)error {
    NSString *finishedTaskId = result.taskId ?: self.currentTaskId;
    if (finishedTaskId.length > 0
        && self.currentTaskId.length > 0
        && ![finishedTaskId isEqualToString:self.currentTaskId]) {
        [self.logView appendLineWithFormat:@"  drop late completion taskId=%@", finishedTaskId];
        return;
    }

    [self stopElapsedTimer];

    if (error) {
        BOOL isCancel = (error.code == eTSErrorUserCancelled);
        TSAIASRDMicState next = isCancel ? TSAIASRDMicStateCancelled : TSAIASRDMicStateFailed;
        self.lastError = error;
        self.lastResult = result; // 中断场景下 result 也可能非 nil（保留中断前文本）
        [self.logView appendLineWithFormat:@"%@ domain=%@ code=%ld msg=%@",
            isCancel ? @"✕ cancelled" : @"✕ failed",
            error.domain ?: @"-",
            (long)error.code,
            error.localizedDescription ?: @"-"];
        self.currentTaskId = nil;
        self.currentState = next;
        [self renderStream];
        [self renderResultCard];
        return;
    }

    if (result == nil) {
        [self.logView appendLine:@"✕ completion result is nil"];
        self.currentTaskId = nil;
        self.currentState = TSAIASRDMicStateFailed;
        [self renderStream];
        return;
    }

    self.lastResult = result;
    // Finished 状态时把累积文本与 result.text 对齐
    self.finalizedText = result.text ?: self.finalizedText;
    self.pendingText = @"";

    [self.logView appendLineWithFormat:@"✓ done duration=%.1fs textLen=%lu offline=%@ interrupt=%@",
        result.duration,
        (unsigned long)(result.text.length),
        result.isOfflineRecognition ? @"Y" : @"N",
        result.isStoppedByInterruption ? @"Y" : @"N"];
    if (result.recordedAudioFileURL) {
        [self.logView appendLineWithFormat:@"  recorded fmt=%@ path=%@",
            [self displayNameForAudioFormat:result.recordedAudioFormat],
            result.recordedAudioFileURL.lastPathComponent];
    }

    self.currentTaskId = nil;
    // 中断场景：result.isStoppedByInterruption=YES，PRD 定为 Failed
    self.currentState = result.isStoppedByInterruption
        ? TSAIASRDMicStateFailed : TSAIASRDMicStateFinished;
    [self renderStream];
    [self renderResultCard];
}

/// 重置一次会话相关的累积状态
- (void)resetSessionState {
    self.finalizedText = @"";
    self.pendingText = @"";
    self.lastCumulativeText = @"";
    self.lastPartialFinal = NO;
    self.partialCount = 0;
    self.taskStartDate = nil;
    self.resultCard.hidden = YES;
}

#pragma mark - 私有方法 - 计时器

/// 启动 1s 计时器刷新 meta 行
- (void)startElapsedTimer {
    [self.elapsedTimer invalidate];
    __weak typeof(self) weakSelf = self;
    self.elapsedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          repeats:YES
                                                            block:^(NSTimer * _Nonnull timer) {
        [weakSelf refreshMetaLabel];
    }];
}

/// 停止计时器
- (void)stopElapsedTimer {
    [self.elapsedTimer invalidate];
    self.elapsedTimer = nil;
}

#pragma mark - 私有方法 - 配置 Sheet

/// 弹出选择语言（不含 Auto / Unknown，ASR 必须事先指定）
- (void)onLangButtonTap {
    NSArray<NSNumber *> *list = @[
        @(TSAILanguageChineseSimplified),
        @(TSAILanguageChineseTraditional),
        @(TSAILanguageEnglishUS),
        @(TSAILanguageEnglishUK),
        @(TSAILanguageJapanese),
        @(TSAILanguageKorean),
        @(TSAILanguageFrench),
        @(TSAILanguageGerman),
        @(TSAILanguageSpanish),
        @(TSAILanguageRussian),
    ];
    [self presentSheetWithTitle:TSLocalizedString(@"ai_asr_dmic.sheet_select_lang")
                        boxList:list
                  selectedValue:self.selectedLanguage
                        nameOf:^NSString * _Nonnull(NSInteger v) {
        return [self displayNameForLanguage:(TSAILanguage)v];
    }
                       sourceView:self.langButton
                          handler:^(NSInteger v) {
        self.selectedLanguage = (TSAILanguage)v;
        [self refreshConfigDisplay];
        [self refreshButtons];
    }];
}

/// 弹出选择场景
- (void)onSceneButtonTap {
    NSArray<NSNumber *> *list = @[
        @(TSAIASRSceneUnknown),
        @(TSAIASRSceneOnSite),
        @(TSAIASRSceneCall),
    ];
    [self presentSheetWithTitle:TSLocalizedString(@"ai_asr_dmic.sheet_select_scene")
                        boxList:list
                  selectedValue:self.selectedScene
                        nameOf:^NSString * _Nonnull(NSInteger v) {
        return [self displayNameForScene:(TSAIASRScene)v];
    }
                       sourceView:self.sceneButton
                          handler:^(NSInteger v) {
        self.selectedScene = (TSAIASRScene)v;
        [self refreshConfigDisplay];
    }];
}

/// 弹出选择录音格式
- (void)onFormatButtonTap {
    NSArray<NSNumber *> *list = @[
        @(TSAIAudioFormatMp3),
        @(TSAIAudioFormatWav),
        @(TSAIAudioFormatOpus),
        @(TSAIAudioFormatPcm),
        @(TSAIAudioFormatNone),
    ];
    [self presentSheetWithTitle:TSLocalizedString(@"ai_asr_dmic.sheet_select_fmt")
                        boxList:list
                  selectedValue:self.selectedAudioFormat
                        nameOf:^NSString * _Nonnull(NSInteger v) {
        return [self displayNameForAudioFormat:(TSAIAudioFormat)v];
    }
                       sourceView:self.formatButton
                          handler:^(NSInteger v) {
        self.selectedAudioFormat = (TSAIAudioFormat)v;
        [self refreshConfigDisplay];
    }];
}

/// 离线开关
- (void)onOfflineSwitchChanged:(UISwitch *)sender {
    self.offlineFallbackEnabled = sender.isOn;
    [self.logView appendLineWithFormat:@"· offlineFallback → %@", sender.isOn ? @"Y" : @"N"];
}

/// 通用 ActionSheet 选择
- (void)presentSheetWithTitle:(NSString *)title
                        boxList:(NSArray<NSNumber *> *)list
                  selectedValue:(NSInteger)selectedValue
                        nameOf:(NSString *(^)(NSInteger value))nameOf
                       sourceView:(UIView *)sourceView
                          handler:(void (^)(NSInteger value))handler {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:title
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSNumber *box in list) {
        NSInteger v = box.integerValue;
        NSString *name = nameOf(v);
        NSString *display = (v == selectedValue) ? [name stringByAppendingString:@"  ✓"] : name;
        [sheet addAction:[UIAlertAction actionWithTitle:display
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            handler(v);
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    if (sheet.popoverPresentationController) {
        sheet.popoverPresentationController.sourceView = sourceView;
        sheet.popoverPresentationController.sourceRect = sourceView.bounds;
    }
    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark - 私有方法 - 录音回放

/// 切换播放/暂停
- (void)onPlayButtonTap {
    if (!self.lastResult.recordedAudioFileURL) return;
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer pause];
        [self.playButton setTitle:@"▶" forState:UIControlStateNormal];
        return;
    }
    if (!self.audioPlayer) {
        NSError *err = nil;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.lastResult.recordedAudioFileURL
                                                                        error:&err];
        if (err || !player) {
            [self.logView appendLineWithFormat:@"✕ player init failed: %@", err.localizedDescription ?: @"unknown"];
            return;
        }
        player.delegate = self;
        [player prepareToPlay];
        self.audioPlayer = player;
    }
    [self.audioPlayer play];
    [self.playButton setTitle:@"⏸" forState:UIControlStateNormal];
    [self startPlayProgressLink];
}

/// 启动播放进度刷新
- (void)startPlayProgressLink {
    [self.playProgressLink invalidate];
    self.playProgressLink = [CADisplayLink displayLinkWithTarget:self
                                                          selector:@selector(updatePlayProgress)];
    [self.playProgressLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

/// 刷新播放进度条与时间
- (void)updatePlayProgress {
    if (!self.audioPlayer) return;
    NSTimeInterval duration = self.audioPlayer.duration;
    NSTimeInterval currentTime = self.audioPlayer.currentTime;
    if (duration <= 0) return;
    CGFloat ratio = MIN(1.f, MAX(0.f, currentTime / duration));
    CGFloat trackW = CGRectGetWidth(self.playProgressTrack.bounds);
    self.playProgressFill.frame = CGRectMake(0, 0, trackW * ratio, 4);
    self.playTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",
                                 [self formatElapsedSeconds:currentTime],
                                 [self formatElapsedSeconds:duration]];
}

/// 完整停止播放并清理 player
- (void)stopAudioPlayback {
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    [self.playProgressLink invalidate];
    self.playProgressLink = nil;
    [self.playButton setTitle:@"▶" forState:UIControlStateNormal];
    self.playProgressFill.frame = CGRectMake(0, 0, 0, 4);
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.logView appendLineWithFormat:@"✓ playback finished ok=%@", flag ? @"Y" : @"N"];
    [self stopAudioPlayback];
}

#pragma mark - 私有方法 - 工具

/// 语言展示名
- (NSString *)displayNameForLanguage:(TSAILanguage)language {
    switch (language) {
        case TSAILanguageChineseSimplified:  return TSLocalizedString(@"ai_asr_file.lang.zh_cn");
        case TSAILanguageChineseTraditional: return TSLocalizedString(@"ai_asr_file.lang.zh_tw");
        case TSAILanguageEnglishUS:          return TSLocalizedString(@"ai_asr_file.lang.en_us");
        case TSAILanguageEnglishUK:          return TSLocalizedString(@"ai_asr_file.lang.en_gb");
        case TSAILanguageJapanese:           return TSLocalizedString(@"ai_asr_file.lang.ja");
        case TSAILanguageKorean:             return TSLocalizedString(@"ai_asr_file.lang.ko");
        case TSAILanguageFrench:             return TSLocalizedString(@"ai_asr_file.lang.fr");
        case TSAILanguageGerman:             return TSLocalizedString(@"ai_asr_file.lang.de");
        case TSAILanguageSpanish:            return TSLocalizedString(@"ai_asr_file.lang.es");
        case TSAILanguageRussian:            return TSLocalizedString(@"ai_asr_file.lang.ru");
        case TSAILanguageAuto:
        case TSAILanguageUnknown:
        default:                             return TSLocalizedString(@"ai_asr_file.lang.unset");
    }
}

/// 场景展示名
- (NSString *)displayNameForScene:(TSAIASRScene)scene {
    switch (scene) {
        case TSAIASRSceneOnSite: return TSLocalizedString(@"ai_asr_dmic.scene.onsite");
        case TSAIASRSceneCall:   return TSLocalizedString(@"ai_asr_dmic.scene.call");
        case TSAIASRSceneUnknown:
        default:                 return TSLocalizedString(@"ai_asr_dmic.scene.unknown");
    }
}

/// 录音格式展示名
- (NSString *)displayNameForAudioFormat:(TSAIAudioFormat)fmt {
    switch (fmt) {
        case TSAIAudioFormatMp3:  return TSLocalizedString(@"ai_asr_dmic.fmt.mp3");
        case TSAIAudioFormatWav:  return TSLocalizedString(@"ai_asr_dmic.fmt.wav");
        case TSAIAudioFormatOpus: return TSLocalizedString(@"ai_asr_dmic.fmt.opus");
        case TSAIAudioFormatPcm:  return TSLocalizedString(@"ai_asr_dmic.fmt.pcm");
        case TSAIAudioFormatNone:
        case TSAIAudioFormatUnknown:
        default:                  return TSLocalizedString(@"ai_asr_dmic.fmt.none");
    }
}

/// 截短 taskId 用于日志/UI 展示
- (NSString *)shortIdForTaskId:(NSString *)taskId {
    if (taskId.length <= 8) return taskId ?: @"-";
    return [NSString stringWithFormat:@"%@…%@",
              [taskId substringToIndex:4],
              [taskId substringFromIndex:taskId.length - 4]];
}

/// 秒数 → mm:ss
- (NSString *)formatElapsedSeconds:(NSTimeInterval)seconds {
    if (seconds < 0) seconds = 0;
    NSInteger total = (NSInteger)seconds;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(total / 60), (long)(total % 60)];
}

/// 字节数 → 可读字符串
- (NSString *)readableSize:(unsigned long long)bytes {
    if (bytes == 0) return @"0 B";
    if (bytes < 1024)            return [NSString stringWithFormat:@"%llu B", bytes];
    if (bytes < 1024 * 1024)     return [NSString stringWithFormat:@"%.1f KB", bytes / 1024.0];
    if (bytes < 1024ULL * 1024 * 1024) return [NSString stringWithFormat:@"%.1f MB", bytes / (1024.0 * 1024.0)];
    return [NSString stringWithFormat:@"%.2f GB", bytes / (1024.0 * 1024.0 * 1024.0)];
}

/// NSDate → HH:mm:ss
- (NSString *)timeStringForDate:(NSDate *)date {
    if (!date) return @"--";
    static NSDateFormatter *fmt;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"HH:mm:ss";
    });
    return [fmt stringFromDate:date];
}

#pragma mark - 属性（懒加载）

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.alwaysBounceVertical = YES;
        _contentScrollView.showsVerticalScrollIndicator = YES;
        if (@available(iOS 11.0, *)) {
            _contentScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _contentScrollView;
}

- (UIView *)deviceBar {
    if (!_deviceBar) {
        _deviceBar = [[UIView alloc] init];
        _deviceBar.backgroundColor = TSColor_Card;
        _deviceBar.layer.cornerRadius = TSRadius_MD;
    }
    return _deviceBar;
}

- (UIView *)deviceDot {
    if (!_deviceDot) {
        _deviceDot = [[UIView alloc] init];
        _deviceDot.backgroundColor = TSColor_Success;
    }
    return _deviceDot;
}

- (UILabel *)deviceLabel {
    if (!_deviceLabel) {
        _deviceLabel = [[UILabel alloc] init];
        _deviceLabel.font = TSFont_Body;
        _deviceLabel.textColor = TSColor_TextPrimary;
    }
    return _deviceLabel;
}

- (UIView *)stateBadge {
    if (!_stateBadge) {
        _stateBadge = [[UIView alloc] init];
        _stateBadge.layer.masksToBounds = YES;
    }
    return _stateBadge;
}

- (UILabel *)stateBadgeLabel {
    if (!_stateBadgeLabel) {
        _stateBadgeLabel = [[UILabel alloc] init];
        _stateBadgeLabel.font = [UIFont systemFontOfSize:11.f weight:UIFontWeightSemibold];
        _stateBadgeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _stateBadgeLabel;
}

- (UIView *)configCard {
    if (!_configCard) {
        _configCard = [self cardContainer];
    }
    return _configCard;
}

- (UILabel *)configTitleLabel {
    if (!_configTitleLabel) {
        _configTitleLabel = [[UILabel alloc] init];
        _configTitleLabel.font = [UIFont systemFontOfSize:12.f weight:UIFontWeightSemibold];
        _configTitleLabel.textColor = TSColor_TextSecondary;
        _configTitleLabel.text = TSLocalizedString(@"ai_asr_dmic.section_config");
    }
    return _configTitleLabel;
}

- (UILabel *)langTitleLabel {
    if (!_langTitleLabel) {
        _langTitleLabel = [self rowTitleLabelWithKey:@"ai_asr_dmic.label_language"];
    }
    return _langTitleLabel;
}

- (UIButton *)langButton {
    if (!_langButton) {
        _langButton = [self pickerButtonWithAction:@selector(onLangButtonTap)];
    }
    return _langButton;
}

- (UILabel *)sceneTitleLabel {
    if (!_sceneTitleLabel) {
        _sceneTitleLabel = [self rowTitleLabelWithKey:@"ai_asr_dmic.label_scene"];
    }
    return _sceneTitleLabel;
}

- (UIButton *)sceneButton {
    if (!_sceneButton) {
        _sceneButton = [self pickerButtonWithAction:@selector(onSceneButtonTap)];
    }
    return _sceneButton;
}

- (UILabel *)offlineTitleLabel {
    if (!_offlineTitleLabel) {
        _offlineTitleLabel = [self rowTitleLabelWithKey:@"ai_asr_dmic.label_offline"];
    }
    return _offlineTitleLabel;
}

- (UISwitch *)offlineSwitch {
    if (!_offlineSwitch) {
        _offlineSwitch = [[UISwitch alloc] init];
        _offlineSwitch.onTintColor = TSColor_Success;
        [_offlineSwitch addTarget:self
                            action:@selector(onOfflineSwitchChanged:)
                  forControlEvents:UIControlEventValueChanged];
    }
    return _offlineSwitch;
}

- (UILabel *)formatTitleLabel {
    if (!_formatTitleLabel) {
        _formatTitleLabel = [self rowTitleLabelWithKey:@"ai_asr_dmic.label_format"];
    }
    return _formatTitleLabel;
}

- (UIButton *)formatButton {
    if (!_formatButton) {
        _formatButton = [self pickerButtonWithAction:@selector(onFormatButtonTap)];
    }
    return _formatButton;
}

- (UILabel *)metaLabel {
    if (!_metaLabel) {
        _metaLabel = [[UILabel alloc] init];
        _metaLabel.font = TSFont_Caption;
        _metaLabel.textColor = TSColor_TextSecondary;
    }
    return _metaLabel;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [self primaryButtonWithTitleKey:@"ai_asr_dmic.btn_start"
                                                background:TSColor_Primary
                                                    action:@selector(onStartTap)];
    }
    return _startButton;
}

- (UIButton *)stopButton {
    if (!_stopButton) {
        _stopButton = [self primaryButtonWithTitleKey:@"ai_asr_dmic.btn_stop"
                                                background:TSColor_Success
                                                    action:@selector(onStopTap)];
    }
    return _stopButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [self primaryButtonWithTitleKey:@"ai_asr_dmic.btn_cancel"
                                                background:TSColor_Danger
                                                    action:@selector(onCancelTap)];
    }
    return _cancelButton;
}

- (UIView *)streamCard {
    if (!_streamCard) {
        _streamCard = [self cardContainer];
    }
    return _streamCard;
}

- (UILabel *)streamTitleLabel {
    if (!_streamTitleLabel) {
        _streamTitleLabel = [[UILabel alloc] init];
        _streamTitleLabel.font = [UIFont systemFontOfSize:12.f weight:UIFontWeightSemibold];
        _streamTitleLabel.textColor = TSColor_TextSecondary;
        _streamTitleLabel.text = TSLocalizedString(@"ai_asr_dmic.section_stream");
    }
    return _streamTitleLabel;
}

- (UITextView *)streamTextView {
    if (!_streamTextView) {
        _streamTextView = [[UITextView alloc] init];
        _streamTextView.editable = NO;
        _streamTextView.backgroundColor = [UIColor clearColor];
        _streamTextView.textContainerInset = UIEdgeInsetsZero;
        _streamTextView.textContainer.lineFragmentPadding = 0;
        _streamTextView.alwaysBounceVertical = YES;
    }
    return _streamTextView;
}

- (UIView *)recPulseDot {
    if (!_recPulseDot) {
        _recPulseDot = [[UIView alloc] init];
        _recPulseDot.backgroundColor = TSColor_Danger;
        _recPulseDot.hidden = YES;
    }
    return _recPulseDot;
}

- (UIView *)resultCard {
    if (!_resultCard) {
        _resultCard = [self cardContainer];
        _resultCard.hidden = YES;
    }
    return _resultCard;
}

- (UILabel *)resultTitleLabel {
    if (!_resultTitleLabel) {
        _resultTitleLabel = [[UILabel alloc] init];
        _resultTitleLabel.font = [UIFont systemFontOfSize:12.f weight:UIFontWeightSemibold];
        _resultTitleLabel.textColor = TSColor_TextSecondary;
    }
    return _resultTitleLabel;
}

- (UILabel *)resultTextLabel {
    if (!_resultTextLabel) {
        _resultTextLabel = [[UILabel alloc] init];
        _resultTextLabel.font = TSFont_Body;
        _resultTextLabel.textColor = TSColor_TextPrimary;
        _resultTextLabel.numberOfLines = 0;
    }
    return _resultTextLabel;
}

- (UILabel *)resultMetaLabel {
    if (!_resultMetaLabel) {
        _resultMetaLabel = [[UILabel alloc] init];
        _resultMetaLabel.font = TSFont_Caption;
        _resultMetaLabel.textColor = TSColor_TextSecondary;
        _resultMetaLabel.numberOfLines = 0;
    }
    return _resultMetaLabel;
}

- (UIView *)playerRow {
    if (!_playerRow) {
        _playerRow = [[UIView alloc] init];
    }
    return _playerRow;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setTitle:@"▶" forState:UIControlStateNormal];
        [_playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _playButton.titleLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightSemibold];
        _playButton.backgroundColor = TSColor_Primary;
        [_playButton addTarget:self action:@selector(onPlayButtonTap)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIView *)playProgressTrack {
    if (!_playProgressTrack) {
        _playProgressTrack = [[UIView alloc] init];
        _playProgressTrack.backgroundColor = TSColor_Separator;
    }
    return _playProgressTrack;
}

- (UIView *)playProgressFill {
    if (!_playProgressFill) {
        _playProgressFill = [[UIView alloc] init];
        _playProgressFill.backgroundColor = TSColor_Primary;
    }
    return _playProgressFill;
}

- (UILabel *)playTimeLabel {
    if (!_playTimeLabel) {
        _playTimeLabel = [[UILabel alloc] init];
        _playTimeLabel.font = [self monospacedFontOfSize:11.f];
        _playTimeLabel.textColor = TSColor_TextSecondary;
    }
    return _playTimeLabel;
}

- (UILabel *)playFileMetaLabel {
    if (!_playFileMetaLabel) {
        _playFileMetaLabel = [[UILabel alloc] init];
        _playFileMetaLabel.font = TSFont_Caption;
        _playFileMetaLabel.textColor = TSColor_TextSecondary;
        _playFileMetaLabel.textAlignment = NSTextAlignmentRight;
    }
    return _playFileMetaLabel;
}

- (TSAILogView *)logView {
    if (!_logView) {
        _logView = [[TSAILogView alloc] init];
    }
    return _logView;
}

/// 卡片通用容器
- (UIView *)cardContainer {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = TSColor_Card;
    card.layer.cornerRadius = TSRadius_MD;
    return card;
}

/// 行标题 label
- (UILabel *)rowTitleLabelWithKey:(NSString *)key {
    UILabel *label = [[UILabel alloc] init];
    label.font = TSFont_Body;
    label.textColor = TSColor_TextPrimary;
    label.text = TSLocalizedString(key);
    return label;
}

/// 配置区下拉按钮共用样式
- (UIButton *)pickerButtonWithAction:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = TSColor_Background;
    button.layer.cornerRadius = TSRadius_SM;
    button.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
    button.layer.borderColor = TSColor_Separator.CGColor;
    button.titleLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    [button setTitleColor:TSColor_TextPrimary forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

/// 主按钮通用样式
- (UIButton *)primaryButtonWithTitleKey:(NSString *)key
                              background:(UIColor *)bg
                                  action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:TSLocalizedString(key) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightSemibold];
    btn.backgroundColor = bg;
    btn.layer.cornerRadius = TSRadius_SM;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

@end
