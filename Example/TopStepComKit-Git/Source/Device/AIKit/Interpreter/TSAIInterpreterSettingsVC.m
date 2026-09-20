//
//  TSAIInterpreterSettingsVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterSettingsVC.h"

#import <TopStepAIKit/TopStepAIKit.h>

#import "TSAILogView.h"
#import "TSRootVC.h"

static NSArray<NSString *> *kInterpreterSpeakerPresets(void) {
    return @[ @"xiaogang", @"xiaomei", @"xiaoyu" ];
}

typedef NS_ENUM(NSInteger, TSAIInterpreterRouteSegment) {
    TSAIInterpreterRouteSegmentAutomatic = 0,
    TSAIInterpreterRouteSegmentPhone,
    TSAIInterpreterRouteSegmentEarphone,
    TSAIInterpreterRouteSegmentDevice,
};

@interface TSAIInterpreterSettingsVC ()

#pragma mark - 视图
/// 页面滚动容器
@property (nonatomic, strong) UIScrollView *scrollView;
/// 副标题
@property (nonatomic, strong) UILabel *subtitleLabel;
/// 音频路径分组标题
@property (nonatomic, strong) UILabel *audioRouteSectionLabel;
/// 音频路径卡片
@property (nonatomic, strong) UIView *audioRouteCardView;
/// 拾音设置标题
@property (nonatomic, strong) UILabel *pickupTitleLabel;
/// 当前拾音设置
@property (nonatomic, strong) UILabel *pickupValueLabel;
/// 拾音路径分段控件
@property (nonatomic, strong) UISegmentedControl *pickupSegmentControl;
/// 播放设置标题
@property (nonatomic, strong) UILabel *playbackTitleLabel;
/// 当前播放设置
@property (nonatomic, strong) UILabel *playbackValueLabel;
/// 播放路径分段控件
@property (nonatomic, strong) UISegmentedControl *playbackSegmentControl;
/// 译文语音分组标题
@property (nonatomic, strong) UILabel *voiceSectionLabel;
/// 译文语音设置卡片
@property (nonatomic, strong) UIView *voiceSettingsCardView;
/// 「Voice Output (TTS)」主标签
@property (nonatomic, strong) UILabel *ttsTitleLabel;
/// 「Voice Output (TTS)」副标签
@property (nonatomic, strong) UILabel *ttsSubLabel;
/// 「Voice Output (TTS)」开关
@property (nonatomic, strong) UISwitch *ttsSwitch;
/// 「Auto Play on Device」主标签
@property (nonatomic, strong) UILabel *autoPlayTitleLabel;
/// 「Auto Play on Device」副标签
@property (nonatomic, strong) UILabel *autoPlaySubLabel;
/// 「Auto Play on Device」开关
@property (nonatomic, strong) UISwitch *autoPlaySwitch;
/// 「TTS Speaker」主标签
@property (nonatomic, strong) UILabel *speakerTitleLabel;
/// 「TTS Speaker」副标签
@property (nonatomic, strong) UILabel *speakerSubLabel;
/// 「TTS Speaker」当前值标签（卡片内右对齐）
@property (nonatomic, strong) UILabel *speakerValueLabel;
/// Speaker 预设胶囊容器
@property (nonatomic, strong) UIView *speakerPresetsView;
/// Speaker 预设胶囊数组（顺序：xiaogang / xiaomei / xiaoyu / default）
@property (nonatomic, strong) NSArray<UIButton *> *speakerPresetButtons;
/// 「LOGS / EVENTS」section 标题
@property (nonatomic, strong) UILabel *logsHeaderLabel;
/// 日志区"Clear"按钮（链接样式）
@property (nonatomic, strong) UIButton *logsClearButton;
/// 外部传入并 reparent 的日志视图
@property (nonatomic, strong) TSAILogView *logView;

#pragma mark - 状态
/// 当前音频路由
@property (nonatomic, copy) TSAIAudioRouteConfiguration *audioRouteConfiguration;
/// 同传支持的完整音频路由
@property (nonatomic, copy) NSArray<TSAIAudioRouteCapability *> *audioRouteCapabilities;
@property (nonatomic, assign) BOOL enableVoiceOutput;
@property (nonatomic, assign) BOOL autoPlayVoice;
@property (nonatomic, copy, nullable) NSString *speakerId;

@end

@implementation TSAIInterpreterSettingsVC

#pragma mark - 生命周期

- (instancetype)initWithConfig:(TSAIInterpreterConfig *)config
                       logView:(TSAILogView *)logView {
    self = [super init];
    if (self) {
        _audioRouteConfiguration = [config.audioRouteConfiguration copy] ?:
            [TSAIAudioRouteConfiguration defaultConfiguration];
        _enableVoiceOutput = config.enableVoiceOutput;
        _autoPlayVoice = config.autoPlayVoice;
        _speakerId = [config.speakerId copy];
        _logView = logView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.title = TSLocalizedString(@"ai_interpreter.sheet_settings_title");
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                       target:self
                                                       action:@selector(onDoneTap)];
    [self refreshAudioRouteCapabilities];
    [self setupViews];
    [self refreshAllRows];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.logView removeFromSuperview];
    BOOL sheetIsBeingDismissed = self.isBeingDismissed ||
        self.navigationController.isBeingDismissed;
    if (sheetIsBeingDismissed) {
        if (self.onDismiss) {
            self.onDismiss();
        }
    }
}

