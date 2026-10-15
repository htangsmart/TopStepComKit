//
//  TSAIInterpreterVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterVC.h"

#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepAIKit/TSAILanguageMapper.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSAIEarbudsPickupAvailability.h"
#import "TSAIInterpreterFormatter.h"
#import "TSAIInterpreterReportVC.h"
#import "TSAIInterpreterTheme.h"
#import "TSAIInterpreterUtteranceUI.h"

/// 历史区最多展示的已完成句数
static const NSUInteger kTSAIInterpreterHistoryLimit = 3;
/// 累积保存的 TTS 音频上限（字节），超出后不再保存但仍计数
static const NSUInteger kTSAIInterpreterAudioKeepLimit = 24 * 1024 * 1024;
/// 译文定稿后等待 TTS 音频的时限（秒），超时视为该语言无语音
static const NSTimeInterval kTSAIInterpreterAudioWaitTimeout = 3.0;

@interface TSAIInterpreterVC ()

#pragma mark - 视图 - 顶栏
/// 返回
@property (nonatomic, strong) UIButton *backButton;
/// 状态胶囊
@property (nonatomic, strong) UIView *pillView;
/// 指示点
@property (nonatomic, strong) UIView *dotView;
/// "X收音"
@property (nonatomic, strong) UILabel *deviceLabel;
/// 分隔
@property (nonatomic, strong) UIView *pillSeparator;
/// 计时
@property (nonatomic, strong) UILabel *timerLabel;
/// "屏端同步"
@property (nonatomic, strong) UIView *syncChip;
@property (nonatomic, strong) UIImageView *syncIcon;
@property (nonatomic, strong) UILabel *syncLabel;

#pragma mark - 视图 - 语言对
@property (nonatomic, strong) UILabel *pairSourceLabel;
@property (nonatomic, strong) UIImageView *pairArrow;
@property (nonatomic, strong) UILabel *pairTargetLabel;
@property (nonatomic, strong) UIImageView *pairSpeakerIcon;
@property (nonatomic, strong) UILabel *pairOutputLabel;

#pragma mark - 视图 - 历史与最新
/// 历史容器（底部对齐、超出裁切）
@property (nonatomic, strong) UIView *historyView;
/// 原文块
@property (nonatomic, strong) UIView *originalBlock;
@property (nonatomic, strong) UILabel *originalNumLabel;
@property (nonatomic, strong) UILabel *originalKeyLabel;
@property (nonatomic, strong) UIView *barsView;
@property (nonatomic, copy) NSArray<UIView *> *bars;
@property (nonatomic, strong) UILabel *originalTextLabel;
/// 译文块
@property (nonatomic, strong) UIView *translatedBlock;
@property (nonatomic, strong) UILabel *translatedKeyLabel;
@property (nonatomic, strong) UIImageView *ttsIcon;
@property (nonatomic, strong) UILabel *ttsStateLabel;
@property (nonatomic, strong) UILabel *translatedTextLabel;

#pragma mark - 视图 - 底栏
/// 结束
@property (nonatomic, strong) UIButton *stopButton;
/// 信息与日志
@property (nonatomic, strong) UIButton *infoButton;

#pragma mark - 视图 - 日志面板
@property (nonatomic, strong) UIControl *logOverlay;
@property (nonatomic, strong) UIView *logSheet;
@property (nonatomic, strong) UIView *logGrab;
@property (nonatomic, copy) NSArray<UIView *> *logRows;
@property (nonatomic, strong) UILabel *logSessionValue;
@property (nonatomic, strong) UILabel *logRouteValue;
@property (nonatomic, strong) UILabel *logLanguageValue;
@property (nonatomic, strong) UITextView *logTextView;

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
/// 本次请求
@property (nonatomic, copy) TSAIInterpretationRequest *request;
/// 当前会话 id（nil 表示空闲）
@property (nonatomic, copy, nullable) NSString *sessionId;
/// 最近一次快照
@property (nonatomic, strong, nullable) TSAIInterpretationSnapshot *snapshot;
/// utterance UI 模型（按 index 升序）
@property (nonatomic, strong) NSMutableArray<TSAIInterpreterUtteranceUI *> *utterances;
/// 已保存的音频字节数
@property (nonatomic, assign) NSUInteger keptAudioBytes;
/// 会话开始时间（本地）
@property (nonatomic, strong, nullable) NSDate *startDate;
/// 计时器
@property (nonatomic, strong, nullable) NSTimer *timer;
/// 日志文本
@property (nonatomic, strong) NSMutableString *logText;
/// 是否已启动过
@property (nonatomic, assign) BOOL hasStarted;
/// 页面是否正在退出
@property (nonatomic, assign) BOOL leavingPage;
/// 音量条是否在动
@property (nonatomic, assign) BOOL barsAnimating;
/// 耳机收音时的路由变化监听（只做提示；等待重连与超时结束由 SDK 负责）
@property (nonatomic, strong, nullable) id<NSObject> earbudsRouteObserver;
/// 耳机当前是否处于断开等待中
@property (nonatomic, assign) BOOL earbudsLost;
/// 本次会话是否出现过耳机断开（用于区分「启动时耳机麦不可用」与「中途断开未重连」）
@property (nonatomic, assign) BOOL earbudsLossObserved;

@end

@implementation TSAIInterpreterVC

#pragma mark - 生命周期

- (instancetype)initWithRequest:(TSAIInterpretationRequest *)request {
    self = [super init];
    if (self) {
        _request = [request copy];
    }
    return self;
}

- (void)initData {
    [super initData];
    self.view.backgroundColor = [TSAIInterpreterTheme ink];
    self.utterances = [NSMutableArray array];
    self.logText = [NSMutableString string];
}

- (void)setupViews {
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.pillView];
    [self.pillView addSubview:self.dotView];
    [self.pillView addSubview:self.deviceLabel];
    [self.pillView addSubview:self.pillSeparator];
    [self.pillView addSubview:self.timerLabel];
    [self.pillView addSubview:self.syncChip];
    [self.syncChip addSubview:self.syncIcon];
    [self.syncChip addSubview:self.syncLabel];

    [self.view addSubview:self.pairSourceLabel];
    [self.view addSubview:self.pairArrow];
    [self.view addSubview:self.pairTargetLabel];
    [self.view addSubview:self.pairSpeakerIcon];
    [self.view addSubview:self.pairOutputLabel];

    [self.view addSubview:self.historyView];

    [self.view addSubview:self.originalBlock];
    [self.originalBlock addSubview:self.originalNumLabel];
    [self.originalBlock addSubview:self.originalKeyLabel];
    [self.originalBlock addSubview:self.barsView];
    for (UIView *bar in self.bars) [self.barsView addSubview:bar];
    [self.originalBlock addSubview:self.originalTextLabel];

    [self.view addSubview:self.translatedBlock];
    [self.translatedBlock addSubview:self.translatedKeyLabel];
    [self.translatedBlock addSubview:self.ttsIcon];
    [self.translatedBlock addSubview:self.ttsStateLabel];
    [self.translatedBlock addSubview:self.translatedTextLabel];

    [self.view addSubview:self.stopButton];
    [self.view addSubview:self.infoButton];

    [self.view addSubview:self.logOverlay];
    [self.view addSubview:self.logSheet];
    [self.logSheet addSubview:self.logGrab];
    for (UIView *row in self.logRows) [self.logSheet addSubview:row];
    [self.logSheet addSubview:self.logTextView];

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
    // 同传中禁用侧滑返回，结束只能经确认面板
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
    if (![TSAIInterpreterTheme isInterpreterPage:self.navigationController.topViewController]) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
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
    if (_earbudsRouteObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:_earbudsRouteObserver];
    }
    if (_sessionId.length > 0) {
        [[TSAIKit sharedInstance].activeContext.interpretation stopWithSessionId:_sessionId];
    }
}

