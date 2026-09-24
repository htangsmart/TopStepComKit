//
//  TSAIInterpreterVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterVC.h"

#import <TopStepAIKit/TopStepAIKit.h>

#import "TSAIInterpreterFormatter.h"
#import "TSAIInterpreterLanguageBarView.h"
#import "TSAIInterpreterSessionStripView.h"
#import "TSAIInterpreterSettingsVC.h"
#import "TSAIInterpreterSetupSheetVC.h"
#import "TSAIInterpreterSplitView.h"
#import "TSAIInterpreterUtteranceUI.h"
#import "TSAILogView.h"

/// 上一次会话请求的持久化 key
static NSString *const kTSAIInterpreterLastRequestKey = @"TSAIInterpreterLastRequest";

@interface TSAIInterpreterVC ()

#pragma mark - 视图
/// 语言条（只读）
@property (nonatomic, strong) TSAIInterpreterLanguageBarView *languageBarView;
/// 状态条
@property (nonatomic, strong) TSAIInterpreterSessionStripView *sessionStripView;
/// 上下分栏字幕
@property (nonatomic, strong) TSAIInterpreterSplitView *splitView;
/// 日志视图（在信息抽屉内展示）
@property (nonatomic, strong) TSAILogView *logView;
/// 底栏容器
@property (nonatomic, strong) UIView *bottomBarView;
/// 底栏分割线
@property (nonatomic, strong) UIView *bottomBarSeparator;
/// 麦克风主按钮（Start / Stop）
@property (nonatomic, strong) UIButton *micButton;
/// 信息与日志抽屉按钮
@property (nonatomic, strong) UIButton *infoButton;

#pragma mark - 状态
/// 上一次 / 当前会话请求
@property (nonatomic, copy, nullable) TSAIInterpretationRequest *lastRequest;
/// 当前会话 id（nil 表示空闲）
@property (nonatomic, copy, nullable) NSString *sessionId;
/// 最近一次快照
@property (nonatomic, strong, nullable) TSAIInterpretationSnapshot *snapshot;
/// 当前会话的 utterance UI 模型（按 index 升序）
@property (nonatomic, strong) NSMutableArray<TSAIInterpreterUtteranceUI *> *utterances;
/// 是否已在首次显示时弹出设置抽屉
@property (nonatomic, assign) BOOL hasPresentedInitialSetup;
/// 会话结束后是否退出页面（返回键确认 / 异常结束）
@property (nonatomic, assign) BOOL popAfterCompletion;
/// 页面是否正在退出
@property (nonatomic, assign) BOOL leavingPage;

@end

@implementation TSAIInterpreterVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"ai_interpreter.title");
    self.utterances = [NSMutableArray array];
    self.lastRequest = [self loadLastRequest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    [self setupViews];
    [self refreshAllUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.leavingPage = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.hasPresentedInitialSetup) {
        self.hasPresentedInitialSetup = YES;
        [self presentSetupSheet];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.leavingPage = YES;
    // 未经确认就离开（如侧滑）时兜底结束会话。
    [self stopSessionIfActive];
}

- (void)dealloc {
    if (_sessionId.length > 0) {
        [[TSAIKit sharedInstance].activeContext.interpretation stopWithSessionId:_sessionId];
    }
}

#pragma mark - 私有方法 - 视图搭建

- (void)setupViews {
    [self.view addSubview:self.languageBarView];
    [self.view addSubview:self.sessionStripView];
    [self.view addSubview:self.splitView];
    self.splitView.utterances = self.utterances;

    [self.view addSubview:self.bottomBarView];
    [self.bottomBarView addSubview:self.bottomBarSeparator];
    [self.bottomBarView addSubview:self.micButton];
    [self.bottomBarView addSubview:self.infoButton];
    [self.languageBarView setPillsEnabled:NO swapEnabled:NO];
}

- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat padding = 14.0;
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    CGFloat innerW = width - padding * 2;
    CGFloat y = topOffset + 12.0;

    self.languageBarView.frame = CGRectMake(padding, y, innerW, 76.0);
    y = CGRectGetMaxY(self.languageBarView.frame) + 10.0;

    self.sessionStripView.frame = CGRectMake(padding, y, innerW, 44.0);
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
    self.infoButton.frame = CGRectMake(width - padding - 28.0 - sideBtn, sideY, sideBtn, sideBtn);
    self.infoButton.layer.cornerRadius = sideBtn / 2.0;

    self.splitView.frame = CGRectMake(padding, y, innerW, MAX(barY - 8.0 - y, 0));
}