#pragma mark - 私有方法 - 视图搭建 / 布局

- (void)setupViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.subtitleLabel];
    [self.scrollView addSubview:self.audioRouteSectionLabel];
    [self.scrollView addSubview:self.audioRouteCardView];
    [self.scrollView addSubview:self.voiceSectionLabel];
    [self.scrollView addSubview:self.voiceSettingsCardView];
    [self.scrollView addSubview:self.logsHeaderLabel];
    [self.scrollView addSubview:self.logsClearButton];
    if (self.logView) {
        [self.scrollView addSubview:self.logView];
    }

    [self.audioRouteCardView addSubview:self.pickupTitleLabel];
    [self.audioRouteCardView addSubview:self.pickupValueLabel];
    [self.audioRouteCardView addSubview:self.pickupSegmentControl];
    [self.audioRouteCardView addSubview:self.playbackTitleLabel];
    [self.audioRouteCardView addSubview:self.playbackValueLabel];
    [self.audioRouteCardView addSubview:self.playbackSegmentControl];

    [self.voiceSettingsCardView addSubview:self.ttsTitleLabel];
    [self.voiceSettingsCardView addSubview:self.ttsSubLabel];
    [self.voiceSettingsCardView addSubview:self.ttsSwitch];
    [self.voiceSettingsCardView addSubview:self.autoPlayTitleLabel];
    [self.voiceSettingsCardView addSubview:self.autoPlaySubLabel];
    [self.voiceSettingsCardView addSubview:self.autoPlaySwitch];
    [self.voiceSettingsCardView addSubview:self.speakerTitleLabel];
    [self.voiceSettingsCardView addSubview:self.speakerSubLabel];
    [self.voiceSettingsCardView addSubview:self.speakerValueLabel];
    [self.voiceSettingsCardView addSubview:self.speakerPresetsView];
    for (UIButton *presetButton in self.speakerPresetButtons) {
        [self.speakerPresetsView addSubview:presetButton];
    }
}

- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat sideInset = 20.0;
    CGFloat contentWidth = width - sideInset * 2;

    self.scrollView.frame = self.view.bounds;

    CGFloat y = self.view.safeAreaInsets.top + 12.0;
    CGSize subtitleSize = [self.subtitleLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    self.subtitleLabel.frame = CGRectMake(sideInset, y, contentWidth, subtitleSize.height);
    y += subtitleSize.height + 18.0;

    CGFloat sectionHeight = 18.0;
    self.audioRouteSectionLabel.frame = CGRectMake(sideInset + 4.0,
                                                   y,
                                                   contentWidth - 8.0,
                                                   sectionHeight);
    y += sectionHeight + 8.0;

    CGFloat audioRouteCardHeight = 152.0;
    self.audioRouteCardView.frame = CGRectMake(sideInset,
                                               y,
                                               contentWidth,
                                               audioRouteCardHeight);
    [self layoutAudioRouteCard];
    y += audioRouteCardHeight + 18.0;

    self.voiceSectionLabel.frame = CGRectMake(sideInset + 4.0,
                                              y,
                                              contentWidth - 8.0,
                                              sectionHeight);
    y += sectionHeight + 8.0;

    CGFloat voiceCardHeight = 206.0;
    self.voiceSettingsCardView.frame = CGRectMake(sideInset,
                                                  y,
                                                  contentWidth,
                                                  voiceCardHeight);
    [self layoutVoiceSettingsCard];
    y += voiceCardHeight + 22.0;

    CGFloat logsHeaderHeight = 18.0;
    self.logsHeaderLabel.frame = CGRectMake(sideInset + 4.0,
                                            y,
                                            contentWidth - 68.0,
                                            logsHeaderHeight);
    self.logsClearButton.frame = CGRectMake(width - sideInset - 60.0,
                                            y - 4.0,
                                            60.0,
                                            logsHeaderHeight + 8.0);
    y += logsHeaderHeight + 8.0;

    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    CGFloat logBottom = height - bottomInset - 16.0;
    CGFloat logHeight = MAX(100.0, logBottom - y);
    self.logView.frame = CGRectMake(sideInset, y, contentWidth, logHeight);
    self.scrollView.contentSize = CGSizeMake(width,
                                             CGRectGetMaxY(self.logView.frame) + bottomInset + 16.0);
}