#pragma mark - 布局

- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    if (width <= 0 || height <= 0) return;
    CGFloat side = 20.0;
    CGFloat innerW = width - side * 2;

    // 顶栏：padding 54 20 0，gap 10
    CGFloat topY = self.view.safeAreaInsets.top + 10.0;
    self.backButton.frame = CGRectMake(side, topY, 44.0, 44.0);
    self.pillView.frame = CGRectMake(side + 54.0, topY, innerW - 54.0, 44.0);
    [self layoutPill];

    // 语言对：padding 12 20 0
    CGFloat pairY = topY + 44.0 + 12.0;
    [self layoutPairAtY:pairY width:innerW];

    // 底栏：padding 18 20 34；stop 76 居中，info 52 在其右侧 gap 24
    CGFloat bottomPad = MAX(self.view.safeAreaInsets.bottom, 16.0);
    CGFloat footTop = height - bottomPad - 76.0;
    self.stopButton.frame = CGRectMake((width - 76.0) / 2.0, footTop, 76.0, 76.0);
    self.infoButton.frame = CGRectMake(CGRectGetMaxX(self.stopButton.frame) + 24.0, footTop + 12.0, 52.0, 52.0);
    CGFloat latestBottom = footTop - 18.0;

    // 最新一句：两块从底部向上排，gap 10；块内 padding 16 18，hd 18 高 → gap 8 → 正文
    CGFloat blockInnerW = innerW - 36.0;
    CGFloat translatedTextH = MAX(34.0, [self heightForLabel:self.translatedTextLabel width:blockInnerW maxLines:4]);
    CGFloat translatedBlockH = 16.0 + 18.0 + 8.0 + translatedTextH + 16.0;
    self.translatedBlock.frame = CGRectMake(side, latestBottom - translatedBlockH, innerW, translatedBlockH);
    [self layoutTranslatedBlockWithTextHeight:translatedTextH];

    CGFloat originalTextH = MAX(29.0, [self heightForLabel:self.originalTextLabel width:blockInnerW maxLines:4]);
    CGFloat originalBlockH = 16.0 + 18.0 + 8.0 + originalTextH + 16.0;
    self.originalBlock.frame = CGRectMake(side, CGRectGetMinY(self.translatedBlock.frame) - 10.0 - originalBlockH,
                                          innerW, originalBlockH);
    [self layoutOriginalBlockWithTextHeight:originalTextH];

    // 历史：pair 之下 16 到最新块之上 16，内容底部对齐
    CGFloat historyTop = pairY + 18.0 + 16.0;
    CGFloat historyBottom = CGRectGetMinY(self.originalBlock.frame) - 16.0;
    self.historyView.frame = CGRectMake(side, historyTop, innerW, MAX(0, historyBottom - historyTop));
    [self layoutHistory];

    // 面板
    [self layoutLogSheet];
    [self layoutConfirmSheet];
}

/// 胶囊内部：padding 0 8 0 14，gap 10
- (void)layoutPill {
    CGFloat h = CGRectGetHeight(self.pillView.bounds);
    CGFloat w = CGRectGetWidth(self.pillView.bounds);
    CGFloat x = 14.0;
    self.dotView.frame = CGRectMake(x, (h - 8.0) / 2.0, 8.0, 8.0);
    x += 8.0 + 10.0;
    CGSize devSize = [self.deviceLabel sizeThatFits:CGSizeMake(w, h)];
    self.deviceLabel.frame = CGRectMake(x, 0, ceil(devSize.width), h);
    x += ceil(devSize.width) + 10.0;
    self.pillSeparator.frame = CGRectMake(x, (h - 16.0) / 2.0, 1.0, 16.0);
    x += 1.0 + 10.0;
    CGSize tmSize = [self.timerLabel sizeThatFits:CGSizeMake(w, h)];
    self.timerLabel.frame = CGRectMake(x, 0, ceil(tmSize.width) + 2.0, h);
    if (!self.syncChip.hidden) {
        CGSize syncSize = [self.syncLabel sizeThatFits:CGSizeMake(w, 28.0)];
        CGFloat chipW = 10.0 + 14.0 + 6.0 + ceil(syncSize.width) + 10.0;
        self.syncChip.frame = CGRectMake(w - 8.0 - chipW, (h - 28.0) / 2.0, chipW, 28.0);
        self.syncIcon.frame = CGRectMake(10.0, 7.0, 14.0, 14.0);
        self.syncLabel.frame = CGRectMake(30.0, 0, ceil(syncSize.width), 28.0);
    }
}

/// 语言对一行：src → dst … 🔊 朗读端
- (void)layoutPairAtY:(CGFloat)y width:(CGFloat)width {
    CGFloat side = 20.0;
    CGFloat h = 18.0;
    CGFloat x = side;
    CGSize s = [self.pairSourceLabel sizeThatFits:CGSizeMake(width, h)];
    self.pairSourceLabel.frame = CGRectMake(x, y, ceil(s.width), h);
    x += ceil(s.width) + 8.0;
    self.pairArrow.frame = CGRectMake(x, y + 2.0, 14.0, 14.0);
    x += 14.0 + 8.0;
    CGSize outSize = [self.pairOutputLabel sizeThatFits:CGSizeMake(width, h)];
    CGFloat outW = ceil(outSize.width);
    CGFloat outX = side + width - outW;
    self.pairOutputLabel.frame = CGRectMake(outX, y, outW, h);
    self.pairSpeakerIcon.frame = CGRectMake(outX - 4.0 - 14.0, y + 2.0, 14.0, 14.0);
    CGFloat targetMaxW = CGRectGetMinX(self.pairSpeakerIcon.frame) - 8.0 - x;
    CGSize t = [self.pairTargetLabel sizeThatFits:CGSizeMake(targetMaxW, h)];
    self.pairTargetLabel.frame = CGRectMake(x, y, MIN(ceil(t.width), targetMaxW), h);
}

- (void)layoutOriginalBlockWithTextHeight:(CGFloat)textH {
    CGFloat w = CGRectGetWidth(self.originalBlock.bounds);
    self.originalNumLabel.frame = CGRectMake(18.0, 16.0, 18.0, 18.0);
    CGSize keySize = [self.originalKeyLabel sizeThatFits:CGSizeMake(w, 18.0)];
    self.originalKeyLabel.frame = CGRectMake(18.0 + 18.0 + 8.0, 16.0, ceil(keySize.width), 18.0);
    self.barsView.frame = CGRectMake(w - 18.0 - 23.0, 16.0 + 2.0, 23.0, 14.0);
    // 音量条带缩放动画，改 bounds / position 而不是 frame
    [self.bars enumerateObjectsUsingBlock:^(UIView *bar, NSUInteger idx, BOOL *stop) {
        bar.bounds = CGRectMake(0, 0, 3.0, 14.0);
        bar.layer.position = CGPointMake(idx * 5.0 + 1.5, 14.0);
    }];
    self.originalTextLabel.frame = CGRectMake(18.0, 16.0 + 18.0 + 8.0, w - 36.0, textH);
}

