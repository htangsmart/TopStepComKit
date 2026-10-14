//
//  TSAIInterpreterSetupVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterSetupVC.h"

#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSAIInterpreterDeviceCell.h"
#import "TSAIInterpreterFormatter.h"
#import "TSAIInterpreterLanguageSheetVC.h"
#import "TSAIInterpreterTheme.h"
#import "TSAIInterpreterVC.h"

/// 上一次会话请求的持久化 key
static NSString *const kTSAIInterpreterLastRequestKey = @"TSAIInterpreterLastRequest";

/// 「译文从哪里播放」的四个选项
typedef NS_ENUM(NSInteger, TSAIInterpreterOutputOption) {
    TSAIInterpreterOutputOptionAuto = 0,
    TSAIInterpreterOutputOptionPhone = 1,
    TSAIInterpreterOutputOptionCase = 2,
    TSAIInterpreterOutputOptionMute = 3,
};

@interface TSAIInterpreterSetupVC () <UIGestureRecognizerDelegate>

#pragma mark - 视图 - 顶栏
/// 返回
@property (nonatomic, strong) UIButton *backButton;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;
/// 帮助
@property (nonatomic, strong) UIButton *helpButton;

#pragma mark - 视图 - 滚动区
/// 滚动容器
@property (nonatomic, strong) UIScrollView *scrollView;
/// 「翻译什么」
@property (nonatomic, strong) UILabel *whatLabel;
/// 语言卡片
@property (nonatomic, strong) UIView *languageCard;
/// 源语言块
@property (nonatomic, strong) UIControl *sourceTile;
@property (nonatomic, strong) UILabel *sourceKeyLabel;
@property (nonatomic, strong) UILabel *sourceValueLabel;
@property (nonatomic, strong) UILabel *sourceHintLabel;
/// 交换
@property (nonatomic, strong) UIButton *swapButton;
/// 目标语言块
@property (nonatomic, strong) UIControl *targetTile;
@property (nonatomic, strong) UILabel *targetKeyLabel;
@property (nonatomic, strong) UILabel *targetValueLabel;
@property (nonatomic, strong) UILabel *targetHintLabel;
/// 「用什么设备」
@property (nonatomic, strong) UILabel *deviceLabel;
/// 设备卡片
@property (nonatomic, strong) UIView *deviceCard;
/// 「谁来收音」
@property (nonatomic, strong) UILabel *pickupTitleLabel;
@property (nonatomic, strong) UILabel *pickupHintLabel;
/// 收音格子（phone / earbuds / case）
@property (nonatomic, copy) NSArray<TSAIInterpreterDeviceCell *> *pickupCells;
/// 分隔线
@property (nonatomic, strong) UIView *hairline;
/// 「译文从哪里播放」
@property (nonatomic, strong) UILabel *outputTitleLabel;
@property (nonatomic, strong) UILabel *outputHintLabel;
/// 播放格子（auto / phone / case / mute）
@property (nonatomic, copy) NSArray<TSAIInterpreterDeviceCell *> *outputCells;

#pragma mark - 视图 - 底栏
/// 底栏容器
@property (nonatomic, strong) UIView *footerView;
/// 不可开始原因
@property (nonatomic, strong) UILabel *reasonLabel;
/// 开始同传
@property (nonatomic, strong) UIButton *startButton;

#pragma mark - 状态
/// 正在编辑的请求
@property (nonatomic, strong) TSAIInterpretationRequest *request;
/// 当前播放选项
@property (nonatomic, assign) TSAIInterpreterOutputOption outputOption;
/// 各拾音设备的启动资格（key 为 TSAIInterpretationPickup）
@property (nonatomic, copy) NSDictionary<NSNumber *, TSAIStartEligibility *> *pickupEligibilities;
/// 支持的语言，按显示名排序
@property (nonatomic, copy) NSArray<NSNumber *> *languages;
/// 进入前的侧滑手势代理，离开时还原
@property (nonatomic, weak, nullable) id<UIGestureRecognizerDelegate> previousPopDelegate;

@end

@implementation TSAIInterpreterSetupVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.view.backgroundColor = [TSAIInterpreterTheme paper];
    self.request = [self loadLastRequest];
    self.outputOption = [self outputOptionForRequest:self.request];
}

