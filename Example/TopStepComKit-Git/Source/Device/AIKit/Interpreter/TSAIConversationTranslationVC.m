//
//  TSAIConversationTranslationVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/9/18.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIConversationTranslationVC.h"

#import <AVFoundation/AVFoundation.h>
#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSAIConversationTranslationReportVC.h"
#import "TSAIConversationTranslationUI.h"
#import "TSAIInterpreterFormatter.h"
#import "TSAIInterpreterTheme.h"

/// 气泡状态行文字色 #8E97A8
static UIColor *TSConversationStatusColor(void) {
    return [UIColor colorWithRed:0.56 green:0.59 blue:0.66 alpha:1.0];
}

#pragma mark - 对话气泡

/// 一轮对话的气泡：发言方 + 时间 → 气泡（原文 / 译文 / 状态 + 播放）
@interface TSAIConversationTurnCell : UITableViewCell

@property (nonatomic, strong) UILabel *whoLabel;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UILabel *originalLabel;
@property (nonatomic, strong) UILabel *translatedLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *playButton;
/// 是否我方（靠右、钴蓝）
@property (nonatomic, assign) BOOL isSelf;
/// 播放按钮回调
@property (nonatomic, copy, nullable) void (^onPlay)(void);

/// 按宽度计算行高；与 layoutSubviews 使用同一套尺寸
+ (CGFloat)heightForOriginal:(NSString *)original
                  translated:(NSString *)translated
                       width:(CGFloat)width;
+ (CGFloat)bubbleWidthForOriginal:(NSString *)original translated:(NSString *)translated width:(CGFloat)width;
+ (UIFont *)originalFont;
+ (UIFont *)translatedFont;

@end

@implementation TSAIConversationTurnCell

+ (UIFont *)originalFont { return [TSAIInterpreterTheme fontOfSize:14.0 cssWeight:400]; }
+ (UIFont *)translatedFont { return [TSAIInterpreterTheme fontOfSize:17.0 cssWeight:600]; }

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _whoLabel = [[UILabel alloc] init];
        _whoLabel.font = [TSAIInterpreterTheme fontOfSize:11.0 cssWeight:600];
        [self.contentView addSubview:_whoLabel];
        _bubbleView = [[UIView alloc] init];
        _bubbleView.layer.cornerRadius = 20.0;
        [self.contentView addSubview:_bubbleView];
        _originalLabel = [[UILabel alloc] init];
        _originalLabel.font = [[self class] originalFont];
        _originalLabel.textColor = [TSAIInterpreterTheme textOnDark2];
        _originalLabel.numberOfLines = 0;
        [_bubbleView addSubview:_originalLabel];
        _translatedLabel = [[UILabel alloc] init];
        _translatedLabel.font = [[self class] translatedFont];
        _translatedLabel.textColor = UIColor.whiteColor;
        _translatedLabel.numberOfLines = 0;
        [_bubbleView addSubview:_translatedLabel];
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = [TSAIInterpreterTheme fontOfSize:11.0 cssWeight:400];
        _statusLabel.textColor = TSConversationStatusColor();
        [_bubbleView addSubview:_statusLabel];
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.titleLabel.font = [TSAIInterpreterTheme fontOfSize:11.0 cssWeight:600];
        _playButton.layer.cornerRadius = 13.0;
        _playButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10.0, 0, 10.0);
        _playButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4.0, 0, -4.0);
        [_playButton addTarget:self action:@selector(onPlayTap) forControlEvents:UIControlEventTouchUpInside];
        [_bubbleView addSubview:_playButton];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.onPlay = nil;
}

- (void)onPlayTap {
    if (self.onPlay) self.onPlay();
}

