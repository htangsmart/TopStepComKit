//
//  TSAIInterpreterSettingsVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterSettingsVC.h"

#import "TSAILogView.h"
#import "TSRootVC.h"

static NSArray<NSString *> *kInterpreterSpeakerPresets(void) {
    return @[ @"xiaogang", @"xiaomei", @"xiaoyu" ];
}

@interface TSAIInterpreterSettingsVC ()

#pragma mark - 视图
/// 副标题
@property (nonatomic, strong) UILabel *subtitleLabel;
/// 设置卡片容器
@property (nonatomic, strong) UIView *settingsCardView;
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
@property (nonatomic, assign) BOOL enableVoiceOutput;
@property (nonatomic, assign) BOOL autoPlayVoice;
@property (nonatomic, copy, nullable) NSString *speakerId;

@end

@implementation TSAIInterpreterSettingsVC

#pragma mark - 生命周期

- (instancetype)initWithEnableVoiceOutput:(BOOL)enableVoiceOutput
                             autoPlayVoice:(BOOL)autoPlayVoice
                                 speakerId:(NSString *)speakerId
                                   logView:(TSAILogView *)logView {
    self = [super init];
    if (self) {
        _enableVoiceOutput = enableVoiceOutput;
        _autoPlayVoice = autoPlayVoice;
        _speakerId = [speakerId copy];
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
    if (self.isBeingDismissed) {
        if (self.onDismiss) self.onDismiss();
    }
}

#pragma mark - 私有方法 - 视图搭建 / 布局

- (void)setupViews {
    [self.view addSubview:self.subtitleLabel];

    [self.view addSubview:self.settingsCardView];
    [self.settingsCardView addSubview:self.ttsTitleLabel];
    [self.settingsCardView addSubview:self.ttsSubLabel];
    [self.settingsCardView addSubview:self.ttsSwitch];
    [self.settingsCardView addSubview:self.autoPlayTitleLabel];
    [self.settingsCardView addSubview:self.autoPlaySubLabel];
    [self.settingsCardView addSubview:self.autoPlaySwitch];
    [self.settingsCardView addSubview:self.speakerTitleLabel];
    [self.settingsCardView addSubview:self.speakerSubLabel];
    [self.settingsCardView addSubview:self.speakerValueLabel];

    [self.view addSubview:self.speakerPresetsView];
    for (UIButton *btn in self.speakerPresetButtons) {
        [self.speakerPresetsView addSubview:btn];
    }

    [self.view addSubview:self.logsHeaderLabel];
    [self.view addSubview:self.logsClearButton];
    if (self.logView) [self.view addSubview:self.logView];
}

- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat side = 20.0;
    CGFloat innerW = width - side * 2;

    CGFloat y = self.view.safeAreaInsets.top + 12.0;
    CGSize subSize = [self.subtitleLabel sizeThatFits:CGSizeMake(innerW, CGFLOAT_MAX)];
    self.subtitleLabel.frame = CGRectMake(side, y, innerW, subSize.height);
    y += subSize.height + 16.0;

    CGFloat rowH = 56.0;
    CGFloat cardH = rowH * 3;
    self.settingsCardView.frame = CGRectMake(side, y, innerW, cardH);
    [self layoutSettingsCard];
    y += cardH + 10.0;

    CGFloat presetsH = 36.0;
    self.speakerPresetsView.frame = CGRectMake(side, y, innerW, presetsH);
    [self layoutSpeakerPresets];
    y += presetsH + 22.0;

    CGFloat headerH = 18.0;
    self.logsHeaderLabel.frame = CGRectMake(side + 4.0, y, innerW - 60.0, headerH);
    self.logsClearButton.frame = CGRectMake(width - side - 60.0, y - 4.0, 60.0, headerH + 8.0);
    y += headerH + 8.0;

    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    CGFloat logBottom = height - bottomInset - 16.0;
    self.logView.frame = CGRectMake(side, y, innerW, MAX(80.0, logBottom - y));
}

- (void)layoutSettingsCard {
    CGFloat innerW = CGRectGetWidth(self.settingsCardView.bounds);
    CGFloat rowH = 56.0;
    CGFloat labelLeft = 16.0;
    CGFloat ctrlRight = 16.0;
    CGFloat switchW = 51.0;
    CGFloat switchH = 31.0;
    CGFloat labelW = innerW - switchW - labelLeft - ctrlRight;

    self.ttsTitleLabel.frame = CGRectMake(labelLeft, 10.0, labelW, 18.0);
    self.ttsSubLabel.frame = CGRectMake(labelLeft, 30.0, labelW, 16.0);
    self.ttsSwitch.frame = CGRectMake(innerW - switchW - ctrlRight,
                                        (rowH - switchH) / 2.0,
                                        switchW, switchH);

    CGFloat row2Y = rowH;
    self.autoPlayTitleLabel.frame = CGRectMake(labelLeft, row2Y + 10.0, labelW, 18.0);
    self.autoPlaySubLabel.frame = CGRectMake(labelLeft, row2Y + 30.0, labelW, 16.0);
    self.autoPlaySwitch.frame = CGRectMake(innerW - switchW - ctrlRight,
                                             row2Y + (rowH - switchH) / 2.0,
                                             switchW, switchH);

    CGFloat row3Y = rowH * 2;
    CGFloat valueW = 110.0;
    CGFloat speakerLabelW = innerW - valueW - labelLeft - ctrlRight;
    self.speakerTitleLabel.frame = CGRectMake(labelLeft, row3Y + 10.0, speakerLabelW, 18.0);
    self.speakerSubLabel.frame = CGRectMake(labelLeft, row3Y + 30.0, speakerLabelW, 16.0);
    self.speakerValueLabel.frame = CGRectMake(innerW - valueW - ctrlRight,
                                                 row3Y + (rowH - 22.0) / 2.0,
                                                 valueW, 22.0);
}

