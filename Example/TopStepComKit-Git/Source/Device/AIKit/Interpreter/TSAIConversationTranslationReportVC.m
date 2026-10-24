//
//  TSAIConversationTranslationReportVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIConversationTranslationReportVC.h"

#import <AVFoundation/AVFoundation.h>
#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSAIAudioSessionIdleWaiter.h"
#import "TSAIConversationTranslationUI.h"
#import "TSAIConversationTranslationVC.h"
#import "TSAIInterpreterFormatter.h"
#import "TSAIInterpreterTheme.h"

#pragma mark - 逐轮卡片

/// 逐轮记录卡片：发言方标签 + 序号 + 播放，原文（参与者色 14）+ 译文（16 / 500）
@interface TSAIConversationReportTurnCard : UIView

@property (nonatomic, strong) UILabel *whoLabel;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *originalLabel;
@property (nonatomic, strong) UILabel *translatedLabel;

/// 按参与者着色
- (void)applyParticipant:(TSAIConversationParticipant)participant;
/// 按宽度计算高度并排布子视图
- (CGFloat)layoutForWidth:(CGFloat)width;

@end

@implementation TSAIConversationReportTurnCard

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [TSAIInterpreterTheme panel];
        self.layer.cornerRadius = 18.0;
        _whoLabel = [[UILabel alloc] init];
        _whoLabel.font = [TSAIInterpreterTheme fontOfSize:11.0 cssWeight:700];
        _whoLabel.textAlignment = NSTextAlignmentCenter;
        _whoLabel.layer.cornerRadius = 10.0;
        _whoLabel.clipsToBounds = YES;
        [self addSubview:_whoLabel];
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [TSAIInterpreterTheme tabularFontOfSize:12.0 cssWeight:400];
        _indexLabel.textColor = [TSAIInterpreterTheme muted];
        [self addSubview:_indexLabel];
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.layer.cornerRadius = 16.0;
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:12.0 weight:UIImageSymbolWeightBold];
        [_playButton setImage:[[UIImage systemImageNamed:@"play.fill" withConfiguration:cfg]
                                  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                     forState:UIControlStateNormal];
        [self addSubview:_playButton];
        _originalLabel = [[UILabel alloc] init];
        _originalLabel.font = [TSAIInterpreterTheme fontOfSize:14.0 cssWeight:400];
        _originalLabel.numberOfLines = 0;
        [self addSubview:_originalLabel];
        _translatedLabel = [[UILabel alloc] init];
        _translatedLabel.font = [TSAIInterpreterTheme fontOfSize:16.0 cssWeight:500];
        _translatedLabel.textColor = [TSAIInterpreterTheme ink];
        _translatedLabel.numberOfLines = 0;
        [self addSubview:_translatedLabel];
    }
    return self;
}

- (void)applyParticipant:(TSAIConversationParticipant)participant {
    BOOL isSelf = participant == TSAIConversationParticipantSelf;
    UIColor *accent = isSelf ? [TSAIInterpreterTheme cobalt] : [TSAIInterpreterTheme jade];
    UIColor *soft = isSelf ? [TSAIInterpreterTheme cobalt50] : [TSAIInterpreterTheme jade50];
    self.whoLabel.text = isSelf ? TSLocalizedString(@"ai_conversation.matrix_col_me") : TSLocalizedString(@"ai_conversation.matrix_col_peer");
    self.whoLabel.textColor = accent;
    self.whoLabel.backgroundColor = soft;
    self.playButton.backgroundColor = soft;
    self.playButton.tintColor = accent;
    self.originalLabel.textColor = accent;
}

