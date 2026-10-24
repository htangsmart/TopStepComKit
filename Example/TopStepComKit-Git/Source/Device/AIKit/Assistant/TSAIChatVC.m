//
//  TSAIChatVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatVC.h"

#import <AVFoundation/AVFoundation.h>

#import <TopStepAIKit/TopStepAIKit.h>

#import "TSAIChatAudioPreference.h"
#import "TSAIChatAudioSheet.h"
#import "TSAIChatAuroraView.h"
#import "TSAIChatBannerView.h"
#import "TSAIChatConfigSheet.h"
#import "TSAIChatContextMenu.h"
#import "TSAIChatDeviceSessionCoordinator.h"
#import "TSAIChatDockView.h"
#import "TSAIChatEndCard.h"
#import "TSAIChatFlowView.h"
#import "TSAIChatHeroView.h"
#import "TSAIChatIntentCoordinator.h"
#import "TSAIChatLogSheet.h"
#import "TSAIChatModeSegment.h"
#import "TSAIChatFlowToggle.h"
#import "TSAIChatPCMPlayer.h"
#import "TSAIChatRoundModel.h"
#import "TSAIChatRoundView.h"
#import "TSAIChatRoutePill.h"
#import "TSAIChatTheme.h"
#import "TSAIEarbudsMicrophoneUI.h"
#import "TSAIChatToastView.h"
#import "TSAIChatTranscriptView.h"
#import "TSAIMainThreadStallDetector.h"
#import "TSDeviceCoordinator.h"

#pragma mark - 状态机

/// 对话模式状态（规范 §3.5）
typedef NS_ENUM(NSInteger, TSAIChatChatState) {
    TSAIChatChatStateIdle = 0,
    /// 按住说话：已按下，麦克风还没出数据（等 InputReady）
    TSAIChatChatStatePreparing,
    /// 按住说话：正在听（InputReady 之后）
    TSAIChatChatStateRecording,
    TSAIChatChatStateRecognizing,
    TSAIChatChatStateAnswering,
    TSAIChatChatStateSpeaking,
    TSAIChatChatStateError,
};

/// 畅聊模式状态（规范 §4.5）
typedef NS_ENUM(NSInteger, TSAIChatFlowState) {
    TSAIChatFlowStateIdle = 0,
    TSAIChatFlowStateConnecting,
    TSAIChatFlowStateListening,
    TSAIChatFlowStateHearing,
    TSAIChatFlowStateThinking,
    TSAIChatFlowStateSpeaking,
    TSAIChatFlowStateEnded,
};

/// 最短有效时长（秒）：准备中按下不足、或正在听收听不足都按「说话时间太短」丢弃
static const NSTimeInterval kTSAIChatMinimumPressDuration = 0.5;
/// 最长收听时长（秒，从 InputReady 起），满时自动结束输入
static const NSTimeInterval kTSAIChatMaximumPressDuration = 60;
/// 「准备中」超过该时长提示「麦克风启动较慢…」（秒）；SDK 看门狗 5 秒后以错误结束
static const NSTimeInterval kTSAIChatPreparingSlowHintDelay = 3.0;
/// 语音「退出对话」后停留展示提示的时长（秒），随后返回上一页
static const NSTimeInterval kTSAIChatVoiceExitLeaveDelay = 1.0;
/// 语音「退出对话」时本轮显示的回复
static NSString * const kTSAIChatVoiceExitReply = @"好的，已退出 AI 对话。";

#pragma mark - VC

@interface TSAIChatVC () <TSAIChatRoundViewDelegate, TSAIChatIntentCoordinatorDelegate>

// 会话协调器
@property (nonatomic, strong) TSAIChatDeviceSessionCoordinator *coordinator;
// 意图协调器（定位意图等 App 侧处理）
@property (nonatomic, strong) TSAIChatIntentCoordinator *intentCoordinator;
// 页面模式
@property (nonatomic, assign) TSAIChatPageMode mode;
// 对话模式状态
@property (nonatomic, assign) TSAIChatChatState chatState;
// 畅聊模式状态
@property (nonatomic, assign) TSAIChatFlowState flowState;

// 对话记录（同页累积）
@property (nonatomic, strong) NSMutableArray<TSAIChatRoundModel *> *rounds;
// roundId → 轮视图
@property (nonatomic, strong) NSMutableDictionary<NSString *, TSAIChatRoundView *> *roundViews;
// 当前进行中的对话轮
@property (nonatomic, strong, nullable) TSAIChatRoundModel *currentRound;
// 待发送的文字（SessionStarted 后发）
@property (nonatomic, copy, nullable) NSString *pendingText;
// 会话是否已启动（SessionStarted）
@property (nonatomic, assign) BOOL sessionStarted;
// 正在丢弃当前轮（取消 / 太短），completion 不按错误处理
@property (nonatomic, assign) BOOL discardingRound;
// 用户语音「退出对话」后正在退出页面（意图与 completion 都可能触发，只处理一次）
@property (nonatomic, assign) BOOL exitingByVoice;
// 录音计时（InputReady 之后）
@property (nonatomic, strong, nullable) NSTimer *recordTimer;
// 「麦克风启动较慢」提示计时（准备中）
@property (nonatomic, strong, nullable) NSTimer *preparingSlowTimer;
// 按住说话：按下的时刻（systemUptime）
@property (nonatomic, assign) NSTimeInterval voicePressUptime;
// 按住说话：startSessionFromAppWithConfig: 返回的时刻
@property (nonatomic, assign) NSTimeInterval voiceStartReturnedUptime;
// 按住说话：InputReady 到达的时刻（0 表示还没到）
@property (nonatomic, assign) NSTimeInterval voiceInputReadyUptime;
// 按住说话：本轮 [voiceLatency] 日志是否已输出
@property (nonatomic, assign) BOOL voiceLatencyLogged;

// 畅聊记录（仅会话内）
@property (nonatomic, strong) NSMutableArray<TSAIChatRoundModel *> *flowRounds;
// 畅聊当前轮
@property (nonatomic, strong, nullable) TSAIChatRoundModel *flowCurrentRound;
// 畅聊开始时间
@property (nonatomic, strong, nullable) NSDate *flowStartDate;
// 畅聊：本次会话是否已收到 SessionStarted（「连接中」副标题用）
@property (nonatomic, assign) BOOL flowSessionStarted;
// 畅聊是否显示记录视图
@property (nonatomic, assign) BOOL flowShowingTranscript;
// 结束原因文案
@property (nonatomic, copy, nullable) NSString *flowEndReason;

// 键盘遮挡高度
@property (nonatomic, assign) CGFloat keyboardOverlap;
// 上次已知的耳机连接状态
@property (nonatomic, assign) BOOL lastHeadsetConnected;
// PCM 播放器（长按菜单「播放」）
@property (nonatomic, strong) TSAIChatPCMPlayer *pcmPlayer;
// 当前日志弹层
@property (nonatomic, weak, nullable) TSAIChatLogSheet *currentLogSheet;
// 当前长按菜单
@property (nonatomic, weak, nullable) TSAIChatContextMenu *contextMenu;
// 当前音频设置面板
@property (nonatomic, weak, nullable) TSAIChatAudioSheet *audioSheet;

// 公共视图
@property (nonatomic, strong) TSAIChatAuroraView *auroraView;
@property (nonatomic, strong) TSAIChatModeSegment *modeSegment;
@property (nonatomic, strong) TSAIChatRoutePill *routePill;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) TSAIChatBannerView *bannerView;

// 对话模式视图
@property (nonatomic, strong) UIScrollView *roundsScrollView;
@property (nonatomic, strong) TSAIChatHeroView *heroView;
@property (nonatomic, strong) TSAIChatDockView *dockView;

// 畅聊模式视图
@property (nonatomic, strong) TSAIChatFlowView *flowView;
@property (nonatomic, strong) TSAIChatTranscriptView *transcriptView;
@property (nonatomic, strong) TSAIChatEndCard *endCard;
@property (nonatomic, strong) TSAIChatFlowToggle *flowToggle;
@property (nonatomic, strong) UIControl *flowCloseButton;
@property (nonatomic, strong) UIImageView *flowCloseIcon;
@property (nonatomic, strong) CAGradientLayer *flowCloseGradient;
@property (nonatomic, strong) UILabel *flowCloseLabel;

// ---- 会话进行中切换模式：先结束当前会话（菊花等待），结束后再切换并开启新会话 ----
/** 等待当前会话结束后要切换到的模式；nil 表示没有待处理的切换 */
@property (nonatomic, strong, nullable) NSNumber *pendingSwitchMode;
/** 等待结束的兜底计时（SDK 侧结束通常 0.1~0.4s；超时则放弃切换并提示） */
@property (nonatomic, strong, nullable) NSTimer *pendingSwitchTimer;
/** 已提示过「路由被回退」的任务，避免同一会话反复弹横幅 */
@property (nonatomic, copy, nullable) NSString *routeFallbackNoticeTaskId;

@end

/// 会话进行中切换模式时等待结束的最长时间（秒）
static const NSTimeInterval kTSAIChatModeSwitchTimeout = 3.0;

@implementation TSAIChatVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = @"AI 对话";
    self.view.backgroundColor = TSAIChatPaperColor();
    self.coordinator = [TSAIChatDeviceSessionCoordinator sharedInstance];
    self.intentCoordinator = [[TSAIChatIntentCoordinator alloc] initWithSessionCoordinator:self.coordinator];
    self.intentCoordinator.delegate = self;
    self.rounds = [NSMutableArray array];
    self.roundViews = [NSMutableDictionary dictionary];
    self.flowRounds = [NSMutableArray array];
    self.pcmPlayer = [[TSAIChatPCMPlayer alloc] init];
    self.mode = TSAIChatPageModeChat;
    self.chatState = TSAIChatChatStateIdle;
    self.flowState = TSAIChatFlowStateIdle;
    // 页面打开前设备已发起的畅聊（由主标签页路由打开本页）→ 直接进「AI 畅聊」
    TSAIChatConfig *active = self.coordinator.activeSessionConfig;
    if ([self.coordinator isSessionActive] && active &&
        active.conversationMode == TSAIChatConversationModeContinuous) {
        self.mode = TSAIChatPageModeFlow;
    }
    self.lastHeadsetConnected = [self.coordinator isHeadsetConnected];
    [self registerObservers];
}

- (void)setupViews {
    [self.view addSubview:self.auroraView];
    [self.view addSubview:self.modeSegment];
    [self.view addSubview:self.routePill];
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.bannerView];

    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain
                                        target:self action:@selector(onMoreTapped)],
        [[UIBarButtonItem alloc] initWithTitle:@"日志" style:UIBarButtonItemStylePlain
                                        target:self action:@selector(onLogTapped)],
    ];

    [self.modeSegment setSelectedMode:self.mode animated:NO];
    [self rebuildContentForMode];
    [self synchronizeFromCoordinator];
    [self replayCoordinatorHistory];
    [self refreshUI];
}