#pragma mark - 私有方法 - UI 刷新

- (void)refreshAllUI {
    [self refreshLanguageBar];
    [self refreshSessionStrip];
    [self refreshMicButton];
    [self refreshSplitPanels];
    [self refreshNavigationLock];
}

/// 语言条只读展示当前 / 上一次请求的语言
- (void)refreshLanguageBar {
    TSAIInterpretationRequest *request = self.lastRequest;
    NSString *srcValue = request != nil
        ? [TSAIInterpreterFormatter displayNameForLanguage:request.sourceLanguage]
        : TSLocalizedString(@"ai_interpreter.lang_pill_unset");
    NSString *srcAutoTag = (request != nil && request.sourceLanguage == TSAILanguageAuto)
        ? TSLocalizedString(@"ai_interpreter.lang_pill_auto_tag")
        : nil;
    [self.languageBarView setSourceValueText:srcValue autoTag:srcAutoTag];
    NSString *dstValue = request != nil
        ? [TSAIInterpreterFormatter displayNameForLanguage:request.targetLanguage]
        : TSLocalizedString(@"ai_interpreter.lang_pill_unset");
    [self.languageBarView setTargetValueText:dstValue];
    [self.splitView setSourceLanguageText:request != nil
        ? [TSAIInterpreterFormatter displayNameForLanguage:request.sourceLanguage]
        : nil];
    [self.splitView setTargetLanguageText:request != nil
        ? [TSAIInterpreterFormatter displayNameForLanguage:request.targetLanguage]
        : nil];
}

/// 状态条直接映射快照状态
- (void)refreshSessionStrip {
    TSAIInterpretationState state = self.snapshot.state;
    BOOL active = [self isSessionActive];
    NSString *statusText = TSLocalizedString(@"ai_interpreter.status_ready");
    UIColor *statusColor = [UIColor secondaryLabelColor];
    NSString *taskIdText = nil;
    switch (state) {
        case TSAIInterpretationStatePreparing:
            statusText = TSLocalizedString(@"ai_asr_dmic.state.starting");
            statusColor = [UIColor systemOrangeColor];
            break;
        case TSAIInterpretationStateListening:
            statusText = [NSString stringWithFormat:@"%@ · %@",
                          TSLocalizedString(@"ai_interpreter.status_listening"),
                          [self pickupTitleForRequest:self.lastRequest]];
            statusColor = [UIColor systemGreenColor];
            taskIdText = [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.taskid_fmt"),
                          [TSAIInterpreterFormatter shortIdForTaskId:self.snapshot.taskId]];
            break;
        case TSAIInterpretationStateStopping:
            statusText = TSLocalizedString(@"ai_interpreter.status_finishing");
            statusColor = [UIColor systemOrangeColor];
            break;
        case TSAIInterpretationStateEnded:
            if (self.snapshot.endReason != TSAIInterpretationEndReasonUserStop) {
                statusText = TSLocalizedString(@"ai_interpreter.status_failed");
                statusColor = [UIColor systemRedColor];
            }
            break;
        case TSAIInterpretationStateIdle:
        default:
            break;
    }
    [self.sessionStripView setStatusText:statusText textColor:statusColor];
    [self.sessionStripView setTaskIdText:taskIdText];
    [self.sessionStripView setActive:active];
}