- (void)layoutTranslatedBlockWithTextHeight:(CGFloat)textH {
    CGFloat w = CGRectGetWidth(self.translatedBlock.bounds);
    CGSize keySize = [self.translatedKeyLabel sizeThatFits:CGSizeMake(w, 18.0)];
    self.translatedKeyLabel.frame = CGRectMake(18.0, 16.0, ceil(keySize.width), 18.0);
    CGSize stateSize = [self.ttsStateLabel sizeThatFits:CGSizeMake(w, 18.0)];
    CGFloat stateW = ceil(stateSize.width);
    self.ttsStateLabel.frame = CGRectMake(w - 18.0 - stateW, 16.0, stateW, 18.0);
    self.ttsIcon.frame = CGRectMake(CGRectGetMinX(self.ttsStateLabel.frame) - 4.0 - 14.0, 18.0, 14.0, 14.0);
    self.translatedTextLabel.frame = CGRectMake(18.0, 16.0 + 18.0 + 8.0, w - 36.0, textH);
}

/// 历史区：每句 原文 14 + 4 + 译文 15，句间 14，底部对齐
- (void)layoutHistory {
    CGFloat w = CGRectGetWidth(self.historyView.bounds);
    CGFloat h = CGRectGetHeight(self.historyView.bounds);
    CGFloat y = h;
    NSArray<UIView *> *items = self.historyView.subviews;
    for (NSInteger i = items.count - 1; i >= 0; i--) {
        UIView *item = items[i];
        UILabel *o = item.subviews.firstObject;
        UILabel *t = item.subviews.lastObject;
        CGFloat oH = [self heightForLabel:o width:w maxLines:2];
        CGFloat tH = [self heightForLabel:t width:w maxLines:2];
        CGFloat itemH = oH + 4.0 + tH;
        y -= itemH;
        item.frame = CGRectMake(0, y, w, itemH);
        o.frame = CGRectMake(0, 0, w, oH);
        t.frame = CGRectMake(0, oH + 4.0, w, tH);
        y -= 14.0;
    }
}

/// 日志面板：max-height 60%，kv 行 + 日志文本
- (void)layoutLogSheet {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    self.logOverlay.frame = self.view.bounds;
    CGFloat bottomPad = MAX(self.view.safeAreaInsets.bottom, 16.0);
    CGFloat sheetH = floor(height * 0.6);
    // 面板用 transform 做上滑动画，布局时只改 bounds / center，避免带着 transform 设 frame 导致位置跳动
    self.logSheet.bounds = CGRectMake(0, 0, width, sheetH);
    self.logSheet.center = CGPointMake(width / 2.0, height - sheetH / 2.0);
    self.logGrab.frame = CGRectMake((width - 36.0) / 2.0, 12.0, 36.0, 5.0);
    CGFloat y = 12.0 + 5.0 + 10.0;
    for (UIView *row in self.logRows) {
        row.frame = CGRectMake(20.0, y, width - 40.0, 33.0);
        UILabel *key = row.subviews[0];
        UILabel *value = row.subviews[1];
        UIView *line = row.subviews[2];
        CGSize keySize = [key sizeThatFits:CGSizeMake(width, 32.0)];
        key.frame = CGRectMake(0, 0, ceil(keySize.width), 32.0);
        value.frame = CGRectMake(ceil(keySize.width) + 12.0, 0, width - 40.0 - ceil(keySize.width) - 12.0, 32.0);
        line.frame = CGRectMake(0, 32.0, width - 40.0, 1.0);
        y += 33.0;
    }
    y += 10.0;
    self.logTextView.frame = CGRectMake(20.0, y, width - 40.0, MAX(40.0, sheetH - y - bottomPad));
}

/// 结束确认面板：padding 12 20 34，gap 18
- (void)layoutConfirmSheet {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    self.confirmOverlay.frame = self.view.bounds;
    CGFloat side = 20.0;
    CGFloat innerW = width - side * 2;
    CGFloat bottomPad = MAX(self.view.safeAreaInsets.bottom, 16.0);
    CGFloat y = 12.0 + 5.0 + 18.0;
    CGFloat titleH = 30.0;
    CGFloat bodyH = ceil([self.confirmBodyLabel sizeThatFits:CGSizeMake(innerW, CGFLOAT_MAX)].height);
    CGFloat statsH = 14.0 + 15.0 + 2.0 + 24.0 + 14.0;
    CGFloat sheetH = y + titleH + 6.0 + bodyH + 18.0 + statsH + 18.0 + 56.0 + 10.0 + 56.0 + bottomPad;
    self.confirmSheet.bounds = CGRectMake(0, 0, width, sheetH);
    self.confirmSheet.center = CGPointMake(width / 2.0, height - sheetH / 2.0);
    self.confirmGrab.frame = CGRectMake((width - 36.0) / 2.0, 12.0, 36.0, 5.0);
    self.confirmTitleLabel.frame = CGRectMake(side, y, innerW, titleH);
    y += titleH + 6.0;
    self.confirmBodyLabel.frame = CGRectMake(side, y, innerW, bodyH);
    y += bodyH + 18.0;
    self.statsCard.frame = CGRectMake(side, y, innerW, statsH);
    CGFloat statsInnerW = innerW - 32.0;
    CGFloat colW = floor((statsInnerW - 14.0 * 2 - 1.0 * 2) / 3.0);
    for (NSUInteger i = 0; i < 3; i++) {
        CGFloat x = 16.0 + i * (colW + 14.0 + 1.0 + 14.0);
        self.statKeyLabels[i].frame = CGRectMake(x, 14.0, colW, 15.0);
        self.statValueLabels[i].frame = CGRectMake(x, 14.0 + 15.0 + 2.0, colW, 24.0);
        if (i < 2) {
            self.statDividers[i].frame = CGRectMake(x + colW + 14.0, 14.0, 1.0, statsH - 28.0);
        }
    }
    y += statsH + 18.0;
    self.confirmStopButton.frame = CGRectMake(side, y, innerW, 56.0);
    y += 56.0 + 10.0;
    self.confirmContinueButton.frame = CGRectMake(side, y, innerW, 56.0);
}

/// 多行文字高度（按 maxLines 封顶）
- (CGFloat)heightForLabel:(UILabel *)label width:(CGFloat)width maxLines:(NSInteger)maxLines {
    NSInteger saved = label.numberOfLines;
    label.numberOfLines = maxLines;
    CGFloat h = ceil([label sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height);
    label.numberOfLines = saved;
    return MAX(h, ceil(label.font.lineHeight));
}

#pragma mark - 私有方法 - UI 刷新

/// 只依赖请求的静态文案
- (void)refreshStaticUI {
    TSAIInterpretationRequest *request = self.request;
    self.deviceLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.live_pickup_fmt"),
                             [TSAIInterpreterFormatter displayNameForPickup:request.pickup]];
    self.syncChip.hidden = request.pickup != TSAIInterpretationPickupChargingCase;
    self.pairSourceLabel.text = [TSAIInterpreterFormatter displayNameForLanguage:request.sourceLanguage];
    self.pairTargetLabel.text = [TSAIInterpreterFormatter displayNameForLanguage:request.targetLanguage];
    self.pairOutputLabel.text = [TSAIInterpreterFormatter playbackNameForRequest:request];
    self.statValueLabels[2].text = [TSAIInterpreterFormatter displayNameForPickup:request.pickup];
    self.confirmBodyLabel.text = request.pickup == TSAIInterpretationPickupChargingCase
        ? TSLocalizedString(@"ai_interpreter.confirm_body_case")
        : TSLocalizedString(@"ai_interpreter.confirm_body");
    self.logRouteValue.text = [NSString stringWithFormat:@"%@ → %@",
                               [TSAIInterpreterFormatter codeForPickup:request.pickup],
                               [TSAIInterpreterFormatter codeForPlaybackOfRequest:request]];
    self.logLanguageValue.text = [NSString stringWithFormat:@"%@ → %@",
                                  [TSAILanguageMapper bcp47CodeForLanguage:request.sourceLanguage] ?: @"auto",
                                  [TSAILanguageMapper bcp47CodeForLanguage:request.targetLanguage] ?: @"-"];
}