- (void)layoutViews {
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat bottomSafe = self.view.safeAreaInsets.bottom;

    self.auroraView.frame = self.view.bounds;
    self.modeSegment.frame = CGRectMake(20, topOffset + 6, width - 40, [TSAIChatModeSegment preferredHeight]);
    CGSize pillSize = [self.routePill sizeThatFits:CGSizeZero];
    self.routePill.frame = CGRectMake((width - pillSize.width) / 2, CGRectGetMaxY(self.modeSegment.frame) + 8,
                                      pillSize.width, pillSize.height);
    CGFloat contentTop = CGRectGetMaxY(self.routePill.frame) + 4;
    self.contentView.frame = CGRectMake(0, contentTop, width, height - contentTop);
    CGFloat contentHeight = CGRectGetHeight(self.contentView.bounds);

    CGSize bannerSize = [self.bannerView sizeThatFits:CGSizeMake(width - 36, 0)];
    self.bannerView.frame = CGRectMake(18, topOffset + 6, width - 36, bannerSize.height);

    if (self.mode == TSAIChatPageModeChat) {
        CGFloat dockInset = self.keyboardOverlap > 0 ? 0 : bottomSafe;
        CGFloat dockHeight = [TSAIChatDockView contentHeight] + dockInset;
        CGFloat dockTop = contentHeight - self.keyboardOverlap - dockHeight;
        self.dockView.frame = CGRectMake(0, dockTop, width, dockHeight);
        self.roundsScrollView.frame = CGRectMake(0, 0, width, MAX(0, dockTop));
        CGSize heroSize = [self.heroView sizeThatFits:CGSizeMake(width, 0)];
        self.heroView.frame = CGRectMake(0, MAX(0, (dockTop - heroSize.height) / 2), width, heroSize.height);
        [self layoutRounds];
    } else {
        CGFloat dockHeight = 8 + 68 + 6 + 16 + 8 + bottomSafe;
        CGFloat dockTop = contentHeight - dockHeight;
        self.flowCloseButton.frame = CGRectMake((width - 68) / 2, dockTop + 8, 68, 68);
        self.flowCloseGradient.frame = self.flowCloseButton.bounds;
        self.flowCloseLabel.frame = CGRectMake(0, dockTop + 8 + 68 + 6, width, 16);
        CGSize toggleSize = [self.flowToggle sizeThatFits:CGSizeZero];
        self.flowToggle.frame = CGRectMake(width - 18 - toggleSize.width, 6, toggleSize.width, toggleSize.height);
        CGFloat stageBottom = dockTop;
        if (self.flowState == TSAIChatFlowStateEnded) {
            CGFloat cardHeight = [TSAIChatEndCard preferredHeight];
            self.endCard.frame = CGRectMake(20, dockTop - 10 - cardHeight, width - 40, cardHeight);
            stageBottom = CGRectGetMinY(self.endCard.frame) - 10;
        }
        self.flowView.frame = CGRectMake(0, 0, width, MAX(0, stageBottom));
        self.transcriptView.frame = CGRectMake(0, 0, width, MAX(0, dockTop));
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 已有定位权限时静默取一次位置：天气 / 附近类问题启动时就能带上位置，不弹框
    [self.intentCoordinator prepareLocationContextSilently];
    [self.heroView restartAnimations];
    [self.flowView restartAnimations];
    [self.dockView restartAnimations];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // DEBUG：主线程卡顿探测（> 100 ms 打印），回归按下无响应的问题
    [TSAIMainThreadStallDetector startMonitoringForOwner:@"TSAIChatVC"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [TSAIMainThreadStallDetector stopMonitoringForOwner:@"TSAIChatVC"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.dockView.textField resignFirstResponder];
    [self.contextMenu dismiss];
    [self.audioSheet dismiss];
    [self.pcmPlayer stop];
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        // 离开页面：结束本页发起的会话；畅聊记录随页面清空（需求 C13）
        if ([self.coordinator isSessionActive]) {
            [self.coordinator stopSessionFromApp];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_intentCoordinator reset];
    [_recordTimer invalidate];
    [_preparingSlowTimer invalidate];
    [_pendingSwitchTimer invalidate];
    [_pcmPlayer stop];
}

#pragma mark - 私有方法 - 观察

/// 注册协调器、设备连接与键盘通知
- (void)registerObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onSessionPhaseDidChange:)
                   name:TSAIChatDeviceSessionDidChangeNotification object:self.coordinator];
    [center addObserver:self selector:@selector(onSessionDidReceiveContent:)
                   name:TSAIChatDeviceSessionDidReceiveContentNotification object:self.coordinator];
    [center addObserver:self selector:@selector(onSessionDidReceiveEvent:)
                   name:TSAIChatDeviceSessionDidReceiveEventNotification object:self.coordinator];
    [center addObserver:self selector:@selector(onSessionDidComplete:)
                   name:TSAIChatDeviceSessionDidCompleteNotification object:self.coordinator];
    [center addObserver:self selector:@selector(onDeviceRequestIgnored:)
                   name:TSAIChatDeviceSessionDidIgnoreDeviceRequestNotification object:self.coordinator];
    [center addObserver:self selector:@selector(onDeviceSnapshotChanged:)
                   name:TSDeviceConnectionSnapshotDidChangeNotification object:[TSDeviceCoordinator sharedInstance]];
    [center addObserver:self selector:@selector(onKeyboardWillChange:)
                   name:UIKeyboardWillChangeFrameNotification object:nil];
    [center addObserver:self selector:@selector(onKeyboardWillChange:)
                   name:UIKeyboardWillHideNotification object:nil];
    // 系统蓝牙耳机（HFP/A2DP）连接 / 断开：「耳机」选项的生效结果会变，刷新路由胶囊
    [center addObserver:self selector:@selector(onAudioRouteChanged:)
                   name:AVAudioSessionRouteChangeNotification object:nil];
    // SDK 耳机麦克风状态变化（入仓 / 取出、权限、充电仓连接）：「耳机」拾音的生效结果会变
    [center addObserver:self selector:@selector(onAudioRouteChanged:)
                   name:TSAIEarbudsMicrophoneStatusDidChangeNotification object:nil];
}

/// 系统音频路由变化
- (void)onAudioRouteChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshRoutePill];
    });
}

/// 页面进入时与协调器状态对齐（设备发起的畅聊已在进行中）；SessionStarted 不代表麦克风已开，以 InputReady 为准
- (void)synchronizeFromCoordinator {
    if (![self.coordinator isSessionActive] || self.mode != TSAIChatPageModeFlow) return;
    self.flowStartDate = [NSDate date];
    self.flowSessionStarted = self.coordinator.phase == TSAIChatDeviceSessionPhaseActive;
    self.flowState = self.coordinator.isInputReady ? TSAIChatFlowStateListening : TSAIChatFlowStateConnecting;
}

/// 回放页面打开前收到的内容与事件
- (void)replayCoordinatorHistory {
    for (TSAIChatContent *content in self.coordinator.contentHistory) {
        [self handleContent:content];
    }
    for (TSAIChatEvent *event in self.coordinator.eventHistory) {
        [self handleEvent:event];
    }
}

#pragma mark - 私有方法 - 视图切换

/// 按模式重建 content 区（只替换 content，公共部分不动）
- (void)rebuildContentForMode {
    for (UIView *subview in [self.contentView.subviews copy]) {
        [subview removeFromSuperview];
    }
    if (self.mode == TSAIChatPageModeChat) {
        [self.contentView addSubview:self.roundsScrollView];
        [self.contentView addSubview:self.heroView];
        [self.contentView addSubview:self.dockView];
        [self.heroView playEntrance];
        TSAIChatPopIn(self.dockView, 0.5, 0.1);
    } else {
        [self.contentView addSubview:self.flowView];
        [self.contentView addSubview:self.transcriptView];
        [self.contentView addSubview:self.endCard];
        [self.contentView addSubview:self.flowToggle];
        [self.contentView addSubview:self.flowCloseButton];
        [self.contentView addSubview:self.flowCloseLabel];
        TSAIChatPopIn(self.flowView, 0.5, 0);
    }
    [self.view setNeedsLayout];
    [self layoutViews];
}

/// 是否忙碌（规范 §5.1）
- (BOOL)isBusy {
    if (self.mode == TSAIChatPageModeChat) {
        return self.chatState != TSAIChatChatStateIdle && self.chatState != TSAIChatChatStateError;
    }
    return self.flowState != TSAIChatFlowStateIdle && self.flowState != TSAIChatFlowStateEnded;
}

/// 气色映射（规范 §2.1）
- (TSAIChatTone)currentTone {
    if (self.mode == TSAIChatPageModeChat) {
        switch (self.chatState) {
            case TSAIChatChatStatePreparing:
            case TSAIChatChatStateRecording:   return TSAIChatToneRecording;
            case TSAIChatChatStateRecognizing:
            case TSAIChatChatStateAnswering:   return TSAIChatToneThinking;
            case TSAIChatChatStateSpeaking:    return TSAIChatToneSpeaking;
            case TSAIChatChatStateError:       return TSAIChatToneError;
            default:                           return TSAIChatToneIdle;
        }
    }
    switch (self.flowState) {
        case TSAIChatFlowStateListening:
        case TSAIChatFlowStateHearing:   return TSAIChatToneRecording;
        case TSAIChatFlowStateThinking:  return TSAIChatToneThinking;
        case TSAIChatFlowStateSpeaking:  return TSAIChatToneSpeaking;
        default:                         return TSAIChatToneIdle;
    }
}

/// 统一刷新：气色、分段锁定、胶囊、dock、畅聊文案
- (void)refreshUI {
    BOOL busy = [self isBusy];
    [self.auroraView setTone:[self currentTone] animated:YES];
    self.modeSegment.locked = busy;
    [self refreshRoutePill];
    self.routePill.locked = busy;

    if (self.mode == TSAIChatPageModeChat) {
        self.heroView.hidden = self.rounds.count > 0;
        self.roundsScrollView.hidden = self.rounds.count == 0;
        self.dockView.busy = busy;
        self.dockView.pulseEnabled = self.chatState == TSAIChatChatStateIdle && self.rounds.count == 0;
        switch (self.chatState) {
            case TSAIChatChatStateRecognizing: self.dockView.hintText = @"正在识别…"; break;
            case TSAIChatChatStateAnswering:   self.dockView.hintText = @"AI 正在回答…"; break;
            case TSAIChatChatStateSpeaking:    self.dockView.hintText = @"播放中"; break;
            default:                           self.dockView.hintText = @""; break;
        }
    } else {
        [self refreshFlowStage];
    }
    [self.view setNeedsLayout];
}

#pragma mark - 私有方法 - 对话模式 · 轮次

/// 新建一轮并挂到消息流
- (TSAIChatRoundModel *)appendRoundWithSource:(TSAIChatRoundSource)source {
    TSAIChatRoundModel *round = [TSAIChatRoundModel roundWithSource:source];
    [self.rounds addObject:round];
    TSAIChatRoundView *roundView = [[TSAIChatRoundView alloc] initWithModel:round];
    roundView.delegate = self;
    self.roundViews[round.roundId] = roundView;
    [self.roundsScrollView addSubview:roundView];
    self.currentRound = round;
    [self refreshUI];
    [self layoutRounds];
    [roundView playEntranceIfNeeded];
    [self scrollRoundsToBottomAnimated:YES];
    return round;
}

/// 移除一轮
- (void)removeRound:(TSAIChatRoundModel *)round {
    if (!round) return;
    TSAIChatRoundView *roundView = self.roundViews[round.roundId];
    [UIView animateWithDuration:TSAIChatReduceMotion() ? 0 : 0.2
                     animations:^{
        roundView.alpha = 0;
        roundView.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }
                     completion:^(BOOL finished) {
        [roundView removeFromSuperview];
    }];
    [self.roundViews removeObjectForKey:round.roundId];
    [self.rounds removeObject:round];
    if (self.currentRound == round) self.currentRound = nil;
    [self refreshUI];
    [self layoutRounds];
}

/// 刷新当前轮视图（流式刷新，不重放入场）
- (void)refreshRound:(TSAIChatRoundModel *)round {
    if (!round) return;
    TSAIChatRoundView *roundView = self.roundViews[round.roundId];
    [roundView refresh];
    [self layoutRounds];
    [roundView playEntranceIfNeeded];
    [self scrollRoundsToBottomAnimated:YES];
}

/// 消息流布局：上 6、左右 18、下 20，轮距 14
- (void)layoutRounds {
    CGFloat width = CGRectGetWidth(self.roundsScrollView.bounds) - 36;
    if (width <= 0) return;
    CGFloat y = 6;
    for (TSAIChatRoundModel *round in self.rounds) {
        TSAIChatRoundView *roundView = self.roundViews[round.roundId];
        CGFloat height = [roundView heightForWidth:width];
        roundView.frame = CGRectMake(18, y, width, height);
        y += height + 14;
    }
    self.roundsScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.roundsScrollView.bounds), y - 14 + 20);
}

/// 新内容滚到底
- (void)scrollRoundsToBottomAnimated:(BOOL)animated {
    CGFloat bottom = self.roundsScrollView.contentSize.height - CGRectGetHeight(self.roundsScrollView.bounds);
    if (bottom > 0) {
        [self.roundsScrollView setContentOffset:CGPointMake(0, bottom) animated:animated];
    }
}

#pragma mark - 私有方法 - 对话模式 · 按住说话

