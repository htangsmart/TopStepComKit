//
//  TSAIAudioRecordVC+Views.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordVC+Views.h"

#import <QuartzCore/QuartzCore.h>

#import "TSAIAudioRecordVC+Private.h"
#import "TSAIAudioRecordGradientView.h"
#import "TSAIAudioRecordTranscriptView.h"
#import "TSAIAudioRecordWaveformView.h"

static UIColor *TSAIAudioRecordColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    return [UIColor colorWithRed:red / 255.0
                           green:green / 255.0
                            blue:blue / 255.0
                           alpha:alpha];
}

@implementation TSAIAudioRecordVC (Views)
#pragma mark - 公开方法

/** 构建完整页面层级和约束 */
- (void)buildPageViews {
    [self prepareViewProperties];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentStackView];
    [self.view addSubview:self.bottomBar];
    [self.view addSubview:self.finalizingOverlay];
    [self.view addSubview:self.recordingHelpOverlay];
    [self.view addSubview:self.audioRouteOverlay];
    [self.contentStackView addArrangedSubview:self.sessionCard];
    [self.contentStackView addArrangedSubview:self.transcriptCard];
    [self.contentStackView addArrangedSubview:self.resultCard];
    [self.contentStackView setCustomSpacing:4.0 afterView:self.sessionCard];
    [self installSessionCardContent];
    [self installTranscriptCardContent];
    [self installResultCardContent];
    [self installBottomBarContent];
    [self installFinalizingOverlayContent];
    [self installRecordingHelpContent];
    [self installAudioRouteSheetContent];
    [self activatePageConstraints];
}

#pragma mark - 私有方法