- (void)setupViews {
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.helpButton];

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.whatLabel];
    [self.scrollView addSubview:self.languageCard];
    [self.languageCard addSubview:self.sourceTile];
    [self.sourceTile addSubview:self.sourceKeyLabel];
    [self.sourceTile addSubview:self.sourceValueLabel];
    [self.sourceTile addSubview:self.sourceHintLabel];
    [self.languageCard addSubview:self.targetTile];
    [self.targetTile addSubview:self.targetKeyLabel];
    [self.targetTile addSubview:self.targetValueLabel];
    [self.targetTile addSubview:self.targetHintLabel];
    [self.languageCard addSubview:self.swapButton];

    [self.scrollView addSubview:self.deviceLabel];
    [self.scrollView addSubview:self.deviceCard];
    [self.deviceCard addSubview:self.pickupTitleLabel];
    [self.deviceCard addSubview:self.pickupHintLabel];
    for (TSAIInterpreterDeviceCell *cell in self.pickupCells) [self.deviceCard addSubview:cell];
    [self.deviceCard addSubview:self.hairline];
    [self.deviceCard addSubview:self.outputTitleLabel];
    [self.deviceCard addSubview:self.outputHintLabel];
    for (TSAIInterpreterDeviceCell *cell in self.outputCells) [self.deviceCard addSubview:cell];

    [self.view addSubview:self.footerView];
    [self.footerView addSubview:self.reasonLabel];
    [self.footerView addSubview:self.startButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    // 从语言页 / 同传页回来或连接状态变化后重新读取可用性。
    [self reloadCapabilities];
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

- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    if (width <= 0 || height <= 0) return;
    CGFloat side = 20.0;
    CGFloat innerW = width - side * 2;

    // 顶栏：padding 54 20 8 → 状态栏 + 10，行高 44
    CGFloat topY = self.view.safeAreaInsets.top + 10.0;
    self.backButton.frame = CGRectMake(side, topY, 44.0, 44.0);
    self.helpButton.frame = CGRectMake(width - side - 44.0, topY, 44.0, 44.0);
    self.titleLabel.frame = CGRectMake(side + 54.0, topY, innerW - 108.0, 44.0);
    CGFloat scrollTop = topY + 44.0 + 8.0;

    // 底栏：padding 12 20 34，gap 10
    CGFloat bottomPad = MAX(self.view.safeAreaInsets.bottom, 16.0);
    CGSize reasonSize = [self.reasonLabel sizeThatFits:CGSizeMake(innerW, CGFLOAT_MAX)];
    CGFloat reasonH = MAX(16.0, ceil(reasonSize.height));
    CGFloat footerH = 12.0 + reasonH + 10.0 + 56.0 + bottomPad;
    self.footerView.frame = CGRectMake(0, height - footerH, width, footerH);
    self.reasonLabel.frame = CGRectMake(side, 12.0, innerW, reasonH);
    self.startButton.frame = CGRectMake(side, CGRectGetMaxY(self.reasonLabel.frame) + 10.0, innerW, 56.0);

    // 滚动区：padding 8 20 0，sec 间距 22
    self.scrollView.frame = CGRectMake(0, scrollTop, width, CGRectGetMinY(self.footerView.frame) - scrollTop);
    CGFloat y = 8.0 + 4.0;
    self.whatLabel.frame = CGRectMake(side, y, innerW, 16.0);
    y += 16.0 + 10.0;

    // 语言卡：padding 6，gap 6，swap 40 且 margin 0 -14
    CGFloat tileH = 94.0;
    CGFloat cardH = tileH + 12.0;
    self.languageCard.frame = CGRectMake(side, y, innerW, cardH);
    CGFloat swapFootprint = 40.0 - 28.0;
    CGFloat tileW = floor((innerW - 12.0 - swapFootprint - 12.0) / 2.0);
    self.sourceTile.frame = CGRectMake(6.0, 6.0, tileW, tileH);
    self.targetTile.frame = CGRectMake(innerW - 6.0 - tileW, 6.0, tileW, tileH);
    self.swapButton.frame = CGRectMake((innerW - 40.0) / 2.0, (cardH - 40.0) / 2.0, 40.0, 40.0);
    [self layoutTile:self.sourceTile key:self.sourceKeyLabel value:self.sourceValueLabel hint:self.sourceHintLabel leftPad:14.0];
    [self layoutTile:self.targetTile key:self.targetKeyLabel value:self.targetValueLabel hint:self.targetHintLabel leftPad:22.0];
    y = CGRectGetMaxY(self.languageCard.frame) + 22.0;

    self.deviceLabel.frame = CGRectMake(side, y, innerW, 16.0);
    y += 16.0 + 10.0;

    // 设备卡：padding 16，row gap 16；row 内 hd → 10 → grid
    CGFloat cardInnerW = innerW - 32.0;
    CGFloat cy = 16.0;
    cy = [self layoutRowHeaderAtY:cy width:cardInnerW title:self.pickupTitleLabel hint:self.pickupHintLabel];
    cy = [self layoutGrid:self.pickupCells atY:cy width:cardInnerW columns:3];
    cy += 16.0;
    self.hairline.frame = CGRectMake(16.0, cy, cardInnerW, 1.0);
    cy += 1.0 + 16.0;
    cy = [self layoutRowHeaderAtY:cy width:cardInnerW title:self.outputTitleLabel hint:self.outputHintLabel];
    cy = [self layoutGrid:self.outputCells atY:cy width:cardInnerW columns:4];
    cy += 16.0;
    self.deviceCard.frame = CGRectMake(side, y, innerW, cy);
    y = CGRectGetMaxY(self.deviceCard.frame) + 8.0;
    self.scrollView.contentSize = CGSizeMake(width, y + 12.0);
}

