//
//  TSAIChatVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatVC.h"

#import "TSAIChatMicButton.h"
#import "TSAIChatRoundCell.h"
#import "TSAIChatConfigSheet.h"
#import "TSAIChatLogSheet.h"
#import "TSAIChatReportDialog.h"
#import "TSAIAudioPlayer.h"

#pragma mark - 状态机

typedef NS_ENUM(NSInteger, TSAIChatViewState) {
    /// 空闲（未启动会话） / Idle: no active session
    TSAIChatViewStateIdle        = 0,
    /// 聆听用户说话 / Listening to user speech
    TSAIChatViewStateListening   = 1,
    /// 等待 AI 回复 / Waiting for AI reply
    TSAIChatViewStateThinking    = 2,
    /// AI 回复播放中 / AI reply playing
    TSAIChatViewStateSpeaking    = 3,
    /// 已结束（待用户关闭报告或重新开始） / Ended; waiting for user to dismiss / restart
    TSAIChatViewStateEnded       = 4,
    /// 设备 SDK 不支持 / Not supported by current SDK
    TSAIChatViewStateUnsupported = 5,
};

#pragma mark - VC

@interface TSAIChatVC ()

// AI 助手实例
@property (nonatomic, strong, nullable) id<TSAIAssistantInterface> assistant;
// 当前会话 taskId（nil 表示无会话）
@property (nonatomic, copy, nullable) NSString *currentTaskId;
// 编辑后的 config（默认值）
@property (nonatomic, strong) TSAIChatConfig *config;
// 当前视图状态
@property (nonatomic, assign) TSAIChatViewState viewState;
// 已渲染的轮次 cell 缓存：roundIndex → Cell
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, TSAIChatRoundCell *> *roundCells;
// 最大已见 round 序号（用于报告 fallback）
@property (nonatomic, assign) NSInteger maxRoundIndex;
// 音频播放器
@property (nonatomic, strong) TSAIAudioPlayer *audioPlayer;
// 横幅自动消失定时器
@property (nonatomic, strong, nullable) NSTimer *bannerTimer;

// UI
@property (nonatomic, strong) UIView      *bannerView;
@property (nonatomic, strong) UILabel     *bannerLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *roundStack;
@property (nonatomic, strong) UIView      *emptyView;
@property (nonatomic, strong) UIView      *robotAvatarView;
@property (nonatomic, strong) UILabel     *robotEmojiLabel;
@property (nonatomic, strong) UILabel     *emptyTitleLabel;
@property (nonatomic, strong) UILabel     *emptySubLabel;
@property (nonatomic, strong) UIView      *footerView;
@property (nonatomic, strong) TSAIChatMicButton *micButton;
@property (nonatomic, strong) UILabel     *statusLabel;
@property (nonatomic, strong) UIButton    *logButton;

// 弹层
@property (nonatomic, weak, nullable) TSAIChatLogSheet *currentLogSheet;

@end

@implementation TSAIChatVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = @"AI Voice Chat";
    self.assistant = [[TopStepComKit sharedInstance] aiAssistant];
    self.config = [TSAIChatConfig defaultConfig];
    self.roundCells = [NSMutableDictionary dictionary];
    self.maxRoundIndex = -1;
    self.audioPlayer = [[TSAIAudioPlayer alloc] init];
    if (self.assistant && [self.assistant isSupport]) {
        self.viewState = TSAIChatViewStateIdle;
    } else {
        self.viewState = TSAIChatViewStateUnsupported;
    }
}