- (CGFloat)layoutForWidth:(CGFloat)width {
    // padding 14 16，gap 8；m 行高 32（播放按钮）
    CGFloat innerW = width - 32.0;
    CGFloat y = 14.0;
    CGFloat whoW = ceil([self.whoLabel sizeThatFits:CGSizeMake(innerW, 20.0)].width) + 16.0;
    self.whoLabel.frame = CGRectMake(16.0, y + 6.0, whoW, 20.0);
    CGSize indexSize = [self.indexLabel sizeThatFits:CGSizeMake(innerW, 32.0)];
    self.indexLabel.frame = CGRectMake(16.0 + whoW + 8.0, y, ceil(indexSize.width), 32.0);
    self.playButton.frame = CGRectMake(width - 16.0 - 32.0, y, 32.0, 32.0);
    y += 32.0 + 8.0;
    CGFloat oH = ceil([self.originalLabel sizeThatFits:CGSizeMake(innerW, CGFLOAT_MAX)].height);
    self.originalLabel.frame = CGRectMake(16.0, y, innerW, oH);
    y += oH + 8.0;
    CGFloat tH = ceil([self.translatedLabel sizeThatFits:CGSizeMake(innerW, CGFLOAT_MAX)].height);
    self.translatedLabel.frame = CGRectMake(16.0, y, innerW, tH);
    y += tH + 14.0;
    return y;
}

@end

#pragma mark - 报告页

@interface TSAIConversationTranslationReportVC () <UIGestureRecognizerDelegate, AVAudioPlayerDelegate>

#pragma mark - 视图 - 顶栏
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *shareButton;

#pragma mark - 视图 - 滚动区
@property (nonatomic, strong) UIScrollView *scrollView;
/// 概览卡（深色）
@property (nonatomic, strong) UIView *overviewCard;
@property (nonatomic, strong) UILabel *metaSelfLabel;
@property (nonatomic, strong) UIImageView *metaArrow;
@property (nonatomic, strong) UILabel *metaPeerLabel;
@property (nonatomic, strong) UILabel *metaModeLabel;
@property (nonatomic, copy) NSArray<UILabel *> *bigLabels;
@property (nonatomic, copy) NSArray<UILabel *> *smallLabels;
@property (nonatomic, strong) UILabel *endLabel;
/// 逐轮记录
@property (nonatomic, strong) UILabel *listLabel;
@property (nonatomic, strong) UIButton *copyButton;
@property (nonatomic, copy) NSArray<TSAIConversationReportTurnCard *> *cards;
@property (nonatomic, strong) UILabel *emptyCard;

#pragma mark - 视图 - 底栏
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *changeButton;
@property (nonatomic, strong) UIButton *againButton;

#pragma mark - 状态
@property (nonatomic, strong) TSAIConversationTranslationConfig *config;
@property (nonatomic, copy) NSArray<TSAIConversationTranslationTurn *> *turns;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, copy) NSString *endReasonText;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong, nullable) AVAudioPlayer *player;
// 等待 SDK 拆完音频会话（会话刚结束就点回放时）
@property (nonatomic, strong, nullable) TSAIAudioSessionIdleWaiter *idleWaiter;
@property (nonatomic, weak, nullable) id<UIGestureRecognizerDelegate> previousPopDelegate;

@end

@implementation TSAIConversationTranslationReportVC

#pragma mark - 生命周期

- (instancetype)initWithConfig:(TSAIConversationTranslationConfig *)config
                         turns:(NSArray<TSAIConversationTranslationTurn *> *)turns
                      duration:(NSTimeInterval)duration
                 endReasonText:(NSString *)endReasonText
                       endDate:(NSDate *)endDate {
    self = [super init];
    if (self) {
        _config = config;
        _turns = [turns copy] ?: @[];
        _duration = duration;
        _endReasonText = [endReasonText copy] ?: @"";
        _endDate = endDate ?: [NSDate date];
    }
    return self;
}

- (void)initData {
    [super initData];
    self.view.backgroundColor = [TSAIInterpreterTheme paper];
}