+ (CGFloat)bubbleWidthForOriginal:(NSString *)original translated:(NSString *)translated width:(CGFloat)width {
    CGFloat maxW = floor((width - 32.0) * 0.86);
    CGFloat textMaxW = maxW - 28.0;
    CGFloat oW = ceil([original boundingRectWithSize:CGSizeMake(textMaxW, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{ NSFontAttributeName: [self originalFont] }
                                             context:nil].size.width);
    CGFloat tW = ceil([translated boundingRectWithSize:CGSizeMake(textMaxW, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{ NSFontAttributeName: [self translatedFont] }
                                               context:nil].size.width);
    return MIN(maxW, MAX(150.0, MAX(oW, tW) + 28.0));
}

+ (CGFloat)textHeight:(NSString *)text font:(UIFont *)font width:(CGFloat)width {
    if (text.length == 0) return 0;
    return ceil([text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{ NSFontAttributeName: font }
                                   context:nil].size.height);
}

+ (CGFloat)heightForOriginal:(NSString *)original translated:(NSString *)translated width:(CGFloat)width {
    CGFloat bubbleW = [self bubbleWidthForOriginal:original translated:translated width:width];
    CGFloat textW = bubbleW - 28.0;
    CGFloat oH = MAX(18.0, [self textHeight:original font:[self originalFont] width:textW]);
    CGFloat tH = [self textHeight:translated font:[self translatedFont] width:textW];
    // who 14 + 6 → bubble(12 + o + (6 + t) + 6 + 26 + 12) + 12
    return 14.0 + 6.0 + 12.0 + oH + (tH > 0 ? 6.0 + tH : 0) + 6.0 + 26.0 + 12.0 + 12.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    NSString *original = self.originalLabel.text ?: @"";
    NSString *translated = self.translatedLabel.text ?: @"";
    CGFloat bubbleW = [[self class] bubbleWidthForOriginal:original translated:translated width:width];
    CGFloat textW = bubbleW - 28.0;
    CGFloat x = self.isSelf ? width - 16.0 - bubbleW : 16.0;
    CGSize whoSize = [self.whoLabel sizeThatFits:CGSizeMake(bubbleW, 14.0)];
    self.whoLabel.frame = CGRectMake(self.isSelf ? width - 16.0 - ceil(whoSize.width) : 16.0, 0, ceil(whoSize.width), 14.0);
    CGFloat y = 12.0;
    CGFloat oH = MAX(18.0, [[self class] textHeight:original font:[[self class] originalFont] width:textW]);
    self.originalLabel.frame = CGRectMake(14.0, y, textW, oH);
    y += oH;
    CGFloat tH = [[self class] textHeight:translated font:[[self class] translatedFont] width:textW];
    self.translatedLabel.hidden = tH == 0;
    if (tH > 0) {
        y += 6.0;
        self.translatedLabel.frame = CGRectMake(14.0, y, textW, tH);
        y += tH;
    }
    y += 6.0;
    CGFloat playW = self.playButton.hidden ? 0 : ceil([self.playButton sizeThatFits:CGSizeMake(120.0, 26.0)].width);
    self.playButton.frame = CGRectMake(14.0 + textW - playW, y, playW, 26.0);
    self.statusLabel.frame = CGRectMake(14.0, y, textW - playW - (playW > 0 ? 8.0 : 0), 26.0);
    y += 26.0 + 12.0;
    self.bubbleView.frame = CGRectMake(x, 14.0 + 6.0, bubbleW, y);
    // 尾角：我方右下、对方左下用小圆角
    self.bubbleView.layer.maskedCorners = self.isSelf
        ? (kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner)
        : (kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner);
}

@end

#pragma mark - 对话页

@interface TSAIConversationTranslationVC () <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>

#pragma mark - 视图 - 顶栏
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIView *pillView;
@property (nonatomic, strong) UIView *dotView;
@property (nonatomic, strong) UILabel *modeLabel;
@property (nonatomic, strong) UIView *pillSeparator;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) UIView *syncBadge;
@property (nonatomic, strong) UIImageView *syncIcon;
@property (nonatomic, strong) UILabel *syncLabel;

#pragma mark - 视图 - 语言对
@property (nonatomic, strong) UILabel *selfLanguageLabel;
@property (nonatomic, strong) UIImageView *pairArrow;
@property (nonatomic, strong) UILabel *peerLanguageLabel;
@property (nonatomic, strong) UILabel *routeLabel;

#pragma mark - 视图 - 对话
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UIButton *latestButton;
@property (nonatomic, strong) UILabel *statusLine;

#pragma mark - 视图 - 底栏
@property (nonatomic, strong) UIButton *holdSelfButton;
@property (nonatomic, strong) UIButton *holdPeerButton;
@property (nonatomic, strong) UIButton *stopButton;

#pragma mark - 视图 - 结束确认面板
@property (nonatomic, strong) UIControl *confirmOverlay;
@property (nonatomic, strong) UIView *confirmSheet;
@property (nonatomic, strong) UIView *confirmGrab;
@property (nonatomic, strong) UILabel *confirmTitleLabel;
@property (nonatomic, strong) UILabel *confirmBodyLabel;
@property (nonatomic, strong) UIView *statsCard;
@property (nonatomic, copy) NSArray<UILabel *> *statKeyLabels;
@property (nonatomic, copy) NSArray<UILabel *> *statValueLabels;
@property (nonatomic, copy) NSArray<UIView *> *statDividers;
@property (nonatomic, strong) UIButton *confirmStopButton;
@property (nonatomic, strong) UIButton *confirmContinueButton;

#pragma mark - 状态
/// 本次会话的配置
@property (nonatomic, strong) TSAIConversationTranslationConfig *config;
/// 当前会话标识；nil 表示无会话
@property (nonatomic, copy, nullable) NSString *sessionId;
/// 最近一次快照
@property (nonatomic, strong, nullable) TSAIConversationTranslationSnapshot *snapshot;
/// 本页展示的轮次（来自最近快照）
@property (nonatomic, copy) NSArray<TSAIConversationTranslationTurn *> *turns;
/// 会话开始时间
@property (nonatomic, strong, nullable) NSDate *startDate;
/// 计时器
@property (nonatomic, strong, nullable) NSTimer *timer;
/// 是否已启动过会话
@property (nonatomic, assign) BOOL hasStarted;
/// 页面是否正在退出
@property (nonatomic, assign) BOOL leavingPage;
/// 已按下但快照尚未进入聆听态的参与者
@property (nonatomic, assign) TSAIConversationParticipant pressedParticipant;
/// 按钮已松开，等快照进入聆听态后立即结束本轮
@property (nonatomic, assign) BOOL releasePendingTurn;
/// 正在播放归档音频的轮次；nil 表示未播放
@property (nonatomic, copy, nullable) NSString *playingTurnId;
@property (nonatomic, strong, nullable) AVAudioPlayer *audioPlayer;
/// 用户是否向上滚离了最新一条
@property (nonatomic, assign) BOOL userScrolledUp;

@end

@implementation TSAIConversationTranslationVC

#pragma mark - 生命周期

- (instancetype)initWithConfig:(TSAIConversationTranslationConfig *)config {
    self = [super init];
    if (self) {
        _config = config;
        _turns = @[];
        _pressedParticipant = TSAIConversationParticipantNone;
    }
    return self;
}

- (void)initData {
    [super initData];
    self.view.backgroundColor = [TSAIInterpreterTheme ink];
}

- (void)setupViews {
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.pillView];
    [self.pillView addSubview:self.dotView];
    [self.pillView addSubview:self.modeLabel];
    [self.pillView addSubview:self.pillSeparator];
    [self.pillView addSubview:self.timerLabel];
    [self.pillView addSubview:self.syncBadge];
    [self.syncBadge addSubview:self.syncIcon];
    [self.syncBadge addSubview:self.syncLabel];

    [self.view addSubview:self.selfLanguageLabel];
    [self.view addSubview:self.pairArrow];
    [self.view addSubview:self.peerLanguageLabel];
    [self.view addSubview:self.routeLabel];

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.emptyLabel];
    [self.view addSubview:self.latestButton];
    [self.view addSubview:self.statusLine];

    [self.view addSubview:self.holdSelfButton];
    [self.view addSubview:self.stopButton];
    [self.view addSubview:self.holdPeerButton];

    [self.view addSubview:self.confirmOverlay];
    [self.view addSubview:self.confirmSheet];
    [self.confirmSheet addSubview:self.confirmGrab];
    [self.confirmSheet addSubview:self.confirmTitleLabel];
    [self.confirmSheet addSubview:self.confirmBodyLabel];
    [self.confirmSheet addSubview:self.statsCard];
    for (UILabel *label in self.statKeyLabels) [self.statsCard addSubview:label];
    for (UILabel *label in self.statValueLabels) [self.statsCard addSubview:label];
    for (UIView *divider in self.statDividers) [self.statsCard addSubview:divider];
    [self.confirmSheet addSubview:self.confirmStopButton];
    [self.confirmSheet addSubview:self.confirmContinueButton];

    [self refreshStaticUI];
    [self refreshLiveUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.leavingPage = NO;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 对话中禁用侧滑返回，结束只能经确认面板
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if (!self.hasStarted) {
        self.hasStarted = YES;
        [self startSession];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.leavingPage = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    if (![TSAIConversationTranslationUI isCustomBarPage:self.navigationController.topViewController]) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
    [self stopArchivedPlayback];
    // 未经确认就离开（如被外部 pop）时兜底结束会话。
    [self stopSessionIfActive];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    [_timer invalidate];
    [_audioPlayer stop];
    if (_sessionId.length > 0) {
        [[TSAIKit sharedInstance].activeContext.conversationTranslation stopWithSessionId:_sessionId completion:nil];
    }
}

#pragma mark - 布局

- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    if (width <= 0 || height <= 0) return;
    CGFloat side = 20.0;
    CGFloat innerW = width - side * 2;

    // 顶栏：返回 44 + 胶囊
    CGFloat topY = self.view.safeAreaInsets.top + 10.0;
    self.backButton.frame = CGRectMake(side, topY, 44.0, 44.0);
    self.pillView.frame = CGRectMake(side + 54.0, topY, innerW - 54.0, 44.0);
    CGFloat px = 14.0;
    self.dotView.frame = CGRectMake(px, 18.0, 8.0, 8.0);
    px += 8.0 + 10.0;
    CGFloat syncW = self.syncBadge.hidden ? 0 : 84.0;
    CGFloat timerW = 44.0;
    CGFloat modeW = MIN(ceil([self.modeLabel sizeThatFits:CGSizeMake(200.0, 44.0)].width),
                        CGRectGetWidth(self.pillView.bounds) - px - 10.0 - 1.0 - 10.0 - timerW - 8.0 - syncW - 8.0);
    self.modeLabel.frame = CGRectMake(px, 0, MAX(modeW, 0), 44.0);
    px += MAX(modeW, 0) + 10.0;
    self.pillSeparator.frame = CGRectMake(px, 14.0, 1.0, 16.0);
    px += 1.0 + 10.0;
    self.timerLabel.frame = CGRectMake(px, 0, timerW, 44.0);
    self.syncBadge.frame = CGRectMake(CGRectGetWidth(self.pillView.bounds) - 8.0 - syncW, 8.0, syncW, 28.0);
    self.syncIcon.frame = CGRectMake(10.0, 7.0, 14.0, 14.0);
    self.syncLabel.frame = CGRectMake(30.0, 0, syncW - 30.0 - 6.0, 28.0);

    // 语言对行：padding 12 20 0，行高 18
    CGFloat ly = CGRectGetMaxY(self.pillView.frame) + 12.0;
    CGFloat lx = side;
    CGFloat selfW = ceil([self.selfLanguageLabel sizeThatFits:CGSizeMake(innerW, 18.0)].width);
    self.selfLanguageLabel.frame = CGRectMake(lx, ly, selfW, 18.0);
    lx += selfW + 8.0;
    self.pairArrow.frame = CGRectMake(lx, ly + 2.0, 14.0, 14.0);
    lx += 14.0 + 8.0;
    CGFloat routeW = ceil([self.routeLabel sizeThatFits:CGSizeMake(innerW, 18.0)].width);
    CGFloat peerW = MIN(ceil([self.peerLanguageLabel sizeThatFits:CGSizeMake(innerW, 18.0)].width),
                        side + innerW - lx - routeW - 8.0);
    self.peerLanguageLabel.frame = CGRectMake(lx, ly, MAX(peerW, 0), 18.0);
    self.routeLabel.frame = CGRectMake(side + innerW - routeW, ly, routeW, 18.0);

    // 底栏：按住说话行 padding 12 16 30，按钮 92 高；上面是状态行 18
    CGFloat bottomPad = MAX(self.view.safeAreaInsets.bottom, 14.0) + 16.0;
    CGFloat holdH = 92.0;
    CGFloat talkTop = height - bottomPad - holdH;
    CGFloat stopW = 64.0;
    CGFloat holdW = floor((width - 32.0 - stopW - 20.0) / 2.0);
    self.holdSelfButton.frame = CGRectMake(16.0, talkTop, holdW, holdH);
    self.stopButton.frame = CGRectMake(16.0 + holdW + 10.0, talkTop + holdH - stopW, stopW, stopW);
    self.holdPeerButton.frame = CGRectMake(width - 16.0 - holdW, talkTop, holdW, holdH);
    self.statusLine.frame = CGRectMake(side, talkTop - 12.0 - 18.0, innerW, 18.0);

    // 对话列表
    CGFloat listTop = CGRectGetMaxY(self.selfLanguageLabel.frame) + 8.0;
    CGFloat listBottom = CGRectGetMinY(self.statusLine.frame) - 8.0;
    self.tableView.frame = CGRectMake(0, listTop, width, listBottom - listTop);
    self.emptyLabel.frame = CGRectInset(self.tableView.frame, 48.0, 40.0);
    CGFloat latestW = ceil([self.latestButton sizeThatFits:CGSizeMake(200.0, 30.0)].width) + 24.0;
    self.latestButton.frame = CGRectMake((width - latestW) / 2.0, listBottom - 8.0 - 30.0, latestW, 30.0);

    // 结束确认面板
    self.confirmOverlay.frame = self.view.bounds;
    CGFloat sheetPad = 20.0;
    CGFloat sheetInnerW = width - sheetPad * 2;
    CGFloat sy = 12.0;
    self.confirmGrab.frame = CGRectMake((width - 36.0) / 2.0, sy, 36.0, 5.0);
    sy += 5.0 + 18.0;
    self.confirmTitleLabel.frame = CGRectMake(sheetPad, sy, sheetInnerW, 28.0);
    sy += 28.0 + 6.0;
    CGFloat bodyH = ceil([self.confirmBodyLabel sizeThatFits:CGSizeMake(sheetInnerW, CGFLOAT_MAX)].height);
    self.confirmBodyLabel.frame = CGRectMake(sheetPad, sy, sheetInnerW, bodyH);
    sy += bodyH + 18.0;
    CGFloat statsH = 14.0 + 15.0 + 2.0 + 22.0 + 14.0;
    self.statsCard.frame = CGRectMake(sheetPad, sy, sheetInnerW, statsH);
    CGFloat colW = floor((sheetInnerW - 32.0 - 14.0 * 2 - 2.0) / 3.0);
    for (NSUInteger i = 0; i < 3; i++) {
        CGFloat cx = 16.0 + i * (colW + 14.0 + 1.0);
        self.statKeyLabels[i].frame = CGRectMake(cx, 14.0, colW, 15.0);
        self.statValueLabels[i].frame = CGRectMake(cx, 14.0 + 15.0 + 2.0, colW, 22.0);
        if (i < 2) self.statDividers[i].frame = CGRectMake(cx + colW + 7.0, 14.0, 1.0, statsH - 28.0);
    }
    sy += statsH + 18.0;
    self.confirmStopButton.frame = CGRectMake(sheetPad, sy, sheetInnerW, 56.0);
    sy += 56.0 + 10.0;
    self.confirmContinueButton.frame = CGRectMake(sheetPad, sy, sheetInnerW, 56.0);
    sy += 56.0 + MAX(self.view.safeAreaInsets.bottom, 16.0) + 18.0;
    CGRect sheetFrame = CGRectMake(0, height - sy, width, sy);
    if (self.confirmSheet.hidden || CGAffineTransformIsIdentity(self.confirmSheet.transform)) {
        self.confirmSheet.frame = sheetFrame;
    } else {
        self.confirmSheet.bounds = CGRectMake(0, 0, width, sy);
        self.confirmSheet.center = CGPointMake(width / 2.0, height - sy / 2.0);
    }
}