- (void)setupViews {
    [self.view addSubview:self.bannerView];
    [self.bannerView addSubview:self.bannerLabel];

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.roundStack];
    [self.scrollView addSubview:self.emptyView];
    [self.emptyView addSubview:self.robotAvatarView];
    [self.robotAvatarView addSubview:self.robotEmojiLabel];
    [self.emptyView addSubview:self.emptyTitleLabel];
    [self.emptyView addSubview:self.emptySubLabel];

    [self.view addSubview:self.footerView];
    [self.footerView addSubview:self.micButton];
    [self.footerView addSubview:self.statusLabel];
    [self.footerView addSubview:self.logButton];

    UIBarButtonItem *cfgItem = [[UIBarButtonItem alloc] initWithImage:[self gearImage]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(onConfigTapped)];
    self.navigationItem.rightBarButtonItem = cfgItem;

    [self setupConstraints];
    [self refreshUIForState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.currentTaskId.length > 0 && self.assistant) {
        [self.assistant stopChatWithTaskId:self.currentTaskId];
        self.currentTaskId = nil;
    }
    [self.audioPlayer stop];
}

- (void)dealloc {
    if (_currentTaskId.length > 0 && _assistant) {
        [_assistant stopChatWithTaskId:_currentTaskId];
    }
    [_audioPlayer stop];
    [_bannerTimer invalidate];
}

#pragma mark - 公开方法 / 状态机

- (void)setViewState:(TSAIChatViewState)viewState {
    _viewState = viewState;
    [self refreshUIForState];
}

/// 设备端 RequestStart：保证 view 已加载后启动会话
- (void)startSessionFromDevice {
    if (![self isViewLoaded]) {
        (void)[self view];
    }
    [self startSession];
}

/// 设备端 RequestEnd / Interrupted：以当前 taskId 调用 stopChatWithTaskId:
- (void)stopSessionFromDevice {
    [self stopSession];
}

#pragma mark - 私有方法 - 布局

