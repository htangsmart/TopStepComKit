//
//  TSAITTSVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAITTSVC.h"

#import "TSAILogView.h"
#import "TSAITTSInputCard.h"
#import "TSAITTSPlaybackView.h"
#import "TSAITTSSpeakerSelector.h"

#pragma mark - 状态机

typedef NS_ENUM(NSInteger, TSAITTSState) {
    TSAITTSStateIdle = 0,
    TSAITTSStateSynthesizing,
    TSAITTSStateReady,
    TSAITTSStatePlaying,
    TSAITTSStatePaused,
    TSAITTSStateFailed,
    TSAITTSStateCancelled,
    TSAITTSStateUnsupported,
};

#pragma mark - 常量

/// 文本最大字符数
static const NSInteger kTSAITTSMaxChars = 500;

/// 内置发音人列表
static NSArray<TSAITTSSpeakerEntry *> *TSAITTSBuiltInSpeakers(void) {
    static NSArray<TSAITTSSpeakerEntry *> *list = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        list = @[
            [TSAITTSSpeakerEntry entryWithId:@"zh_female_tianmeitaozi_mars_bigtts" displayName:@"小刚 · 男声"],
            [TSAITTSSpeakerEntry entryWithId:@"aiqi"     displayName:@"艾琪 · 女声"],
            [TSAITTSSpeakerEntry entryWithId:@"xiaowan"  displayName:@"小宛 · 温柔"],
            [TSAITTSSpeakerEntry entryWithId:@"aoming"   displayName:@"奥铭 · 主播"],
            [TSAITTSSpeakerEntry entryWithId:@"laomei"   displayName:@"Lara · 英文"],
        ];
    });
    return list;
}

#pragma mark - VC

@interface TSAITTSVC () <TSAITTSInputCardDelegate, TSAITTSPlaybackViewDelegate, TSAITTSSpeakerSelectorDelegate>

// SDK
@property (nonatomic, strong, nullable) id<TSAISpeechInterface> speech;
@property (nonatomic, copy, nullable)   NSString *currentTaskId;

// 当前合成结果（Ready/Playing/Paused 时非空）
@property (nonatomic, strong, nullable) TSAITTSResult *currentResult;
@property (nonatomic, strong, nullable) NSDate *synthesizeStartTime;
@property (nonatomic, assign)           NSTimeInterval synthesizeDurationMs;

// 发音人状态
@property (nonatomic, copy)              NSString *selectedSpeakerId;
@property (nonatomic, strong) NSMutableArray<TSAITTSSpeakerEntry *> *customSpeakers;

// 滚动容器（所有内容卡片都加在此上，确保整页可滚动）
@property (nonatomic, strong) UIScrollView *contentScrollView;

// 子组件
@property (nonatomic, strong) TSAITTSInputCard       *inputCard;
@property (nonatomic, strong) TSAITTSSpeakerSelector *speakerSelector;
@property (nonatomic, strong) TSAITTSPlaybackView    *playbackView;
@property (nonatomic, strong) TSAILogView            *logView;

// 主按钮 + 取消
@property (nonatomic, strong) UIButton                *primaryButton;
@property (nonatomic, strong) UILabel                 *primaryButtonLabel;
@property (nonatomic, strong) UIActivityIndicatorView *primaryButtonIndicator;
@property (nonatomic, strong) UIButton                *cancelButton;

// 结果卡片外壳（标题 + 徽章 + 内嵌 PlaybackView）
@property (nonatomic, strong) UIView   *resultCard;
@property (nonatomic, strong) UILabel  *resultTitleLabel;
@property (nonatomic, strong) UIView   *statusBadge;
@property (nonatomic, strong) UILabel  *statusLabel;

// 状态
@property (nonatomic, assign) TSAITTSState currentState;

@end

@implementation TSAITTSVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"ai_tts.title");
    self.speech = [[TopStepComKit sharedInstance] aiSpeech];
    self.customSpeakers = [NSMutableArray array];
    self.selectedSpeakerId = TSAITTSBuiltInSpeakers().firstObject.speakerId;
    if (self.speech && [self.speech isSupport]) {
        self.currentState = TSAITTSStateIdle;
    } else {
        self.currentState = TSAITTSStateUnsupported;
    }
}