#pragma mark - 私有方法 - 会话

/// 启动会话；拒绝原因随 completion 回来
- (void)startSession {
    id<TSAIConversationTranslationInterface> conversation = [TSAIKit sharedInstance].activeContext.conversationTranslation;
    if (conversation == nil) {
        [self failStartWithReason:TSLocalizedString(@"ai_conversation.unavailable")];
        return;
    }
    self.turns = @[];
    self.snapshot = nil;
    self.startDate = [NSDate date];
    self.pressedParticipant = TSAIConversationParticipantNone;
    self.releasePendingTurn = NO;
    TSLog(@"[TSAIConversationTranslationVC] ▶ start mode=%ld self=%ld peer=%ld endpoints=%ld/%ld/%ld/%ld autoPhone=%d",
          (long)self.config.mode, (long)self.config.selfLanguage, (long)self.config.peerLanguage,
          (long)self.config.selfCaptureEndpoint, (long)self.config.selfPlaybackEndpoint,
          (long)self.config.peerCaptureEndpoint, (long)self.config.peerPlaybackEndpoint, self.config.autoSpeakOnPhone);
    __weak typeof(self) weakSelf = self;
    NSString *sessionId = [conversation startWithConfig:self.config
        onSnapshot:^(TSAIConversationTranslationSnapshot *snapshot) {
            [weakSelf handleSnapshot:snapshot];
        }
        onEvent:^(TSAIConversationTranslationEvent *event) {
            [weakSelf handleEvent:event];
        }
        completion:^(TSAIConversationTranslationEndReason reason, NSError *error) {
            [weakSelf handleCompletionWithReason:reason error:error];
        }];
    if (sessionId.length == 0) {
        [self refreshLiveUI];
        return;
    }
    self.sessionId = sessionId;
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onTimerTick) userInfo:nil repeats:YES];
    [self refreshLiveUI];
}

