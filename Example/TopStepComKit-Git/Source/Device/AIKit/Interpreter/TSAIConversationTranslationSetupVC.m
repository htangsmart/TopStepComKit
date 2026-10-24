//
//  TSAIConversationTranslationSetupVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIConversationTranslationSetupVC.h"

#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSAIConversationTranslationUI.h"
#import "TSAIConversationTranslationVC.h"
#import "TSAIEarbudsMicrophoneUI.h"
#import "TSAIInterpreterFormatter.h"
#import "TSAIInterpreterLanguageSheetVC.h"
#import "TSAIInterpreterTheme.h"

/// 上一次配置的持久化 key
static NSString *const kTSAIConversationLastConfigKey = @"TSAIConversationTranslationLastConfig";

@interface TSAIConversationTranslationSetupVC () <UIGestureRecognizerDelegate>

#pragma mark - 视图 - 顶栏
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *helpButton;

#pragma mark - 视图 - 滚动区
@property (nonatomic, strong) UIScrollView *scrollView;
/// 「双方语言」
@property (nonatomic, strong) UILabel *languageSectionLabel;
@property (nonatomic, strong) UIView *languageCard;
@property (nonatomic, strong) UIControl *selfTile;
@property (nonatomic, strong) UILabel *selfKeyLabel;
@property (nonatomic, strong) UILabel *selfValueLabel;
@property (nonatomic, strong) UILabel *selfHintLabel;
@property (nonatomic, strong) UIButton *swapButton;
@property (nonatomic, strong) UIControl *peerTile;
@property (nonatomic, strong) UILabel *peerKeyLabel;
@property (nonatomic, strong) UILabel *peerValueLabel;
@property (nonatomic, strong) UILabel *peerHintLabel;
/// 「怎么交流」
@property (nonatomic, strong) UILabel *modeSectionLabel;
@property (nonatomic, copy) NSArray<TSAIConversationPresetCard *> *presetCards;
/// 预设 / 自定义说明行
@property (nonatomic, strong) UILabel *customTagLabel;
@property (nonatomic, strong) UILabel *customTextLabel;
/// 「谁收音、在哪听译文」
@property (nonatomic, strong) UILabel *matrixSectionLabel;
@property (nonatomic, strong) UIView *matrixCard;
@property (nonatomic, strong) UILabel *selfColumnLabel;
@property (nonatomic, strong) UILabel *peerColumnLabel;
@property (nonatomic, strong) UILabel *captureRowLabel;
@property (nonatomic, strong) UILabel *playbackRowLabel;
@property (nonatomic, strong) TSAIConversationDeviceSegment *selfCaptureSegment;
@property (nonatomic, strong) TSAIConversationDeviceSegment *peerCaptureSegment;
@property (nonatomic, strong) TSAIConversationDeviceSegment *selfPlaybackSegment;
@property (nonatomic, strong) TSAIConversationDeviceSegment *peerPlaybackSegment;
@property (nonatomic, strong) UIView *matrixHairline;
@property (nonatomic, strong) UILabel *matrixNoteLabel;
/// 「播报」
@property (nonatomic, strong) UILabel *playbackSectionLabel;
@property (nonatomic, strong) UIView *playbackCard;
@property (nonatomic, strong) UILabel *autoSpeakTitleLabel;
@property (nonatomic, strong) UILabel *autoSpeakHintLabel;
@property (nonatomic, strong) UISwitch *autoSpeakSwitch;

#pragma mark - 视图 - 底栏
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILabel *reasonLabel;
@property (nonatomic, strong) UIButton *startButton;

#pragma mark - 状态
/// 正在编辑的配置（四个端点始终为显式值）
@property (nonatomic, strong) TSAIConversationTranslationConfig *config;
/// 各设备的可用性，key 为 TSAIConversationEndpoint
@property (nonatomic, copy) NSDictionary<NSNumber *, TSAIStartEligibility *> *deviceEligibilities;
/// 耳机麦克风状态（SDK：DeviceVoiceTranslation）
@property (nonatomic, strong, nullable) TSAIEarbudsMicrophoneStatus *earbudsStatus;
/// 因路由组合不可用而置灰的预设及原因（例如「便携 + 耳机」），key 为 TSAIConversationTranslationMode
@property (nonatomic, copy) NSDictionary<NSNumber *, NSString *> *presetUnavailableReasons;
/// 耳机 / 充电仓状态变化监听，页面可见期间有效
@property (nonatomic, strong, nullable) id<NSObject> earbudsObserver;
/// 支持的语言，按显示名排序
@property (nonatomic, copy) NSArray<NSNumber *> *languages;
/// 进入前的侧滑手势代理，离开时还原
@property (nonatomic, weak, nullable) id<UIGestureRecognizerDelegate> previousPopDelegate;

@end

@implementation TSAIConversationTranslationSetupVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.view.backgroundColor = [TSAIInterpreterTheme paper];
    self.config = [self loadLastConfig];
}