- (void)layoutAudioRouteCard {
    CGFloat width = CGRectGetWidth(self.audioRouteCardView.bounds);
    CGFloat rowHeight = 76.0;
    CGFloat horizontalInset = 16.0;
    CGFloat titleWidth = 90.0;
    CGFloat valueWidth = width - horizontalInset * 2 - titleWidth;

    self.pickupTitleLabel.frame = CGRectMake(horizontalInset, 10.0, titleWidth, 18.0);
    self.pickupValueLabel.frame = CGRectMake(horizontalInset + titleWidth,
                                             10.0,
                                             valueWidth,
                                             18.0);
    self.pickupSegmentControl.frame = CGRectMake(horizontalInset,
                                                 36.0,
                                                 width - horizontalInset * 2,
                                                 32.0);

    self.playbackTitleLabel.frame = CGRectMake(horizontalInset,
                                               rowHeight + 10.0,
                                               titleWidth,
                                               18.0);
    self.playbackValueLabel.frame = CGRectMake(horizontalInset + titleWidth,
                                               rowHeight + 10.0,
                                               valueWidth,
                                               18.0);
    self.playbackSegmentControl.frame = CGRectMake(horizontalInset,
                                                   rowHeight + 36.0,
                                                   width - horizontalInset * 2,
                                                   32.0);
}

- (void)layoutVoiceSettingsCard {
    CGFloat width = CGRectGetWidth(self.voiceSettingsCardView.bounds);
    CGFloat rowHeight = 56.0;
    CGFloat labelLeft = 16.0;
    CGFloat controlRight = 16.0;
    CGFloat switchWidth = 51.0;
    CGFloat switchHeight = 31.0;
    CGFloat labelWidth = width - switchWidth - labelLeft - controlRight;

    self.ttsTitleLabel.frame = CGRectMake(labelLeft, 10.0, labelWidth, 18.0);
    self.ttsSubLabel.frame = CGRectMake(labelLeft, 30.0, labelWidth, 16.0);
    self.ttsSwitch.frame = CGRectMake(width - switchWidth - controlRight,
                                      (rowHeight - switchHeight) / 2.0,
                                      switchWidth,
                                      switchHeight);

    CGFloat autoPlayY = rowHeight;
    self.autoPlayTitleLabel.frame = CGRectMake(labelLeft, autoPlayY + 10.0, labelWidth, 18.0);
    self.autoPlaySubLabel.frame = CGRectMake(labelLeft, autoPlayY + 30.0, labelWidth, 16.0);
    self.autoPlaySwitch.frame = CGRectMake(width - switchWidth - controlRight,
                                           autoPlayY + (rowHeight - switchHeight) / 2.0,
                                           switchWidth,
                                           switchHeight);

    CGFloat speakerY = rowHeight * 2;
    CGFloat valueWidth = 110.0;
    CGFloat speakerLabelWidth = width - valueWidth - labelLeft - controlRight;
    self.speakerTitleLabel.frame = CGRectMake(labelLeft, speakerY + 9.0, speakerLabelWidth, 18.0);
    self.speakerSubLabel.frame = CGRectMake(labelLeft, speakerY + 28.0, speakerLabelWidth, 16.0);
    self.speakerValueLabel.frame = CGRectMake(width - valueWidth - controlRight,
                                              speakerY + 9.0,
                                              valueWidth,
                                              22.0);
    self.speakerPresetsView.frame = CGRectMake(labelLeft,
                                               speakerY + 50.0,
                                               width - labelLeft - controlRight,
                                               36.0);
    [self layoutSpeakerPresets];
}

- (void)layoutSpeakerPresets {
    CGFloat contentWidth = CGRectGetWidth(self.speakerPresetsView.bounds);
    NSArray<UIButton *> *presetButtons = self.speakerPresetButtons;
    if (presetButtons.count == 0) {
        return;
    }
    CGFloat gap = 8.0;
    CGFloat buttonWidth = (contentWidth - gap * (presetButtons.count - 1)) / presetButtons.count;
    CGFloat buttonHeight = CGRectGetHeight(self.speakerPresetsView.bounds);
    for (NSUInteger i = 0; i < presetButtons.count; i++) {
        presetButtons[i].frame = CGRectMake((buttonWidth + gap) * i, 0, buttonWidth, buttonHeight);
        presetButtons[i].layer.cornerRadius = buttonHeight / 2.0;
    }
}

#pragma mark - 私有方法 - 状态刷新

/** 查询同传当前支持的完整音频路由 */
- (void)refreshAudioRouteCapabilities {
    id<TSAIAudioRoutingInterface> audioRouting =
        [TSAIKit sharedInstance].activeContext.audioRouting;
    self.audioRouteCapabilities =
        [audioRouting audioRouteCapabilitiesForFeature:TSAIFeatureInterpretation] ?: @[];
}