/** 创建并设置全部页面控件 */
- (void)prepareViewProperties {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    self.contentStackView = [[UIStackView alloc] init];
    self.contentStackView.axis = UILayoutConstraintAxisVertical;
    self.contentStackView.spacing = 0.0;
    self.contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.sessionCard = [[UIView alloc] init];
    self.sessionCard.translatesAutoresizingMaskIntoConstraints = NO;
    self.sessionCard.backgroundColor = UIColor.clearColor;
    self.transcriptCard = [self cardView];
    self.resultCard = [self cardView];
    self.transcriptCard.backgroundColor = TSAIAudioRecordColor(243.0, 244.0, 248.0, 1.0);
    self.transcriptCard.layer.cornerRadius = 19.0;
    self.resultCard.backgroundColor = UIColor.clearColor;
    self.resultCard.layer.shadowOpacity = 0.0;
    self.transcriptCard.hidden = YES;
    self.resultCard.hidden = YES;

    self.deviceBadgeLabel = [self labelWithFont:[UIFont systemFontOfSize:11.0 weight:UIFontWeightSemibold]
                                         color:TSAIAudioRecordColor(37.0, 139.0, 115.0, 1.0)];
    self.deviceBadgeLabel.textAlignment = NSTextAlignmentCenter;
    self.deviceBadgeLabel.backgroundColor = TSAIAudioRecordColor(31.0, 200.0, 160.0, 0.08);
    self.deviceBadgeLabel.layer.cornerRadius = 13.0;
    self.deviceBadgeLabel.layer.borderWidth = 1.0;
    self.deviceBadgeLabel.layer.borderColor = TSAIAudioRecordColor(31.0, 200.0, 160.0, 0.16).CGColor;
    self.deviceBadgeLabel.layer.masksToBounds = YES;
    self.statusLabel = [self labelWithFont:[UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold]
                                    color:TSAIAudioRecordColor(104.0, 112.0, 143.0, 1.0)];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.recordingPulseView = [[UIView alloc] init];
    self.recordingPulseView.translatesAutoresizingMaskIntoConstraints = NO;
    self.recordingPulseView.backgroundColor = TSAIAudioRecordColor(255.0, 77.0, 94.0, 1.0);
    self.recordingPulseView.layer.cornerRadius = 4.0;
    self.recordingPulseView.hidden = YES;
    self.timerLabel = [self labelWithFont:[UIFont monospacedDigitSystemFontOfSize:48.0
                                                                            weight:UIFontWeightRegular]
                                   color:TSAIAudioRecordColor(16.0, 20.0, 45.0, 1.0)];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    self.waveformView = [[TSAIAudioRecordWaveformView alloc] init];
    self.waveformView.translatesAutoresizingMaskIntoConstraints = NO;
    self.recordHintLabel = [self labelWithFont:[UIFont systemFontOfSize:13.0 weight:UIFontWeightRegular]
                                         color:TSAIAudioRecordColor(104.0, 112.0, 143.0, 1.0)];
    self.recordHintLabel.text = @"由设备端收音并实时回传 App\n开始前可选择声源语言";
    self.recordHintLabel.textAlignment = NSTextAlignmentCenter;
    self.recordHintLabel.numberOfLines = 2;

    self.transcriptView = [[TSAIAudioRecordTranscriptView alloc]
        initWithStyle:TSAIAudioRecordTranscriptViewStyleLive];
    self.durationMetricLabel = [self completionMetricLabel];
    self.transcriptMetricLabel = [self completionMetricLabel];
    self.speakerMetricLabel = [self completionMetricLabel];
    self.resultSegmentControl = [[UISegmentedControl alloc] initWithItems:@[
        @"Transcript",
        @"Session events"
    ]];
    self.resultSegmentControl.selectedSegmentIndex = 0;
    self.resultSegmentControl.backgroundColor = UIColor.clearColor;
    self.resultSegmentControl.tintColor = UIColor.clearColor;
    UIImage *clearImage = [self imageWithColor:UIColor.clearColor];
    [self.resultSegmentControl setBackgroundImage:clearImage
                                         forState:UIControlStateNormal
                                       barMetrics:UIBarMetricsDefault];
    [self.resultSegmentControl setBackgroundImage:clearImage
                                         forState:UIControlStateSelected
                                       barMetrics:UIBarMetricsDefault];
    [self.resultSegmentControl setDividerImage:clearImage
                           forLeftSegmentState:UIControlStateNormal
                             rightSegmentState:UIControlStateNormal
                                    barMetrics:UIBarMetricsDefault];
    if (@available(iOS 13.0, *)) {
        self.resultSegmentControl.selectedSegmentTintColor = UIColor.clearColor;
    }
    [self.resultSegmentControl setTitleTextAttributes:@{
        NSForegroundColorAttributeName: TSAIAudioRecordColor(156.0, 162.0, 184.0, 1.0),
        NSFontAttributeName: [UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold]
    } forState:UIControlStateNormal];
    [self.resultSegmentControl setTitleTextAttributes:@{
        NSForegroundColorAttributeName: TSAIAudioRecordColor(16.0, 20.0, 45.0, 1.0),
        NSFontAttributeName: [UIFont systemFontOfSize:12.0 weight:UIFontWeightBold]
    } forState:UIControlStateSelected];
    [self.resultSegmentControl addTarget:self
                                  action:@selector(handleResultSegmentChanged)
                        forControlEvents:UIControlEventValueChanged];
    self.resultTranscriptView = [[TSAIAudioRecordTranscriptView alloc]
        initWithStyle:TSAIAudioRecordTranscriptViewStyleResult];
    self.resultTextView = [self resultTextViewWithEmptyText:@""];
    self.resultTextView.backgroundColor = UIColor.whiteColor;
    self.resultTextView.layer.cornerRadius = 0.0;
    self.resultTextView.hidden = YES;
    self.resultSelectionIndicator = [[UIView alloc] init];
    self.resultSelectionIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.resultSelectionIndicator.backgroundColor = TSAIAudioRecordColor(79.0, 123.0, 255.0, 1.0);
    self.resultSelectionIndicator.layer.cornerRadius = 1.0;

    self.bottomBar = [[UIView alloc] init];
    self.bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomBar.backgroundColor = TSAIAudioRecordColor(245.0, 246.0, 251.0, 1.0);
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recordButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.recordButton.layer.cornerRadius = 36.0;
    self.recordButton.backgroundColor = TSAIAudioRecordColor(255.0, 225.0, 229.0, 1.0);
    self.recordButton.titleLabel.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightBold];
    self.recordButton.layer.shadowColor = TSAIAudioRecordColor(255.0, 77.0, 94.0, 1.0).CGColor;
    self.recordButton.layer.shadowOpacity = 0.25;
    self.recordButton.layer.shadowRadius = 11.0;
    self.recordButton.layer.shadowOffset = CGSizeMake(0.0, 8.0);
    [self.recordButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(handleRecordButton)
                forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(handleRecordButtonTouchDown)
                forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(handleRecordButtonTouchUp)
                forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside |
                                 UIControlEventTouchCancel];
    self.recordButtonFillView = [[UIView alloc] init];
    self.recordButtonFillView.translatesAutoresizingMaskIntoConstraints = NO;
    self.recordButtonFillView.backgroundColor = TSAIAudioRecordColor(255.0, 77.0, 94.0, 1.0);
    self.recordButtonFillView.layer.cornerRadius = 29.0;
    self.recordButtonFillView.userInteractionEnabled = NO;
    self.recordStopView = [[UIView alloc] init];
    self.recordStopView.translatesAutoresizingMaskIntoConstraints = NO;
    self.recordStopView.backgroundColor = UIColor.whiteColor;
    self.recordStopView.layer.cornerRadius = 5.0;
    self.recordStopView.userInteractionEnabled = NO;
    self.recordStopView.hidden = YES;
    self.actionHintLabel = [self labelWithFont:[UIFont systemFontOfSize:10.0 weight:UIFontWeightSemibold]
                                        color:TSAIAudioRecordColor(104.0, 112.0, 143.0, 1.0)];
    self.actionHintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.actionHintLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLanguageButton = [self valueButton];
    self.bottomLanguageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.bottomLanguageButton.backgroundColor = TSAIAudioRecordColor(240.0, 241.0, 245.0, 1.0);
    self.bottomLanguageButton.layer.cornerRadius = 12.0;
    self.bottomLanguageButton.titleLabel.font = [UIFont systemFontOfSize:11.0 weight:UIFontWeightSemibold];
    self.bottomLanguageButton.contentEdgeInsets = UIEdgeInsetsMake(7.0, 10.0, 7.0, 10.0);
    [self.bottomLanguageButton addTarget:self action:@selector(handleLanguageSelection)
                        forControlEvents:UIControlEventTouchUpInside];
    self.pickupRouteButton = [self recordRouteButtonWithSystemName:@"mic"];
    [self.pickupRouteButton addTarget:self action:@selector(handlePickupRouteSelection)
                       forControlEvents:UIControlEventTouchUpInside];
    self.contentPlaybackRouteButton = [self recordRouteButtonWithSystemName:@"speaker.wave.2"];
    [self.contentPlaybackRouteButton addTarget:self
                                        action:@selector(handleContentPlaybackRouteSelection)
                              forControlEvents:UIControlEventTouchUpInside];
    self.sideMetaLabel = [self labelWithFont:[UIFont monospacedSystemFontOfSize:9.0
                                                                          weight:UIFontWeightRegular]
                                       color:TSAIAudioRecordColor(156.0, 162.0, 184.0, 1.0)];
    self.sideMetaLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.sideMetaLabel.numberOfLines = 3;
    self.sideMetaLabel.textAlignment = NSTextAlignmentRight;

    self.finalizingOverlay = [[UIView alloc] init];
    self.finalizingOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    self.finalizingOverlay.backgroundColor = TSAIAudioRecordColor(16.0, 20.0, 45.0, 0.16);
    self.finalizingOverlay.hidden = YES;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    if (@available(iOS 13.0, *)) {
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
    }
    self.activityIndicator.color = UIColor.whiteColor;
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.finalizingLabel = [self labelWithFont:[UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium]
                                        color:UIColor.whiteColor];
    self.finalizingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.finalizingLabel.text = @"Finalizing session…";
    self.finalizingLabel.textAlignment = NSTextAlignmentCenter;
    self.finalizingLabel.numberOfLines = 0;

    self.recordingHelpOverlay = [[UIView alloc] init];
    self.recordingHelpOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    self.recordingHelpOverlay.backgroundColor = TSAIAudioRecordColor(16.0, 20.0, 45.0, 0.38);
    self.recordingHelpOverlay.hidden = YES;
    self.recordingHelpSheet = [[UIView alloc] init];
    self.recordingHelpSheet.translatesAutoresizingMaskIntoConstraints = NO;
    self.recordingHelpSheet.backgroundColor = UIColor.whiteColor;
    self.recordingHelpSheet.layer.cornerRadius = 24.0;
    self.recordingHelpSheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;

    self.audioRouteOverlay = [[UIView alloc] init];
    self.audioRouteOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    self.audioRouteOverlay.backgroundColor = TSAIAudioRecordColor(16.0, 20.0, 45.0, 0.38);
    self.audioRouteOverlay.hidden = YES;
    self.audioRouteSheet = [[UIView alloc] init];
    self.audioRouteSheet.translatesAutoresizingMaskIntoConstraints = NO;
    self.audioRouteSheet.backgroundColor = UIColor.whiteColor;
    self.audioRouteSheet.layer.cornerRadius = 24.0;
    self.audioRouteSheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.audioRouteSheetTitleLabel = [self labelWithFont:[UIFont systemFontOfSize:18.0
                                                                              weight:UIFontWeightBold]
                                                   color:TSAIAudioRecordColor(16.0, 20.0, 45.0, 1.0)];
    self.audioRouteSheetSubtitleLabel = [self labelWithFont:[UIFont systemFontOfSize:10.0
                                                                                 weight:UIFontWeightRegular]
                                                      color:TSAIAudioRecordColor(104.0, 112.0, 143.0, 1.0)];
    self.audioRouteOptionStackView = [self verticalStackWithSpacing:8.0];
    self.audioRouteOptionStackView.distribution = UIStackViewDistributionFillEqually;
    for (NSInteger optionIndex = 0; optionIndex < 3; optionIndex++) {
        UIButton *optionButton = [self audioRouteOptionButtonWithTag:optionIndex];
        [optionButton addTarget:self action:@selector(handleAudioRouteOption:)
               forControlEvents:UIControlEventTouchUpInside];
        [self.audioRouteOptionStackView addArrangedSubview:optionButton];
    }
}