- (void)setupViews {
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.helpButton];

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.languageSectionLabel];
    [self.scrollView addSubview:self.languageCard];
    [self.languageCard addSubview:self.selfTile];
    [self.selfTile addSubview:self.selfKeyLabel];
    [self.selfTile addSubview:self.selfValueLabel];
    [self.selfTile addSubview:self.selfHintLabel];
    [self.languageCard addSubview:self.peerTile];
    [self.peerTile addSubview:self.peerKeyLabel];
    [self.peerTile addSubview:self.peerValueLabel];
    [self.peerTile addSubview:self.peerHintLabel];
    [self.languageCard addSubview:self.swapButton];

    [self.scrollView addSubview:self.modeSectionLabel];
    for (TSAIConversationPresetCard *card in self.presetCards) [self.scrollView addSubview:card];
    [self.scrollView addSubview:self.customTagLabel];
    [self.scrollView addSubview:self.customTextLabel];

    [self.scrollView addSubview:self.matrixSectionLabel];
    [self.scrollView addSubview:self.matrixCard];
    [self.matrixCard addSubview:self.selfColumnLabel];
    [self.matrixCard addSubview:self.peerColumnLabel];
    [self.matrixCard addSubview:self.captureRowLabel];
    [self.matrixCard addSubview:self.playbackRowLabel];
    [self.matrixCard addSubview:self.selfCaptureSegment];
    [self.matrixCard addSubview:self.peerCaptureSegment];
    [self.matrixCard addSubview:self.selfPlaybackSegment];
    [self.matrixCard addSubview:self.peerPlaybackSegment];
    [self.matrixCard addSubview:self.matrixHairline];
    [self.matrixCard addSubview:self.matrixNoteLabel];

    [self.scrollView addSubview:self.playbackSectionLabel];
    [self.scrollView addSubview:self.playbackCard];
    [self.playbackCard addSubview:self.autoSpeakTitleLabel];
    [self.playbackCard addSubview:self.autoSpeakHintLabel];
    [self.playbackCard addSubview:self.autoSpeakSwitch];

    [self.view addSubview:self.footerView];
    [self.footerView addSubview:self.reasonLabel];
    [self.footerView addSubview:self.startButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    // 从语言页 / 对话页回来或连接状态变化后重新读取可用性。
    [self reloadCapabilities];
    // 页面可见期间 SDK 报告耳机麦克风状态变化（耳机接入/断开、入仓、权限、充电仓连接）时实时刷新
    if (self.earbudsObserver == nil) {
        __weak typeof(self) weakSelf = self;
        self.earbudsObserver = [TSAIEarbudsMicrophoneUI
            addStatusObserverForFeature:TSAIFeatureDeviceVoiceTranslation
                                handler:^(TSAIEarbudsMicrophoneStatus *status) {
            [weakSelf reloadCapabilities];
        }];
    }
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
    [TSAIEarbudsMicrophoneUI removeObserver:self.earbudsObserver];
    self.earbudsObserver = nil;
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

    // 顶栏
    CGFloat topY = self.view.safeAreaInsets.top + 10.0;
    self.backButton.frame = CGRectMake(side, topY, 44.0, 44.0);
    self.helpButton.frame = CGRectMake(width - side - 44.0, topY, 44.0, 44.0);
    self.titleLabel.frame = CGRectMake(side + 54.0, topY, innerW - 108.0, 44.0);
    CGFloat scrollTop = topY + 44.0 + 8.0;

    // 底栏
    CGFloat bottomPad = MAX(self.view.safeAreaInsets.bottom, 16.0);
    CGSize reasonSize = [self.reasonLabel sizeThatFits:CGSizeMake(innerW, CGFLOAT_MAX)];
    CGFloat reasonH = MAX(16.0, ceil(reasonSize.height));
    CGFloat footerH = 12.0 + reasonH + 10.0 + 56.0 + bottomPad;
    self.footerView.frame = CGRectMake(0, height - footerH, width, footerH);
    self.reasonLabel.frame = CGRectMake(side, 12.0, innerW, reasonH);
    self.startButton.frame = CGRectMake(side, CGRectGetMaxY(self.reasonLabel.frame) + 10.0, innerW, 56.0);

    // 滚动区
    self.scrollView.frame = CGRectMake(0, scrollTop, width, CGRectGetMinY(self.footerView.frame) - scrollTop);
    CGFloat y = 12.0;

    // 双方语言
    self.languageSectionLabel.frame = CGRectMake(side, y, innerW, 16.0);
    y += 16.0 + 10.0;
    CGFloat tileH = 94.0;
    CGFloat cardH = tileH + 12.0;
    self.languageCard.frame = CGRectMake(side, y, innerW, cardH);
    CGFloat swapFootprint = 40.0 - 28.0;
    CGFloat tileW = floor((innerW - 12.0 - swapFootprint - 12.0) / 2.0);
    self.selfTile.frame = CGRectMake(6.0, 6.0, tileW, tileH);
    self.peerTile.frame = CGRectMake(innerW - 6.0 - tileW, 6.0, tileW, tileH);
    self.swapButton.frame = CGRectMake((innerW - 40.0) / 2.0, (cardH - 40.0) / 2.0, 40.0, 40.0);
    [self layoutTile:self.selfTile key:self.selfKeyLabel value:self.selfValueLabel hint:self.selfHintLabel leftPad:14.0];
    [self layoutTile:self.peerTile key:self.peerKeyLabel value:self.peerValueLabel hint:self.peerHintLabel leftPad:22.0];
    y = CGRectGetMaxY(self.languageCard.frame) + 22.0;

    // 怎么交流：三张预设卡 + 说明行
    self.modeSectionLabel.frame = CGRectMake(side, y, innerW, 16.0);
    y += 16.0 + 10.0;
    CGFloat gap = 8.0;
    CGFloat presetW = floor((innerW - gap * 2) / 3.0);
    CGFloat presetH = 98.0;
    [self.presetCards enumerateObjectsUsingBlock:^(TSAIConversationPresetCard *card, NSUInteger idx, BOOL *stop) {
        card.frame = CGRectMake(side + idx * (presetW + gap), y, presetW, presetH);
    }];
    y += presetH + 8.0;
    CGFloat tagW = 0;
    if (!self.customTagLabel.hidden) {
        tagW = ceil([self.customTagLabel sizeThatFits:CGSizeMake(innerW, 20.0)].width) + 16.0;
        self.customTagLabel.frame = CGRectMake(side, y, tagW, 20.0);
        tagW += 8.0;
    }
    CGFloat customH = ceil([self.customTextLabel sizeThatFits:CGSizeMake(innerW - tagW, CGFLOAT_MAX)].height);
    self.customTextLabel.frame = CGRectMake(side + tagW, y + (20.0 - MIN(customH, 20.0)) / 2.0, innerW - tagW, MAX(customH, 20.0));
    y += MAX(customH, 20.0) + 22.0;

    // 谁收音、在哪听译文：矩阵
    self.matrixSectionLabel.frame = CGRectMake(side, y, innerW, 16.0);
    y += 16.0 + 10.0;
    CGFloat pad = 14.0;
    CGFloat rowKeyW = 52.0;
    CGFloat segW = floor((innerW - pad * 2 - rowKeyW - 8.0 * 2) / 2.0);
    CGFloat segH = 54.0;
    CGFloat my = pad;
    self.selfColumnLabel.frame = CGRectMake(pad + rowKeyW + 8.0, my, segW, 18.0);
    self.peerColumnLabel.frame = CGRectMake(pad + rowKeyW + 8.0 + segW + 8.0, my, segW, 18.0);
    my += 18.0 + 10.0;
    self.captureRowLabel.frame = CGRectMake(pad, my, rowKeyW, segH);
    self.selfCaptureSegment.frame = CGRectMake(pad + rowKeyW + 8.0, my, segW, segH);
    self.peerCaptureSegment.frame = CGRectMake(pad + rowKeyW + 8.0 + segW + 8.0, my, segW, segH);
    my += segH + 10.0;
    self.playbackRowLabel.frame = CGRectMake(pad, my, rowKeyW, segH);
    self.selfPlaybackSegment.frame = CGRectMake(pad + rowKeyW + 8.0, my, segW, segH);
    self.peerPlaybackSegment.frame = CGRectMake(pad + rowKeyW + 8.0 + segW + 8.0, my, segW, segH);
    my += segH + 12.0;
    self.matrixHairline.frame = CGRectMake(pad, my, innerW - pad * 2, 1.0);
    my += 1.0 + 10.0;
    CGFloat noteH = ceil([self.matrixNoteLabel sizeThatFits:CGSizeMake(innerW - pad * 2, CGFLOAT_MAX)].height);
    self.matrixNoteLabel.frame = CGRectMake(pad, my, innerW - pad * 2, noteH);
    my += noteH + 12.0;
    self.matrixCard.frame = CGRectMake(side, y, innerW, my);
    y = CGRectGetMaxY(self.matrixCard.frame) + 22.0;

    // 播报
    self.playbackSectionLabel.frame = CGRectMake(side, y, innerW, 16.0);
    y += 16.0 + 10.0;
    CGFloat switchW = 51.0;
    CGFloat textW = innerW - 32.0 - switchW - 12.0;
    CGFloat hintH = ceil([self.autoSpeakHintLabel sizeThatFits:CGSizeMake(textW, CGFLOAT_MAX)].height);
    CGFloat rowH = 14.0 + 18.0 + 2.0 + hintH + 14.0;
    self.playbackCard.frame = CGRectMake(side, y, innerW, rowH);
    self.autoSpeakTitleLabel.frame = CGRectMake(16.0, 14.0, textW, 18.0);
    self.autoSpeakHintLabel.frame = CGRectMake(16.0, 14.0 + 18.0 + 2.0, textW, hintH);
    self.autoSpeakSwitch.center = CGPointMake(innerW - 16.0 - switchW / 2.0, rowH / 2.0);
    y = CGRectGetMaxY(self.playbackCard.frame) + 8.0;
    self.scrollView.contentSize = CGSizeMake(width, y + 12.0);
}