- (void)setupViews {
    self.inputCard.maxChars = kTSAITTSMaxChars;
    [self.view addSubview:self.contentScrollView];

    [self.contentScrollView addSubview:self.inputCard];

    [self.contentScrollView addSubview:self.speakerSelector];
    [self.speakerSelector setSpeakerEntries:[self allSpeakerEntries]];
    [self.speakerSelector setSelectedSpeakerId:self.selectedSpeakerId];

    [self.contentScrollView addSubview:self.primaryButton];
    [self.primaryButton addSubview:self.primaryButtonIndicator];
    [self.primaryButton addSubview:self.primaryButtonLabel];
    [self.contentScrollView addSubview:self.cancelButton];

    [self.contentScrollView addSubview:self.resultCard];
    [self.resultCard addSubview:self.resultTitleLabel];
    [self.resultCard addSubview:self.statusBadge];
    [self.statusBadge addSubview:self.statusLabel];
    [self.resultCard addSubview:self.playbackView];

    [self.contentScrollView addSubview:self.logView];

    [self refreshUIForState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.currentTaskId.length > 0 && self.speech) {
        [self.logView appendLineWithFormat:@"viewWillDisappear: auto-cancel taskId=%@", self.currentTaskId];
        [self.speech cancelSynthesisWithTaskId:self.currentTaskId];
        self.currentTaskId = nil;
    }
    [self.playbackView stopPlayback];
}

- (void)dealloc {
    if (_currentTaskId.length > 0 && _speech) {
        [_speech cancelSynthesisWithTaskId:_currentTaskId];
    }
}

- (void)layoutViews {
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;

    CGFloat fullWidth = CGRectGetWidth(self.view.bounds);
    CGFloat fullHeight = CGRectGetHeight(self.view.bounds);

    self.contentScrollView.frame = CGRectMake(0, topOffset, fullWidth, fullHeight - topOffset - bottomInset);

    CGFloat margin = TSSpacing_MD;
    CGFloat contentWidth = fullWidth - margin * 2;
    CGFloat gap = TSSpacing_SM;

    // 各区块固定高度，整页可在 ScrollView 内滚动
    CGFloat inputHeight = 180.f;
    CGFloat speakerCardHeight = 92.f;
    CGFloat buttonHeight = 48.f;
    CGFloat resultCardHeight = 230.f;
    CGFloat logHeight = 220.f;

    CGFloat y = margin;
    self.inputCard.frame = CGRectMake(margin, y, contentWidth, inputHeight);
    y += inputHeight + gap;

    self.speakerSelector.frame = CGRectMake(margin, y, contentWidth, speakerCardHeight);
    y += speakerCardHeight + gap;

    CGFloat primaryWidth = (contentWidth - gap) * 0.62f;
    CGFloat cancelWidth  = contentWidth - gap - primaryWidth;
    self.primaryButton.frame = CGRectMake(margin, y, primaryWidth, buttonHeight);
    self.cancelButton.frame  = CGRectMake(margin + primaryWidth + gap, y, cancelWidth, buttonHeight);
    [self layoutPrimaryButtonContent];
    y += buttonHeight + gap;

    self.resultCard.frame = CGRectMake(margin, y, contentWidth, resultCardHeight);
    [self layoutResultCard];
    y += resultCardHeight + gap;

    self.logView.frame = CGRectMake(margin, y, contentWidth, logHeight);
    y += logHeight + margin;

    self.contentScrollView.contentSize = CGSizeMake(fullWidth, y);
}