/// 按下：新建语音轮、进入「准备中」并启动单轮会话；麦克风出数据（InputReady）后才进入「正在听」并开始计时
- (void)beginVoiceRound {
    NSTimeInterval pressUptime = NSProcessInfo.processInfo.systemUptime;
    [TSAIMainThreadStallDetector markContext:@"chat.press"];
    if ([self isBusy]) return;
    if ([self.coordinator isSessionActive]) {
        [self.coordinator stopSessionFromApp];
        [TSAIChatToastView showText:@"上一轮还在收尾，请稍后再试" inView:self.view];
        return;
    }
    if (![self ensureMicrophonePermissionForVoiceRound]) return;
    [self.contextMenu dismiss];
    self.sessionStarted = NO;
    self.discardingRound = NO;
    [self resetVoiceLatencyWithPressUptime:pressUptime];
    [self.dockView enterPreparingWithCancelTarget:YES hint:@"准备中…"];
    [self appendRoundWithSource:TSAIChatRoundSourceVoice];
    self.chatState = TSAIChatChatStatePreparing;
    [self refreshUI];
    [self startPreparingSlowTimer];
    TSAIChatConfig *config = [self.coordinator sessionConfigForMode:TSAIChatConversationModeSingleRound
                                                        voiceInput:YES
                                                endsInputOnSilence:NO];
    [self.coordinator startSessionFromAppWithConfig:config];
    self.voiceStartReturnedUptime = NSProcessInfo.processInfo.systemUptime;
}

/// InputReady：「准备中」→「正在听」（选择触感、提示、波形，计时从此刻开始）
- (void)enterListeningForVoiceRound {
    if (self.chatState != TSAIChatChatStatePreparing || !self.dockView.isRecording) return;
    [TSAIMainThreadStallDetector markContext:@"chat.inputReady"];
    self.voiceInputReadyUptime = NSProcessInfo.processInfo.systemUptime;
    [self stopPreparingSlowTimer];
    self.chatState = TSAIChatChatStateRecording;
    [self.dockView enterListeningWithHint:@"正在听你说 · 松开发送，上滑取消"];
    [self refreshUI];
    [self startRecordTimer];
    TSLog(@"[TSAIChatVC] voice input ready: press→inputReady=%.0f ms",
          (self.voiceInputReadyUptime - self.voicePressUptime) * 1000.0);
}

/// 手机麦克风或耳机麦克风路由下检查录音权限（TSAIKit）：手机麦没有权限时只会送出静音，
/// 耳机麦没有权限时 SDK 以 1021 失败
- (BOOL)ensureMicrophonePermissionForVoiceRound {
    BOOL headset = [self.coordinator isHeadsetConnected];
    TSAIAudioInputChannel input =
        [[TSAIChatAudioPreference preferenceForConversationMode:TSAIChatConversationModeSingleRound] inputChannelWithHeadset:headset];
    if (input != TSAIAudioInputChannelBuiltInMic && input != TSAIAudioInputChannelSCO) return YES;
    switch ([TSAIKit microphonePermissionStatus]) {
        case TSAIMicrophonePermissionStatusGranted:
            return YES;
        case TSAIMicrophonePermissionStatusDenied: {
            TSLog(@"[TSAIChatVC] voice round blocked: microphone permission denied");
            [self showMicrophonePermissionDeniedBanner];
            return NO;
        }
        default: {
            // 首次使用：先弹系统授权，授权后再按住说话（系统弹窗会打断本次长按）
            TSLog(@"[TSAIChatVC] voice round deferred: requesting microphone permission");
            __weak typeof(self) weakSelf = self;
            [TSAIEarbudsMicrophoneUI requestMicrophonePermission:^(BOOL granted) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;
                TSLog(@"[TSAIChatVC] microphone permission result: granted=%d", granted);
                if (granted) {
                    [TSAIChatToastView showText:@"已获得麦克风权限，请再次按住说话" inView:strongSelf.view];
                } else {
                    [strongSelf.bannerView showText:@"没有麦克风权限，无法用手机或耳机说话"
                                             symbol:@"mic.slash.fill"
                                              style:TSAIChatBannerStyleError
                                        actionTitle:nil
                                             action:nil
                                           duration:4];
                }
            }];
            return NO;
        }
    }
}

