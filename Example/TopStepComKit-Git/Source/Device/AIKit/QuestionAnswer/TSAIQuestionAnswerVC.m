//
//  TSAIQuestionAnswerVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQuestionAnswerVC.h"

#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepAIKit/TSAIDeviceCoordination.h>
#import <TopStepAIKit/TSAIStartEligibility.h>
#import <TopStepAIKit/TSAIStartRequest.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSAIAudioRecordAppCapture.h"
#import "TSAIQABadgeLabel.h"
#import "TSAIQAComposerView.h"
#import "TSAIQADeviceActionBar.h"
#import "TSAIQADeviceRound.h"
#import "TSAIQADeviceRoundCell.h"
#import "TSAIQADeviceSessionCoordinator.h"
#import "TSAIQADeviceStatusView.h"
#import "TSAIQAEmptyStateView.h"
#import "TSAIQALogSheet.h"
#import "TSAIQASpeechPlayer.h"
#import "TSAIQATextRound.h"
#import "TSAIQATextRoundCell.h"
#import "TSAIQATheme.h"
#import "TSAIQAVoiceCapture.h"

static const NSTimeInterval kTSAIQAPlaybackPollInterval = 0.6;
static const NSTimeInterval kTSAIQAPlaybackPollWindow = 30.0;
static const NSTimeInterval kTSAIQAListeningTickInterval = 0.25;

@interface TSAIQuestionAnswerVC () <UITableViewDataSource, UITableViewDelegate,
                                    TSAIQATextRoundCellDelegate, TSAIQAEmptyStateViewDelegate,
                                    TSAIQAComposerViewDelegate, TSAIQADeviceStatusViewDelegate,
                                    TSAIQADeviceActionBarDelegate, TSAIQAVoiceCaptureDelegate>

// 当前拾音方式
@property (nonatomic, assign, readwrite) TSAIQAInputMode inputMode;
// 设备协同问答协调器（手表拾音）
@property (nonatomic, strong) TSAIQADeviceSessionCoordinator *coordinator;
// 手机 / 耳机拾音
@property (nonatomic, strong) TSAIQAVoiceCapture *voiceCapture;
// 手机播报
@property (nonatomic, strong) TSAIQASpeechPlayer *speechPlayer;
// 手机 / 耳机模式是否播报答案
@property (nonatomic, assign) BOOL phoneSpeechEnabled;
// 轮次列表：TSAIQATextRound（文字 / 手机 / 耳机）与 TSAIQADeviceRound（手表）混排
@property (nonatomic, strong) NSMutableArray *roundItems;
// 进行中的 askQuestion 任务标识
@property (nonatomic, copy, nullable) NSString *currentTextTaskId;
// 进行中的语音轮次（拾音 / 识别阶段）
@property (nonatomic, strong, nullable) TSAIQATextRound *voiceRound;
// 键盘遮挡高度
@property (nonatomic, assign) CGFloat keyboardOverlap;
// 播放条轮询定时器（手表）
@property (nonatomic, strong, nullable) NSTimer *playbackTimer;
// 拾音计时定时器（手机 / 耳机）
@property (nonatomic, strong, nullable) NSTimer *listeningTimer;
// 已弹出的日志弹层
@property (nonatomic, weak, nullable) TSAIQALogSheet *presentedLogSheet;

// 拾音方式分段
@property (nonatomic, strong) UISegmentedControl *modeSegment;
// 状态栏：智能体 chip + 状态徽标
@property (nonatomic, strong) UIButton *agentChipButton;
@property (nonatomic, strong) TSAIQABadgeLabel *statusBadge;
// 轮次列表
@property (nonatomic, strong) UITableView *roundTableView;
// 表头
@property (nonatomic, strong) TSAIQAEmptyStateView *emptyStateView;
@property (nonatomic, strong) TSAIQADeviceStatusView *deviceStatusView;
// 底部
@property (nonatomic, strong) TSAIQAComposerView *composerView;
@property (nonatomic, strong) TSAIQADeviceActionBar *deviceActionBar;

@end

@implementation TSAIQuestionAnswerVC

#pragma mark - 生命周期

- (instancetype)initWithInputMode:(TSAIQAInputMode)inputMode {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _inputMode = inputMode;
    }
    return self;
}

- (void)initData {
    [super initData];
    self.title = @"AI Q&A";
    self.coordinator = [TSAIQADeviceSessionCoordinator sharedInstance];
    self.voiceCapture = [[TSAIQAVoiceCapture alloc] init];
    self.voiceCapture.delegate = self;
    self.speechPlayer = [[TSAIQASpeechPlayer alloc] init];
    self.phoneSpeechEnabled = YES;
    self.roundItems = [NSMutableArray array];
    // 进入页面前手表已经发起过的轮次也显示出来
    [self.roundItems addObjectsFromArray:self.coordinator.rounds];
    self.view.backgroundColor = TSAIQAPageBackgroundColor();
}

- (void)setupViews {
    [self.view addSubview:self.roundTableView];
    [self.view addSubview:self.modeSegment];
    [self.view addSubview:self.agentChipButton];
    [self.view addSubview:self.statusBadge];
    [self.view addSubview:self.composerView];
    [self.view addSubview:self.deviceActionBar];

    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain
                                        target:self action:@selector(onSettingsTapped)],
        [[UIBarButtonItem alloc] initWithTitle:@"日志" style:UIBarButtonItemStylePlain
                                        target:self action:@selector(onLogTapped)],
    ];

    [self registerObservers];
    [self applyInputMode];
}

- (void)layoutViews {
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) {
        topOffset = self.view.safeAreaInsets.top;
    }
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat bottomSafe = self.view.safeAreaInsets.bottom;

    self.modeSegment.frame = CGRectMake(16.0, topOffset + 6.0, width - 32.0, 36.0);
    CGFloat chipY = topOffset + 50.0;
    CGSize chipSize = [self.agentChipButton sizeThatFits:CGSizeMake(width, 28.0)];
    self.agentChipButton.frame = CGRectMake(16.0, chipY, MIN(chipSize.width + 24.0, width - 140.0), 28.0);
    CGSize badgeSize = [self.statusBadge intrinsicContentSize];
    self.statusBadge.frame = CGRectMake(width - 16.0 - badgeSize.width, chipY + 3.0, badgeSize.width, badgeSize.height);
    CGFloat tableTop = chipY + 28.0 + 8.0;

    CGFloat bottomBarTop = height;
    if (self.inputMode == TSAIQAInputModeText) {
        CGFloat contentHeight = [self.composerView contentHeight];
        CGFloat inset = self.keyboardOverlap > 0 ? 0 : bottomSafe;
        CGFloat composerHeight = contentHeight + inset;
        bottomBarTop = height - self.keyboardOverlap - composerHeight;
        self.composerView.frame = CGRectMake(0, bottomBarTop, width, composerHeight);
    } else {
        CGFloat barHeight = [TSAIQADeviceActionBar contentHeight] + bottomSafe;
        bottomBarTop = height - barHeight;
        self.deviceActionBar.frame = CGRectMake(0, bottomBarTop, width, barHeight);
    }
    self.roundTableView.frame = CGRectMake(0, tableTop, width, MAX(0, bottomBarTop - tableTop));
    [self layoutTableHeader];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.composerView dismissKeyboard];
    // 离开页面：取消 App 侧进行中的任务，避免 VC 销毁后回调悬挂；手表轮次由协调器继续持有
    if (self.currentTextTaskId.length > 0) {
        [self cancelCurrentTextTask];
    }
    if (self.voiceCapture.state != TSAIQAVoiceCaptureStateIdle) {
        [self.voiceCapture cancel];
    }
    [self.speechPlayer stop];
}

- (void)dealloc {
    [_playbackTimer invalidate];
    [_listeningTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 公开方法

/** 以代码切换拾音方式 */
- (void)switchToInputMode:(TSAIQAInputMode)inputMode {
    if (self.inputMode == inputMode) {
        return;
    }
    self.inputMode = inputMode;
    [self applyInputMode];
}

#pragma mark - 私有方法 - 模式与状态

/** 注册通知 */
- (void)registerObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onSessionDidChange:)
                   name:TSAIQADeviceSessionDidChangeNotification object:self.coordinator];
    [center addObserver:self selector:@selector(onSessionDidUpdateRound:)
                   name:TSAIQADeviceSessionDidUpdateRoundNotification object:self.coordinator];
    [center addObserver:self selector:@selector(onSessionDidRequestPresentation:)
                   name:TSAIQADeviceSessionDidRequestPresentationNotification object:self.coordinator];
    [center addObserver:self selector:@selector(onSessionDidAppendLog:)
                   name:TSAIQADeviceSessionDidAppendLogNotification object:self.coordinator];
    [center addObserver:self selector:@selector(onKeyboardWillChangeFrame:)
                   name:UIKeyboardWillChangeFrameNotification object:nil];
}

/** 按当前拾音方式切换底部区域并刷新 */
- (void)applyInputMode {
    BOOL isText = (self.inputMode == TSAIQAInputModeText);
    self.modeSegment.selectedSegmentIndex = (NSInteger)self.inputMode;
    self.composerView.hidden = !isText;
    self.deviceActionBar.hidden = isText;
    if (!isText) {
        [self.composerView dismissKeyboard];
    }
    [self refreshStatus];
    [self layoutViews];
    [self scrollToBottomAnimated:NO];
    [self updatePlaybackPolling];
}

