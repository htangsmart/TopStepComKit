//
//  TSAIInterpreterVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterVC.h"

#import "TSAIInterpreterUtteranceCell.h"
#import "TSAIInterpreterFormatter.h"
#import "TSAIInterpreterSessionStripView.h"
#import "TSAIInterpreterLanguageBarView.h"
#import "TSAIInterpreterLanguageSheetVC.h"
#import "TSAIInterpreterSettingsVC.h"
#import "TSAILogView.h"

@interface TSAIInterpreterVC () <UITableViewDataSource, UITableViewDelegate>

#pragma mark - 顶部语言条
/// 语言条组件（白卡 + 两胶囊 + 蓝色互换按钮）
@property (nonatomic, strong) TSAIInterpreterLanguageBarView *languageBarView;

#pragma mark - 状态条
/// 状态条视图（卡片 + 5 根 meter + 状态文 + taskId）
@property (nonatomic, strong) TSAIInterpreterSessionStripView *sessionStripView;

#pragma mark - 字幕 + 日志 + 主按钮 + 底部
/// 字幕表（每行一段 utterance）
@property (nonatomic, strong) UITableView *transcriptTableView;
/// 字幕区为空时的占位文案
@property (nonatomic, strong) UILabel *transcriptPlaceholder;
/// 事件 / 错误日志输出
@property (nonatomic, strong) TSAILogView *logView;
/// 底部 bar 容器（白底 + 顶部分割线，承载三按钮）
@property (nonatomic, strong) UIView *bottomBarView;
/// 底部分割线
@property (nonatomic, strong) UIView *bottomBarSeparator;
/// 麦克风圆形主按钮（Start / Stop）
@property (nonatomic, strong) UIButton *micButton;
/// 底部左：历史按钮（暂未启用，预留）
@property (nonatomic, strong) UIButton *historyButton;
/// 底部右：齿轮按钮（弹出会话设置抽屉）
@property (nonatomic, strong) UIButton *settingsButton;

#pragma mark - 状态
/// 当前选择的源语言（可为 Auto）
@property (nonatomic, assign) TSAILanguage selectedSourceLanguage;
/// 当前选择的目标语言（不可为 Auto）
@property (nonatomic, assign) TSAILanguage selectedTargetLanguage;
/// 源语 Auto 解析后的具体语言（LanguageDetected 事件回填）
@property (nonatomic, assign) TSAILanguage resolvedSourceLanguage;
/// 是否产出 TTS 音频（enableVoiceOutput）
@property (nonatomic, assign) BOOL enableVoiceOutput;
/// 是否由 SDK 自动送到设备播放（autoPlayVoice）
@property (nonatomic, assign) BOOL autoPlayVoice;
/// TTS 发音人 ID（speakerId，可为 nil 走后端默认）
@property (nonatomic, copy, nullable) NSString *speakerId;
/// 当前进行中的 taskId（nil 表示空闲）
@property (nonatomic, copy, nullable) NSString *currentTaskId;
/// 当前会话开始时间
@property (nonatomic, strong, nullable) NSDate *sessionStartDate;
/// 当前会话累积的 utterance UI 模型（按 index 升序）
@property (nonatomic, strong) NSMutableArray<TSAIInterpreterUtteranceUI *> *utterances;

@end

@implementation TSAIInterpreterVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"ai_interpreter.title");
    self.selectedSourceLanguage = TSAILanguageAuto;
    self.selectedTargetLanguage = TSAILanguageChineseSimplified;
    self.resolvedSourceLanguage = TSAILanguageUnknown;
    self.enableVoiceOutput = YES;
    self.autoPlayVoice = YES;
    self.speakerId = nil;
    self.utterances = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    [self setupViews];
    [self setupLanguageBarHandlers];
    [self refreshAllUI];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.currentTaskId.length > 0) {
        [self.logView appendLineWithFormat:@"[interpreter] viewWillDisappear: stop taskId=%@",
            [TSAIInterpreterFormatter shortIdForTaskId:self.currentTaskId]];
        [[[TopStepComKit sharedInstance] aiInterpreter] stopInterpretationWithTaskId:self.currentTaskId];
    }
}