/// 结束会话（幂等）；结束原因随 completion 回调
- (void)stopSessionIfActive {
    if (self.sessionId.length == 0) return;
    TSLog(@"[TSAIConversationTranslationVC] ⏹ stop sessionId=%@", [TSAIInterpreterFormatter shortIdForTaskId:self.sessionId]);
    [[TSAIKit sharedInstance].activeContext.conversationTranslation stopWithSessionId:self.sessionId completion:nil];
}

/// 启动被拒：提示后回到准备页
- (void)failStartWithReason:(NSString *)reason {
    if (self.leavingPage) return;
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:TSLocalizedString(@"ai_conversation.unavailable")
                                            message:reason
                                     preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onTimerTick {
    self.timerLabel.text = [TSAIInterpreterTheme elapsedString:self.startDate ? -[self.startDate timeIntervalSinceNow] : 0];
}

- (BOOL)isSessionActive {
    return self.sessionId.length > 0;
}

#pragma mark - 私有方法 - SDK 回调

/// 快照：重建轮次列表并刷新界面；处理「按下后松开过快」的收尾
- (void)handleSnapshot:(TSAIConversationTranslationSnapshot *)snapshot {
    self.snapshot = snapshot;
    self.turns = snapshot.turns ?: @[];
    if (snapshot.state == TSAIConversationTranslationStateListening
        && snapshot.activeParticipant == self.pressedParticipant) {
        if (self.releasePendingTurn) {
            self.releasePendingTurn = NO;
            self.pressedParticipant = TSAIConversationParticipantNone;
            [[TSAIKit sharedInstance].activeContext.conversationTranslation endTurnWithSessionId:self.sessionId];
        }
    } else if (snapshot.state != TSAIConversationTranslationStateListening) {
        self.pressedParticipant = TSAIConversationParticipantNone;
        self.releasePendingTurn = NO;
    }
    [self refreshLiveUI];
}

/// 事件：拒绝与失败提示用户，其余只记日志
- (void)handleEvent:(TSAIConversationTranslationEvent *)event {
    TSLog(@"[TSAIConversationTranslationVC] event type=%ld participant=%ld initiator=%ld turnId=%@ error=%@",
          (long)event.eventType, (long)event.participant, (long)event.initiator,
          event.turnId, event.error.localizedDescription ?: @"-");
    switch (event.eventType) {
        case TSAIConversationTranslationEventTypeTurnRejectedBusy:
            [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_conversation.live_busy") inView:self.view];
            break;
        case TSAIConversationTranslationEventTypeTurnFailed:
            [TSAIInterpreterTheme showToast:event.error.localizedDescription.length > 0
                                                ? event.error.localizedDescription
                                                : TSLocalizedString(@"ai_conversation.end_reason_failure")
                                     inView:self.view];
            break;
        case TSAIConversationTranslationEventTypeDeviceExitRequested:
            [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_conversation.live_device_exit_requested") inView:self.view];
            break;
        default:
            break;
    }
}

/// 完成：启动即被拒只提示并回准备页；其余一律进入报告页
- (void)handleCompletionWithReason:(TSAIConversationTranslationEndReason)reason error:(nullable NSError *)error {
    BOOL hadSession = [self isSessionActive];
    NSTimeInterval duration = self.startDate ? -[self.startDate timeIntervalSinceNow] : 0;
    TSLog(@"[TSAIConversationTranslationVC] ■ ended reason=%ld turns=%lu error=%@",
          (long)reason, (unsigned long)self.turns.count, error.localizedDescription ?: @"-");
    self.sessionId = nil;
    [self.timer invalidate];
    self.timer = nil;
    self.pressedParticipant = TSAIConversationParticipantNone;
    self.releasePendingTurn = NO;
    [self refreshLiveUI];
    [self setSheet:self.confirmSheet overlay:self.confirmOverlay visible:NO animated:NO];
    if (self.leavingPage) return;
    NSString *reasonText = [TSAIConversationTranslationUI displayNameForEndReason:reason];
    NSString *detail = error.localizedDescription;
    if (!hadSession) {
        [self failStartWithReason:detail.length > 0 ? [NSString stringWithFormat:@"%@\n%@", reasonText, detail] : reasonText];
        return;
    }
    NSString *fullReason = (reason != TSAIConversationTranslationEndReasonUserExitApp && detail.length > 0)
        ? [NSString stringWithFormat:@"%@（%@）", reasonText, detail]
        : reasonText;
    NSMutableArray<TSAIConversationTranslationTurn *> *finished = [NSMutableArray array];
    for (TSAIConversationTranslationTurn *turn in self.turns) {
        if (turn.originalText.length > 0 || turn.translatedText.length > 0) [finished addObject:turn];
    }
    TSAIConversationTranslationReportVC *reportVC =
        [[TSAIConversationTranslationReportVC alloc] initWithConfig:self.config
                                                               turns:finished
                                                            duration:duration
                                                       endReasonText:fullReason
                                                             endDate:[NSDate date]];
    NSMutableArray<UIViewController *> *stack = [self.navigationController.viewControllers mutableCopy];
    [stack removeObject:self];
    [stack addObject:reportVC];
    [self.navigationController setViewControllers:stack animated:YES];
}

#pragma mark - 私有方法 - UI 刷新

/// 会话期间不变的部分：模式、语言、播报出口、按钮副标题、确认面板文案
- (void)refreshStaticUI {
    TSAIConversationTranslationMode preset = [TSAIConversationTranslationUI presetMatchingConfig:self.config];
    self.modeLabel.text = [TSAIConversationTranslationUI titleForMode:preset];
    self.syncBadge.hidden = ![self.config caseParticipates];
    self.selfLanguageLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_conversation.live_self_fmt"),
                                   [TSAIInterpreterFormatter displayNameForLanguage:self.config.selfLanguage]];
    self.peerLanguageLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_conversation.live_peer_fmt"),
                                   [TSAIInterpreterFormatter displayNameForLanguage:self.config.peerLanguage]];
    self.routeLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_conversation.live_route_fmt"),
                            [TSAIConversationTranslationUI nameForEndpoint:self.config.selfPlaybackEndpoint],
                            [TSAIConversationTranslationUI nameForEndpoint:self.config.peerPlaybackEndpoint]];
    [self.holdSelfButton setTitle:[self holdTitleForParticipant:TSAIConversationParticipantSelf primary:TSLocalizedString(@"ai_conversation.hold_to_talk")]
                         forState:UIControlStateNormal];
    [self.holdPeerButton setTitle:[self holdTitleForParticipant:TSAIConversationParticipantPeer primary:TSLocalizedString(@"ai_conversation.hold_to_talk")]
                         forState:UIControlStateNormal];
    self.emptyLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_conversation.live_empty_fmt"),
                            [TSAIConversationTranslationUI nameForEndpoint:self.config.peerCaptureEndpoint]];
    self.confirmBodyLabel.text = [self.config caseParticipates]
        ? TSLocalizedString(@"ai_conversation.confirm_body_case")
        : TSLocalizedString(@"ai_conversation.confirm_body");
    self.statValueLabels[2].text = [TSAIConversationTranslationUI titleForMode:preset];
}