/** 刷新状态徽标、表头与底部区域 */
- (void)refreshStatus {
    [self.agentChipButton setTitle:[NSString stringWithFormat:@"智能体 · %@",
                                    [self titleForAgent:self.coordinator.config.agent]]
                          forState:UIControlStateNormal];
    switch (self.inputMode) {
        case TSAIQAInputModeText:
            [self refreshTextStatus];
            break;
        case TSAIQAInputModePhoneMic:
        case TSAIQAInputModeHeadset:
            [self refreshPhoneVoiceStatus];
            break;
        case TSAIQAInputModeWatch:
            [self refreshWatchStatus];
            break;
    }
    [self layoutViews];
}

/** 文字模式 */
- (void)refreshTextStatus {
    BOOL streaming = (self.currentTextTaskId.length > 0);
    BOOL available = ([self questionAnswerInterface] != nil);
    NSError *serviceError = available ? [self textEligibilityError] : nil;
    BOOL supported = available && serviceError == nil;
    if (streaming) {
        [self.statusBadge applyText:@"回答中" style:TSAIQABadgeStyleLive];
    } else if (!available) {
        [self.statusBadge applyText:@"Context 未激活" style:TSAIQABadgeStyleWarning];
    } else if (!supported) {
        [self.statusBadge applyText:@"服务不支持" style:TSAIQABadgeStyleDanger];
    } else if (self.roundItems.count > 0) {
        [self.statusBadge applyText:[NSString stringWithFormat:@"%lu 轮 · 空闲", (unsigned long)self.roundItems.count]
                              style:TSAIQABadgeStyleIdle];
    } else {
        [self.statusBadge applyText:@"空闲" style:TSAIQABadgeStyleIdle];
    }
    self.composerView.streaming = streaming;
    self.composerView.inputEnabled = supported;
    if (streaming) {
        self.composerView.hint = @"取消为逻辑取消：completion 将以 error 终态回调一次，后续回调被丢弃";
    } else if (!available) {
        self.composerView.hint = @"AI Context 未激活或设备未连接，无法发起问答";
    } else if (!supported) {
        self.composerView.hint = [NSString stringWithFormat:@"服务不支持问答 · %@",
                                  [self readableEligibilityError:serviceError]];
    } else {
        self.composerView.hint = nil;
    }
    self.emptyStateView.suggestionsEnabled = supported;
}

/** 手机 / 耳机模式 */
- (void)refreshPhoneVoiceStatus {
    BOOL isHeadset = (self.inputMode == TSAIQAInputModeHeadset);
    TSAIQAVoiceCaptureState captureState = self.voiceCapture.state;
    BOOL answering = (self.currentTextTaskId.length > 0);
    BOOL speaking = self.speechPlayer.isBusy;
    BOOL available = ([self questionAnswerInterface] != nil);
    NSError *serviceError = available ? [self textEligibilityError] : nil;
    BOOL speechAvailable = ([self speechInterface] != nil);
    BOOL supported = available && serviceError == nil && speechAvailable;

    // 徽标
    if (captureState == TSAIQAVoiceCaptureStateListening) {
        [self.statusBadge applyText:@"聆听中" style:TSAIQABadgeStyleLive];
    } else if (captureState == TSAIQAVoiceCaptureStateRecognizing) {
        [self.statusBadge applyText:@"识别中" style:TSAIQABadgeStyleLive];
    } else if (answering) {
        [self.statusBadge applyText:@"回答中" style:TSAIQABadgeStyleLive];
    } else if (speaking) {
        [self.statusBadge applyText:@"播报中" style:TSAIQABadgeStyleLive];
    } else if (!available) {
        [self.statusBadge applyText:@"Context 未激活" style:TSAIQABadgeStyleWarning];
    } else if (!supported) {
        [self.statusBadge applyText:@"不可用" style:TSAIQABadgeStyleDanger];
    } else {
        [self.statusBadge applyText:@"就绪" style:TSAIQABadgeStyleSuccess];
    }

    // 表头
    NSString *inputTitle = isHeadset ? @"蓝牙耳机 (HFP)" : @"手机麦克风";
    NSString *outputTitle = self.phoneSpeechEnabled ? @"手机播报" : @"不播报";
    self.deviceStatusView.inputRouteTitle = inputTitle;
    self.deviceStatusView.outputRouteTitle = outputTitle;
    self.deviceStatusView.routeLocked = (captureState != TSAIQAVoiceCaptureStateIdle || answering);
    self.deviceStatusView.routeHint = [NSString stringWithFormat:
        @"纯 App 路径，不经过手表：%@ 采集 16 kHz PCM → recognizeSpeechWithPCMData: → askQuestion: → %@。",
        inputTitle, self.phoneSpeechEnabled ? @"synthesizeSpeechWithText: 在手机播放" : @"仅显示文字"];
    self.deviceStatusView.sessionIdentifier = nil;
    TSAIQATimelineStep step = TSAIQATimelineStepNotStarted;
    BOOL failed = NO;
    if (captureState == TSAIQAVoiceCaptureStateListening || captureState == TSAIQAVoiceCaptureStateRecognizing) {
        step = TSAIQATimelineStepQuestion;
    } else if (answering || speaking) {
        step = TSAIQATimelineStepAnswer;
    } else if (supported) {
        TSAIQATextRound *last = [self lastTextRound];
        if (last.state == TSAIQATextRoundStateCompleted) {
            step = TSAIQATimelineStepCompleted;
        } else if (last.state == TSAIQATextRoundStateFailed) {
            step = last.answer.length > 0 ? TSAIQATimelineStepAnswer : TSAIQATimelineStepQuestion;
            failed = YES;
        } else {
            step = TSAIQATimelineStepArmed;
        }
    }
    self.deviceStatusView.timelineStep = step;
    self.deviceStatusView.timelineFailed = failed;
    if (self.roundItems.count > 0) {
        self.deviceStatusView.heroMode = TSAIQADeviceHeroModeHidden;
    } else if (captureState == TSAIQAVoiceCaptureStateListening) {
        self.deviceStatusView.heroMode = TSAIQADeviceHeroModeListening;
        self.deviceStatusView.heroTitle = [NSString stringWithFormat:@"正在聆听 · %.1fs", self.voiceCapture.capturedDuration];
        self.deviceStatusView.heroSubtitle = @"说完后点击底部按钮结束，PCM 会一次性交给语音识别。";
    } else {
        self.deviceStatusView.heroMode = TSAIQADeviceHeroModeIdle;
        self.deviceStatusView.heroTitle = isHeadset ? @"用蓝牙耳机提问" : @"对着手机提问";
        self.deviceStatusView.heroSubtitle = @"点击底部按钮开始拾音，再次点击结束并识别；答案流式显示，可选在手机播报。";
    }
    [self.deviceStatusView refresh];

    // 底部
    BOOL listening = (captureState == TSAIQAVoiceCaptureStateListening);
    self.deviceActionBar.armed = listening || answering;
    self.deviceActionBar.busy = (captureState == TSAIQAVoiceCaptureStateRecognizing);
    self.deviceActionBar.primaryEnabled = supported || answering;
    self.deviceActionBar.inputRouteTitle = inputTitle;
    self.deviceActionBar.outputRouteTitle = outputTitle;
    if (listening) {
        self.deviceActionBar.caption = [NSString stringWithFormat:@"聆听中 %.1fs · 点击结束并识别", self.voiceCapture.capturedDuration];
    } else if (captureState == TSAIQAVoiceCaptureStateRecognizing) {
        self.deviceActionBar.caption = @"识别中 · recognizeSpeechWithPCMData:";
    } else if (answering) {
        self.deviceActionBar.caption = @"回答中 · askQuestion: 流式返回 · 点击停止（逻辑取消）";
    } else if (!available) {
        self.deviceActionBar.caption = @"AI Context 未激活或设备未连接";
    } else if (serviceError) {
        self.deviceActionBar.caption = [NSString stringWithFormat:@"服务不支持问答 · %@",
                                        [self readableEligibilityError:serviceError]];
    } else if (!speechAvailable) {
        self.deviceActionBar.caption = @"Speech 接口不可用，无法识别语音";
    } else {
        self.deviceActionBar.caption = [NSString stringWithFormat:@"点击开始 · %@ 拾音", inputTitle];
    }
    [self updateListeningTimer];
}