- (void)dealloc {
    if (_currentTaskId.length > 0) {
        [[[TopStepComKit sharedInstance] aiInterpreter] stopInterpretationWithTaskId:_currentTaskId];
    }
}

#pragma mark - 私有方法 - 视图搭建

- (void)setupViews {
    [self.view addSubview:self.languageBarView];
    [self.view addSubview:self.sessionStripView];
    [self.view addSubview:self.transcriptTableView];
    [self.transcriptTableView addSubview:self.transcriptPlaceholder];

    [self.view addSubview:self.bottomBarView];
    [self.bottomBarView addSubview:self.bottomBarSeparator];
    [self.bottomBarView addSubview:self.historyButton];
    [self.bottomBarView addSubview:self.micButton];
    [self.bottomBarView addSubview:self.settingsButton];
}

- (void)setupLanguageBarHandlers {
    __weak typeof(self) weakSelf = self;
    self.languageBarView.onSourceTap = ^{ [weakSelf onSourceLanguagePillTap]; };
    self.languageBarView.onTargetTap = ^{ [weakSelf onTargetLanguagePillTap]; };
    self.languageBarView.onSwapTap = ^{ [weakSelf onSwapLanguageTap]; };
}

- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat padding = 14.0;
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    CGFloat innerW = width - padding * 2;
    CGFloat y = topOffset + 12.0;

    CGFloat langBarH = 76.0;
    self.languageBarView.frame = CGRectMake(padding, y, innerW, langBarH);
    y = CGRectGetMaxY(self.languageBarView.frame) + 10.0;

    CGFloat stripH = 44.0;
    self.sessionStripView.frame = CGRectMake(padding, y, innerW, stripH);
    y = CGRectGetMaxY(self.sessionStripView.frame) + 12.0;

    CGFloat barTopPad = 14.0;
    CGFloat micSize = 78.0;
    CGFloat barH = barTopPad + micSize + 14.0 + bottomInset;
    CGFloat barY = CGRectGetHeight(self.view.bounds) - barH;
    self.bottomBarView.frame = CGRectMake(0, barY, width, barH);
    self.bottomBarSeparator.frame = CGRectMake(0, 0, width, 0.5);
    self.micButton.frame = CGRectMake((width - micSize) / 2.0, barTopPad, micSize, micSize);
    self.micButton.layer.cornerRadius = micSize / 2.0;
    CGFloat sideBtn = 44.0;
    CGFloat sideY = barTopPad + (micSize - sideBtn) / 2.0;
    self.historyButton.frame = CGRectMake(padding + 28.0, sideY, sideBtn, sideBtn);
    self.historyButton.layer.cornerRadius = sideBtn / 2.0;
    self.settingsButton.frame = CGRectMake(width - padding - 28.0 - sideBtn, sideY, sideBtn, sideBtn);
    self.settingsButton.layer.cornerRadius = sideBtn / 2.0;

    CGFloat transcriptHeight = barY - 8.0 - y;
    self.transcriptTableView.frame = CGRectMake(0, y, width, transcriptHeight);
    self.transcriptPlaceholder.frame = CGRectMake(padding, 40, width - padding * 2, transcriptHeight - 40);
}

#pragma mark - 私有方法 - UI 状态刷新

- (void)refreshAllUI {
    [self refreshLanguagePillTitles];
    [self refreshSessionStrip];
    [self refreshMicButtonForState];
    [self refreshTranscriptPlaceholder];
}

- (void)refreshLanguagePillTitles {
    NSString *srcValue;
    NSString *srcAutoTag;
    if (self.selectedSourceLanguage == TSAILanguageAuto) {
        if (self.resolvedSourceLanguage != TSAILanguageUnknown
            && self.resolvedSourceLanguage != TSAILanguageAuto) {
            srcValue = [TSAIInterpreterFormatter displayNameForLanguage:self.resolvedSourceLanguage];
            srcAutoTag = TSLocalizedString(@"ai_interpreter.lang_pill_auto_tag");
        } else {
            srcValue = TSLocalizedString(@"ai_interpreter.lang_pill_auto");
            srcAutoTag = TSLocalizedString(@"ai_interpreter.lang_pill_detect_tag");
        }
    } else {
        srcValue = [TSAIInterpreterFormatter displayNameForLanguage:self.selectedSourceLanguage];
        srcAutoTag = nil;
    }
    [self.languageBarView setSourceValueText:srcValue autoTag:srcAutoTag];

    NSString *dstValue = (self.selectedTargetLanguage == TSAILanguageUnknown)
        ? TSLocalizedString(@"ai_interpreter.lang_pill_unset")
        : [TSAIInterpreterFormatter displayNameForLanguage:self.selectedTargetLanguage];
    [self.languageBarView setTargetValueText:dstValue];

    BOOL running = (self.currentTaskId.length > 0);
    BOOL canSwap = !running && self.selectedSourceLanguage != TSAILanguageAuto;
    [self.languageBarView setPillsEnabled:!running swapEnabled:canSwap];
}