/// 随会话变化的部分：指示点、最新句、历史、TTS 状态
- (void)refreshLiveUI {
    // 指示点：聆听中为绿色，其余为警示色
    BOOL listening = self.snapshot.state == TSAIInterpretationStateListening;
    self.dotView.backgroundColor = listening ? [TSAIInterpreterTheme ok] : [TSAIInterpreterTheme warn];
    self.logSessionValue.text = self.sessionId.length > 0
        ? [TSAIInterpreterFormatter shortIdForTaskId:self.sessionId] : @"-";

    // 最新一句 = 最后一个模型；历史 = 它之前最近三句已完成的
    TSAIInterpreterUtteranceUI *latest = self.utterances.lastObject;
    NSMutableArray<TSAIInterpreterUtteranceUI *> *history = [NSMutableArray array];
    for (NSInteger i = (NSInteger)self.utterances.count - 2; i >= 0 && history.count < kTSAIInterpreterHistoryLimit; i--) {
        TSAIInterpreterUtteranceUI *u = self.utterances[i];
        if (u.originalText.length > 0 || u.translatedText.length > 0) {
            [history insertObject:u atIndex:0];
        }
    }
    [self rebuildHistoryWithUtterances:history];

    self.originalNumLabel.text = latest != nil ? [NSString stringWithFormat:@"%ld", (long)(latest.index + 1)] : @"–";
    self.originalTextLabel.text = latest != nil && latest.originalText.length > 0
        ? latest.originalText
        : (latest != nil ? @"" : TSLocalizedString(@"ai_interpreter.live_waiting"));
    self.translatedTextLabel.text = latest.translatedText ?: @"";
    BOOL hearing = latest != nil && !latest.isOriginalFinal;
    [self updateBarsAnimating:hearing];

    NSString *state;
    if (latest == nil) {
        state = TSLocalizedString(@"ai_interpreter.tts_waiting");
    } else if (!latest.isOriginalFinal) {
        state = TSLocalizedString(@"ai_interpreter.tts_recognizing");
    } else if (!latest.isTranslatedFinal) {
        state = TSLocalizedString(@"ai_interpreter.tts_translating");
    } else if (!self.request.enableVoiceOutput) {
        state = TSLocalizedString(@"ai_interpreter.tts_text_only");
    } else if (latest.isAudioUnavailable) {
        state = TSLocalizedString(@"ai_interpreter.tts_no_audio");
    } else if (!latest.isAudioFinal) {
        state = [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.tts_playing_fmt"),
                 [TSAIInterpreterFormatter playbackTargetShortNameForRequest:self.request]];
    } else {
        state = TSLocalizedString(@"ai_interpreter.tts_played");
    }
    self.ttsStateLabel.text = state;
    [self.view setNeedsLayout];
}

/// 重建历史区子视图
- (void)rebuildHistoryWithUtterances:(NSArray<TSAIInterpreterUtteranceUI *> *)history {
    for (UIView *item in self.historyView.subviews.copy) [item removeFromSuperview];
    for (TSAIInterpreterUtteranceUI *u in history) {
        UIView *item = [[UIView alloc] init];
        item.alpha = 0.55;
        UILabel *o = [[UILabel alloc] init];
        o.text = u.originalText ?: @"";
        o.font = [TSAIInterpreterTheme fontOfSize:14.0 cssWeight:400];
        o.textColor = [TSAIInterpreterTheme textOnDark2];
        o.numberOfLines = 2;
        [item addSubview:o];
        UILabel *t = [[UILabel alloc] init];
        t.text = u.translatedText ?: @"";
        t.font = [TSAIInterpreterTheme fontOfSize:15.0 cssWeight:400];
        t.textColor = [TSAIInterpreterTheme textOnDark];
        t.numberOfLines = 2;
        [item addSubview:t];
        [self.historyView addSubview:item];
    }
}

/// 音量条：聆听中循环起伏，否则压扁为 4pt 半透明
/// （方法名不能叫 setBarsAnimating:，否则会覆盖属性 setter 导致自递归）
- (void)updateBarsAnimating:(BOOL)animating {
    if (animating == self.barsAnimating) return;
    self.barsAnimating = animating;
    [self.bars enumerateObjectsUsingBlock:^(UIView *bar, NSUInteger idx, BOOL *stop) {
        [bar.layer removeAllAnimations];
        if (animating) {
            bar.alpha = 1.0;
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
            anim.fromValue = @(5.0 / 14.0);
            anim.toValue = @(1.0);
            anim.duration = 0.45;
            anim.autoreverses = YES;
            anim.repeatCount = HUGE_VALF;
            anim.beginTime = CACurrentMediaTime() + idx * 0.15;
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [bar.layer addAnimation:anim forKey:@"bar"];
        } else {
            bar.alpha = 0.5;
            bar.layer.transform = CATransform3DMakeScale(1.0, 4.0 / 14.0, 1.0);
        }
    }];
    if (animating) {
        for (UIView *bar in self.bars) bar.layer.transform = CATransform3DIdentity;
    }
}

- (void)refreshTimer {
    NSTimeInterval elapsed = self.startDate ? -[self.startDate timeIntervalSinceNow] : 0;
    self.timerLabel.text = [TSAIInterpreterTheme elapsedString:elapsed];
    // 只重排胶囊，不触发整页布局（面板动画期间整页布局会打断动画）
    [self layoutPill];
}

#pragma mark - 私有方法 - 事件

- (void)onBackTap {
    [self openConfirm];
}

- (void)onStopTap {
    [self openConfirm];
}

- (void)onInfoTap {
    self.logTextView.text = self.logText;
    [self setSheet:self.logSheet overlay:self.logOverlay visible:YES];
}

- (void)onLogOverlayTap {
    [self setSheet:self.logSheet overlay:self.logOverlay visible:NO];
}

- (void)onConfirmContinueTap {
    [self setSheet:self.confirmSheet overlay:self.confirmOverlay visible:NO];
}