/// 麦克风：空闲 → 绿色 Start；进行中 → 红色 Stop（Stopping 期间禁用）
- (void)refreshMicButton {
    BOOL active = [self isSessionActive];
    BOOL stopping = self.snapshot.state == TSAIInterpretationStateStopping;
    UIImageSymbolConfiguration *cfg =
        [UIImageSymbolConfiguration configurationWithPointSize:28.0 weight:UIImageSymbolWeightSemibold];
    if (active) {
        self.micButton.backgroundColor = [UIColor systemRedColor];
        [self.micButton setImage:[UIImage systemImageNamed:@"stop.fill" withConfiguration:cfg]
                        forState:UIControlStateNormal];
        self.micButton.enabled = !stopping;
        self.micButton.alpha = stopping ? 0.65 : 1.0;
    } else {
        self.micButton.backgroundColor = [UIColor systemGreenColor];
        [self.micButton setImage:[UIImage systemImageNamed:@"mic.fill" withConfiguration:cfg]
                        forState:UIControlStateNormal];
        self.micButton.enabled = YES;
        self.micButton.alpha = 1.0;
    }
}

/// 分栏面板：最新句高亮仅在会话进行中；TTS 徽标按请求
- (void)refreshSplitPanels {
    self.splitView.highlightsLatest = self.snapshot.state == TSAIInterpretationStateListening;
    BOOL voice = self.lastRequest.enableVoiceOutput;
    self.splitView.showAudio = voice;
    [self.splitView setTargetBadgeText:voice ? TSLocalizedString(@"ai_interpreter.panel_badge_autoplay") : nil];
}

/// 会话进行中：接管返回键做二次确认，禁用侧滑返回
- (void)refreshNavigationLock {
    BOOL active = [self isSessionActive];
    self.navigationController.interactivePopGestureRecognizer.enabled = !active;
    if (active) {
        if (self.navigationItem.leftBarButtonItem == nil) {
            UIImage *icon = [UIImage systemImageNamed:@"chevron.backward"];
            self.navigationItem.leftBarButtonItem =
                [[UIBarButtonItem alloc] initWithImage:icon
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(onBackTap)];
        }
        self.navigationItem.hidesBackButton = YES;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = NO;
    }
}

#pragma mark - 私有方法 - 事件

/// 麦克风：空闲 → 设置抽屉；进行中 → 二次确认后结束
- (void)onMicButtonTap {
    if ([self isSessionActive]) {
        [self confirmStopWithPop:NO];
    } else {
        [self presentSetupSheet];
    }
}