- (void)setupConstraints {
    self.bannerView.translatesAutoresizingMaskIntoConstraints      = NO;
    self.bannerLabel.translatesAutoresizingMaskIntoConstraints     = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints      = NO;
    self.roundStack.translatesAutoresizingMaskIntoConstraints      = NO;
    self.emptyView.translatesAutoresizingMaskIntoConstraints       = NO;
    self.robotAvatarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.robotEmojiLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.emptyTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.emptySubLabel.translatesAutoresizingMaskIntoConstraints   = NO;
    self.footerView.translatesAutoresizingMaskIntoConstraints      = NO;
    self.micButton.translatesAutoresizingMaskIntoConstraints       = NO;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints     = NO;
    self.logButton.translatesAutoresizingMaskIntoConstraints       = NO;

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;

    [NSLayoutConstraint activateConstraints:@[
        // 顶部横幅
        [self.bannerView.topAnchor      constraintEqualToAnchor:safeArea.topAnchor],
        [self.bannerView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [self.bannerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.bannerLabel.topAnchor      constraintEqualToAnchor:self.bannerView.topAnchor      constant:10.f],
        [self.bannerLabel.bottomAnchor   constraintEqualToAnchor:self.bannerView.bottomAnchor   constant:-10.f],
        [self.bannerLabel.leadingAnchor  constraintEqualToAnchor:self.bannerView.leadingAnchor  constant:16.f],
        [self.bannerLabel.trailingAnchor constraintEqualToAnchor:self.bannerView.trailingAnchor constant:-16.f],

        // 底部 footer 高度固定 168（按钮 96 + 状态行 + log）
        [self.footerView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [self.footerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.footerView.bottomAnchor   constraintEqualToAnchor:safeArea.bottomAnchor],
        [self.footerView.heightAnchor   constraintEqualToConstant:170.f],

        [self.micButton.topAnchor     constraintEqualToAnchor:self.footerView.topAnchor constant:16.f],
        [self.micButton.centerXAnchor constraintEqualToAnchor:self.footerView.centerXAnchor],
        [self.micButton.widthAnchor   constraintEqualToConstant:96.f],
        [self.micButton.heightAnchor  constraintEqualToConstant:96.f],

        [self.statusLabel.topAnchor      constraintEqualToAnchor:self.micButton.bottomAnchor constant:8.f],
        [self.statusLabel.leadingAnchor  constraintEqualToAnchor:self.footerView.leadingAnchor  constant:16.f],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.footerView.trailingAnchor constant:-16.f],

        [self.logButton.trailingAnchor constraintEqualToAnchor:self.footerView.trailingAnchor constant:-16.f],
        [self.logButton.bottomAnchor   constraintEqualToAnchor:self.footerView.bottomAnchor   constant:-12.f],
        [self.logButton.heightAnchor   constraintEqualToConstant:30.f],

        // 中部滚动区
        [self.scrollView.topAnchor      constraintEqualToAnchor:self.bannerView.bottomAnchor],
        [self.scrollView.leadingAnchor  constraintEqualToAnchor:safeArea.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [self.scrollView.bottomAnchor   constraintEqualToAnchor:self.footerView.topAnchor],

        [self.roundStack.topAnchor      constraintEqualToAnchor:self.scrollView.topAnchor      constant:16.f],
        [self.roundStack.leadingAnchor  constraintEqualToAnchor:self.scrollView.leadingAnchor  constant:16.f],
        [self.roundStack.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-16.f],
        [self.roundStack.bottomAnchor   constraintEqualToAnchor:self.scrollView.bottomAnchor   constant:-16.f],
        [self.roundStack.widthAnchor    constraintEqualToAnchor:self.scrollView.widthAnchor    constant:-32.f],

        // 空态居中
        [self.emptyView.centerXAnchor constraintEqualToAnchor:self.scrollView.centerXAnchor],
        [self.emptyView.centerYAnchor constraintEqualToAnchor:self.scrollView.centerYAnchor],
        [self.emptyView.widthAnchor   constraintEqualToAnchor:self.scrollView.widthAnchor    constant:-64.f],

        // 圆形机器人头像（最顶部）
        [self.robotAvatarView.topAnchor      constraintEqualToAnchor:self.emptyView.topAnchor],
        [self.robotAvatarView.centerXAnchor  constraintEqualToAnchor:self.emptyView.centerXAnchor],
        [self.robotAvatarView.widthAnchor    constraintEqualToConstant:96.f],
        [self.robotAvatarView.heightAnchor   constraintEqualToConstant:96.f],

        [self.robotEmojiLabel.centerXAnchor  constraintEqualToAnchor:self.robotAvatarView.centerXAnchor],
        [self.robotEmojiLabel.centerYAnchor  constraintEqualToAnchor:self.robotAvatarView.centerYAnchor],

        [self.emptyTitleLabel.topAnchor      constraintEqualToAnchor:self.robotAvatarView.bottomAnchor constant:16.f],
        [self.emptyTitleLabel.leadingAnchor  constraintEqualToAnchor:self.emptyView.leadingAnchor],
        [self.emptyTitleLabel.trailingAnchor constraintEqualToAnchor:self.emptyView.trailingAnchor],

        [self.emptySubLabel.topAnchor      constraintEqualToAnchor:self.emptyTitleLabel.bottomAnchor constant:8.f],
        [self.emptySubLabel.leadingAnchor  constraintEqualToAnchor:self.emptyView.leadingAnchor],
        [self.emptySubLabel.trailingAnchor constraintEqualToAnchor:self.emptyView.trailingAnchor],
        [self.emptySubLabel.bottomAnchor   constraintEqualToAnchor:self.emptyView.bottomAnchor],
    ]];
}

- (UIImage *)gearImage {
    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:@"gearshape"];
    }
    return nil;
}

#pragma mark - 私有方法 - 状态刷新