/// 语言块内部：padding 16 14（对方块左 22），k / v / h 纵向 gap 4
- (void)layoutTile:(UIView *)tile key:(UILabel *)key value:(UILabel *)value hint:(UILabel *)hint leftPad:(CGFloat)leftPad {
    CGFloat w = CGRectGetWidth(tile.bounds) - leftPad - 14.0;
    CGFloat ty = 16.0;
    key.frame = CGRectMake(leftPad, ty, w, 14.0);
    ty += 14.0 + 4.0;
    value.frame = CGRectMake(leftPad, ty, w, 26.0);
    ty += 26.0 + 4.0;
    hint.frame = CGRectMake(leftPad, ty, w, 14.0);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.navigationController.viewControllers.count > 1;
}

#pragma mark - 私有方法 - 数据

/// 重新读取设备可用性与语言列表，并刷新整页
- (void)reloadCapabilities {
    id<TSAIInterpretationInterface> interpretation = [TSAIKit sharedInstance].activeContext.interpretation;
    NSMutableDictionary<NSNumber *, TSAIStartEligibility *> *eligibilities = [NSMutableDictionary dictionary];
    // 充电仓沿用同传的拾音检查；耳机不能借用同传检查（同传要求固件 AI 音频源为 SCO，T80 为 Opus 会恒灰）
    TSAIStartEligibility *caseEligibility = [interpretation eligibilityForPickup:TSAIInterpretationPickupChargingCase];
    if (caseEligibility != nil) eligibilities[@(TSAIConversationEndpointCase)] = caseEligibility;
    self.deviceEligibilities = eligibilities;
    // 耳机：SDK 给出的耳机麦克风状态（零副作用）；能否真正用耳机麦由 SDK 在开始时校验
    self.earbudsStatus = [TSAIEarbudsMicrophoneUI statusForFeature:TSAIFeatureDeviceVoiceTranslation];
    NSArray<NSNumber *> *languages = [interpretation supportedLanguages] ?: @[];
    self.languages = [languages sortedArrayUsingComparator:^NSComparisonResult(NSNumber *a, NSNumber *b) {
        return [[TSAIInterpreterFormatter displayNameForLanguage:a.integerValue]
            localizedCaseInsensitiveCompare:[TSAIInterpreterFormatter displayNameForLanguage:b.integerValue]];
    }];
    // 上次选的设备当前不可用时退回手机。
    if (![self isEndpointAvailable:self.config.selfCaptureEndpoint]) self.config.selfCaptureEndpoint = TSAIConversationEndpointPhone;
    if (![self isEndpointAvailable:self.config.selfPlaybackEndpoint]) self.config.selfPlaybackEndpoint = TSAIConversationEndpointPhone;
    if (![self isEndpointAvailable:self.config.peerCaptureEndpoint]) self.config.peerCaptureEndpoint = TSAIConversationEndpointPhone;
    if (![self isEndpointAvailable:self.config.peerPlaybackEndpoint]) self.config.peerPlaybackEndpoint = TSAIConversationEndpointPhone;
    [self refreshAllUI];
}

- (NSArray<NSNumber *> *)endpointOrder {
    return @[ @(TSAIConversationEndpointPhone), @(TSAIConversationEndpointEarbuds), @(TSAIConversationEndpointCase) ];
}

- (BOOL)isEndpointAvailable:(TSAIConversationEndpoint)endpoint {
    if (endpoint == TSAIConversationEndpointPhone) return YES;
    if (endpoint == TSAIConversationEndpointEarbuds) {
        // 权限相关状态不置灰，点「开始」时统一引导授权（与手机收音一致）
        return [TSAIEarbudsMicrophoneUI isSelectableStatus:self.earbudsStatus];
    }
    return self.deviceEligibilities[@(endpoint)].support == TSAICapabilitySupported;
}

- (BOOL)isCaseConnected {
    return [self isEndpointAvailable:TSAIConversationEndpointCase];
}

/// 不可用设备被点击时的原因
- (NSString *)unavailableReasonForEndpoint:(TSAIConversationEndpoint)endpoint {
    if (endpoint == TSAIConversationEndpointEarbuds) {
        return [TSAIEarbudsMicrophoneUI unavailableReasonForStatus:self.earbudsStatus]
            ?: TSLocalizedString(@"ai_conversation.earbuds_not_ready");
    }
    NSError *error = self.deviceEligibilities[@(endpoint)].error;
    if ([error.domain isEqualToString:TSAIErrorDomain] && error.code == TSAIErrorCodeBusy) {
        return TSLocalizedString(@"ai_interpreter.setup_reason_busy");
    }
    return TSLocalizedString(@"ai_interpreter.setup_pickup_case_unavailable");
}

