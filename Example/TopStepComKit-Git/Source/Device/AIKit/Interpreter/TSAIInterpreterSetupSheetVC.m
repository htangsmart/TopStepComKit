//
//  TSAIInterpreterSetupSheetVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterSetupSheetVC.h"

#import <TopStepAIKit/TopStepAIKit.h>

#import "TSAIInterpreterFormatter.h"
#import "TSAIInterpreterLanguageSheetVC.h"
#import "TSRootVC.h"

typedef NS_ENUM(NSInteger, TSAIInterpreterSetupSection) {
    TSAIInterpreterSetupSectionPickup = 0,
    TSAIInterpreterSetupSectionLanguage,
    TSAIInterpreterSetupSectionVoice,
    TSAIInterpreterSetupSectionCount,
};

static NSString *const kSetupCellID = @"TSAIInterpreterSetupCell";

/// 发音人预设（nil 为后端默认）
static NSArray<NSString *> *kSetupSpeakerPresets(void) {
    return @[ @"xiaogang", @"xiaomei", @"xiaoyu" ];
}

@interface TSAIInterpreterSetupSheetVC () <UITableViewDataSource, UITableViewDelegate>

/// 列表
@property (nonatomic, strong) UITableView *tableView;
/// 底部容器：错误文案 + 开始按钮
@property (nonatomic, strong) UIView *footerView;
/// 不可启动原因
@property (nonatomic, strong) UILabel *reasonLabel;
/// 开始按钮
@property (nonatomic, strong) UIButton *startButton;
/// 正在编辑的请求
@property (nonatomic, strong) TSAIInterpretationRequest *request;
/// 当前可用拾音设备
@property (nonatomic, copy) NSArray<NSNumber *> *availablePickups;
/// 支持的语言，按显示名排序
@property (nonatomic, copy) NSArray<NSNumber *> *languages;

@end

@implementation TSAIInterpreterSetupSheetVC

#pragma mark - 生命周期

- (instancetype)initWithInitialRequest:(nullable TSAIInterpretationRequest *)request {
    self = [super init];
    if (self) {
        _request = request != nil ? [request copy]
            : [TSAIInterpretationRequest requestWithSourceLanguage:TSAILanguageAuto
                                                    targetLanguage:TSAILanguageChineseSimplified
                                                            pickup:TSAIInterpretationPickupChargingCase];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"ai_interpreter.setup_title");
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                       target:self
                                                       action:@selector(onCancelTap)];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.footerView];
    [self.footerView addSubview:self.reasonLabel];
    [self.footerView addSubview:self.startButton];
    [self reloadCapabilities];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 从语言选择返回或连接状态变化后，重新读取可用性。
    [self reloadCapabilities];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    CGFloat footerHeight = 16.0 + 34.0 + 8.0 + 50.0 + 12.0 + bottomInset;
    self.footerView.frame = CGRectMake(0, height - footerHeight, width, footerHeight);
    self.reasonLabel.frame = CGRectMake(20.0, 12.0, width - 40.0, 38.0);
    self.startButton.frame = CGRectMake(20.0, CGRectGetMaxY(self.reasonLabel.frame) + 8.0, width - 40.0, 50.0);
    self.startButton.layer.cornerRadius = 14.0;
    self.tableView.frame = CGRectMake(0, 0, width, height - footerHeight);
}

#pragma mark - 私有方法 - 数据

/// 重新读取拾音设备可用性、语言列表，并刷新可启动状态
- (void)reloadCapabilities {
    id<TSAIInterpretationInterface> interpretation = [TSAIKit sharedInstance].activeContext.interpretation;
    self.availablePickups = [interpretation availablePickups] ?: @[];
    NSArray<NSNumber *> *languages = [interpretation supportedLanguages] ?: @[];
    self.languages = [languages sortedArrayUsingComparator:^NSComparisonResult(NSNumber *a, NSNumber *b) {
        return [[TSAIInterpreterFormatter displayNameForLanguage:a.integerValue]
            localizedCaseInsensitiveCompare:[TSAIInterpreterFormatter displayNameForLanguage:b.integerValue]];
    }];
    // 上次选择的拾音设备当前不可用时，退到第一个可用项。
    if (![self.availablePickups containsObject:@(self.request.pickup)] && self.availablePickups.count > 0) {
        self.request.pickup = self.availablePickups.firstObject.integerValue;
    }
    [self.tableView reloadData];
    [self refreshEligibility];
}