- (void)refreshUIForState {
    switch (self.viewState) {
        case TSAIChatViewStateIdle:
            self.micButton.micState = TSAIChatMicButtonStateIdle;
            self.statusLabel.text = @"点击开始对话";
            self.statusLabel.textColor = TSColor_TextSecondary;
            self.emptyView.hidden = (self.roundCells.count > 0);
            self.micButton.userInteractionEnabled = YES;
            self.micButton.alpha = 1.f;
            break;
        case TSAIChatViewStateListening:
            self.micButton.micState = TSAIChatMicButtonStateListening;
            self.statusLabel.text = @"正在聆听…";
            self.statusLabel.textColor = TSColor_Primary;
            self.emptyView.hidden = YES;
            self.micButton.userInteractionEnabled = YES;
            self.micButton.alpha = 1.f;
            break;
        case TSAIChatViewStateThinking:
            self.micButton.micState = TSAIChatMicButtonStateThinking;
            self.statusLabel.text = @"思考中…";
            self.statusLabel.textColor = TSColor_Purple;
            self.emptyView.hidden = YES;
            self.micButton.userInteractionEnabled = YES;
            self.micButton.alpha = 1.f;
            break;
        case TSAIChatViewStateSpeaking:
            self.micButton.micState = TSAIChatMicButtonStateSpeaking;
            self.statusLabel.text = @"回复中…（开口可打断）";
            self.statusLabel.textColor = TSColor_Success;
            self.emptyView.hidden = YES;
            self.micButton.userInteractionEnabled = YES;
            self.micButton.alpha = 1.f;
            break;
        case TSAIChatViewStateEnded:
            self.micButton.micState = TSAIChatMicButtonStateIdle;
            self.statusLabel.text = @"会话已结束";
            self.statusLabel.textColor = TSColor_TextSecondary;
            self.micButton.userInteractionEnabled = YES;
            self.micButton.alpha = 1.f;
            break;
        case TSAIChatViewStateUnsupported:
            self.micButton.micState = TSAIChatMicButtonStateIdle;
            self.statusLabel.text = @"当前 SDK 不支持语音对话";
            self.statusLabel.textColor = TSColor_TextSecondary;
            self.emptyView.hidden = NO;
            self.micButton.userInteractionEnabled = NO;
            self.micButton.alpha = 0.4f;
            break;
    }
}

#pragma mark - 私有方法 - 会话生命周期

/// 会话开始：清空旧轮次缓存 / 调用 SDK / 注册回调
- (void)startSession {
    if (![self.assistant isSupport]) {
        TSLog(@"[TSAIChatVC] startSession aborted: assistant not supported");
        return;
    }
    if (self.currentTaskId.length > 0) {
        TSLog(@"[TSAIChatVC] startSession ignored: another session is running, taskId=%@", self.currentTaskId);
        return;
    }

    [self resetRoundsForNewSession];

    __weak typeof(self) weakSelf = self;
    NSString *taskId = [self.assistant startChatWithConfig:self.config
                                                 onContent:^(TSAIChatContent *content) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (![content.taskId isEqualToString:strongSelf.currentTaskId]) return;
            [strongSelf handleContent:content];
        });
    }
                                                   onEvent:^(TSAIChatEvent *event) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (![event.taskId isEqualToString:strongSelf.currentTaskId]) return;
            [strongSelf handleEvent:event];
        });
    }
                                                completion:^(TSAIChatReport * _Nullable report,
                                                             NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            NSString *cbTaskId = report.taskId ?: strongSelf.currentTaskId;
            if (cbTaskId.length > 0 && strongSelf.currentTaskId.length > 0
                && ![cbTaskId isEqualToString:strongSelf.currentTaskId]) return;
            [strongSelf handleCompletion:report error:error];
        });
    }];

    self.currentTaskId = taskId;
    TSLog(@"[TSAIChatVC] startSession: taskId=%@", taskId);
}

/// 会话主动结束（按钮触发）
- (void)stopSession {
    if (self.currentTaskId.length == 0) return;
    TSLog(@"[TSAIChatVC] stopSession: taskId=%@", self.currentTaskId);
    [self.assistant stopChatWithTaskId:self.currentTaskId];
}