/// 按错误码给出不可开始的原因；NotSupported 与未知码附带 SDK 原始描述
- (NSString *)localizedReasonForError:(nullable NSError *)error {
    NSString *fallback = TSLocalizedString(@"ai_conversation.unavailable");
    if (error == nil) return fallback;
    NSString *detail = error.localizedDescription;
    NSString *withDetail = detail.length > 0 ? [NSString stringWithFormat:@"%@ · %@", fallback, detail] : fallback;
    if (![error.domain isEqualToString:TSAIErrorDomain]) return withDetail;
    switch (error.code) {
        case TSAIErrorCodeBridgeUnavailable:
            return TSLocalizedString(@"ai_interpreter.setup_pickup_case_unavailable");
        case TSAIErrorCodeAudioRouteUnavailable:
            return detail.length > 0
                ? [NSString stringWithFormat:@"%@ · %@", TSLocalizedString(@"ai_conversation.route_unavailable"), detail]
                : TSLocalizedString(@"ai_conversation.route_unavailable");
        case TSAIErrorCodeBusy:
            return TSLocalizedString(@"ai_interpreter.setup_reason_busy");
        case TSAIErrorCodeInvalidParameter:
            return TSLocalizedString(@"ai_interpreter.setup_reason_invalid");
        case TSAIErrorCodeContextInactive:
            return fallback;
        default:
            return withDetail;
    }
}

/// 预设的路由组合是否被 SDK 判定不可用（零副作用校验）；返回给用户的原因，可用时为 nil。
/// 「便携 + 耳机」（我用耳机、对方用手机）：HFP 输入期间 iOS 不能同时用手机麦或外放，第一版不支持
- (nullable NSString *)routeUnavailableReasonForPreset:(TSAIConversationTranslationMode)mode {
    id<TSAIConversationTranslationInterface> conversation = [TSAIKit sharedInstance].activeContext.conversationTranslation;
    if (conversation == nil) {
        return nil;
    }
    TSAIConversationTranslationConfig *candidate = [self.config copy];
    [TSAIConversationTranslationUI applyPreset:mode toConfig:candidate];
    candidate.mode = [TSAIConversationTranslationUI deviceModeForConfig:candidate];
    TSAIStartEligibility *eligibility = [conversation eligibilityForConfig:candidate];
    NSError *error = eligibility.error;
    if (eligibility.support == TSAICapabilitySupported ||
        ![error.domain isEqualToString:TSAIErrorDomain] ||
        error.code != TSAIErrorCodeAudioRouteUnavailable) {
        return nil;
    }
    BOOL earbudsWithPhone = candidate.selfCaptureEndpoint == TSAIConversationEndpointEarbuds &&
        (candidate.peerCaptureEndpoint == TSAIConversationEndpointPhone ||
         candidate.peerPlaybackEndpoint == TSAIConversationEndpointPhone ||
         candidate.selfPlaybackEndpoint == TSAIConversationEndpointPhone);
    return earbudsWithPhone
        ? @"耳机收音时 iOS 不能同时使用手机麦克风或手机外放，暂不支持「便携 + 耳机」，请改用私密模式或手机收音"
        : (error.localizedDescription ?: TSLocalizedString(@"ai_conversation.unavailable"));
}

/// 手机是否是任一方的播报端
- (BOOL)phonePlaysBack {
    return self.config.selfPlaybackEndpoint == TSAIConversationEndpointPhone
        || self.config.peerPlaybackEndpoint == TSAIConversationEndpointPhone;
}

#pragma mark - 私有方法 - UI 刷新

- (void)refreshAllUI {
    // 下发给设备的产品模式随端点组合变化
    self.config.mode = [TSAIConversationTranslationUI deviceModeForConfig:self.config];
    TSAIConversationTranslationMode preset = [TSAIConversationTranslationUI presetMatchingConfig:self.config];

    // 语言块
    self.selfValueLabel.text = [TSAIInterpreterFormatter displayNameForLanguage:self.config.selfLanguage];
    self.peerValueLabel.text = [TSAIInterpreterFormatter displayNameForLanguage:self.config.peerLanguage];
    self.selfHintLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_conversation.setup_lang_hint_fmt"),
                               [TSAIConversationTranslationUI nameForEndpoint:self.config.selfCaptureEndpoint],
                               [TSAIConversationTranslationUI nameForEndpoint:self.config.selfPlaybackEndpoint]];
    self.peerHintLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_conversation.setup_lang_hint_fmt"),
                               [TSAIConversationTranslationUI nameForEndpoint:self.config.peerCaptureEndpoint],
                               [TSAIConversationTranslationUI nameForEndpoint:self.config.peerPlaybackEndpoint]];

    // 预设卡：端点不可用，或 SDK 判定路由组合不可用（「便携 + 耳机」第一版不支持）时置灰
    NSMutableDictionary<NSNumber *, NSString *> *presetReasons = [NSMutableDictionary dictionary];
    for (TSAIConversationPresetCard *card in self.presetCards) {
        BOOL available = [self isCaseConnected];
        for (NSNumber *boxed in [TSAIConversationTranslationUI presetEndpointsForMode:card.mode]) {
            if (![self isEndpointAvailable:(TSAIConversationEndpoint)boxed.integerValue]) available = NO;
        }
        if (available) {
            NSString *routeReason = [self routeUnavailableReasonForPreset:card.mode];
            if (routeReason.length > 0) {
                available = NO;
                presetReasons[@(card.mode)] = routeReason;
            }
        }
        card.available = available;
        card.selected = card.mode == preset;
    }
    self.presetUnavailableReasons = presetReasons;
    BOOL custom = preset == TSAIConversationTranslationModeInvalid;
    self.customTagLabel.hidden = !custom;
    if (custom) {
        self.customTextLabel.text = [TSAIConversationTranslationUI descriptionForMode:TSAIConversationTranslationModeInvalid];
    } else {
        NSString *title = [TSAIConversationTranslationUI titleForMode:preset];
        NSString *desc = [TSAIConversationTranslationUI descriptionForMode:preset];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
            initWithString:[NSString stringWithFormat:@"%@  %@", title, desc]
                attributes:@{ NSFontAttributeName: [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400],
                              NSForegroundColorAttributeName: [TSAIInterpreterTheme muted] }];
        [text addAttributes:@{ NSFontAttributeName: [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600],
                               NSForegroundColorAttributeName: [TSAIInterpreterTheme ink] }
                      range:NSMakeRange(0, title.length)];
        self.customTextLabel.attributedText = text;
    }

    // 矩阵
    NSArray<TSAIConversationDeviceSegment *> *segments = @[ self.selfCaptureSegment, self.selfPlaybackSegment,
                                                             self.peerCaptureSegment, self.peerPlaybackSegment ];
    for (TSAIConversationDeviceSegment *segment in segments) {
        for (NSNumber *boxed in [self endpointOrder]) {
            [segment setEndpoint:(TSAIConversationEndpoint)boxed.integerValue
                       available:[self isEndpointAvailable:(TSAIConversationEndpoint)boxed.integerValue]];
        }
    }
    self.selfCaptureSegment.selectedEndpoint = self.config.selfCaptureEndpoint;
    self.selfPlaybackSegment.selectedEndpoint = self.config.selfPlaybackEndpoint;
    self.peerCaptureSegment.selectedEndpoint = self.config.peerCaptureEndpoint;
    self.peerPlaybackSegment.selectedEndpoint = self.config.peerPlaybackEndpoint;
    if (![self isCaseConnected]) {
        self.matrixNoteLabel.text = TSLocalizedString(@"ai_conversation.note_case_required");
        self.matrixNoteLabel.textColor = [TSAIInterpreterTheme warn];
    } else {
        self.matrixNoteLabel.text = [self.config caseParticipates]
            ? TSLocalizedString(@"ai_conversation.note_case_participates")
            : TSLocalizedString(@"ai_conversation.note_case_idle");
        self.matrixNoteLabel.textColor = [TSAIInterpreterTheme muted];
    }

    // 播报
    BOOL phonePlays = [self phonePlaysBack];
    self.autoSpeakSwitch.on = phonePlays && self.config.autoSpeakOnPhone;
    self.autoSpeakSwitch.enabled = phonePlays;
    self.autoSpeakHintLabel.text = phonePlays
        ? TSLocalizedString(@"ai_conversation.setup_auto_speak_hint")
        : TSLocalizedString(@"ai_conversation.setup_auto_speak_na");
    self.autoSpeakTitleLabel.alpha = phonePlays ? 1.0 : 0.4;

    [self refreshEligibility];
    [self.view setNeedsLayout];
}