/// 返回：会话进行中先确认，结束后再退出
- (void)onBackTap {
    if ([self isSessionActive]) {
        [self confirmStopWithPop:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onInfoButtonTap {
    TSAIInterpreterSettingsVC *drawer =
        [[TSAIInterpreterSettingsVC alloc] initWithRequest:self.lastRequest logView:self.logView];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:drawer];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    UISheetPresentationController *sheet = nav.sheetPresentationController;
    sheet.detents = @[ [UISheetPresentationControllerDetent mediumDetent],
                        [UISheetPresentationControllerDetent largeDetent] ];
    sheet.prefersGrabberVisible = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

/// 弹出开始前设置抽屉
- (void)presentSetupSheet {
    if ([self isSessionActive] || self.presentedViewController != nil) {
        return;
    }
    TSAIInterpreterSetupSheetVC *setup =
        [[TSAIInterpreterSetupSheetVC alloc] initWithInitialRequest:self.lastRequest];
    __weak typeof(self) weakSelf = self;
    setup.onStart = ^(TSAIInterpretationRequest *request) {
        [weakSelf startSessionWithRequest:request];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:setup];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    UISheetPresentationController *sheet = nav.sheetPresentationController;
    sheet.detents = @[ [UISheetPresentationControllerDetent largeDetent] ];
    sheet.prefersGrabberVisible = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

/// 二次确认结束会话
- (void)confirmStopWithPop:(BOOL)pop {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:TSLocalizedString(@"ai_interpreter.confirm_exit_title")
                                            message:TSLocalizedString(@"ai_interpreter.confirm_exit_body")
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"ai_interpreter.confirm_exit_stop")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action) {
        weakSelf.popAfterCompletion = pop;
        [weakSelf stopSessionIfActive];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 私有方法 - 会话

- (BOOL)isSessionActive {
    return self.sessionId.length > 0;
}

/// 启动会话：清空字幕，把意图交给 SDK 会话
- (void)startSessionWithRequest:(TSAIInterpretationRequest *)request {
    id<TSAIInterpretationInterface> interpretation = [TSAIKit sharedInstance].activeContext.interpretation;
    if (interpretation == nil || [self isSessionActive]) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_interpreter.toast_unavailable")];
        return;
    }
    self.lastRequest = request;
    [self saveLastRequest:request];
    [self.utterances removeAllObjects];
    [self.splitView reloadAllData];
    self.popAfterCompletion = NO;
    [self.logView appendLineWithFormat:@"[interpretation] ▶ start pickup=%ld src=%@ dst=%@ tts=%@ speaker=%@",
        (long)request.pickup,
        [TSAIInterpreterFormatter displayNameForLanguage:request.sourceLanguage],
        [TSAIInterpreterFormatter displayNameForLanguage:request.targetLanguage],
        request.enableVoiceOutput ? @"Y" : @"N",
        request.speakerId.length > 0 ? request.speakerId : @"(default)"];

    __weak typeof(self) weakSelf = self;
    NSString *sessionId = [interpretation startWithRequest:request
        onContent:^(TSAIInterpreterContent *content) {
            TSLog(@"[TSAIInterpreterVC][RAW][onContent] taskId=%@, type=%ld, index=%ld, text=%@, "
                  @"textFinal=%d, audioBytes=%lu, audioFinal=%d",
                  content.taskId, (long)content.contentType, (long)content.utteranceIndex,
                  content.text, content.isTextFinal, (unsigned long)content.audioChunk.length,
                  content.isAudioFinal);
            [weakSelf handleContent:content];
        }
        onEvent:^(TSAIInterpreterEvent *event) {
            TSLog(@"[TSAIInterpreterVC][RAW][onEvent] taskId=%@, type=%ld, index=%ld, lang=%ld",
                  event.taskId, (long)event.eventType, (long)event.utteranceIndex,
                  (long)event.detectedLanguage);
            [weakSelf handleEvent:event];
        }
        onSnapshot:^(TSAIInterpretationSnapshot *snapshot) {
            TSLog(@"[TSAIInterpreterVC][RAW][onSnapshot] %@", snapshot);
            [weakSelf handleSnapshot:snapshot];
        }
        completion:^(TSAIInterpreterReport *report, TSAIInterpretationSnapshot *snapshot) {
            TSLog(@"[TSAIInterpreterVC][RAW][completion] report.taskId=%@, utterances=%lu, snapshot=%@",
                  report.taskId, (unsigned long)report.utterances.count, snapshot);
            [weakSelf handleCompletionWithReport:report snapshot:snapshot];
        }];
    self.sessionId = sessionId;
    if (sessionId.length == 0) {
        // 拒绝原因随 completion 回来，这里只刷新 UI。
        [self refreshAllUI];
        return;
    }
    self.snapshot = interpretation.snapshot;
    [self.logView appendLineWithFormat:@"  sessionId=%@", [TSAIInterpreterFormatter shortIdForTaskId:sessionId]];
    [self refreshAllUI];
}

/// 结束会话（幂等）
- (void)stopSessionIfActive {
    if (![self isSessionActive]) {
        return;
    }
    [self.logView appendLineWithFormat:@"[interpretation] ⏹ stop sessionId=%@",
        [TSAIInterpreterFormatter shortIdForTaskId:self.sessionId]];
    [[TSAIKit sharedInstance].activeContext.interpretation stopWithSessionId:self.sessionId];
}

#pragma mark - 私有方法 - SDK 回调

/// 快照：只做渲染
- (void)handleSnapshot:(TSAIInterpretationSnapshot *)snapshot {
    if (![snapshot.sessionId isEqualToString:self.sessionId]) {
        return;
    }
    self.snapshot = snapshot;
    [self refreshAllUI];
}

/// 内容：按 contentType 更新对应 utterance 行
- (void)handleContent:(TSAIInterpreterContent *)content {
    if (![self isSessionActive]) return;
    if (content.contentType != TSAIInterpreterContentTypeOriginalText
        && content.contentType != TSAIInterpreterContentTypeTranslatedText
        && content.contentType != TSAIInterpreterContentTypeAudioChunk) {
        return;
    }
    TSAIInterpreterUtteranceUI *utterance = [self utteranceUIForIndex:content.utteranceIndex createIfMissing:YES];
    switch (content.contentType) {
        case TSAIInterpreterContentTypeOriginalText:
            utterance.originalText = content.text;
            utterance.isOriginalFinal = content.isTextFinal;
            break;
        case TSAIInterpreterContentTypeTranslatedText:
            utterance.translatedText = content.text;
            utterance.isTranslatedFinal = content.isTextFinal;
            break;
        case TSAIInterpreterContentTypeAudioChunk:
            utterance.audioBytes += content.audioChunk.length;
            utterance.isAudioFinal = content.isAudioFinal;
            break;
        default:
            return;
    }
    [self reloadRowForUtterance:utterance];
}

/// 事件：只写日志（断连 / 网络异常由 SDK 会话收口为 completion）
- (void)handleEvent:(TSAIInterpreterEvent *)event {
    switch (event.eventType) {
        case TSAIInterpreterEventTypeSessionStarted:
            [self.logView appendLine:@"  🟢 SessionStarted"];
            break;
        case TSAIInterpreterEventTypeUtteranceStarted:
            [self.logView appendLineWithFormat:@"  🎤 UtteranceStarted #%ld", (long)event.utteranceIndex];
            [self utteranceUIForIndex:event.utteranceIndex createIfMissing:YES];
            break;
        case TSAIInterpreterEventTypeUtteranceEnded:
            [self.logView appendLineWithFormat:@"  🎤 UtteranceEnded   #%ld", (long)event.utteranceIndex];
            break;
        case TSAIInterpreterEventTypeLanguageDetected:
            [self.logView appendLineWithFormat:@"  🌐 LanguageDetected: %@",
                [TSAIInterpreterFormatter displayNameForLanguage:event.detectedLanguage]];
            [self.splitView setSourceLanguageText:[NSString stringWithFormat:
                TSLocalizedString(@"ai_interpreter.panel_lang_auto_fmt"),
                [TSAIInterpreterFormatter displayNameForLanguage:event.detectedLanguage]]];
            break;
        case TSAIInterpreterEventTypeNetworkError:
            [self.logView appendLine:@"  ⚠️ NetworkError (waiting for recovery)"];
            break;
        case TSAIInterpreterEventTypeBleDisconnected:
            [self.logView appendLine:@"  ❌ BleDisconnected"];
            break;
        default:
            break;
    }
}

/// 完成：用报告校正字幕，按 endReason 提示，必要时退出页面
- (void)handleCompletionWithReport:(nullable TSAIInterpreterReport *)report
                          snapshot:(TSAIInterpretationSnapshot *)snapshot {
    BOOL rejectedStart = self.sessionId.length == 0 && snapshot.sessionId.length == 0;
    if (!rejectedStart && ![snapshot.sessionId isEqualToString:self.sessionId]) {
        return;
    }
    self.sessionId = nil;
    self.snapshot = snapshot;
    if (report != nil) {
        [self reconcileUtterancesWithReport:report];
    }
    NSTimeInterval elapsed = snapshot.startDate ? -[snapshot.startDate timeIntervalSinceNow] : 0;
    NSString *reasonText = [TSAIInterpreterFormatter displayNameForInterpretationEndReason:snapshot.endReason];
    [self.logView appendLineWithFormat:@"[interpretation] ■ ended dur=%.2fs utt=%lu reason=%@ error=%@",
        elapsed, (unsigned long)report.utterances.count, reasonText,
        snapshot.error.localizedDescription ?: @"-"];
    [self refreshAllUI];
    if (self.leavingPage) {
        return;
    }
    BOOL shouldPop = self.popAfterCompletion;
    self.popAfterCompletion = NO;
    if (snapshot.endReason == TSAIInterpretationEndReasonUserStop) {
        if (shouldPop) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if (report != nil) {
            [self presentReportSummary:report duration:elapsed];
        }
        return;
    }
    // 异常结束：提示原因；设备退出 / 断连 / 网络异常按需求退出翻译界面
    NSString *body = snapshot.error.localizedDescription.length > 0
        ? [NSString stringWithFormat:@"%@\n%@", reasonText, snapshot.error.localizedDescription]
        : reasonText;
    BOOL leaveAfterAlert = shouldPop ||
        snapshot.endReason == TSAIInterpretationEndReasonDeviceExit ||
        snapshot.endReason == TSAIInterpretationEndReasonDeviceDisconnected ||
        snapshot.endReason == TSAIInterpretationEndReasonNetworkError;
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:TSLocalizedString(@"ai_interpreter.end_reason_title")
                                            message:body
                                     preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        if (leaveAfterAlert) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }]];
    [self presentAlertAboveAnything:alert];
}