/// 重置 round 显示（新会话开始时调用）
- (void)resetRoundsForNewSession {
    for (UIView *v in [self.roundStack.arrangedSubviews copy]) {
        [self.roundStack removeArrangedSubview:v];
        [v removeFromSuperview];
    }
    [self.roundCells removeAllObjects];
    self.maxRoundIndex = -1;
    [self.currentLogSheet clearAll];
    self.bannerView.hidden = YES;
    [self.audioPlayer stop];
}

#pragma mark - 私有方法 - 回调路由

- (void)handleContent:(TSAIChatContent *)content {
    TSAIChatRoundCell *cell = [self ensureRoundCellForIndex:content.roundIndex];
    if (content.roundIndex > self.maxRoundIndex) {
        self.maxRoundIndex = content.roundIndex;
    }

    [self.currentLogSheet appendContent:content];

    switch (content.contentType) {
        case TSAIChatContentTypeQuestion:
            [cell setQuestionText:content.text isFinal:content.isTextFinal];
            break;
        case TSAIChatContentTypeAnswer:
            [cell setAnswerText:content.text isFinal:content.isTextFinal];
            break;
        case TSAIChatContentTypeAudioChunk:
            if (content.audioChunk.length > 0) {
                [self.audioPlayer appendPCM:content.audioChunk];
            }
            break;
        case TSAIChatContentTypeIntent:
            if (content.intent) {
                [cell appendIntent:content.intent];
            }
            break;
        default:
            break;
    }

    [self scrollRoundsToBottom];
}

- (void)handleEvent:(TSAIChatEvent *)event {
    [self.currentLogSheet appendEvent:event];

    switch (event.eventType) {
        case TSAIChatEventTypeSessionStarted:
            self.viewState = TSAIChatViewStateListening;
            break;
        case TSAIChatEventTypeUserSpeechStarted:
            // 已在 Listening，保持
            self.viewState = TSAIChatViewStateListening;
            break;
        case TSAIChatEventTypeUserSpeechEnded:
            self.viewState = TSAIChatViewStateThinking;
            break;
        case TSAIChatEventTypeAIPlaybackStarted:
            self.viewState = TSAIChatViewStateSpeaking;
            break;
        case TSAIChatEventTypeAIPlaybackEnded:
            self.viewState = TSAIChatViewStateListening;
            break;
        case TSAIChatEventTypeAIPlaybackInterrupted:
            [self.audioPlayer stop];
            self.viewState = TSAIChatViewStateListening;
            break;
        case TSAIChatEventTypeNetworkError:
            [self showBanner:@"⚠️ 网络异常"];
            break;
        case TSAIChatEventTypeBleDisconnected:
            [self showBanner:@"⚠️ 设备已断开"];
            break;
        case TSAIChatEventTypeAutoEnding:
            [self showBanner:@"⏱ 无输入，会话即将结束"];
            break;
        default:
            break;
    }
}

- (void)handleCompletion:(TSAIChatReport * _Nullable)report error:(NSError * _Nullable)error {
    [self.audioPlayer stop];
    self.currentTaskId = nil;
    self.viewState = TSAIChatViewStateEnded;

    TSAIChatReport *finalReport = report ?: [self fallbackReportWithError:error];
    NSString *errMsg = error.localizedDescription;
    TSLog(@"[TSAIChatVC] session ended: reason=%ld, duration=%.1f, rounds=%ld, error=%@",
          (long)finalReport.endReason, finalReport.duration, (long)finalReport.roundCount,
          errMsg ?: @"nil");

    TSAIChatReportDialog *dialog = [[TSAIChatReportDialog alloc] initWithReport:finalReport
                                                                    errorMessage:errMsg];
    [self presentViewController:dialog animated:YES completion:nil];
}