/// 用 SDK 的无副作用校验决定能否开始，并展示原因
- (void)refreshEligibility {
    id<TSAIConversationTranslationInterface> conversation = [TSAIKit sharedInstance].activeContext.conversationTranslation;
    NSString *reason = nil;
    BOOL canStart = NO;
    if (![self isCaseConnected]) {
        reason = nil;  // 矩阵下方已经有醒目提示，按钮文案改为「先连接充电仓」
    } else if (self.config.selfLanguage == self.config.peerLanguage) {
        reason = TSLocalizedString(@"ai_conversation.same_language");
    } else if (conversation == nil) {
        reason = TSLocalizedString(@"ai_conversation.unavailable");
    } else {
        TSAIStartEligibility *eligibility = [conversation eligibilityForConfig:self.config];
        canStart = eligibility.support == TSAICapabilitySupported;
        reason = canStart ? nil : [self localizedReasonForError:eligibility.error];
        if (!canStart) {
            TSLog(@"[TSAIConversationSetup] start blocked: mode=%ld endpoints=%ld/%ld/%ld/%ld code=%ld desc=%@",
                  (long)self.config.mode, (long)self.config.selfCaptureEndpoint, (long)self.config.selfPlaybackEndpoint,
                  (long)self.config.peerCaptureEndpoint, (long)self.config.peerPlaybackEndpoint,
                  (long)eligibility.error.code, eligibility.error.localizedDescription);
        }
    }
    self.reasonLabel.text = reason;
    // CTA 用 UIButtonConfiguration 承载标题，改文案要改 attributedTitle
    NSString *title = [self isCaseConnected]
        ? TSLocalizedString(@"ai_conversation.start")
        : TSLocalizedString(@"ai_conversation.setup_start_case_required");
    UIButtonConfiguration *cfg = self.startButton.configuration;
    if (cfg != nil && ![cfg.attributedTitle.string isEqualToString:title]) {
        cfg.attributedTitle = [[NSAttributedString alloc]
            initWithString:title
                attributes:@{ NSFontAttributeName: [TSAIInterpreterTheme fontOfSize:17.0 cssWeight:700],
                              NSForegroundColorAttributeName: UIColor.whiteColor }];
        self.startButton.configuration = cfg;
    }
    self.startButton.enabled = canStart;
    self.startButton.alpha = canStart ? 1.0 : 0.4;
}

#pragma mark - 私有方法 - 事件