/// 语言块内部：padding 16 14（目标块左 22），k / v / h 纵向 gap 4
- (void)layoutTile:(UIView *)tile key:(UILabel *)key value:(UILabel *)value hint:(UILabel *)hint leftPad:(CGFloat)leftPad {
    CGFloat w = CGRectGetWidth(tile.bounds) - leftPad - 14.0;
    CGFloat ty = 16.0;
    key.frame = CGRectMake(leftPad, ty, w, 14.0);
    ty += 14.0 + 4.0;
    value.frame = CGRectMake(leftPad, ty, w, 26.0);
    ty += 26.0 + 4.0;
    hint.frame = CGRectMake(leftPad, ty, w, 14.0);
}

/// 行头：标题左、提示右（按基线对齐），返回下一行 y
- (CGFloat)layoutRowHeaderAtY:(CGFloat)y width:(CGFloat)width title:(UILabel *)title hint:(UILabel *)hint {
    CGSize titleSize = [title sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGFloat titleW = ceil(titleSize.width);
    CGFloat hintW = width - titleW - 8.0;
    CGSize hintSize = [hint sizeThatFits:CGSizeMake(hintW, CGFLOAT_MAX)];
    CGFloat rowH = MAX(18.0, ceil(hintSize.height));
    title.frame = CGRectMake(16.0, y + rowH - 18.0, titleW, 18.0);
    hint.frame = CGRectMake(16.0 + titleW + 8.0, y + rowH - ceil(hintSize.height), hintW, ceil(hintSize.height));
    return y + rowH + 10.0;
}

/// 等分网格：gap 8，格子高 84，返回下一行 y
- (CGFloat)layoutGrid:(NSArray<TSAIInterpreterDeviceCell *> *)cells atY:(CGFloat)y width:(CGFloat)width columns:(NSInteger)columns {
    CGFloat gap = 8.0;
    CGFloat cellW = floor((width - gap * (columns - 1)) / columns);
    CGFloat cellH = 84.0;
    [cells enumerateObjectsUsingBlock:^(TSAIInterpreterDeviceCell *cell, NSUInteger idx, BOOL *stop) {
        NSInteger col = idx % columns;
        NSInteger row = idx / columns;
        cell.frame = CGRectMake(16.0 + col * (cellW + gap), y + row * (cellH + gap), cellW, cellH);
    }];
    NSInteger rows = (cells.count + columns - 1) / columns;
    return y + rows * cellH + (rows - 1) * gap;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.navigationController.viewControllers.count > 1;
}

#pragma mark - 私有方法 - 数据

/// 重新读取各拾音设备的启动资格与语言列表，并刷新整页
- (void)reloadCapabilities {
    id<TSAIInterpretationInterface> interpretation = [TSAIKit sharedInstance].activeContext.interpretation;
    NSMutableDictionary<NSNumber *, TSAIStartEligibility *> *eligibilities = [NSMutableDictionary dictionary];
    for (NSNumber *pickup in [self pickupOrder]) {
        TSAIStartEligibility *eligibility = [interpretation eligibilityForPickup:pickup.integerValue];
        if (eligibility != nil) eligibilities[pickup] = eligibility;
    }
    self.pickupEligibilities = eligibilities;
    NSArray<NSNumber *> *languages = [interpretation supportedLanguages] ?: @[];
    self.languages = [languages sortedArrayUsingComparator:^NSComparisonResult(NSNumber *a, NSNumber *b) {
        return [[TSAIInterpreterFormatter displayNameForLanguage:a.integerValue]
            localizedCaseInsensitiveCompare:[TSAIInterpreterFormatter displayNameForLanguage:b.integerValue]];
    }];
    // 上次选择的拾音设备当前不可用时，退到第一个可用项；仓不可用时播放端退回「跟随收音」。
    if (![self isPickupAvailable:self.request.pickup]) {
        for (NSNumber *pickup in [self pickupOrder]) {
            if ([self isPickupAvailable:pickup.integerValue]) {
                self.request.pickup = pickup.integerValue;
                break;
            }
        }
    }
    if (self.outputOption == TSAIInterpreterOutputOptionCase
        && ![self isPickupAvailable:TSAIInterpretationPickupChargingCase]) {
        self.outputOption = TSAIInterpreterOutputOptionAuto;
    }
    [self refreshAllUI];
}

- (NSArray<NSNumber *> *)pickupOrder {
    return @[ @(TSAIInterpretationPickupPhone),
              @(TSAIInterpretationPickupEarbuds),
              @(TSAIInterpretationPickupChargingCase) ];
}

/// 拾音设备当前是否可用
- (BOOL)isPickupAvailable:(TSAIInterpretationPickup)pickup {
    return self.pickupEligibilities[@(pickup)].support == TSAICapabilitySupported;
}

- (BOOL)hasAnyPickupAvailable {
    for (NSNumber *pickup in [self pickupOrder]) {
        if ([self isPickupAvailable:pickup.integerValue]) return YES;
    }
    return NO;
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

/// 拾音设备可用时的提示
- (NSString *)hintForPickup:(TSAIInterpretationPickup)pickup {
    switch (pickup) {
        case TSAIInterpretationPickupPhone: return TSLocalizedString(@"ai_interpreter.setup_pickup_hint_phone");
        case TSAIInterpretationPickupEarbuds: return TSLocalizedString(@"ai_interpreter.setup_pickup_hint_earbuds");
        case TSAIInterpretationPickupChargingCase: return TSLocalizedString(@"ai_interpreter.setup_pickup_hint_case");
        default: return @"";
    }
}

/// 不可用的拾音设备被点击时的原因（优先 SDK 判定）
- (NSString *)unavailableReasonForPickup:(TSAIInterpretationPickup)pickup {
    TSAIStartEligibility *eligibility = self.pickupEligibilities[@(pickup)];
    return [self localizedReasonForError:eligibility.error pickup:pickup];
}

/// 按错误码给出本地化原因；Demo 面向集成方，NotSupported 与未知码附带 SDK 的原始描述
- (NSString *)localizedReasonForError:(nullable NSError *)error pickup:(TSAIInterpretationPickup)pickup {
    NSString *fallback = pickup == TSAIInterpretationPickupChargingCase
        ? TSLocalizedString(@"ai_interpreter.setup_pickup_case_unavailable")
        : pickup == TSAIInterpretationPickupEarbuds
            ? TSLocalizedString(@"ai_interpreter.setup_pickup_earbuds_unavailable")
            : TSLocalizedString(@"ai_interpreter.setup_pickup_unavailable");
    if (error == nil) {
        return fallback;
    }
    NSString *detail = error.localizedDescription;
    NSString *withDetail = detail.length > 0
        ? [NSString stringWithFormat:@"%@ · %@", TSLocalizedString(@"ai_interpreter.toast_unavailable"), detail]
        : TSLocalizedString(@"ai_interpreter.toast_unavailable");
    if ([error.domain isEqualToString:TSAIErrorDomain]) {
        switch (error.code) {
            case TSAIErrorCodeBridgeUnavailable:
                return TSLocalizedString(@"ai_interpreter.setup_pickup_case_unavailable");
            case TSAIErrorCodeAudioRouteUnavailable:
                return fallback;
            case TSAIErrorCodeBusy:
                return TSLocalizedString(@"ai_interpreter.setup_reason_busy");
            case TSAIErrorCodeInvalidParameter:
                return TSLocalizedString(@"ai_interpreter.setup_reason_invalid");
            case TSAIErrorCodeContextInactive:
                return TSLocalizedString(@"ai_interpreter.toast_unavailable");
            case TSAIErrorCodeNotSupported:
            default:
                return withDetail;
        }
    }
    return withDetail;
}

/// 播放选项标题
- (NSString *)titleForOutputOption:(TSAIInterpreterOutputOption)option {
    switch (option) {
        case TSAIInterpreterOutputOptionAuto: return TSLocalizedString(@"ai_interpreter.setup_output_auto");
        case TSAIInterpreterOutputOptionPhone: return TSLocalizedString(@"ai_interpreter.setup_output_phone");
        case TSAIInterpreterOutputOptionCase: return TSLocalizedString(@"ai_interpreter.setup_output_case");
        case TSAIInterpreterOutputOptionMute: return TSLocalizedString(@"ai_interpreter.setup_output_mute");
    }
    return @"";
}

/// 播放选项当前是否可用：仓需要仓可收音，其余恒可用
- (BOOL)isOutputOptionAvailable:(TSAIInterpreterOutputOption)option {
    if (option == TSAIInterpreterOutputOptionCase) {
        return [self isPickupAvailable:TSAIInterpretationPickupChargingCase];
    }
    return YES;
}

/// 「跟随收音」实际会落到哪个设备
- (TSAIInterpretationPickup)resolvedOutputPickup {
    switch (self.outputOption) {
        case TSAIInterpreterOutputOptionPhone: return TSAIInterpretationPickupPhone;
        case TSAIInterpreterOutputOptionCase: return TSAIInterpretationPickupChargingCase;
        case TSAIInterpreterOutputOptionAuto:
        case TSAIInterpreterOutputOptionMute:
        default: return self.request.pickup;
    }
}

/// 从历史请求推断播放选项
- (TSAIInterpreterOutputOption)outputOptionForRequest:(TSAIInterpretationRequest *)request {
    if (!request.enableVoiceOutput) return TSAIInterpreterOutputOptionMute;
    switch (request.voiceOutputChannel) {
        case TSAIAudioOutputChannelBuiltInSpeaker: return TSAIInterpreterOutputOptionPhone;
        case TSAIAudioOutputChannelOpus: return TSAIInterpreterOutputOptionCase;
        default: return TSAIInterpreterOutputOptionAuto;
    }
}

/// 把播放选项写回请求
- (void)applyOutputOptionToRequest {
    switch (self.outputOption) {
        case TSAIInterpreterOutputOptionAuto:
            self.request.enableVoiceOutput = YES;
            self.request.voiceOutputChannel = TSAIAudioOutputChannelAutomatic;
            break;
        case TSAIInterpreterOutputOptionPhone:
            self.request.enableVoiceOutput = YES;
            self.request.voiceOutputChannel = TSAIAudioOutputChannelBuiltInSpeaker;
            break;
        case TSAIInterpreterOutputOptionCase:
            self.request.enableVoiceOutput = YES;
            self.request.voiceOutputChannel = TSAIAudioOutputChannelOpus;
            break;
        case TSAIInterpreterOutputOptionMute:
            self.request.enableVoiceOutput = NO;
            self.request.voiceOutputChannel = TSAIAudioOutputChannelNone;
            break;
    }
}

#pragma mark - 私有方法 - UI 刷新

- (void)refreshAllUI {
    [self applyOutputOptionToRequest];
    // 语言块
    self.sourceValueLabel.text = [TSAIInterpreterFormatter displayNameForLanguage:self.request.sourceLanguage];
    self.sourceHintLabel.text = self.request.sourceLanguage == TSAILanguageAuto
        ? TSLocalizedString(@"ai_interpreter.setup_src_hint_auto")
        : TSLocalizedString(@"ai_interpreter.setup_src_hint_fixed");
    self.targetValueLabel.text = [TSAIInterpreterFormatter displayNameForLanguage:self.request.targetLanguage];

    // 收音格
    [self.pickupCells enumerateObjectsUsingBlock:^(TSAIInterpreterDeviceCell *cell, NSUInteger idx, BOOL *stop) {
        TSAIInterpretationPickup pickup = (TSAIInterpretationPickup)cell.optionId;
        cell.available = [self isPickupAvailable:pickup];
        cell.selected = cell.available && pickup == self.request.pickup;
    }];
    self.pickupHintLabel.text = [self isPickupAvailable:self.request.pickup]
        ? [self hintForPickup:self.request.pickup] : @"";
    self.pickupHintLabel.textColor = [TSAIInterpreterTheme muted];

    // 播放格
    [self.outputCells enumerateObjectsUsingBlock:^(TSAIInterpreterDeviceCell *cell, NSUInteger idx, BOOL *stop) {
        TSAIInterpreterOutputOption option = (TSAIInterpreterOutputOption)cell.optionId;
        cell.available = [self isOutputOptionAvailable:option];
        cell.selected = cell.available && option == self.outputOption;
    }];
    BOOL warnHint = NO;
    NSString *outputHint = nil;
    switch (self.outputOption) {
        case TSAIInterpreterOutputOptionAuto:
            if (self.request.pickup == TSAIInterpretationPickupChargingCase) {
                outputHint = TSLocalizedString(@"ai_interpreter.setup_output_hint_auto_case");
                warnHint = YES;
            } else {
                outputHint = [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.setup_output_hint_auto_fmt"),
                              [self titleForPickup:[self resolvedOutputPickup]]];
            }
            break;
        case TSAIInterpreterOutputOptionMute:
            outputHint = TSLocalizedString(@"ai_interpreter.setup_output_hint_mute");
            break;
        case TSAIInterpreterOutputOptionCase:
            outputHint = TSLocalizedString(@"ai_interpreter.setup_output_hint_case");
            warnHint = YES;
            break;
        case TSAIInterpreterOutputOptionPhone:
            outputHint = TSLocalizedString(@"ai_interpreter.setup_output_hint_phone");
            break;
    }
    self.outputHintLabel.text = outputHint;
    self.outputHintLabel.textColor = warnHint ? [TSAIInterpreterTheme warn] : [TSAIInterpreterTheme muted];

    [self refreshEligibility];
    [self.view setNeedsLayout];
}

/// 用 SDK 的无副作用校验决定「开始同传」能否点，并展示原因
- (void)refreshEligibility {
    id<TSAIInterpretationInterface> interpretation = [TSAIKit sharedInstance].activeContext.interpretation;
    NSString *reason = nil;
    BOOL canStart = NO;
    if (![self hasAnyPickupAvailable]) {
        reason = TSLocalizedString(@"ai_interpreter.setup_reason_no_pickup");
    } else if (self.request.sourceLanguage == self.request.targetLanguage) {
        reason = TSLocalizedString(@"ai_interpreter.setup_reason_same_language");
    } else if (interpretation == nil) {
        reason = TSLocalizedString(@"ai_interpreter.toast_unavailable");
    } else {
        TSAIStartEligibility *eligibility = [interpretation eligibilityForRequest:self.request];
        canStart = eligibility.support == TSAICapabilitySupported;
        reason = canStart ? nil : [self localizedReasonForError:eligibility.error pickup:self.request.pickup];
        if (!canStart) {
            TSLog(@"[TSAIInterpreterSetup] start blocked: pickup=%ld code=%ld desc=%@",
                  (long)self.request.pickup, (long)eligibility.error.code,
                  eligibility.error.localizedDescription);
        }
    }
    self.reasonLabel.text = reason;
    self.startButton.enabled = canStart;
    self.startButton.alpha = canStart ? 1.0 : 0.4;
}

#pragma mark - 私有方法 - 事件

- (void)onBackTap {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onHelpTap {
    [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_interpreter.setup_help_toast") inView:self.view];
}

- (void)onSourceTileTap {
    [self presentLanguagePickerForSource:YES];
}

- (void)onTargetTileTap {
    [self presentLanguagePickerForSource:NO];
}

/// 交换语言（源为 Auto 时不可交换）
- (void)onSwapTap {
    if (self.request.sourceLanguage == TSAILanguageAuto) {
        [TSAIInterpreterTheme showToast:TSLocalizedString(@"ai_interpreter.setup_swap_auto_toast") inView:self.view];
        return;
    }
    TSAILanguage source = self.request.sourceLanguage;
    self.request.sourceLanguage = self.request.targetLanguage;
    self.request.targetLanguage = source;
    [self refreshAllUI];
}

/// 收音 / 播放格子被点击
- (void)onDeviceCellTap:(TSAIInterpreterDeviceCell *)cell {
    if (cell.kind == TSAIInterpreterDeviceCellKindInput) {
        TSAIInterpretationPickup pickup = (TSAIInterpretationPickup)cell.optionId;
        if (![self isPickupAvailable:pickup]) {
            [TSAIInterpreterTheme showToast:[self unavailableReasonForPickup:pickup] inView:self.view];
            return;
        }
        self.request.pickup = pickup;
    } else {
        TSAIInterpreterOutputOption option = (TSAIInterpreterOutputOption)cell.optionId;
        if (![self isOutputOptionAvailable:option]) {
            [TSAIInterpreterTheme showToast:[self unavailableReasonForPickup:TSAIInterpretationPickupChargingCase]
                                     inView:self.view];
            return;
        }
        self.outputOption = option;
    }
    [self refreshAllUI];
}

/// 开始：保存请求，push 同传页
- (void)onStartTap {
    [self applyOutputOptionToRequest];
    TSAIInterpretationRequest *request = [self.request copy];
    [self saveLastRequest:request];
    TSAIInterpreterVC *live = [[TSAIInterpreterVC alloc] initWithRequest:request];
    [self.navigationController pushViewController:live animated:YES];
}

/// present 语言页
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
                                                                ? TSLocalizedString(@"ai_interpreter.setup_src_key")
                                                                : TSLocalizedString(@"ai_interpreter.setup_dst_key")
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
        [strongSelf refreshAllUI];
    }];
    sheet.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark - 私有方法 - 请求持久化

/// 读取上一次请求（拾音设备、语言、播放端、发音人）
- (TSAIInterpretationRequest *)loadLastRequest {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kTSAIInterpreterLastRequestKey];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return [TSAIInterpretationRequest requestWithSourceLanguage:TSAILanguageAuto
                                                     targetLanguage:TSAILanguageChineseSimplified
                                                             pickup:TSAIInterpretationPickupChargingCase];
    }
    TSAIInterpretationRequest *request =
        [TSAIInterpretationRequest requestWithSourceLanguage:[dict[@"source"] integerValue]
                                              targetLanguage:[dict[@"target"] integerValue]
                                                      pickup:[dict[@"pickup"] integerValue]];
    request.enableVoiceOutput = dict[@"voice"] != nil ? [dict[@"voice"] boolValue] : YES;
    request.voiceOutputChannel = dict[@"channel"] != nil
        ? (TSAIAudioOutputChannel)[dict[@"channel"] integerValue]
        : TSAIAudioOutputChannelAutomatic;
    request.speakerId = [dict[@"speaker"] isKindOfClass:[NSString class]] ? dict[@"speaker"] : nil;
    return request;
}