- (void)refreshSessionStrip {
    BOOL active = (self.currentTaskId.length > 0);
    if (active) {
        [self.sessionStripView setStatusText:TSLocalizedString(@"ai_interpreter.status_listening")
                                    textColor:[UIColor systemGreenColor]];
        [self.sessionStripView setTaskIdText:[NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.taskid_fmt"),
                                                 [TSAIInterpreterFormatter shortIdForTaskId:self.currentTaskId]]];
    } else {
        [self.sessionStripView setStatusText:TSLocalizedString(@"ai_interpreter.status_ready")
                                    textColor:[UIColor secondaryLabelColor]];
        [self.sessionStripView setTaskIdText:nil];
    }
    [self.sessionStripView setActive:active];
}

- (void)refreshMicButtonForState {
    BOOL running = (self.currentTaskId.length > 0);
    BOOL canStart = !running
                    && self.selectedTargetLanguage != TSAILanguageUnknown
                    && self.selectedTargetLanguage != TSAILanguageAuto;
    if (running) {
        self.micButton.backgroundColor = [UIColor systemRedColor];
        if (@available(iOS 13.0, *)) {
            UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:28.0
                                                                                                weight:UIImageSymbolWeightSemibold];
            UIImage *stopIcon = [UIImage systemImageNamed:@"stop.fill" withConfiguration:cfg];
            [self.micButton setImage:stopIcon forState:UIControlStateNormal];
        }
        self.micButton.enabled = YES;
        self.micButton.alpha = 1.0;
    } else {
        self.micButton.backgroundColor = canStart ? [UIColor systemGreenColor] : [UIColor systemGray3Color];
        if (@available(iOS 13.0, *)) {
            UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:28.0
                                                                                                weight:UIImageSymbolWeightSemibold];
            UIImage *micIcon = [UIImage systemImageNamed:@"mic.fill" withConfiguration:cfg];
            [self.micButton setImage:micIcon forState:UIControlStateNormal];
        }
        self.micButton.enabled = canStart;
        self.micButton.alpha = canStart ? 1.0 : 0.65;
    }
}

- (void)refreshTranscriptPlaceholder {
    self.transcriptPlaceholder.hidden = (self.utterances.count > 0);
}

#pragma mark - 私有方法 - 按钮事件

- (void)onSourceLanguagePillTap {
    NSMutableArray<NSNumber *> *list = [NSMutableArray arrayWithObject:@(TSAILanguageAuto)];
    [list addObjectsFromArray:[TSAIInterpreterFormatter concreteLanguageList]];
    [self presentLanguageSheetWithList:list
                                  title:TSLocalizedString(@"ai_interpreter.sheet_select_source")
                              isSource:YES];
}

- (void)onTargetLanguagePillTap {
    [self presentLanguageSheetWithList:[TSAIInterpreterFormatter concreteLanguageList]
                                  title:TSLocalizedString(@"ai_interpreter.sheet_select_target")
                              isSource:NO];
}

/// ⇄ 互换源 / 目标语言（源为 Auto 时禁用）
- (void)onSwapLanguageTap {
    if (self.selectedSourceLanguage == TSAILanguageAuto) return;
    TSAILanguage tmp = self.selectedSourceLanguage;
    self.selectedSourceLanguage = self.selectedTargetLanguage;
    self.selectedTargetLanguage = tmp;
    self.resolvedSourceLanguage = TSAILanguageUnknown;
    [self refreshLanguagePillTitles];
    [self refreshMicButtonForState];
}