/** 刷新拾音和播放分段控件 */
- (void)refreshAudioRouteControls {
    TSAIAudioInputChannel inputChannel = self.audioRouteConfiguration.inputChannel;
    TSAIAudioOutputChannel outputChannel = self.audioRouteConfiguration.outputChannel;
    self.pickupSegmentControl.selectedSegmentIndex = [self segmentIndexForInputChannel:inputChannel];
    self.playbackSegmentControl.selectedSegmentIndex = [self segmentIndexForOutputChannel:outputChannel];

    self.pickupValueLabel.text = [NSString
        stringWithFormat:TSLocalizedString(@"ai_interpreter.route_current_fmt"),
                         [self titleForInputChannel:inputChannel]];
    self.playbackValueLabel.text = [NSString
        stringWithFormat:TSLocalizedString(@"ai_interpreter.route_current_fmt"),
                         [self titleForOutputChannel:outputChannel]];

    for (NSInteger segmentIndex = TSAIInterpreterRouteSegmentPhone;
         segmentIndex <= TSAIInterpreterRouteSegmentDevice;
         segmentIndex++) {
        [self.pickupSegmentControl setEnabled:[self hasAvailableInputForSegmentIndex:segmentIndex]
                                  forSegmentAtIndex:segmentIndex];
        [self.playbackSegmentControl setEnabled:[self hasAvailableOutputForSegmentIndex:segmentIndex]
                                    forSegmentAtIndex:segmentIndex];
    }
}

/** 判断指定拾音入口是否存在可用完整路由 */
- (BOOL)hasAvailableInputForSegmentIndex:(NSInteger)segmentIndex {
    TSAIAudioInputChannel inputChannel = [self inputChannelForSegmentIndex:segmentIndex];
    for (TSAIAudioRouteCapability *capability in self.audioRouteCapabilities) {
        if (capability.isAvailable &&
            capability.inputChannel == inputChannel &&
            [self capabilityProvidesRequiredPlayback:capability]) {
            return YES;
        }
    }
    return NO;
}

/** 判断指定播放出口是否存在可用完整路由 */
- (BOOL)hasAvailableOutputForSegmentIndex:(NSInteger)segmentIndex {
    for (TSAIAudioRouteCapability *capability in self.audioRouteCapabilities) {
        if (capability.isAvailable &&
            [self outputChannel:capability.outputChannel matchesSegmentIndex:segmentIndex]) {
            return YES;
        }
    }
    return NO;
}

/** 查找匹配输入和期望输出的可用完整路由 */
- (nullable TSAIAudioRouteCapability *)availableCapabilityForInputChannel:(TSAIAudioInputChannel)inputChannel
                                                            outputChannel:(TSAIAudioOutputChannel)outputChannel {
    TSAIAudioRouteCapability *fallbackCapability = nil;
    for (TSAIAudioRouteCapability *capability in self.audioRouteCapabilities) {
        if (!capability.isAvailable ||
            capability.inputChannel != inputChannel ||
            ![self capabilityProvidesRequiredPlayback:capability]) {
            continue;
        }
        if (capability.outputChannel == outputChannel ||
            ([self isEarphoneOutputChannel:capability.outputChannel] &&
             [self isEarphoneOutputChannel:outputChannel])) {
            return capability;
        }
        if (fallbackCapability == nil ||
            fallbackCapability.outputChannel == TSAIAudioOutputChannelNone) {
            fallbackCapability = capability;
        }
    }
    return fallbackCapability;
}

/** 查找匹配播放出口的可用完整路由 */
- (nullable TSAIAudioRouteCapability *)availableCapabilityForOutputSegmentIndex:(NSInteger)segmentIndex
                                                                  preferredInput:(TSAIAudioInputChannel)preferredInput {
    TSAIAudioRouteCapability *fallbackCapability = nil;
    for (TSAIAudioRouteCapability *capability in self.audioRouteCapabilities) {
        if (!capability.isAvailable ||
            ![self outputChannel:capability.outputChannel matchesSegmentIndex:segmentIndex]) {
            continue;
        }
        if (capability.inputChannel == preferredInput) {
            return capability;
        }
        if (fallbackCapability == nil) {
            fallbackCapability = capability;
        }
    }
    return fallbackCapability;
}

/** 判断完整路由是否满足当前播放开关 */
- (BOOL)capabilityProvidesRequiredPlayback:(TSAIAudioRouteCapability *)capability {
    BOOL requiresPlayback = self.enableVoiceOutput && self.autoPlayVoice;
    return !requiresPlayback || capability.outputChannel != TSAIAudioOutputChannelNone;
}

/** 使用完整可用路由更新当前选择 */
- (void)applyAudioRouteCapability:(TSAIAudioRouteCapability *)capability {
    self.audioRouteConfiguration =
        [TSAIAudioRouteConfiguration
            configurationWithInputChannel:capability.inputChannel
                              outputChannel:capability.outputChannel
                     routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyFail];
}