/// 保存本次请求
- (void)saveLastRequest:(TSAIInterpretationRequest *)request {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"source"] = @(request.sourceLanguage);
    dict[@"target"] = @(request.targetLanguage);
    dict[@"pickup"] = @(request.pickup);
    dict[@"voice"] = @(request.enableVoiceOutput);
    dict[@"channel"] = @(request.voiceOutputChannel);
    if (request.speakerId.length > 0) {
        dict[@"speaker"] = request.speakerId;
    }
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kTSAIInterpreterLastRequestKey];
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
        _titleLabel.text = TSLocalizedString(@"ai_interpreter.title");
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

/// 分组标题（`.lbl`：13px / 600 / muted / 0.5 字距）
- (UILabel *)sectionLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.attributedText = [[NSAttributedString alloc]
        initWithString:text
            attributes:@{ NSFontAttributeName: [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600],
                          NSForegroundColorAttributeName: [TSAIInterpreterTheme muted],
                          NSKernAttributeName: @0.5 }];
    return label;
}

- (UILabel *)whatLabel {
    if (!_whatLabel) _whatLabel = [self sectionLabelWithText:TSLocalizedString(@"ai_interpreter.setup_sec_what")];
    return _whatLabel;
}

- (UILabel *)deviceLabel {
    if (!_deviceLabel) _deviceLabel = [self sectionLabelWithText:TSLocalizedString(@"ai_interpreter.setup_sec_device")];
    return _deviceLabel;
}