/** 手表模式 */
- (void)refreshWatchStatus {
    TSAIQADeviceSessionState state = self.coordinator.state;
    TSAIQADeviceRound *activeRound = [self.coordinator activeRound];
    TSAIQADeviceRound *lastRound = self.coordinator.rounds.lastObject;
    NSError *appEligibility = (state == TSAIQADeviceSessionStateRegistered)
        ? [self.coordinator deviceRoundEligibilityErrorForInitiator:TSAISessionInitiatorApp]
        : nil;

    // 徽标
    switch (state) {
        case TSAIQADeviceSessionStateUnbound:
            [self.statusBadge applyText:@"未连接 / 未鉴权" style:TSAIQABadgeStyleWarning];
            break;
        case TSAIQADeviceSessionStateUnsupported:
            [self.statusBadge applyText:@"不可用" style:TSAIQABadgeStyleDanger];
            break;
        case TSAIQADeviceSessionStateRegistered:
            if (appEligibility) {
                [self.statusBadge applyText:@"手表不支持" style:TSAIQABadgeStyleDanger];
            } else {
                [self.statusBadge applyText:@"已注册 · 就绪" style:TSAIQABadgeStyleSuccess];
            }
            break;
        case TSAIQADeviceSessionStatePreparing:
            [self.statusBadge applyText:@"准备中" style:TSAIQABadgeStyleLive];
            break;
        case TSAIQADeviceSessionStateListening:
            [self.statusBadge applyText:@"手表拾音中" style:TSAIQABadgeStyleLive];
            break;
        case TSAIQADeviceSessionStateAnswering:
            [self.statusBadge applyText:activeRound.phase == TSAIDeviceQuestionAnswerPhaseAnswer ? @"回答中" : @"识别中"
                                  style:TSAIQABadgeStyleLive];
            break;
        case TSAIQADeviceSessionStateStopping:
            [self.statusBadge applyText:@"停止中" style:TSAIQABadgeStyleLive];
            break;
    }

    // 表头
    TSAIAudioRouteConfiguration *route = [TSAIQADeviceSessionCoordinator resolvedDeviceRouteForConfig:self.coordinator.config];
    NSString *inputTitle = [self titleForInputChannel:route.inputChannel];
    NSString *outputTitle = [self titleForOutputChannel:route.outputChannel];
    BOOL inRound = (state == TSAIQADeviceSessionStatePreparing || state == TSAIQADeviceSessionStateListening ||
                    state == TSAIQADeviceSessionStateAnswering || state == TSAIQADeviceSessionStateStopping);
    self.deviceStatusView.inputRouteTitle = inputTitle;
    self.deviceStatusView.outputRouteTitle = outputTitle;
    self.deviceStatusView.routeLocked = inRound;
    self.deviceStatusView.routeHint = [NSString stringWithFormat:
        @"问题由「%@」采集（FitCloud App 发起固定 Opus）；回答文字在手机显示并回写手表，TTS 由路由 Driver 在「%@」播放。",
        inputTitle, outputTitle];
    self.deviceStatusView.sessionIdentifier = self.coordinator.sessionIdentifier ?: self.coordinator.currentRequest.requestIdentifier;
    [self applyWatchTimelineForState:state activeRound:activeRound lastRound:lastRound];
    [self applyWatchHeroForState:state appEligibility:appEligibility];
    [self.deviceStatusView refresh];

    // 底部
    self.deviceActionBar.armed = inRound;
    self.deviceActionBar.busy = (state == TSAIQADeviceSessionStatePreparing || state == TSAIQADeviceSessionStateStopping);
    self.deviceActionBar.primaryEnabled = (state == TSAIQADeviceSessionStateRegistered && appEligibility == nil) || inRound;
    self.deviceActionBar.inputRouteTitle = inputTitle;
    self.deviceActionBar.outputRouteTitle = outputTitle;
    switch (state) {
        case TSAIQADeviceSessionStateUnbound:
            self.deviceActionBar.caption = @"设备未连接或 AI 鉴权未完成";
            break;
        case TSAIQADeviceSessionStateUnsupported:
            self.deviceActionBar.caption = @"问答接口不可用";
            break;
        case TSAIQADeviceSessionStateRegistered:
            if (appEligibility) {
                self.deviceActionBar.caption = [NSString stringWithFormat:@"手表不支持 App 发起问答 · %@",
                                                [self readableEligibilityError:appEligibility]];
            } else if (self.coordinator.lastError) {
                self.deviceActionBar.caption = [NSString stringWithFormat:@"上次失败 · %@ · 点击重试",
                                                [self readableError:self.coordinator.lastError]];
            } else {
                self.deviceActionBar.caption = @"点击开始 · startDeviceAISessionFromAppWithRequest:（手表拾音）";
            }
            break;
        case TSAIQADeviceSessionStatePreparing:
            self.deviceActionBar.caption = self.coordinator.origin == TSAIQADeviceSessionOriginDevice
                ? @"手表发起 · 本地准备中（startDeviceQuestionAnswer）"
                : @"准备中 · 等待本地配置与手表同步";
            break;
        case TSAIQADeviceSessionStateListening:
            self.deviceActionBar.caption = @"手表拾音中 · 点击停止 stopDeviceAISessionWithRequest:";
            break;
        case TSAIQADeviceSessionStateAnswering:
            self.deviceActionBar.caption = @"拾音结束 · 等待识别、回答与播报 · 点击可中止";
            break;
        case TSAIQADeviceSessionStateStopping:
            self.deviceActionBar.caption = @"停止中";
            break;
    }
}

/** 手表模式时间线 */
- (void)applyWatchTimelineForState:(TSAIQADeviceSessionState)state
                       activeRound:(TSAIQADeviceRound *)activeRound
                         lastRound:(TSAIQADeviceRound *)lastRound {
    TSAIQATimelineStep step = TSAIQATimelineStepNotStarted;
    BOOL failed = NO;
    switch (state) {
        case TSAIQADeviceSessionStateRegistered:
            step = TSAIQATimelineStepArmed;
            if (lastRound.phase == TSAIDeviceQuestionAnswerPhaseCompleted) {
                step = TSAIQATimelineStepCompleted;
            } else if (lastRound.phase == TSAIDeviceQuestionAnswerPhaseFailed) {
                step = lastRound.answer.length > 0 ? TSAIQATimelineStepAnswer : TSAIQATimelineStepQuestion;
                failed = YES;
            }
            break;
        case TSAIQADeviceSessionStatePreparing:
            step = TSAIQATimelineStepArmed;
            break;
        case TSAIQADeviceSessionStateListening:
            step = TSAIQATimelineStepQuestion;
            break;
        case TSAIQADeviceSessionStateAnswering:
        case TSAIQADeviceSessionStateStopping:
            step = activeRound.phase == TSAIDeviceQuestionAnswerPhaseAnswer
                ? TSAIQATimelineStepAnswer : TSAIQATimelineStepQuestion;
            break;
        default:
            break;
    }
    self.deviceStatusView.timelineStep = step;
    self.deviceStatusView.timelineFailed = failed;
}

/** 手表模式主视觉区 */
- (void)applyWatchHeroForState:(TSAIQADeviceSessionState)state appEligibility:(NSError *)appEligibility {
    if (self.roundItems.count > 0) {
        self.deviceStatusView.heroMode = TSAIQADeviceHeroModeHidden;
        return;
    }
    switch (state) {
        case TSAIQADeviceSessionStateListening:
            self.deviceStatusView.heroMode = TSAIQADeviceHeroModeListening;
            self.deviceStatusView.heroTitle = @"手表正在拾音";
            self.deviceStatusView.heroSubtitle = @"对着手表说话；问题与答案的累计文字快照会实时显示在这里。";
            break;
        case TSAIQADeviceSessionStatePreparing:
        case TSAIQADeviceSessionStateAnswering:
            self.deviceStatusView.heroMode = TSAIQADeviceHeroModeListening;
            self.deviceStatusView.heroTitle = state == TSAIQADeviceSessionStatePreparing ? @"正在准备" : @"正在识别与回答";
            self.deviceStatusView.heroSubtitle = @"AIKit 负责 ASR、答案生成与 TTS，App 只观察 onEvent。";
            break;
        case TSAIQADeviceSessionStateUnbound:
            self.deviceStatusView.heroMode = TSAIQADeviceHeroModeIdle;
            self.deviceStatusView.heroTitle = @"设备未连接";
            self.deviceStatusView.heroSubtitle = @"连接手表并完成 AI 鉴权后，问答路由会自动注册。";
            break;
        case TSAIQADeviceSessionStateUnsupported:
            self.deviceStatusView.heroMode = TSAIQADeviceHeroModeIdle;
            self.deviceStatusView.heroTitle = @"问答接口不可用";
            self.deviceStatusView.heroSubtitle = @"Context 未提供 questionAnswer 接口。";
            break;
        default:
            self.deviceStatusView.heroMode = TSAIQADeviceHeroModeIdle;
            if (appEligibility) {
                self.deviceStatusView.heroTitle = @"手表不支持 App 发起问答";
                self.deviceStatusView.heroSubtitle = [self readableEligibilityError:appEligibility];
            } else {
                self.deviceStatusView.heroTitle = @"手表拾音问答";
                self.deviceStatusView.heroSubtitle = @"点击开始由 App 发起一轮，手表进入问答并拾音；也可直接在手表上发起（需固件声明 0x24）。";
            }
            break;
    }
}

/** 按模式与数据决定表头并布局 */
- (void)layoutTableHeader {
    CGFloat width = CGRectGetWidth(self.roundTableView.bounds);
    UIView *header = nil;
    CGFloat headerHeight = 0;
    if (self.inputMode == TSAIQAInputModeText) {
        if (self.roundItems.count == 0) {
            header = self.emptyStateView;
            headerHeight = [TSAIQAEmptyStateView heightForWidth:width
                                                suggestionCount:self.emptyStateView.suggestions.count];
        }
    } else {
        header = self.deviceStatusView;
        headerHeight = [TSAIQADeviceStatusView heightForWidth:width heroMode:self.deviceStatusView.heroMode];
    }
    if (!header) {
        if (self.roundTableView.tableHeaderView) {
            self.roundTableView.tableHeaderView = nil;
        }
        return;
    }
    header.frame = CGRectMake(0, 0, width, headerHeight);
    if (self.roundTableView.tableHeaderView != header ||
        fabs(CGRectGetHeight(self.roundTableView.tableHeaderView.bounds) - headerHeight) > 0.5) {
        self.roundTableView.tableHeaderView = header;
    } else {
        [header setNeedsLayout];
    }
}