/// 没有麦克风权限：横幅引导到系统设置
- (void)showMicrophonePermissionDeniedBanner {
    [self.bannerView showText:@"没有麦克风权限，无法用手机或耳机说话。请在系统设置中允许 TopStep 使用麦克风"
                       symbol:@"mic.slash.fill"
                        style:TSAIChatBannerStyleError
                  actionTitle:@"去设置"
                       action:^{
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (url) [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
                     duration:6];
}

/// 松手（方案图 19）：准备中 → 丢弃（按下不足 0.5 秒「说话时间太短」，否则「麦克风还没准备好」）；
/// 正在听 → 收听不足 0.5 秒丢弃，否则结束输入；其他（SDK 已静默收口）→ 只收起录音 UI
- (void)handleVoicePressEndedCancelled:(BOOL)cancelled {
    NSTimeInterval releaseUptime = NSProcessInfo.processInfo.systemUptime;
    [TSAIMainThreadStallDetector markContext:@"chat.release"];
    if (cancelled) {
        [self discardVoiceRoundWithToast:@"已取消" outcome:@"cancelled" releaseUptime:releaseUptime];
        return;
    }
    if (self.chatState == TSAIChatChatStatePreparing) {
        // 麦克风还没出过任何数据：这一轮没有可用的录音，直接丢弃
        BOOL tooShort = releaseUptime - self.voicePressUptime < kTSAIChatMinimumPressDuration;
        [self discardVoiceRoundWithToast:tooShort ? @"说话时间太短" : @"麦克风还没准备好，等提示后再说"
                                 outcome:tooShort ? @"tooShort" : @"notReady"
                           releaseUptime:releaseUptime];
        return;
    }
    if (self.chatState == TSAIChatChatStateRecording &&
        releaseUptime - self.voiceInputReadyUptime < kTSAIChatMinimumPressDuration) {
        [self discardVoiceRoundWithToast:@"说话时间太短" outcome:@"tooShort" releaseUptime:releaseUptime];
        return;
    }
    [self finishVoiceInputWithReleaseUptime:releaseUptime];
}

/// 结束输入：录音 UI 只跟手指走，无条件收起；正在听 → 识别中并结束输入。
/// SDK 可能在松手前已静默收口并把本轮推进到识别 / 回答态，此时只收 UI、不回退状态，
/// finishInputFromApp 对已结束的输入是 no-op。releaseUptime 为 0 表示满 60 秒自动结束
- (void)finishVoiceInputWithReleaseUptime:(NSTimeInterval)releaseUptime {
    BOOL listening = self.chatState == TSAIChatChatStateRecording;
    NSTimeInterval endUptime = releaseUptime > 0 ? releaseUptime : NSProcessInfo.processInfo.systemUptime;
    NSString *outcome = listening ? (releaseUptime > 0 ? @"sent" : @"maxDuration") : @"closedBySDK";
    [self exitVoiceRecordingWithOutcome:outcome releaseUptime:releaseUptime];
    TSAIChatRoundModel *round = self.currentRound;
    if (!round) {
        [self refreshUI];
        return;
    }
    if (round.inputDuration <= 0 && self.voiceInputReadyUptime > 0) {
        round.inputDuration = endUptime - self.voiceInputReadyUptime;
    }
    if (listening) {
        round.state = TSAIChatRoundStateRecognizing;
        self.chatState = TSAIChatChatStateRecognizing;
    }
    [self refreshRound:round];
    [self refreshUI];
    // InputReady 一定在 SessionStarted 之后，正在听时会话必然已启动
    [self.coordinator finishInputFromApp];
}

/// 丢弃当前语音轮（上滑取消 / 太短 / 麦克风还没准备好）并结束会话
- (void)discardVoiceRoundWithToast:(NSString *)toast
                           outcome:(NSString *)outcome
                     releaseUptime:(NSTimeInterval)releaseUptime {
    [self exitVoiceRecordingWithOutcome:outcome releaseUptime:releaseUptime];
    TSAIChatRoundModel *round = self.currentRound;
    self.discardingRound = [self.coordinator isSessionActive];
    [self removeRound:round];
    self.chatState = TSAIChatChatStateIdle;
    [self refreshUI];
    [self.coordinator stopSessionFromApp];
    [TSAIChatToastView showText:toast inView:self.view];
}

/// 收起录音 UI（停计时、退出录音条）；本轮时延日志还没输出时一并输出
- (void)exitVoiceRecordingWithOutcome:(NSString *)outcome releaseUptime:(NSTimeInterval)releaseUptime {
    [self stopRecordTimer];
    [self stopPreparingSlowTimer];
    [self.dockView exitRecording];
    [self logVoiceLatencyWithReleaseUptime:releaseUptime outcome:outcome];
}

/// 录音计时（0.1s，从 InputReady 起），满 60s 自动结束输入
- (void)startRecordTimer {
    [self.recordTimer invalidate];
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                        target:self
                                                      selector:@selector(onRecordTick)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)stopRecordTimer {
    [self.recordTimer invalidate];
    self.recordTimer = nil;
}

/// 「准备中」超过 3 秒提示「麦克风启动较慢…」
- (void)startPreparingSlowTimer {
    [self.preparingSlowTimer invalidate];
    self.preparingSlowTimer = [NSTimer scheduledTimerWithTimeInterval:kTSAIChatPreparingSlowHintDelay
                                                               target:self
                                                             selector:@selector(onPreparingSlow)
                                                             userInfo:nil
                                                              repeats:NO];
}

- (void)stopPreparingSlowTimer {
    [self.preparingSlowTimer invalidate];
    self.preparingSlowTimer = nil;
}

#pragma mark - 私有方法 - 对话模式 · 时延日志

/// 新一轮：清空时延记录（文字提问传 0，之后不再输出）
- (void)resetVoiceLatencyWithPressUptime:(NSTimeInterval)pressUptime {
    self.voicePressUptime = pressUptime;
    self.voiceStartReturnedUptime = 0;
    self.voiceInputReadyUptime = 0;
    self.voiceLatencyLogged = NO;
}

/// 输出本轮 [voiceLatency]（每轮一次）；releaseUptime 为 0 表示没有松手（出错 / 满 60 秒 / 会话被结束）
- (void)logVoiceLatencyWithReleaseUptime:(NSTimeInterval)releaseUptime outcome:(NSString *)outcome {
    if (self.voiceLatencyLogged || self.voicePressUptime <= 0) return;
    self.voiceLatencyLogged = YES;
    NSTimeInterval press = self.voicePressUptime;
    NSTimeInterval ready = self.voiceInputReadyUptime;
    TSLog(@"[voiceLatency] press→startChatReturned=%@ press→inputReady=%@ press→release=%@ ready→release=%@ outcome=%@",
          [self latencyTextFrom:press to:self.voiceStartReturnedUptime],
          [self latencyTextFrom:press to:ready],
          [self latencyTextFrom:press to:releaseUptime],
          [self latencyTextFrom:ready to:releaseUptime],
          outcome);
}

/// 两个时刻之差（毫秒）的日志文本；任一时刻缺失为「-」
- (NSString *)latencyTextFrom:(NSTimeInterval)from to:(NSTimeInterval)to {
    if (from <= 0 || to <= 0) return @"-";
    return [NSString stringWithFormat:@"%.0f ms", (to - from) * 1000.0];
}

#pragma mark - 私有方法 - 对话模式 · 麦克风错误

/// 语音轮的麦克风错误（方案 9.1）：权限 → 引导到设置；Busy →「麦克风正被其他功能使用」；1023 →「录音被中断」；
/// 其他启动失败 →「麦克风暂不可用」。已有回答或不是麦克风错误时返回 NO，按原有方式处理
- (BOOL)failVoiceRoundForMicrophoneError:(NSError *)error
                                   round:(nullable TSAIChatRoundModel *)round
                               preparing:(BOOL)preparing {
    if (!round || round.source != TSAIChatRoundSourceVoice || round.answer.length > 0) return NO;
    NSString *reason = [self microphoneFailureReasonForError:error preparing:preparing];
    if (reason.length == 0) return NO;
    TSLog(@"[TSAIChatVC] voice round microphone failure: code=%ld, preparing=%d, reason=%@, error=%@",
          (long)error.code, preparing, reason, error);
    round.errorBodyText = [self microphoneFailureBodyForError:error];
    if (error.code == TSAIErrorCodeMicrophonePermissionDenied) {
        [self showMicrophonePermissionDeniedBanner];
    }
    [self failCurrentRoundWithText:reason];
    return YES;
}

/// 麦克风错误的短提示；不是麦克风错误时为 nil（preparing：麦克风还没出过数据，启动类失败按「麦克风暂不可用」）
- (nullable NSString *)microphoneFailureReasonForError:(nullable NSError *)error preparing:(BOOL)preparing {
    if (![error.domain isEqualToString:TSAIErrorDomain]) return nil;
    switch (error.code) {
        case TSAIErrorCodeMicrophonePermissionDenied:
            return @"没有麦克风权限";
        case TSAIErrorCodeBusy:
            return @"麦克风正被其他功能使用";
        case TSAIErrorCodeAudioInputLost:
            return @"录音被中断";
        case TSAIErrorCodeEarbudsMicrophoneUnavailable:
            return @"麦克风暂不可用";
        default:
            break;
    }
    // 启动失败：SDK 在错误里标记 audioFailurePhase = start；播放链路（audioFailureScope = output）不算麦克风
    if ([error.userInfo[@"audioFailureScope"] isEqual:@"output"]) return nil;
    BOOL startFailure = [error.userInfo[@"audioFailurePhase"] isEqual:@"start"];
    BOOL routeFailure = error.code == TSAIErrorCodeAudioRouteUnavailable || error.code == TSAIErrorCodeAudioRouteMismatch;
    return (startFailure || (preparing && routeFailure)) ? @"麦克风暂不可用" : nil;
}

/// 麦克风错误在 AI 气泡里的说明
- (NSString *)microphoneFailureBodyForError:(NSError *)error {
    switch (error.code) {
        case TSAIErrorCodeMicrophonePermissionDenied:
            return @"没有麦克风权限。请在系统设置中允许 TopStep 使用麦克风，然后再按住说话。";
        case TSAIErrorCodeBusy:
            return @"麦克风正被 AI 录音、同声传译等其他功能使用，结束后再按住说话。";
        case TSAIErrorCodeAudioInputLost:
            return [self inputLostBodyForError:error];
        case TSAIErrorCodeEarbudsMicrophoneUnavailable:
            return [TSAIEarbudsMicrophoneUI descriptionForEarbudsMicrophoneError:error];
        default:
            return @"麦克风没能启动，请稍后重新按住说话。";
    }
}

/// 1023 按丢失原因给出说明
- (NSString *)inputLostBodyForError:(NSError *)error {
    TSAIAudioInputLostReason reason = [error.userInfo[TSAIErrorUserInfoAudioInputLostReasonKey] integerValue];
    switch (reason) {
        case TSAIAudioInputLostReasonTimeout:
            return [TSAIEarbudsMicrophoneUI descriptionForEarbudsMicrophoneError:error];
        case TSAIAudioInputLostReasonUserRouteChange:
            return @"音频被切离了耳机，录音中断。请重新按住说话。";
        case TSAIAudioInputLostReasonInterrupted:
            return @"录音被系统打断（如来电、闹钟、Siri）。请重新按住说话。";
        case TSAIAudioInputLostReasonPreempted:
            return @"麦克风被其他功能接管，录音中断。请重新按住说话。";
        case TSAIAudioInputLostReasonSessionReconfigured:
            return @"音频会话被其他功能反复改写，录音中断。请重新按住说话。";
        case TSAIAudioInputLostReasonMediaServicesReset:
            return @"系统音频服务已重置，录音中断。请重新按住说话。";
        default:
            return @"录音中途被打断，请重新按住说话。";
    }
}

#pragma mark - 私有方法 - 对话模式 · 文字提问

/// 文字提问：None 路由启动单轮，SessionStarted 后 sendChatText
- (void)sendTextQuestion:(NSString *)text {
    if (text.length == 0 || [self isBusy]) return;
    if ([self.coordinator isSessionActive]) {
        [self.coordinator stopSessionFromApp];
        [TSAIChatToastView showText:@"上一轮还在收尾，请稍后再试" inView:self.view];
        return;
    }
    [self.contextMenu dismiss];
    self.sessionStarted = NO;
    self.discardingRound = NO;
    [self resetVoiceLatencyWithPressUptime:0];
    self.pendingText = text;
    TSAIChatRoundModel *round = [self appendRoundWithSource:TSAIChatRoundSourceText];
    round.question = text;
    round.questionFinal = YES;
    round.state = TSAIChatRoundStateAnswering;
    self.chatState = TSAIChatChatStateAnswering;
    [self refreshRound:round];
    [self refreshUI];
    TSAIChatConfig *config = [self.coordinator sessionConfigForMode:TSAIChatConversationModeSingleRound
                                                        voiceInput:NO
                                                endsInputOnSilence:YES];
    [self.coordinator startSessionFromAppWithConfig:config];
}

#pragma mark - 私有方法 - 对话模式 · 回调

/// 对话模式事件
- (void)handleChatEvent:(TSAIChatEvent *)event {
    TSAIChatRoundModel *round = self.currentRound;
    switch (event.eventType) {
        case TSAIChatEventTypeSessionStarted:
            // 会话已受理；语音轮的麦克风未必已开，「正在听」以 InputReady 为准
            self.sessionStarted = YES;
            if (self.pendingText.length > 0) {
                NSString *text = self.pendingText;
                self.pendingText = nil;
                if (![self.coordinator sendTextFromApp:text]) {
                    [self failCurrentRoundWithText:@"发送失败"];
                    [self.coordinator stopSessionFromApp];
                }
            }
            break;
        case TSAIChatEventTypeInputReady:
            [self enterListeningForVoiceRound];
            break;
        case TSAIChatEventTypeAIPlaybackStarted:
            if (round && [round isInProgress]) {
                round.state = TSAIChatRoundStateSpeaking;
                self.chatState = TSAIChatChatStateSpeaking;
                [self refreshRound:round];
                [self refreshUI];
            }
            break;
        case TSAIChatEventTypeAIPlaybackEnded:
        case TSAIChatEventTypeAIPlaybackInterrupted:
            if (round && [round isInProgress]) {
                round.state = TSAIChatRoundStateDone;
                [self refreshRound:round];
            }
            break;
        case TSAIChatEventTypeRoundCompleted:
            // 本轮完成；胶囊在 completion 到达后恢复（SDK 随即优雅停止会话）
            if (round && [round isInProgress]) {
                round.state = TSAIChatRoundStateDone;
                [self refreshRound:round];
            }
            break;
        case TSAIChatEventTypeAutoEnding:
            // 单轮下该事件只在「输入结束后迟迟没有识别结果 / 回答」的等待超时时发出：
            // 此刻就把本轮置为失败，不再等 completion（厂商 stop 不回 finish 时 completion 可能迟到数秒甚至不来）
            if (round && [round isInProgress] && round.answer.length == 0) {
                if (round.question.length > 0) {
                    round.errorBodyText = @"AI 没有给出回答，请换个说法再问一次。";
                    [self failCurrentRoundWithText:@"没有收到回答"];
                } else {
                    [self failCurrentRoundWithText:@"没有听到声音"];
                }
            }
            break;
        case TSAIChatEventTypeNetworkError:
            [self failCurrentRoundWithText:@"网络异常"];
            break;
        case TSAIChatEventTypeBleDisconnected:
            [self failCurrentRoundWithText:@"耳机已断开"];
            break;
        case TSAIChatEventTypeIntentActionTimedOut:
            if (round && [round isInProgress]) {
                [self.intentCoordinator handleIntentActionTimedOutForRound:round];
            }
            break;
        default:
            break;
    }
}

/// 对话模式内容
- (void)handleChatContent:(TSAIChatContent *)content {
    TSAIChatRoundModel *round = self.currentRound;
    if (!round || ![round isInProgress]) return;
    switch (content.contentType) {
        case TSAIChatContentTypeQuestion:
            if (round.source == TSAIChatRoundSourceVoice || round.question.length == 0) {
                round.question = content.text;
            }
            round.questionFinal = content.isTextFinal || round.source == TSAIChatRoundSourceText;
            if (content.isTextFinal && round.state <= TSAIChatRoundStateRecognizing) {
                round.state = TSAIChatRoundStateAnswering;
                self.chatState = TSAIChatChatStateAnswering;
            }
            [self refreshRound:round];
            [self refreshUI];
            break;
        case TSAIChatContentTypeAnswer:
            round.answer = content.text;
            round.answerFinal = content.isTextFinal;
            if (round.state <= TSAIChatRoundStateRecognizing) {
                round.state = TSAIChatRoundStateAnswering;
            }
            if (self.chatState < TSAIChatChatStateAnswering) {
                self.chatState = TSAIChatChatStateAnswering;
            }
            [self.intentCoordinator roundDidReceiveAnswer:round];
            [self refreshRound:round];
            [self refreshUI];
            break;
        case TSAIChatContentTypeAudioChunk:
            if (content.audioChunk.length > 0) {
                [round.answerPCM appendData:content.audioChunk];
            }
            break;
        case TSAIChatContentTypeIntent:
            if (content.intent) {
                [round.intents addObject:content.intent];
                [self refreshRound:round];
                [self.intentCoordinator handleIntent:content.intent round:round];
            }
            break;
        default:
            break;
    }
}

/// 对话模式完成
- (void)handleChatCompletionWithReport:(TSAIChatReport *)report error:(NSError *)error {
    // 还按着就结束了（如麦克风启动失败）：记下当时是否仍在「准备中」，用于错误提示
    BOOL preparing = self.chatState == TSAIChatChatStatePreparing;
    [self exitVoiceRecordingWithOutcome:error ? @"failed" : @"sessionEnded" releaseUptime:0];
    [self.intentCoordinator reset];
    self.sessionStarted = NO;
    self.pendingText = nil;
    if (self.discardingRound) {
        self.discardingRound = NO;
        self.chatState = TSAIChatChatStateIdle;
        [self refreshUI];
        return;
    }
    if (!error && report.endReason == TSAIChatEndReasonDialogExit) {
        // 语音「退出对话」：SDK 已结束会话。意图通常先到并已处理；没到时在这里兜底退出，不按「没有收到回答」处理
        [self exitChatByVoiceWithRound:self.currentRound];
        return;
    }
    TSAIChatRoundModel *round = self.currentRound;
    if (round && ![round isInProgress] && round.answer.length == 0 &&
        round.intentStatus == TSAIChatRoundIntentStatusUnsupported) {
        // 本轮已按「当前设备暂不支持」收口、App 随后主动停了会话：停止带来的取消错误不再改写本轮，也不切出错气色
        self.chatState = TSAIChatChatStateIdle;
        [self refreshUI];
        return;
    }
    if (error) {
        if ([self failVoiceRoundForMicrophoneError:error round:round preparing:preparing]) {
            return;
        }
        NSString *reason = error.localizedDescription.length > 0 ? error.localizedDescription : @"出错了";
        if ([error.domain isEqualToString:TSAIErrorDomain] &&
            (error.code == TSAIErrorCodeAudioRouteUnavailable ||
             error.code == TSAIErrorCodeAudioRouteMismatch ||
             error.code == TSAIErrorCodeNotSupported)) {
            // 音频路由解析失败（文字轮多为播放通道不可用）：给可操作的提示而不是原始错误文案
            reason = @"当前语音播放通道不可用，请在设置里切换「语音播放」后重试";
        } else if ([error.domain isEqualToString:TSAIErrorDomain] &&
                   error.code == TSAIErrorCodeIntentActionRequired) {
            // 云端要位置、App 没能及时补上（权限弹窗未处理 / 定位失败）
            reason = @"需要位置信息才能回答";
            if (round) round.errorBodyText = @"这个问题需要你的位置。允许定位后再问一次试试。";
        }
        if (round && round.answer.length > 0) {
            // 回答已经到了（例如 TTS 阶段配额不足）：保留回答，错误用横幅提示，不覆盖成「没听清」
            round.state = TSAIChatRoundStateDone;
            [self refreshRound:round];
            self.chatState = TSAIChatChatStateIdle;
            [self refreshUI];
            [self.bannerView showText:[NSString stringWithFormat:@"回答后出错：%@", reason] symbol:@"exclamationmark.triangle.fill"
                                style:TSAIChatBannerStyleError actionTitle:nil action:nil duration:4];
            return;
        }
        [self failCurrentRoundWithText:reason];
        return;
    }
    if (round && [round isInProgress]) {
        if (round.answer.length == 0) {
            // 识别到了问题却没有回答（如云端等待定位后静默结束）也算失败，不再静默置为「已回答」
            BOOL heardNothing = round.question.length == 0;
            if (!heardNothing) {
                round.errorBodyText = @"AI 没有给出回答，请换个说法再问一次。";
            }
            [self failCurrentRoundWithText:heardNothing
                 ? (report.endReason == TSAIChatEndReasonTimeout ? @"没有听到声音" : @"没有收到回答")
                 : @"没有收到回答"];
            return;
        }
        round.state = TSAIChatRoundStateDone;
        [self refreshRound:round];
    }
    self.chatState = TSAIChatChatStateIdle;
    [self refreshUI];
}

/// 当前轮置为出错
- (void)failCurrentRoundWithText:(NSString *)text {
    [self exitVoiceRecordingWithOutcome:@"failed" releaseUptime:0];
    TSAIChatRoundModel *round = self.currentRound;
    if (!round) {
        self.chatState = TSAIChatChatStateIdle;
        [self refreshUI];
        return;
    }
    if ([round isInProgress]) {
        round.state = TSAIChatRoundStateError;
        round.errorText = text;
        [self refreshRound:round];
    }
    self.chatState = TSAIChatChatStateError;
    [self refreshUI];
}

#pragma mark - 私有方法 - 畅聊模式

/// 切到 AI 畅聊：先弹「拾音与语音播放」（AI 畅聊自己的选择），点「完成」后才开始畅聊与拾音。
/// 设备已发起畅聊时直接跟随，不再弹出；「重新开始」不经过这里，直接沿用上次选择。
- (void)presentFlowAudioSheetThenStart {
    if ([self.coordinator isSessionActive]) {
        [self startFlowSession];
        return;
    }
    [self.flowRounds removeAllObjects];
    self.flowCurrentRound = nil;
    self.flowEndReason = nil;
    self.flowShowingTranscript = NO;
    [self.transcriptView clear];
    self.endCard.hidden = YES;
    self.flowState = TSAIChatFlowStateIdle;
    [self refreshUI];
    [self.audioSheet dismiss];
    __weak typeof(self) weakSelf = self;
    self.audioSheet = [TSAIChatAudioSheet showConfirmInView:self.view
                                          headsetConnected:[self.coordinator isHeadsetConnected]
                                          conversationMode:TSAIChatConversationModeContinuous
                                                  onChange:^{
        [weakSelf refreshRoutePill];
    }
                                                 onConfirm:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || strongSelf.mode != TSAIChatPageModeFlow) return;
        if (strongSelf.flowState != TSAIChatFlowStateIdle && ![strongSelf.coordinator isSessionActive]) return;
        [strongSelf startFlowSession];
    }];
}