- (UIView *)languageCard {
    if (!_languageCard) {
        _languageCard = [[UIView alloc] init];
        _languageCard.backgroundColor = [TSAIInterpreterTheme panel];
        _languageCard.layer.cornerRadius = 22.0;
    }
    return _languageCard;
}

/// 语言块容器（`.lang`：圆角 18）
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
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.userInteractionEnabled = NO;
    return label;
}

- (UIControl *)sourceTile {
    if (!_sourceTile) _sourceTile = [self tileWithBackground:[TSAIInterpreterTheme jade50] action:@selector(onSourceTileTap)];
    return _sourceTile;
}

- (UILabel *)sourceKeyLabel {
    if (!_sourceKeyLabel) {
        _sourceKeyLabel = [self tileLabelWithFont:[TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600]
                                            color:[TSAIInterpreterTheme jade]];
        _sourceKeyLabel.text = TSLocalizedString(@"ai_interpreter.setup_src_key");
    }
    return _sourceKeyLabel;
}

- (UILabel *)sourceValueLabel {
    if (!_sourceValueLabel) {
        _sourceValueLabel = [self tileLabelWithFont:[TSAIInterpreterTheme fontOfSize:22.0 cssWeight:700]
                                              color:[TSAIInterpreterTheme ink]];
    }
    return _sourceValueLabel;
}