- (void)setupViews {
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.shareButton];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.overviewCard];
    [self.overviewCard addSubview:self.metaSelfLabel];
    [self.overviewCard addSubview:self.metaArrow];
    [self.overviewCard addSubview:self.metaPeerLabel];
    [self.overviewCard addSubview:self.metaModeLabel];
    for (UILabel *label in self.bigLabels) [self.overviewCard addSubview:label];
    for (UILabel *label in self.smallLabels) [self.overviewCard addSubview:label];
    [self.overviewCard addSubview:self.endLabel];
    [self.scrollView addSubview:self.listLabel];
    [self.scrollView addSubview:self.copyButton];
    for (TSAIConversationReportTurnCard *card in self.cards) [self.scrollView addSubview:card];
    [self.scrollView addSubview:self.emptyCard];
    [self.view addSubview:self.footerView];
    [self.footerView addSubview:self.changeButton];
    [self.footerView addSubview:self.againButton];
    [self fillContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.navigationController.interactivePopGestureRecognizer.delegate != self) {
        self.previousPopDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.idleWaiter cancel];
    self.idleWaiter = nil;
    [self.player stop];
    if (self.navigationController.interactivePopGestureRecognizer.delegate == self) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self.previousPopDelegate;
    }
    if (![TSAIConversationTranslationUI isCustomBarPage:self.navigationController.topViewController]) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

#pragma mark - 布局

- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    if (width <= 0 || height <= 0) return;
    CGFloat side = 20.0;
    CGFloat innerW = width - side * 2;

    CGFloat topY = self.view.safeAreaInsets.top + 10.0;
    self.backButton.frame = CGRectMake(side, topY, 44.0, 44.0);
    self.shareButton.frame = CGRectMake(width - side - 44.0, topY, 44.0, 44.0);
    self.titleLabel.frame = CGRectMake(side + 54.0, topY, innerW - 108.0, 44.0);
    CGFloat scrollTop = topY + 44.0 + 8.0;

    CGFloat bottomPad = MAX(self.view.safeAreaInsets.bottom, 16.0);
    CGFloat footerH = 12.0 + 56.0 + bottomPad;
    self.footerView.frame = CGRectMake(0, height - footerH, width, footerH);
    CGFloat ghostW = floor((innerW - 10.0) / 2.4);
    self.changeButton.frame = CGRectMake(side, 12.0, ghostW, 56.0);
    self.againButton.frame = CGRectMake(side + ghostW + 10.0, 12.0, innerW - ghostW - 10.0, 56.0);

    self.scrollView.frame = CGRectMake(0, scrollTop, width, CGRectGetMinY(self.footerView.frame) - scrollTop);
    CGFloat y = 8.0;
    CGFloat overviewH = [self layoutOverviewCardWithWidth:innerW];
    self.overviewCard.frame = CGRectMake(side, y, innerW, overviewH);
    y += overviewH + 16.0;

    self.listLabel.frame = CGRectMake(side, y, innerW - 100.0, 32.0);
    CGSize copySize = [self.copyButton sizeThatFits:CGSizeMake(innerW, 32.0)];
    self.copyButton.frame = CGRectMake(side + innerW - ceil(copySize.width), y, ceil(copySize.width), 32.0);
    y += 32.0 + 16.0;

    if (self.cards.count == 0) {
        self.emptyCard.hidden = NO;
        self.emptyCard.frame = CGRectMake(side, y, innerW, 48.0);
        y += 48.0;
    } else {
        self.emptyCard.hidden = YES;
        for (TSAIConversationReportTurnCard *card in self.cards) {
            CGFloat h = [card layoutForWidth:innerW];
            card.frame = CGRectMake(side, y, innerW, h);
            y += h + 10.0;
        }
        y -= 10.0;
    }
    y += 8.0;
    self.scrollView.contentSize = CGSizeMake(width, y + 12.0);
}