/// 进入畅聊：立即 connecting 并启动多轮会话
- (void)startFlowSession {
    [self.flowRounds removeAllObjects];
    self.flowCurrentRound = nil;
    self.flowEndReason = nil;
    self.flowShowingTranscript = NO;
    [self.transcriptView clear];
    self.endCard.hidden = YES;
    self.flowStartDate = [NSDate date];
    if ([self.coordinator isSessionActive]) {
        // 设备已发起：直接跟随协调器（SessionStarted 不代表麦克风已开，「在听」以 InputReady 为准）
        self.flowSessionStarted = self.coordinator.phase == TSAIChatDeviceSessionPhaseActive;
        self.flowState = self.coordinator.isInputReady ? TSAIChatFlowStateListening : TSAIChatFlowStateConnecting;
        [self refreshUI];
        return;
    }
    self.flowSessionStarted = NO;
    self.flowState = TSAIChatFlowStateConnecting;
    [self refreshUI];
    TSAIChatConfig *config = [self.coordinator sessionConfigForMode:TSAIChatConversationModeContinuous
                                                        voiceInput:YES
                                                endsInputOnSilence:YES];
    [self.coordinator startSessionFromAppWithConfig:config];
}

/// 畅聊主区：光球态、文案、当前轮文字、光球/记录切换、关闭键
- (void)refreshFlowStage {
    TSAIChatOrbState orbState = TSAIChatOrbStateIdle;
    NSString *title = @"";
    NSString *subtitle = @"";
    switch (self.flowState) {
        case TSAIChatFlowStateConnecting:
            // 光球停在「连接中」直到 InputReady；会话已建立时副标题改为等待麦克风
            orbState = TSAIChatOrbStateConnecting; title = @"正在连接";
            subtitle = self.flowSessionStarted ? @"正在打开麦克风…" : @"激活耳机 AI 并建立会话";
            break;
        case TSAIChatFlowStateListening:
            orbState = TSAIChatOrbStateListening; title = @"我在听"; subtitle = @"直接说话就好"; break;
        case TSAIChatFlowStateHearing:
            orbState = TSAIChatOrbStateHearing; title = @"听到了"; break;
        case TSAIChatFlowStateThinking:
            orbState = TSAIChatOrbStateThinking; title = @"想一想"; break;
        case TSAIChatFlowStateSpeaking:
            orbState = TSAIChatOrbStateSpeaking;
            if (self.coordinator.activeSessionConfig && !self.coordinator.activeSessionConfig.enableVoiceOutput) {
                title = @"回答中"; subtitle = @"语音播放已关闭 · 说话可以打断";
            } else {
                title = @""; subtitle = @"说话或点击光球可以打断";
            }
            break;
        case TSAIChatFlowStateEnded:
            orbState = TSAIChatOrbStateEnded; title = @"畅聊已结束"; subtitle = self.flowEndReason ?: @""; break;
        case TSAIChatFlowStateIdle:
            title = @"选择拾音与语音播放"; subtitle = @"点击「完成」后开始畅聊"; break;
        default:
            break;
    }
    if (self.flowView.orbState != orbState) self.flowView.orbState = orbState;
    self.flowView.statusTitle = title;
    self.flowView.statusSubtitle = subtitle;

    TSAIChatRoundModel *round = self.flowCurrentRound;
    BOOL ended = self.flowState == TSAIChatFlowStateEnded;
    self.flowView.questionText = ended ? @"" : round.question;
    self.flowView.answerText = ended ? @"" : round.answer;
    self.flowView.answerCursorVisible = self.flowState == TSAIChatFlowStateSpeaking && !round.answerFinal;

    BOOL showTranscript = self.flowShowingTranscript && !ended;
    self.flowView.hidden = showTranscript;
    self.transcriptView.hidden = !showTranscript;
    self.flowToggle.hidden = ended;
    [self.flowToggle setCurrentStage:showTranscript ? TSAIChatFlowStageTranscript : TSAIChatFlowStageOrb animated:NO];
    [self.view setNeedsLayout];
    if (showTranscript) {
        self.transcriptView.emptyText = title.length > 0 ? title : @"…";
        [self.transcriptView updateWithRounds:[self.flowRounds copy] thinking:self.flowState == TSAIChatFlowStateThinking];
    }

    // 未开始（等待选择拾音 / 播放）与已结束都用主按钮样式：「开始」重新弹出选择，「重新开始」沿用上次选择
    BOOL notStarted = self.flowState == TSAIChatFlowStateIdle && ![self.coordinator isSessionActive];
    BOOL primary = ended || notStarted;
    self.flowCloseLabel.text = ended ? @"重新开始" : (notStarted ? @"开始" : @"关闭");
    NSString *closeSymbol = ended ? @"arrow.clockwise" : (notStarted ? @"play.fill" : @"xmark");
    self.flowCloseIcon.image = TSAIChatSymbol(closeSymbol, 22, UIImageSymbolWeightBold);
    self.flowCloseIcon.tintColor = primary ? [UIColor whiteColor] : TSAIChatInkColor();
    self.flowCloseGradient.hidden = !primary;
    self.flowCloseButton.backgroundColor = primary ? [UIColor clearColor] : TSAIChatGlassColor();
    self.flowCloseButton.layer.borderColor = primary ? [UIColor clearColor].CGColor : TSAIChatGlassLineColor().CGColor;
}

/// 畅聊：取/建 roundIndex 对应的轮
- (TSAIChatRoundModel *)flowRoundForIndex:(NSInteger)roundIndex {
    TSAIChatRoundModel *current = self.flowCurrentRound;
    if (current && [current isInProgress] && (current.sdkRoundIndex == roundIndex || current.sdkRoundIndex < 0)) {
        current.sdkRoundIndex = roundIndex;
        return current;
    }
    for (TSAIChatRoundModel *round in self.flowRounds) {
        if (round.sdkRoundIndex == roundIndex) return round;
    }
    TSAIChatRoundModel *round = [TSAIChatRoundModel roundWithSource:TSAIChatRoundSourceVoice];
    round.state = TSAIChatRoundStateRecognizing;
    round.sdkRoundIndex = roundIndex;
    [self.flowRounds addObject:round];
    self.flowCurrentRound = round;
    return round;
}

/// 畅聊：归档当前轮
- (void)archiveFlowRoundTruncated:(BOOL)truncated {
    TSAIChatRoundModel *round = self.flowCurrentRound;
    if (!round) return;
    if (truncated && round.answer.length > 0 && !round.answerFinal) {
        round.answer = [round.answer stringByAppendingString:@"…"];
    }
    round.answerFinal = YES;
    round.questionFinal = YES;
    round.state = TSAIChatRoundStateDone;
    if (![self.flowRounds containsObject:round]) [self.flowRounds addObject:round];
}

/// 畅聊事件
- (void)handleFlowEvent:(TSAIChatEvent *)event {
    switch (event.eventType) {
        case TSAIChatEventTypeSessionStarted:
            // 会话已受理，麦克风未必已开：光球停在「连接中」，等 InputReady 再切到「在听」
            self.flowStartDate = [NSDate date];
            self.flowSessionStarted = YES;
            if (self.flowState == TSAIChatFlowStateIdle) {
                self.flowState = TSAIChatFlowStateConnecting;
            }
            break;
        case TSAIChatEventTypeInputReady:
            if (self.flowState == TSAIChatFlowStateIdle || self.flowState == TSAIChatFlowStateConnecting) {
                self.flowState = TSAIChatFlowStateListening;
            }
            break;
        case TSAIChatEventTypeUserSpeechStarted: {
            if (self.flowState == TSAIChatFlowStateSpeaking) {
                [self archiveFlowRoundTruncated:YES];
            }
            TSAIChatRoundModel *current = self.flowCurrentRound;
            if (!current || ![current isInProgress]) {
                TSAIChatRoundModel *round = [TSAIChatRoundModel roundWithSource:TSAIChatRoundSourceVoice];
                round.state = TSAIChatRoundStateRecognizing;
                [self.flowRounds addObject:round];
                self.flowCurrentRound = round;
            }
            self.flowState = TSAIChatFlowStateHearing;
            break;
        }
        case TSAIChatEventTypeUserSpeechEnded:
        case TSAIChatEventTypeInputFinished:
            if (self.flowState == TSAIChatFlowStateHearing) {
                self.flowState = TSAIChatFlowStateThinking;
            }
            break;
        case TSAIChatEventTypeAIPlaybackStarted:
            if (self.flowCurrentRound) self.flowCurrentRound.state = TSAIChatRoundStateSpeaking;
            self.flowState = TSAIChatFlowStateSpeaking;
            break;
        case TSAIChatEventTypeAIPlaybackEnded:
            [self archiveFlowRoundTruncated:NO];
            self.flowState = TSAIChatFlowStateListening;
            break;
        case TSAIChatEventTypeAIPlaybackInterrupted:
            [self archiveFlowRoundTruncated:YES];
            self.flowState = TSAIChatFlowStateListening;
            break;
        case TSAIChatEventTypeRoundCompleted:
            if (self.flowCurrentRound && [self.flowCurrentRound isInProgress] && self.flowState != TSAIChatFlowStateSpeaking) {
                [self archiveFlowRoundTruncated:NO];
                self.flowState = TSAIChatFlowStateListening;
            }
            break;
        case TSAIChatEventTypeAutoEnding: {
            // 「继续」= 提示用户直接说话即可，不调 SDK
            [self.bannerView showText:@"一会儿没听到你说话，10 秒后自动结束"
                               symbol:@"clock"
                                style:TSAIChatBannerStyleInfo
                          actionTitle:@"继续"
                               action:nil
                             duration:10];
            break;
        }
        case TSAIChatEventTypeNetworkError:
            [self.bannerView showText:@"网络连接中断，畅聊已结束" symbol:@"wifi.slash"
                                style:TSAIChatBannerStyleError actionTitle:nil action:nil duration:3];
            self.flowEndReason = @"网络连接中断";
            break;
        case TSAIChatEventTypeBleDisconnected:
            [self.bannerView showText:@"耳机已断开，畅聊已结束" symbol:@"headphones"
                                style:TSAIChatBannerStyleError actionTitle:nil action:nil duration:3];
            self.flowEndReason = @"耳机已断开";
            break;
        case TSAIChatEventTypeIntentActionTimedOut: {
            TSAIChatRoundModel *timedOutRound = event.roundIndex >= 0 ? [self flowRoundForIndex:event.roundIndex] : self.flowCurrentRound;
            if (timedOutRound && [timedOutRound isInProgress]) {
                [self.intentCoordinator handleIntentActionTimedOutForRound:timedOutRound];
            }
            break;
        }
        default:
            break;
    }
    [self refreshUI];
}