/// 用 SDK 的无副作用校验决定「开始」能否点，并展示原因
- (void)refreshEligibility {
    id<TSAIInterpretationInterface> interpretation = [TSAIKit sharedInstance].activeContext.interpretation;
    NSString *reason = nil;
    BOOL canStart = NO;
    if (interpretation == nil) {
        reason = TSLocalizedString(@"ai_interpreter.toast_unavailable");
    } else {
        TSAIStartEligibility *eligibility = [interpretation eligibilityForRequest:self.request];
        canStart = eligibility.support == TSAICapabilitySupported;
        reason = canStart ? nil : [self localizedReasonForError:eligibility.error];
    }
    self.reasonLabel.text = reason;
    self.startButton.enabled = canStart;
    self.startButton.alpha = canStart ? 1.0 : 0.5;
}

/// 按错误码给出本地化原因；未知错误码退回 SDK 描述
- (NSString *)localizedReasonForError:(nullable NSError *)error {
    if (error == nil) {
        return TSLocalizedString(@"ai_interpreter.toast_unavailable");
    }
    if ([error.domain isEqualToString:TSAIErrorDomain]) {
        switch (error.code) {
            case TSAIErrorCodeBridgeUnavailable:
                return TSLocalizedString(@"ai_interpreter.setup_pickup_case_unavailable");
            case TSAIErrorCodeAudioRouteUnavailable:
                return self.request.pickup == TSAIInterpretationPickupChargingCase
                    ? TSLocalizedString(@"ai_interpreter.setup_pickup_case_unavailable")
                    : TSLocalizedString(@"ai_interpreter.setup_pickup_unavailable");
            case TSAIErrorCodeBusy:
                return TSLocalizedString(@"ai_interpreter.setup_reason_busy");
            case TSAIErrorCodeContextInactive:
            case TSAIErrorCodeNotSupported:
                return TSLocalizedString(@"ai_interpreter.toast_unavailable");
            case TSAIErrorCodeInvalidParameter:
                return TSLocalizedString(@"ai_interpreter.setup_reason_invalid");
            default:
                break;
        }
    }
    return error.localizedDescription ?: TSLocalizedString(@"ai_interpreter.toast_unavailable");
}

/// 拾音设备的标题
- (NSString *)titleForPickup:(TSAIInterpretationPickup)pickup {
    switch (pickup) {
        case TSAIInterpretationPickupPhone: return TSLocalizedString(@"ai_interpreter.setup_pickup_phone");
        case TSAIInterpretationPickupEarbuds: return TSLocalizedString(@"ai_interpreter.setup_pickup_earbuds");
        case TSAIInterpretationPickupChargingCase: return TSLocalizedString(@"ai_interpreter.setup_pickup_case");
        default: return @"";
    }
}

/// 拾音设备的副标题（不可用时给出原因）
- (nullable NSString *)subtitleForPickup:(TSAIInterpretationPickup)pickup available:(BOOL)available {
    if (available) {
        return pickup == TSAIInterpretationPickupChargingCase
            ? TSLocalizedString(@"ai_interpreter.setup_pickup_case_hint")
            : nil;
    }
    return pickup == TSAIInterpretationPickupChargingCase
        ? TSLocalizedString(@"ai_interpreter.setup_pickup_case_unavailable")
        : TSLocalizedString(@"ai_interpreter.setup_pickup_unavailable");
}

#pragma mark - 私有方法 - 事件