/// 结果卡片内部布局：标题 + 徽章 + PlaybackView
- (void)layoutResultCard {
    CGFloat pad = TSSpacing_SM;
    CGFloat width = CGRectGetWidth(self.resultCard.bounds);
    CGFloat height = CGRectGetHeight(self.resultCard.bounds);

    CGFloat headerH = 22.f;
    CGFloat badgeW = 80.f;
    self.resultTitleLabel.frame = CGRectMake(pad, pad, width - pad * 2 - badgeW, headerH);
    self.statusBadge.frame = CGRectMake(width - pad - badgeW, pad, badgeW, headerH);
    self.statusBadge.layer.cornerRadius = headerH / 2.f;
    self.statusLabel.frame = self.statusBadge.bounds;

    CGFloat playbackY = pad + headerH + TSSpacing_XS;
    self.playbackView.frame = CGRectMake(pad, playbackY,
                                          width - pad * 2,
                                          height - playbackY - pad);
}

/// 主按钮内部布局：菊花 + 文字居中
- (void)layoutPrimaryButtonContent {
    CGFloat buttonW = CGRectGetWidth(self.primaryButton.bounds);
    CGFloat buttonH = CGRectGetHeight(self.primaryButton.bounds);
    if (buttonW <= 0 || buttonH <= 0) return;

    CGFloat indicatorSize = 16.f;
    CGFloat innerGap = 8.f;

    self.primaryButtonLabel.font = TSFont_H2;
    CGSize textSize = [(self.primaryButtonLabel.text ?: @"")
                       sizeWithAttributes:@{NSFontAttributeName: TSFont_H2}];
    CGFloat textW = ceilf((float)textSize.width);

    BOOL showIndicator = !self.primaryButtonIndicator.hidden;
    CGFloat groupW = showIndicator ? (indicatorSize + innerGap + textW) : textW;
    groupW = MIN(groupW, buttonW - 16.f);
    CGFloat startX = (buttonW - groupW) / 2.f;

    if (showIndicator) {
        self.primaryButtonIndicator.frame = CGRectMake(startX,
                                                        (buttonH - indicatorSize) / 2.f,
                                                        indicatorSize, indicatorSize);
        self.primaryButtonLabel.frame = CGRectMake(startX + indicatorSize + innerGap,
                                                    0,
                                                    groupW - indicatorSize - innerGap,
                                                    buttonH);
    } else {
        self.primaryButtonLabel.frame = CGRectMake(startX, 0, groupW, buttonH);
    }
}

#pragma mark - 公开方法 / 状态机

- (void)setCurrentState:(TSAITTSState)currentState {
    _currentState = currentState;
    [self refreshUIForState];
}

#pragma mark - 私有方法 - 数据 / 校验

/// 当前所有发音人 = 内置 + 自定义
- (NSArray<TSAITTSSpeakerEntry *> *)allSpeakerEntries {
    NSMutableArray *result = [NSMutableArray arrayWithArray:TSAITTSBuiltInSpeakers()];
    [result addObjectsFromArray:self.customSpeakers];
    return result;
}

/// 当前状态是否允许编辑参数
- (BOOL)isParameterEditableState {
    switch (self.currentState) {
        case TSAITTSStateIdle:
        case TSAITTSStateReady:
        case TSAITTSStateFailed:
        case TSAITTSStateCancelled:
            return YES;
        case TSAITTSStateSynthesizing:
        case TSAITTSStatePlaying:
        case TSAITTSStatePaused:
        case TSAITTSStateUnsupported:
            return NO;
    }
}

/// 文本是否合法
- (BOOL)isInputValid {
    NSString *trimmed = [self.inputCard trimmedText];
    return trimmed.length > 0 && self.inputCard.text.length <= kTSAITTSMaxChars;
}

#pragma mark - 私有方法 - UI 状态刷新

/// 根据当前状态刷新所有 UI
- (void)refreshUIForState {
    BOOL editable = [self isParameterEditableState];
    BOOL hasInput = [self isInputValid];

    [self refreshPrimaryAndCancelButtonsForEditable:editable hasInput:hasInput];

    self.inputCard.editable = editable;
    self.speakerSelector.chipsEnabled = editable;

    [self refreshStatusBadge];
    [self refreshPlaybackForState];

    [self.view setNeedsLayout];
}