/** 安装会话状态卡内容 */
- (void)installSessionCardContent {
    UIStackView *stackView = [self verticalStackWithSpacing:0.0];
    stackView.alignment = UIStackViewAlignmentCenter;
    UIStackView *statusStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.recordingPulseView,
        self.statusLabel
    ]];
    statusStack.axis = UILayoutConstraintAxisHorizontal;
    statusStack.alignment = UIStackViewAlignmentCenter;
    statusStack.spacing = 7.0;
    [stackView addArrangedSubview:self.deviceBadgeLabel];
    [stackView addArrangedSubview:statusStack];
    [stackView addArrangedSubview:self.timerLabel];
    [stackView addArrangedSubview:self.waveformView];
    [stackView addArrangedSubview:self.recordHintLabel];
    [stackView setCustomSpacing:12.0 afterView:self.deviceBadgeLabel];
    [stackView setCustomSpacing:1.0 afterView:statusStack];
    [stackView setCustomSpacing:12.0 afterView:self.timerLabel];
    [stackView setCustomSpacing:18.0 afterView:self.waveformView];
    [self.sessionCard addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.sessionCard.topAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:self.sessionCard.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.sessionCard.trailingAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:self.sessionCard.bottomAnchor],
        [self.deviceBadgeLabel.widthAnchor constraintGreaterThanOrEqualToConstant:132.0],
        [self.deviceBadgeLabel.heightAnchor constraintEqualToConstant:26.0],
        [statusStack.heightAnchor constraintEqualToConstant:33.0],
        [self.recordingPulseView.widthAnchor constraintEqualToConstant:8.0],
        [self.recordingPulseView.heightAnchor constraintEqualToConstant:8.0],
        [self.timerLabel.heightAnchor constraintEqualToConstant:48.0],
        [self.waveformView.widthAnchor constraintEqualToAnchor:stackView.widthAnchor],
        [self.waveformView.heightAnchor constraintEqualToConstant:154.0],
        [self.recordHintLabel.heightAnchor constraintEqualToConstant:42.0],
    ]];
}

/** 安装实时转写卡内容 */
- (void)installTranscriptCardContent {
    UILabel *titleLabel = [self labelWithFont:[UIFont systemFontOfSize:15.0 weight:UIFontWeightBold]
                                        color:TSAIAudioRecordColor(16.0, 20.0, 45.0, 1.0)];
    titleLabel.text = @"Live transcript";
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel *liveBadgeLabel = [self labelWithFont:[UIFont systemFontOfSize:9.0 weight:UIFontWeightBold]
                                           color:TSAIAudioRecordColor(79.0, 123.0, 255.0, 1.0)];
    liveBadgeLabel.text = @"● STREAMING";
    liveBadgeLabel.textAlignment = NSTextAlignmentCenter;
    liveBadgeLabel.backgroundColor = TSAIAudioRecordColor(79.0, 123.0, 255.0, 0.09);
    liveBadgeLabel.layer.cornerRadius = 8.0;
    liveBadgeLabel.layer.masksToBounds = YES;
    liveBadgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.transcriptCard addSubview:titleLabel];
    [self.transcriptCard addSubview:liveBadgeLabel];
    [self.transcriptCard addSubview:self.transcriptView];
    self.transcriptCardHeightConstraint = [self.transcriptCard.heightAnchor constraintEqualToConstant:208.0];
    self.transcriptCardHeightConstraint.priority = UILayoutPriorityDefaultHigh;
    self.transcriptCardHeightConstraint.active = YES;
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.transcriptCard.leadingAnchor constant:15.0],
        [titleLabel.centerYAnchor constraintEqualToAnchor:self.transcriptCard.topAnchor constant:24.0],
        [liveBadgeLabel.trailingAnchor constraintEqualToAnchor:self.transcriptCard.trailingAnchor constant:-15.0],
        [liveBadgeLabel.centerYAnchor constraintEqualToAnchor:titleLabel.centerYAnchor],
        [liveBadgeLabel.widthAnchor constraintEqualToConstant:86.0],
        [liveBadgeLabel.heightAnchor constraintEqualToConstant:24.0],
        [self.transcriptView.topAnchor constraintEqualToAnchor:self.transcriptCard.topAnchor constant:48.0],
        [self.transcriptView.leadingAnchor constraintEqualToAnchor:self.transcriptCard.leadingAnchor],
        [self.transcriptView.trailingAnchor constraintEqualToAnchor:self.transcriptCard.trailingAnchor],
        [self.transcriptView.bottomAnchor constraintEqualToAnchor:self.transcriptCard.bottomAnchor],
    ]];
}