- (void)onConfirmStopTap {
    [self setSheet:self.confirmSheet overlay:self.confirmOverlay visible:NO];
    if ([self isSessionActive]) {
        [self stopSessionIfActive];
    } else {
        // 会话尚未建立就点了结束：直接回准备页
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/// 打开结束确认面板并刷新统计
- (void)openConfirm {
    NSTimeInterval elapsed = self.startDate ? -[self.startDate timeIntervalSinceNow] : 0;
    self.statValueLabels[0].text = [TSAIInterpreterTheme elapsedString:elapsed];
    self.statValueLabels[1].text = [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.confirm_count_fmt"),
                                    (unsigned long)[self completedUtterances].count];
    [self.view setNeedsLayout];
    [self setSheet:self.confirmSheet overlay:self.confirmOverlay visible:YES];
}

/// 面板显隐（带淡入 / 上滑）；重复调用同一状态会被忽略，避免动画叠加
- (void)setSheet:(UIView *)sheet overlay:(UIView *)overlay visible:(BOOL)visible {
    [self setSheet:sheet overlay:overlay visible:visible animated:YES];
}

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
    // tag = 1 表示正在收起，期间再次调用 visible:NO 直接忽略
    sheet.tag = 1;
    if (!animated) {
        overlay.hidden = YES;
        sheet.hidden = YES;
        overlay.alpha = 0;
        sheet.transform = CGAffineTransformIdentity;
        sheet.tag = 0;
        return;
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState animations:^{
        overlay.alpha = 0;
        sheet.transform = CGAffineTransformMakeTranslation(0, offscreen);
    } completion:^(BOOL finished) {
        if (sheet.tag != 1) return;   // 收起过程中又被打开，保持打开状态
        overlay.hidden = YES;
        sheet.hidden = YES;
        sheet.transform = CGAffineTransformIdentity;
        sheet.tag = 0;
    }];
}

#pragma mark - 私有方法 - 会话

- (BOOL)isSessionActive {
    return self.sessionId.length > 0;
}

/// 启动会话：把意图交给 SDK 会话
- (void)startSession {
    id<TSAIInterpretationInterface> interpretation = [TSAIKit sharedInstance].activeContext.interpretation;
    if (interpretation == nil || [self isSessionActive]) {
        [self failStartWithReason:TSLocalizedString(@"ai_interpreter.toast_unavailable")];
        return;
    }
    TSAIInterpretationRequest *request = self.request;
    [self.utterances removeAllObjects];
    self.keptAudioBytes = 0;
    self.startDate = [NSDate date];
    [self.timer invalidate];
    __weak typeof(self) weakTimerSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer *timer) {
        [weakTimerSelf refreshTimer];
    }];
    [self refreshTimer];
    [self log:[NSString stringWithFormat:@"session starting pickup=%@ output=%@ lang=%@→%@ speaker=%@",
               [TSAIInterpreterFormatter codeForPickup:request.pickup],
               [TSAIInterpreterFormatter codeForPlaybackOfRequest:request],
               [TSAILanguageMapper bcp47CodeForLanguage:request.sourceLanguage] ?: @"auto",
               [TSAILanguageMapper bcp47CodeForLanguage:request.targetLanguage] ?: @"-",
               request.speakerId.length > 0 ? request.speakerId : @"(default)"]];

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
        // 拒绝原因随 completion 回来
        [self refreshLiveUI];
        return;
    }
    [self startObservingEarbudsIfNeeded];
    self.snapshot = interpretation.snapshot;
    [self log:[NSString stringWithFormat:@"sessionId=%@", [TSAIInterpreterFormatter shortIdForTaskId:sessionId]]];
    [self refreshLiveUI];
}

/// 结束会话（幂等）
- (void)stopSessionIfActive {
    if (![self isSessionActive]) return;
    [self log:[NSString stringWithFormat:@"stop sessionId=%@", [TSAIInterpreterFormatter shortIdForTaskId:self.sessionId]]];
    [[TSAIKit sharedInstance].activeContext.interpretation stopWithSessionId:self.sessionId];
}

#pragma mark - 私有方法 - 耳机收音

/// 耳机收音时监听路由变化，给出断开 / 重连提示
- (void)startObservingEarbudsIfNeeded {
    if (self.earbudsRouteObserver != nil || self.request.pickup != TSAIInterpretationPickupEarbuds) return;
    self.earbudsLost = NO;
    self.earbudsLossObserved = NO;
    __weak typeof(self) weakSelf = self;
    self.earbudsRouteObserver = [[NSNotificationCenter defaultCenter]
        addObserverForName:AVAudioSessionRouteChangeNotification
                    object:nil
                     queue:[NSOperationQueue mainQueue]
                usingBlock:^(NSNotification *notification) {
        [weakSelf handleEarbudsRouteChange:notification];
    }];
}

/// 停止监听
- (void)stopObservingEarbuds {
    if (self.earbudsRouteObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.earbudsRouteObserver];
        self.earbudsRouteObserver = nil;
    }
    self.earbudsLost = NO;
}

/// 路由变化：蓝牙设备被移除且已无蓝牙音频为断开；新设备接入且蓝牙音频恢复为重连（与对话翻译同一判断）。
/// SDK 在宽限期内自动选回耳机麦继续收音，超时则以 AudioRouteUnavailable 结束会话
- (void)handleEarbudsRouteChange:(NSNotification *)notification {
    if (![self isSessionActive]) return;
    NSUInteger reason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable && !self.earbudsLost) {
        AVAudioSessionRouteDescription *previousRoute = notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
        if ([TSAIEarbudsPickupAvailability routeContainsBluetoothAudio:previousRoute]
            && [TSAIEarbudsPickupAvailability connectedBluetoothAudioDeviceNameAllowingProbe:NO] == nil) {
            self.earbudsLost = YES;
            self.earbudsLossObserved = YES;
            [self log:[NSString stringWithFormat:@"earbuds lost, waiting %.0fs for reconnect", TSAIEarbudsReconnectGracePeriod]];
            [TSAIInterpreterTheme showToast:[NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.live_earbuds_lost"),
                                             TSAIEarbudsReconnectGracePeriod]
                                     inView:self.view];
        }
    } else if (reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable && self.earbudsLost
               && [TSAIEarbudsPickupAvailability connectedBluetoothAudioDeviceNameAllowingProbe:NO] != nil) {
        self.earbudsLost = NO;
        [self log:@"earbuds reconnected"];
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_interpreter.live_earbuds_reconnected") inView:self.view];
    }
}

/// 是否为耳机收音的路由失败（启动时耳机麦不可用，或中途断开未重连）；来电等系统打断以 AudioInterrupted 结束，不算
- (BOOL)isEarbudsRouteFailure:(TSAIInterpretationSnapshot *)snapshot {
    NSError *error = snapshot.error;
    return self.request.pickup == TSAIInterpretationPickupEarbuds
        && snapshot.endReason == TSAIInterpretationEndReasonFailure
        && [error.domain isEqualToString:TSAIErrorDomain]
        && (error.code == TSAIErrorCodeAudioRouteUnavailable || error.code == TSAIErrorCodeAudioRouteMismatch);
}

/// 启动失败：提示原因后回到准备页
- (void)failStartWithReason:(NSString *)reason {
    [self.timer invalidate];
    self.timer = nil;
    if (self.leavingPage) return;
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:TSLocalizedString(@"ai_interpreter.live_start_failed")
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

/// 译文定稿后若超时仍无任何音频，标记为「该语言无语音」，避免状态一直停在「播放中」
- (void)scheduleAudioWatchdogForUtterance:(TSAIInterpreterUtteranceUI *)utterance {
    if (!self.request.enableVoiceOutput) return;
    __weak typeof(self) weakSelf = self;
    __weak TSAIInterpreterUtteranceUI *weakUtterance = utterance;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTSAIInterpreterAudioWaitTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        TSAIInterpreterUtteranceUI *target = weakUtterance;
        if (strongSelf == nil || target == nil) return;
        if (target.audioBytes > 0 || target.isAudioFinal || target.isAudioUnavailable) return;
        target.isAudioUnavailable = YES;
        [strongSelf log:[NSString stringWithFormat:@"utterance %ld no tts audio within %.0fs, target language has no voice",
                         (long)(target.index + 1), kTSAIInterpreterAudioWaitTimeout]];
        [strongSelf refreshLiveUI];
    });
}

#pragma mark - 私有方法 - SDK 回调

- (void)handleSnapshot:(TSAIInterpretationSnapshot *)snapshot {
    if (![snapshot.sessionId isEqualToString:self.sessionId]) return;
    self.snapshot = snapshot;
    if (snapshot.startDate != nil) {
        self.startDate = snapshot.startDate;
    }
    [self refreshLiveUI];
}