/// 主按钮 / 取消按钮的状态切换
- (void)refreshPrimaryAndCancelButtonsForEditable:(BOOL)editable hasInput:(BOOL)hasInput {
    NSString *title = nil;
    UIColor *titleColor = [UIColor whiteColor];
    UIColor *bgColor = TSColor_Primary;
    UIColor *borderColor = nil;
    BOOL primaryEnabled = NO;
    BOOL showIndicator = NO;
    BOOL cancelEnabled = NO;

    switch (self.currentState) {
        case TSAITTSStateIdle:
        case TSAITTSStateFailed:
        case TSAITTSStateCancelled:
            title = TSLocalizedString(@"ai_tts.synthesize");
            primaryEnabled = hasInput;
            break;
        case TSAITTSStateReady:
            title = TSLocalizedString(@"ai_tts.resynthesize");
            primaryEnabled = hasInput;
            break;
        case TSAITTSStateSynthesizing:
            title = TSLocalizedString(@"ai_tts.synthesizing");
            titleColor = TSColor_Primary;
            bgColor = TSColor_Card;
            borderColor = TSColor_Primary;
            primaryEnabled = NO;
            cancelEnabled = YES;
            showIndicator = YES;
            break;
        case TSAITTSStatePlaying:
        case TSAITTSStatePaused:
            title = TSLocalizedString(@"ai_tts.resynthesize");
            primaryEnabled = NO;
            break;
        case TSAITTSStateUnsupported:
            title = TSLocalizedString(@"ai_tts.synthesize");
            primaryEnabled = NO;
            break;
    }

    self.primaryButtonLabel.text = title;
    self.primaryButtonLabel.textColor = primaryEnabled ? titleColor : [titleColor colorWithAlphaComponent:0.5f];
    self.primaryButton.backgroundColor = bgColor;
    self.primaryButton.layer.borderWidth = borderColor ? 1.f : 0.f;
    self.primaryButton.layer.borderColor = borderColor.CGColor;
    self.primaryButton.enabled = primaryEnabled;
    self.primaryButton.alpha = primaryEnabled ? 1.f : 0.5f;

    self.primaryButtonIndicator.hidden = !showIndicator;
    if (showIndicator) {
        self.primaryButtonIndicator.color = TSColor_Primary;
        [self.primaryButtonIndicator startAnimating];
    } else {
        [self.primaryButtonIndicator stopAnimating];
    }

    self.cancelButton.enabled = cancelEnabled;
    self.cancelButton.alpha = cancelEnabled ? 1.f : 0.4f;

    [self layoutPrimaryButtonContent];
}

/// 刷新状态徽章颜色与文案
- (void)refreshStatusBadge {
    NSString *text = nil;
    UIColor *color = TSColor_TextSecondary;
    switch (self.currentState) {
        case TSAITTSStateIdle:         text = TSLocalizedString(@"ai_tts.status_idle");         color = TSColor_TextSecondary; break;
        case TSAITTSStateSynthesizing: text = TSLocalizedString(@"ai_tts.status_synthesizing"); color = TSColor_Primary;       break;
        case TSAITTSStateReady:        text = TSLocalizedString(@"ai_tts.status_ready");        color = TSColor_Primary;       break;
        case TSAITTSStatePlaying:      text = TSLocalizedString(@"ai_tts.status_playing");      color = TSColor_Success;       break;
        case TSAITTSStatePaused:       text = TSLocalizedString(@"ai_tts.status_paused");       color = TSColor_Warning;       break;
        case TSAITTSStateFailed:       text = TSLocalizedString(@"ai_tts.status_failed");       color = TSColor_Danger;        break;
        case TSAITTSStateCancelled:    text = TSLocalizedString(@"ai_tts.status_cancelled");    color = TSColor_Warning;       break;
        case TSAITTSStateUnsupported:  text = TSLocalizedString(@"ai_tts.status_unsupported");  color = TSColor_TextSecondary; break;
    }
    self.statusLabel.text = text;
    self.statusLabel.textColor = color;
    self.statusBadge.backgroundColor = [color colorWithAlphaComponent:0.15f];
}