/// 信息抽屉 / 确认弹窗还开着时，先关掉再弹，避免 present 静默失败丢掉提示
- (void)presentAlertAboveAnything:(UIAlertController *)alert {
    __weak typeof(self) weakSelf = self;
    void (^show)(void) = ^{
        [weakSelf presentViewController:alert animated:YES completion:nil];
    };
    if (self.presentedViewController != nil) {
        [self dismissViewControllerAnimated:NO completion:show];
    } else {
        show();
    }
}

#pragma mark - 私有方法 - utterance / report 工具

/// 会话结束后以 report 为准校正每句原文 / 译文，并把未收尾的状态标记为完成
- (void)reconcileUtterancesWithReport:(TSAIInterpreterReport *)report {
    BOOL changed = NO;
    for (TSAIInterpreterUtterance *reported in report.utterances) {
        TSAIInterpreterUtteranceUI *utterance = [self utteranceUIForIndex:reported.index createIfMissing:YES];
        if (reported.originalText.length > 0 &&
            ![reported.originalText isEqualToString:utterance.originalText]) {
            utterance.originalText = reported.originalText;
            changed = YES;
        }
        if (reported.translatedText.length > 0 &&
            ![reported.translatedText isEqualToString:utterance.translatedText]) {
            utterance.translatedText = reported.translatedText;
            changed = YES;
        }
        BOOL originalFinal = utterance.originalText.length > 0;
        BOOL translatedFinal = utterance.translatedText.length > 0;
        BOOL audioFinal = utterance.isAudioFinal || utterance.audioBytes > 0;
        if (utterance.isOriginalFinal != originalFinal ||
            utterance.isTranslatedFinal != translatedFinal ||
            utterance.isAudioFinal != audioFinal) {
            changed = YES;
        }
        utterance.isOriginalFinal = originalFinal;
        utterance.isTranslatedFinal = translatedFinal;
        utterance.isAudioFinal = audioFinal;
    }
    if (changed) {
        [self.logView appendLineWithFormat:@"  📋 reconciled %lu utterances from report",
            (unsigned long)report.utterances.count];
        [self.splitView reloadAllData];
    }
}