- (UILabel *)sourceHintLabel {
    if (!_sourceHintLabel) {
        _sourceHintLabel = [self tileLabelWithFont:[TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400]
                                             color:[TSAIInterpreterTheme muted]];
    }
    return _sourceHintLabel;
}

- (UIControl *)targetTile {
    if (!_targetTile) _targetTile = [self tileWithBackground:[TSAIInterpreterTheme cobalt50] action:@selector(onTargetTileTap)];
    return _targetTile;
}

- (UILabel *)targetKeyLabel {
    if (!_targetKeyLabel) {
        _targetKeyLabel = [self tileLabelWithFont:[TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600]
                                            color:[TSAIInterpreterTheme cobalt]];
        _targetKeyLabel.text = TSLocalizedString(@"ai_interpreter.setup_dst_key");
    }
    return _targetKeyLabel;
}

- (UILabel *)targetValueLabel {
    if (!_targetValueLabel) {
        _targetValueLabel = [self tileLabelWithFont:[TSAIInterpreterTheme fontOfSize:22.0 cssWeight:700]
                                              color:[TSAIInterpreterTheme ink]];
    }
    return _targetValueLabel;
}

- (UILabel *)targetHintLabel {
    if (!_targetHintLabel) {
        _targetHintLabel = [self tileLabelWithFont:[TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400]
                                             color:[TSAIInterpreterTheme muted]];
        _targetHintLabel.text = TSLocalizedString(@"ai_interpreter.setup_dst_hint");
    }
    return _targetHintLabel;
}

