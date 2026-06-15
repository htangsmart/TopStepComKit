//
//  TSAIChatConfigSheet.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatConfigSheet.h"

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

#import "TSRootVC.h"
#import "TSAIChatAgentSelector.h"

/// 内置智能体预设
static NSArray<TSAIChatAgentEntry *> *TSAIChatBuiltInAgents(void) {
    static NSArray<TSAIChatAgentEntry *> *list = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        list = @[
            [TSAIChatAgentEntry entryWithAgentId:@"ZNT002"
                                       speakerId:@"zh_female_tianmeitaozi_mars_bigtts"
                                     displayName:@"🇨🇳 中文助手"],
            [TSAIChatAgentEntry entryWithAgentId:@"ZNT005"
                                       speakerId:@"zh_female_tianmeitaozi_mars_bigtts"
                                     displayName:@"🇺🇸 English"],
        ];
    });
    return list;
}

@interface TSAIChatConfigSheet () <UITextFieldDelegate, UITextViewDelegate, TSAIChatAgentSelectorDelegate>

@property (nonatomic, strong) TSAIChatConfig *editingConfig;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView  *formStack;

@property (nonatomic, strong) UISegmentedControl     *languageSegment;
@property (nonatomic, strong) TSAIChatAgentSelector  *agentSelector;
@property (nonatomic, strong) NSMutableArray<TSAIChatAgentEntry *> *customAgents;
@property (nonatomic, strong) UITextView         *promptTextView;
@property (nonatomic, strong) UILabel            *promptPlaceholder;
@property (nonatomic, strong) UISwitch           *voiceSwitch;
@property (nonatomic, strong) UISwitch           *interruptSwitch;
@property (nonatomic, strong) UISlider           *silenceSlider;
@property (nonatomic, strong) UILabel            *silenceValueLabel;
@property (nonatomic, strong) UISlider           *timeoutSlider;
@property (nonatomic, strong) UILabel            *timeoutValueLabel;

@property (nonatomic, strong) UIButton *applyButton;
@property (nonatomic, strong) UIButton *resetButton;

@end

@implementation TSAIChatConfigSheet

#pragma mark - 生命周期

- (instancetype)initWithConfig:(TSAIChatConfig *)config {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _editingConfig = [self snapshotFromConfig:config ?: [TSAIChatConfig defaultConfig]];
        _customAgents  = [NSMutableArray array];
        if (@available(iOS 13.0, *)) {
            self.modalPresentationStyle = UIModalPresentationPageSheet;
        } else {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TSColor_Background;
    self.title = @"会话配置";

    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                            target:self
                                                                                            action:@selector(onCancelTapped)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"应用"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(onApplyTapped)];

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.formStack];

    [self buildFormRows];
    [self setupLayoutConstraints];
    [self syncFormFromConfig];
}

#pragma mark - 公开方法 / 无

#pragma mark - 私有方法

/// AutoLayout 约束
- (void)setupLayoutConstraints {
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.formStack.translatesAutoresizingMaskIntoConstraints  = NO;

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor      constraintEqualToAnchor:safeArea.topAnchor],
        [self.scrollView.leadingAnchor  constraintEqualToAnchor:safeArea.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [self.scrollView.bottomAnchor   constraintEqualToAnchor:safeArea.bottomAnchor],

        [self.formStack.topAnchor      constraintEqualToAnchor:self.scrollView.topAnchor      constant:TSSpacing_MD],
        [self.formStack.leadingAnchor  constraintEqualToAnchor:self.scrollView.leadingAnchor  constant:TSSpacing_MD],
        [self.formStack.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-TSSpacing_MD],
        [self.formStack.bottomAnchor   constraintEqualToAnchor:self.scrollView.bottomAnchor   constant:-TSSpacing_MD],
        [self.formStack.widthAnchor    constraintEqualToAnchor:self.scrollView.widthAnchor    constant:-TSSpacing_MD * 2],
    ]];
}