/// 概览卡：padding 18 18 16，gap 14；meta 行可换行，nums 三列，end 一行
- (CGFloat)layoutOverviewCardWithWidth:(CGFloat)width {
    CGFloat innerW = width - 36.0;
    CGFloat y = 18.0;
    CGFloat rowH = 18.0;
    CGFloat x = 18.0;
    CGSize s = [self.metaSelfLabel sizeThatFits:CGSizeMake(innerW, rowH)];
    self.metaSelfLabel.frame = CGRectMake(x, y, ceil(s.width), rowH);
    x += ceil(s.width) + 8.0;
    self.metaArrow.frame = CGRectMake(x, y + 2.0, 14.0, 14.0);
    x += 14.0 + 8.0;
    CGSize p = [self.metaPeerLabel sizeThatFits:CGSizeMake(innerW, rowH)];
    CGFloat peerW = MIN(ceil(p.width), 18.0 + innerW - x);
    self.metaPeerLabel.frame = CGRectMake(x, y, peerW, rowH);
    x += peerW + 8.0;
    CGSize m = [self.metaModeLabel sizeThatFits:CGSizeMake(innerW, rowH)];
    CGFloat modeW = ceil(m.width);
    if (x + modeW <= 18.0 + innerW) {
        self.metaModeLabel.frame = CGRectMake(18.0 + innerW - modeW, y, modeW, rowH);
        y += rowH;
    } else {
        y += rowH + 8.0;
        self.metaModeLabel.frame = CGRectMake(18.0 + innerW - MIN(modeW, innerW), y, MIN(modeW, innerW), rowH);
        y += rowH;
    }
    y += 14.0;
    CGFloat colW = floor((innerW - 12.0 * 2) / 3.0);
    for (NSUInteger i = 0; i < 3; i++) {
        CGFloat cx = 18.0 + i * (colW + 12.0);
        self.bigLabels[i].frame = CGRectMake(cx, y, colW, 31.0);
        self.smallLabels[i].frame = CGRectMake(cx, y + 31.0 + 2.0, colW, 15.0);
    }
    y += 31.0 + 2.0 + 15.0 + 14.0;
    CGFloat endH = ceil([self.endLabel sizeThatFits:CGSizeMake(innerW, CGFLOAT_MAX)].height);
    self.endLabel.frame = CGRectMake(18.0, y, innerW, endH);
    y += endH + 16.0;
    return y;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.navigationController.viewControllers.count > 1;
}

#pragma mark - 私有方法 - 内容

- (void)fillContent {
    self.metaSelfLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_conversation.live_self_fmt"),
                               [TSAIInterpreterFormatter displayNameForLanguage:self.config.selfLanguage]];
    self.metaPeerLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_conversation.live_peer_fmt"),
                               [TSAIInterpreterFormatter displayNameForLanguage:self.config.peerLanguage]];
    self.metaModeLabel.text = [TSAIConversationTranslationUI titleForMode:[TSAIConversationTranslationUI presetMatchingConfig:self.config]];
    NSUInteger selfCount = 0, peerCount = 0;
    for (TSAIConversationTranslationTurn *turn in self.turns) {
        if (turn.speaker == TSAIConversationParticipantSelf) selfCount++; else peerCount++;
    }
    self.bigLabels[0].text = [TSAIInterpreterTheme elapsedString:self.duration];
    self.bigLabels[1].text = [NSString stringWithFormat:@"%lu", (unsigned long)self.turns.count];
    self.bigLabels[2].text = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)selfCount, (unsigned long)peerCount];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M/d HH:mm";
    self.endLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.report_end_reason_fmt"),
                          self.endReasonText, [formatter stringFromDate:self.endDate]];
}

/// 纯文本记录，用于复制 / 分享
- (NSString *)transcriptText {
    NSMutableArray<NSString *> *lines = [NSMutableArray array];
    [self.turns enumerateObjectsUsingBlock:^(TSAIConversationTranslationTurn *turn, NSUInteger idx, BOOL *stop) {
        NSString *who = turn.speaker == TSAIConversationParticipantSelf
            ? TSLocalizedString(@"ai_conversation.matrix_col_me")
            : TSLocalizedString(@"ai_conversation.matrix_col_peer");
        [lines addObject:[NSString stringWithFormat:@"%lu. [%@] %@\n   %@",
                          (unsigned long)idx + 1, who, turn.originalText ?: @"", turn.translatedText ?: @""]];
    }];
    return [lines componentsJoinedByString:@"\n"];
}