- (UIButton *)swapButton {
    if (!_swapButton) {
        _swapButton = [TSAIInterpreterTheme roundButtonWithSymbol:@"arrow.up.arrow.down"
                                                        pointSize:16.0
                                                       background:[TSAIInterpreterTheme ink]
                                                             tint:[UIColor whiteColor]
                                                           target:self
                                                           action:@selector(onSwapTap)];
        _swapButton.layer.cornerRadius = 20.0;
    }
    return _swapButton;
}

- (UIView *)deviceCard {
    if (!_deviceCard) {
        _deviceCard = [[UIView alloc] init];
        _deviceCard.backgroundColor = [TSAIInterpreterTheme panel];
        _deviceCard.layer.cornerRadius = 22.0;
    }
    return _deviceCard;
}

/// 行标题（`.row .hd .t`：15px / 600）
- (UILabel *)rowTitleLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [TSAIInterpreterTheme fontOfSize:15.0 cssWeight:600];
    label.textColor = [TSAIInterpreterTheme ink];
    return label;
}

/// 行提示（`.row .hd .hint`：12px / muted / 右对齐）
- (UILabel *)rowHintLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400];
    label.textColor = [TSAIInterpreterTheme muted];
    label.textAlignment = NSTextAlignmentRight;
    label.numberOfLines = 2;
    return label;
}