- (void)refreshAllRows {
    [self refreshAudioRouteControls];
    self.ttsSwitch.on = self.enableVoiceOutput;
    self.autoPlaySwitch.on = self.autoPlayVoice;

    self.autoPlaySwitch.enabled = self.enableVoiceOutput;
    self.autoPlaySwitch.alpha = self.enableVoiceOutput ? 1.0 : 0.45;
    BOOL enablesPlaybackSelection = self.enableVoiceOutput && self.autoPlayVoice;
    self.playbackSegmentControl.enabled = enablesPlaybackSelection;
    self.playbackSegmentControl.alpha = enablesPlaybackSelection ? 1.0 : 0.45;
    self.playbackTitleLabel.alpha = enablesPlaybackSelection ? 1.0 : 0.45;
    self.playbackValueLabel.alpha = enablesPlaybackSelection ? 1.0 : 0.45;

    NSString *currentSpeakerKey = self.speakerId.length > 0 ? self.speakerId : @"";
    NSString *valueText = self.speakerId.length > 0
        ? self.speakerId
        : TSLocalizedString(@"ai_interpreter.speaker_default");
    self.speakerValueLabel.text = valueText;
    self.speakerValueLabel.alpha = self.enableVoiceOutput ? 1.0 : 0.45;

    NSArray<NSString *> *presets = kInterpreterSpeakerPresets();
    for (NSUInteger i = 0; i < self.speakerPresetButtons.count; i++) {
        UIButton *presetButton = self.speakerPresetButtons[i];
        BOOL isDefault = (i == presets.count);
        BOOL active = isDefault
            ? (self.speakerId.length == 0)
            : [presets[i] isEqualToString:currentSpeakerKey];
        presetButton.selected = active;
        presetButton.enabled = self.enableVoiceOutput;
        presetButton.alpha = self.enableVoiceOutput ? 1.0 : 0.45;
        [self applyPresetButtonStyle:presetButton active:active];
    }
}

- (void)applyPresetButtonStyle:(UIButton *)button active:(BOOL)active {
    button.layer.borderWidth = 1.0;
    if (active) {
        button.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.10];
        button.layer.borderColor = [UIColor systemBlueColor].CGColor;
        [button setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    } else {
        button.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        button.layer.borderColor = [UIColor systemGray4Color].CGColor;
        [button setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    }
}

#pragma mark - 私有方法 - 事件

- (void)onTTSSwitchChanged:(UISwitch *)sender {
    self.enableVoiceOutput = sender.isOn;
    if (!sender.isOn) {
        self.autoPlayVoice = NO;
    }
    [self refreshAllRows];
}

- (void)onAutoPlaySwitchChanged:(UISwitch *)sender {
    self.autoPlayVoice = sender.isOn;
    if (sender.isOn &&
        self.audioRouteConfiguration.outputChannel == TSAIAudioOutputChannelNone) {
        TSAIAudioInputChannel inputChannel = self.audioRouteConfiguration.inputChannel;
        TSAIAudioRouteCapability *capability =
            [self availableCapabilityForInputChannel:inputChannel
                                       outputChannel:TSAIAudioOutputChannelAutomatic];
        self.audioRouteConfiguration = capability != nil
            ? [TSAIAudioRouteConfiguration
                configurationWithInputChannel:capability.inputChannel
                                  outputChannel:capability.outputChannel
                         routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyFail]
            : [TSAIAudioRouteConfiguration defaultConfiguration];
    }
    [self refreshAllRows];
}

/** 切换拾音入口并自动匹配可用的完整路由 */
- (void)onPickupSegmentChanged:(UISegmentedControl *)sender {
    NSInteger segmentIndex = sender.selectedSegmentIndex;
    TSAIAudioInputChannel inputChannel = [self inputChannelForSegmentIndex:segmentIndex];
    TSAIAudioOutputChannel outputChannel = self.audioRouteConfiguration.outputChannel;
    if (inputChannel == TSAIAudioInputChannelAutomatic) {
        self.audioRouteConfiguration =
            [TSAIAudioRouteConfiguration
                configurationWithInputChannel:TSAIAudioInputChannelAutomatic
                                  outputChannel:outputChannel
                         routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyUseAutomaticRoute];
        [self refreshAudioRouteControls];
        return;
    }

    TSAIAudioRouteCapability *capability =
        [self availableCapabilityForInputChannel:inputChannel
                                   outputChannel:outputChannel];
    if (capability != nil) {
        [self applyAudioRouteCapability:capability];
    }
    [self refreshAudioRouteControls];
}

/** 切换播放出口并自动匹配可用的完整路由 */
- (void)onPlaybackSegmentChanged:(UISegmentedControl *)sender {
    NSInteger segmentIndex = sender.selectedSegmentIndex;
    TSAIAudioInputChannel inputChannel = self.audioRouteConfiguration.inputChannel;
    if (segmentIndex == TSAIInterpreterRouteSegmentAutomatic) {
        self.audioRouteConfiguration =
            [TSAIAudioRouteConfiguration
                configurationWithInputChannel:inputChannel
                                  outputChannel:TSAIAudioOutputChannelAutomatic
                         routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyUseAutomaticRoute];
        [self refreshAudioRouteControls];
        return;
    }

    TSAIAudioRouteCapability *capability =
        [self availableCapabilityForOutputSegmentIndex:segmentIndex
                                        preferredInput:inputChannel];
    if (capability != nil) {
        [self applyAudioRouteCapability:capability];
    }
    [self refreshAudioRouteControls];
}

- (void)onSpeakerPresetTap:(UIButton *)sender {
    NSArray<NSString *> *presets = kInterpreterSpeakerPresets();
    NSUInteger presetIndex = [self.speakerPresetButtons indexOfObject:sender];
    if (presetIndex == NSNotFound) {
        return;
    }
    self.speakerId = (presetIndex < presets.count) ? presets[presetIndex] : nil;
    [self refreshAllRows];
}

- (void)onLogsClearTap {
    [self.logView clear];
}

- (void)onDoneTap {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 属性（懒加载）

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:13.0];
        _subtitleLabel.textColor = [UIColor secondaryLabelColor];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.text = TSLocalizedString(@"ai_interpreter.sheet_settings_subtitle");
    }
    return _subtitleLabel;
}