/// 按钮两行文字：第一行状态、第二行「我 · 手机」
- (NSString *)holdTitleForParticipant:(TSAIConversationParticipant)participant primary:(NSString *)primary {
    BOOL isSelf = participant == TSAIConversationParticipantSelf;
    TSAIConversationEndpoint capture = isSelf ? self.config.selfCaptureEndpoint : self.config.peerCaptureEndpoint;
    NSString *who = isSelf ? TSLocalizedString(@"ai_conversation.matrix_col_me") : TSLocalizedString(@"ai_conversation.matrix_col_peer");
    return [NSString stringWithFormat:@"%@\n%@ · %@", primary, who, [TSAIConversationTranslationUI nameForEndpoint:capture]];
}

/// 随快照变化的部分：列表、按钮状态、状态行、指示点
- (void)refreshLiveUI {
    [self.tableView reloadData];
    self.emptyLabel.hidden = self.turns.count > 0;
    if (!self.userScrolledUp) [self scrollToBottomAnimated:NO];

    TSAIConversationTranslationState state = self.snapshot.state;
    BOOL active = [self isSessionActive];
    BOOL ready = active && state == TSAIConversationTranslationStateReady;
    for (NSNumber *boxed in @[ @(TSAIConversationParticipantSelf), @(TSAIConversationParticipantPeer) ]) {
        TSAIConversationParticipant participant = (TSAIConversationParticipant)boxed.integerValue;
        UIButton *button = participant == TSAIConversationParticipantSelf ? self.holdSelfButton : self.holdPeerButton;
        BOOL speaking = active && state == TSAIConversationTranslationStateListening && self.snapshot.activeParticipant == participant;
        NSString *primary;
        if (!active) {
            primary = TSLocalizedString(@"ai_conversation.not_started");
        } else if (speaking) {
            primary = TSLocalizedString(@"ai_conversation.live_release_to_send");
        } else if (state == TSAIConversationTranslationStateListening) {
            primary = participant == TSAIConversationParticipantSelf
                ? TSLocalizedString(@"ai_conversation.live_peer_speaking")
                : TSLocalizedString(@"ai_conversation.live_self_speaking");
        } else if (ready) {
            primary = TSLocalizedString(@"ai_conversation.hold_to_talk");
        } else {
            primary = TSLocalizedString(@"ai_conversation.state_busy");
        }
        [button setTitle:[self holdTitleForParticipant:participant primary:primary] forState:UIControlStateNormal];
        [self styleHoldButton:button participant:participant pressed:speaking enabled:(ready || speaking)];
    }

    if (!active) {
        self.dotView.backgroundColor = [TSAIInterpreterTheme textOnDark2];
        self.statusLine.text = self.snapshot == nil
            ? TSLocalizedString(@"ai_conversation.live_status_connecting")
            : TSLocalizedString(@"ai_conversation.end_reason_user_exit");
        return;
    }
    switch (state) {
        case TSAIConversationTranslationStateReady:
            self.dotView.backgroundColor = [TSAIInterpreterTheme ok];
            self.statusLine.text = self.playingTurnId.length > 0
                ? TSLocalizedString(@"ai_conversation.live_status_replaying")
                : TSLocalizedString(@"ai_conversation.live_status_ready");
            break;
        case TSAIConversationTranslationStateListening:
            self.dotView.backgroundColor = [UIColor colorWithRed:0.95 green:0.64 blue:0.25 alpha:1.0];
            self.statusLine.text = [NSString stringWithFormat:TSLocalizedString(@"ai_conversation.live_status_listening_fmt"),
                                    self.snapshot.activeParticipant == TSAIConversationParticipantSelf
                                        ? TSLocalizedString(@"ai_conversation.matrix_col_me")
                                        : TSLocalizedString(@"ai_conversation.matrix_col_peer")];
            break;
        case TSAIConversationTranslationStateTranslating:
            self.dotView.backgroundColor = [TSAIInterpreterTheme cobalt200];
            self.statusLine.text = TSLocalizedString(@"ai_conversation.live_status_translating");
            break;
        case TSAIConversationTranslationStateEntering:
            self.dotView.backgroundColor = [TSAIInterpreterTheme textOnDark2];
            self.statusLine.text = TSLocalizedString(@"ai_conversation.live_status_connecting");
            break;
        case TSAIConversationTranslationStateExiting:
        default:
            self.dotView.backgroundColor = [TSAIInterpreterTheme textOnDark2];
            self.statusLine.text = TSLocalizedString(@"ai_conversation.live_status_exiting");
            break;
    }
}