- (void)onBackTap {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onHelpTap {
    [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_conversation.setup_help_toast") inView:self.view];
}

- (void)onSelfTileTap {
    [self presentLanguagePickerForSelf:YES];
}

- (void)onPeerTileTap {
    [self presentLanguagePickerForSelf:NO];
}

- (void)onSwapTap {
    TSAILanguage selfLanguage = self.config.selfLanguage;
    self.config.selfLanguage = self.config.peerLanguage;
    self.config.peerLanguage = selfLanguage;
    [self refreshAllUI];
}

/// 点预设卡：回填四个端点
- (void)onPresetTap:(TSAIConversationPresetCard *)card {
    if (!card.available) {
        NSString *routeReason = self.presetUnavailableReasons[@(card.mode)];
        [TSAIInterpreterTheme showToast:routeReason.length > 0
                                            ? routeReason
                                            : ([self isCaseConnected]
                                                ? [self unavailableReasonForEndpoint:TSAIConversationEndpointEarbuds]
                                                : TSLocalizedString(@"ai_interpreter.setup_pickup_case_unavailable"))
                                 inView:self.view];
        return;
    }
    [TSAIConversationTranslationUI applyPreset:card.mode toConfig:self.config];
    [self refreshAllUI];
}

/// 矩阵某格被点：写入端点后重新反推预设
- (void)onSegment:(TSAIConversationDeviceSegment *)segment pickEndpoint:(TSAIConversationEndpoint)endpoint {
    if (![self isEndpointAvailable:endpoint]) {
        [TSAIInterpreterTheme showToast:[self unavailableReasonForEndpoint:endpoint] inView:self.view];
        return;
    }
    if (segment == self.selfCaptureSegment) self.config.selfCaptureEndpoint = endpoint;
    else if (segment == self.selfPlaybackSegment) self.config.selfPlaybackEndpoint = endpoint;
    else if (segment == self.peerCaptureSegment) self.config.peerCaptureEndpoint = endpoint;
    else if (segment == self.peerPlaybackSegment) self.config.peerPlaybackEndpoint = endpoint;
    [self refreshAllUI];
}

- (void)onAutoSpeakChanged:(UISwitch *)sender {
    self.config.autoSpeakOnPhone = sender.isOn;
}

/// 开始：手机或耳机收音先确认麦克风权限（已拒绝引导去设置，未询问先请求），再进入对话页
- (void)onStartTap {
    if (![self needsMicrophonePermission]) {
        [self pushLiveSession];
        return;
    }
    if ([TSAIEarbudsMicrophoneUI isMicrophonePermissionDenied]) {
        [self presentMicrophonePermissionAlert];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [TSAIEarbudsMicrophoneUI requestMicrophonePermission:^(BOOL granted) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) return;
        if (!granted) {
            [strongSelf presentMicrophonePermissionAlert];
            return;
        }
        // 刚授权时 SDK 才开始判断耳机佩戴与蓝牙路由：重读状态，耳机端点不可用就留在本页并说明原因
        BOOL usesEarbuds = strongSelf.config.selfCaptureEndpoint == TSAIConversationEndpointEarbuds
            || strongSelf.config.peerCaptureEndpoint == TSAIConversationEndpointEarbuds;
        [strongSelf reloadCapabilities];
        if (usesEarbuds && ![strongSelf isEndpointAvailable:TSAIConversationEndpointEarbuds]) {
            [TSAIInterpreterTheme showToast:[strongSelf unavailableReasonForEndpoint:TSAIConversationEndpointEarbuds]
                                     inView:strongSelf.view];
            return;
        }
        [strongSelf pushLiveSession];
    }];
}

/// 任一方由手机或耳机收音时需要麦克风权限；充电仓收音由设备采集，不需要
- (BOOL)needsMicrophonePermission {
    NSArray<NSNumber *> *captures = @[ @(self.config.selfCaptureEndpoint), @(self.config.peerCaptureEndpoint) ];
    for (NSNumber *boxed in captures) {
        TSAIConversationEndpoint endpoint = (TSAIConversationEndpoint)boxed.integerValue;
        if (endpoint == TSAIConversationEndpointPhone || endpoint == TSAIConversationEndpointEarbuds) {
            return YES;
        }
    }
    return NO;
}

/// 麦克风权限被拒：引导去系统设置开启
- (void)presentMicrophonePermissionAlert {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:TSLocalizedString(@"ai_conversation.mic_permission_title")
                                            message:TSLocalizedString(@"ai_conversation.mic_permission_denied")
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.go_settings")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        [TSAIEarbudsMicrophoneUI openAppSettings];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 保存配置并进入对话页
- (void)pushLiveSession {
    [self saveLastConfig:self.config];
    TSAIConversationTranslationConfig *config = [self copyOfConfig:self.config];
    TSAIConversationTranslationVC *live = [[TSAIConversationTranslationVC alloc] initWithConfig:config];
    [self.navigationController pushViewController:live animated:YES];
}

/// present 语言页；选到与另一方相同的语言时提示并忽略
- (void)presentLanguagePickerForSelf:(BOOL)isSelf {
    TSAILanguage current = isSelf ? self.config.selfLanguage : self.config.peerLanguage;
    __weak typeof(self) weakSelf = self;
    TSAIInterpreterLanguageSheetVC *sheet =
        [[TSAIInterpreterLanguageSheetVC alloc] initWithTitle:isSelf
                                                                ? TSLocalizedString(@"ai_conversation.setup_me_key")
                                                                : TSLocalizedString(@"ai_conversation.setup_peer_key")
                                                     languages:self.languages
                                                       current:current
                                                        onPick:^(TSAILanguage picked) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) return;
        TSAILanguage other = isSelf ? strongSelf.config.peerLanguage : strongSelf.config.selfLanguage;
        if (picked == other) {
            [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_conversation.same_language") inView:strongSelf.view];
            return;
        }
        if (isSelf) strongSelf.config.selfLanguage = picked;
        else strongSelf.config.peerLanguage = picked;
        [strongSelf refreshAllUI];
    }];
    sheet.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark - 私有方法 - 配置持久化

- (TSAIConversationTranslationConfig *)copyOfConfig:(TSAIConversationTranslationConfig *)source {
    TSAIConversationTranslationConfig *config = [TSAIConversationTranslationConfig configWithMode:source.mode];
    config.selfLanguage = source.selfLanguage;
    config.peerLanguage = source.peerLanguage;
    config.selfCaptureEndpoint = source.selfCaptureEndpoint;
    config.selfPlaybackEndpoint = source.selfPlaybackEndpoint;
    config.peerCaptureEndpoint = source.peerCaptureEndpoint;
    config.peerPlaybackEndpoint = source.peerPlaybackEndpoint;
    config.autoSpeakOnPhone = source.autoSpeakOnPhone;
    config.silenceTimeout = source.silenceTimeout;
    return config;
}

/// 读取上一次配置；没有则使用面对面预设 + 中文 / 英语
- (TSAIConversationTranslationConfig *)loadLastConfig {
    TSAIConversationTranslationConfig *config =
        [TSAIConversationTranslationConfig configWithMode:TSAIConversationTranslationModeFaceToFace];
    [TSAIConversationTranslationUI applyPreset:TSAIConversationTranslationModeFaceToFace toConfig:config];
    config.selfLanguage = TSAILanguageChineseSimplified;
    config.peerLanguage = TSAILanguageEnglishUS;
    config.autoSpeakOnPhone = NO;
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kTSAIConversationLastConfigKey];
    if (![dict isKindOfClass:[NSDictionary class]]) return config;
    if (dict[@"self"]) config.selfLanguage = [dict[@"self"] integerValue];
    if (dict[@"peer"]) config.peerLanguage = [dict[@"peer"] integerValue];
    if (dict[@"selfIn"]) config.selfCaptureEndpoint = (TSAIConversationEndpoint)[dict[@"selfIn"] integerValue];
    if (dict[@"selfOut"]) config.selfPlaybackEndpoint = (TSAIConversationEndpoint)[dict[@"selfOut"] integerValue];
    if (dict[@"peerIn"]) config.peerCaptureEndpoint = (TSAIConversationEndpoint)[dict[@"peerIn"] integerValue];
    if (dict[@"peerOut"]) config.peerPlaybackEndpoint = (TSAIConversationEndpoint)[dict[@"peerOut"] integerValue];
    if (dict[@"autoPhone"]) config.autoSpeakOnPhone = [dict[@"autoPhone"] boolValue];
    // 历史里的「自动」一律落成显式端点
    for (NSString *key in @[ @"selfCaptureEndpoint", @"selfPlaybackEndpoint", @"peerCaptureEndpoint", @"peerPlaybackEndpoint" ]) {
        if ([[config valueForKey:key] integerValue] == TSAIConversationEndpointAutomatic) {
            [config setValue:@(TSAIConversationEndpointPhone) forKey:key];
        }
    }
    return config;
}

- (void)saveLastConfig:(TSAIConversationTranslationConfig *)config {
    NSDictionary *dict = @{ @"self": @(config.selfLanguage),
                            @"peer": @(config.peerLanguage),
                            @"selfIn": @(config.selfCaptureEndpoint),
                            @"selfOut": @(config.selfPlaybackEndpoint),
                            @"peerIn": @(config.peerCaptureEndpoint),
                            @"peerOut": @(config.peerPlaybackEndpoint),
                            @"autoPhone": @(config.autoSpeakOnPhone) };
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kTSAIConversationLastConfigKey];
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
        _titleLabel.text = TSLocalizedString(@"ai_conversation.setup_title");
        _titleLabel.font = [TSAIInterpreterTheme fontOfSize:17.0 cssWeight:700];
        _titleLabel.textColor = [TSAIInterpreterTheme ink];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)helpButton {
    if (!_helpButton) {
        _helpButton = [TSAIInterpreterTheme iconButtonWithSymbol:@"questionmark.circle"
                                                      background:[TSAIInterpreterTheme panel]
                                                            tint:[TSAIInterpreterTheme ink]
                                                          target:self
                                                          action:@selector(onHelpTap)];
    }
    return _helpButton;
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

- (UILabel *)sectionLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600];
    label.textColor = [TSAIInterpreterTheme muted];
    return label;
}