- (UILabel *)audioRouteSectionLabel {
    if (!_audioRouteSectionLabel) {
        _audioRouteSectionLabel = [self sectionLabelWithKey:@"ai_interpreter.section_audio_route"];
    }
    return _audioRouteSectionLabel;
}

- (UIView *)audioRouteCardView {
    if (!_audioRouteCardView) {
        _audioRouteCardView = [self settingsCard];
    }
    return _audioRouteCardView;
}

- (UILabel *)pickupTitleLabel {
    if (!_pickupTitleLabel) {
        _pickupTitleLabel = [self rowTitleLabel:@"ai_interpreter.setting_pickup"];
    }
    return _pickupTitleLabel;
}

- (UILabel *)pickupValueLabel {
    if (!_pickupValueLabel) {
        _pickupValueLabel = [self routeValueLabel];
    }
    return _pickupValueLabel;
}

- (UISegmentedControl *)pickupSegmentControl {
    if (!_pickupSegmentControl) {
        _pickupSegmentControl = [self routeSegmentControlWithAction:@selector(onPickupSegmentChanged:)];
    }
    return _pickupSegmentControl;
}

- (UILabel *)playbackTitleLabel {
    if (!_playbackTitleLabel) {
        _playbackTitleLabel = [self rowTitleLabel:@"ai_interpreter.setting_playback"];
    }
    return _playbackTitleLabel;
}

- (UILabel *)playbackValueLabel {
    if (!_playbackValueLabel) {
        _playbackValueLabel = [self routeValueLabel];
    }
    return _playbackValueLabel;
}

- (UISegmentedControl *)playbackSegmentControl {
    if (!_playbackSegmentControl) {
        _playbackSegmentControl = [self routeSegmentControlWithAction:@selector(onPlaybackSegmentChanged:)];
    }
    return _playbackSegmentControl;
}

- (UILabel *)voiceSectionLabel {
    if (!_voiceSectionLabel) {
        _voiceSectionLabel = [self sectionLabelWithKey:@"ai_interpreter.section_voice_output"];
    }
    return _voiceSectionLabel;
}

- (UIView *)voiceSettingsCardView {
    if (!_voiceSettingsCardView) {
        _voiceSettingsCardView = [self settingsCard];
    }
    return _voiceSettingsCardView;
}

- (UILabel *)ttsTitleLabel {
    if (!_ttsTitleLabel) {
        _ttsTitleLabel = [self rowTitleLabel:@"ai_interpreter.setting_tts"];
    }
    return _ttsTitleLabel;
}

- (UILabel *)ttsSubLabel {
    if (!_ttsSubLabel) {
        _ttsSubLabel = [self rowSubLabel:@"ai_interpreter.setting_tts_sub"];
    }
    return _ttsSubLabel;
}

- (UISwitch *)ttsSwitch {
    if (!_ttsSwitch) {
        _ttsSwitch = [[UISwitch alloc] init];
        [_ttsSwitch addTarget:self action:@selector(onTTSSwitchChanged:)
              forControlEvents:UIControlEventValueChanged];
    }
    return _ttsSwitch;
}

- (UILabel *)autoPlayTitleLabel {
    if (!_autoPlayTitleLabel) {
        _autoPlayTitleLabel = [self rowTitleLabel:@"ai_interpreter.setting_autoplay"];
    }
    return _autoPlayTitleLabel;
}

- (UILabel *)autoPlaySubLabel {
    if (!_autoPlaySubLabel) {
        _autoPlaySubLabel = [self rowSubLabel:@"ai_interpreter.setting_autoplay_sub"];
    }
    return _autoPlaySubLabel;
}

- (UISwitch *)autoPlaySwitch {
    if (!_autoPlaySwitch) {
        _autoPlaySwitch = [[UISwitch alloc] init];
        [_autoPlaySwitch addTarget:self action:@selector(onAutoPlaySwitchChanged:)
                   forControlEvents:UIControlEventValueChanged];
    }
    return _autoPlaySwitch;
}