/** 滚动到底部 */
- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger rows = [self.roundTableView numberOfRowsInSection:0];
    if (rows <= 0) {
        return;
    }
    [self.roundTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                               atScrollPosition:UITableViewScrollPositionBottom
                                       animated:animated];
}

/** 当前问答接口 */
- (id<TSAIQuestionAnswerInterface>)questionAnswerInterface {
    return [self.coordinator questionAnswerInterface] ?: [TSAIKit sharedInstance].activeContext.questionAnswer;
}

/** 当前语音接口 */
- (id<TSAISpeechInterface>)speechInterface {
    return [TSAIKit sharedInstance].activeContext.speech;
}

/** 最近一轮 App 侧轮次 */
- (TSAIQATextRound *)lastTextRound {
    for (id item in self.roundItems.reverseObjectEnumerator) {
        if ([item isKindOfClass:[TSAIQATextRound class]]) {
            return item;
        }
    }
    return nil;
}

#pragma mark - 私有方法 - 轮次列表

/** 追加轮次并刷新列表 */
- (void)appendRoundItem:(id)item {
    [self.roundItems addObject:item];
    [self.roundTableView reloadData];
    [self refreshStatus];
    [self scrollToBottomAnimated:YES];
}

/** 就地刷新某一轮卡片 */
- (void)refreshRoundItem:(id)item {
    NSUInteger index = [self.roundItems indexOfObjectIdenticalTo:item];
    if (index == NSNotFound) {
        return;
    }
    NSInteger currentRows = [self.roundTableView numberOfRowsInSection:0];
    if ((NSInteger)self.roundItems.count != currentRows) {
        [self.roundTableView reloadData];
        [self scrollToBottomAnimated:YES];
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)index inSection:0];
    UITableViewCell *cell = [self.roundTableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        [self configureCell:cell withItem:item];
        [UIView performWithoutAnimation:^{
            [self.roundTableView beginUpdates];
            [self.roundTableView endUpdates];
        }];
    } else {
        [self.roundTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    if (index == self.roundItems.count - 1) {
        [self scrollToBottomAnimated:NO];
    }
}

/** 按轮次类型绑定 cell */
- (void)configureCell:(UITableViewCell *)cell withItem:(id)item {
    if ([cell isKindOfClass:[TSAIQATextRoundCell class]] && [item isKindOfClass:[TSAIQATextRound class]]) {
        [(TSAIQATextRoundCell *)cell applyRound:item];
    } else if ([cell isKindOfClass:[TSAIQADeviceRoundCell class]] && [item isKindOfClass:[TSAIQADeviceRound class]]) {
        [(TSAIQADeviceRoundCell *)cell applyRound:item playbackText:[self playbackTextForRound:item]];
    }
}

#pragma mark - 私有方法 - askQuestion（文字 / 手机 / 耳机共用）

/** 文字输入提交 */
- (void)submitQuestion:(NSString *)question {
    NSString *trimmed = [question stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmed.length == 0) {
        return;
    }
    if (self.currentTextTaskId.length > 0) {
        [self showAlertWithMsg:@"上一题仍在回答中，请先停止或等待完成"];
        return;
    }
    if (![self questionAnswerInterface]) {
        [self showAlertWithMsg:@"AI Context 未激活，请先连接设备并完成鉴权"];
        return;
    }
    NSError *serviceError = [self textEligibilityError];
    if (serviceError) {
        [self showAlertWithMsg:[NSString stringWithFormat:@"服务不支持问答\n%@", [self readableEligibilityError:serviceError]]];
        return;
    }
    [self.composerView dismissKeyboard];
    self.composerView.text = @"";
    TSAIQATextRound *round = [TSAIQATextRound roundWithQuestion:trimmed taskId:@""];
    [self appendRoundItem:round];
    [self runQuestion:trimmed round:round];
}

/** 对某一轮执行 askQuestion；语音轮次在识别完成后也走这里 */
- (void)runQuestion:(NSString *)question round:(TSAIQATextRound *)round {
    id<TSAIQuestionAnswerInterface> questionAnswer = [self questionAnswerInterface];
    if (!questionAnswer) {
        [round finishWithState:TSAIQATextRoundStateFailed
                         error:[NSError errorWithDomain:TSAIErrorDomain code:TSAIErrorCodeContextInactive
                                               userInfo:@{NSLocalizedDescriptionKey: @"AI Context 未激活"}]];
        [self refreshRoundItem:round];
        [self refreshStatus];
        return;
    }
    round.question = question;
    round.state = TSAIQATextRoundStatePending;
    [self.coordinator appendLogLine:[NSString stringWithFormat:@"askQuestion source=%ld len=%lu",
                                     (long)round.source, (unsigned long)question.length]];

    __weak typeof(self) weakSelf = self;
    __weak TSAIQATextRound *weakRound = round;
    NSString *taskId = [questionAnswer askQuestion:question
                                            config:self.coordinator.config
                                  onStartAnswering:^(NSString *taskId, NSString * _Nullable questionId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            TSAIQATextRound *strongRound = weakRound;
            if (!strongSelf || !strongRound || ![strongSelf isCurrentTextTask:taskId round:strongRound]) return;
            strongRound.questionId = questionId;
            strongRound.state = TSAIQATextRoundStateAnswering;
            [strongSelf.coordinator appendLogLine:[NSString stringWithFormat:@"onStartAnswering taskId=%@ questionId=%@",
                                                   taskId, questionId ?: @"nil"]];
            [strongSelf refreshRoundItem:strongRound];
        });
    }
                                   onPartialResult:^(TSAIQuestionAnswerPartialResult *partialResult) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            TSAIQATextRound *strongRound = weakRound;
            if (!strongSelf || !strongRound ||
                ![strongSelf isCurrentTextTask:partialResult.taskId round:strongRound]) return;
            if (strongRound.state == TSAIQATextRoundStatePending) {
                strongRound.state = TSAIQATextRoundStateAnswering;
            }
            strongRound.questionId = partialResult.questionId ?: strongRound.questionId;
            strongRound.answer = partialResult.fullText ?: @"";
            strongRound.deltaText = partialResult.deltaText;
            strongRound.partialCount += 1;
            [strongSelf.coordinator appendLogLine:[NSString stringWithFormat:@"partial #%lu len=%lu delta=%lu isFinal=%d",
                                                   (unsigned long)strongRound.partialCount,
                                                   (unsigned long)strongRound.answer.length,
                                                   (unsigned long)partialResult.deltaText.length,
                                                   partialResult.isFinal]];
            [strongSelf refreshRoundItem:strongRound];
        });
    }
                                        completion:^(TSAIQuestionAnswerResult * _Nullable result,
                                                     NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            TSAIQATextRound *strongRound = weakRound;
            if (!strongSelf || !strongRound) return;
            NSString *callbackTaskId = result.taskId ?: strongRound.taskId;
            if (![strongSelf isCurrentTextTask:callbackTaskId round:strongRound]) return;
            if (error) {
                BOOL cancelled = [strongSelf isCancellationError:error];
                [strongRound finishWithState:cancelled ? TSAIQATextRoundStateCancelled : TSAIQATextRoundStateFailed
                                       error:error];
                [strongSelf.coordinator appendLogLine:[NSString stringWithFormat:@"completion(error) %@ domain=%@ code=%ld %@",
                                                       cancelled ? @"cancelled" : @"failed",
                                                       error.domain, (long)error.code,
                                                       error.localizedDescription ?: @""]];
            } else {
                strongRound.questionId = result.questionId ?: strongRound.questionId;
                if (result.answerText.length > 0) {
                    strongRound.answer = result.answerText;
                }
                [strongRound finishWithState:TSAIQATextRoundStateCompleted error:nil];
                [strongSelf.coordinator appendLogLine:[NSString stringWithFormat:@"completion(result) len=%lu duration=%.2fs",
                                                       (unsigned long)strongRound.answer.length, strongRound.duration]];
            }
            strongSelf.currentTextTaskId = nil;
            [strongSelf refreshRoundItem:strongRound];
            [strongSelf refreshStatus];
            if (!error && strongRound.source != TSAIQARoundSourceText) {
                [strongSelf speakAnswerOfRound:strongRound];
            }
        });
    }];

    round.taskId = taskId ?: @"";
    self.currentTextTaskId = taskId;
    [self.coordinator appendLogLine:[NSString stringWithFormat:@"taskId=%@", taskId ?: @"nil"]];
    [self refreshRoundItem:round];
    [self refreshStatus];
}