/// 按住说话按钮外观：正常填色、按下换浅色 + 放大、不可用置灰
- (void)styleHoldButton:(UIButton *)button participant:(TSAIConversationParticipant)participant pressed:(BOOL)pressed enabled:(BOOL)enabled {
    BOOL isSelf = participant == TSAIConversationParticipantSelf;
    UIColor *base = isSelf ? [TSAIInterpreterTheme cobalt] : [TSAIInterpreterTheme jade];
    UIColor *light = isSelf ? [TSAIInterpreterTheme cobalt200] : [TSAIInterpreterTheme jade200];
    button.enabled = enabled;
    if (pressed) {
        button.backgroundColor = light;
        [button setTitleColor:[TSAIInterpreterTheme ink] forState:UIControlStateNormal];
        button.transform = CGAffineTransformMakeScale(1.04, 1.04);
    } else if (enabled) {
        button.backgroundColor = base;
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.transform = CGAffineTransformIdentity;
    } else {
        button.backgroundColor = [TSAIInterpreterTheme ink2];
        [button setTitleColor:[UIColor colorWithRed:0.44 green:0.47 blue:0.52 alpha:1.0] forState:UIControlStateDisabled];
        button.transform = CGAffineTransformIdentity;
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if (self.turns.count == 0) return;
    [self.tableView layoutIfNeeded];
    NSIndexPath *last = [NSIndexPath indexPathForRow:self.turns.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:last atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

/// 轮次状态行文字：聆听 / 翻译 / 播报
- (NSString *)statusTextForTurn:(TSAIConversationTranslationTurn *)turn {
    BOOL isSelf = turn.speaker == TSAIConversationParticipantSelf;
    TSAIConversationEndpoint listenerOut = isSelf ? self.config.peerPlaybackEndpoint : self.config.selfPlaybackEndpoint;
    NSString *outName = [TSAIConversationTranslationUI nameForEndpoint:listenerOut];
    if (!turn.isFinal) {
        if (turn.translatedText.length > 0 || (turn.originalText.length > 0 && self.snapshot.state == TSAIConversationTranslationStateTranslating)) {
            return TSLocalizedString(@"ai_conversation.live_turn_translating");
        }
        if (turn.initiator == TSAISessionInitiatorDevice) {
            TSAIConversationEndpoint capture = isSelf ? self.config.selfCaptureEndpoint : self.config.peerCaptureEndpoint;
            return [NSString stringWithFormat:TSLocalizedString(@"ai_conversation.live_turn_device_input_fmt"),
                    [TSAIConversationTranslationUI nameForEndpoint:capture]];
        }
        return TSLocalizedString(@"ai_conversation.listening");
    }
    if (self.playingTurnId.length > 0 && [self.playingTurnId isEqualToString:turn.turnId]) {
        return TSLocalizedString(@"ai_conversation.live_turn_replaying");
    }
    BOOL autoPlays = listenerOut != TSAIConversationEndpointPhone || self.config.autoSpeakOnPhone;
    return autoPlays
        ? [NSString stringWithFormat:TSLocalizedString(@"ai_conversation.live_turn_played_fmt"), outName]
        : TSLocalizedString(@"ai_conversation.live_turn_not_played");
}

#pragma mark - 私有方法 - 事件

- (void)onBackTap {
    [self openConfirm];
}

- (void)onStopTap {
    [self openConfirm];
}

/// 按下：就绪态才允许开始一轮；快照未到聆听态前记住按下方
- (void)onHoldTouchDown:(UIButton *)button {
    TSAIConversationParticipant participant = (TSAIConversationParticipant)button.tag;
    if (![self isSessionActive] || participant == TSAIConversationParticipantNone) return;
    if (self.snapshot.state != TSAIConversationTranslationStateReady) return;
    // 需求：开启新的录音时中断当前译文播放
    [self stopArchivedPlayback];
    self.pressedParticipant = participant;
    self.releasePendingTurn = NO;
    [[TSAIKit sharedInstance].activeContext.conversationTranslation beginTurnForParticipant:participant
                                                                                   sessionId:self.sessionId];
    [self styleHoldButton:button participant:participant pressed:YES enabled:YES];
}

/// 松开：已在聆听态则立即结束本轮；否则等快照进入聆听态后结束
- (void)onHoldTouchUp:(UIButton *)button {
    TSAIConversationParticipant participant = (TSAIConversationParticipant)button.tag;
    if (![self isSessionActive] || participant == TSAIConversationParticipantNone) return;
    if (self.snapshot.state == TSAIConversationTranslationStateListening
        && self.snapshot.activeParticipant == participant) {
        self.pressedParticipant = TSAIConversationParticipantNone;
        [[TSAIKit sharedInstance].activeContext.conversationTranslation endTurnWithSessionId:self.sessionId];
        return;
    }
    if (self.pressedParticipant == participant) {
        self.releasePendingTurn = YES;
    }
    [self refreshLiveUI];
}

- (void)onLatestTap {
    self.userScrolledUp = NO;
    self.latestButton.hidden = YES;
    [self scrollToBottomAnimated:YES];
}

- (void)openConfirm {
    self.statValueLabels[0].text = [TSAIInterpreterTheme elapsedString:self.startDate ? -[self.startDate timeIntervalSinceNow] : 0];
    NSUInteger finished = 0;
    for (TSAIConversationTranslationTurn *turn in self.turns) if (turn.isFinal) finished++;
    self.statValueLabels[1].text = [NSString stringWithFormat:TSLocalizedString(@"ai_conversation.confirm_count_fmt"), (unsigned long)finished];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    [self setSheet:self.confirmSheet overlay:self.confirmOverlay visible:YES animated:YES];
}

- (void)onConfirmContinueTap {
    [self setSheet:self.confirmSheet overlay:self.confirmOverlay visible:NO animated:YES];
}

- (void)onConfirmStopTap {
    [self stopArchivedPlayback];
    if (![self isSessionActive]) {
        // 会话已经结束但页面还在（极少见）：直接回准备页
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self stopSessionIfActive];
}

/// 面板显隐（与同传页一致）
- (void)setSheet:(UIView *)sheet overlay:(UIView *)overlay visible:(BOOL)visible animated:(BOOL)animated {
    BOOL currentlyVisible = !sheet.hidden && sheet.tag == 0;
    if (visible == currentlyVisible) return;
    CGFloat offscreen = CGRectGetHeight(sheet.bounds);
    if (visible) {
        sheet.tag = 0;
        overlay.hidden = NO;
        sheet.hidden = NO;
        if (!animated) {
            overlay.alpha = 1.0;
            sheet.transform = CGAffineTransformIdentity;
            return;
        }
        overlay.alpha = 0;
        sheet.transform = CGAffineTransformMakeTranslation(0, offscreen);
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            overlay.alpha = 1.0;
            sheet.transform = CGAffineTransformIdentity;
        } completion:nil];
        return;
    }
    sheet.tag = 1;
    if (!animated) {
        overlay.hidden = YES;
        sheet.hidden = YES;
        sheet.transform = CGAffineTransformIdentity;
        return;
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState animations:^{
        overlay.alpha = 0;
        sheet.transform = CGAffineTransformMakeTranslation(0, offscreen);
    } completion:^(BOOL finished) {
        if (sheet.tag == 1) {
            overlay.hidden = YES;
            sheet.hidden = YES;
            sheet.transform = CGAffineTransformIdentity;
        }
    }];
}

#pragma mark - 私有方法 - 归档音频

/// 点击播放、再次点击停止；只在就绪态重播，避免与采集 / 播报争抢音频会话
- (void)requestPlaybackForTurn:(TSAIConversationTranslationTurn *)turn {
    if (turn.translatedAudio.length == 0) {
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_interpreter.report_no_audio") inView:self.view];
        return;
    }
    if (self.playingTurnId.length > 0 && [self.playingTurnId isEqualToString:turn.turnId]) {
        [self stopArchivedPlayback];
        return;
    }
    if ([self isSessionActive] && self.snapshot.state != TSAIConversationTranslationStateReady) {
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_conversation.restart_later") inView:self.view];
        return;
    }
    NSData *playable = nil;
    if (turn.translatedAudioFormat == TSAIAudioFormatPcm || turn.translatedAudioFormat == TSAIAudioFormatNone) {
        playable = [self wavDataForPCM:turn.translatedAudio];
    } else if (turn.translatedAudioFormat == TSAIAudioFormatWav || turn.translatedAudioFormat == TSAIAudioFormatMp3) {
        playable = turn.translatedAudio;
    }
    if (playable == nil) {
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_conversation.audio_unavailable") inView:self.view];
        return;
    }
    [self.audioPlayer stop];
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:playable error:&error];
    if (self.audioPlayer == nil || error != nil || ![self.audioPlayer prepareToPlay]) {
        TSLog(@"[TSAIConversationTranslationVC] replay failed: %@", error);
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_conversation.audio_unavailable") inView:self.view];
        self.audioPlayer = nil;
        return;
    }
    self.audioPlayer.delegate = self;
    self.playingTurnId = turn.turnId;
    [self.audioPlayer play];
    [self refreshLiveUI];
}

- (void)stopArchivedPlayback {
    if (self.audioPlayer == nil && self.playingTurnId == nil) return;
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    self.playingTurnId = nil;
    [self refreshLiveUI];
}

/// 给裸 PCM（16k / 16bit / mono）加 44 字节 WAV 头
- (NSData *)wavDataForPCM:(NSData *)pcm {
    uint32_t sampleRate = 16000;
    uint16_t channels = 1;
    uint16_t bits = 16;
    uint32_t dataLength = (uint32_t)pcm.length;
    uint16_t blockAlign = channels * bits / 8;
    uint32_t byteRate = sampleRate * blockAlign;
    uint32_t chunkSize = 36 + dataLength;
    uint32_t fmtSize = 16;
    uint16_t audioFormat = 1;
    NSMutableData *wav = [NSMutableData dataWithCapacity:44 + dataLength];
    [wav appendBytes:"RIFF" length:4];
    [wav appendBytes:&chunkSize length:4];
    [wav appendBytes:"WAVE" length:4];
    [wav appendBytes:"fmt " length:4];
    [wav appendBytes:&fmtSize length:4];
    [wav appendBytes:&audioFormat length:2];
    [wav appendBytes:&channels length:2];
    [wav appendBytes:&sampleRate length:4];
    [wav appendBytes:&byteRate length:4];
    [wav appendBytes:&blockAlign length:2];
    [wav appendBytes:&bits length:2];
    [wav appendBytes:"data" length:4];
    [wav appendBytes:&dataLength length:4];
    [wav appendData:pcm];
    return wav;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (player != self.audioPlayer) return;
    self.audioPlayer = nil;
    self.playingTurnId = nil;
    [self refreshLiveUI];
}