/// 当 SDK 没回 report 时（极少见，例如 start 直接失败）兜底构造
- (TSAIChatReport *)fallbackReportWithError:(NSError *)error {
    TSAIChatReport *r = [[TSAIChatReport alloc] init];
    r.taskId = self.currentTaskId ?: @"";
    r.startTime = [NSDate date];
    r.endTime = [NSDate date];
    r.duration = 0;
    r.roundCount = self.maxRoundIndex < 0 ? 0 : (self.maxRoundIndex + 1);
    r.endReason = error ? TSAIChatEndReasonError : TSAIChatEndReasonUnknown;
    return r;
}

/// 拿到该 round 的 cell（无则创建）
- (TSAIChatRoundCell *)ensureRoundCellForIndex:(NSInteger)roundIndex {
    NSNumber *key = @(roundIndex);
    TSAIChatRoundCell *cell = self.roundCells[key];
    if (cell) return cell;

    cell = [[TSAIChatRoundCell alloc] init];
    cell.roundIndex = roundIndex;
    self.roundCells[key] = cell;
    [self.roundStack addArrangedSubview:cell];
    self.emptyView.hidden = YES;
    return cell;
}

- (void)scrollRoundsToBottom {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scrollView layoutIfNeeded];
        CGFloat bottomY = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
        if (bottomY > 0) {
            [self.scrollView setContentOffset:CGPointMake(0, bottomY) animated:YES];
        }
    });
}

#pragma mark - 私有方法 - 横幅

- (void)showBanner:(NSString *)text {
    self.bannerLabel.text = text;
    self.bannerView.hidden = NO;
    [self.bannerTimer invalidate];
    self.bannerTimer = [NSTimer scheduledTimerWithTimeInterval:4.0
                                                         target:self
                                                       selector:@selector(onBannerTimerFired)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)onBannerTimerFired {
    self.bannerView.hidden = YES;
    self.bannerTimer = nil;
}

#pragma mark - 事件

- (void)onMicTapped {
    switch (self.viewState) {
        case TSAIChatViewStateIdle:
        case TSAIChatViewStateEnded:
            [self startSession];
            break;
        case TSAIChatViewStateListening:
        case TSAIChatViewStateThinking:
        case TSAIChatViewStateSpeaking:
            [self stopSession];
            break;
        case TSAIChatViewStateUnsupported:
            // 不响应
            break;
    }
}

- (void)onConfigTapped {
    TSAIChatConfigSheet *sheet = [[TSAIChatConfigSheet alloc] initWithConfig:self.config];
    __weak typeof(self) weakSelf = self;
    sheet.onApply = ^(TSAIChatConfig *config) {
        weakSelf.config = config;
        TSLog(@"[TSAIChatVC] config applied: voice=%d interrupt=%d silence=%.2f timeout=%.0f",
              config.enableVoiceOutput, config.allowUserInterrupt,
              config.silenceBeforeReplyInterval, config.autoEndSessionTimeout);
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sheet];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)onLogTapped {
    if (self.currentLogSheet) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.currentLogSheet];
        [self presentViewController:nav animated:YES completion:nil];
        return;
    }
    TSAIChatLogSheet *sheet = [[TSAIChatLogSheet alloc] init];
    self.currentLogSheet = sheet;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sheet];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - 属性（懒加载）

- (UIView *)bannerView {
    if (!_bannerView) {
        _bannerView = [[UIView alloc] init];
        _bannerView.backgroundColor = [TSColor_Danger colorWithAlphaComponent:0.18f];
        _bannerView.hidden = YES;
    }
    return _bannerView;
}

- (UILabel *)bannerLabel {
    if (!_bannerLabel) {
        _bannerLabel = [[UILabel alloc] init];
        _bannerLabel.font = TSFont_Caption;
        _bannerLabel.textColor = TSColor_Danger;
        _bannerLabel.numberOfLines = 0;
    }
    return _bannerLabel;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.alwaysBounceVertical = YES;
    }
    return _scrollView;
}

- (UIStackView *)roundStack {
    if (!_roundStack) {
        _roundStack = [[UIStackView alloc] init];
        _roundStack.axis = UILayoutConstraintAxisVertical;
        _roundStack.alignment = UIStackViewAlignmentFill;
        _roundStack.spacing = 16.f;
    }
    return _roundStack;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] init];
    }
    return _emptyView;
}