/** 安装完成结果卡内容 */
- (void)installResultCardContent {
    UIStackView *stackView = [self verticalStackWithSpacing:12.0];
    TSAIAudioRecordGradientView *heroView = [[TSAIAudioRecordGradientView alloc] init];
    heroView.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel *checkLabel = [self labelWithFont:[UIFont systemFontOfSize:20.0 weight:UIFontWeightBold]
                                       color:UIColor.whiteColor];
    checkLabel.text = @"✓";
    checkLabel.textAlignment = NSTextAlignmentCenter;
    checkLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.20];
    checkLabel.layer.cornerRadius = 17.0;
    checkLabel.layer.masksToBounds = YES;
    UILabel *titleLabel = [self labelWithFont:[UIFont systemFontOfSize:21.0 weight:UIFontWeightBold]
                                       color:UIColor.whiteColor];
    titleLabel.text = @"Recording completed";
    UILabel *detailLabel = [self labelWithFont:[UIFont systemFontOfSize:11.0 weight:UIFontWeightRegular]
                                        color:[UIColor colorWithWhite:1.0 alpha:0.78]];
    detailLabel.text = @"音频流与 AI 会话均已结束，最终转写结果已汇总。";
    detailLabel.numberOfLines = 0;
    UIStackView *metricsStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.durationMetricLabel,
        self.transcriptMetricLabel,
        self.speakerMetricLabel
    ]];
    metricsStack.axis = UILayoutConstraintAxisHorizontal;
    metricsStack.spacing = 8.0;
    metricsStack.distribution = UIStackViewDistributionFillEqually;
    UIStackView *heroStack = [self verticalStackWithSpacing:0.0];
    heroStack.alignment = UIStackViewAlignmentLeading;
    [heroStack addArrangedSubview:checkLabel];
    [heroStack addArrangedSubview:titleLabel];
    [heroStack addArrangedSubview:detailLabel];
    [heroStack addArrangedSubview:metricsStack];
    [heroStack setCustomSpacing:15.0 afterView:checkLabel];
    [heroStack setCustomSpacing:6.0 afterView:titleLabel];
    [heroStack setCustomSpacing:13.0 afterView:detailLabel];
    [heroView addSubview:heroStack];
    [NSLayoutConstraint activateConstraints:@[
        [heroView.heightAnchor constraintEqualToConstant:202.0],
        [heroStack.topAnchor constraintEqualToAnchor:heroView.topAnchor constant:19.0],
        [heroStack.leadingAnchor constraintEqualToAnchor:heroView.leadingAnchor constant:19.0],
        [heroStack.trailingAnchor constraintEqualToAnchor:heroView.trailingAnchor constant:-19.0],
        [heroStack.bottomAnchor constraintEqualToAnchor:heroView.bottomAnchor constant:-16.0],
        [checkLabel.widthAnchor constraintEqualToConstant:34.0],
        [checkLabel.heightAnchor constraintEqualToConstant:34.0],
        [metricsStack.widthAnchor constraintEqualToAnchor:heroStack.widthAnchor],
        [metricsStack.heightAnchor constraintEqualToConstant:48.0],
    ]];

    UIView *contentCard = [self cardView];
    UIStackView *contentStack = [self verticalStackWithSpacing:0.0];
    UIView *tabsContainer = [[UIView alloc] init];
    tabsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *tabsSeparator = [[UIView alloc] init];
    tabsSeparator.translatesAutoresizingMaskIntoConstraints = NO;
    tabsSeparator.backgroundColor = TSAIAudioRecordColor(16.0, 20.0, 45.0, 0.08);
    UIView *resultBodyView = [[UIView alloc] init];
    resultBodyView.translatesAutoresizingMaskIntoConstraints = NO;
    [tabsContainer addSubview:self.resultSegmentControl];
    [tabsContainer addSubview:tabsSeparator];
    [contentStack addArrangedSubview:tabsContainer];
    [contentStack addArrangedSubview:resultBodyView];
    [resultBodyView addSubview:self.resultTranscriptView];
    [resultBodyView addSubview:self.resultTextView];
    [contentCard addSubview:self.resultSelectionIndicator];
    self.resultSegmentControl.translatesAutoresizingMaskIntoConstraints = NO;
    [tabsContainer.heightAnchor constraintEqualToConstant:45.0].active = YES;
    [resultBodyView.heightAnchor constraintGreaterThanOrEqualToConstant:230.0].active = YES;
    [contentCard addSubview:contentStack];
    [NSLayoutConstraint activateConstraints:@[
        [contentStack.topAnchor constraintEqualToAnchor:contentCard.topAnchor],
        [contentStack.leadingAnchor constraintEqualToAnchor:contentCard.leadingAnchor],
        [contentStack.trailingAnchor constraintEqualToAnchor:contentCard.trailingAnchor],
        [contentStack.bottomAnchor constraintEqualToAnchor:contentCard.bottomAnchor],
        [self.resultSelectionIndicator.leadingAnchor constraintEqualToAnchor:contentCard.leadingAnchor constant:15.0],
        [self.resultSelectionIndicator.topAnchor constraintEqualToAnchor:contentCard.topAnchor constant:43.0],
        [self.resultSelectionIndicator.widthAnchor constraintEqualToConstant:72.0],
        [self.resultSelectionIndicator.heightAnchor constraintEqualToConstant:2.0],
        [self.resultSegmentControl.leadingAnchor constraintEqualToAnchor:tabsContainer.leadingAnchor constant:4.0],
        [self.resultSegmentControl.topAnchor constraintEqualToAnchor:tabsContainer.topAnchor],
        [self.resultSegmentControl.bottomAnchor constraintEqualToAnchor:tabsContainer.bottomAnchor],
        [self.resultSegmentControl.widthAnchor constraintEqualToConstant:190.0],
        [tabsSeparator.leadingAnchor constraintEqualToAnchor:tabsContainer.leadingAnchor],
        [tabsSeparator.trailingAnchor constraintEqualToAnchor:tabsContainer.trailingAnchor],
        [tabsSeparator.bottomAnchor constraintEqualToAnchor:tabsContainer.bottomAnchor],
        [tabsSeparator.heightAnchor constraintEqualToConstant:1.0],
        [self.resultTranscriptView.topAnchor constraintEqualToAnchor:resultBodyView.topAnchor],
        [self.resultTranscriptView.leadingAnchor constraintEqualToAnchor:resultBodyView.leadingAnchor],
        [self.resultTranscriptView.trailingAnchor constraintEqualToAnchor:resultBodyView.trailingAnchor],
        [self.resultTranscriptView.bottomAnchor constraintEqualToAnchor:resultBodyView.bottomAnchor],
        [self.resultTextView.topAnchor constraintEqualToAnchor:resultBodyView.topAnchor],
        [self.resultTextView.leadingAnchor constraintEqualToAnchor:resultBodyView.leadingAnchor],
        [self.resultTextView.trailingAnchor constraintEqualToAnchor:resultBodyView.trailingAnchor],
        [self.resultTextView.bottomAnchor constraintEqualToAnchor:resultBodyView.bottomAnchor],
    ]];

    UIButton *recordAgainButton = [self primarySmallButtonWithTitle:@"Record again"];
    [recordAgainButton addTarget:self action:@selector(handleRecordAgain)
                forControlEvents:UIControlEventTouchUpInside];
    UIButton *doneButton = [self secondaryButtonWithTitle:@"Done"];
    [doneButton addTarget:self action:@selector(handleDone) forControlEvents:UIControlEventTouchUpInside];
    UIStackView *actionStack = [[UIStackView alloc]
        initWithArrangedSubviews:@[doneButton, recordAgainButton]];
    actionStack.translatesAutoresizingMaskIntoConstraints = NO;
    actionStack.axis = UILayoutConstraintAxisHorizontal;
    actionStack.spacing = 10.0;
    actionStack.distribution = UIStackViewDistributionFillProportionally;
    UIView *actionContainer = [[UIView alloc] init];
    actionContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [actionContainer addSubview:actionStack];
    [NSLayoutConstraint activateConstraints:@[
        [actionContainer.heightAnchor constraintEqualToConstant:94.0],
        [actionStack.leadingAnchor constraintEqualToAnchor:actionContainer.leadingAnchor],
        [actionStack.trailingAnchor constraintEqualToAnchor:actionContainer.trailingAnchor],
        [actionStack.centerYAnchor constraintEqualToAnchor:actionContainer.centerYAnchor],
        [actionStack.heightAnchor constraintEqualToConstant:46.0],
    ]];
    [recordAgainButton.widthAnchor constraintEqualToAnchor:doneButton.widthAnchor multiplier:1.35].active = YES;
    [stackView addArrangedSubview:heroView];
    [stackView addArrangedSubview:contentCard];
    [stackView addArrangedSubview:actionContainer];
    [stackView setCustomSpacing:12.0 afterView:heroView];
    [stackView setCustomSpacing:0.0 afterView:contentCard];
    [self.resultCard addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.resultCard.topAnchor constant:15.0],
        [stackView.leadingAnchor constraintEqualToAnchor:self.resultCard.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.resultCard.trailingAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:self.resultCard.bottomAnchor],
    ]];
}

