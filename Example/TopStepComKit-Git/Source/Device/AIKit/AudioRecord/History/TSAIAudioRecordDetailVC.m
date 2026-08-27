//
//  TSAIAudioRecordDetailVC.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordDetailVC.h"

#import <AVFoundation/AVFoundation.h>
#import <TopStepAIKit/TSAIDefines.h>

#import "TSAIAudioRecordDetailPlayerView.h"
#import "TSAIAudioRecordPlaybackWaveformView.h"

@interface TSAIAudioRecordProgressSlider : UISlider

@end


@implementation TSAIAudioRecordProgressSlider

/** 缩小进度轨道高度 */
- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(0.0, (CGRectGetHeight(bounds) - 3.0) / 2.0,
                      CGRectGetWidth(bounds), 3.0);
}

@end


@interface TSAIAudioRecordDetailVC () <AVAudioPlayerDelegate>

@property (nonatomic, copy) NSDictionary<NSString *, id> *metadata;
@property (nonatomic, strong) NSURL *audioFileURL;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, strong) TSAIAudioRecordPlaybackWaveformView *waveformView;
@property (nonatomic, strong) TSAIAudioRecordProgressSlider *progressSlider;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIStackView *transcriptStackView;
@property (nonatomic, assign) BOOL playerPreparationFailed;

@end


@implementation TSAIAudioRecordDetailVC

#pragma mark - 生命周期

/** 保存详情页播放输入 */
- (instancetype)initWithMetadata:(NSDictionary<NSString *, id> *)metadata
                    audioFileURL:(NSURL *)audioFileURL {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _metadata = [metadata copy];
        _audioFileURL = audioFileURL;
    }
    return self;
}

/** 初始化详情页数据与播放器 */
- (void)initData {
    [super initData];
    self.title = [self recordingTitle];
    self.view.backgroundColor = [UIColor colorWithRed:245.0 / 255.0
                                                green:246.0 / 255.0
                                                 blue:251.0 / 255.0
                                                alpha:1.0];
    [self prepareAudioPlayer];
}