/// 拼装表单行
- (void)buildFormRows {
    [self.formStack addArrangedSubview:[self rowWithTitle:@"languageHint" detail:@"BCP-47 语言提示"
                                                  control:self.languageSegment]];
    [self.formStack addArrangedSubview:self.agentSelector];
    [self.formStack addArrangedSubview:[self promptRow]];
    [self.formStack addArrangedSubview:[self switchRowWithTitle:@"enableVoiceOutput"
                                                         detail:@"是否产出 TTS 音频"
                                                       theSwitch:self.voiceSwitch]];
    [self.formStack addArrangedSubview:[self switchRowWithTitle:@"allowUserInterrupt"
                                                         detail:@"是否允许说话打断 AI 播放"
                                                       theSwitch:self.interruptSwitch]];
    [self.formStack addArrangedSubview:[self sliderRowWithTitle:@"silenceBeforeReplyInterval"
                                                         detail:@"VAD 静默阈值（秒）"
                                                         slider:self.silenceSlider
                                                     valueLabel:self.silenceValueLabel]];
    [self.formStack addArrangedSubview:[self sliderRowWithTitle:@"autoEndSessionTimeout"
                                                         detail:@"无输入超时（秒）"
                                                         slider:self.timeoutSlider
                                                     valueLabel:self.timeoutValueLabel]];
}

/// 通用行：标题 + 副标题 + 自定义控件
- (UIView *)rowWithTitle:(NSString *)title detail:(NSString *)detail control:(UIView *)control {
    UIView *row = [[UIView alloc] init];
    row.backgroundColor = TSColor_Card;
    row.layer.cornerRadius = TSRadius_MD;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = TSFont_H2;
    titleLabel.textColor = TSColor_TextPrimary;
    titleLabel.text = title;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:titleLabel];

    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.font = TSFont_Caption;
    detailLabel.textColor = TSColor_TextSecondary;
    detailLabel.text = detail;
    detailLabel.numberOfLines = 0;
    detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:detailLabel];

    control.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:control];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor      constraintEqualToAnchor:row.topAnchor      constant:TSSpacing_SM + 2.f],
        [titleLabel.leadingAnchor  constraintEqualToAnchor:row.leadingAnchor  constant:TSSpacing_MD],
        [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:row.trailingAnchor constant:-TSSpacing_MD],

        [detailLabel.topAnchor      constraintEqualToAnchor:titleLabel.bottomAnchor constant:2.f],
        [detailLabel.leadingAnchor  constraintEqualToAnchor:titleLabel.leadingAnchor],
        [detailLabel.trailingAnchor constraintLessThanOrEqualToAnchor:row.trailingAnchor constant:-TSSpacing_MD],

        [control.topAnchor      constraintEqualToAnchor:detailLabel.bottomAnchor constant:TSSpacing_SM],
        [control.leadingAnchor  constraintEqualToAnchor:row.leadingAnchor  constant:TSSpacing_MD],
        [control.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-TSSpacing_MD],
        [control.bottomAnchor   constraintEqualToAnchor:row.bottomAnchor   constant:-TSSpacing_SM - 2.f],
    ]];

    return row;
}

/// Switch 行：控件靠右
- (UIView *)switchRowWithTitle:(NSString *)title detail:(NSString *)detail theSwitch:(UISwitch *)theSwitch {
    UIView *row = [[UIView alloc] init];
    row.backgroundColor = TSColor_Card;
    row.layer.cornerRadius = TSRadius_MD;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = TSFont_H2;
    titleLabel.textColor = TSColor_TextPrimary;
    titleLabel.text = title;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:titleLabel];

    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.font = TSFont_Caption;
    detailLabel.textColor = TSColor_TextSecondary;
    detailLabel.text = detail;
    detailLabel.numberOfLines = 0;
    detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:detailLabel];

    theSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    theSwitch.onTintColor = TSColor_Primary;
    [row addSubview:theSwitch];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor      constraintEqualToAnchor:row.topAnchor      constant:TSSpacing_SM + 2.f],
        [titleLabel.leadingAnchor  constraintEqualToAnchor:row.leadingAnchor  constant:TSSpacing_MD],
        [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:theSwitch.leadingAnchor constant:-TSSpacing_SM],

        [detailLabel.topAnchor      constraintEqualToAnchor:titleLabel.bottomAnchor constant:2.f],
        [detailLabel.leadingAnchor  constraintEqualToAnchor:titleLabel.leadingAnchor],
        [detailLabel.trailingAnchor constraintLessThanOrEqualToAnchor:theSwitch.leadingAnchor constant:-TSSpacing_SM],
        [detailLabel.bottomAnchor   constraintEqualToAnchor:row.bottomAnchor   constant:-TSSpacing_SM - 2.f],

        [theSwitch.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [theSwitch.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-TSSpacing_MD],
    ]];

    return row;
}