/// 内容：按 contentType 更新对应 utterance
- (void)handleContent:(TSAIInterpreterContent *)content {
    if (![self isSessionActive]) return;
    if (content.contentType != TSAIInterpreterContentTypeOriginalText
        && content.contentType != TSAIInterpreterContentTypeTranslatedText
        && content.contentType != TSAIInterpreterContentTypeAudioChunk) {
        return;
    }
    TSAIInterpreterUtteranceUI *utterance = [self utteranceUIForIndex:content.utteranceIndex];
    switch (content.contentType) {
        case TSAIInterpreterContentTypeOriginalText:
            utterance.originalText = content.text;
            if (content.isTextFinal && !utterance.isOriginalFinal) {
                utterance.originalFinalDate = [NSDate date];
                [self log:[NSString stringWithFormat:@"utterance %ld original final", (long)(utterance.index + 1)]];
            }
            utterance.isOriginalFinal = content.isTextFinal;
            break;
        case TSAIInterpreterContentTypeTranslatedText:
            utterance.translatedText = content.text;
            if (content.isTextFinal && !utterance.isTranslatedFinal) {
                utterance.translatedFinalDate = [NSDate date];
                [self scheduleAudioWatchdogForUtterance:utterance];
                [self log:[NSString stringWithFormat:@"utterance %ld translated final%@", (long)(utterance.index + 1),
                           self.request.enableVoiceOutput
                               ? [NSString stringWithFormat:@", tts → %@", [TSAIInterpreterFormatter codeForPlaybackOfRequest:self.request]]
                               : @""]];
            }
            utterance.isTranslatedFinal = content.isTextFinal;
            break;
        case TSAIInterpreterContentTypeAudioChunk:
            utterance.audioBytes += content.audioChunk.length;
            utterance.isAudioUnavailable = NO;
            if (utterance.audioFormat == TSAIAudioFormatNone) {
                utterance.audioFormat = content.audioFormat;
            }
            if (content.audioChunk.length > 0 && self.keptAudioBytes + content.audioChunk.length <= kTSAIInterpreterAudioKeepLimit) {
                [utterance.audioData appendData:content.audioChunk];
                self.keptAudioBytes += content.audioChunk.length;
            }
            utterance.isAudioFinal = content.isAudioFinal;
            break;
        default:
            return;
    }
    [self refreshLiveUI];
}

/// 事件：写日志；UtteranceStarted 先建模型，让「对方说」块立刻切到新句
- (void)handleEvent:(TSAIInterpreterEvent *)event {
    switch (event.eventType) {
        case TSAIInterpreterEventTypeSessionStarted:
            [self log:@"session started"];
            break;
        case TSAIInterpreterEventTypeUtteranceStarted:
            [self log:[NSString stringWithFormat:@"utterance %ld speech begin", (long)(event.utteranceIndex + 1)]];
            [self utteranceUIForIndex:event.utteranceIndex];
            [self refreshLiveUI];
            break;
        case TSAIInterpreterEventTypeUtteranceEnded:
            [self log:[NSString stringWithFormat:@"utterance %ld speech end", (long)(event.utteranceIndex + 1)]];
            break;
        case TSAIInterpreterEventTypeLanguageDetected:
            [self log:[NSString stringWithFormat:@"language detected: %@",
                       [TSAIInterpreterFormatter displayNameForLanguage:event.detectedLanguage]]];
            if (self.request.sourceLanguage == TSAILanguageAuto) {
                self.pairSourceLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.panel_lang_auto_fmt"),
                                             [TSAIInterpreterFormatter displayNameForLanguage:event.detectedLanguage]];
                [self.view setNeedsLayout];
            }
            break;
        case TSAIInterpreterEventTypeNetworkError:
            [self log:@"network error (waiting for recovery)"];
            break;
        case TSAIInterpreterEventTypeBleDisconnected:
            [self log:@"ble disconnected"];
            break;
        default:
            break;
    }
}

/// 完成：用报告校正字幕，然后切到报告页
- (void)handleCompletionWithReport:(nullable TSAIInterpreterReport *)report
                          snapshot:(TSAIInterpretationSnapshot *)snapshot {
    BOOL rejectedStart = self.sessionId.length == 0 && snapshot.sessionId.length == 0;
    if (!rejectedStart && ![snapshot.sessionId isEqualToString:self.sessionId]) {
        return;
    }
    self.sessionId = nil;
    self.snapshot = snapshot;
    [self.timer invalidate];
    self.timer = nil;
    BOOL earbudsLossObserved = self.earbudsLossObserved;
    [self stopObservingEarbuds];
    if (report != nil) {
        [self reconcileUtterancesWithReport:report];
    }
    NSTimeInterval elapsed = snapshot.startDate ? -[snapshot.startDate timeIntervalSinceNow]
                                                : (self.startDate ? -[self.startDate timeIntervalSinceNow] : 0);
    NSString *reasonText = [TSAIInterpreterFormatter displayNameForInterpretationEndReason:snapshot.endReason];
    NSString *detail = snapshot.error.localizedDescription;
    [self log:[NSString stringWithFormat:@"ended dur=%.1fs utt=%lu reason=%@ error=%@",
               elapsed, (unsigned long)[self completedUtterances].count, reasonText, detail ?: @"-"]];
    [self updateBarsAnimating:NO];
    // 即将切到报告页，面板直接收起，不再做动画
    [self setSheet:self.confirmSheet overlay:self.confirmOverlay visible:NO animated:NO];
    [self setSheet:self.logSheet overlay:self.logOverlay visible:NO animated:NO];
    if (self.leavingPage) {
        return;
    }
    if (rejectedStart) {
        [self failStartWithReason:detail.length > 0 ? [NSString stringWithFormat:@"%@\n%@", reasonText, detail] : reasonText];
        return;
    }
    if ([self isEarbudsRouteFailure:snapshot]) {
        // 耳机麦启动即不可用（未出现过断开、也没有任何字幕）：提示并回准备页，方便改用手机收音
        if (!earbudsLossObserved && self.utterances.count == 0) {
            [self failStartWithReason:[NSString stringWithFormat:@"%@\n%@",
                                       TSLocalizedString(@"ai_interpreter.live_earbuds_start_failed"), detail ?: @""]];
            return;
        }
        reasonText = TSLocalizedString(@"ai_interpreter.end_reason_earbuds_lost");
    }
    NSString *fullReason = (snapshot.endReason != TSAIInterpretationEndReasonUserStop && detail.length > 0)
        ? [NSString stringWithFormat:@"%@（%@）", reasonText, detail]
        : reasonText;
    TSAIInterpreterReportVC *reportVC =
        [[TSAIInterpreterReportVC alloc] initWithRequest:self.request
                                              utterances:[self completedUtterances]
                                                duration:elapsed
                                           endReasonText:fullReason
                                                 endDate:[NSDate date]];
    NSMutableArray<UIViewController *> *stack = [self.navigationController.viewControllers mutableCopy];
    [stack removeObject:self];
    [stack addObject:reportVC];
    [self.navigationController setViewControllers:stack animated:YES];
}

#pragma mark - 私有方法 - utterance / report 工具

/// 会话结束后以 report 为准校正每句原文 / 译文，并把未收尾的状态标记为完成
- (void)reconcileUtterancesWithReport:(TSAIInterpreterReport *)report {
    for (TSAIInterpreterUtterance *reported in report.utterances) {
        TSAIInterpreterUtteranceUI *utterance = [self utteranceUIForIndex:reported.index];
        if (reported.originalText.length > 0) {
            utterance.originalText = reported.originalText;
        }
        if (reported.translatedText.length > 0) {
            utterance.translatedText = reported.translatedText;
        }
        utterance.isOriginalFinal = utterance.originalText.length > 0;
        utterance.isTranslatedFinal = utterance.translatedText.length > 0;
        utterance.isAudioFinal = utterance.isAudioFinal || utterance.audioBytes > 0;
        if (self.request.enableVoiceOutput && utterance.audioBytes == 0 && utterance.isTranslatedFinal) {
            utterance.isAudioUnavailable = YES;
        }
    }
}