#pragma mark - 私有方法 - 事件

- (void)onBackTap {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onShareTap {
    NSString *text = [self transcriptText];
    if (text.length == 0) {
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_conversation.report_empty") inView:self.view];
        return;
    }
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[ text ]
                                                                           applicationActivities:nil];
    activity.popoverPresentationController.sourceView = self.shareButton;
    activity.popoverPresentationController.sourceRect = self.shareButton.bounds;
    [self presentViewController:activity animated:YES completion:nil];
}

- (void)onCopyTap {
    NSString *text = [self transcriptText];
    if (text.length == 0) {
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_conversation.report_empty") inView:self.view];
        return;
    }
    [UIPasteboard generalPasteboard].string = text;
    [TSAIInterpreterTheme showToast:[NSString stringWithFormat:TSLocalizedString(@"ai_conversation.report_copied_fmt"),
                                     (unsigned long)self.turns.count]
                             inView:self.view];
}

/// 回放某轮的合成语音（PCM 16k / 16bit / mono 包成 WAV）
- (void)onPlayTap:(UIButton *)button {
    if (button.tag >= (NSInteger)self.turns.count) return;
    TSAIConversationTranslationTurn *turn = self.turns[button.tag];
    if (turn.translatedAudio.length == 0) {
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_interpreter.report_no_audio") inView:self.view];
        return;
    }
    NSData *playable = nil;
    if (turn.translatedAudioFormat == TSAIAudioFormatPcm || turn.translatedAudioFormat == TSAIAudioFormatNone) {
        playable = [self wavDataForPCM:turn.translatedAudio];
    } else if (turn.translatedAudioFormat == TSAIAudioFormatWav || turn.translatedAudioFormat == TSAIAudioFormatMp3) {
        playable = turn.translatedAudio;
    }
    if (playable == nil) {
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_interpreter.report_audio_unsupported") inView:self.view];
        return;
    }
    [self.idleWaiter cancel];
    self.idleWaiter = nil;
    [self.player stop];
    if ([TSAIAudioSessionIdleWaiter isAudioSessionIdle]) {
        [self playAudioData:playable];
        return;
    }
    // 会话刚结束、SDK 还在拆除音频会话：等它用完再配置，避免拆除里的反激活把回放停掉
    __weak typeof(self) weakSelf = self;
    self.idleWaiter = [TSAIAudioSessionIdleWaiter waitForIdleWithLabel:@"TSAIConversationReport" handler:^(BOOL timedOut) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf.idleWaiter = nil;
        [strongSelf playAudioData:playable];
    }];
}

/// 配置播放会话并回放一段音频
- (void)playAudioData:(NSData *)playable {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    self.player = [[AVAudioPlayer alloc] initWithData:playable error:&error];
    if (self.player == nil || error != nil) {
        TSLog(@"[TSAIConversationReport] replay failed: %@", error);
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_interpreter.report_audio_unsupported") inView:self.view];
        return;
    }
    self.player.delegate = self;
    [self.player play];
}

/// 换个设置：回到准备页
- (void)onChangeTap {
    [self.navigationController popViewControllerAnimated:YES];
}

/// 再来一次：用同一配置开启新会话，并在栈中替换本页
- (void)onAgainTap {
    TSAIConversationTranslationVC *live = [[TSAIConversationTranslationVC alloc] initWithConfig:self.config];
    NSMutableArray<UIViewController *> *stack = [self.navigationController.viewControllers mutableCopy];
    [stack removeObject:self];
    [stack addObject:live];
    [self.navigationController setViewControllers:stack animated:YES];
}