#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.turns.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const identifier = @"TSAIConversationTurnCell";
    TSAIConversationTurnCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[TSAIConversationTurnCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    TSAIConversationTranslationTurn *turn = self.turns[indexPath.row];
    BOOL isSelf = turn.speaker == TSAIConversationParticipantSelf;
    cell.isSelf = isSelf;
    cell.whoLabel.text = [NSString stringWithFormat:@"%@ · %ld",
                          isSelf ? TSLocalizedString(@"ai_conversation.matrix_col_me") : TSLocalizedString(@"ai_conversation.matrix_col_peer"),
                          (long)turn.index + 1];
    cell.whoLabel.textColor = isSelf ? [TSAIInterpreterTheme cobalt200] : [TSAIInterpreterTheme jade200];
    cell.bubbleView.backgroundColor = isSelf ? [TSAIInterpreterTheme cobalt900] : [TSAIInterpreterTheme jade900];
    cell.originalLabel.text = turn.originalText.length > 0 ? turn.originalText : @"…";
    cell.translatedLabel.text = turn.translatedText ?: @"";
    cell.statusLabel.text = [self statusTextForTurn:turn];
    BOOL playable = turn.isFinal && turn.translatedAudio.length > 0;
    cell.playButton.hidden = !playable;
    BOOL playing = self.playingTurnId.length > 0 && [self.playingTurnId isEqualToString:turn.turnId];
    UIColor *accent = isSelf ? [TSAIInterpreterTheme cobalt200] : [TSAIInterpreterTheme jade200];
    cell.playButton.backgroundColor = playing ? UIColor.whiteColor : [accent colorWithAlphaComponent:0.18];
    [cell.playButton setTitleColor:playing ? [TSAIInterpreterTheme ink] : accent forState:UIControlStateNormal];
    cell.playButton.tintColor = playing ? [TSAIInterpreterTheme ink] : accent;
    UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:9.0 weight:UIImageSymbolWeightBold];
    [cell.playButton setImage:[[UIImage systemImageNamed:playing ? @"stop.fill" : @"play.fill" withConfiguration:cfg]
                                  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                     forState:UIControlStateNormal];
    [cell.playButton setTitle:playing ? TSLocalizedString(@"ai_conversation.live_stop") : TSLocalizedString(@"ai_conversation.live_play")
                     forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    cell.onPlay = ^{ [weakSelf requestPlaybackForTurn:turn]; };
    [cell setNeedsLayout];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSAIConversationTranslationTurn *turn = self.turns[indexPath.row];
    return [TSAIConversationTurnCell heightForOriginal:turn.originalText.length > 0 ? turn.originalText : @"…"
                                            translated:turn.translatedText ?: @""
                                                 width:CGRectGetWidth(tableView.bounds)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.tableView || !scrollView.dragging) return;
    CGFloat distance = scrollView.contentSize.height - scrollView.contentOffset.y - CGRectGetHeight(scrollView.bounds);
    BOOL up = distance > 80.0;
    self.userScrolledUp = up;
    self.latestButton.hidden = !up;
}

#pragma mark - 属性（懒加载）- 顶栏

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [TSAIInterpreterTheme iconButtonWithSymbol:@"chevron.backward"
                                                      background:[TSAIInterpreterTheme ink2]
                                                            tint:[TSAIInterpreterTheme textOnDark]
                                                          target:self
                                                          action:@selector(onBackTap)];
    }
    return _backButton;
}

- (UIView *)pillView {
    if (!_pillView) {
        _pillView = [[UIView alloc] init];
        _pillView.backgroundColor = [TSAIInterpreterTheme ink2];
        _pillView.layer.cornerRadius = 22.0;
    }
    return _pillView;
}

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [[UIView alloc] init];
        _dotView.backgroundColor = [TSAIInterpreterTheme ok];
        _dotView.layer.cornerRadius = 4.0;
    }
    return _dotView;
}

- (UILabel *)modeLabel {
    if (!_modeLabel) {
        _modeLabel = [[UILabel alloc] init];
        _modeLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600];
        _modeLabel.textColor = [TSAIInterpreterTheme textOnDark];
        _modeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _modeLabel;
}

- (UIView *)pillSeparator {
    if (!_pillSeparator) {
        _pillSeparator = [[UIView alloc] init];
        _pillSeparator.backgroundColor = [TSAIInterpreterTheme ink3];
    }
    return _pillSeparator;
}

- (UILabel *)timerLabel {
    if (!_timerLabel) {
        _timerLabel = [[UILabel alloc] init];
        _timerLabel.text = @"00:00";
        _timerLabel.font = [TSAIInterpreterTheme tabularFontOfSize:13.0 cssWeight:400];
        _timerLabel.textColor = [TSAIInterpreterTheme textOnDark2];
    }
    return _timerLabel;
}

- (UIView *)syncBadge {
    if (!_syncBadge) {
        _syncBadge = [[UIView alloc] init];
        _syncBadge.backgroundColor = [TSAIInterpreterTheme jade900];
        _syncBadge.layer.cornerRadius = 14.0;
    }
    return _syncBadge;
}

- (UIImageView *)syncIcon {
    if (!_syncIcon) {
        _syncIcon = [TSAIInterpreterTheme symbolViewNamed:@"display" pointSize:12.0 tint:[TSAIInterpreterTheme jade200]];
    }
    return _syncIcon;
}

- (UILabel *)syncLabel {
    if (!_syncLabel) {
        _syncLabel = [[UILabel alloc] init];
        _syncLabel.text = TSLocalizedString(@"ai_conversation.live_sync");
        _syncLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600];
        _syncLabel.textColor = [TSAIInterpreterTheme jade200];
        _syncLabel.adjustsFontSizeToFitWidth = YES;
        _syncLabel.minimumScaleFactor = 0.8;
    }
    return _syncLabel;
}

#pragma mark - 属性（懒加载）- 语言对

- (UILabel *)selfLanguageLabel {
    if (!_selfLanguageLabel) {
        _selfLanguageLabel = [[UILabel alloc] init];
        _selfLanguageLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600];
        _selfLanguageLabel.textColor = [TSAIInterpreterTheme cobalt200];
    }
    return _selfLanguageLabel;
}

- (UIImageView *)pairArrow {
    if (!_pairArrow) {
        _pairArrow = [TSAIInterpreterTheme symbolViewNamed:@"arrow.up.arrow.down" pointSize:11.0 tint:[TSAIInterpreterTheme textOnDark2]];
    }
    return _pairArrow;
}

- (UILabel *)peerLanguageLabel {
    if (!_peerLanguageLabel) {
        _peerLanguageLabel = [[UILabel alloc] init];
        _peerLanguageLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600];
        _peerLanguageLabel.textColor = [TSAIInterpreterTheme jade200];
        _peerLanguageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _peerLanguageLabel;
}

- (UILabel *)routeLabel {
    if (!_routeLabel) {
        _routeLabel = [[UILabel alloc] init];
        _routeLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:400];
        _routeLabel.textColor = [TSAIInterpreterTheme textOnDark2];
        _routeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _routeLabel;
}