/// 麦克风主按钮：Idle/Ready → Start；Running → Stop
- (void)onMicButtonTap {
    if (self.currentTaskId.length > 0) {
        [self stopSession];
    } else {
        [self startSession];
    }
}

- (void)onHistoryButtonTap {
    [self showAlertWithMsg:TSLocalizedString(@"ai_interpreter.toast_history_unavailable")];
}

/// 底部 ⚙️：弹出会话设置抽屉
- (void)onSettingsBarItemTap {
    if (self.currentTaskId.length > 0) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_interpreter.toast_settings_locked")];
        return;
    }
    TSAIInterpreterSettingsVC *settingsVC =
        [[TSAIInterpreterSettingsVC alloc] initWithEnableVoiceOutput:self.enableVoiceOutput
                                                       autoPlayVoice:self.autoPlayVoice
                                                           speakerId:self.speakerId
                                                             logView:self.logView];
    __weak typeof(self) weakSelf = self;
    __weak TSAIInterpreterSettingsVC *weakSettings = settingsVC;
    settingsVC.onDismiss = ^{
        TSAIInterpreterSettingsVC *strongSettings = weakSettings;
        if (!strongSettings) return;
        weakSelf.enableVoiceOutput = strongSettings.enableVoiceOutput;
        weakSelf.autoPlayVoice = strongSettings.autoPlayVoice;
        weakSelf.speakerId = strongSettings.speakerId;
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    if (@available(iOS 15.0, *)) {
        UISheetPresentationController *sheet = nav.sheetPresentationController;
        sheet.detents = @[ [UISheetPresentationControllerDetent mediumDetent],
                            [UISheetPresentationControllerDetent largeDetent] ];
        sheet.prefersGrabberVisible = YES;
        sheet.prefersScrollingExpandsWhenScrolledToEdge = NO;
    }
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - 私有方法 - 会话流程

- (void)startSession {
    if (self.selectedTargetLanguage == TSAILanguageUnknown
        || self.selectedTargetLanguage == TSAILanguageAuto) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_interpreter.toast_no_target")];
        return;
    }
    id<TSAIInterpreterInterface> interpreter = [[TopStepComKit sharedInstance] aiInterpreter];
    if (interpreter == nil) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_interpreter.toast_unavailable")];
        return;
    }

    [self.utterances removeAllObjects];
    [self.transcriptTableView reloadData];
    [self refreshTranscriptPlaceholder];
    self.resolvedSourceLanguage = TSAILanguageUnknown;
    self.sessionStartDate = [NSDate date];

    TSAIInterpreterConfig *config = [TSAIInterpreterConfig defaultConfig];
    config.sourceLanguage = self.selectedSourceLanguage;
    config.targetLanguage = self.selectedTargetLanguage;
    config.enableVoiceOutput = self.enableVoiceOutput;
    config.autoPlayVoice = self.autoPlayVoice;
    config.speakerId = self.speakerId;

    [self.logView appendLineWithFormat:@"[interpreter] ▶ start src=%@ dst=%@ tts=%@ play=%@ speaker=%@",
        [TSAIInterpreterFormatter displayNameForLanguage:self.selectedSourceLanguage],
        [TSAIInterpreterFormatter displayNameForLanguage:self.selectedTargetLanguage],
        self.enableVoiceOutput ? @"Y" : @"N",
        self.autoPlayVoice ? @"Y" : @"N",
        self.speakerId.length > 0 ? self.speakerId : @"(default)"];

    TSLog(@"[TSAIInterpreterVC][RAW][config] sourceLanguage=%ld, targetLanguage=%ld, "
          @"enableVoiceOutput=%d, autoPlayVoice=%d, speakerId=%@",
          (long)config.sourceLanguage, (long)config.targetLanguage,
          config.enableVoiceOutput, config.autoPlayVoice, config.speakerId);

    __weak typeof(self) weakSelf = self;
    NSString *taskId = [interpreter startInterpretationWithConfig:config
                                                          onContent:^(TSAIInterpreterContent *content) {
        TSLog(@"[TSAIInterpreterVC][RAW][onContent] taskId=%@, contentType=%ld, utteranceIndex=%ld, "
              @"language=%ld, text=%@, isTextFinal=%d, audioChunkBytes=%lu, audioFormat=%ld, isAudioFinal=%d",
              content.taskId, (long)content.contentType, (long)content.utteranceIndex,
              (long)content.language, content.text, content.isTextFinal,
              (unsigned long)content.audioChunk.length, (long)content.audioFormat, content.isAudioFinal);
        [weakSelf handleContent:content];
    }
                                                            onEvent:^(TSAIInterpreterEvent *event) {
        TSLog(@"[TSAIInterpreterVC][RAW][onEvent] taskId=%@, eventType=%ld, timestamp=%@, "
              @"utteranceIndex=%ld, detectedLanguage=%ld",
              event.taskId, (long)event.eventType, event.timestamp,
              (long)event.utteranceIndex, (long)event.detectedLanguage);
        [weakSelf handleEvent:event];
    }
                                                         completion:^(TSAIInterpreterReport * _Nullable report,
                                                                      NSError * _Nullable error) {
        TSLog(@"[TSAIInterpreterVC][RAW][completion] report.taskId=%@, sourceLanguage=%ld, "
              @"targetLanguage=%ld, enableVoiceOutput=%d, autoPlayVoice=%d, speakerId=%@, "
              @"startTime=%@, endTime=%@, duration=%.3f, endReason=%ld, utteranceCount=%lu, "
              @"error.domain=%@, error.code=%ld, error.localizedDescription=%@, error.userInfo=%@",
              report.taskId, (long)report.sourceLanguage,
              (long)report.targetLanguage, report.enableVoiceOutput, report.autoPlayVoice,
              report.speakerId, report.startTime, report.endTime,
              report.duration, (long)report.endReason, (unsigned long)report.utterances.count,
              error.domain, (long)error.code, error.localizedDescription, error.userInfo);
        for (TSAIInterpreterUtterance *u in report.utterances) {
            TSLog(@"[TSAIInterpreterVC][RAW][completion.utterance] index=%ld, startTime=%@, "
                  @"sourceLanguage=%ld, targetLanguage=%ld, originalText=%@, translatedText=%@",
                  (long)u.index, u.startTime, (long)u.sourceLanguage, (long)u.targetLanguage,
                  u.originalText, u.translatedText);
        }
        [weakSelf handleCompletionWithReport:report error:error];
    }];

    self.currentTaskId = taskId;
    TSLog(@"[TSAIInterpreterVC][RAW][startInterpretation returns] taskId=%@", taskId);
    [self.logView appendLineWithFormat:@"  taskId=%@", [TSAIInterpreterFormatter shortIdForTaskId:taskId]];
    [self refreshAllUI];
}