/// Slider 行：滑杆 + 当前值
- (UIView *)sliderRowWithTitle:(NSString *)title
                        detail:(NSString *)detail
                        slider:(UISlider *)slider
                    valueLabel:(UILabel *)valueLabel {
    UIView *row = [[UIView alloc] init];
    row.backgroundColor = TSColor_Card;
    row.layer.cornerRadius = TSRadius_MD;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = TSFont_H2;
    titleLabel.textColor = TSColor_TextPrimary;
    titleLabel.text = title;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:titleLabel];

    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.font = TSFont_Caption;
    detailLabel.textColor = TSColor_TextSecondary;
    detailLabel.text = detail;
    detailLabel.numberOfLines = 0;
    detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:detailLabel];

    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    valueLabel.font = TSFont_Caption;
    valueLabel.textColor = TSColor_Primary;
    valueLabel.textAlignment = NSTextAlignmentRight;
    [row addSubview:valueLabel];

    slider.translatesAutoresizingMaskIntoConstraints = NO;
    slider.minimumTrackTintColor = TSColor_Primary;
    [row addSubview:slider];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor      constraintEqualToAnchor:row.topAnchor      constant:TSSpacing_SM + 2.f],
        [titleLabel.leadingAnchor  constraintEqualToAnchor:row.leadingAnchor  constant:TSSpacing_MD],
        [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:valueLabel.leadingAnchor constant:-TSSpacing_SM],

        [valueLabel.centerYAnchor  constraintEqualToAnchor:titleLabel.centerYAnchor],
        [valueLabel.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-TSSpacing_MD],
        [valueLabel.widthAnchor    constraintGreaterThanOrEqualToConstant:60.f],

        [detailLabel.topAnchor      constraintEqualToAnchor:titleLabel.bottomAnchor constant:2.f],
        [detailLabel.leadingAnchor  constraintEqualToAnchor:titleLabel.leadingAnchor],
        [detailLabel.trailingAnchor constraintLessThanOrEqualToAnchor:row.trailingAnchor constant:-TSSpacing_MD],

        [slider.topAnchor      constraintEqualToAnchor:detailLabel.bottomAnchor constant:TSSpacing_SM],
        [slider.leadingAnchor  constraintEqualToAnchor:row.leadingAnchor  constant:TSSpacing_MD],
        [slider.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-TSSpacing_MD],
        [slider.bottomAnchor   constraintEqualToAnchor:row.bottomAnchor   constant:-TSSpacing_SM],
    ]];

    return row;
}

/// 多行 Prompt 行：UITextView + 占位符
- (UIView *)promptRow {
    UIView *row = [[UIView alloc] init];
    row.backgroundColor = TSColor_Card;
    row.layer.cornerRadius = TSRadius_MD;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = TSFont_H2;
    titleLabel.textColor = TSColor_TextPrimary;
    titleLabel.text = @"initialPrompt";
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:titleLabel];

    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.font = TSFont_Caption;
    detailLabel.textColor = TSColor_TextSecondary;
    detailLabel.text = @"AI 角色初始上下文";
    detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:detailLabel];

    self.promptTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:self.promptTextView];
    self.promptPlaceholder.translatesAutoresizingMaskIntoConstraints = NO;
    [self.promptTextView addSubview:self.promptPlaceholder];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor      constraintEqualToAnchor:row.topAnchor      constant:TSSpacing_SM + 2.f],
        [titleLabel.leadingAnchor  constraintEqualToAnchor:row.leadingAnchor  constant:TSSpacing_MD],
        [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:row.trailingAnchor constant:-TSSpacing_MD],

        [detailLabel.topAnchor      constraintEqualToAnchor:titleLabel.bottomAnchor constant:2.f],
        [detailLabel.leadingAnchor  constraintEqualToAnchor:titleLabel.leadingAnchor],
        [detailLabel.trailingAnchor constraintLessThanOrEqualToAnchor:row.trailingAnchor constant:-TSSpacing_MD],

        [self.promptTextView.topAnchor      constraintEqualToAnchor:detailLabel.bottomAnchor constant:TSSpacing_SM],
        [self.promptTextView.leadingAnchor  constraintEqualToAnchor:row.leadingAnchor  constant:TSSpacing_MD],
        [self.promptTextView.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-TSSpacing_MD],
        [self.promptTextView.heightAnchor   constraintEqualToConstant:80.f],
        [self.promptTextView.bottomAnchor   constraintEqualToAnchor:row.bottomAnchor   constant:-TSSpacing_SM - 2.f],

        [self.promptPlaceholder.topAnchor      constraintEqualToAnchor:self.promptTextView.topAnchor      constant:6.f],
        [self.promptPlaceholder.leadingAnchor  constraintEqualToAnchor:self.promptTextView.leadingAnchor  constant:5.f],
        [self.promptPlaceholder.trailingAnchor constraintEqualToAnchor:self.promptTextView.trailingAnchor constant:-5.f],
    ]];

    return row;
}