- (void)onCancelTap {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/// 确认：先关闭抽屉，再把请求交回宿主
- (void)onStartTap {
    TSAIInterpretationRequest *request = [self.request copy];
    void (^onStart)(TSAIInterpretationRequest *) = self.onStart;
    [self dismissViewControllerAnimated:YES completion:^{
        if (onStart != nil) {
            onStart(request);
        }
    }];
}

- (void)onVoiceSwitchChanged:(UISwitch *)sender {
    self.request.enableVoiceOutput = sender.isOn;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:TSAIInterpreterSetupSectionVoice]
                  withRowAnimation:UITableViewRowAnimationNone];
    [self refreshEligibility];
}

/// 弹出语言选择
- (void)presentLanguagePickerForSource:(BOOL)isSource {
    NSMutableArray<NSNumber *> *list = [NSMutableArray array];
    if (isSource) {
        [list addObject:@(TSAILanguageAuto)];
    }
    [list addObjectsFromArray:self.languages];
    TSAILanguage current = isSource ? self.request.sourceLanguage : self.request.targetLanguage;
    __weak typeof(self) weakSelf = self;
    TSAIInterpreterLanguageSheetVC *sheet =
        [[TSAIInterpreterLanguageSheetVC alloc] initWithTitle:isSource
                                                                ? TSLocalizedString(@"ai_interpreter.sheet_select_source")
                                                                : TSLocalizedString(@"ai_interpreter.sheet_select_target")
                                                     languages:list
                                                       current:current
                                                        onPick:^(TSAILanguage picked) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) return;
        if (isSource) {
            strongSelf.request.sourceLanguage = picked;
        } else {
            strongSelf.request.targetLanguage = picked;
        }
        [strongSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:TSAIInterpreterSetupSectionLanguage]
                            withRowAnimation:UITableViewRowAnimationNone];
        [strongSelf refreshEligibility];
    }];
    sheet.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:sheet animated:YES completion:nil];
}

/// 交换语言（源为 Auto 时不可交换）
- (void)swapLanguages {
    if (self.request.sourceLanguage == TSAILanguageAuto) {
        return;
    }
    TSAILanguage source = self.request.sourceLanguage;
    self.request.sourceLanguage = self.request.targetLanguage;
    self.request.targetLanguage = source;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:TSAIInterpreterSetupSectionLanguage]
                  withRowAnimation:UITableViewRowAnimationNone];
    [self refreshEligibility];
}