#pragma mark - 私有方法 - 音频

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
    if (player == self.player) self.player = nil;
}

#pragma mark - 属性（懒加载）- 顶栏

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [TSAIInterpreterTheme iconButtonWithSymbol:@"chevron.backward"
                                                      background:[TSAIInterpreterTheme panel]
                                                            tint:[TSAIInterpreterTheme ink]
                                                          target:self
                                                          action:@selector(onBackTap)];
    }
    return _backButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = TSLocalizedString(@"ai_conversation.end_title");
        _titleLabel.font = [TSAIInterpreterTheme fontOfSize:17.0 cssWeight:700];
        _titleLabel.textColor = [TSAIInterpreterTheme ink];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [TSAIInterpreterTheme iconButtonWithSymbol:@"square.and.arrow.up"
                                                       background:[TSAIInterpreterTheme panel]
                                                             tint:[TSAIInterpreterTheme ink]
                                                           target:self
                                                           action:@selector(onShareTap)];
    }
    return _shareButton;
}

#pragma mark - 属性（懒加载）- 滚动区

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)overviewCard {
    if (!_overviewCard) {
        _overviewCard = [[UIView alloc] init];
        _overviewCard.backgroundColor = [TSAIInterpreterTheme ink];
        _overviewCard.layer.cornerRadius = 22.0;
    }
    return _overviewCard;
}

- (UILabel *)metaLabelWithColor:(UIColor *)color weight:(NSInteger)weight {
    UILabel *label = [[UILabel alloc] init];
    label.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:weight];
    label.textColor = color;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    return label;
}

- (UILabel *)metaSelfLabel {
    if (!_metaSelfLabel) _metaSelfLabel = [self metaLabelWithColor:[TSAIInterpreterTheme cobalt200] weight:600];
    return _metaSelfLabel;
}

- (UIImageView *)metaArrow {
    if (!_metaArrow) _metaArrow = [TSAIInterpreterTheme symbolViewNamed:@"arrow.up.arrow.down" pointSize:11.0 tint:[TSAIInterpreterTheme textOnDark2]];
    return _metaArrow;
}

- (UILabel *)metaPeerLabel {
    if (!_metaPeerLabel) _metaPeerLabel = [self metaLabelWithColor:[TSAIInterpreterTheme jade200] weight:600];
    return _metaPeerLabel;
}

- (UILabel *)metaModeLabel {
    if (!_metaModeLabel) {
        _metaModeLabel = [self metaLabelWithColor:[TSAIInterpreterTheme textOnDark2] weight:400];
        _metaModeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _metaModeLabel;
}

- (NSArray<UILabel *> *)bigLabels {
    if (!_bigLabels) {
        NSMutableArray *labels = [NSMutableArray array];
        for (NSInteger i = 0; i < 3; i++) {
            UILabel *label = [[UILabel alloc] init];
            label.font = [TSAIInterpreterTheme tabularFontOfSize:28.0 cssWeight:700];
            label.textColor = [TSAIInterpreterTheme textOnDark];
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.6;
            [labels addObject:label];
        }
        _bigLabels = labels;
    }
    return _bigLabels;
}

- (NSArray<UILabel *> *)smallLabels {
    if (!_smallLabels) {
        NSMutableArray *labels = [NSMutableArray array];
        for (NSString *text in @[ TSLocalizedString(@"ai_interpreter.report_duration"),
                                  TSLocalizedString(@"ai_conversation.report_turns"),
                                  TSLocalizedString(@"ai_conversation.report_split") ]) {
            UILabel *label = [[UILabel alloc] init];
            label.text = text;
            label.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400];
            label.textColor = [TSAIInterpreterTheme textOnDark2];
            [labels addObject:label];
        }
        _smallLabels = labels;
    }
    return _smallLabels;
}