/// 把当前状态翻译给 PlaybackView（仅 Idle/Synthesizing/Unsupported 处理空态；Ready/Failed/Cancelled 由 completion 路径触发）
- (void)refreshPlaybackForState {
    switch (self.currentState) {
        case TSAITTSStateIdle:
            [self.playbackView showEmptyWithHint:TSLocalizedString(@"ai_tts.result_empty")];
            break;
        case TSAITTSStateSynthesizing:
            [self.playbackView showEmptyWithHint:TSLocalizedString(@"ai_tts.synthesizing")];
            break;
        case TSAITTSStateUnsupported:
            [self.playbackView showEmptyWithHint:TSLocalizedString(@"ai_tts.unsupported_hint")];
            break;
        default:
            break;
    }
}

#pragma mark - 私有方法 - 业务

/// 触发合成
- (void)triggerSynthesize {
    if (!self.speech || ![self.speech isSupport]) {
        [self.logView appendLine:TSLocalizedString(@"ai_tts.toast_unavailable")];
        return;
    }
    NSString *trimmed = [self.inputCard trimmedText];
    if (trimmed.length == 0) {
        [self.logView appendLine:TSLocalizedString(@"ai_tts.toast_empty_input")];
        return;
    }
    if (self.inputCard.text.length > kTSAITTSMaxChars) {
        [self.logView appendLineWithFormat:TSLocalizedString(@"ai_tts.toast_too_long"), (long)kTSAITTSMaxChars];
        return;
    }

    [self.inputCard resignTextEditing];
    [self.playbackView stopPlayback];
    self.currentResult = nil;
    self.synthesizeStartTime = [NSDate date];

    [self.logView appendLineWithFormat:@"▶ synthesize len=%lu speakerId=%@",
        (unsigned long)trimmed.length, self.selectedSpeakerId];
    self.currentState = TSAITTSStateSynthesizing;

    TSAITTSConfig *config = [TSAITTSConfig configWithSpeakerId:self.selectedSpeakerId];

    __weak typeof(self) weakSelf = self;
    NSString *taskId = [self.speech synthesizeSpeechWithText:trimmed
                                                       config:config
                                                   completion:^(TSAITTSResult * _Nullable result, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            // 校验 taskId 一致，避免上一个任务的迟到回调污染 UI
            NSString *callbackTaskId = result.taskId ?: strongSelf.currentTaskId;
            if (callbackTaskId.length > 0 && strongSelf.currentTaskId.length > 0
                && ![callbackTaskId isEqualToString:strongSelf.currentTaskId]) {
                return;
            }
            [strongSelf handleSynthesisCompletionWithResult:result error:error];
        });
    }];

    self.currentTaskId = taskId;
    [self.logView appendLineWithFormat:@"  taskId=%@", taskId];
}

/// 处理合成回调（已在主线程）
- (void)handleSynthesisCompletionWithResult:(TSAITTSResult * _Nullable)result error:(NSError * _Nullable)error {
    self.synthesizeDurationMs = [[NSDate date] timeIntervalSinceDate:self.synthesizeStartTime] * 1000.0;

    if (error) {
        BOOL isCancel = (error.code == eTSErrorUserCancelled);
        if (isCancel) {
            [self.playbackView showErrorWithTitle:TSLocalizedString(@"ai_tts.cancelled_hint")
                                            detail:error.localizedDescription ?: @""
                                       accentColor:TSColor_Warning];
            self.currentState = TSAITTSStateCancelled;
            [self.logView appendLineWithFormat:@"✕ cancelled: %@", error.localizedDescription ?: @""];
        } else {
            NSString *detail = [NSString stringWithFormat:@"domain=%@\ncode=%ld\nmsg=%@",
                                error.domain ?: @"-",
                                (long)error.code,
                                error.localizedDescription ?: @"-"];
            [self.playbackView showErrorWithTitle:TSLocalizedString(@"ai_tts.failed_hint")
                                            detail:detail
                                       accentColor:TSColor_Danger];
            self.currentState = TSAITTSStateFailed;
            [self.logView appendLineWithFormat:@"✕ failed: domain=%@ code=%ld msg=%@",
                error.domain, (long)error.code, error.localizedDescription ?: @""];
        }
        self.currentTaskId = nil;
        return;
    }

    self.currentResult = result;
    [self.playbackView showReadyWithResult:result synthesizeDurationMs:self.synthesizeDurationMs];
    self.currentState = TSAITTSStateReady;
    [self.logView appendLineWithFormat:@"✓ done duration=%.0fms bytes=%lu format=%ld",
        self.synthesizeDurationMs,
        (unsigned long)result.audioData.length,
        (long)result.audioFormat];
    self.currentTaskId = nil;
}