/** 创建 HTML 详情页对应视图 */
- (void)setupViews {
    [self configureNavigationItems];

    TSAIAudioRecordDetailPlayerView *playerCard = [[TSAIAudioRecordDetailPlayerView alloc] init];
    playerCard.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:playerCard];
    [self configurePlayerCard:playerCard];

    UIStackView *actionStackView = [self actionStackView];
    actionStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:actionStackView];

    UIScrollView *transcriptScrollView = [[UIScrollView alloc] init];
    transcriptScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    transcriptScrollView.alwaysBounceVertical = YES;
    transcriptScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:transcriptScrollView];
    [self configureTranscriptContentInScrollView:transcriptScrollView];

    [NSLayoutConstraint activateConstraints:@[
        [playerCard.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:5.0],
        [playerCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:18.0],
        [playerCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-18.0],
        [playerCard.heightAnchor constraintEqualToConstant:210.0],
        [actionStackView.topAnchor constraintEqualToAnchor:playerCard.bottomAnchor constant:12.0],
        [actionStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:18.0],
        [actionStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-18.0],
        [actionStackView.heightAnchor constraintEqualToConstant:46.0],
        [transcriptScrollView.topAnchor constraintEqualToAnchor:actionStackView.bottomAnchor constant:12.0],
        [transcriptScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [transcriptScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [transcriptScrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

/** Auto Layout 已完成页面布局 */
- (void)layoutViews {
}

/** 页面出现后提示无法解析的音频 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.playerPreparationFailed) {
        self.playerPreparationFailed = NO;
        [self showAlertWithMsg:@"音频文件格式不受支持或文件已损坏"];
    }
}

/** 离开详情页时停止播放刷新 */
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pausePlayback];
}

/** 释放播放器资源 */
- (void)dealloc {
    [self.progressTimer invalidate];
    [[AVAudioSession sharedInstance] setActive:NO
                                  withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                        error:nil];
}

#pragma mark - 私有方法

/** 配置自定义返回与更多操作 */
- (void)configureNavigationItems {
    UIColor *navigationColor = [self primaryTextColor];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 0.0, 36.0, 36.0);
    backButton.titleLabel.font = [UIFont systemFontOfSize:23.0 weight:UIFontWeightRegular];
    [backButton setTitle:@"‹" forState:UIControlStateNormal];
    [backButton setTitleColor:navigationColor forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(0.0, 0.0, 40.0, 36.0);
    moreButton.titleLabel.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightBold];
    [moreButton setTitle:@"···" forState:UIControlStateNormal];
    [moreButton setTitleColor:navigationColor forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(handleMore) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
}

/** 配置渐变播放卡片 */
- (void)configurePlayerCard:(UIView *)playerCard {
    UILabel *kickerLabel = [self labelWithFont:[UIFont systemFontOfSize:9.0 weight:UIFontWeightBold]
                                        color:[UIColor colorWithWhite:1.0 alpha:0.78]];
    kickerLabel.text = [self playerKickerText];
    UILabel *titleLabel = [self labelWithFont:[UIFont systemFontOfSize:17.0 weight:UIFontWeightBold]
                                       color:UIColor.whiteColor];
    titleLabel.text = [self recordingTitle];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    self.waveformView = [[TSAIAudioRecordPlaybackWaveformView alloc] init];
    self.waveformView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressSlider = [[TSAIAudioRecordProgressSlider alloc] init];
    self.progressSlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressSlider.minimumTrackTintColor = UIColor.whiteColor;
    self.progressSlider.maximumTrackTintColor = [UIColor colorWithWhite:1.0 alpha:0.24];
    [self.progressSlider setThumbImage:[self progressThumbImage] forState:UIControlStateNormal];
    [self.progressSlider addTarget:self
                            action:@selector(handleProgressChanged:)
                  forControlEvents:UIControlEventValueChanged];

    self.currentTimeLabel = [self playbackTimeLabel];
    self.currentTimeLabel.text = @"00:00";
    self.totalTimeLabel = [self playbackTimeLabel];
    self.totalTimeLabel.textAlignment = NSTextAlignmentRight;
    self.totalTimeLabel.text = [self formattedTime:self.audioPlayer.duration];

    UIButton *rewindButton = [self transportButtonWithFallbackTitle:@"−3"
                                                         systemName:@"gobackward.3"
                                                           diameter:34.0];
    [rewindButton addTarget:self
                     action:@selector(handleRewind)
           forControlEvents:UIControlEventTouchUpInside];
    self.playButton = [self transportButtonWithFallbackTitle:@"▶"
                                                  systemName:@"play.fill"
                                                    diameter:42.0];
    self.playButton.backgroundColor = UIColor.whiteColor;
    [self.playButton setTitleColor:[self primaryTextColor] forState:UIControlStateNormal];
    self.playButton.tintColor = [self primaryTextColor];
    [self.playButton addTarget:self
                        action:@selector(handlePlayPause)
              forControlEvents:UIControlEventTouchUpInside];
    UIButton *forwardButton = [self transportButtonWithFallbackTitle:@"+3"
                                                          systemName:@"goforward.3"
                                                            diameter:34.0];
    [forwardButton addTarget:self
                      action:@selector(handleForward)
            forControlEvents:UIControlEventTouchUpInside];
    UIStackView *transportStackView = [[UIStackView alloc]
        initWithArrangedSubviews:@[rewindButton, self.playButton, forwardButton]];
    transportStackView.translatesAutoresizingMaskIntoConstraints = NO;
    transportStackView.axis = UILayoutConstraintAxisHorizontal;
    transportStackView.alignment = UIStackViewAlignmentCenter;
    transportStackView.spacing = 27.0;

    for (UIView *view in @[kickerLabel, titleLabel, self.waveformView,
                          self.progressSlider, self.currentTimeLabel,
                          self.totalTimeLabel, transportStackView]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [playerCard addSubview:view];
    }
    [NSLayoutConstraint activateConstraints:@[
        [kickerLabel.topAnchor constraintEqualToAnchor:playerCard.topAnchor constant:16.0],
        [kickerLabel.leadingAnchor constraintEqualToAnchor:playerCard.leadingAnchor constant:17.0],
        [kickerLabel.trailingAnchor constraintEqualToAnchor:playerCard.trailingAnchor constant:-17.0],
        [titleLabel.topAnchor constraintEqualToAnchor:kickerLabel.bottomAnchor constant:6.0],
        [titleLabel.leadingAnchor constraintEqualToAnchor:kickerLabel.leadingAnchor],
        [titleLabel.trailingAnchor constraintEqualToAnchor:kickerLabel.trailingAnchor],
        [self.waveformView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:13.0],
        [self.waveformView.leadingAnchor constraintEqualToAnchor:kickerLabel.leadingAnchor],
        [self.waveformView.trailingAnchor constraintEqualToAnchor:kickerLabel.trailingAnchor],
        [self.waveformView.heightAnchor constraintEqualToConstant:46.0],
        [self.progressSlider.topAnchor constraintEqualToAnchor:self.waveformView.bottomAnchor],
        [self.progressSlider.leadingAnchor constraintEqualToAnchor:kickerLabel.leadingAnchor],
        [self.progressSlider.trailingAnchor constraintEqualToAnchor:kickerLabel.trailingAnchor],
        [self.progressSlider.heightAnchor constraintEqualToConstant:18.0],
        [self.currentTimeLabel.topAnchor constraintEqualToAnchor:self.progressSlider.bottomAnchor constant:-1.0],
        [self.currentTimeLabel.leadingAnchor constraintEqualToAnchor:kickerLabel.leadingAnchor],
        [self.totalTimeLabel.topAnchor constraintEqualToAnchor:self.currentTimeLabel.topAnchor],
        [self.totalTimeLabel.trailingAnchor constraintEqualToAnchor:kickerLabel.trailingAnchor],
        [transportStackView.topAnchor constraintEqualToAnchor:self.currentTimeLabel.bottomAnchor constant:9.0],
        [transportStackView.centerXAnchor constraintEqualToAnchor:playerCard.centerXAnchor],
        [transportStackView.heightAnchor constraintEqualToConstant:42.0],
    ]];
}

/** 创建播放器操作按钮区 */
- (UIStackView *)actionStackView {
    UIButton *summaryButton = [self actionButtonWithTitle:@"AI 总结"
                                              systemName:@"sparkles"];
    [summaryButton addTarget:self
                      action:@selector(handleSummary)
            forControlEvents:UIControlEventTouchUpInside];
    UIButton *translationButton = [self actionButtonWithTitle:@"翻译"
                                                  systemName:@"character.book.closed"];
    [translationButton addTarget:self
                          action:@selector(handleTranslation)
                forControlEvents:UIControlEventTouchUpInside];
    UIStackView *stackView = [[UIStackView alloc]
        initWithArrangedSubviews:@[summaryButton, translationButton]];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.spacing = 10.0;
    return stackView;
}

/** 创建可滚动的转写内容 */
- (void)configureTranscriptContentInScrollView:(UIScrollView *)scrollView {
    self.transcriptStackView = [[UIStackView alloc] init];
    self.transcriptStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.transcriptStackView.axis = UILayoutConstraintAxisVertical;
    self.transcriptStackView.spacing = 0.0;
    [scrollView addSubview:self.transcriptStackView];
    [NSLayoutConstraint activateConstraints:@[
        [self.transcriptStackView.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor
                                                           constant:4.0],
        [self.transcriptStackView.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor
                                                               constant:18.0],
        [self.transcriptStackView.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor
                                                                constant:-18.0],
        [self.transcriptStackView.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor
                                                              constant:-24.0],
        [self.transcriptStackView.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor
                                                             constant:-36.0],
    ]];

    NSArray<NSDictionary<NSString *, id> *> *transcriptItems = [self transcriptItems];
    UIStackView *headerStackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self transcriptHeaderLabel],
        [self transcriptMetadataLabelWithCount:transcriptItems.count],
    ]];
    headerStackView.axis = UILayoutConstraintAxisHorizontal;
    headerStackView.alignment = UIStackViewAlignmentCenter;
    headerStackView.distribution = UIStackViewDistributionEqualSpacing;
    headerStackView.layoutMargins = UIEdgeInsetsMake(8.0, 1.0, 12.0, 1.0);
    headerStackView.layoutMarginsRelativeArrangement = YES;
    [self.transcriptStackView addArrangedSubview:headerStackView];

    if (transcriptItems.count == 0) {
        UILabel *emptyLabel = [self labelWithFont:[UIFont systemFontOfSize:13.0]
                                            color:[self secondaryTextColor]];
        emptyLabel.text = @"本次录音没有可显示的转写内容";
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        emptyLabel.numberOfLines = 0;
        emptyLabel.layoutMargins = UIEdgeInsetsMake(24.0, 8.0, 24.0, 8.0);
        [emptyLabel.heightAnchor constraintGreaterThanOrEqualToConstant:76.0].active = YES;
        [self.transcriptStackView addArrangedSubview:emptyLabel];
        return;
    }

    for (NSDictionary<NSString *, id> *transcriptItem in transcriptItems) {
        [self.transcriptStackView addArrangedSubview:[self transcriptLineForItem:transcriptItem]];
    }
}