- (void)stopSession {
    if (self.currentTaskId.length == 0) return;
    [self.logView appendLineWithFormat:@"[interpreter] ⏹ stop taskId=%@",
        [TSAIInterpreterFormatter shortIdForTaskId:self.currentTaskId]];
    self.micButton.enabled = NO;
    self.micButton.alpha = 0.65;
    [self.sessionStripView setStatusText:TSLocalizedString(@"ai_interpreter.status_finishing")
                                textColor:[UIColor systemOrangeColor]];
    [[[TopStepComKit sharedInstance] aiInterpreter] stopInterpretationWithTaskId:self.currentTaskId];
}

#pragma mark - 私有方法 - SDK 回调

/// onContent：按 contentType 分发
- (void)handleContent:(TSAIInterpreterContent *)content {
    if (![content.taskId isEqualToString:self.currentTaskId]) return;

    TSAIInterpreterUtteranceUI *utterance = [self utteranceUIForIndex:content.utteranceIndex
                                                          createIfMissing:YES];
    switch (content.contentType) {
        case TSAIInterpreterContentTypeOriginalText:
            utterance.originalText = content.text;
            utterance.isOriginalFinal = content.isTextFinal;
            if (content.isTextFinal) {
                [self.logView appendLineWithFormat:@"  📝 #%ld Orig final len=%lu",
                    (long)content.utteranceIndex, (unsigned long)content.text.length];
            }
            break;
        case TSAIInterpreterContentTypeTranslatedText:
            utterance.translatedText = content.text;
            utterance.isTranslatedFinal = content.isTextFinal;
            if (content.isTextFinal) {
                [self.logView appendLineWithFormat:@"  📝 #%ld Trans final len=%lu",
                    (long)content.utteranceIndex, (unsigned long)content.text.length];
            }
            break;
        case TSAIInterpreterContentTypeAudioChunk:
            utterance.audioBytes += content.audioChunk.length;
            utterance.isAudioFinal = content.isAudioFinal;
            if (content.isAudioFinal) {
                [self.logView appendLineWithFormat:@"  🎵 #%ld audio final bytes=%lu",
                    (long)content.utteranceIndex, (unsigned long)utterance.audioBytes];
            }
            break;
        case TSAIInterpreterContentTypeUnknown:
        default:
            return;
    }
    [self reloadRowForUtterance:utterance];
    [self refreshTranscriptPlaceholder];
}