/** 校验回调是否属于当前任务，避免迟到回调污染 UI */
- (BOOL)isCurrentTextTask:(NSString *)taskId round:(TSAIQATextRound *)round {
    if ([self.roundItems indexOfObjectIdenticalTo:round] == NSNotFound) {
        return NO;
    }
    if (taskId.length > 0 && round.taskId.length > 0 && ![taskId isEqualToString:round.taskId]) {
        return NO;
    }
    return ![round isTerminal];
}

/** 判断错误是否为取消 */
- (BOOL)isCancellationError:(NSError *)error {
    if ([error.domain isEqualToString:TSAIErrorDomain] && error.code == TSAIErrorCodeCancelled) {
        return YES;
    }
    return error.code == eTSErrorUserCancelled;
}

/** 逻辑取消当前 askQuestion 任务 */
- (void)cancelCurrentTextTask {
    if (self.currentTextTaskId.length == 0) {
        return;
    }
    [self.coordinator appendLogLine:[NSString stringWithFormat:@"cancelQuestionAnswer taskId=%@", self.currentTextTaskId]];
    [[self questionAnswerInterface] cancelQuestionAnswerWithTaskId:self.currentTextTaskId];
}

#pragma mark - 私有方法 - 手机 / 耳机拾音

/** 主按钮：开始拾音或结束并识别 */
- (void)togglePhoneVoiceCapture {
    switch (self.voiceCapture.state) {
        case TSAIQAVoiceCaptureStateListening:
            [self.voiceCapture finish];
            return;
        case TSAIQAVoiceCaptureStateRecognizing:
            return;
        case TSAIQAVoiceCaptureStateIdle:
            break;
    }
    if (self.currentTextTaskId.length > 0) {
        [self showAlertWithMsg:@"上一题仍在回答中，请先停止或等待完成"];
        return;
    }
    if (![self questionAnswerInterface]) {
        [self showAlertWithMsg:@"AI Context 未激活，请先连接设备并完成鉴权"];
        return;
    }
    NSError *serviceError = [self textEligibilityError];
    if (serviceError) {
        [self showAlertWithMsg:[NSString stringWithFormat:@"服务不支持问答\n%@", [self readableEligibilityError:serviceError]]];
        return;
    }
    id<TSAISpeechInterface> speech = [self speechInterface];
    if (!speech) {
        [self showAlertWithMsg:@"Speech 接口不可用，无法识别语音"];
        return;
    }
    [self.speechPlayer stop];
    TSAIQARoundSource source = (self.inputMode == TSAIQAInputModeHeadset)
        ? TSAIQARoundSourceHeadset : TSAIQARoundSourcePhoneMic;
    __weak typeof(self) weakSelf = self;
    [TSAIAudioRecordAppCapture requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (!granted) {
                [strongSelf showAlertWithMsg:@"麦克风权限被拒绝，请在系统设置中开启"];
                return;
            }
            [strongSelf startPhoneVoiceCaptureWithSource:source speech:speech];
        });
    }];
}

/** 创建语音轮次并开始采集 */
- (void)startPhoneVoiceCaptureWithSource:(TSAIQARoundSource)source speech:(id<TSAISpeechInterface>)speech {
    if (self.voiceCapture.state != TSAIQAVoiceCaptureStateIdle) {
        return;
    }
    self.voiceCapture.speech = speech;
    NSError *error = nil;
    TSAIQATextRound *round = [TSAIQATextRound voiceRoundWithSource:source];
    self.voiceRound = round;
    if (![self.voiceCapture startWithSource:source error:&error]) {
        self.voiceRound = nil;
        [self showAlertWithMsg:[NSString stringWithFormat:@"无法开始拾音\n%@", [self readableError:error]]];
        [self refreshStatus];
        return;
    }
    [self appendRoundItem:round];
}

/** 拾音计时：聆听中每 0.25s 刷新一次文案 */
- (void)updateListeningTimer {
    BOOL listening = (self.inputMode == TSAIQAInputModePhoneMic || self.inputMode == TSAIQAInputModeHeadset) &&
        self.voiceCapture.state == TSAIQAVoiceCaptureStateListening;
    if (listening && !self.listeningTimer) {
        __weak typeof(self) weakSelf = self;
        self.listeningTimer = [NSTimer scheduledTimerWithTimeInterval:kTSAIQAListeningTickInterval
                                                              repeats:YES
                                                                block:^(NSTimer *timer) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                [timer invalidate];
                return;
            }
            [strongSelf refreshPhoneVoiceStatus];
        }];
    } else if (!listening && self.listeningTimer) {
        [self.listeningTimer invalidate];
        self.listeningTimer = nil;
    }
}

/** 在手机上播报某一轮答案 */
- (void)speakAnswerOfRound:(TSAIQATextRound *)round {
    if (!self.phoneSpeechEnabled || round.answer.length == 0) {
        return;
    }
    id<TSAISpeechInterface> speech = [self speechInterface];
    if (!speech) {
        round.playbackText = @"Speech 接口不可用，未播报";
        [self refreshRoundItem:round];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak TSAIQATextRound *weakRound = round;
    [self.speechPlayer speakText:round.answer
                          speech:speech
                   statusHandler:^(NSString *status, BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        TSAIQATextRound *strongRound = weakRound;
        if (!strongSelf || !strongRound) return;
        strongRound.playbackText = status;
        [strongSelf.coordinator appendLogLine:[NSString stringWithFormat:@"[tts] %@", status]];
        [strongSelf refreshRoundItem:strongRound];
        if (finished) {
            [strongSelf refreshStatus];
        }
    }];
    [self refreshStatus];
}

#pragma mark - 私有方法 - 手表拾音

/** 播放条文字：文字阶段不等待播放，播放状态来自路由快照 */
- (NSString *)playbackTextForRound:(TSAIQADeviceRound *)round {
    if (round.phase != TSAIDeviceQuestionAnswerPhaseAnswer &&
        round.phase != TSAIDeviceQuestionAnswerPhaseCompleted) {
        return nil;
    }
    if (round != self.coordinator.rounds.lastObject) {
        return round.phase == TSAIDeviceQuestionAnswerPhaseCompleted ? @"TTS · 已由路由 Driver 播放" : nil;
    }
    id<TSAIAudioRoutingInterface> audioRouting = [TSAIKit sharedInstance].activeContext.audioRouting;
    TSAIAudioRouteSnapshot *snapshot = [audioRouting activeAudioRouteForFeature:TSAIFeatureDeviceQuestionAnswering];
    TSAIAudioRouteConfiguration *route = [TSAIQADeviceSessionCoordinator resolvedDeviceRouteForConfig:self.coordinator.config];
    NSString *outputTitle = snapshot
        ? [self titleForOutputChannel:snapshot.effectiveRoute.outputChannel]
        : [self titleForOutputChannel:route.outputChannel];
    if (snapshot) {
        NSString *stateText = @"";
        switch (snapshot.state) {
            case TSAIAudioRouteStateResolving:
            case TSAIAudioRouteStateActivating: stateText = @"准备播放"; break;
            case TSAIAudioRouteStateActive:     stateText = @"播放中"; break;
            case TSAIAudioRouteStateStopping:   stateText = @"结束中"; break;
            case TSAIAudioRouteStateInterrupted: stateText = @"已中断"; break;
            case TSAIAudioRouteStateFailed:     stateText = @"播放失败"; break;
            default:                            stateText = @"路由就绪"; break;
        }
        return [NSString stringWithFormat:@"TTS · %@ · %@（路由快照）", outputTitle, stateText];
    }
    if (round.phase == TSAIDeviceQuestionAnswerPhaseCompleted) {
        return [NSString stringWithFormat:@"TTS · %@ · 文字已完成，播放由路由 Driver 负责", outputTitle];
    }
    return [NSString stringWithFormat:@"TTS · %@ · 等待合成", outputTitle];
}

/** 最近一轮处于回答或刚完成时，轮询路由快照刷新播放条 */
- (void)updatePlaybackPolling {
    TSAIQADeviceRound *lastRound = self.coordinator.rounds.lastObject;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    BOOL shouldPoll = self.inputMode == TSAIQAInputModeWatch && lastRound &&
        (lastRound.phase == TSAIDeviceQuestionAnswerPhaseAnswer ||
         (lastRound.phase == TSAIDeviceQuestionAnswerPhaseCompleted &&
          now - lastRound.updatedAt < kTSAIQAPlaybackPollWindow));
    if (shouldPoll && !self.playbackTimer) {
        __weak typeof(self) weakSelf = self;
        self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:kTSAIQAPlaybackPollInterval
                                                             repeats:YES
                                                               block:^(NSTimer *timer) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                [timer invalidate];
                return;
            }
            [strongSelf onPlaybackTick];
        }];
    } else if (!shouldPoll && self.playbackTimer) {
        [self.playbackTimer invalidate];
        self.playbackTimer = nil;
    }
}

/** 轮询刷新最后一轮的播放条 */
- (void)onPlaybackTick {
    TSAIQADeviceRound *lastRound = self.coordinator.rounds.lastObject;
    if (lastRound) {
        [self refreshRoundItem:lastRound];
    }
    [self updatePlaybackPolling];
}

#pragma mark - 私有方法 - 路由与智能体