/// 把 editingConfig 同步到表单控件
- (void)syncFormFromConfig {
    NSArray *langValues = @[@"", @"zh-CN", @"en-US", @"ja-JP"];
    NSUInteger langIndex = 0;
    NSString *current = self.editingConfig.languageHint ?: @"";
    NSUInteger idx = [langValues indexOfObject:current];
    if (idx != NSNotFound) langIndex = idx;
    self.languageSegment.selectedSegmentIndex = (NSInteger)langIndex;

    [self syncAgentSelectorFromConfig];

    self.promptTextView.text = self.editingConfig.initialPrompt;
    self.promptPlaceholder.hidden = (self.promptTextView.text.length > 0);

    self.voiceSwitch.on     = self.editingConfig.enableVoiceOutput;
    self.interruptSwitch.on = self.editingConfig.allowUserInterrupt;

    self.silenceSlider.value = (float)self.editingConfig.silenceBeforeReplyInterval;
    self.timeoutSlider.value = (float)self.editingConfig.autoEndSessionTimeout;
    [self updateSilenceValueLabel];
    [self updateTimeoutValueLabel];
}

/// 反查 editingConfig 对应的 entry；不在预设里则作为自定义追加并选中
- (void)syncAgentSelectorFromConfig {
    NSString *agentId   = self.editingConfig.agentId ?: @"";
    NSString *speakerId = self.editingConfig.speakerId ?: @"";

    TSAIChatAgentEntry *matched = nil;
    NSArray<TSAIChatAgentEntry *> *merged = [self mergedAgentEntries];
    for (TSAIChatAgentEntry *entry in merged) {
        if ([entry.agentId isEqualToString:agentId]
            && [entry.speakerId isEqualToString:speakerId]) {
            matched = entry;
            break;
        }
    }

    // config 里没有 agentId 时，默认选中第一个预设
    if (!matched && agentId.length == 0) {
        matched = TSAIChatBuiltInAgents().firstObject;
        if (matched) {
            self.editingConfig.agentId   = matched.agentId;
            self.editingConfig.speakerId = matched.speakerId;
        }
    }

    // 有 agentId 但不在预设里 → 自动追加为自定义并选中
    if (!matched && agentId.length > 0) {
        matched = [TSAIChatAgentEntry entryWithAgentId:agentId
                                             speakerId:speakerId
                                           displayName:@"⭐ 自定义"];
        [self.customAgents addObject:matched];
    }

    [self.agentSelector setEntries:[self mergedAgentEntries]];
    [self.agentSelector setSelectedEntry:matched];
}

/// 预设 + 自定义合并
- (NSArray<TSAIChatAgentEntry *> *)mergedAgentEntries {
    NSMutableArray *all = [NSMutableArray arrayWithArray:TSAIChatBuiltInAgents()];
    [all addObjectsFromArray:self.customAgents];
    return [all copy];
}