/// 已有原文或译文的句子（报告用）
- (NSArray<TSAIInterpreterUtteranceUI *> *)completedUtterances {
    NSMutableArray *result = [NSMutableArray array];
    for (TSAIInterpreterUtteranceUI *u in self.utterances) {
        if (u.originalText.length > 0 || u.translatedText.length > 0) [result addObject:u];
    }
    return result;
}

/// 取或建一个 utterance UI 模型（按 index 升序插入）
- (TSAIInterpreterUtteranceUI *)utteranceUIForIndex:(NSInteger)index {
    for (TSAIInterpreterUtteranceUI *exist in self.utterances) {
        if (exist.index == index) return exist;
    }
    TSAIInterpreterUtteranceUI *utterance = [[TSAIInterpreterUtteranceUI alloc] init];
    utterance.index = index;
    utterance.startTime = [NSDate date];
    utterance.startOffsetText = [TSAIInterpreterTheme elapsedString:self.startDate ? -[self.startDate timeIntervalSinceNow] : 0];
    NSUInteger insertAt = self.utterances.count;
    for (NSUInteger i = 0; i < self.utterances.count; i++) {
        if (self.utterances[i].index > index) { insertAt = i; break; }
    }
    [self.utterances insertObject:utterance atIndex:insertAt];
    return utterance;
}

/// 追加一行日志（mm:ss 前缀）
- (void)log:(NSString *)line {
    NSTimeInterval elapsed = self.startDate ? -[self.startDate timeIntervalSinceNow] : 0;
    [self.logText appendFormat:@"%@  %@\n", [TSAIInterpreterTheme elapsedString:elapsed], line];
    if (!self.logSheet.hidden) {
        self.logTextView.text = self.logText;
    }
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
        _pillView.clipsToBounds = YES;
    }
    return _pillView;
}

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [[UIView alloc] init];
        _dotView.backgroundColor = [TSAIInterpreterTheme warn];
        _dotView.layer.cornerRadius = 4.0;
    }
    return _dotView;
}

- (UILabel *)deviceLabel {
    if (!_deviceLabel) {
        _deviceLabel = [[UILabel alloc] init];
        _deviceLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600];
        _deviceLabel.textColor = [TSAIInterpreterTheme textOnDark];
    }
    return _deviceLabel;
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
        _timerLabel.font = [TSAIInterpreterTheme tabularFontOfSize:13.0 cssWeight:400];
        _timerLabel.textColor = [TSAIInterpreterTheme textOnDark2];
        _timerLabel.text = @"00:00";
    }
    return _timerLabel;
}

- (UIView *)syncChip {
    if (!_syncChip) {
        _syncChip = [[UIView alloc] init];
        _syncChip.backgroundColor = [TSAIInterpreterTheme jade900];
        _syncChip.layer.cornerRadius = 14.0;
    }
    return _syncChip;
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
        _syncLabel.text = TSLocalizedString(@"ai_interpreter.live_sync");
        _syncLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600];
        _syncLabel.textColor = [TSAIInterpreterTheme jade200];
    }
    return _syncLabel;
}

#pragma mark - 属性（懒加载）- 语言对

- (UILabel *)pairSourceLabel {
    if (!_pairSourceLabel) {
        _pairSourceLabel = [[UILabel alloc] init];
        _pairSourceLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600];
        _pairSourceLabel.textColor = [TSAIInterpreterTheme jade200];
    }
    return _pairSourceLabel;
}

- (UIImageView *)pairArrow {
    if (!_pairArrow) {
        _pairArrow = [TSAIInterpreterTheme symbolViewNamed:@"arrow.right" pointSize:12.0 tint:[TSAIInterpreterTheme textOnDark2]];
    }
    return _pairArrow;
}

- (UILabel *)pairTargetLabel {
    if (!_pairTargetLabel) {
        _pairTargetLabel = [[UILabel alloc] init];
        _pairTargetLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600];
        _pairTargetLabel.textColor = [TSAIInterpreterTheme cobalt200];
        _pairTargetLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _pairTargetLabel;
}

- (UIImageView *)pairSpeakerIcon {
    if (!_pairSpeakerIcon) {
        _pairSpeakerIcon = [TSAIInterpreterTheme symbolViewNamed:@"speaker.wave.2" pointSize:12.0 tint:[TSAIInterpreterTheme textOnDark2]];
    }
    return _pairSpeakerIcon;
}

- (UILabel *)pairOutputLabel {
    if (!_pairOutputLabel) {
        _pairOutputLabel = [[UILabel alloc] init];
        _pairOutputLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:400];
        _pairOutputLabel.textColor = [TSAIInterpreterTheme textOnDark2];
    }
    return _pairOutputLabel;
}

#pragma mark - 属性（懒加载）- 历史与最新

- (UIView *)historyView {
    if (!_historyView) {
        _historyView = [[UIView alloc] init];
        _historyView.clipsToBounds = YES;
    }
    return _historyView;
}

- (UIView *)originalBlock {
    if (!_originalBlock) {
        _originalBlock = [[UIView alloc] init];
        _originalBlock.backgroundColor = [TSAIInterpreterTheme jade900];
        _originalBlock.layer.cornerRadius = 22.0;
    }
    return _originalBlock;
}

- (UILabel *)originalNumLabel {
    if (!_originalNumLabel) {
        _originalNumLabel = [[UILabel alloc] init];
        _originalNumLabel.font = [TSAIInterpreterTheme fontOfSize:11.0 cssWeight:600];
        _originalNumLabel.textColor = [UIColor whiteColor];
        _originalNumLabel.backgroundColor = [TSAIInterpreterTheme jade];
        _originalNumLabel.textAlignment = NSTextAlignmentCenter;
        _originalNumLabel.layer.cornerRadius = 9.0;
        _originalNumLabel.clipsToBounds = YES;
        _originalNumLabel.text = @"–";
    }
    return _originalNumLabel;
}

- (UILabel *)originalKeyLabel {
    if (!_originalKeyLabel) {
        _originalKeyLabel = [[UILabel alloc] init];
        _originalKeyLabel.text = TSLocalizedString(@"ai_interpreter.setup_src_key");
        _originalKeyLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600];
        _originalKeyLabel.textColor = [TSAIInterpreterTheme jade200];
    }
    return _originalKeyLabel;
}

- (UIView *)barsView {
    if (!_barsView) _barsView = [[UIView alloc] init];
    return _barsView;
}

- (NSArray<UIView *> *)bars {
    if (!_bars) {
        NSMutableArray *bars = [NSMutableArray array];
        for (NSInteger i = 0; i < 5; i++) {
            UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(i * 5.0, 0, 3.0, 14.0)];
            bar.backgroundColor = [TSAIInterpreterTheme jade200];
            bar.layer.cornerRadius = 1.5;
            bar.layer.anchorPoint = CGPointMake(0.5, 1.0);
            bar.alpha = 0.5;
            bar.layer.transform = CATransform3DMakeScale(1.0, 4.0 / 14.0, 1.0);
            [bars addObject:bar];
        }
        _bars = bars;
    }
    return _bars;
}

- (UILabel *)originalTextLabel {
    if (!_originalTextLabel) {
        _originalTextLabel = [[UILabel alloc] init];
        _originalTextLabel.font = [TSAIInterpreterTheme fontOfSize:20.0 cssWeight:500];
        _originalTextLabel.textColor = [TSAIInterpreterTheme textOnDark];
        _originalTextLabel.numberOfLines = 4;
    }
    return _originalTextLabel;
}