/// onEvent：路由到日志、状态条、语言胶囊
- (void)handleEvent:(TSAIInterpreterEvent *)event {
    if (![event.taskId isEqualToString:self.currentTaskId]) return;
    switch (event.eventType) {
        case TSAIInterpreterEventTypeSessionStarted:
            [self.logView appendLine:@"  🟢 SessionStarted"];
            break;
        case TSAIInterpreterEventTypeUtteranceStarted:
            [self.logView appendLineWithFormat:@"  🎤 UtteranceStarted #%ld", (long)event.utteranceIndex];
            [self utteranceUIForIndex:event.utteranceIndex createIfMissing:YES];
            [self refreshTranscriptPlaceholder];
            break;
        case TSAIInterpreterEventTypeUtteranceEnded:
            [self.logView appendLineWithFormat:@"  🎤 UtteranceEnded   #%ld", (long)event.utteranceIndex];
            break;
        case TSAIInterpreterEventTypeLanguageDetected:
            self.resolvedSourceLanguage = event.detectedLanguage;
            [self.logView appendLineWithFormat:@"  🌐 LanguageDetected: %@",
                [TSAIInterpreterFormatter displayNameForLanguage:event.detectedLanguage]];
            [self refreshLanguagePillTitles];
            break;
        case TSAIInterpreterEventTypeTranslationPlaybackStarted:
            [self.logView appendLineWithFormat:@"  🔊 PlaybackStarted #%ld", (long)event.utteranceIndex];
            break;
        case TSAIInterpreterEventTypeTranslationPlaybackEnded:
            [self.logView appendLineWithFormat:@"  🔊 PlaybackEnded   #%ld", (long)event.utteranceIndex];
            break;
        case TSAIInterpreterEventTypeNetworkError:
            [self.logView appendLine:@"  ⚠️ NetworkError"];
            break;
        case TSAIInterpreterEventTypeBleDisconnected:
            [self.logView appendLine:@"  ❌ BleDisconnected"];
            break;
        case TSAIInterpreterEventTypeUnknown:
        default:
            break;
    }
}

/// completion：写日志、弹结束卡、重置状态
- (void)handleCompletionWithReport:(TSAIInterpreterReport * _Nullable)report
                              error:(NSError * _Nullable)error {
    NSTimeInterval elapsed = self.sessionStartDate
        ? -[self.sessionStartDate timeIntervalSinceNow] : 0;

    if (error) {
        [self.logView appendLineWithFormat:@"[interpreter] ❌ %@:%ld %@",
            error.domain ?: @"-", (long)error.code, error.localizedDescription ?: @"-"];
        [self.sessionStripView setStatusText:TSLocalizedString(@"ai_interpreter.status_failed")
                                    textColor:[UIColor systemRedColor]];
        [self showAlertWithMsg:[NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.toast_error_fmt"),
                                  error.localizedDescription ?: @"-"]];
    } else if (report) {
        NSString *reasonText = [TSAIInterpreterFormatter displayNameForEndReason:report.endReason];
        [self.logView appendLineWithFormat:@"[interpreter] ✅ done dur=%.2fs utt=%lu reason=%@",
            elapsed, (unsigned long)report.utterances.count, reasonText];
        [self presentReportSummary:report duration:elapsed];
    }

    self.currentTaskId = nil;
    self.sessionStartDate = nil;
    [self refreshAllUI];
}