/** 手表模式输出路由选择：列出问答功能可用的完整路由对 */
- (void)presentWatchRouteSheetFromView:(UIView *)sourceView {
    id<TSAIAudioRoutingInterface> audioRouting = [TSAIKit sharedInstance].activeContext.audioRouting;
    NSArray<TSAIAudioRouteCapability *> *capabilities =
        [audioRouting audioRouteCapabilitiesForFeature:TSAIFeatureDeviceQuestionAnswering] ?: @[];
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"手表问答音频路由 · TSAIFeatureDeviceQuestionAnswering"
                         message:@"输入固定为设备 Opus；这里选择 TTS 的输出通道，下一轮生效"
                  preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"跟随系统（SystemDefault）"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        (void)action;
        [weakSelf applyRouteConfiguration:nil];
    }]];
    for (TSAIAudioRouteCapability *capability in capabilities) {
        if (capability.inputChannel != TSAIAudioInputChannelOpus) {
            continue;
        }
        NSString *title = [NSString stringWithFormat:@"%@ → %@",
                           [self titleForInputChannel:capability.inputChannel],
                           [self titleForOutputChannel:capability.outputChannel]];
        if (!capability.isAvailable) {
            title = [title stringByAppendingFormat:@"（不可用%@）",
                     capability.unavailableReason.length > 0 ? [@"：" stringByAppendingString:capability.unavailableReason] : @""];
        }
        UIAlertAction *routeAction = [UIAlertAction actionWithTitle:title
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
            (void)action;
            [weakSelf applyRouteConfiguration:[TSAIAudioRouteConfiguration
                configurationWithInputChannel:capability.inputChannel
                                outputChannel:capability.outputChannel
                       routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyUseAutomaticRoute]];
        }];
        routeAction.enabled = capability.isAvailable;
        [alert addAction:routeAction];
    }
    if (capabilities.count == 0) {
        UIAlertAction *emptyAction = [UIAlertAction actionWithTitle:@"未查询到可用路由（Context 未激活）"
                                                              style:UIAlertActionStyleDefault handler:nil];
        emptyAction.enabled = NO;
        [alert addAction:emptyAction];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    alert.popoverPresentationController.sourceView = sourceView;
    alert.popoverPresentationController.sourceRect = sourceView.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

/** 应用新的路由配置 */
- (void)applyRouteConfiguration:(TSAIAudioRouteConfiguration *)route {
    TSAIQuestionAnswerConfig *config = [self.coordinator.config copy];
    config.audioRouteConfiguration = route;
    [self.coordinator updateConfig:config];
    [self refreshStatus];
}

/** 手机 / 耳机模式的路由点击：输入在手机 / 耳机间切换，输出切换播报开关 */
- (void)handlePhoneVoiceRouteTap:(TSAIQARouteKind)kind {
    if (self.voiceCapture.state != TSAIQAVoiceCaptureStateIdle || self.currentTextTaskId.length > 0) {
        [self showAlertWithMsg:@"拾音或回答进行中，稍后再切换"];
        return;
    }
    if (kind == TSAIQARouteKindInput) {
        [self switchToInputMode:self.inputMode == TSAIQAInputModeHeadset
                                ? TSAIQAInputModePhoneMic : TSAIQAInputModeHeadset];
    } else {
        self.phoneSpeechEnabled = !self.phoneSpeechEnabled;
        [self.coordinator appendLogLine:[NSString stringWithFormat:@"phone speech %@", self.phoneSpeechEnabled ? @"on" : @"off"]];
        [self refreshStatus];
    }
}

/** 弹出智能体选择；手表发起的问答中，手表已选择的智能体优先于此值 */
- (void)presentAgentEditor {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"AI 智能体 · config.agent"
                         message:@"未指定时由服务选择默认智能体；手表发起的问答以手表上选择的智能体优先"
                  preferredStyle:UIAlertControllerStyleActionSheet];
    TSAIQuestionAnswerAgent current = self.coordinator.config.agent;
    __weak typeof(self) weakSelf = self;
    for (NSNumber *value in [self selectableAgents]) {
        TSAIQuestionAnswerAgent agent = (TSAIQuestionAnswerAgent)value.integerValue;
        NSString *title = [self titleForAgent:agent];
        if (agent == current) {
            title = [@"✓ " stringByAppendingString:title];
        }
        [alert addAction:[UIAlertAction actionWithTitle:title
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
            (void)action;
            __strong typeof(weakSelf) strongSelf = weakSelf;
            TSAIQuestionAnswerConfig *config = [strongSelf.coordinator.config copy];
            config.agent = agent;
            [strongSelf.coordinator updateConfig:config];
            [strongSelf refreshStatus];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    alert.popoverPresentationController.sourceView = self.agentChipButton;
    alert.popoverPresentationController.sourceRect = self.agentChipButton.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

/** 可选智能体列表 */
- (NSArray<NSNumber *> *)selectableAgents {
    return @[@(TSAIQuestionAnswerAgentUnspecified),
             @(TSAIQuestionAnswerAgentDoubao),
             @(TSAIQuestionAnswerAgentDeepSeek),
             @(TSAIQuestionAnswerAgentChatGLM),
             @(TSAIQuestionAnswerAgentERNIEBot),
             @(TSAIQuestionAnswerAgentQwen),
             @(TSAIQuestionAnswerAgentSpark),
             @(TSAIQuestionAnswerAgentKimi)];
}

/** 智能体的显示名 */
- (NSString *)titleForAgent:(TSAIQuestionAnswerAgent)agent {
    switch (agent) {
        case TSAIQuestionAnswerAgentUnspecified: return @"默认";
        case TSAIQuestionAnswerAgentDoubao:      return @"豆包";
        case TSAIQuestionAnswerAgentDeepSeek:    return @"DeepSeek";
        case TSAIQuestionAnswerAgentChatGLM:     return @"智谱清言";
        case TSAIQuestionAnswerAgentERNIEBot:    return @"文心一言";
        case TSAIQuestionAnswerAgentQwen:        return @"通义千问";
        case TSAIQuestionAnswerAgentSpark:       return @"讯飞星火";
        case TSAIQuestionAnswerAgentKimi:        return @"Kimi";
    }
    return [NSString stringWithFormat:@"agent %ld", (long)agent];
}

/** 输入通道的显示名 */
- (NSString *)titleForInputChannel:(TSAIAudioInputChannel)channel {
    switch (channel) {
        case TSAIAudioInputChannelBuiltInMic: return @"手机麦克风";
        case TSAIAudioInputChannelSCO:        return @"耳机拾音 (SCO)";
        case TSAIAudioInputChannelOpus:       return @"手表拾音 (Opus)";
        case TSAIAudioInputChannelAutomatic:  return @"自动";
        default:                              return @"未知";
    }
}

/** 输出通道的显示名 */
- (NSString *)titleForOutputChannel:(TSAIAudioOutputChannel)channel {
    switch (channel) {
        case TSAIAudioOutputChannelNone:           return @"不播放";
        case TSAIAudioOutputChannelBuiltInSpeaker: return @"手机播放";
        case TSAIAudioOutputChannelSCO:            return @"耳机播放 (SCO)";
        case TSAIAudioOutputChannelA2DP:           return @"耳机播放 (A2DP)";
        case TSAIAudioOutputChannelOpus:           return @"手表播放 (Opus)";
        case TSAIAudioOutputChannelSystemDefault:  return @"跟随系统";
        case TSAIAudioOutputChannelAutomatic:      return @"自动";
        default:                                   return @"未知";
    }
}

/** 错误的简短可读文本 */
- (NSString *)readableError:(NSError *)error {
    return [NSString stringWithFormat:@"%ld %@", (long)error.code, error.localizedDescription ?: @""];
}

#pragma mark - 私有方法 - 能力诊断

/** 当前激活的 AI Context */
- (nullable TSAIContext *)activeContext {
    return [TSAIKit sharedInstance].activeContext;
}

/**
 * 服务级问答资格（文字 / 手机 / 耳机共用）；支持时返回 nil
 * 走 startEligibilityForRequest:，比 supportsAIFeatures: 多带一个原因 NSError
 */
- (nullable NSError *)textEligibilityError {
    TSAIContext *context = [self activeContext];
    if (!context) {
        return [NSError errorWithDomain:TSAIErrorDomain
                                   code:TSAIErrorCodeContextInactive
                               userInfo:@{NSLocalizedDescriptionKey: @"AI Context is inactive"}];
    }
    TSAIStartRequest *request =
        [TSAIStartRequest requestWithIdentifier:[NSString stringWithFormat:@"qa-diag-text.%@", NSUUID.UUID.UUIDString]
                                        useCase:TSAIUseCaseTextQuestionAnswer
                                     parameters:nil
                             deviceCoordination:nil];
    TSAIStartEligibility *eligibility = [context startEligibilityForRequest:request];
    if (eligibility.support == TSAICapabilitySupported) {
        return nil;
    }
    return eligibility.error ?: [NSError errorWithDomain:TSAIErrorDomain
                                                    code:TSAIErrorCodeNotSupported
                                                userInfo:@{NSLocalizedDescriptionKey: @"Unsupported without a reason"}];
}

/** 把 TSAICapabilityResolver 的英文原因翻成一眼能看懂的中文，并保留原文 */
- (NSString *)readableEligibilityError:(NSError *)error {
    NSString *description = error.localizedDescription ?: @"";
    NSString *hint = nil;
    if ([description containsString:@"does not support this use case"] ||
        [description containsString:@"service capability is unavailable"]) {
        hint = @"AIBuds 当前 vendor 未提供问答服务(aiAskingService 为空)";
    } else if ([description containsString:@"device scene, initiator and audio input"]) {
        hint = @"手表能力位未声明该发起方向的问答场景(0x24=手表发起 / 0x25=App 发起)";
    } else if ([description containsString:@"No App handler"]) {
        hint = @"App 未注册 VoiceQuestionAnswer 路由";
    } else if ([description containsString:@"authorization is required"]) {
        hint = @"AI 鉴权未完成";
    } else if ([description containsString:@"Context is inactive"]) {
        hint = @"AI Context 未激活";
    } else if ([description containsString:@"host audio route"]) {
        hint = @"手机侧音频路由不可用";
    } else if ([description containsString:@"transport is unavailable"] ||
               [description containsString:@"device AI capability is unavailable"]) {
        hint = @"设备未连接或 Bridge 不可用";
    }
    return hint
        ? [NSString stringWithFormat:@"%@（%ld %@）", hint, (long)error.code, description]
        : [NSString stringWithFormat:@"%ld %@", (long)error.code, description];
}

/** 弹出能力诊断结果 */
- (void)presentCapabilityDiagnostics {
    TSAIContext *context = [self activeContext];
    NSMutableArray<NSString *> *lines = [NSMutableArray array];
    [lines addObject:[NSString stringWithFormat:@"Context: %@", context ? @"已激活" : @"未激活"]];
    if (context) {
        [lines addObject:[NSString stringWithFormat:@"supportsAIFeatures 问答(1<<12): %@",
                          [context supportsAIFeatures:TSAIFeatureQuestionAnswering] ? @"YES" : @"NO"]];
        [lines addObject:[NSString stringWithFormat:@"supportsAIFeatures 手表发起问答(1<<15): %@",
                          [context supportsAIFeatures:TSAIFeatureDeviceQuestionAnswering] ? @"YES" : @"NO"]];
        [lines addObject:[NSString stringWithFormat:@"speech 接口: %@", context.speech ? @"可用" : @"nil"]];
    }
    NSError *textError = [self textEligibilityError];
    [lines addObject:[NSString stringWithFormat:@"\n问答服务(文字/手机/耳机): %@",
                      textError ? [self readableEligibilityError:textError] : @"Supported"]];
    NSError *appInitiated = [self.coordinator deviceRoundEligibilityErrorForInitiator:TSAISessionInitiatorApp];
    [lines addObject:[NSString stringWithFormat:@"\n手表拾音·App 发起(0x25): %@",
                      appInitiated ? [self readableEligibilityError:appInitiated] : @"Supported"]];
    NSError *deviceInitiated = [self.coordinator deviceRoundEligibilityErrorForInitiator:TSAISessionInitiatorDevice];
    [lines addObject:[NSString stringWithFormat:@"\n手表拾音·手表发起(0x24): %@",
                      deviceInitiated ? [self readableEligibilityError:deviceInitiated] : @"Supported"]];
    [lines addObject:[NSString stringWithFormat:@"\n协调器状态: %ld origin=%ld",
                      (long)self.coordinator.state, (long)self.coordinator.origin]];
    NSString *message = [lines componentsJoinedByString:@"\n"];
    [self.coordinator appendLogLine:[NSString stringWithFormat:@"[diag] %@",
                                     [message stringByReplacingOccurrencesOfString:@"\n" withString:@" | "]]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"问答能力诊断"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        (void)action;
        [UIPasteboard generalPasteboard].string = message;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 事件

/** 切换拾音方式 */
- (void)onModeSegmentChanged {
    TSAIQAInputMode target = (TSAIQAInputMode)self.modeSegment.selectedSegmentIndex;
    if (target == self.inputMode) {
        return;
    }
    // 手机 / 耳机拾音进行中不允许切走，避免采集悬挂
    if (self.voiceCapture.state != TSAIQAVoiceCaptureStateIdle) {
        self.modeSegment.selectedSegmentIndex = (NSInteger)self.inputMode;
        [self showAlertWithMsg:@"语音拾音进行中，请先结束或取消"];
        return;
    }
    [self switchToInputMode:target];
}

/** 智能体 chip */
- (void)onAgentChipTapped {
    [self presentAgentEditor];
}

/** 日志 */
- (void)onLogTapped {
    TSAIQALogSheet *sheet = [[TSAIQALogSheet alloc] initWithLines:self.coordinator.logLines];
    self.presentedLogSheet = sheet;
    [self presentViewController:sheet animated:YES completion:nil];
}

/** 设置 */
- (void)onSettingsTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"问答设置"
                                                                   message:@"TSAIQuestionAnswerConfig"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"AI 智能体：%@",
                                                     [self titleForAgent:self.coordinator.config.agent]]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        (void)action;
        [weakSelf presentAgentEditor];
    }]];
    TSAIAudioRouteConfiguration *route = [TSAIQADeviceSessionCoordinator resolvedDeviceRouteForConfig:self.coordinator.config];
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"手表问答 TTS 输出：%@",
                                                     [self titleForOutputChannel:route.outputChannel]]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        (void)action;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf presentWatchRouteSheetFromView:strongSelf.statusBadge];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"手机 / 耳机拾音后播报答案：%@",
                                                     self.phoneSpeechEnabled ? @"开" : @"关"]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        (void)action;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.phoneSpeechEnabled = !strongSelf.phoneSpeechEnabled;
        [strongSelf refreshStatus];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"能力诊断 · startEligibilityForRequest:"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        (void)action;
        [weakSelf presentCapabilityDiagnostics];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"清空本页轮次"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action) {
        (void)action;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.speechPlayer stop];
        [strongSelf.roundItems removeAllObjects];
        [strongSelf.coordinator clearRounds];
        [strongSelf.roundTableView reloadData];
        [strongSelf refreshStatus];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    alert.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItems.firstObject;
    [self presentViewController:alert animated:YES completion:nil];
}