- (UILabel *)endLabel {
    if (!_endLabel) {
        _endLabel = [[UILabel alloc] init];
        _endLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400];
        _endLabel.textColor = [TSAIInterpreterTheme textOnDark2];
        _endLabel.numberOfLines = 0;
    }
    return _endLabel;
}

- (UILabel *)listLabel {
    if (!_listLabel) {
        _listLabel = [[UILabel alloc] init];
        _listLabel.text = TSLocalizedString(@"ai_conversation.report_list");
        _listLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600];
        _listLabel.textColor = [TSAIInterpreterTheme muted];
    }
    return _listLabel;
}

- (UIButton *)copyButton {
    if (!_copyButton) {
        _copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _copyButton.backgroundColor = [TSAIInterpreterTheme panel];
        _copyButton.layer.cornerRadius = 16.0;
        _copyButton.titleLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600];
        _copyButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12.0, 0, 12.0);
        [_copyButton setTitle:TSLocalizedString(@"ai_interpreter.report_copy_all") forState:UIControlStateNormal];
        [_copyButton setTitleColor:[TSAIInterpreterTheme ink] forState:UIControlStateNormal];
        [_copyButton addTarget:self action:@selector(onCopyTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _copyButton;
}

- (NSArray<TSAIConversationReportTurnCard *> *)cards {
    if (!_cards) {
        NSMutableArray *cards = [NSMutableArray arrayWithCapacity:self.turns.count];
        [self.turns enumerateObjectsUsingBlock:^(TSAIConversationTranslationTurn *turn, NSUInteger idx, BOOL *stop) {
            TSAIConversationReportTurnCard *card = [[TSAIConversationReportTurnCard alloc] init];
            [card applyParticipant:turn.speaker];
            card.indexLabel.text = [NSString stringWithFormat:@"#%lu", (unsigned long)idx + 1];
            card.originalLabel.text = turn.originalText ?: @"";
            card.translatedLabel.text = turn.translatedText ?: @"";
            card.playButton.tag = idx;
            card.playButton.hidden = turn.translatedAudio.length == 0;
            [card.playButton addTarget:self action:@selector(onPlayTap:) forControlEvents:UIControlEventTouchUpInside];
            [cards addObject:card];
        }];
        _cards = cards;
    }
    return _cards;
}

- (UILabel *)emptyCard {
    if (!_emptyCard) {
        _emptyCard = [[UILabel alloc] init];
        _emptyCard.text = TSLocalizedString(@"ai_conversation.report_empty");
        _emptyCard.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:400];
        _emptyCard.textColor = [TSAIInterpreterTheme muted];
        _emptyCard.textAlignment = NSTextAlignmentCenter;
        _emptyCard.backgroundColor = [TSAIInterpreterTheme panel];
        _emptyCard.layer.cornerRadius = 18.0;
        _emptyCard.clipsToBounds = YES;
    }
    return _emptyCard;
}

#pragma mark - 属性（懒加载）- 底栏

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = [TSAIInterpreterTheme paper];
    }
    return _footerView;
}

- (UIButton *)changeButton {
    if (!_changeButton) {
        _changeButton = [TSAIInterpreterTheme ctaButtonWithTitle:TSLocalizedString(@"ai_interpreter.report_change")
                                                          symbol:nil
                                                      background:[TSAIInterpreterTheme panel]
                                                            tint:[TSAIInterpreterTheme ink]
                                                       cssWeight:600
                                                          target:self
                                                          action:@selector(onChangeTap)];
    }
    return _changeButton;
}

- (UIButton *)againButton {
    if (!_againButton) {
        _againButton = [TSAIInterpreterTheme ctaButtonWithTitle:TSLocalizedString(@"ai_interpreter.report_again")
                                                         symbol:@"arrow.counterclockwise"
                                                     background:[TSAIInterpreterTheme ink]
                                                           tint:UIColor.whiteColor
                                                      cssWeight:700
                                                         target:self
                                                         action:@selector(onAgainTap)];
    }
    return _againButton;
}

@end