#pragma mark - 私有方法 - utterance / report 工具

/// 取或建一个 utterance UI 模型（按 index 升序插入）
- (TSAIInterpreterUtteranceUI *)utteranceUIForIndex:(NSInteger)index
                                       createIfMissing:(BOOL)create {
    for (TSAIInterpreterUtteranceUI *exist in self.utterances) {
        if (exist.index == index) return exist;
    }
    if (!create) return nil;
    TSAIInterpreterUtteranceUI *utterance = [[TSAIInterpreterUtteranceUI alloc] init];
    utterance.index = index;
    utterance.startTime = [NSDate date];
    NSUInteger insertAt = self.utterances.count;
    for (NSUInteger i = 0; i < self.utterances.count; i++) {
        if (self.utterances[i].index > index) { insertAt = i; break; }
    }
    [self.utterances insertObject:utterance atIndex:insertAt];
    [self.transcriptTableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:insertAt inSection:0] ]
                                     withRowAnimation:UITableViewRowAnimationFade];
    return utterance;
}

/// 找到 utterance 在数组中的位置并刷新对应 row + 滚动到底
- (void)reloadRowForUtterance:(TSAIInterpreterUtteranceUI *)utterance {
    NSUInteger idx = [self.utterances indexOfObject:utterance];
    if (idx == NSNotFound) return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    [self.transcriptTableView reloadRowsAtIndexPaths:@[ indexPath ]
                                     withRowAnimation:UITableViewRowAnimationNone];
    if ([self.transcriptTableView numberOfRowsInSection:0] > 0) {
        [self.transcriptTableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionBottom
                                                  animated:YES];
    }
}

/// 弹结束卡：duration / utterance count / 语言对 / TTS 配置 / endReason
- (void)presentReportSummary:(TSAIInterpreterReport *)report
                     duration:(NSTimeInterval)duration {
    NSString *src = [TSAIInterpreterFormatter displayNameForLanguage:report.sourceLanguage];
    NSString *dst = [TSAIInterpreterFormatter displayNameForLanguage:report.targetLanguage];
    NSString *reason = [TSAIInterpreterFormatter displayNameForEndReason:report.endReason];
    NSString *body = [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.report_body_fmt"),
                        duration,
                        (unsigned long)report.utterances.count,
                        src, dst,
                        report.enableVoiceOutput ? @"On" : @"Off",
                        report.autoPlayVoice ? @"On" : @"Off",
                        reason];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"ai_interpreter.report_title")
                                                                    message:body
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm")
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 私有方法 - 语言弹层

- (void)presentLanguageSheetWithList:(NSArray<NSNumber *> *)list
                                title:(NSString *)title
                            isSource:(BOOL)isSource {
    TSAILanguage current = isSource ? self.selectedSourceLanguage : self.selectedTargetLanguage;
    __weak typeof(self) weakSelf = self;
    TSAIInterpreterLanguageSheetVC *sheet =
        [[TSAIInterpreterLanguageSheetVC alloc] initWithTitle:title
                                                     languages:list
                                                       current:current
                                                        onPick:^(TSAILanguage picked) {
        if (isSource) {
            weakSelf.selectedSourceLanguage = picked;
            weakSelf.resolvedSourceLanguage = TSAILanguageUnknown;
        } else {
            weakSelf.selectedTargetLanguage = picked;
        }
        [weakSelf refreshLanguagePillTitles];
        [weakSelf refreshMicButtonForState];
    }];
    sheet.modalPresentationStyle = UIModalPresentationPageSheet;
    if (@available(iOS 15.0, *)) {
        UISheetPresentationController *presentation = sheet.sheetPresentationController;
        presentation.detents = @[ [UISheetPresentationControllerDetent mediumDetent],
                                   [UISheetPresentationControllerDetent largeDetent] ];
        presentation.prefersGrabberVisible = YES;
    }
    [self presentViewController:sheet animated:YES completion:nil];
}