/** 安装底部操作栏 */
- (void)installBottomBarContent {
    UILabel *languageTitleLabel = [self labelWithFont:[UIFont systemFontOfSize:10.0 weight:UIFontWeightRegular]
                                               color:TSAIAudioRecordColor(156.0, 162.0, 184.0, 1.0)];
    languageTitleLabel.text = @"Source language";
    UIStackView *languageStack = [self verticalStackWithSpacing:6.0];
    [languageStack addArrangedSubview:languageTitleLabel];
    [languageStack addArrangedSubview:self.bottomLanguageButton];
    UIStackView *leftColumnStack = [self verticalStackWithSpacing:0.0];
    leftColumnStack.alignment = UIStackViewAlignmentLeading;
    leftColumnStack.distribution = UIStackViewDistributionEqualSpacing;
    [leftColumnStack addArrangedSubview:self.pickupRouteButton];
    [leftColumnStack addArrangedSubview:languageStack];
    UIStackView *rightColumnStack = [self verticalStackWithSpacing:0.0];
    rightColumnStack.alignment = UIStackViewAlignmentTrailing;
    rightColumnStack.distribution = UIStackViewDistributionEqualSpacing;
    [rightColumnStack addArrangedSubview:self.contentPlaybackRouteButton];
    [rightColumnStack addArrangedSubview:self.sideMetaLabel];
    [self.bottomBar addSubview:self.recordButton];
    [self.recordButton addSubview:self.recordButtonFillView];
    [self.recordButtonFillView addSubview:self.recordStopView];
    [self.bottomBar addSubview:self.actionHintLabel];
    [self.bottomBar addSubview:leftColumnStack];
    [self.bottomBar addSubview:rightColumnStack];
    [NSLayoutConstraint activateConstraints:@[
        [self.recordButton.topAnchor constraintEqualToAnchor:self.bottomBar.topAnchor constant:12.0],
        [self.recordButton.centerXAnchor constraintEqualToAnchor:self.bottomBar.centerXAnchor],
        [self.recordButton.widthAnchor constraintEqualToConstant:72.0],
        [self.recordButton.heightAnchor constraintEqualToConstant:72.0],
        [self.recordButtonFillView.centerXAnchor constraintEqualToAnchor:self.recordButton.centerXAnchor],
        [self.recordButtonFillView.centerYAnchor constraintEqualToAnchor:self.recordButton.centerYAnchor],
        [self.recordButtonFillView.widthAnchor constraintEqualToConstant:58.0],
        [self.recordButtonFillView.heightAnchor constraintEqualToConstant:58.0],
        [self.recordStopView.centerXAnchor constraintEqualToAnchor:self.recordButtonFillView.centerXAnchor],
        [self.recordStopView.centerYAnchor constraintEqualToAnchor:self.recordButtonFillView.centerYAnchor],
        [self.recordStopView.widthAnchor constraintEqualToConstant:22.0],
        [self.recordStopView.heightAnchor constraintEqualToConstant:22.0],
        [self.actionHintLabel.topAnchor constraintEqualToAnchor:self.recordButton.bottomAnchor constant:7.0],
        [self.actionHintLabel.centerXAnchor constraintEqualToAnchor:self.recordButton.centerXAnchor],
        [leftColumnStack.topAnchor constraintEqualToAnchor:self.bottomBar.topAnchor constant:12.0],
        [leftColumnStack.leadingAnchor constraintEqualToAnchor:self.bottomBar.leadingAnchor constant:18.0],
        [leftColumnStack.bottomAnchor
            constraintEqualToAnchor:self.bottomBar.safeAreaLayoutGuide.bottomAnchor
            constant:-12.0],
        [leftColumnStack.widthAnchor constraintEqualToConstant:116.0],
        [rightColumnStack.topAnchor constraintEqualToAnchor:leftColumnStack.topAnchor],
        [rightColumnStack.trailingAnchor constraintEqualToAnchor:self.bottomBar.trailingAnchor constant:-18.0],
        [rightColumnStack.bottomAnchor constraintEqualToAnchor:leftColumnStack.bottomAnchor],
        [rightColumnStack.widthAnchor constraintEqualToConstant:116.0],
        [self.pickupRouteButton.widthAnchor constraintEqualToAnchor:leftColumnStack.widthAnchor],
        [self.pickupRouteButton.heightAnchor constraintEqualToConstant:44.0],
        [self.contentPlaybackRouteButton.widthAnchor constraintEqualToAnchor:rightColumnStack.widthAnchor],
        [self.contentPlaybackRouteButton.heightAnchor constraintEqualToConstant:44.0],
        [languageStack.widthAnchor constraintLessThanOrEqualToAnchor:leftColumnStack.widthAnchor],
        [self.sideMetaLabel.widthAnchor constraintLessThanOrEqualToAnchor:rightColumnStack.widthAnchor],
    ]];
}