- (UILabel *)pickupTitleLabel {
    if (!_pickupTitleLabel) _pickupTitleLabel = [self rowTitleLabelWithText:TSLocalizedString(@"ai_interpreter.setup_row_pickup")];
    return _pickupTitleLabel;
}

- (UILabel *)pickupHintLabel {
    if (!_pickupHintLabel) _pickupHintLabel = [self rowHintLabel];
    return _pickupHintLabel;
}

- (UILabel *)outputTitleLabel {
    if (!_outputTitleLabel) _outputTitleLabel = [self rowTitleLabelWithText:TSLocalizedString(@"ai_interpreter.setup_row_output")];
    return _outputTitleLabel;
}

- (UILabel *)outputHintLabel {
    if (!_outputHintLabel) _outputHintLabel = [self rowHintLabel];
    return _outputHintLabel;
}

- (UIView *)hairline {
    if (!_hairline) {
        _hairline = [[UIView alloc] init];
        _hairline.backgroundColor = [TSAIInterpreterTheme paper];
    }
    return _hairline;
}

- (TSAIInterpreterDeviceCell *)cellWithKind:(TSAIInterpreterDeviceCellKind)kind
                                   optionId:(NSInteger)optionId
                                     symbol:(NSString *)symbol
                                      title:(NSString *)title {
    TSAIInterpreterDeviceCell *cell = [[TSAIInterpreterDeviceCell alloc] initWithFrame:CGRectZero];
    cell.kind = kind;
    cell.optionId = optionId;
    [cell setSymbol:symbol title:title];
    [cell addTarget:self action:@selector(onDeviceCellTap:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (NSArray<TSAIInterpreterDeviceCell *> *)pickupCells {
    if (!_pickupCells) {
        _pickupCells = @[
            [self cellWithKind:TSAIInterpreterDeviceCellKindInput optionId:TSAIInterpretationPickupPhone
                        symbol:@"iphone" title:[self titleForPickup:TSAIInterpretationPickupPhone]],
            [self cellWithKind:TSAIInterpreterDeviceCellKindInput optionId:TSAIInterpretationPickupEarbuds
                        symbol:@"headphones" title:[self titleForPickup:TSAIInterpretationPickupEarbuds]],
            [self cellWithKind:TSAIInterpreterDeviceCellKindInput optionId:TSAIInterpretationPickupChargingCase
                        symbol:@"case" title:[self titleForPickup:TSAIInterpretationPickupChargingCase]],
        ];
    }
    return _pickupCells;
}

- (NSArray<TSAIInterpreterDeviceCell *> *)outputCells {
    if (!_outputCells) {
        _outputCells = @[
            [self cellWithKind:TSAIInterpreterDeviceCellKindOutput optionId:TSAIInterpreterOutputOptionAuto
                        symbol:@"sparkles" title:[self titleForOutputOption:TSAIInterpreterOutputOptionAuto]],
            [self cellWithKind:TSAIInterpreterDeviceCellKindOutput optionId:TSAIInterpreterOutputOptionPhone
                        symbol:@"speaker.wave.2" title:[self titleForOutputOption:TSAIInterpreterOutputOptionPhone]],
            [self cellWithKind:TSAIInterpreterDeviceCellKindOutput optionId:TSAIInterpreterOutputOptionCase
                        symbol:@"case" title:[self titleForOutputOption:TSAIInterpreterOutputOptionCase]],
            [self cellWithKind:TSAIInterpreterDeviceCellKindOutput optionId:TSAIInterpreterOutputOptionMute
                        symbol:@"speaker.slash" title:[self titleForOutputOption:TSAIInterpreterOutputOptionMute]],
        ];
    }
    return _outputCells;
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
        _reasonLabel.numberOfLines = 3;
    }
    return _reasonLabel;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [TSAIInterpreterTheme ctaButtonWithTitle:TSLocalizedString(@"ai_interpreter.setup_start")
                                                         symbol:@"mic"
                                                     background:[TSAIInterpreterTheme ink]
                                                           tint:[UIColor whiteColor]
                                                      cssWeight:700
                                                         target:self
                                                         action:@selector(onStartTap)];
    }
    return _startButton;
}

@end