- (UIView *)robotAvatarView {
    if (!_robotAvatarView) {
        _robotAvatarView = [[UIView alloc] init];
        _robotAvatarView.layer.cornerRadius = 48.f;
        _robotAvatarView.layer.masksToBounds = NO;
        // 蓝色光晕阴影
        _robotAvatarView.layer.shadowColor = [UIColor colorWithRed:59/255.f green:130/255.f blue:246/255.f alpha:0.35f].CGColor;
        _robotAvatarView.layer.shadowOffset = CGSizeMake(0, 8);
        _robotAvatarView.layer.shadowRadius = 20.f;
        _robotAvatarView.layer.shadowOpacity = 1.f;

        // 渐变背景层
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.colors = @[
            (__bridge id)[UIColor colorWithRed:219/255.f green:234/255.f blue:254/255.f alpha:1.f].CGColor,  // #dbeafe
            (__bridge id)[UIColor colorWithRed:191/255.f green:219/255.f blue:254/255.f alpha:1.f].CGColor,  // #bfdbfe
        ];
        gradient.startPoint = CGPointMake(0, 0);
        gradient.endPoint   = CGPointMake(1, 1);
        gradient.frame = CGRectMake(0, 0, 96, 96);
        gradient.cornerRadius = 48.f;
        [_robotAvatarView.layer addSublayer:gradient];
    }
    return _robotAvatarView;
}

- (UILabel *)robotEmojiLabel {
    if (!_robotEmojiLabel) {
        _robotEmojiLabel = [[UILabel alloc] init];
        _robotEmojiLabel.text = @"🤖";
        _robotEmojiLabel.font = [UIFont systemFontOfSize:40.f];
        _robotEmojiLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _robotEmojiLabel;
}

- (UILabel *)emptyTitleLabel {
    if (!_emptyTitleLabel) {
        _emptyTitleLabel = [[UILabel alloc] init];
        _emptyTitleLabel.font = TSFont_H2;
        _emptyTitleLabel.textColor = TSColor_TextPrimary;
        _emptyTitleLabel.textAlignment = NSTextAlignmentCenter;
        _emptyTitleLabel.text = @"点击下方按钮开始对话";
    }
    return _emptyTitleLabel;
}

- (UILabel *)emptySubLabel {
    if (!_emptySubLabel) {
        _emptySubLabel = [[UILabel alloc] init];
        _emptySubLabel.font = TSFont_Caption;
        _emptySubLabel.textColor = TSColor_TextSecondary;
        _emptySubLabel.textAlignment = NSTextAlignmentCenter;
        _emptySubLabel.numberOfLines = 0;
        _emptySubLabel.text = @"说话时请贴近设备麦克风\n支持多轮问答与语音打断";
    }
    return _emptySubLabel;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = TSColor_Background;
    }
    return _footerView;
}

- (TSAIChatMicButton *)micButton {
    if (!_micButton) {
        _micButton = [[TSAIChatMicButton alloc] init];
        __weak typeof(self) weakSelf = self;
        _micButton.onTap = ^{
            [weakSelf onMicTapped];
        };
    }
    return _micButton;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = TSFont_Body;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLabel;
}

- (UIButton *)logButton {
    if (!_logButton) {
        _logButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_logButton setTitle:@"日志" forState:UIControlStateNormal];
        _logButton.titleLabel.font = TSFont_Caption;
        [_logButton setTitleColor:TSColor_TextSecondary forState:UIControlStateNormal];
        _logButton.backgroundColor = [TSColor_TextSecondary colorWithAlphaComponent:0.12f];
        _logButton.layer.cornerRadius = 15.f;
        _logButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
        [_logButton addTarget:self
                       action:@selector(onLogTapped)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _logButton;
}

@end