/** 安装最终结果整理遮罩 */
- (void)installFinalizingOverlayContent {
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc]
        initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    blurView.alpha = 0.22;
    UIView *panel = [[UIView alloc] init];
    panel.translatesAutoresizingMaskIntoConstraints = NO;
    panel.backgroundColor = TSAIAudioRecordColor(16.0, 20.0, 45.0, 0.88);
    panel.layer.cornerRadius = 18.0;
    [self.finalizingOverlay addSubview:blurView];
    [self.finalizingOverlay addSubview:panel];
    [panel addSubview:self.activityIndicator];
    [panel addSubview:self.finalizingLabel];
    [NSLayoutConstraint activateConstraints:@[
        [blurView.topAnchor constraintEqualToAnchor:self.finalizingOverlay.topAnchor],
        [blurView.leadingAnchor constraintEqualToAnchor:self.finalizingOverlay.leadingAnchor],
        [blurView.trailingAnchor constraintEqualToAnchor:self.finalizingOverlay.trailingAnchor],
        [blurView.bottomAnchor constraintEqualToAnchor:self.finalizingOverlay.bottomAnchor],
        [panel.centerXAnchor constraintEqualToAnchor:self.finalizingOverlay.centerXAnchor],
        [panel.centerYAnchor constraintEqualToAnchor:self.finalizingOverlay.centerYAnchor],
        [panel.widthAnchor constraintEqualToConstant:150.0],
        [panel.heightAnchor constraintEqualToConstant:98.0],
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:panel.centerXAnchor],
        [self.activityIndicator.topAnchor constraintEqualToAnchor:panel.topAnchor constant:22.0],
        [self.finalizingLabel.topAnchor constraintEqualToAnchor:self.activityIndicator.bottomAnchor constant:12.0],
        [self.finalizingLabel.leadingAnchor constraintEqualToAnchor:panel.leadingAnchor constant:14.0],
        [self.finalizingLabel.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-14.0],
    ]];
}

/** 安装与 HTML 一致的录音说明底部弹层 */
- (void)installRecordingHelpContent {
    [self.recordingHelpOverlay addSubview:self.recordingHelpSheet];
    UIView *gripView = [[UIView alloc] init];
    gripView.translatesAutoresizingMaskIntoConstraints = NO;
    gripView.backgroundColor = TSAIAudioRecordColor(223.0, 226.0, 235.0, 1.0);
    gripView.layer.cornerRadius = 2.0;
    UILabel *titleLabel = [self labelWithFont:[UIFont systemFontOfSize:17.0 weight:UIFontWeightBold]
                                        color:TSAIAudioRecordColor(16.0, 20.0, 45.0, 1.0)];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"AI Recording";
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    closeButton.titleLabel.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightRegular];
    [closeButton setTitle:@"×" forState:UIControlStateNormal];
    [closeButton setTitleColor:TSAIAudioRecordColor(16.0, 20.0, 45.0, 1.0)
                      forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(handleCloseRecordingHelp)
          forControlEvents:UIControlEventTouchUpInside];
    UIView *onSiteView = [self recordingModeViewWithTitle:@"现场录音"
                                                   detail:@"适用于会议与面对面沟通。"
                                                          @"未在通话时自动选择此模式。"
                                               systemName:@"person.2"];
    UIView *callView = [self recordingModeViewWithTitle:@"通话录音"
                                                 detail:@"适用于系统语音与网络通话，"
                                                        @"开始时由设备自动判断。"
                                             systemName:@"phone"];
    UIButton *primaryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    primaryButton.translatesAutoresizingMaskIntoConstraints = NO;
    primaryButton.backgroundColor = TSAIAudioRecordColor(79.0, 123.0, 255.0, 1.0);
    primaryButton.layer.cornerRadius = 15.0;
    primaryButton.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightBold];
    [primaryButton setTitle:@"开始体验" forState:UIControlStateNormal];
    [primaryButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [primaryButton addTarget:self action:@selector(handleCloseRecordingHelp)
             forControlEvents:UIControlEventTouchUpInside];
    for (UIView *view in @[gripView, titleLabel, closeButton, onSiteView, callView, primaryButton]) {
        [self.recordingHelpSheet addSubview:view];
    }
    [NSLayoutConstraint activateConstraints:@[
        [self.recordingHelpSheet.leadingAnchor constraintEqualToAnchor:self.recordingHelpOverlay.leadingAnchor],
        [self.recordingHelpSheet.trailingAnchor constraintEqualToAnchor:self.recordingHelpOverlay.trailingAnchor],
        [self.recordingHelpSheet.bottomAnchor constraintEqualToAnchor:self.recordingHelpOverlay.bottomAnchor],
        [self.recordingHelpSheet.heightAnchor constraintEqualToConstant:326.0],
        [gripView.topAnchor constraintEqualToAnchor:self.recordingHelpSheet.topAnchor constant:9.0],
        [gripView.centerXAnchor constraintEqualToAnchor:self.recordingHelpSheet.centerXAnchor],
        [gripView.widthAnchor constraintEqualToConstant:38.0],
        [gripView.heightAnchor constraintEqualToConstant:4.0],
        [titleLabel.topAnchor constraintEqualToAnchor:gripView.bottomAnchor constant:13.0],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.recordingHelpSheet.leadingAnchor constant:18.0],
        [closeButton.centerYAnchor constraintEqualToAnchor:titleLabel.centerYAnchor],
        [closeButton.trailingAnchor constraintEqualToAnchor:self.recordingHelpSheet.trailingAnchor constant:-14.0],
        [closeButton.widthAnchor constraintEqualToConstant:36.0],
        [closeButton.heightAnchor constraintEqualToConstant:36.0],
        [onSiteView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:13.0],
        [onSiteView.leadingAnchor constraintEqualToAnchor:self.recordingHelpSheet.leadingAnchor constant:18.0],
        [onSiteView.trailingAnchor constraintEqualToAnchor:self.recordingHelpSheet.trailingAnchor constant:-18.0],
        [onSiteView.heightAnchor constraintEqualToConstant:76.0],
        [callView.topAnchor constraintEqualToAnchor:onSiteView.bottomAnchor constant:8.0],
        [callView.leadingAnchor constraintEqualToAnchor:onSiteView.leadingAnchor],
        [callView.trailingAnchor constraintEqualToAnchor:onSiteView.trailingAnchor],
        [callView.heightAnchor constraintEqualToConstant:76.0],
        [primaryButton.topAnchor constraintEqualToAnchor:callView.bottomAnchor constant:9.0],
        [primaryButton.leadingAnchor constraintEqualToAnchor:onSiteView.leadingAnchor],
        [primaryButton.trailingAnchor constraintEqualToAnchor:onSiteView.trailingAnchor],
        [primaryButton.heightAnchor constraintEqualToConstant:48.0],
    ]];
}

