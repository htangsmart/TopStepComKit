//
//  TSAIInterpreterReportVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterReportVC.h"

#import <AVFoundation/AVFoundation.h>
#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSAIInterpreterFormatter.h"
#import "TSAIInterpreterTheme.h"
#import "TSAIInterpreterUtteranceUI.h"
#import "TSAIInterpreterVC.h"

#pragma mark - 逐句卡片

/// 逐句记录卡片（`.utt`）：序号 + 时间 + 播放，原文（翠绿 14）+ 译文（16 / 500）
@interface TSAIInterpreterReportUtteranceCard : UIView

@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *originalLabel;
@property (nonatomic, strong) UILabel *translatedLabel;

/// 按宽度计算高度并排布子视图
- (CGFloat)layoutForWidth:(CGFloat)width;

@end

@implementation TSAIInterpreterReportUtteranceCard

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [TSAIInterpreterTheme panel];
        self.layer.cornerRadius = 18.0;
        _numLabel = [[UILabel alloc] init];
        _numLabel.font = [TSAIInterpreterTheme fontOfSize:11.0 cssWeight:700];
        _numLabel.textColor = [TSAIInterpreterTheme jade];
        _numLabel.backgroundColor = [TSAIInterpreterTheme jade50];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.layer.cornerRadius = 9.0;
        _numLabel.clipsToBounds = YES;
        [self addSubview:_numLabel];
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [TSAIInterpreterTheme tabularFontOfSize:12.0 cssWeight:400];
        _timeLabel.textColor = [TSAIInterpreterTheme muted];
        [self addSubview:_timeLabel];
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.backgroundColor = [TSAIInterpreterTheme cobalt50];
        _playButton.tintColor = [TSAIInterpreterTheme cobalt];
        _playButton.layer.cornerRadius = 16.0;
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:12.0 weight:UIImageSymbolWeightBold];
        [_playButton setImage:[[UIImage systemImageNamed:@"play.fill" withConfiguration:cfg]
                                  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                     forState:UIControlStateNormal];
        [self addSubview:_playButton];
        _originalLabel = [[UILabel alloc] init];
        _originalLabel.font = [TSAIInterpreterTheme fontOfSize:14.0 cssWeight:400];
        _originalLabel.textColor = [TSAIInterpreterTheme jade];
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

- (CGFloat)layoutForWidth:(CGFloat)width {
    // padding 14 16，gap 8；m 行高 32（播放按钮）
    CGFloat innerW = width - 32.0;
    CGFloat y = 14.0;
    self.numLabel.frame = CGRectMake(16.0, y + 7.0, 18.0, 18.0);
    CGSize timeSize = [self.timeLabel sizeThatFits:CGSizeMake(innerW, 32.0)];
    self.timeLabel.frame = CGRectMake(16.0 + 18.0 + 8.0, y, ceil(timeSize.width), 32.0);
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

@interface TSAIInterpreterReportVC () <UIGestureRecognizerDelegate, AVAudioPlayerDelegate>

#pragma mark - 视图 - 顶栏
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *shareButton;

#pragma mark - 视图 - 滚动区
@property (nonatomic, strong) UIScrollView *scrollView;
/// 概览卡
@property (nonatomic, strong) UIView *overviewCard;
@property (nonatomic, strong) UILabel *metaSourceLabel;
@property (nonatomic, strong) UIImageView *metaArrow;
@property (nonatomic, strong) UILabel *metaTargetLabel;
@property (nonatomic, strong) UILabel *metaRouteLabel;
@property (nonatomic, copy) NSArray<UILabel *> *bigLabels;
@property (nonatomic, copy) NSArray<UILabel *> *smallLabels;
@property (nonatomic, strong) UILabel *endLabel;
/// 「逐句记录」行
@property (nonatomic, strong) UILabel *listLabel;
@property (nonatomic, strong) UIButton *copyButton;
/// 逐句卡片
@property (nonatomic, copy) NSArray<TSAIInterpreterReportUtteranceCard *> *cards;
/// 空记录卡
@property (nonatomic, strong) UILabel *emptyCard;

#pragma mark - 视图 - 底栏
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *changeButton;
@property (nonatomic, strong) UIButton *againButton;

#pragma mark - 状态
@property (nonatomic, copy) TSAIInterpretationRequest *request;
@property (nonatomic, copy) NSArray<TSAIInterpreterUtteranceUI *> *utterances;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, copy) NSString *endReasonText;
@property (nonatomic, copy) NSDate *endDate;
/// 回放器
@property (nonatomic, strong, nullable) AVAudioPlayer *player;
/// 进入前的侧滑手势代理，离开时还原
@property (nonatomic, weak, nullable) id<UIGestureRecognizerDelegate> previousPopDelegate;

@end

@implementation TSAIInterpreterReportVC

#pragma mark - 生命周期

- (instancetype)initWithRequest:(TSAIInterpretationRequest *)request
                     utterances:(NSArray<TSAIInterpreterUtteranceUI *> *)utterances
                       duration:(NSTimeInterval)duration
                  endReasonText:(NSString *)endReasonText
                        endDate:(NSDate *)endDate {
    self = [super init];
    if (self) {
        _request = [request copy];
        _utterances = [utterances copy];
        _duration = duration;
        _endReasonText = [endReasonText copy];
        _endDate = [endDate copy];
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
    [self.overviewCard addSubview:self.metaSourceLabel];
    [self.overviewCard addSubview:self.metaArrow];
    [self.overviewCard addSubview:self.metaTargetLabel];
    [self.overviewCard addSubview:self.metaRouteLabel];
    for (UILabel *label in self.bigLabels) [self.overviewCard addSubview:label];
    for (UILabel *label in self.smallLabels) [self.overviewCard addSubview:label];
    [self.overviewCard addSubview:self.endLabel];
    [self.scrollView addSubview:self.listLabel];
    [self.scrollView addSubview:self.copyButton];
    for (TSAIInterpreterReportUtteranceCard *card in self.cards) [self.scrollView addSubview:card];
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
    // 导航栏隐藏后侧滑返回需要自己做代理，离开时还原
    if (self.navigationController.interactivePopGestureRecognizer.delegate != self) {
        self.previousPopDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player stop];
    if (self.navigationController.interactivePopGestureRecognizer.delegate == self) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self.previousPopDelegate;
    }
    if (![TSAIInterpreterTheme isInterpreterPage:self.navigationController.topViewController]) {
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

    // 顶栏
    CGFloat topY = self.view.safeAreaInsets.top + 10.0;
    self.backButton.frame = CGRectMake(side, topY, 44.0, 44.0);
    self.shareButton.frame = CGRectMake(width - side - 44.0, topY, 44.0, 44.0);
    self.titleLabel.frame = CGRectMake(side + 54.0, topY, innerW - 108.0, 44.0);
    CGFloat scrollTop = topY + 44.0 + 8.0;

    // 底栏：padding 12 20 34，两个按钮 flex 1 : 1.4，gap 10
    CGFloat bottomPad = MAX(self.view.safeAreaInsets.bottom, 16.0);
    CGFloat footerH = 12.0 + 56.0 + bottomPad;
    self.footerView.frame = CGRectMake(0, height - footerH, width, footerH);
    CGFloat ghostW = floor((innerW - 10.0) / 2.4);
    self.changeButton.frame = CGRectMake(side, 12.0, ghostW, 56.0);
    self.againButton.frame = CGRectMake(side + ghostW + 10.0, 12.0, innerW - ghostW - 10.0, 56.0);

    // 滚动区：padding 8 20 0，gap 16
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
        for (TSAIInterpreterReportUtteranceCard *card in self.cards) {
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
    CGSize s = [self.metaSourceLabel sizeThatFits:CGSizeMake(innerW, rowH)];
    self.metaSourceLabel.frame = CGRectMake(x, y, ceil(s.width), rowH);
    x += ceil(s.width) + 8.0;
    self.metaArrow.frame = CGRectMake(x, y + 2.0, 14.0, 14.0);
    x += 14.0 + 8.0;
    CGSize t = [self.metaTargetLabel sizeThatFits:CGSizeMake(innerW, rowH)];
    CGFloat targetW = MIN(ceil(t.width), 18.0 + innerW - x);
    self.metaTargetLabel.frame = CGRectMake(x, y, targetW, rowH);
    x += targetW + 8.0;
    CGSize r = [self.metaRouteLabel sizeThatFits:CGSizeMake(innerW, rowH)];
    CGFloat routeW = ceil(r.width);
    if (x + routeW <= 18.0 + innerW) {
        self.metaRouteLabel.frame = CGRectMake(18.0 + innerW - routeW, y, routeW, rowH);
        y += rowH;
    } else {
        // 放不下时换到第二行，靠右
        y += rowH + 8.0;
        self.metaRouteLabel.frame = CGRectMake(18.0 + innerW - MIN(routeW, innerW), y, MIN(routeW, innerW), rowH);
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

/// 用会话结果填充所有文案
- (void)fillContent {
    TSAIInterpretationRequest *request = self.request;
    self.metaSourceLabel.text = [TSAIInterpreterFormatter displayNameForLanguage:request.sourceLanguage];
    self.metaTargetLabel.text = [TSAIInterpreterFormatter displayNameForLanguage:request.targetLanguage];
    self.metaRouteLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.report_route_fmt"),
                                [TSAIInterpreterFormatter displayNameForPickup:request.pickup],
                                [TSAIInterpreterFormatter playbackNameForRequest:request]];
    self.bigLabels[0].text = [TSAIInterpreterTheme elapsedString:self.duration];
    self.bigLabels[1].text = [NSString stringWithFormat:@"%lu", (unsigned long)self.utterances.count];
    NSTimeInterval total = 0;
    NSUInteger count = 0;
    for (TSAIInterpreterUtteranceUI *u in self.utterances) {
        if (u.latency >= 0) {
            total += u.latency;
            count++;
        }
    }
    self.bigLabels[2].text = count > 0
        ? [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.report_latency_fmt"), total / count]
        : @"—";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M/d HH:mm";
    self.endLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.report_end_reason_fmt"),
                          self.endReasonText, [formatter stringFromDate:self.endDate ?: [NSDate date]]];
    [self.cards enumerateObjectsUsingBlock:^(TSAIInterpreterReportUtteranceCard *card, NSUInteger idx, BOOL *stop) {
        TSAIInterpreterUtteranceUI *u = self.utterances[idx];
        card.numLabel.text = [NSString stringWithFormat:@"%ld", (long)(u.index + 1)];
        card.timeLabel.text = u.startOffsetText ?: @"00:00";
        card.originalLabel.text = u.originalText ?: @"";
        card.translatedLabel.text = u.translatedText ?: @"";
        card.playButton.tag = idx;
        // 没有合成语音的句子：播放键置灰但仍可点，点击给出原因
        card.playButton.alpha = (self.request.enableVoiceOutput && u.audioData.length > 0) ? 1.0 : 0.4;
    }];
}

/// 逐句记录的纯文本（复制 / 分享用）
- (NSString *)transcriptText {
    NSMutableArray<NSString *> *lines = [NSMutableArray array];
    for (TSAIInterpreterUtteranceUI *u in self.utterances) {
        [lines addObject:[NSString stringWithFormat:@"%ld. %@\n   %@", (long)(u.index + 1),
                          u.originalText ?: @"", u.translatedText ?: @""]];
    }
    return [lines componentsJoinedByString:@"\n"];
}

#pragma mark - 私有方法 - 事件

- (void)onBackTap {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onShareTap {
    NSString *text = self.transcriptText;
    if (text.length == 0) {
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_interpreter.report_empty") inView:self.view];
        return;
    }
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[ text ]
                                                                           applicationActivities:nil];
    activity.popoverPresentationController.sourceView = self.shareButton;
    activity.popoverPresentationController.sourceRect = self.shareButton.bounds;
    [self presentViewController:activity animated:YES completion:nil];
}

- (void)onCopyTap {
    NSString *text = self.transcriptText;
    if (text.length == 0) {
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_interpreter.report_empty") inView:self.view];
        return;
    }
    [UIPasteboard generalPasteboard].string = text;
    [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_interpreter.report_copied") inView:self.view];
}

/// 回放某句的合成语音（PCM 16k / 16bit / mono 包成 WAV）
- (void)onPlayTap:(UIButton *)button {
    if (button.tag >= (NSInteger)self.utterances.count) return;
    TSAIInterpreterUtteranceUI *u = self.utterances[button.tag];
    if (!self.request.enableVoiceOutput) {
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_interpreter.report_no_audio") inView:self.view];
        return;
    }
    if (u.audioData.length == 0) {
        [TSAIInterpreterTheme showToast:u.isAudioUnavailable
                                            ? TSLocalizedString(@"ai_interpreter.tts_no_audio")
                                            : TSLocalizedString(@"ai_interpreter.report_no_audio")
                                 inView:self.view];
        return;
    }
    NSData *playable = nil;
    if (u.audioFormat == TSAIAudioFormatPcm || u.audioFormat == TSAIAudioFormatNone) {
        playable = [self wavDataForPCM:u.audioData sampleRate:16000 channels:1 bitsPerSample:16];
    } else if (u.audioFormat == TSAIAudioFormatWav || u.audioFormat == TSAIAudioFormatMp3) {
        playable = u.audioData;
    }
    if (playable == nil) {
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_interpreter.report_audio_unsupported") inView:self.view];
        return;
    }
    [self.player stop];
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    self.player = [[AVAudioPlayer alloc] initWithData:playable error:&error];
    if (self.player == nil || error != nil) {
        TSLog(@"[TSAIInterpreterReport] replay failed: %@", error);
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

/// 再来一次：用同一请求开启新会话，并在栈中替换本页
- (void)onAgainTap {
    TSAIInterpreterVC *live = [[TSAIInterpreterVC alloc] initWithRequest:self.request];
    NSMutableArray<UIViewController *> *stack = [self.navigationController.viewControllers mutableCopy];
    [stack removeObject:self];
    [stack addObject:live];
    [self.navigationController setViewControllers:stack animated:YES];
}

#pragma mark - 私有方法 - 音频

/// 给裸 PCM 加 44 字节 WAV 头
- (NSData *)wavDataForPCM:(NSData *)pcm sampleRate:(uint32_t)sampleRate channels:(uint16_t)channels bitsPerSample:(uint16_t)bits {
    uint32_t dataLength = (uint32_t)pcm.length;
    uint16_t blockAlign = channels * bits / 8;
    uint32_t byteRate = sampleRate * blockAlign;
    NSMutableData *wav = [NSMutableData dataWithCapacity:44 + dataLength];
    uint32_t chunkSize = 36 + dataLength;
    uint32_t fmtSize = 16;
    uint16_t audioFormat = 1;
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
        _titleLabel.text = TSLocalizedString(@"ai_interpreter.report_ended");
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

- (UILabel *)metaSourceLabel {
    if (!_metaSourceLabel) {
        _metaSourceLabel = [[UILabel alloc] init];
        _metaSourceLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600];
        _metaSourceLabel.textColor = [TSAIInterpreterTheme jade200];
    }
    return _metaSourceLabel;
}

- (UIImageView *)metaArrow {
    if (!_metaArrow) {
        _metaArrow = [TSAIInterpreterTheme symbolViewNamed:@"arrow.right" pointSize:12.0 tint:[TSAIInterpreterTheme textOnDark2]];
    }
    return _metaArrow;
}

- (UILabel *)metaTargetLabel {
    if (!_metaTargetLabel) {
        _metaTargetLabel = [[UILabel alloc] init];
        _metaTargetLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600];
        _metaTargetLabel.textColor = [TSAIInterpreterTheme cobalt200];
        _metaTargetLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _metaTargetLabel;
}

- (UILabel *)metaRouteLabel {
    if (!_metaRouteLabel) {
        _metaRouteLabel = [[UILabel alloc] init];
        _metaRouteLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:400];
        _metaRouteLabel.textColor = [TSAIInterpreterTheme textOnDark2];
        _metaRouteLabel.textAlignment = NSTextAlignmentRight;
    }
    return _metaRouteLabel;
}

- (NSArray<UILabel *> *)bigLabels {
    if (!_bigLabels) {
        NSMutableArray *labels = [NSMutableArray array];
        for (NSInteger i = 0; i < 3; i++) {
            UILabel *label = [[UILabel alloc] init];
            label.font = [TSAIInterpreterTheme tabularFontOfSize:28.0 cssWeight:700];
            label.textColor = [TSAIInterpreterTheme textOnDark];
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.7;
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
                                  TSLocalizedString(@"ai_interpreter.report_count"),
                                  TSLocalizedString(@"ai_interpreter.report_latency") ]) {
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
        _listLabel.text = TSLocalizedString(@"ai_interpreter.report_list");
        _listLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600];
        _listLabel.textColor = [TSAIInterpreterTheme muted];
    }
    return _listLabel;
}

- (UIButton *)copyButton {
    if (!_copyButton) {
        _copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIButtonConfiguration *cfg = [UIButtonConfiguration plainButtonConfiguration];
        cfg.contentInsets = NSDirectionalEdgeInsetsMake(0, 12.0, 0, 12.0);
        UIBackgroundConfiguration *bg = cfg.background;
        bg.backgroundColor = [TSAIInterpreterTheme panel];
        bg.cornerRadius = 16.0;
        cfg.background = bg;
        cfg.baseForegroundColor = [TSAIInterpreterTheme ink];
        cfg.attributedTitle = [[NSAttributedString alloc]
            initWithString:TSLocalizedString(@"ai_interpreter.report_copy_all")
                attributes:@{ NSFontAttributeName: [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600],
                              NSForegroundColorAttributeName: [TSAIInterpreterTheme ink] }];
        _copyButton.configuration = cfg;
        _copyButton.configurationUpdateHandler = ^(UIButton *b) {
            UIButtonConfiguration *updated = b.configuration;
            UIBackgroundConfiguration *updatedBg = updated.background;
            updatedBg.backgroundColor = [TSAIInterpreterTheme panel];
            updated.background = updatedBg;
            updated.baseForegroundColor = [TSAIInterpreterTheme ink];
            b.configuration = updated;
        };
        [_copyButton addTarget:self action:@selector(onCopyTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _copyButton;
}

- (NSArray<TSAIInterpreterReportUtteranceCard *> *)cards {
    if (!_cards) {
        NSMutableArray *cards = [NSMutableArray array];
        for (NSUInteger i = 0; i < self.utterances.count; i++) {
            TSAIInterpreterReportUtteranceCard *card = [[TSAIInterpreterReportUtteranceCard alloc] initWithFrame:CGRectZero];
            [card.playButton addTarget:self action:@selector(onPlayTap:) forControlEvents:UIControlEventTouchUpInside];
            [cards addObject:card];
        }
        _cards = cards;
    }
    return _cards;
}

- (UILabel *)emptyCard {
    if (!_emptyCard) {
        _emptyCard = [[UILabel alloc] init];
        _emptyCard.text = TSLocalizedString(@"ai_interpreter.report_empty");
        _emptyCard.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:400];
        _emptyCard.textColor = [TSAIInterpreterTheme muted];
        _emptyCard.backgroundColor = [TSAIInterpreterTheme panel];
        _emptyCard.layer.cornerRadius = 18.0;
        _emptyCard.clipsToBounds = YES;
        _emptyCard.textAlignment = NSTextAlignmentCenter;
        _emptyCard.hidden = YES;
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
                                                           tint:[UIColor whiteColor]
                                                      cssWeight:700
                                                         target:self
                                                         action:@selector(onAgainTap)];
    }
    return _againButton;
}

@end