/// 把表单控件回写到 editingConfig
- (TSAIChatConfig *)snapshotFromForm {
    TSAIChatConfig *cfg = [TSAIChatConfig defaultConfig];
    NSArray *langValues = @[@"", @"zh-CN", @"en-US", @"ja-JP"];
    NSInteger li = self.languageSegment.selectedSegmentIndex;
    NSString *lang = (li >= 0 && li < (NSInteger)langValues.count) ? langValues[li] : @"";
    cfg.languageHint = lang.length > 0 ? lang : nil;
    TSAIChatAgentEntry *entry = self.agentSelector.selectedEntry;
    cfg.agentId   = entry.agentId.length   > 0 ? entry.agentId   : nil;
    cfg.speakerId = entry.speakerId.length > 0 ? entry.speakerId : nil;
    cfg.initialPrompt = [self trimmedText:self.promptTextView.text];
    cfg.enableVoiceOutput  = self.voiceSwitch.on;
    cfg.allowUserInterrupt = self.interruptSwitch.on;
    cfg.silenceBeforeReplyInterval = self.silenceSlider.value;
    cfg.autoEndSessionTimeout      = self.timeoutSlider.value;
    return cfg;
}

/// 拷贝出可编辑的快照（避免直接持有外部传入对象）
- (TSAIChatConfig *)snapshotFromConfig:(TSAIChatConfig *)src {
    TSAIChatConfig *cfg = [TSAIChatConfig defaultConfig];
    cfg.languageHint  = src.languageHint;
    cfg.agentId       = src.agentId;
    cfg.speakerId     = src.speakerId;
    cfg.initialPrompt = src.initialPrompt;
    cfg.enableVoiceOutput  = src.enableVoiceOutput;
    cfg.allowUserInterrupt = src.allowUserInterrupt;
    cfg.silenceBeforeReplyInterval = src.silenceBeforeReplyInterval;
    cfg.autoEndSessionTimeout      = src.autoEndSessionTimeout;
    return cfg;
}

/// trim 后空字符串返回 nil
- (nullable NSString *)trimmedText:(nullable NSString *)text {
    NSString *out = [(text ?: @"") stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return out.length > 0 ? out : nil;
}

- (void)updateSilenceValueLabel {
    self.silenceValueLabel.text = [NSString stringWithFormat:@"%.1f s", self.silenceSlider.value];
}

- (void)updateTimeoutValueLabel {
    self.timeoutValueLabel.text = [NSString stringWithFormat:@"%.0f s", self.timeoutSlider.value];
}

#pragma mark - 事件

- (void)onCancelTapped {
    void(^cb)(void) = self.onCancel;
    [self dismissViewControllerAnimated:YES completion:^{
        if (cb) cb();
    }];
}

- (void)onApplyTapped {
    TSAIChatConfig *cfg = [self snapshotFromForm];
    void(^cb)(TSAIChatConfig *) = self.onApply;
    [self dismissViewControllerAnimated:YES completion:^{
        if (cb) cb(cfg);
    }];
}

- (void)onSilenceChanged {
    [self updateSilenceValueLabel];
}

- (void)onTimeoutChanged {
    [self updateTimeoutValueLabel];
}

#pragma mark - TSAIChatAgentSelectorDelegate

- (void)agentSelector:(TSAIChatAgentSelector *)selector
       didSelectEntry:(TSAIChatAgentEntry *)entry {
    [selector setSelectedEntry:entry];
}

- (void)agentSelectorDidRequestCustomEntry:(TSAIChatAgentSelector *)selector {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"自定义智能体"
                         message:@"请填写 name / agentId / speakerId"
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"name（如 🤖 我的助手）";
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"agentId（如 ZNT002）";
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"speakerId（可空）";
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        NSString *name      = [strongSelf trimmedText:alert.textFields[0].text];
        NSString *agentId   = [strongSelf trimmedText:alert.textFields[1].text];
        NSString *speakerId = [strongSelf trimmedText:alert.textFields[2].text] ?: @"";

        if (name.length == 0 || agentId.length == 0) {
            [strongSelf showAlertWithMessage:@"name 与 agentId 不能为空"];
            return;
        }

        // 已存在（agentId+speakerId 一致）则复用并选中
        TSAIChatAgentEntry *existing = nil;
        for (TSAIChatAgentEntry *entry in [strongSelf mergedAgentEntries]) {
            if ([entry.agentId isEqualToString:agentId]
                && [entry.speakerId isEqualToString:speakerId]) {
                existing = entry;
                break;
            }
        }
        if (existing) {
            [strongSelf.agentSelector setSelectedEntry:existing];
            return;
        }

        TSAIChatAgentEntry *entry = [TSAIChatAgentEntry entryWithAgentId:agentId
                                                               speakerId:speakerId
                                                             displayName:name];
        [strongSelf.customAgents addObject:entry];
        [strongSelf.agentSelector appendCustomEntry:entry];
        [strongSelf.agentSelector setSelectedEntry:entry];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

/// 校验失败提示
- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:nil
                                                              message:message
                                                       preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.promptPlaceholder.hidden = (textView.text.length > 0);
}

#pragma mark - 属性（懒加载）

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _scrollView;
}