/// 取或建一个 utterance UI 模型（按 index 升序插入）
- (TSAIInterpreterUtteranceUI *)utteranceUIForIndex:(NSInteger)index createIfMissing:(BOOL)create {
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
    [self.splitView insertUtteranceAtPosition:insertAt];
    return utterance;
}

/// 刷新 utterance 对应的两个面板行
- (void)reloadRowForUtterance:(TSAIInterpreterUtteranceUI *)utterance {
    NSUInteger idx = [self.utterances indexOfObject:utterance];
    if (idx == NSNotFound) return;
    [self.splitView reloadUtteranceAtPosition:idx];
}

/// 结束卡：时长 / 句数 / 语言对 / TTS / 结束原因
- (void)presentReportSummary:(TSAIInterpreterReport *)report duration:(NSTimeInterval)duration {
    NSString *body = [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.report_body_fmt"),
                      duration,
                      (unsigned long)report.utterances.count,
                      [TSAIInterpreterFormatter displayNameForLanguage:report.sourceLanguage],
                      [TSAIInterpreterFormatter displayNameForLanguage:report.targetLanguage],
                      report.enableVoiceOutput ? @"On" : @"Off",
                      report.autoPlayVoice ? @"On" : @"Off",
                      [TSAIInterpreterFormatter displayNameForEndReason:report.endReason]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"ai_interpreter.report_title")
                                                                    message:body
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm")
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentAlertAboveAnything:alert];
}