- (void)layoutSpeakerPresets {
    CGFloat innerW = CGRectGetWidth(self.speakerPresetsView.bounds);
    NSArray<UIButton *> *btns = self.speakerPresetButtons;
    if (btns.count == 0) return;
    CGFloat gap = 8.0;
    CGFloat btnW = (innerW - gap * (btns.count - 1)) / btns.count;
    CGFloat btnH = CGRectGetHeight(self.speakerPresetsView.bounds);
    for (NSUInteger i = 0; i < btns.count; i++) {
        btns[i].frame = CGRectMake((btnW + gap) * i, 0, btnW, btnH);
        btns[i].layer.cornerRadius = btnH / 2.0;
    }
}

#pragma mark - 私有方法 - 状态刷新

- (void)refreshAllRows {
    self.ttsSwitch.on = self.enableVoiceOutput;
    self.autoPlaySwitch.on = self.autoPlayVoice;

    self.autoPlaySwitch.enabled = self.enableVoiceOutput;
    self.autoPlaySwitch.alpha = self.enableVoiceOutput ? 1.0 : 0.45;

    NSString *currentSpeakerKey = self.speakerId.length > 0 ? self.speakerId : @"";
    NSString *valueText = self.speakerId.length > 0
        ? self.speakerId
        : TSLocalizedString(@"ai_interpreter.speaker_default");
    self.speakerValueLabel.text = valueText;
    self.speakerValueLabel.alpha = self.enableVoiceOutput ? 1.0 : 0.45;

    NSArray<NSString *> *presets = kInterpreterSpeakerPresets();
    for (NSUInteger i = 0; i < self.speakerPresetButtons.count; i++) {
        UIButton *btn = self.speakerPresetButtons[i];
        BOOL isDefault = (i == presets.count);
        BOOL active = isDefault
            ? (self.speakerId.length == 0)
            : [presets[i] isEqualToString:currentSpeakerKey];
        btn.selected = active;
        btn.enabled = self.enableVoiceOutput;
        btn.alpha = self.enableVoiceOutput ? 1.0 : 0.45;
        [self applyPresetButtonStyle:btn active:active];
    }
}

- (void)applyPresetButtonStyle:(UIButton *)btn active:(BOOL)active {
    btn.layer.borderWidth = 1.0;
    if (active) {
        btn.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.10];
        btn.layer.borderColor = [UIColor systemBlueColor].CGColor;
        [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    } else {
        btn.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        btn.layer.borderColor = [UIColor systemGray4Color].CGColor;
        [btn setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    }
}

#pragma mark - 私有方法 - 事件

- (void)onTTSSwitchChanged:(UISwitch *)sender {
    self.enableVoiceOutput = sender.isOn;
    if (!sender.isOn) self.autoPlayVoice = NO;
    [self refreshAllRows];
}

- (void)onAutoPlaySwitchChanged:(UISwitch *)sender {
    self.autoPlayVoice = sender.isOn;
}

- (void)onSpeakerPresetTap:(UIButton *)sender {
    NSArray<NSString *> *presets = kInterpreterSpeakerPresets();
    NSUInteger idx = [self.speakerPresetButtons indexOfObject:sender];
    if (idx == NSNotFound) return;
    self.speakerId = (idx < presets.count) ? presets[idx] : nil;
    [self refreshAllRows];
}

- (void)onLogsClearTap {
    [self.logView clear];
}

- (void)onDoneTap {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 属性（懒加载）

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

- (UIView *)settingsCardView {
    if (!_settingsCardView) {
        _settingsCardView = [[UIView alloc] init];
        _settingsCardView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        _settingsCardView.layer.cornerRadius = 12.0;
    }
    return _settingsCardView;
}

- (UILabel *)ttsTitleLabel {
    if (!_ttsTitleLabel) _ttsTitleLabel = [self rowTitleLabel:@"ai_interpreter.setting_tts"];
    return _ttsTitleLabel;
}

- (UILabel *)ttsSubLabel {
    if (!_ttsSubLabel) _ttsSubLabel = [self rowSubLabel:@"ai_interpreter.setting_tts_sub"];
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
    if (!_autoPlayTitleLabel) _autoPlayTitleLabel = [self rowTitleLabel:@"ai_interpreter.setting_autoplay"];
    return _autoPlayTitleLabel;
}

- (UILabel *)autoPlaySubLabel {
    if (!_autoPlaySubLabel) _autoPlaySubLabel = [self rowSubLabel:@"ai_interpreter.setting_autoplay_sub"];
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
    if (!_speakerTitleLabel) _speakerTitleLabel = [self rowTitleLabel:@"ai_interpreter.setting_speaker"];
    return _speakerTitleLabel;
}

- (UILabel *)speakerSubLabel {
    if (!_speakerSubLabel) _speakerSubLabel = [self rowSubLabel:@"ai_interpreter.setting_speaker_sub"];
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
    if (!_speakerPresetsView) _speakerPresetsView = [[UIView alloc] init];
    return _speakerPresetsView;
}

- (NSArray<UIButton *> *)speakerPresetButtons {
    if (!_speakerPresetButtons) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSString *preset in kInterpreterSpeakerPresets()) {
            [arr addObject:[self makePresetButtonWithTitle:preset]];
        }
        [arr addObject:[self makePresetButtonWithTitle:TSLocalizedString(@"ai_interpreter.speaker_default")]];
        _speakerPresetButtons = [arr copy];
    }
    return _speakerPresetButtons;
}

- (UIButton *)makePresetButtonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
    [btn addTarget:self action:@selector(onSpeakerPresetTap:)
   forControlEvents:UIControlEventTouchUpInside];
    return btn;
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

@end