#pragma mark - 属性（懒加载）- 对话

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = UIColor.clearColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.contentInset = UIEdgeInsetsMake(8.0, 0, 8.0, 0);
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _tableView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.font = [TSAIInterpreterTheme fontOfSize:14.0 cssWeight:400];
        _emptyLabel.textColor = TSConversationStatusColor();
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.numberOfLines = 0;
    }
    return _emptyLabel;
}

- (UIButton *)latestButton {
    if (!_latestButton) {
        _latestButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _latestButton.backgroundColor = UIColor.whiteColor;
        _latestButton.layer.cornerRadius = 15.0;
        _latestButton.titleLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600];
        [_latestButton setTitle:TSLocalizedString(@"ai_interpreter.panel_jump_latest") forState:UIControlStateNormal];
        [_latestButton setTitleColor:[TSAIInterpreterTheme ink] forState:UIControlStateNormal];
        _latestButton.hidden = YES;
        [_latestButton addTarget:self action:@selector(onLatestTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _latestButton;
}

- (UILabel *)statusLine {
    if (!_statusLine) {
        _statusLine = [[UILabel alloc] init];
        _statusLine.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400];
        _statusLine.textColor = TSConversationStatusColor();
        _statusLine.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLine;
}

#pragma mark - 属性（懒加载）- 底栏

- (UIButton *)holdButtonForParticipant:(TSAIConversationParticipant)participant {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = participant;
    button.layer.cornerRadius = 24.0;
    button.titleLabel.font = [TSAIInterpreterTheme fontOfSize:15.0 cssWeight:700];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:@selector(onHoldTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(onHoldTouchUp:)
     forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
    return button;
}

- (UIButton *)holdSelfButton {
    if (!_holdSelfButton) _holdSelfButton = [self holdButtonForParticipant:TSAIConversationParticipantSelf];
    return _holdSelfButton;
}

- (UIButton *)holdPeerButton {
    if (!_holdPeerButton) _holdPeerButton = [self holdButtonForParticipant:TSAIConversationParticipantPeer];
    return _holdPeerButton;
}

- (UIButton *)stopButton {
    if (!_stopButton) {
        _stopButton = [TSAIInterpreterTheme roundButtonWithSymbol:@"stop.fill"
                                                        pointSize:22.0
                                                       background:[TSAIInterpreterTheme danger]
                                                             tint:UIColor.whiteColor
                                                           target:self
                                                           action:@selector(onStopTap)];
        _stopButton.layer.cornerRadius = 32.0;
    }
    return _stopButton;
}

#pragma mark - 属性（懒加载）- 结束确认面板

- (UIControl *)confirmOverlay {
    if (!_confirmOverlay) {
        _confirmOverlay = [[UIControl alloc] init];
        _confirmOverlay.backgroundColor = [TSAIInterpreterTheme overlay];
        _confirmOverlay.hidden = YES;
        [_confirmOverlay addTarget:self action:@selector(onConfirmContinueTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmOverlay;
}

- (UIView *)confirmSheet {
    if (!_confirmSheet) {
        _confirmSheet = [[UIView alloc] init];
        _confirmSheet.backgroundColor = [TSAIInterpreterTheme sheetBackground];
        _confirmSheet.layer.cornerRadius = 28.0;
        _confirmSheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        _confirmSheet.hidden = YES;
    }
    return _confirmSheet;
}

- (UIView *)confirmGrab {
    if (!_confirmGrab) {
        _confirmGrab = [[UIView alloc] init];
        _confirmGrab.backgroundColor = [TSAIInterpreterTheme grab];
        _confirmGrab.layer.cornerRadius = 2.5;
    }
    return _confirmGrab;
}

- (UILabel *)confirmTitleLabel {
    if (!_confirmTitleLabel) {
        _confirmTitleLabel = [[UILabel alloc] init];
        _confirmTitleLabel.text = TSLocalizedString(@"ai_conversation.confirm_title");
        _confirmTitleLabel.font = [TSAIInterpreterTheme fontOfSize:22.0 cssWeight:700];
        _confirmTitleLabel.textColor = [TSAIInterpreterTheme ink];
    }
    return _confirmTitleLabel;
}

- (UILabel *)confirmBodyLabel {
    if (!_confirmBodyLabel) {
        _confirmBodyLabel = [[UILabel alloc] init];
        _confirmBodyLabel.font = [TSAIInterpreterTheme fontOfSize:14.0 cssWeight:400];
        _confirmBodyLabel.textColor = [TSAIInterpreterTheme muted];
        _confirmBodyLabel.numberOfLines = 0;
    }
    return _confirmBodyLabel;
}

- (UIView *)statsCard {
    if (!_statsCard) {
        _statsCard = [[UIView alloc] init];
        _statsCard.backgroundColor = [TSAIInterpreterTheme panel];
        _statsCard.layer.cornerRadius = 18.0;
    }
    return _statsCard;
}

- (NSArray<UILabel *> *)statKeyLabels {
    if (!_statKeyLabels) {
        NSMutableArray *labels = [NSMutableArray array];
        for (NSString *key in @[ TSLocalizedString(@"ai_interpreter.confirm_stat_duration"),
                                 TSLocalizedString(@"ai_interpreter.confirm_stat_count"),
                                 TSLocalizedString(@"ai_conversation.confirm_stat_mode") ]) {
            UILabel *label = [[UILabel alloc] init];
            label.text = key;
            label.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400];
            label.textColor = [TSAIInterpreterTheme muted];
            [labels addObject:label];
        }
        _statKeyLabels = labels;
    }
    return _statKeyLabels;
}

- (NSArray<UILabel *> *)statValueLabels {
    if (!_statValueLabels) {
        NSMutableArray *labels = [NSMutableArray array];
        for (NSInteger i = 0; i < 3; i++) {
            UILabel *label = [[UILabel alloc] init];
            label.font = [TSAIInterpreterTheme tabularFontOfSize:18.0 cssWeight:700];
            label.textColor = [TSAIInterpreterTheme ink];
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.7;
            [labels addObject:label];
        }
        _statValueLabels = labels;
    }
    return _statValueLabels;
}

- (NSArray<UIView *> *)statDividers {
    if (!_statDividers) {
        NSMutableArray *dividers = [NSMutableArray array];
        for (NSInteger i = 0; i < 2; i++) {
            UIView *divider = [[UIView alloc] init];
            divider.backgroundColor = [TSAIInterpreterTheme paper];
            [dividers addObject:divider];
        }
        _statDividers = dividers;
    }
    return _statDividers;
}

- (UIButton *)confirmStopButton {
    if (!_confirmStopButton) {
        _confirmStopButton = [TSAIInterpreterTheme ctaButtonWithTitle:TSLocalizedString(@"ai_conversation.confirm_stop")
                                                               symbol:nil
                                                           background:[TSAIInterpreterTheme danger]
                                                                 tint:UIColor.whiteColor
                                                            cssWeight:700
                                                               target:self
                                                               action:@selector(onConfirmStopTap)];
    }
    return _confirmStopButton;
}

- (UIButton *)confirmContinueButton {
    if (!_confirmContinueButton) {
        _confirmContinueButton = [TSAIInterpreterTheme ctaButtonWithTitle:TSLocalizedString(@"ai_interpreter.confirm_continue")
                                                                   symbol:nil
                                                               background:[TSAIInterpreterTheme panel]
                                                                     tint:[TSAIInterpreterTheme ink]
                                                                cssWeight:600
                                                                   target:self
                                                                   action:@selector(onConfirmContinueTap)];
    }
    return _confirmContinueButton;
}

@end