/// 触发取消
- (void)triggerCancel {
    if (self.currentTaskId.length == 0) return;
    [self.logView appendLineWithFormat:@"▶ cancel taskId=%@", self.currentTaskId];
    [self.speech cancelSynthesisWithTaskId:self.currentTaskId];
}

#pragma mark - 事件

- (void)onPrimaryButtonTapped {
    [self triggerSynthesize];
}

- (void)onCancelButtonTapped {
    [self triggerCancel];
}

#pragma mark - TSAITTSInputCardDelegate

- (void)inputCardDidChangeText:(TSAITTSInputCard *)card {
    [self refreshUIForState];
}

- (void)inputCardDidTapSample:(TSAITTSInputCard *)card {
    card.text = TSLocalizedString(@"ai_tts.sample_text");
    [self refreshUIForState];
}

#pragma mark - TSAITTSSpeakerSelectorDelegate

- (void)speakerSelector:(TSAITTSSpeakerSelector *)selector didSelectSpeakerId:(NSString *)speakerId {
    if (speakerId.length == 0) return;
    self.selectedSpeakerId = speakerId;
    [selector setSelectedSpeakerId:speakerId];
    [self.logView appendLineWithFormat:@"· speaker → %@", speakerId];
}

- (void)speakerSelectorDidRequestCustomSpeaker:(TSAITTSSpeakerSelector *)selector {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:TSLocalizedString(@"ai_tts.custom_speaker_title")
                         message:TSLocalizedString(@"ai_tts.custom_speaker_msg")
                  preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"speakerId";
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"ai_tts.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        NSString *raw = alert.textFields.firstObject.text ?: @"";
        NSString *speakerId = [raw stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (speakerId.length == 0) return;
        BOOL exists = NO;
        for (TSAITTSSpeakerEntry *entry in [strongSelf allSpeakerEntries]) {
            if ([entry.speakerId isEqualToString:speakerId]) { exists = YES; break; }
        }
        if (!exists) {
            [strongSelf.customSpeakers addObject:[TSAITTSSpeakerEntry entryWithId:speakerId displayName:speakerId]];
            [strongSelf.speakerSelector setSpeakerEntries:[strongSelf allSpeakerEntries]];
        }
        strongSelf.selectedSpeakerId = speakerId;
        [strongSelf.speakerSelector setSelectedSpeakerId:speakerId];
        [strongSelf.logView appendLineWithFormat:@"· speaker → %@（custom）", speakerId];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TSAITTSPlaybackViewDelegate

- (void)playbackViewDidRequestPlay:(TSAITTSPlaybackView *)view {
    BOOL ok = [view startPlayback];
    if (!ok) {
        [self.logView appendLine:@"✕ playback abort: unsupported format or empty data"];
        return;
    }
    self.currentState = TSAITTSStatePlaying;
    [self.logView appendLineWithFormat:@"▶ play taskId=%@",
        self.currentResult.taskId.length > 8 ? [self.currentResult.taskId substringToIndex:8] : (self.currentResult.taskId ?: @"")];
}

- (void)playbackViewDidRequestPause:(TSAITTSPlaybackView *)view {
    [view pausePlayback];
    self.currentState = TSAITTSStatePaused;
    [self.logView appendLine:@"⏸ pause"];
}

- (void)playbackViewDidRequestResume:(TSAITTSPlaybackView *)view {
    [view resumePlayback];
    self.currentState = TSAITTSStatePlaying;
    [self.logView appendLine:@"▶ resume"];
}

- (void)playbackViewDidRequestStop:(TSAITTSPlaybackView *)view {
    [view stopPlayback];
    self.currentState = TSAITTSStateReady;
    [self.logView appendLine:@"⏹ stop"];
}

- (void)playbackViewDidFinishPlayback:(TSAITTSPlaybackView *)view successfully:(BOOL)flag {
    self.currentState = TSAITTSStateReady;
    [self.logView appendLineWithFormat:@"✓ playback finished, ok=%@", flag ? @"YES" : @"NO"];
}

#pragma mark - 属性（懒加载）

- (TSAITTSInputCard *)inputCard {
    if (!_inputCard) {
        _inputCard = [[TSAITTSInputCard alloc] initWithFrame:CGRectZero];
        _inputCard.delegate = self;
    }
    return _inputCard;
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.alwaysBounceVertical = YES;
        _contentScrollView.showsVerticalScrollIndicator = YES;
        _contentScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        if (@available(iOS 11.0, *)) {
            _contentScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _contentScrollView;
}

- (TSAITTSSpeakerSelector *)speakerSelector {
    if (!_speakerSelector) {
        _speakerSelector = [[TSAITTSSpeakerSelector alloc] initWithFrame:CGRectZero];
        _speakerSelector.delegate = self;
    }
    return _speakerSelector;
}

- (TSAITTSPlaybackView *)playbackView {
    if (!_playbackView) {
        _playbackView = [[TSAITTSPlaybackView alloc] initWithFrame:CGRectZero];
        _playbackView.delegate = self;
    }
    return _playbackView;
}

- (TSAILogView *)logView {
    if (!_logView) {
        _logView = [[TSAILogView alloc] initWithFrame:CGRectZero];
    }
    return _logView;
}

- (UIButton *)primaryButton {
    if (!_primaryButton) {
        _primaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _primaryButton.layer.cornerRadius = TSRadius_SM;
        _primaryButton.layer.masksToBounds = YES;
        [_primaryButton addTarget:self action:@selector(onPrimaryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _primaryButton;
}

- (UILabel *)primaryButtonLabel {
    if (!_primaryButtonLabel) {
        _primaryButtonLabel = [[UILabel alloc] init];
        _primaryButtonLabel.font = TSFont_H2;
        _primaryButtonLabel.textAlignment = NSTextAlignmentLeft;
        _primaryButtonLabel.userInteractionEnabled = NO;
    }
    return _primaryButtonLabel;
}

- (UIActivityIndicatorView *)primaryButtonIndicator {
    if (!_primaryButtonIndicator) {
        if (@available(iOS 13.0, *)) {
            _primaryButtonIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _primaryButtonIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _primaryButtonIndicator.hidesWhenStopped = YES;
        _primaryButtonIndicator.userInteractionEnabled = NO;
    }
    return _primaryButtonIndicator;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:TSLocalizedString(@"ai_tts.cancel") forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = TSFont_H2;
        [_cancelButton setTitleColor:TSColor_Danger forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [TSColor_Danger colorWithAlphaComponent:0.10f];
        _cancelButton.layer.cornerRadius = TSRadius_SM;
        [_cancelButton addTarget:self action:@selector(onCancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIView *)resultCard {
    if (!_resultCard) {
        _resultCard = [[UIView alloc] init];
        _resultCard.backgroundColor = TSColor_Card;
        _resultCard.layer.cornerRadius = TSRadius_MD;
    }
    return _resultCard;
}

- (UILabel *)resultTitleLabel {
    if (!_resultTitleLabel) {
        _resultTitleLabel = [[UILabel alloc] init];
        _resultTitleLabel.font = TSFont_H2;
        _resultTitleLabel.textColor = TSColor_TextPrimary;
        _resultTitleLabel.text = TSLocalizedString(@"ai_tts.result");
    }
    return _resultTitleLabel;
}

- (UIView *)statusBadge {
    if (!_statusBadge) {
        _statusBadge = [[UIView alloc] init];
        _statusBadge.layer.masksToBounds = YES;
    }
    return _statusBadge;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = [UIFont systemFontOfSize:11.f weight:UIFontWeightSemibold];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLabel;
}

@end