- (UILabel *)languageSectionLabel {
    if (!_languageSectionLabel) _languageSectionLabel = [self sectionLabelWithText:TSLocalizedString(@"ai_conversation.setup_section_languages")];
    return _languageSectionLabel;
}

- (UILabel *)modeSectionLabel {
    if (!_modeSectionLabel) _modeSectionLabel = [self sectionLabelWithText:TSLocalizedString(@"ai_conversation.setup_section_mode")];
    return _modeSectionLabel;
}

- (UILabel *)matrixSectionLabel {
    if (!_matrixSectionLabel) _matrixSectionLabel = [self sectionLabelWithText:TSLocalizedString(@"ai_conversation.setup_section_matrix")];
    return _matrixSectionLabel;
}

- (UILabel *)playbackSectionLabel {
    if (!_playbackSectionLabel) _playbackSectionLabel = [self sectionLabelWithText:TSLocalizedString(@"ai_conversation.setup_section_playback")];
    return _playbackSectionLabel;
}

- (UIView *)cardView {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [TSAIInterpreterTheme panel];
    card.layer.cornerRadius = 22.0;
    return card;
}

- (UIView *)languageCard {
    if (!_languageCard) _languageCard = [self cardView];
    return _languageCard;
}

- (UIControl *)tileWithBackground:(UIColor *)background action:(SEL)action {
    UIControl *tile = [[UIControl alloc] init];
    tile.backgroundColor = background;
    tile.layer.cornerRadius = 18.0;
    [tile addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return tile;
}

- (UILabel *)tileLabelWithFont:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    label.userInteractionEnabled = NO;
    return label;
}

- (UIControl *)selfTile {
    if (!_selfTile) _selfTile = [self tileWithBackground:[TSAIInterpreterTheme cobalt50] action:@selector(onSelfTileTap)];
    return _selfTile;
}

- (UILabel *)selfKeyLabel {
    if (!_selfKeyLabel) {
        _selfKeyLabel = [self tileLabelWithFont:[TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600]
                                          color:[TSAIInterpreterTheme cobalt]];
        _selfKeyLabel.text = TSLocalizedString(@"ai_conversation.setup_me_key");
    }
    return _selfKeyLabel;
}

- (UILabel *)selfValueLabel {
    if (!_selfValueLabel) {
        _selfValueLabel = [self tileLabelWithFont:[TSAIInterpreterTheme fontOfSize:22.0 cssWeight:700]
                                            color:[TSAIInterpreterTheme ink]];
        _selfValueLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _selfValueLabel;
}

- (UILabel *)selfHintLabel {
    if (!_selfHintLabel) {
        _selfHintLabel = [self tileLabelWithFont:[TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400]
                                           color:[TSAIInterpreterTheme muted]];
        _selfHintLabel.adjustsFontSizeToFitWidth = YES;
        _selfHintLabel.minimumScaleFactor = 0.8;
    }
    return _selfHintLabel;
}

- (UIControl *)peerTile {
    if (!_peerTile) _peerTile = [self tileWithBackground:[TSAIInterpreterTheme jade50] action:@selector(onPeerTileTap)];
    return _peerTile;
}

- (UILabel *)peerKeyLabel {
    if (!_peerKeyLabel) {
        _peerKeyLabel = [self tileLabelWithFont:[TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600]
                                          color:[TSAIInterpreterTheme jade]];
        _peerKeyLabel.text = TSLocalizedString(@"ai_conversation.setup_peer_key");
    }
    return _peerKeyLabel;
}

- (UILabel *)peerValueLabel {
    if (!_peerValueLabel) {
        _peerValueLabel = [self tileLabelWithFont:[TSAIInterpreterTheme fontOfSize:22.0 cssWeight:700]
                                            color:[TSAIInterpreterTheme ink]];
        _peerValueLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _peerValueLabel;
}

- (UILabel *)peerHintLabel {
    if (!_peerHintLabel) {
        _peerHintLabel = [self tileLabelWithFont:[TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400]
                                           color:[TSAIInterpreterTheme muted]];
        _peerHintLabel.adjustsFontSizeToFitWidth = YES;
        _peerHintLabel.minimumScaleFactor = 0.8;
    }
    return _peerHintLabel;
}

- (UIButton *)swapButton {
    if (!_swapButton) {
        _swapButton = [TSAIInterpreterTheme roundButtonWithSymbol:@"arrow.up.arrow.down"
                                                        pointSize:16.0
                                                       background:[TSAIInterpreterTheme ink]
                                                             tint:UIColor.whiteColor
                                                           target:self
                                                           action:@selector(onSwapTap)];
        _swapButton.layer.cornerRadius = 20.0;
    }
    return _swapButton;
}

- (NSArray<TSAIConversationPresetCard *> *)presetCards {
    if (!_presetCards) {
        NSMutableArray<TSAIConversationPresetCard *> *cards = [NSMutableArray arrayWithCapacity:3];
        for (NSNumber *boxed in @[ @(TSAIConversationTranslationModeFaceToFace),
                                   @(TSAIConversationTranslationModePrivate),
                                   @(TSAIConversationTranslationModePortable) ]) {
            TSAIConversationPresetCard *card = [[TSAIConversationPresetCard alloc] init];
            card.mode = (TSAIConversationTranslationMode)boxed.integerValue;
            [card addTarget:self action:@selector(onPresetTap:) forControlEvents:UIControlEventTouchUpInside];
            [cards addObject:card];
        }
        _presetCards = cards;
    }
    return _presetCards;
}

- (UILabel *)customTagLabel {
    if (!_customTagLabel) {
        _customTagLabel = [[UILabel alloc] init];
        _customTagLabel.text = TSLocalizedString(@"ai_conversation.preset_custom");
        _customTagLabel.font = [TSAIInterpreterTheme fontOfSize:11.0 cssWeight:600];
        _customTagLabel.textColor = UIColor.whiteColor;
        _customTagLabel.backgroundColor = [TSAIInterpreterTheme ink];
        _customTagLabel.textAlignment = NSTextAlignmentCenter;
        _customTagLabel.layer.cornerRadius = 10.0;
        _customTagLabel.clipsToBounds = YES;
        _customTagLabel.hidden = YES;
    }
    return _customTagLabel;
}

- (UILabel *)customTextLabel {
    if (!_customTextLabel) {
        _customTextLabel = [[UILabel alloc] init];
        _customTextLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400];
        _customTextLabel.textColor = [TSAIInterpreterTheme muted];
        _customTextLabel.numberOfLines = 0;
    }
    return _customTextLabel;
}

- (UIView *)matrixCard {
    if (!_matrixCard) _matrixCard = [self cardView];
    return _matrixCard;
}

- (UILabel *)columnLabelWithText:(NSString *)text color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:700];
    label.textColor = color;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (UILabel *)selfColumnLabel {
    if (!_selfColumnLabel) _selfColumnLabel = [self columnLabelWithText:TSLocalizedString(@"ai_conversation.matrix_col_me")
                                                                  color:[TSAIInterpreterTheme cobalt]];
    return _selfColumnLabel;
}