/** 创建转写标题 */
- (UILabel *)transcriptHeaderLabel {
    UILabel *label = [self labelWithFont:[UIFont systemFontOfSize:14.0 weight:UIFontWeightBold]
                                   color:[self primaryTextColor]];
    label.text = @"Transcript";
    return label;
}

/** 创建转写语言与段数信息 */
- (UILabel *)transcriptMetadataLabelWithCount:(NSUInteger)count {
    UILabel *label = [self labelWithFont:[UIFont systemFontOfSize:10.0]
                                   color:[self secondaryTextColor]];
    label.text = [NSString stringWithFormat:@"%@ · %lu 段",
                  [self transcriptLanguageName],
                  (unsigned long)count];
    label.textAlignment = NSTextAlignmentRight;
    return label;
}

/** 创建单段转写视图 */
- (UIView *)transcriptLineForItem:(NSDictionary<NSString *, id> *)transcriptItem {
    UILabel *timeLabel = [self labelWithFont:[UIFont monospacedSystemFontOfSize:9.0
                                                                            weight:UIFontWeightRegular]
                                       color:[self accentColor]];
    NSTimeInterval startTime = [transcriptItem[@"startTimeMilliseconds"] doubleValue] / 1000.0;
    timeLabel.text = [self formattedTime:startTime];

    UILabel *textLabel = [self labelWithFont:[UIFont systemFontOfSize:13.0]
                                       color:[UIColor colorWithRed:37.0 / 255.0
                                                            green:42.0 / 255.0
                                                             blue:66.0 / 255.0
                                                            alpha:1.0]];
    textLabel.numberOfLines = 0;
    textLabel.text = [transcriptItem[@"text"] description];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4.0;
    textLabel.attributedText = [[NSAttributedString alloc]
        initWithString:textLabel.text ?: @""
        attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];

    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor colorWithRed:16.0 / 255.0
                                                     green:20.0 / 255.0
                                                      blue:45.0 / 255.0
                                                     alpha:0.07];
    [separatorView.heightAnchor constraintEqualToConstant:1.0].active = YES;
    UIStackView *lineStackView = [[UIStackView alloc]
        initWithArrangedSubviews:@[timeLabel, textLabel, separatorView]];
    lineStackView.axis = UILayoutConstraintAxisVertical;
    lineStackView.spacing = 6.0;
    lineStackView.layoutMargins = UIEdgeInsetsMake(0.0, 1.0, 14.0, 1.0);
    lineStackView.layoutMarginsRelativeArrangement = YES;
    return lineStackView;
}