/// 畅聊内容
- (void)handleFlowContent:(TSAIChatContent *)content {
    if (self.flowState == TSAIChatFlowStateEnded) return;
    TSAIChatRoundModel *round = nil;
    switch (content.contentType) {
        case TSAIChatContentTypeQuestion:
            round = [self flowRoundForIndex:content.roundIndex];
            round.question = content.text;
            round.questionFinal = content.isTextFinal;
            if (self.flowState == TSAIChatFlowStateListening) self.flowState = TSAIChatFlowStateHearing;
            break;
        case TSAIChatContentTypeAnswer:
            round = [self flowRoundForIndex:content.roundIndex];
            round.answer = content.text;
            round.answerFinal = content.isTextFinal;
            if (round.state < TSAIChatRoundStateAnswering) round.state = TSAIChatRoundStateAnswering;
            [self.intentCoordinator roundDidReceiveAnswer:round];
            if (!self.coordinator.activeSessionConfig.enableVoiceOutput) {
                // 无语音输出：以文字到达 / 定稿代替播放开始 / 结束
                self.flowState = TSAIChatFlowStateSpeaking;
                if (content.isTextFinal) {
                    [self archiveFlowRoundTruncated:NO];
                    self.flowState = TSAIChatFlowStateListening;
                }
            }
            break;
        case TSAIChatContentTypeAudioChunk:
            round = [self flowRoundForIndex:content.roundIndex];
            if (content.audioChunk.length > 0) [round.answerPCM appendData:content.audioChunk];
            return;
        case TSAIChatContentTypeIntent:
            round = [self flowRoundForIndex:content.roundIndex];
            if (content.intent) {
                [round.intents addObject:content.intent];
                // 畅聊：定位意图到达时云端在等位置，这轮先按「想一想」展示，由意图协调器补位置后重发
                if (round.state < TSAIChatRoundStateAnswering) round.state = TSAIChatRoundStateAnswering;
                if (self.flowState == TSAIChatFlowStateHearing) self.flowState = TSAIChatFlowStateThinking;
                [self.intentCoordinator handleIntent:content.intent round:round];
            }
            break;
        default:
            return;
    }
    [self refreshUI];
}

/// 畅聊完成：ended + 结束卡
- (void)handleFlowCompletionWithReport:(TSAIChatReport *)report error:(NSError *)error {
    // 光球还在「连接中」就结束：麦克风没出过数据，启动类失败按「麦克风暂不可用」提示
    BOOL connecting = self.flowState == TSAIChatFlowStateConnecting;
    [self.intentCoordinator reset];
    [self archiveFlowRoundTruncated:YES];
    self.flowCurrentRound = nil;
    self.flowSessionStarted = NO;
    [self.bannerView dismiss];
    if (error) {
        NSString *microphoneReason = [self microphoneFailureReasonForError:error preparing:connecting];
        if (microphoneReason.length > 0) {
            TSLog(@"[TSAIChatVC] flow microphone failure: code=%ld, reason=%@, error=%@",
                  (long)error.code, microphoneReason, error);
            self.flowEndReason = microphoneReason;
            if (error.code == TSAIErrorCodeMicrophonePermissionDenied) {
                [self showMicrophonePermissionDeniedBanner];
            }
        } else {
            self.flowEndReason = error.localizedDescription.length > 0 ? error.localizedDescription : @"出错了";
        }
    } else if (!self.flowEndReason) {
        switch (report.endReason) {
            case TSAIChatEndReasonTimeout:  self.flowEndReason = @"长时间没有输入，已自动结束"; break;
            case TSAIChatEndReasonUserStop: self.flowEndReason = @"已结束"; break;
            case TSAIChatEndReasonDialogExit: self.flowEndReason = @"已退出 AI 对话"; break;
            default:                        self.flowEndReason = @"会话已结束"; break;
        }
    }
    self.flowState = TSAIChatFlowStateEnded;
    self.flowShowingTranscript = NO;
    [self refreshUI];
    [self layoutViews];
    NSTimeInterval duration = report.duration > 0 ? report.duration : -[self.flowStartDate timeIntervalSinceNow];
    NSInteger count = report.roundCount > 0 ? report.roundCount : (NSInteger)self.flowRounds.count;
    [self.endCard showWithRoundCount:MAX(count, (NSInteger)self.flowRounds.count) duration:MAX(0, duration)];
    if (!error && report.endReason == TSAIChatEndReasonDialogExit) {
        // 语音「退出对话」：意图没到 App 时在这里兜底退出页面
        [self exitChatByVoiceWithRound:nil];
    }
}

#pragma mark - 私有方法 - 回调分发

- (void)handleEvent:(TSAIChatEvent *)event {
    [self.currentLogSheet appendEvent:event];
    if (self.mode == TSAIChatPageModeChat) {
        [self handleChatEvent:event];
    } else {
        [self handleFlowEvent:event];
    }
}

- (void)handleContent:(TSAIChatContent *)content {
    [self.currentLogSheet appendContent:content];
    if (self.mode == TSAIChatPageModeChat) {
        [self handleChatContent:content];
    } else {
        [self handleFlowContent:content];
    }
}

#pragma mark - 通知

/// 协调器阶段变化：设备发起的会话固定为 AI 畅聊，页面切到「AI 畅聊」并跟随
- (void)onSessionPhaseDidChange:(NSNotification *)notification {
    TSAIChatDeviceSessionPhase phase = [notification.userInfo[TSAIChatDeviceSessionPhaseUserInfoKey] integerValue];
    if (phase != TSAIChatDeviceSessionPhaseStartRequested) return;
    if (!self.coordinator.activeSessionDeviceInitiated) return;
    [self.currentLogSheet clearAll];
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    // 协调器已把畅聊线路的拾音 / 播放选为耳机仓：收起尚未确认的选择面板，直接跟随
    [self.audioSheet dismiss];
    if (self.mode == TSAIChatPageModeChat) {
        [self switchToFlowForDeviceSession];
    } else {
        [self startFlowSession];
    }
    [self.bannerView showText:@"设备发起了 AI 畅聊" symbol:@"earbuds.case.fill"
                        style:TSAIChatBannerStyleInfo actionTitle:nil action:nil duration:2.2];
}

/// 设备发起畅聊时页面停在「AI 对话」：收起对话态（此时没有 App 会话，不需要停会话），切到「AI 畅聊」跟随设备会话
- (void)switchToFlowForDeviceSession {
    [self exitVoiceRecordingWithOutcome:@"interrupted" releaseUptime:0];
    TSAIChatRoundModel *round = self.currentRound;
    if (round && [round isInProgress]) {
        if (round.answer.length > 0) {
            round.state = TSAIChatRoundStateDone;
            [self refreshRound:round];
        } else {
            [self removeRound:round];
        }
    }
    self.chatState = TSAIChatChatStateIdle;
    self.sessionStarted = NO;
    self.discardingRound = NO;
    self.pendingText = nil;
    [self.modeSegment setSelectedMode:TSAIChatPageModeFlow animated:YES];
    [self onModeSelected:TSAIChatPageModeFlow];
}

- (void)onSessionDidReceiveContent:(NSNotification *)notification {
    TSAIChatContent *content = notification.userInfo[TSAIChatDeviceSessionContentUserInfoKey];
    if (content) [self handleContent:content];
}

- (void)onSessionDidReceiveEvent:(NSNotification *)notification {
    TSAIChatEvent *event = notification.userInfo[TSAIChatDeviceSessionEventUserInfoKey];
    if (event) [self handleEvent:event];
}

- (void)onSessionDidComplete:(NSNotification *)notification {
    TSAIChatReport *report = notification.userInfo[TSAIChatDeviceSessionReportUserInfoKey];
    NSError *error = notification.userInfo[TSAIChatDeviceSessionErrorUserInfoKey];
    TSLog(@"[TSAIChatVC] session ended: reason=%ld, duration=%.1f, rounds=%ld, error=%@",
          (long)report.endReason, report.duration, (long)report.roundCount, error.localizedDescription ?: @"nil");
    if (self.mode == TSAIChatPageModeChat) {
        [self handleChatCompletionWithReport:report error:error];
    } else {
        [self handleFlowCompletionWithReport:report error:error];
    }
    [self finishPendingModeSwitchIfNeeded];
}

/// 耳机唤醒被忽略（需求 B8）
- (void)onDeviceRequestIgnored:(NSNotification *)notification {
    [TSAIChatToastView showText:@"已有 AI 会话，忽略耳机唤醒" inView:self.view];
}

/// 耳机连接变化（规范 §5.3）；会话中的断开由 BleDisconnected 事件处理
- (void)onDeviceSnapshotChanged:(NSNotification *)notification {
    BOOL connected = [self.coordinator isHeadsetConnected];
    if (connected == self.lastHeadsetConnected) return;
    self.lastHeadsetConnected = connected;
    [self refreshRoutePill];
    [self.audioSheet updateHeadsetConnected:connected];
    [self.view setNeedsLayout];
    if (connected) {
        [TSAIChatToastView showText:@"耳机仓已连接，恢复耳机仓拾音与播放" inView:self.view];
    } else if (![self isBusy]) {
        [self.bannerView showText:@"耳机仓已断开，拾音切到手机麦克风" symbol:@"headphones"
                            style:TSAIChatBannerStyleWarn actionTitle:nil action:nil duration:3];
    }
}

/// 键盘：对话模式下抬起底部胶囊
- (void)onKeyboardWillChange:(NSNotification *)notification {
    if (self.mode != TSAIChatPageModeChat) return;
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frameInView = [self.view convertRect:endFrame fromView:nil];
    CGFloat overlap = MAX(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(frameInView));
    if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) overlap = 0;
    self.keyboardOverlap = overlap;
    [UIView animateWithDuration:duration animations:^{
        [self layoutViews];
    }];
    [self scrollRoundsToBottomAnimated:YES];
}

#pragma mark - 事件

/// 分段切换
- (void)onModeSelected:(TSAIChatPageMode)mode {
    if (mode == self.mode) return;
    [self.dockView.textField resignFirstResponder];
    [self.contextMenu dismiss];
    [self.bannerView dismiss];
    self.mode = mode;
    [self rebuildContentForMode];
    if (mode == TSAIChatPageModeFlow) {
        [self presentFlowAudioSheetThenStart];
    } else {
        self.chatState = TSAIChatChatStateIdle;
        [self.flowRounds removeAllObjects];
        [self.transcriptView clear];
        [self refreshUI];
    }
}