/** 安装音频路径选择底部弹层 */
- (void)installAudioRouteSheetContent {
    [self.audioRouteOverlay addSubview:self.audioRouteSheet];
    UIView *gripView = [[UIView alloc] init];
    gripView.translatesAutoresizingMaskIntoConstraints = NO;
    gripView.backgroundColor = TSAIAudioRecordColor(214.0, 216.0, 225.0, 1.0);
    gripView.layer.cornerRadius = 2.0;
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    closeButton.backgroundColor = TSAIAudioRecordColor(240.0, 241.0, 245.0, 1.0);
    closeButton.layer.cornerRadius = 15.0;
    closeButton.titleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightRegular];
    [closeButton setTitle:@"×" forState:UIControlStateNormal];
    [closeButton setTitleColor:TSAIAudioRecordColor(104.0, 112.0, 143.0, 1.0)
                      forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(handleCloseAudioRouteSelection)
          forControlEvents:UIControlEventTouchUpInside];
    UILabel *footnoteLabel = [self labelWithFont:[UIFont systemFontOfSize:9.0
                                                                       weight:UIFontWeightRegular]
                                           color:TSAIAudioRecordColor(104.0, 112.0, 143.0, 1.0)];
    footnoteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    footnoteLabel.text = @"选择仅对 AI 录音生效；录音进行中不可切换。";
    footnoteLabel.textAlignment = NSTextAlignmentCenter;
    footnoteLabel.numberOfLines = 2;
    for (UIView *view in @[
        gripView,
        self.audioRouteSheetTitleLabel,
        self.audioRouteSheetSubtitleLabel,
        closeButton,
        self.audioRouteOptionStackView,
        footnoteLabel
    ]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.audioRouteSheet addSubview:view];
    }
    [NSLayoutConstraint activateConstraints:@[
        [self.audioRouteSheet.leadingAnchor constraintEqualToAnchor:self.audioRouteOverlay.leadingAnchor],
        [self.audioRouteSheet.trailingAnchor constraintEqualToAnchor:self.audioRouteOverlay.trailingAnchor],
        [self.audioRouteSheet.bottomAnchor constraintEqualToAnchor:self.audioRouteOverlay.bottomAnchor],
        [self.audioRouteSheet.heightAnchor constraintEqualToConstant:354.0],
        [gripView.topAnchor constraintEqualToAnchor:self.audioRouteSheet.topAnchor constant:9.0],
        [gripView.centerXAnchor constraintEqualToAnchor:self.audioRouteSheet.centerXAnchor],
        [gripView.widthAnchor constraintEqualToConstant:38.0],
        [gripView.heightAnchor constraintEqualToConstant:4.0],
        [self.audioRouteSheetTitleLabel.topAnchor constraintEqualToAnchor:gripView.bottomAnchor constant:14.0],
        [self.audioRouteSheetTitleLabel.leadingAnchor constraintEqualToAnchor:self.audioRouteSheet.leadingAnchor
                                                                      constant:16.0],
        [self.audioRouteSheetTitleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:closeButton.leadingAnchor
                                                                                   constant:-10.0],
        [self.audioRouteSheetSubtitleLabel.topAnchor
            constraintEqualToAnchor:self.audioRouteSheetTitleLabel.bottomAnchor constant:4.0],
        [self.audioRouteSheetSubtitleLabel.leadingAnchor
            constraintEqualToAnchor:self.audioRouteSheetTitleLabel.leadingAnchor],
        [closeButton.topAnchor constraintEqualToAnchor:gripView.bottomAnchor constant:10.0],
        [closeButton.trailingAnchor constraintEqualToAnchor:self.audioRouteSheet.trailingAnchor constant:-16.0],
        [closeButton.widthAnchor constraintEqualToConstant:30.0],
        [closeButton.heightAnchor constraintEqualToConstant:30.0],
        [self.audioRouteOptionStackView.topAnchor
            constraintEqualToAnchor:self.audioRouteSheetSubtitleLabel.bottomAnchor constant:16.0],
        [self.audioRouteOptionStackView.leadingAnchor constraintEqualToAnchor:self.audioRouteSheet.leadingAnchor
                                                                       constant:16.0],
        [self.audioRouteOptionStackView.trailingAnchor constraintEqualToAnchor:self.audioRouteSheet.trailingAnchor
                                                                        constant:-16.0],
        [self.audioRouteOptionStackView.heightAnchor constraintEqualToConstant:208.0],
        [footnoteLabel.topAnchor constraintEqualToAnchor:self.audioRouteOptionStackView.bottomAnchor constant:10.0],
        [footnoteLabel.leadingAnchor constraintEqualToAnchor:self.audioRouteSheet.leadingAnchor constant:16.0],
        [footnoteLabel.trailingAnchor constraintEqualToAnchor:self.audioRouteSheet.trailingAnchor constant:-16.0],
    ]];
}