/// 拾音设备展示名
- (NSString *)pickupTitleForRequest:(nullable TSAIInterpretationRequest *)request {
    switch (request.pickup) {
        case TSAIInterpretationPickupPhone: return TSLocalizedString(@"ai_interpreter.setup_pickup_phone");
        case TSAIInterpretationPickupEarbuds: return TSLocalizedString(@"ai_interpreter.setup_pickup_earbuds");
        case TSAIInterpretationPickupChargingCase: return TSLocalizedString(@"ai_interpreter.setup_pickup_case");
        default: return @"";
    }
}

#pragma mark - 私有方法 - 请求持久化

/// 读取上一次请求（只存拾音设备、语言、TTS、发音人）
- (nullable TSAIInterpretationRequest *)loadLastRequest {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kTSAIInterpreterLastRequestKey];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    TSAIInterpretationRequest *request =
        [TSAIInterpretationRequest requestWithSourceLanguage:[dict[@"source"] integerValue]
                                              targetLanguage:[dict[@"target"] integerValue]
                                                      pickup:[dict[@"pickup"] integerValue]];
    request.enableVoiceOutput = dict[@"voice"] != nil ? [dict[@"voice"] boolValue] : YES;
    request.speakerId = [dict[@"speaker"] isKindOfClass:[NSString class]] ? dict[@"speaker"] : nil;
    return request;
}

/// 保存本次请求
- (void)saveLastRequest:(TSAIInterpretationRequest *)request {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"source"] = @(request.sourceLanguage);
    dict[@"target"] = @(request.targetLanguage);
    dict[@"pickup"] = @(request.pickup);
    dict[@"voice"] = @(request.enableVoiceOutput);
    if (request.speakerId.length > 0) {
        dict[@"speaker"] = request.speakerId;
    }
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kTSAIInterpreterLastRequestKey];
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

- (TSAIInterpreterSplitView *)splitView {
    if (!_splitView) _splitView = [[TSAIInterpreterSplitView alloc] init];
    return _splitView;
}

- (TSAILogView *)logView {
    if (!_logView) _logView = [[TSAILogView alloc] init];
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
        [_micButton addTarget:self action:@selector(onMicButtonTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _micButton;
}

- (UIButton *)infoButton {
    if (!_infoButton) {
        _infoButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _infoButton.backgroundColor = [UIColor systemGray6Color];
        _infoButton.tintColor = [UIColor labelColor];
        UIImageSymbolConfiguration *cfg =
            [UIImageSymbolConfiguration configurationWithPointSize:18.0 weight:UIImageSymbolWeightRegular];
        [_infoButton setImage:[UIImage systemImageNamed:@"doc.text.magnifyingglass" withConfiguration:cfg]
                     forState:UIControlStateNormal];
        [_infoButton addTarget:self action:@selector(onInfoButtonTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _infoButton;
}

@end