/** 协调器状态变化 */
- (void)onSessionDidChange:(NSNotification *)notification {
    (void)notification;
    // 协调器清空轮次时同步移除列表里的手表轮次
    if (self.coordinator.rounds.count == 0) {
        NSIndexSet *deviceIndexes = [self.roundItems indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj isKindOfClass:[TSAIQADeviceRound class]];
        }];
        if (deviceIndexes.count > 0) {
            [self.roundItems removeObjectsAtIndexes:deviceIndexes];
            [self.roundTableView reloadData];
        }
    }
    [self refreshStatus];
    [self updatePlaybackPolling];
}

/** 手表轮次快照更新 */
- (void)onSessionDidUpdateRound:(NSNotification *)notification {
    TSAIQADeviceRound *round = notification.userInfo[TSAIQADeviceSessionRoundUserInfoKey];
    if (![round isKindOfClass:[TSAIQADeviceRound class]]) {
        return;
    }
    if ([self.roundItems indexOfObjectIdenticalTo:round] == NSNotFound) {
        [self appendRoundItem:round];
    } else {
        [self refreshRoundItem:round];
    }
    [self refreshStatus];
    [self updatePlaybackPolling];
}

/** 手表轮次激活：页面已在栈内时切到手表拾音 */
- (void)onSessionDidRequestPresentation:(NSNotification *)notification {
    (void)notification;
    if (self.voiceCapture.state != TSAIQAVoiceCaptureStateIdle) {
        return;
    }
    [self switchToInputMode:TSAIQAInputModeWatch];
}

/** 日志追加：同步到已弹出的日志弹层 */
- (void)onSessionDidAppendLog:(NSNotification *)notification {
    NSString *line = notification.userInfo[TSAIQADeviceSessionLogLineUserInfoKey];
    if ([line isKindOfClass:[NSString class]]) {
        [self.presentedLogSheet appendLine:line];
    }
}