/// 会话进行中切换模式：显示菊花 → 结束当前会话 → 收到结束回调后再切换并开启新会话。
/// SDK 侧结束只需 0.1~0.4s（厂商 finish ≈65ms + 手表 0x6F ≈260ms）；底层厂商会话会转入保活，
/// 新模式直接复用同一条连接，不会再触发「同进程第二次建连」的 8s 超时。
- (void)beginModeSwitchAfterEndingSession:(TSAIChatPageMode)mode {
    if (mode == self.mode) return;
    if (self.pendingSwitchMode) {
        [TSAIChatToastView showText:@"正在结束当前会话…" inView:self.view];
        return;
    }
    if (![self.coordinator isSessionActive]) {
        // 页面状态忙但协调器已无会话（如出错态残留）：直接切
        [self.modeSegment setSelectedMode:mode animated:YES];
        [self onModeSelected:mode];
        return;
    }
    self.pendingSwitchMode = @(mode);
    [self.dockView.textField resignFirstResponder];
    [self.contextMenu dismiss];
    [self.audioSheet dismiss];
    [self.pcmPlayer stop];
    [TSLoadingHUD showIn:self.view message:@"正在结束当前对话…"];
    if (self.mode == TSAIChatPageModeChat) {
        // 对话模式：当前轮按「丢弃」处理，结束回调不再把它标成出错
        [self exitVoiceRecordingWithOutcome:@"interrupted" releaseUptime:0];
        TSAIChatRoundModel *round = self.currentRound;
        if (round && [round isInProgress]) {
            if (round.answer.length > 0) {
                round.state = TSAIChatRoundStateDone;
                [self refreshRound:round];
            } else {
                [self removeRound:round];
            }
        }
        self.discardingRound = YES;
    }
    [self.pendingSwitchTimer invalidate];
    self.pendingSwitchTimer = [NSTimer scheduledTimerWithTimeInterval:kTSAIChatModeSwitchTimeout
                                                               target:self
                                                             selector:@selector(onPendingSwitchTimeout)
                                                             userInfo:nil
                                                              repeats:NO];
    [self.coordinator stopSessionFromApp];
}

/// 会话结束回调到达：完成待处理的模式切换
- (void)finishPendingModeSwitchIfNeeded {
    NSNumber *pending = self.pendingSwitchMode;
    if (!pending) return;
    [self.pendingSwitchTimer invalidate];
    self.pendingSwitchTimer = nil;
    self.pendingSwitchMode = nil;
    [TSLoadingHUD hideIn:self.view];
    TSAIChatPageMode mode = (TSAIChatPageMode)pending.integerValue;
    [self.modeSegment setSelectedMode:mode animated:YES];
    [self onModeSelected:mode];
}

/// 结束超时：放弃切换，保留当前模式并提示
- (void)onPendingSwitchTimeout {
    if (!self.pendingSwitchMode) return;
    self.pendingSwitchTimer = nil;
    self.pendingSwitchMode = nil;
    [TSLoadingHUD hideIn:self.view];
    [self.bannerView showText:@"结束当前会话超时，请稍后再切换" symbol:@"exclamationmark.triangle.fill"
                        style:TSAIChatBannerStyleWarn actionTitle:nil action:nil duration:3];
}

/// 录音计时：从 InputReady 起算，满 60 秒自动结束输入
- (void)onRecordTick {
    if (self.voiceInputReadyUptime <= 0) return;
    NSTimeInterval elapsed = NSProcessInfo.processInfo.systemUptime - self.voiceInputReadyUptime;
    self.dockView.recordingElapsed = elapsed;
    if (elapsed >= kTSAIChatMaximumPressDuration && self.chatState == TSAIChatChatStateRecording) {
        [self finishVoiceInputWithReleaseUptime:0];
    }
}

/// 「准备中」超过 3 秒：提示麦克风启动较慢（SDK 看门狗 5 秒后以错误结束，不会一直停在准备中）
- (void)onPreparingSlow {
    self.preparingSlowTimer = nil;
    if (self.chatState != TSAIChatChatStatePreparing || !self.dockView.isRecording) return;
    TSLog(@"[TSAIChatVC] microphone slow to start: preparing for %.0f ms",
          (NSProcessInfo.processInfo.systemUptime - self.voicePressUptime) * 1000.0);
    [TSAIChatToastView showText:@"麦克风启动较慢…" inView:self.view];
}

/// 畅聊关闭 / 重新开始
- (void)onFlowCloseTapped {
    if (self.flowState == TSAIChatFlowStateEnded) {
        // 重新开始：沿用 AI 畅聊上次的拾音 / 播放选择，不再弹出选择面板
        [self startFlowSession];
        return;
    }
    if (self.flowState == TSAIChatFlowStateIdle && ![self.coordinator isSessionActive]) {
        // 尚未开始（选择面板被收起的兜底）：重新弹出选择
        [self presentFlowAudioSheetThenStart];
        return;
    }
    [self.coordinator stopSessionFromApp];
}

/// 畅聊 光球 ⇄ 记录
- (void)onFlowStageToggled:(TSAIChatFlowStage)nextStage {
    if (self.flowState == TSAIChatFlowStateEnded) return;
    self.flowShowingTranscript = nextStage == TSAIChatFlowStageTranscript;
    [self refreshUI];
}

- (void)onFlowClosePressed {
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.62 initialSpringVelocity:0.8 options:0 animations:^{
        self.flowCloseButton.transform = CGAffineTransformMakeScale(1.06, 1.06);
        if (self.flowCloseGradient.hidden) self.flowCloseIcon.tintColor = TSAIChatRoseColor();
    } completion:nil];
}

- (void)onFlowCloseReleased {
    [UIView animateWithDuration:0.2 animations:^{
        self.flowCloseButton.transform = CGAffineTransformIdentity;
        if (self.flowCloseGradient.hidden) self.flowCloseIcon.tintColor = TSAIChatInkColor();
    }];
}

/// 「更多」= 原配置弹层（路由 / Agent / prompt）
- (void)onMoreTapped {
    TSAIChatConfigSheet *sheet = [[TSAIChatConfigSheet alloc] initWithConfig:self.coordinator.config];
    __weak typeof(self) weakSelf = self;
    sheet.onApply = ^(TSAIChatConfig *config) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        [strongSelf.coordinator updateConfig:config];
        [TSAIChatToastView showText:@"配置已保存" inView:strongSelf.view];
        [strongSelf refreshUI];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sheet];
    [self presentViewController:nav animated:YES completion:nil];
}

/// 胶囊 = 音频设置入口；忙碌时锁定
- (void)onRoutePillTapped {
    if ([self isBusy]) {
        [TSAIChatToastView showText:@"会话进行中，结束后再更改" inView:self.view];
        return;
    }
    [self.contextMenu dismiss];
    [self.dockView.textField resignFirstResponder];
    __weak typeof(self) weakSelf = self;
    self.audioSheet = [TSAIChatAudioSheet showInView:self.view
                                    headsetConnected:[self.coordinator isHeadsetConnected]
                                    conversationMode:[self currentConversationMode]
                                            onChange:^{
        [weakSelf refreshRoutePill];
    }];
}

/// 页面模式对应的 SDK 会话模式：对话 = SingleRound，畅聊 = Continuous
- (TSAIChatConversationMode)currentConversationMode {
    return self.mode == TSAIChatPageModeFlow ? TSAIChatConversationModeContinuous : TSAIChatConversationModeSingleRound;
}

/// 胶囊文案 = 当前生效的拾音 / 播放短名
- (void)refreshRoutePill {
    BOOL headset = [self.coordinator isHeadsetConnected];
    // 胶囊显示当前页面所在线路（AI 对话 / AI 畅聊）自己的选择
    TSAIChatAudioPreference *preference = [TSAIChatAudioPreference preferenceForConversationMode:[self currentConversationMode]];
    TSAIChatAudioInputOption input = [preference effectiveInputWithHeadset:headset];
    TSAIChatAudioOutputOption output = [preference effectiveOutputWithHeadset:headset];
    // 会话进行中以 SDK 解析后的生效路由为准：请求的组合不可用时 SDK 会自动回退，
    // 胶囊若仍显示偏好值，用户会对着手机说话而实际在用耳机仓拾音（18:55 日志）
    if ([self.coordinator isSessionActive]) {
        id<TSAIAudioRoutingInterface> audioRouting = [TSAIKit sharedInstance].activeContext.audioRouting;
        TSAIAudioRouteSnapshot *snapshot = [audioRouting activeAudioRouteForFeature:TSAIFeatureAIChat];
        TSAIAudioRouteConfiguration *effective = snapshot.effectiveRoute;
        if (effective && (snapshot.state == TSAIAudioRouteStateActivating || snapshot.state == TSAIAudioRouteStateActive)) {
            BOOL voiceRound = effective.inputChannel != TSAIAudioInputChannelNone;
            if (voiceRound) {
                TSAIChatAudioInputOption effectiveInput = [TSAIChatAudioPreference inputOptionForChannel:effective.inputChannel];
                if (effectiveInput != input) {
                    NSString *taskId = self.coordinator.currentTaskId;
                    if (taskId.length > 0 && ![taskId isEqualToString:self.routeFallbackNoticeTaskId]) {
                        self.routeFallbackNoticeTaskId = taskId;
                        [self.bannerView showText:[NSString stringWithFormat:@"「%@」拾音当前不可用，本次改用「%@」",
                                                   [TSAIChatAudioPreference titleForInputOption:input],
                                                   [TSAIChatAudioPreference titleForInputOption:effectiveInput]]
                                           symbol:@"mic.fill" style:TSAIChatBannerStyleWarn
                                      actionTitle:nil action:nil duration:4];
                    }
                    input = effectiveInput;
                }
            }
            output = [TSAIChatAudioPreference outputOptionForChannel:effective.outputChannel];
        }
    }
    self.routePill.inputTitle = [TSAIChatAudioPreference shortTitleForInputOption:input];
    self.routePill.inputSymbol = [TSAIChatAudioPreference symbolForInputOption:input];
    self.routePill.outputTitle = [TSAIChatAudioPreference shortTitleForOutputOption:output];
    self.routePill.voiceOff = output == TSAIChatAudioOutputOptionNone;
    [self.view setNeedsLayout];
}

- (void)onLogTapped {
    TSAIChatLogSheet *sheet = self.currentLogSheet;
    if (!sheet) {
        sheet = [[TSAIChatLogSheet alloc] init];
        self.currentLogSheet = sheet;
        for (TSAIChatContent *content in self.coordinator.contentHistory) [sheet appendContent:content];
        for (TSAIChatEvent *event in self.coordinator.eventHistory) [sheet appendEvent:event];
    }
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sheet];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - TSAIChatIntentCoordinatorDelegate

/// 意图状态 / 进度文案变化：刷新对应轮次
- (void)intentCoordinator:(TSAIChatIntentCoordinator *)coordinator didUpdateRound:(TSAIChatRoundModel *)round {
    if (self.mode == TSAIChatPageModeChat) {
        [self refreshRound:round];
    }
    [self refreshUI];
}

/// 意图处理失败：本轮置错、横幅提示，单轮时结束会话
- (void)intentCoordinator:(TSAIChatIntentCoordinator *)coordinator
             didFailRound:(TSAIChatRoundModel *)round
                   reason:(NSString *)reason
                 bodyText:(NSString *)bodyText
              actionTitle:(NSString *)actionTitle
                   action:(void (^)(void))action
              endsSession:(BOOL)endsSession {
    round.errorBodyText = bodyText;
    if (self.mode == TSAIChatPageModeChat) {
        if (round == self.currentRound) {
            [self failCurrentRoundWithText:reason];
        } else if ([round isInProgress]) {
            round.state = TSAIChatRoundStateError;
            round.errorText = reason;
            [self refreshRound:round];
        }
    } else {
        if ([round isInProgress]) {
            round.state = TSAIChatRoundStateError;
            round.errorText = reason;
            round.answerFinal = YES;
            round.questionFinal = YES;
            if (![self.flowRounds containsObject:round]) [self.flowRounds addObject:round];
            if (self.flowCurrentRound == round) self.flowCurrentRound = nil;
        }
        if (self.flowState != TSAIChatFlowStateEnded) self.flowState = TSAIChatFlowStateListening;
        [self refreshUI];
    }
    [self.bannerView showText:[NSString stringWithFormat:@"%@：%@", reason, bodyText]
                       symbol:@"location.slash"
                        style:TSAIChatBannerStyleError
                  actionTitle:actionTitle
                       action:action
                     duration:action ? 8 : 4];
    if (endsSession && [self.coordinator isSessionActive]) {
        [self.coordinator stopSessionFromApp];
    }
}