- (UIView *)translatedBlock {
    if (!_translatedBlock) {
        _translatedBlock = [[UIView alloc] init];
        _translatedBlock.backgroundColor = [TSAIInterpreterTheme cobalt900];
        _translatedBlock.layer.cornerRadius = 22.0;
    }
    return _translatedBlock;
}

- (UILabel *)translatedKeyLabel {
    if (!_translatedKeyLabel) {
        _translatedKeyLabel = [[UILabel alloc] init];
        _translatedKeyLabel.text = TSLocalizedString(@"ai_interpreter.live_dst_key");
        _translatedKeyLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600];
        _translatedKeyLabel.textColor = [TSAIInterpreterTheme cobalt200];
    }
    return _translatedKeyLabel;
}

- (UIImageView *)ttsIcon {
    if (!_ttsIcon) {
        _ttsIcon = [TSAIInterpreterTheme symbolViewNamed:@"speaker.wave.2" pointSize:12.0 tint:[TSAIInterpreterTheme cobalt200]];
    }
    return _ttsIcon;
}

- (UILabel *)ttsStateLabel {
    if (!_ttsStateLabel) {
        _ttsStateLabel = [[UILabel alloc] init];
        _ttsStateLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600];
        _ttsStateLabel.textColor = [TSAIInterpreterTheme cobalt200];
    }
    return _ttsStateLabel;
}

- (UILabel *)translatedTextLabel {
    if (!_translatedTextLabel) {
        _translatedTextLabel = [[UILabel alloc] init];
        _translatedTextLabel.font = [TSAIInterpreterTheme fontOfSize:24.0 cssWeight:700];
        _translatedTextLabel.textColor = [UIColor whiteColor];
        _translatedTextLabel.numberOfLines = 4;
    }
    return _translatedTextLabel;
}

#pragma mark - 属性（懒加载）- 底栏

- (UIButton *)stopButton {
    if (!_stopButton) {
        _stopButton = [TSAIInterpreterTheme roundButtonWithSymbol:@"stop.fill"
                                                        pointSize:26.0
                                                       background:[TSAIInterpreterTheme danger]
                                                             tint:[UIColor whiteColor]
                                                           target:self
                                                           action:@selector(onStopTap)];
        _stopButton.layer.cornerRadius = 38.0;
    }
    return _stopButton;
}

- (UIButton *)infoButton {
    if (!_infoButton) {
        _infoButton = [TSAIInterpreterTheme roundButtonWithSymbol:@"info.circle"
                                                        pointSize:20.0
                                                       background:[TSAIInterpreterTheme ink2]
                                                             tint:[TSAIInterpreterTheme textOnDark]
                                                           target:self
                                                           action:@selector(onInfoTap)];
        _infoButton.layer.cornerRadius = 26.0;
    }
    return _infoButton;
}

#pragma mark - 属性（懒加载）- 面板共用

- (UIControl *)overlayWithAction:(SEL)action {
    UIControl *overlay = [[UIControl alloc] init];
    overlay.backgroundColor = [TSAIInterpreterTheme overlay];
    overlay.hidden = YES;
    [overlay addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return overlay;
}

- (UIView *)sheetView {
    UIView *sheet = [[UIView alloc] init];
    sheet.backgroundColor = [TSAIInterpreterTheme sheetBackground];
    sheet.layer.cornerRadius = 28.0;
    sheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    sheet.hidden = YES;
    return sheet;
}

- (UIView *)grabView {
    UIView *grab = [[UIView alloc] init];
    grab.backgroundColor = [TSAIInterpreterTheme grab];
    grab.layer.cornerRadius = 2.5;
    return grab;
}

#pragma mark - 属性（懒加载）- 日志面板

- (UIControl *)logOverlay {
    if (!_logOverlay) _logOverlay = [self overlayWithAction:@selector(onLogOverlayTap)];
    return _logOverlay;
}

- (UIView *)logSheet {
    if (!_logSheet) _logSheet = [self sheetView];
    return _logSheet;
}

- (UIView *)logGrab {
    if (!_logGrab) _logGrab = [self grabView];
    return _logGrab;
}

/// kv 行：key muted 左、value 右，底部 1px 细线
- (UIView *)logRowWithKey:(NSString *)key valueLabel:(UILabel *)valueLabel {
    UIView *row = [[UIView alloc] init];
    UILabel *keyLabel = [[UILabel alloc] init];
    keyLabel.text = key;
    keyLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400];
    keyLabel.textColor = [TSAIInterpreterTheme muted];
    [row addSubview:keyLabel];
    valueLabel.font = [TSAIInterpreterTheme tabularFontOfSize:12.0 cssWeight:400];
    valueLabel.textColor = [TSAIInterpreterTheme ink];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [row addSubview:valueLabel];
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [TSAIInterpreterTheme line];
    [row addSubview:line];
    return row;
}

- (NSArray<UIView *> *)logRows {
    if (!_logRows) {
        _logRows = @[
            [self logRowWithKey:@"sessionId" valueLabel:self.logSessionValue],
            [self logRowWithKey:@"pickup → output" valueLabel:self.logRouteValue],
            [self logRowWithKey:@"language" valueLabel:self.logLanguageValue],
        ];
    }
    return _logRows;
}

- (UILabel *)logSessionValue {
    if (!_logSessionValue) _logSessionValue = [[UILabel alloc] init];
    return _logSessionValue;
}

- (UILabel *)logRouteValue {
    if (!_logRouteValue) _logRouteValue = [[UILabel alloc] init];
    return _logRouteValue;
}

- (UILabel *)logLanguageValue {
    if (!_logLanguageValue) _logLanguageValue = [[UILabel alloc] init];
    return _logLanguageValue;
}

- (UITextView *)logTextView {
    if (!_logTextView) {
        _logTextView = [[UITextView alloc] init];
        _logTextView.editable = NO;
        _logTextView.backgroundColor = [UIColor clearColor];
        _logTextView.font = [UIFont monospacedSystemFontOfSize:11.0 weight:UIFontWeightRegular];
        _logTextView.textColor = [TSAIInterpreterTheme muted];
        _logTextView.textContainerInset = UIEdgeInsetsZero;
        _logTextView.textContainer.lineFragmentPadding = 0;
        _logTextView.alwaysBounceVertical = YES;
    }
    return _logTextView;
}

#pragma mark - 属性（懒加载）- 结束确认面板

- (UIControl *)confirmOverlay {
    if (!_confirmOverlay) _confirmOverlay = [self overlayWithAction:@selector(onConfirmContinueTap)];
    return _confirmOverlay;
}

- (UIView *)confirmSheet {
    if (!_confirmSheet) _confirmSheet = [self sheetView];
    return _confirmSheet;
}

- (UIView *)confirmGrab {
    if (!_confirmGrab) _confirmGrab = [self grabView];
    return _confirmGrab;
}

- (UILabel *)confirmTitleLabel {
    if (!_confirmTitleLabel) {
        _confirmTitleLabel = [[UILabel alloc] init];
        _confirmTitleLabel.text = TSLocalizedString(@"ai_interpreter.confirm_title");
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
                                 TSLocalizedString(@"ai_interpreter.confirm_stat_pickup") ]) {
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
        _confirmStopButton = [TSAIInterpreterTheme ctaButtonWithTitle:TSLocalizedString(@"ai_interpreter.confirm_stop")
                                                               symbol:nil
                                                           background:[TSAIInterpreterTheme danger]
                                                                 tint:[UIColor whiteColor]
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