/// 循环切换发音人预设
- (void)cycleSpeakerPreset {
    NSArray<NSString *> *presets = kSetupSpeakerPresets();
    NSUInteger index = self.request.speakerId.length > 0 ? [presets indexOfObject:self.request.speakerId] : NSNotFound;
    if (index == NSNotFound) {
        self.request.speakerId = presets.firstObject;
    } else if (index + 1 < presets.count) {
        self.request.speakerId = presets[index + 1];
    } else {
        self.request.speakerId = nil;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:TSAIInterpreterSetupSectionVoice]
                  withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TSAIInterpreterSetupSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case TSAIInterpreterSetupSectionPickup: return 3;
        case TSAIInterpreterSetupSectionLanguage: return 3;
        case TSAIInterpreterSetupSectionVoice: return self.request.enableVoiceOutput ? 2 : 1;
        default: return 0;
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TSAIInterpreterSetupSectionPickup: return TSLocalizedString(@"ai_interpreter.setup_section_pickup");
        case TSAIInterpreterSetupSectionLanguage: return TSLocalizedString(@"ai_interpreter.setup_section_language");
        case TSAIInterpreterSetupSectionVoice: return TSLocalizedString(@"ai_interpreter.section_voice_output");
        default: return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:kSetupCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    switch (indexPath.section) {
        case TSAIInterpreterSetupSectionPickup: {
            TSAIInterpretationPickup pickup = (TSAIInterpretationPickup)(indexPath.row + 1);
            BOOL available = [self.availablePickups containsObject:@(pickup)];
            cell.textLabel.text = [self titleForPickup:pickup];
            cell.detailTextLabel.text = [self subtitleForPickup:pickup available:available];
            cell.textLabel.textColor = available ? [UIColor labelColor] : [UIColor tertiaryLabelColor];
            cell.userInteractionEnabled = available;
            cell.accessoryType = (available && self.request.pickup == pickup)
                ? UITableViewCellAccessoryCheckmark
                : UITableViewCellAccessoryNone;
            break;
        }
        case TSAIInterpreterSetupSectionLanguage: {
            if (indexPath.row == 0) {
                cell.textLabel.text = TSLocalizedString(@"ai_interpreter.label_source");
                cell.detailTextLabel.text = [TSAIInterpreterFormatter displayNameForLanguage:self.request.sourceLanguage];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = TSLocalizedString(@"ai_interpreter.label_target");
                cell.detailTextLabel.text = [TSAIInterpreterFormatter displayNameForLanguage:self.request.targetLanguage];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                BOOL canSwap = self.request.sourceLanguage != TSAILanguageAuto;
                cell.textLabel.text = TSLocalizedString(@"ai_interpreter.setup_swap_languages");
                cell.textLabel.textColor = canSwap ? [UIColor systemBlueColor] : [UIColor tertiaryLabelColor];
                cell.userInteractionEnabled = canSwap;
            }
            break;
        }
        case TSAIInterpreterSetupSectionVoice: {
            if (indexPath.row == 0) {
                cell.textLabel.text = TSLocalizedString(@"ai_interpreter.setting_tts");
                cell.detailTextLabel.text = TSLocalizedString(@"ai_interpreter.setup_tts_hint");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UISwitch *voiceSwitch = [[UISwitch alloc] init];
                voiceSwitch.on = self.request.enableVoiceOutput;
                [voiceSwitch addTarget:self action:@selector(onVoiceSwitchChanged:)
                      forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = voiceSwitch;
            } else {
                cell.textLabel.text = TSLocalizedString(@"ai_interpreter.setting_speaker");
                cell.detailTextLabel.text = self.request.speakerId.length > 0
                    ? self.request.speakerId
                    : TSLocalizedString(@"ai_interpreter.speaker_default");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case TSAIInterpreterSetupSectionPickup:
            self.request.pickup = (TSAIInterpretationPickup)(indexPath.row + 1);
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:TSAIInterpreterSetupSectionPickup]
                     withRowAnimation:UITableViewRowAnimationNone];
            [self refreshEligibility];
            break;
        case TSAIInterpreterSetupSectionLanguage:
            if (indexPath.row == 2) {
                [self swapLanguages];
            } else {
                [self presentLanguagePickerForSource:indexPath.row == 0];
            }
            break;
        case TSAIInterpreterSetupSectionVoice:
            if (indexPath.row == 1) {
                [self cycleSpeakerPreset];
            }
            break;
        default:
            break;
    }
}

#pragma mark - 属性（懒加载）

- (UITableView *)tableView {
    if (!_tableView) {
        UITableViewStyle style = UITableViewStyleGrouped;
        if (@available(iOS 13.0, *)) {
            style = UITableViewStyleInsetGrouped;
        }
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    }
    return _tableView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    }
    return _footerView;
}

- (UILabel *)reasonLabel {
    if (!_reasonLabel) {
        _reasonLabel = [[UILabel alloc] init];
        _reasonLabel.font = [UIFont systemFontOfSize:13.0];
        _reasonLabel.textColor = [UIColor systemOrangeColor];
        _reasonLabel.numberOfLines = 2;
        _reasonLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _reasonLabel;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _startButton.backgroundColor = [UIColor systemGreenColor];
        _startButton.tintColor = [UIColor whiteColor];
        _startButton.titleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];
        [_startButton setTitle:TSLocalizedString(@"ai_interpreter.setup_start") forState:UIControlStateNormal];
        [_startButton addTarget:self action:@selector(onStartTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

@end