- (UILabel *)peerColumnLabel {
    if (!_peerColumnLabel) _peerColumnLabel = [self columnLabelWithText:TSLocalizedString(@"ai_conversation.matrix_col_peer")
                                                                  color:[TSAIInterpreterTheme jade]];
    return _peerColumnLabel;
}

- (UILabel *)rowLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600];
    label.textColor = [TSAIInterpreterTheme muted];
    label.numberOfLines = 2;
    return label;
}

- (UILabel *)captureRowLabel {
    if (!_captureRowLabel) _captureRowLabel = [self rowLabelWithText:TSLocalizedString(@"ai_conversation.matrix_row_capture")];
    return _captureRowLabel;
}

- (UILabel *)playbackRowLabel {
    if (!_playbackRowLabel) _playbackRowLabel = [self rowLabelWithText:TSLocalizedString(@"ai_conversation.matrix_row_playback")];
    return _playbackRowLabel;
}

- (TSAIConversationDeviceSegment *)segmentWithTint:(UIColor *)tint {
    TSAIConversationDeviceSegment *segment = [[TSAIConversationDeviceSegment alloc] init];
    segment.tint = tint;
    __weak typeof(self) weakSelf = self;
    __weak TSAIConversationDeviceSegment *weakSegment = segment;
    segment.onTap = ^(TSAIConversationEndpoint endpoint) {
        [weakSelf onSegment:weakSegment pickEndpoint:endpoint];
    };
    return segment;
}

- (TSAIConversationDeviceSegment *)selfCaptureSegment {
    if (!_selfCaptureSegment) _selfCaptureSegment = [self segmentWithTint:[TSAIInterpreterTheme cobalt]];
    return _selfCaptureSegment;
}

- (TSAIConversationDeviceSegment *)selfPlaybackSegment {
    if (!_selfPlaybackSegment) _selfPlaybackSegment = [self segmentWithTint:[TSAIInterpreterTheme cobalt]];
    return _selfPlaybackSegment;
}

- (TSAIConversationDeviceSegment *)peerCaptureSegment {
    if (!_peerCaptureSegment) _peerCaptureSegment = [self segmentWithTint:[TSAIInterpreterTheme jade]];
    return _peerCaptureSegment;
}

- (TSAIConversationDeviceSegment *)peerPlaybackSegment {
    if (!_peerPlaybackSegment) _peerPlaybackSegment = [self segmentWithTint:[TSAIInterpreterTheme jade]];
    return _peerPlaybackSegment;
}

- (UIView *)matrixHairline {
    if (!_matrixHairline) {
        _matrixHairline = [[UIView alloc] init];
        _matrixHairline.backgroundColor = [TSAIInterpreterTheme paper];
    }
    return _matrixHairline;
}

- (UILabel *)matrixNoteLabel {
    if (!_matrixNoteLabel) {
        _matrixNoteLabel = [[UILabel alloc] init];
        _matrixNoteLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400];
        _matrixNoteLabel.textColor = [TSAIInterpreterTheme muted];
        _matrixNoteLabel.numberOfLines = 0;
    }
    return _matrixNoteLabel;
}

- (UIView *)playbackCard {
    if (!_playbackCard) _playbackCard = [self cardView];
    return _playbackCard;
}

- (UILabel *)autoSpeakTitleLabel {
    if (!_autoSpeakTitleLabel) {
        _autoSpeakTitleLabel = [[UILabel alloc] init];
        _autoSpeakTitleLabel.text = TSLocalizedString(@"ai_conversation.setup_auto_speak");
        _autoSpeakTitleLabel.font = [TSAIInterpreterTheme fontOfSize:15.0 cssWeight:600];
        _autoSpeakTitleLabel.textColor = [TSAIInterpreterTheme ink];
    }
    return _autoSpeakTitleLabel;
}

- (UILabel *)autoSpeakHintLabel {
    if (!_autoSpeakHintLabel) {
        _autoSpeakHintLabel = [[UILabel alloc] init];
        _autoSpeakHintLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400];
        _autoSpeakHintLabel.textColor = [TSAIInterpreterTheme muted];
        _autoSpeakHintLabel.numberOfLines = 0;
    }
    return _autoSpeakHintLabel;
}

- (UISwitch *)autoSpeakSwitch {
    if (!_autoSpeakSwitch) {
        _autoSpeakSwitch = [[UISwitch alloc] init];
        _autoSpeakSwitch.onTintColor = [TSAIInterpreterTheme cobalt];
        [_autoSpeakSwitch addTarget:self action:@selector(onAutoSpeakChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _autoSpeakSwitch;
}

#pragma mark - 属性（懒加载）- 底栏

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = [TSAIInterpreterTheme paper];
    }
    return _footerView;
}

- (UILabel *)reasonLabel {
    if (!_reasonLabel) {
        _reasonLabel = [[UILabel alloc] init];
        _reasonLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400];
        _reasonLabel.textColor = [TSAIInterpreterTheme warn];
        _reasonLabel.textAlignment = NSTextAlignmentCenter;
        _reasonLabel.numberOfLines = 0;
    }
    return _reasonLabel;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [TSAIInterpreterTheme ctaButtonWithTitle:TSLocalizedString(@"ai_conversation.start")
                                                         symbol:@"bubble.left.and.bubble.right"
                                                     background:[TSAIInterpreterTheme ink]
                                                           tint:UIColor.whiteColor
                                                      cssWeight:700
                                                         target:self
                                                         action:@selector(onStartTap)];
    }
    return _startButton;
}

@end