- (UIStackView *)formStack {
    if (!_formStack) {
        _formStack = [[UIStackView alloc] init];
        _formStack.axis = UILayoutConstraintAxisVertical;
        _formStack.alignment = UIStackViewAlignmentFill;
        _formStack.spacing = TSSpacing_SM;
    }
    return _formStack;
}

- (UISegmentedControl *)languageSegment {
    if (!_languageSegment) {
        _languageSegment = [[UISegmentedControl alloc] initWithItems:@[@"系统", @"zh-CN", @"en-US", @"ja-JP"]];
        _languageSegment.selectedSegmentIndex = 0;
    }
    return _languageSegment;
}

- (TSAIChatAgentSelector *)agentSelector {
    if (!_agentSelector) {
        _agentSelector = [[TSAIChatAgentSelector alloc] initWithFrame:CGRectZero];
        _agentSelector.delegate = self;
    }
    return _agentSelector;
}

- (UITextView *)promptTextView {
    if (!_promptTextView) {
        _promptTextView = [[UITextView alloc] init];
        _promptTextView.font = TSFont_Body;
        _promptTextView.textColor = TSColor_TextPrimary;
        _promptTextView.backgroundColor = TSColor_Background;
        _promptTextView.layer.cornerRadius = TSRadius_SM;
        _promptTextView.delegate = self;
    }
    return _promptTextView;
}

- (UILabel *)promptPlaceholder {
    if (!_promptPlaceholder) {
        _promptPlaceholder = [[UILabel alloc] init];
        _promptPlaceholder.font = TSFont_Body;
        _promptPlaceholder.textColor = TSColor_TextSecondary;
        _promptPlaceholder.text = @"User's name is John. Location is Beijing.";
        _promptPlaceholder.userInteractionEnabled = NO;
        _promptPlaceholder.numberOfLines = 0;
    }
    return _promptPlaceholder;
}

- (UISwitch *)voiceSwitch {
    if (!_voiceSwitch) {
        _voiceSwitch = [[UISwitch alloc] init];
    }
    return _voiceSwitch;
}

- (UISwitch *)interruptSwitch {
    if (!_interruptSwitch) {
        _interruptSwitch = [[UISwitch alloc] init];
    }
    return _interruptSwitch;
}

- (UISlider *)silenceSlider {
    if (!_silenceSlider) {
        _silenceSlider = [[UISlider alloc] init];
        _silenceSlider.minimumValue = 0.3f;
        _silenceSlider.maximumValue = 2.0f;
        [_silenceSlider addTarget:self
                           action:@selector(onSilenceChanged)
                 forControlEvents:UIControlEventValueChanged];
    }
    return _silenceSlider;
}

- (UILabel *)silenceValueLabel {
    if (!_silenceValueLabel) {
        _silenceValueLabel = [[UILabel alloc] init];
    }
    return _silenceValueLabel;
}

- (UISlider *)timeoutSlider {
    if (!_timeoutSlider) {
        _timeoutSlider = [[UISlider alloc] init];
        _timeoutSlider.minimumValue = 5.f;
        _timeoutSlider.maximumValue = 60.f;
        [_timeoutSlider addTarget:self
                           action:@selector(onTimeoutChanged)
                 forControlEvents:UIControlEventValueChanged];
    }
    return _timeoutSlider;
}

- (UILabel *)timeoutValueLabel {
    if (!_timeoutValueLabel) {
        _timeoutValueLabel = [[UILabel alloc] init];
    }
    return _timeoutValueLabel;
}

@end