/** 键盘位置变化 */
- (void)onKeyboardWillChangeFrame:(NSNotification *)notification {
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frameInView = [self.view convertRect:endFrame fromView:nil];
    CGFloat overlap = MAX(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(frameInView));
    self.keyboardOverlap = overlap;
    [UIView animateWithDuration:duration animations:^{
        [self layoutViews];
    } completion:^(BOOL finished) {
        (void)finished;
        if (overlap > 0) {
            [self scrollToBottomAnimated:YES];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.roundItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = indexPath.row < (NSInteger)self.roundItems.count ? self.roundItems[(NSUInteger)indexPath.row] : nil;
    if ([item isKindOfClass:[TSAIQADeviceRound class]]) {
        TSAIQADeviceRoundCell *cell = [tableView dequeueReusableCellWithIdentifier:TSAIQADeviceRoundCell.cellReuseIdentifier
                                                                           forIndexPath:indexPath];
        [self configureCell:cell withItem:item];
        return cell;
    }
    TSAIQATextRoundCell *cell = [tableView dequeueReusableCellWithIdentifier:TSAIQATextRoundCell.cellReuseIdentifier
                                                                       forIndexPath:indexPath];
    cell.delegate = self;
    if (item) {
        [self configureCell:cell withItem:item];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    (void)scrollView;
    [self.composerView dismissKeyboard];
}

#pragma mark - TSAIQATextRoundCellDelegate

- (void)textRoundCell:(TSAIQATextRoundCell *)cell didTapCopyForRound:(TSAIQATextRound *)round {
    (void)cell;
    [UIPasteboard generalPasteboard].string = round.answer ?: @"";
    [self.coordinator appendLogLine:@"answer copied"];
}

- (void)textRoundCell:(TSAIQATextRoundCell *)cell didTapRetryForRound:(TSAIQATextRound *)round {
    (void)cell;
    if (self.currentTextTaskId.length > 0) {
        [self showAlertWithMsg:@"上一题仍在回答中，请先停止或等待完成"];
        return;
    }
    TSAIQATextRound *retry = [TSAIQATextRound roundWithQuestion:round.question taskId:@""];
    retry.source = round.source;
    [self appendRoundItem:retry];
    [self runQuestion:round.question round:retry];
}

#pragma mark - TSAIQAEmptyStateViewDelegate

- (void)emptyStateView:(TSAIQAEmptyStateView *)view didSelectSuggestion:(NSString *)question {
    (void)view;
    [self submitQuestion:question];
}

#pragma mark - TSAIQAComposerViewDelegate

- (void)composerView:(TSAIQAComposerView *)composer didSubmitText:(NSString *)text {
    (void)composer;
    [self submitQuestion:text];
}

- (void)composerViewDidTapStop:(TSAIQAComposerView *)composer {
    (void)composer;
    [self cancelCurrentTextTask];
}

- (void)composerViewDidChangeHeight:(TSAIQAComposerView *)composer {
    (void)composer;
    [self layoutViews];
}

#pragma mark - TSAIQADeviceStatusViewDelegate

- (void)deviceStatusView:(TSAIQADeviceStatusView *)view didTapRoute:(TSAIQARouteKind)kind {
    if (self.inputMode == TSAIQAInputModeWatch) {
        if (kind == TSAIQARouteKindInput) {
            [self showAlertWithMsg:@"手表拾音的输入固定为设备 Opus（FitCloud App 发起会话总是请求设备麦克风）"];
        } else {
            [self presentWatchRouteSheetFromView:view];
        }
    } else {
        [self handlePhoneVoiceRouteTap:kind];
    }
}

#pragma mark - TSAIQADeviceActionBarDelegate

- (void)deviceActionBarDidTapPrimary:(TSAIQADeviceActionBar *)bar {
    (void)bar;
    if (self.inputMode == TSAIQAInputModeWatch) {
        switch (self.coordinator.state) {
            case TSAIQADeviceSessionStateRegistered: {
                NSError *eligibility = [self.coordinator deviceRoundEligibilityErrorForInitiator:TSAISessionInitiatorApp];
                if (eligibility) {
                    [self showAlertWithMsg:[NSString stringWithFormat:@"手表不支持 App 发起问答\n%@",
                                            [self readableEligibilityError:eligibility]]];
                    return;
                }
                [self.coordinator startRoundFromApp];
                break;
            }
            case TSAIQADeviceSessionStatePreparing:
            case TSAIQADeviceSessionStateListening:
            case TSAIQADeviceSessionStateAnswering:
                [self.coordinator stopCurrentRound];
                break;
            default:
                break;
        }
    } else {
        if (self.currentTextTaskId.length > 0 && self.voiceCapture.state == TSAIQAVoiceCaptureStateIdle) {
            [self cancelCurrentTextTask];
        } else {
            [self togglePhoneVoiceCapture];
        }
    }
    [self refreshStatus];
}

- (void)deviceActionBar:(TSAIQADeviceActionBar *)bar didTapRoute:(TSAIQARouteKind)kind {
    [self deviceStatusView:self.deviceStatusView didTapRoute:kind];
    (void)bar;
}

#pragma mark - TSAIQAVoiceCaptureDelegate

- (void)voiceCapture:(TSAIQAVoiceCapture *)capture didChangeState:(TSAIQAVoiceCaptureState)state {
    (void)capture;
    (void)state;
    [self refreshStatus];
}

- (void)voiceCapture:(TSAIQAVoiceCapture *)capture didUpdatePartialText:(NSString *)text {
    (void)capture;
    TSAIQATextRound *round = self.voiceRound;
    if (!round) {
        return;
    }
    round.question = text ?: @"";
    [self refreshRoundItem:round];
}

- (void)voiceCapture:(TSAIQAVoiceCapture *)capture
   didFinishWithText:(NSString *)text
       voiceDuration:(NSTimeInterval)voiceDuration
               error:(NSError *)error {
    (void)capture;
    TSAIQATextRound *round = self.voiceRound;
    self.voiceRound = nil;
    if (!round) {
        return;
    }
    round.voiceDuration = voiceDuration;
    if (error) {
        BOOL cancelled = [self isCancellationError:error];
        [round finishWithState:cancelled ? TSAIQATextRoundStateCancelled : TSAIQATextRoundStateFailed error:error];
        [self refreshRoundItem:round];
        [self refreshStatus];
        return;
    }
    [self runQuestion:text round:round];
}

- (void)voiceCapture:(TSAIQAVoiceCapture *)capture didAppendLog:(NSString *)line {
    (void)capture;
    [self.coordinator appendLogLine:line];
}

#pragma mark - 属性（懒加载）

- (UISegmentedControl *)modeSegment {
    if (!_modeSegment) {
        _modeSegment = [[UISegmentedControl alloc] initWithItems:@[@"文字", @"手机拾音", @"耳机拾音", @"手表拾音"]];
        _modeSegment.selectedSegmentIndex = 0;
        if (@available(iOS 13.0, *)) {
            _modeSegment.selectedSegmentTintColor = [UIColor whiteColor];
            [_modeSegment setTitleTextAttributes:@{NSForegroundColorAttributeName: TSAIQATextPrimaryColor(),
                                                   NSFontAttributeName: [UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold]}
                                        forState:UIControlStateSelected];
            [_modeSegment setTitleTextAttributes:@{NSForegroundColorAttributeName: TSAIQATextTertiaryColor(),
                                                   NSFontAttributeName: [UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold]}
                                        forState:UIControlStateNormal];
        } else {
            _modeSegment.tintColor = TSAIQATintColor();
        }
        [_modeSegment addTarget:self action:@selector(onModeSegmentChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _modeSegment;
}

- (UIButton *)agentChipButton {
    if (!_agentChipButton) {
        _agentChipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _agentChipButton.backgroundColor = [UIColor whiteColor];
        _agentChipButton.layer.cornerRadius = 14.0;
        _agentChipButton.layer.borderWidth = 1.0;
        _agentChipButton.layer.borderColor = TSAIQALineColor().CGColor;
        _agentChipButton.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold];
        _agentChipButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_agentChipButton setTitleColor:TSAIQATextSecondaryColor() forState:UIControlStateNormal];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // iOS 15 起建议改用 UIButtonConfiguration，此处保留旧属性以兼容自定义字体与标题设置
        _agentChipButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12.0, 0, 12.0);
#pragma clang diagnostic pop
        [_agentChipButton addTarget:self action:@selector(onAgentChipTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agentChipButton;
}

- (TSAIQABadgeLabel *)statusBadge {
    if (!_statusBadge) {
        _statusBadge = [[TSAIQABadgeLabel alloc] init];
    }
    return _statusBadge;
}

- (UITableView *)roundTableView {
    if (!_roundTableView) {
        _roundTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _roundTableView.dataSource = self;
        _roundTableView.delegate = self;
        _roundTableView.backgroundColor = [UIColor clearColor];
        _roundTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _roundTableView.rowHeight = UITableViewAutomaticDimension;
        _roundTableView.estimatedRowHeight = 160.0;
        _roundTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _roundTableView.contentInset = UIEdgeInsetsMake(0, 0, 12.0, 0);
        if (@available(iOS 11.0, *)) {
            _roundTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_roundTableView registerClass:[TSAIQATextRoundCell class]
                forCellReuseIdentifier:TSAIQATextRoundCell.cellReuseIdentifier];
        [_roundTableView registerClass:[TSAIQADeviceRoundCell class]
                forCellReuseIdentifier:TSAIQADeviceRoundCell.cellReuseIdentifier];
    }
    return _roundTableView;
}

- (TSAIQAEmptyStateView *)emptyStateView {
    if (!_emptyStateView) {
        _emptyStateView = [[TSAIQAEmptyStateView alloc] init];
        _emptyStateView.delegate = self;
        _emptyStateView.suggestions = @[@"今天适合户外跑步吗？",
                                        @"帮我解释一下心率变异性",
                                        @"昨晚睡得怎么样，怎么改善？"];
    }
    return _emptyStateView;
}

- (TSAIQADeviceStatusView *)deviceStatusView {
    if (!_deviceStatusView) {
        _deviceStatusView = [[TSAIQADeviceStatusView alloc] init];
        _deviceStatusView.delegate = self;
    }
    return _deviceStatusView;
}

- (TSAIQAComposerView *)composerView {
    if (!_composerView) {
        _composerView = [[TSAIQAComposerView alloc] init];
        _composerView.delegate = self;
    }
    return _composerView;
}

- (TSAIQADeviceActionBar *)deviceActionBar {
    if (!_deviceActionBar) {
        _deviceActionBar = [[TSAIQADeviceActionBar alloc] init];
        _deviceActionBar.delegate = self;
    }
    return _deviceActionBar;
}

@end