/// 执行不了的指令意图没有等到回答：本轮立即收口并提示（不按故障处理），单轮时结束会话
- (void)intentCoordinator:(TSAIChatIntentCoordinator *)coordinator
 didCloseUnsupportedRound:(TSAIChatRoundModel *)round
                   reason:(NSString *)reason
                   notice:(NSString *)notice
              endsSession:(BOOL)endsSession {
    if ([round isInProgress]) {
        round.state = TSAIChatRoundStateError;
        round.errorText = reason;
        round.errorBodyText = notice;
        round.questionFinal = YES;
        round.answerFinal = YES;
    }
    if (self.mode == TSAIChatPageModeChat) {
        [self refreshRound:round];
        if (round == self.currentRound) {
            // 不是故障：胶囊回到空闲，不切出错气色
            [self exitVoiceRecordingWithOutcome:@"unsupportedIntent" releaseUptime:0];
            self.chatState = TSAIChatChatStateIdle;
        }
    } else {
        if (![self.flowRounds containsObject:round]) [self.flowRounds addObject:round];
        if (self.flowCurrentRound == round) self.flowCurrentRound = nil;
        // 只把「听到了 / 想一想」拉回「我在听」；别的轮正在播放时保持不变
        if (self.flowState == TSAIChatFlowStateHearing || self.flowState == TSAIChatFlowStateThinking) {
            self.flowState = TSAIChatFlowStateListening;
        }
    }
    [self refreshUI];
    [self.bannerView showText:notice
                       symbol:@"bolt.slash.fill"
                        style:TSAIChatBannerStyleInfo
                  actionTitle:nil
                       action:nil
                     duration:4];
    if (endsSession && [self.coordinator isSessionActive]) {
        [self.coordinator stopSessionFromApp];
    }
}

/// 用户语音「退出对话」（dialog.exit）：本轮显示「已退出 AI 对话」，稍后返回上一页（SDK 会以 DialogExit 结束会话）
- (void)intentCoordinator:(TSAIChatIntentCoordinator *)coordinator didRequestExitForRound:(TSAIChatRoundModel *)round {
    [self exitChatByVoiceWithRound:round];
}

#pragma mark - 私有方法 - 语音退出

/// 语音「退出对话」：本轮收口为已回答的提示，稍后返回上一页；意图与 completion 都可能触发，只处理一次
- (void)exitChatByVoiceWithRound:(nullable TSAIChatRoundModel *)round {
    if (self.exitingByVoice) {
        return;
    }
    self.exitingByVoice = YES;
    TSLog(@"[TSAIChatVC] exit AI chat by voice: mode=%ld, round=%@, sessionActive=%d",
          (long)self.mode,
          round.roundId,
          [self.coordinator isSessionActive]);
    if (round) {
        if (round.answer.length == 0) {
            round.answer = kTSAIChatVoiceExitReply;
        }
        round.questionFinal = YES;
        round.answerFinal = YES;
        round.state = TSAIChatRoundStateDone;
    }
    if (self.mode == TSAIChatPageModeChat) {
        if (round) {
            [self refreshRound:round];
        }
        [self exitVoiceRecordingWithOutcome:@"voiceExit" releaseUptime:0];
        self.chatState = TSAIChatChatStateIdle;
    } else {
        if (round && ![self.flowRounds containsObject:round]) {
            [self.flowRounds addObject:round];
        }
        if (self.flowCurrentRound == round) {
            self.flowCurrentRound = nil;
        }
        self.flowEndReason = @"已退出 AI 对话";
    }
    [self refreshUI];
    [TSAIChatToastView showText:@"已退出 AI 对话" inView:self.view];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTSAIChatVoiceExitLeaveDelay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [weakSelf leaveChatPageAfterVoiceExit];
    });
}

/// 返回上一页；离开页面时 viewWillDisappear 会停掉仍在进行的会话
- (void)leaveChatPageAfterVoiceExit {
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    UINavigationController *navigationController = self.navigationController;
    if (navigationController != nil && navigationController.topViewController == self &&
        navigationController.viewControllers.count > 1) {
        [navigationController popViewControllerAnimated:YES];
    } else if (self.presentingViewController != nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        TSLog(@"[TSAIChatVC] exit AI chat by voice: page is not on top, session ended only");
    }
}

#pragma mark - TSAIChatRoundViewDelegate

- (void)roundViewDidTapSpeakingBubble:(TSAIChatRoundView *)roundView {
    [self.coordinator interruptPlaybackFromApp];
    roundView.model.state = TSAIChatRoundStateDone;
    [self refreshRound:roundView.model];
    [TSAIChatToastView showText:@"已停止播放" inView:self.view];
}

- (void)roundView:(TSAIChatRoundView *)roundView didLongPressBubble:(UIView *)bubble isUserBubble:(BOOL)isUserBubble {
    [self.contextMenu dismiss];
    TSAIChatRoundModel *round = roundView.model;
    __weak typeof(self) weakSelf = self;
    self.contextMenu = [TSAIChatContextMenu showAboveBubble:bubble
                                                     inView:self.view
                                                 alignRight:isUserBubble
                                                    handler:^(TSAIChatContextMenuAction action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        switch (action) {
            case TSAIChatContextMenuActionPlay: {
                NSData *pcm = isUserBubble ? round.questionPCM : round.answerPCM;
                if (pcm.length == 0) {
                    [TSAIChatToastView showText:isUserBubble ? @"这段录音未缓存" : @"这段回答没有语音" inView:strongSelf.view];
                    return;
                }
                [strongSelf.pcmPlayer playPCM:pcm completion:nil];
                [TSAIChatToastView showText:@"播放这段语音" inView:strongSelf.view];
                break;
            }
            case TSAIChatContextMenuActionCopy:
                [UIPasteboard generalPasteboard].string = (isUserBubble ? round.question : round.answer) ?: @"";
                [TSAIChatToastView showText:@"已复制" inView:strongSelf.view];
                break;
            case TSAIChatContextMenuActionDelete:
                [strongSelf removeRound:round];
                [TSAIChatToastView showText:@"已删除" inView:strongSelf.view];
                break;
        }
    }];
}

- (void)roundViewDidTapRetry:(TSAIChatRoundView *)roundView {
    [self removeRound:roundView.model];
    self.chatState = TSAIChatChatStateIdle;
    [self refreshUI];
}

#pragma mark - 属性（懒加载）

- (TSAIChatAuroraView *)auroraView {
    if (!_auroraView) {
        _auroraView = [[TSAIChatAuroraView alloc] init];
    }
    return _auroraView;
}

- (TSAIChatModeSegment *)modeSegment {
    if (!_modeSegment) {
        _modeSegment = [[TSAIChatModeSegment alloc] init];
        __weak typeof(self) weakSelf = self;
        _modeSegment.onSelect = ^(TSAIChatPageMode mode) {
            [weakSelf onModeSelected:mode];
        };
        // 会话进行中点另一模式：先结束当前会话（菊花等待），结束回调到达后再切换并开启新会话
        _modeSegment.onLockedSelect = ^(TSAIChatPageMode mode) {
            [weakSelf beginModeSwitchAfterEndingSession:mode];
        };
        _modeSegment.onLockedTap = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [TSAIChatToastView showText:@"正在结束当前会话…" inView:strongSelf.view];
        };
    }
    return _modeSegment;
}

- (TSAIChatRoutePill *)routePill {
    if (!_routePill) {
        _routePill = [[TSAIChatRoutePill alloc] init];
        [_routePill addTarget:self action:@selector(onRoutePillTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _routePill;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (TSAIChatBannerView *)bannerView {
    if (!_bannerView) {
        _bannerView = [[TSAIChatBannerView alloc] init];
    }
    return _bannerView;
}

- (UIScrollView *)roundsScrollView {
    if (!_roundsScrollView) {
        _roundsScrollView = [[UIScrollView alloc] init];
        _roundsScrollView.alwaysBounceVertical = YES;
        _roundsScrollView.showsVerticalScrollIndicator = NO;
        _roundsScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _roundsScrollView.hidden = YES;
    }
    return _roundsScrollView;
}

- (TSAIChatHeroView *)heroView {
    if (!_heroView) {
        _heroView = [[TSAIChatHeroView alloc] init];
        __weak typeof(self) weakSelf = self;
        _heroView.onSuggestionTap = ^(NSString *text) {
            [weakSelf sendTextQuestion:text];
        };
    }
    return _heroView;
}

- (TSAIChatDockView *)dockView {
    if (!_dockView) {
        _dockView = [[TSAIChatDockView alloc] init];
        __weak typeof(self) weakSelf = self;
        _dockView.onSend = ^(NSString *text) {
            [weakSelf sendTextQuestion:text];
        };
        _dockView.onPressBegan = ^{
            [weakSelf beginVoiceRound];
        };
        _dockView.onPressMoved = ^(BOOL cancelling) {
            weakSelf.dockView.recordingCancelling = cancelling;
        };
        _dockView.onPressEnded = ^(BOOL cancelled) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            // 以胶囊是否仍在录音态为准，不看 chatState：SDK 静默收口可能已把 chatState 推到回答态，
            // 松手仍必须收起录音 UI
            if (!strongSelf || !strongSelf.dockView.isRecording) return;
            [strongSelf handleVoicePressEndedCancelled:cancelled];
        };
    }
    return _dockView;
}

- (TSAIChatFlowView *)flowView {
    if (!_flowView) {
        _flowView = [[TSAIChatFlowView alloc] init];
        __weak typeof(self) weakSelf = self;
        _flowView.onOrbTap = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || strongSelf.flowState != TSAIChatFlowStateSpeaking) return;
            [strongSelf.coordinator interruptPlaybackFromApp];
            [strongSelf archiveFlowRoundTruncated:YES];
            strongSelf.flowState = TSAIChatFlowStateListening;
            [strongSelf refreshUI];
            [TSAIChatToastView showText:@"已打断" inView:strongSelf.view];
        };
    }
    return _flowView;
}

- (TSAIChatTranscriptView *)transcriptView {
    if (!_transcriptView) {
        _transcriptView = [[TSAIChatTranscriptView alloc] init];
        _transcriptView.hidden = YES;
    }
    return _transcriptView;
}

- (TSAIChatEndCard *)endCard {
    if (!_endCard) {
        _endCard = [[TSAIChatEndCard alloc] init];
        _endCard.hidden = YES;
    }
    return _endCard;
}

- (TSAIChatFlowToggle *)flowToggle {
    if (!_flowToggle) {
        _flowToggle = [[TSAIChatFlowToggle alloc] init];
        __weak typeof(self) weakSelf = self;
        _flowToggle.onToggle = ^(TSAIChatFlowStage nextStage) {
            [weakSelf onFlowStageToggled:nextStage];
        };
    }
    return _flowToggle;
}

- (UIControl *)flowCloseButton {
    if (!_flowCloseButton) {
        _flowCloseButton = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 68, 68)];
        TSAIChatApplyGlass(_flowCloseButton, 34);
        TSAIChatApplyFloatShadow(_flowCloseButton.layer);
        _flowCloseGradient = TSAIChatFlowGradientLayer();
        _flowCloseGradient.cornerRadius = 34;
        _flowCloseGradient.hidden = YES;
        [_flowCloseButton.layer addSublayer:_flowCloseGradient];
        _flowCloseIcon = [[UIImageView alloc] initWithFrame:CGRectMake(21, 21, 26, 26)];
        _flowCloseIcon.contentMode = UIViewContentModeScaleAspectFit;
        _flowCloseIcon.userInteractionEnabled = NO;
        _flowCloseIcon.image = TSAIChatSymbol(@"xmark", 22, UIImageSymbolWeightBold);
        _flowCloseIcon.tintColor = TSAIChatInkColor();
        [_flowCloseButton addSubview:_flowCloseIcon];
        [_flowCloseButton addTarget:self action:@selector(onFlowCloseTapped) forControlEvents:UIControlEventTouchUpInside];
        [_flowCloseButton addTarget:self action:@selector(onFlowClosePressed) forControlEvents:UIControlEventTouchDown];
        [_flowCloseButton addTarget:self action:@selector(onFlowCloseReleased)
                   forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    }
    return _flowCloseButton;
}

- (UILabel *)flowCloseLabel {
    if (!_flowCloseLabel) {
        _flowCloseLabel = [[UILabel alloc] init];
        _flowCloseLabel.font = TSAIChatFont(11.5, UIFontWeightSemibold);
        _flowCloseLabel.textColor = TSAIChatInk3Color();
        _flowCloseLabel.textAlignment = NSTextAlignmentCenter;
        _flowCloseLabel.text = @"关闭";
    }
    return _flowCloseLabel;
}

@end