- (UILabel *)speakerTitleLabel {
    if (!_speakerTitleLabel) {
        _speakerTitleLabel = [self rowTitleLabel:@"ai_interpreter.setting_speaker"];
    }
    return _speakerTitleLabel;
}

- (UILabel *)speakerSubLabel {
    if (!_speakerSubLabel) {
        _speakerSubLabel = [self rowSubLabel:@"ai_interpreter.setting_speaker_sub"];
    }
    return _speakerSubLabel;
}

- (UILabel *)speakerValueLabel {
    if (!_speakerValueLabel) {
        _speakerValueLabel = [[UILabel alloc] init];
        _speakerValueLabel.font = [UIFont monospacedSystemFontOfSize:14.0 weight:UIFontWeightMedium];
        _speakerValueLabel.textColor = [UIColor systemBlueColor];
        _speakerValueLabel.textAlignment = NSTextAlignmentRight;
    }
    return _speakerValueLabel;
}

- (UIView *)speakerPresetsView {
    if (!_speakerPresetsView) {
        _speakerPresetsView = [[UIView alloc] init];
    }
    return _speakerPresetsView;
}

- (NSArray<UIButton *> *)speakerPresetButtons {
    if (!_speakerPresetButtons) {
        NSMutableArray<UIButton *> *presetButtons = [NSMutableArray array];
        for (NSString *preset in kInterpreterSpeakerPresets()) {
            [presetButtons addObject:[self makePresetButtonWithTitle:preset]];
        }
        [presetButtons addObject:
            [self makePresetButtonWithTitle:TSLocalizedString(@"ai_interpreter.speaker_default")]];
        _speakerPresetButtons = [presetButtons copy];
    }
    return _speakerPresetButtons;
}

- (UIButton *)makePresetButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
    [button addTarget:self
               action:@selector(onSpeakerPresetTap:)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UILabel *)logsHeaderLabel {
    if (!_logsHeaderLabel) {
        _logsHeaderLabel = [[UILabel alloc] init];
        _logsHeaderLabel.font = [UIFont systemFontOfSize:11.0 weight:UIFontWeightSemibold];
        _logsHeaderLabel.textColor = [UIColor secondaryLabelColor];
        _logsHeaderLabel.text = TSLocalizedString(@"ai_interpreter.setting_logs_header");
    }
    return _logsHeaderLabel;
}

- (UIButton *)logsClearButton {
    if (!_logsClearButton) {
        _logsClearButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_logsClearButton setTitle:TSLocalizedString(@"general.clear") forState:UIControlStateNormal];
        _logsClearButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _logsClearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_logsClearButton addTarget:self action:@selector(onLogsClearTap)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    return _logsClearButton;
}

#pragma mark - 私有方法 - 工具

- (UILabel *)rowTitleLabel:(NSString *)key {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
    label.textColor = [UIColor labelColor];
    label.text = TSLocalizedString(key);
    return label;
}

- (UILabel *)rowSubLabel:(NSString *)key {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:11.0];
    label.textColor = [UIColor tertiaryLabelColor];
    label.text = TSLocalizedString(key);
    return label;
}

/** 创建分组标题 */
- (UILabel *)sectionLabelWithKey:(NSString *)key {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold];
    label.textColor = [UIColor secondaryLabelColor];
    label.text = TSLocalizedString(key);
    return label;
}

/** 创建设置卡片 */
- (UIView *)settingsCard {
    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    cardView.layer.cornerRadius = 12.0;
    return cardView;
}

/** 创建当前音频路由值标签 */
- (UILabel *)routeValueLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:11.0];
    label.textColor = [UIColor systemBlueColor];
    label.textAlignment = NSTextAlignmentRight;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.8;
    return label;
}

/** 创建音频路由分段控件 */
- (UISegmentedControl *)routeSegmentControlWithAction:(SEL)action {
    NSArray<NSString *> *titles = @[
        TSLocalizedString(@"ai_interpreter.route_auto"),
        TSLocalizedString(@"ai_interpreter.route_phone"),
        TSLocalizedString(@"ai_interpreter.route_earphone"),
        TSLocalizedString(@"ai_interpreter.route_device"),
    ];
    UISegmentedControl *segmentControl =
        [[UISegmentedControl alloc] initWithItems:titles];
    segmentControl.selectedSegmentIndex = TSAIInterpreterRouteSegmentAutomatic;
    [segmentControl addTarget:self
                       action:action
             forControlEvents:UIControlEventValueChanged];
    [segmentControl setTitleTextAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium]
    } forState:UIControlStateNormal];
    if (@available(iOS 13.0, *)) {
        segmentControl.selectedSegmentTintColor =
            [[UIColor systemBlueColor] colorWithAlphaComponent:0.12];
    }
    return segmentControl;
}