/** 准备系统音频播放器 */
- (void)prepareAudioPlayer {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback
                         mode:AVAudioSessionModeDefault
                      options:0
                        error:nil];
    [audioSession setActive:YES error:nil];

    NSError *playerError = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioFileURL
                                                              error:&playerError];
    if (!self.audioPlayer || playerError) {
        self.playerPreparationFailed = YES;
        return;
    }
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
}

/** 开始播放并刷新详情页进度 */
- (void)startPlayback {
    if (!self.audioPlayer) {
        [self showAlertWithMsg:@"当前音频无法播放"];
        return;
    }
    if (self.audioPlayer.currentTime >= self.audioPlayer.duration) {
        self.audioPlayer.currentTime = 0.0;
    }
    if (![self.audioPlayer play]) {
        [self showAlertWithMsg:@"播放器启动失败"];
        return;
    }
    [self updatePlayButtonForPlaying:YES];
    [self startProgressTimer];
}

/** 暂停播放并停止定时刷新 */
- (void)pausePlayback {
    [self.audioPlayer pause];
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    [self updatePlayButtonForPlaying:NO];
    [self updatePlaybackProgress];
}

/** 创建播放进度刷新定时器 */
- (void)startProgressTimer {
    [self.progressTimer invalidate];
    __weak typeof(self) weakSelf = self;
    self.progressTimer = [NSTimer timerWithTimeInterval:0.1
                                                repeats:YES
                                                  block:^(NSTimer *timer) {
        [weakSelf updatePlaybackProgress];
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

/** 同步播放器时间、波形和进度条 */
- (void)updatePlaybackProgress {
    NSTimeInterval duration = self.audioPlayer.duration;
    NSTimeInterval currentTime = self.audioPlayer.currentTime;
    CGFloat progress = duration > 0.0 ? currentTime / duration : 0.0;
    self.progressSlider.value = progress;
    self.currentTimeLabel.text = [self formattedTime:currentTime];
    self.totalTimeLabel.text = [self formattedTime:duration];
}

/** 跳转指定秒数并限制在有效时长内 */
- (void)skipPlaybackByInterval:(NSTimeInterval)interval {
    if (!self.audioPlayer) {
        return;
    }
    NSTimeInterval targetTime = self.audioPlayer.currentTime + interval;
    self.audioPlayer.currentTime = MIN(self.audioPlayer.duration, MAX(0.0, targetTime));
    [self updatePlaybackProgress];
}

/** 更新播放按钮图标 */
- (void)updatePlayButtonForPlaying:(BOOL)isPlaying {
    NSString *fallbackTitle = isPlaying ? @"Ⅱ" : @"▶";
    if (@available(iOS 13.0, *)) {
        NSString *symbolName = isPlaying ? @"pause.fill" : @"play.fill";
        UIImageSymbolConfiguration *configuration =
            [UIImageSymbolConfiguration configurationWithPointSize:14.0
                                                             weight:UIImageSymbolWeightBold];
        [self.playButton setImage:[UIImage systemImageNamed:symbolName
                                          withConfiguration:configuration]
                         forState:UIControlStateNormal];
        [self.playButton setTitle:nil forState:UIControlStateNormal];
    } else {
        [self.playButton setImage:nil forState:UIControlStateNormal];
        [self.playButton setTitle:fallbackTitle forState:UIControlStateNormal];
    }
}

/** 返回历史录音页面 */
- (void)handleBack {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 切换播放与暂停 */
- (void)handlePlayPause {
    if (self.audioPlayer.isPlaying) {
        [self pausePlayback];
    } else {
        [self startPlayback];
    }
}

/** 后退三秒 */
- (void)handleRewind {
    [self skipPlaybackByInterval:-3.0];
}

/** 前进三秒 */
- (void)handleForward {
    [self skipPlaybackByInterval:3.0];
}

/** 拖动播放进度 */
- (void)handleProgressChanged:(UISlider *)slider {
    if (!self.audioPlayer) {
        return;
    }
    self.audioPlayer.currentTime = slider.value * self.audioPlayer.duration;
    [self updatePlaybackProgress];
}

/** 当前录音没有保存 AI 总结结果时给出明确说明 */
- (void)handleSummary {
    [self showAlertWithMsg:@"当前录音暂无可用的 AI 总结"];
}

/** 当前录音没有保存翻译结果时给出明确说明 */
- (void)handleTranslation {
    [self showAlertWithMsg:@"当前录音暂无可用的翻译内容"];
}

/** 展示与 HTML 一致的更多操作入口 */
- (void)handleMore {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [menu addAction:[UIAlertAction actionWithTitle:@"重命名"
                                             style:UIAlertActionStyleDefault
                                           handler:^(__unused UIAlertAction *action) {
        [self showAlertWithMsg:@"重命名功能尚未接入本地存储"];
    }]];
    [menu addAction:[UIAlertAction actionWithTitle:@"复制全文"
                                             style:UIAlertActionStyleDefault
                                           handler:^(__unused UIAlertAction *action) {
        [self copyFullTranscript];
    }]];
    [menu addAction:[UIAlertAction actionWithTitle:@"分享录音"
                                             style:UIAlertActionStyleDefault
                                           handler:^(__unused UIAlertAction *action) {
        [self shareRecording];
    }]];
    [menu addAction:[UIAlertAction actionWithTitle:@"删除录音"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(__unused UIAlertAction *action) {
        [self showAlertWithMsg:@"删除功能尚未接入本地存储"];
    }]];
    [menu addAction:[UIAlertAction actionWithTitle:@"取消"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    menu.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:menu animated:YES completion:nil];
}

/** 复制所有转写文本 */
- (void)copyFullTranscript {
    NSString *transcriptText = [self fullTranscriptText];
    if (transcriptText.length == 0) {
        [self showAlertWithMsg:@"当前录音没有可复制的转写内容"];
        return;
    }
    UIPasteboard.generalPasteboard.string = transcriptText;
    [self showAlertWithMsg:@"转写全文已复制"];
}

/** 调起系统分享面板 */
- (void)shareRecording {
    NSMutableArray *activityItems = [NSMutableArray arrayWithObject:self.audioFileURL];
    NSString *transcriptText = [self fullTranscriptText];
    if (transcriptText.length > 0) {
        [activityItems addObject:transcriptText];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
        initWithActivityItems:activityItems
        applicationActivities:nil];
    activityViewController.popoverPresentationController.barButtonItem =
        self.navigationItem.rightBarButtonItem;
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - AVAudioPlayerDelegate

/** 播放自然结束后复位按钮与进度 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    player.currentTime = 0.0;
    [self updatePlayButtonForPlaying:NO];
    [self updatePlaybackProgress];
}

/** 音频解码失败时停止播放并提示 */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self pausePlayback];
    [self showAlertWithMsg:error.localizedDescription ?: @"音频解码失败"];
}

#pragma mark - 辅助方法

/** 返回保存的转写条目 */
- (NSArray<NSDictionary<NSString *, id> *> *)transcriptItems {
    id transcriptValue = self.metadata[@"transcripts"];
    if (![transcriptValue isKindOfClass:NSArray.class]) {
        return @[];
    }
    NSMutableArray<NSDictionary<NSString *, id> *> *items = [NSMutableArray array];
    for (id value in (NSArray *)transcriptValue) {
        if ([value isKindOfClass:NSDictionary.class]) {
            [items addObject:value];
        }
    }
    return [items copy];
}

/** 合并可复制的转写全文 */
- (NSString *)fullTranscriptText {
    NSMutableArray<NSString *> *paragraphs = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *item in [self transcriptItems]) {
        NSString *text = [item[@"text"] description];
        if (text.length > 0) {
            [paragraphs addObject:text];
        }
    }
    return [paragraphs componentsJoinedByString:@"\n"];
}

/** 返回录音标题 */
- (NSString *)recordingTitle {
    NSString *title = [self.metadata[@"title"] description];
    return title.length > 0 ? title : @"现场录音";
}

/** 返回日期与录音场景文案 */
- (NSString *)playerKickerText {
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:
                         [self.metadata[@"startTimestamp"] doubleValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy/MM/dd";
    NSString *sceneText = [self.metadata[@"isOfflineRecording"] boolValue]
        ? @"OFFLINE RECORDING"
        : @"ON-SITE RECORDING";
    return [NSString stringWithFormat:@"%@ · %@", [formatter stringFromDate:startDate], sceneText];
}

/** 返回转写语言名称 */
- (NSString *)transcriptLanguageName {
    NSInteger language = [self.metadata[@"language"] integerValue];
    switch ((TSAILanguage)language) {
        case TSAILanguageChineseSimplified:
            return @"中文（普通话）";
        case TSAILanguageChineseTraditional:
            return @"中文（繁體）";
        case TSAILanguageEnglishUS:
            return @"English (US)";
        case TSAILanguageEnglishUK:
            return @"English (UK)";
        case TSAILanguageJapanese:
            return @"日本語";
        case TSAILanguageKorean:
            return @"한국어";
        case TSAILanguageFrench:
            return @"Français";
        case TSAILanguageGerman:
            return @"Deutsch";
        case TSAILanguageSpanish:
            return @"Español";
        default:
            return @"声源语言";
    }
}

/** 创建基础文本标签 */
- (UILabel *)labelWithFont:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    return label;
}

/** 创建播放时间标签 */
- (UILabel *)playbackTimeLabel {
    return [self labelWithFont:[UIFont monospacedSystemFontOfSize:9.0
                                                           weight:UIFontWeightRegular]
                         color:[UIColor colorWithWhite:1.0 alpha:0.70]];
}

/** 创建播放控制按钮 */
- (UIButton *)transportButtonWithFallbackTitle:(NSString *)fallbackTitle
                                    systemName:(NSString *)systemName
                                      diameter:(CGFloat)diameter {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightBold];
    [button setTitle:fallbackTitle forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.tintColor = UIColor.whiteColor;
    button.layer.cornerRadius = diameter / 2.0;
    [button.widthAnchor constraintEqualToConstant:diameter].active = YES;
    [button.heightAnchor constraintEqualToConstant:diameter].active = YES;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *configuration =
            [UIImageSymbolConfiguration configurationWithPointSize:13.0
                                                             weight:UIImageSymbolWeightBold];
        [button setImage:[UIImage systemImageNamed:systemName withConfiguration:configuration]
                forState:UIControlStateNormal];
        [button setTitle:nil forState:UIControlStateNormal];
    }
    return button;
}

/** 创建 AI 操作按钮 */
- (UIButton *)actionButtonWithTitle:(NSString *)title systemName:(NSString *)systemName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [[self accentColor] colorWithAlphaComponent:0.09];
    button.layer.cornerRadius = 15.0;
    button.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightBold];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[self accentColor] forState:UIControlStateNormal];
    button.tintColor = [self accentColor];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *configuration =
            [UIImageSymbolConfiguration configurationWithPointSize:15.0
                                                             weight:UIImageSymbolWeightSemibold];
        [button setImage:[UIImage systemImageNamed:systemName withConfiguration:configuration]
                forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0.0, 4.0);
    }
    return button;
}

/** 创建与 HTML 进度条一致的透明拖动点 */
- (UIImage *)progressThumbImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0, 1.0), NO, 0.0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/** 格式化播放器时间 */
- (NSString *)formattedTime:(NSTimeInterval)timeInterval {
    NSInteger totalSeconds = MAX(0, (NSInteger)floor(timeInterval));
    return [NSString stringWithFormat:@"%02ld:%02ld",
            (long)(totalSeconds / 60),
            (long)(totalSeconds % 60)];
}

/** 返回页面主文字颜色 */
- (UIColor *)primaryTextColor {
    return [UIColor colorWithRed:16.0 / 255.0
                           green:20.0 / 255.0
                            blue:45.0 / 255.0
                           alpha:1.0];
}

/** 返回页面次要文字颜色 */
- (UIColor *)secondaryTextColor {
    return [UIColor colorWithRed:156.0 / 255.0
                           green:162.0 / 255.0
                            blue:184.0 / 255.0
                           alpha:1.0];
}

/** 返回 HTML 设计使用的主题蓝色 */
- (UIColor *)accentColor {
    return [UIColor colorWithRed:79.0 / 255.0
                           green:123.0 / 255.0
                            blue:255.0 / 255.0
                           alpha:1.0];
}

@end