/** 创建录音模式说明卡片 */
- (UIView *)recordingModeViewWithTitle:(NSString *)title
                                detail:(NSString *)detail
                            systemName:(NSString *)systemName {
    UIView *modeView = [[UIView alloc] init];
    modeView.translatesAutoresizingMaskIntoConstraints = NO;
    modeView.backgroundColor = TSAIAudioRecordColor(245.0, 246.0, 251.0, 1.0);
    modeView.layer.cornerRadius = 16.0;
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.contentMode = UIViewContentModeCenter;
    iconView.tintColor = TSAIAudioRecordColor(79.0, 123.0, 255.0, 1.0);
    iconView.backgroundColor = TSAIAudioRecordColor(79.0, 123.0, 255.0, 0.09);
    iconView.layer.cornerRadius = 13.0;
    if (@available(iOS 13.0, *)) {
        iconView.image = [UIImage systemImageNamed:systemName];
    }
    UILabel *titleLabel = [self labelWithFont:[UIFont systemFontOfSize:13.0 weight:UIFontWeightBold]
                                        color:TSAIAudioRecordColor(16.0, 20.0, 45.0, 1.0)];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = title;
    UILabel *detailLabel = [self labelWithFont:[UIFont systemFontOfSize:11.0 weight:UIFontWeightRegular]
                                         color:TSAIAudioRecordColor(104.0, 112.0, 143.0, 1.0)];
    detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    detailLabel.numberOfLines = 2;
    detailLabel.text = detail;
    [modeView addSubview:iconView];
    [modeView addSubview:titleLabel];
    [modeView addSubview:detailLabel];
    [NSLayoutConstraint activateConstraints:@[
        [iconView.leadingAnchor constraintEqualToAnchor:modeView.leadingAnchor constant:13.0],
        [iconView.centerYAnchor constraintEqualToAnchor:modeView.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:42.0],
        [iconView.heightAnchor constraintEqualToConstant:42.0],
        [titleLabel.topAnchor constraintEqualToAnchor:modeView.topAnchor constant:13.0],
        [titleLabel.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:12.0],
        [titleLabel.trailingAnchor constraintEqualToAnchor:modeView.trailingAnchor constant:-12.0],
        [detailLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:4.0],
        [detailLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [detailLabel.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],
    ]];
    return modeView;
}

/** 激活页面主要约束 */
- (void)activatePageConstraints {
    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    self.bottomBarHeightConstraint = [self.bottomBar.heightAnchor constraintEqualToConstant:136.0];
    self.bottomBarHeightConstraint.priority = UILayoutPriorityRequired - 1.0;
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.bottomBar.topAnchor],
        [self.contentStackView.topAnchor
            constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor],
        [self.contentStackView.leadingAnchor
            constraintEqualToAnchor:self.scrollView.frameLayoutGuide.leadingAnchor constant:20.0],
        [self.contentStackView.trailingAnchor
            constraintEqualToAnchor:self.scrollView.frameLayoutGuide.trailingAnchor constant:-20.0],
        [self.contentStackView.bottomAnchor
            constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor constant:-20.0],
        [self.bottomBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.bottomBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.bottomBar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        self.bottomBarHeightConstraint,
        [self.finalizingOverlay.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.finalizingOverlay.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.finalizingOverlay.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.finalizingOverlay.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.recordingHelpOverlay.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.recordingHelpOverlay.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.recordingHelpOverlay.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.recordingHelpOverlay.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.audioRouteOverlay.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.audioRouteOverlay.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.audioRouteOverlay.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.audioRouteOverlay.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

/** 创建白色圆角卡片 */
- (UIView *)cardView {
    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 18.0;
    card.layer.shadowColor = UIColor.blackColor.CGColor;
    card.layer.borderWidth = 1.0;
    card.layer.borderColor = TSAIAudioRecordColor(16.0, 20.0, 45.0, 0.08).CGColor;
    card.layer.shadowOpacity = 0.05;
    card.layer.shadowRadius = 9.0;
    card.layer.shadowOffset = CGSizeMake(0.0, 6.0);
    return card;
}

/** 创建基础标签 */
- (UILabel *)labelWithFont:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    return label;
}

/** 创建录音页底部紧凑路径按钮 */
- (UIButton *)recordRouteButtonWithSystemName:(NSString *)systemName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.58];
    button.layer.cornerRadius = 13.0;
    button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 9.0, 0.0, 7.0);
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *configuration =
            [UIImageSymbolConfiguration configurationWithPointSize:17.0
                                                             weight:UIImageSymbolWeightRegular];
        UIImage *image = [UIImage systemImageNamed:systemName withConfiguration:configuration];
        [button setImage:image forState:UIControlStateNormal];
        button.tintColor = TSAIAudioRecordColor(255.0, 77.0, 94.0, 1.0);
        button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 7.0);
    }
    return button;
}

/** 创建音频路径弹层选项按钮 */
- (UIButton *)audioRouteOptionButtonWithTag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.tag = tag;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(9.0, 12.0, 9.0, 12.0);
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    button.layer.cornerRadius = 16.0;
    button.layer.borderWidth = 1.5;
    button.layer.borderColor = TSAIAudioRecordColor(16.0, 20.0, 45.0, 0.08).CGColor;
    button.backgroundColor = UIColor.whiteColor;
    return button;
}

/** 更新紧凑路径按钮的标题和值 */
- (void)updateRouteButton:(UIButton *)button label:(NSString *)label value:(NSString *)value {
    NSString *title = [NSString stringWithFormat:@"%@\n%@", label, value];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2.0;
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc]
        initWithString:title
        attributes:@{
            NSForegroundColorAttributeName: TSAIAudioRecordColor(16.0, 20.0, 45.0, 1.0),
            NSFontAttributeName: [UIFont systemFontOfSize:11.0 weight:UIFontWeightSemibold],
            NSParagraphStyleAttributeName: paragraphStyle
        }];
    [attributedTitle addAttributes:@{
        NSForegroundColorAttributeName: TSAIAudioRecordColor(156.0, 162.0, 184.0, 1.0),
        NSFontAttributeName: [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
    } range:NSMakeRange(0, label.length)];
    [button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

/** 创建配置值按钮 */
- (UIButton *)valueButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.minimumScaleFactor = 0.75;
    [button setTitleColor:TSAIAudioRecordColor(16.0, 20.0, 45.0, 1.0)
                forState:UIControlStateNormal];
    return button;
}

/** 创建单色图片 */
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/** 创建完成态指标标签 */
- (UILabel *)completionMetricLabel {
    UILabel *label = [self labelWithFont:[UIFont monospacedDigitSystemFontOfSize:11.0
                                                                              weight:UIFontWeightSemibold]
                                   color:UIColor.whiteColor];
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.13];
    label.layer.cornerRadius = 12.0;
    label.layer.masksToBounds = YES;
    return label;
}

/** 创建次级操作按钮 */
- (UIButton *)secondaryButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.layer.cornerRadius = 15.0;
    button.backgroundColor = TSAIAudioRecordColor(238.0, 239.0, 244.0, 1.0);
    button.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightBold];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:TSAIAudioRecordColor(16.0, 20.0, 45.0, 1.0)
                forState:UIControlStateNormal];
    return button;
}

/** 创建主色小按钮 */
- (UIButton *)primarySmallButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.layer.cornerRadius = 15.0;
    button.backgroundColor = TSAIAudioRecordColor(79.0, 123.0, 255.0, 1.0);
    button.layer.shadowColor = TSAIAudioRecordColor(79.0, 123.0, 255.0, 1.0).CGColor;
    button.layer.shadowOpacity = 0.24;
    button.layer.shadowRadius = 10.0;
    button.layer.shadowOffset = CGSizeMake(0.0, 8.0);
    button.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightBold];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    return button;
}

/** 创建只读结果文本 */
- (UITextView *)resultTextViewWithEmptyText:(NSString *)emptyText {
    UITextView *textView = [[UITextView alloc] init];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.backgroundColor = TSAdaptiveColor(
        [UIColor colorWithRed:247.0 / 255.0 green:248.0 / 255.0 blue:252.0 / 255.0 alpha:1.0],
        [UIColor colorWithRed:37.0 / 255.0 green:37.0 / 255.0 blue:42.0 / 255.0 alpha:1.0]);
    textView.layer.cornerRadius = 12.0;
    textView.editable = NO;
    textView.selectable = YES;
    textView.textContainerInset = UIEdgeInsetsMake(14.0, 15.0, 14.0, 15.0);
    textView.font = [UIFont systemFontOfSize:11.0];
    textView.textColor = TSAIAudioRecordColor(37.0, 42.0, 66.0, 1.0);
    textView.text = emptyText;
    return textView;
}

/** 创建纵向栈 */
- (UIStackView *)verticalStackWithSpacing:(CGFloat)spacing {
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = spacing;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    return stackView;
}

@end