/** 返回分段位置对应的输入通道 */
- (TSAIAudioInputChannel)inputChannelForSegmentIndex:(NSInteger)segmentIndex {
    switch (segmentIndex) {
        case TSAIInterpreterRouteSegmentPhone:
            return TSAIAudioInputChannelBuiltInMic;
        case TSAIInterpreterRouteSegmentEarphone:
            return TSAIAudioInputChannelSCO;
        case TSAIInterpreterRouteSegmentDevice:
            return TSAIAudioInputChannelOpus;
        case TSAIInterpreterRouteSegmentAutomatic:
        default:
            return TSAIAudioInputChannelAutomatic;
    }
}

/** 返回输入通道对应的分段位置 */
- (NSInteger)segmentIndexForInputChannel:(TSAIAudioInputChannel)inputChannel {
    switch (inputChannel) {
        case TSAIAudioInputChannelBuiltInMic:
            return TSAIInterpreterRouteSegmentPhone;
        case TSAIAudioInputChannelSCO:
            return TSAIInterpreterRouteSegmentEarphone;
        case TSAIAudioInputChannelOpus:
            return TSAIInterpreterRouteSegmentDevice;
        case TSAIAudioInputChannelAutomatic:
        case TSAIAudioInputChannelUnknown:
        default:
            return TSAIInterpreterRouteSegmentAutomatic;
    }
}

/** 返回输出通道对应的分段位置 */
- (NSInteger)segmentIndexForOutputChannel:(TSAIAudioOutputChannel)outputChannel {
    switch (outputChannel) {
        case TSAIAudioOutputChannelBuiltInSpeaker:
            return TSAIInterpreterRouteSegmentPhone;
        case TSAIAudioOutputChannelSCO:
        case TSAIAudioOutputChannelA2DP:
            return TSAIInterpreterRouteSegmentEarphone;
        case TSAIAudioOutputChannelOpus:
            return TSAIInterpreterRouteSegmentDevice;
        case TSAIAudioOutputChannelNone:
        case TSAIAudioOutputChannelAutomatic:
        case TSAIAudioOutputChannelUnknown:
        default:
            return TSAIInterpreterRouteSegmentAutomatic;
    }
}

/** 判断输出通道是否属于蓝牙耳机 */
- (BOOL)isEarphoneOutputChannel:(TSAIAudioOutputChannel)outputChannel {
    return outputChannel == TSAIAudioOutputChannelSCO ||
        outputChannel == TSAIAudioOutputChannelA2DP;
}

/** 判断输出通道是否对应指定分段位置 */
- (BOOL)outputChannel:(TSAIAudioOutputChannel)outputChannel
    matchesSegmentIndex:(NSInteger)segmentIndex {
    switch (segmentIndex) {
        case TSAIInterpreterRouteSegmentPhone:
            return outputChannel == TSAIAudioOutputChannelBuiltInSpeaker;
        case TSAIInterpreterRouteSegmentEarphone:
            return [self isEarphoneOutputChannel:outputChannel];
        case TSAIInterpreterRouteSegmentDevice:
            return outputChannel == TSAIAudioOutputChannelOpus;
        case TSAIInterpreterRouteSegmentAutomatic:
        default:
            return outputChannel == TSAIAudioOutputChannelAutomatic;
    }
}

/** 返回输入通道显示名称 */
- (NSString *)titleForInputChannel:(TSAIAudioInputChannel)inputChannel {
    switch (inputChannel) {
        case TSAIAudioInputChannelBuiltInMic:
            return TSLocalizedString(@"ai_interpreter.route_phone_microphone");
        case TSAIAudioInputChannelSCO:
            return TSLocalizedString(@"ai_interpreter.route_earphone_microphone");
        case TSAIAudioInputChannelOpus:
            return TSLocalizedString(@"ai_interpreter.route_device_microphone");
        case TSAIAudioInputChannelAutomatic:
        case TSAIAudioInputChannelUnknown:
        default:
            return TSLocalizedString(@"ai_interpreter.route_automatic");
    }
}

/** 返回输出通道显示名称 */
- (NSString *)titleForOutputChannel:(TSAIAudioOutputChannel)outputChannel {
    switch (outputChannel) {
        case TSAIAudioOutputChannelBuiltInSpeaker:
            return TSLocalizedString(@"ai_interpreter.route_phone_speaker");
        case TSAIAudioOutputChannelSCO:
        case TSAIAudioOutputChannelA2DP:
            return TSLocalizedString(@"ai_interpreter.route_earphone_speaker");
        case TSAIAudioOutputChannelOpus:
            return TSLocalizedString(@"ai_interpreter.route_device_speaker");
        case TSAIAudioOutputChannelNone:
            return TSLocalizedString(@"ai_interpreter.route_no_playback");
        case TSAIAudioOutputChannelAutomatic:
        case TSAIAudioOutputChannelUnknown:
        default:
            return TSLocalizedString(@"ai_interpreter.route_automatic");
    }
}

@end