#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.utterances.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const identifier = @"TSAIInterpreterUtteranceCell";
    TSAIInterpreterUtteranceCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TSAIInterpreterUtteranceCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:identifier];
    }
    TSAIInterpreterUtteranceUI *utterance = self.utterances[indexPath.row];
    [cell bindWithUtterance:utterance showAudio:self.enableVoiceOutput];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSAIInterpreterUtteranceUI *utterance = self.utterances[indexPath.row];
    return [TSAIInterpreterUtteranceCell heightForUtterance:utterance
                                                   showAudio:self.enableVoiceOutput
                                                   cellWidth:CGRectGetWidth(tableView.bounds)];
}

#pragma mark - 属性（懒加载）

- (TSAIInterpreterLanguageBarView *)languageBarView {
    if (!_languageBarView) _languageBarView = [[TSAIInterpreterLanguageBarView alloc] init];
    return _languageBarView;
}

- (TSAIInterpreterSessionStripView *)sessionStripView {
    if (!_sessionStripView) _sessionStripView = [[TSAIInterpreterSessionStripView alloc] init];
    return _sessionStripView;
}

- (UITableView *)transcriptTableView {
    if (!_transcriptTableView) {
        _transcriptTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _transcriptTableView.dataSource = self;
        _transcriptTableView.delegate = self;
        _transcriptTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _transcriptTableView.backgroundColor = [UIColor clearColor];
        _transcriptTableView.contentInset = UIEdgeInsetsMake(4, 0, 4, 0);
        _transcriptTableView.showsVerticalScrollIndicator = NO;
    }
    return _transcriptTableView;
}

- (UILabel *)transcriptPlaceholder {
    if (!_transcriptPlaceholder) {
        _transcriptPlaceholder = [[UILabel alloc] init];
        _transcriptPlaceholder.text = TSLocalizedString(@"ai_interpreter.transcript_empty");
        _transcriptPlaceholder.textAlignment = NSTextAlignmentCenter;
        _transcriptPlaceholder.numberOfLines = 0;
        _transcriptPlaceholder.font = [UIFont systemFontOfSize:13.0];
        _transcriptPlaceholder.textColor = [UIColor tertiaryLabelColor];
    }
    return _transcriptPlaceholder;
}

- (TSAILogView *)logView {
    if (!_logView) {
        _logView = [[TSAILogView alloc] init];
    }
    return _logView;
}

- (UIView *)bottomBarView {
    if (!_bottomBarView) {
        _bottomBarView = [[UIView alloc] init];
        _bottomBarView.backgroundColor = [[UIColor systemBackgroundColor] colorWithAlphaComponent:0.92];
    }
    return _bottomBarView;
}

- (UIView *)bottomBarSeparator {
    if (!_bottomBarSeparator) {
        _bottomBarSeparator = [[UIView alloc] init];
        _bottomBarSeparator.backgroundColor = [UIColor separatorColor];
    }
    return _bottomBarSeparator;
}

- (UIButton *)micButton {
    if (!_micButton) {
        _micButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _micButton.backgroundColor = [UIColor systemGreenColor];
        _micButton.tintColor = [UIColor whiteColor];
        _micButton.layer.borderColor = [UIColor systemBackgroundColor].CGColor;
        _micButton.layer.borderWidth = 4.0;
        _micButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _micButton.layer.shadowOpacity = 0.18;
        _micButton.layer.shadowRadius = 12.0;
        _micButton.layer.shadowOffset = CGSizeMake(0, 4);
        [_micButton addTarget:self action:@selector(onMicButtonTap)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _micButton;
}

- (UIButton *)historyButton {
    if (!_historyButton) {
        _historyButton = [self bottomIconButtonWithSystemName:@"clock.arrow.circlepath"
                                                          action:@selector(onHistoryButtonTap)];
    }
    return _historyButton;
}

- (UIButton *)settingsButton {
    if (!_settingsButton) {
        _settingsButton = [self bottomIconButtonWithSystemName:@"gearshape"
                                                          action:@selector(onSettingsBarItemTap)];
    }
    return _settingsButton;
}

- (UIButton *)bottomIconButtonWithSystemName:(NSString *)systemName action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [UIColor systemGray6Color];
    btn.tintColor = [UIColor labelColor];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:18.0
                                                                                            weight:UIImageSymbolWeightRegular];
        [btn setImage:[UIImage systemImageNamed:systemName withConfiguration:cfg]
                forState:UIControlStateNormal];
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

@end
