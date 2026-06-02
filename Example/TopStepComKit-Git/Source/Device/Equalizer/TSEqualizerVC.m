//
//  TSEqualizerVC.m
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/5/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSEqualizerVC.h"
#import <TopStepComKit/TopStepComKit.h>

static const CGFloat kPad             = 16.f;
static const CGFloat kCornerRadius    = 12.f;
static const CGFloat kStatusCardH     = 72.f;
static const CGFloat kPresetCellH     = 44.f;
static const CGFloat kPresetGridSpace = 10.f;
static const CGFloat kBandsCardH      = 280.f;
static const CGFloat kResultCardH     = 56.f;
static const CGFloat kApplyBarH       = 88.f;
static const CGFloat kSliderRangeDb   = 12.f;
static const CGFloat kToastDuration   = 1.6f;
static const CGFloat kToastFade       = 0.2f;

@interface TSEqualizerVC ()

// 状态卡
@property (nonatomic, strong) UIView   *statusCard;
@property (nonatomic, strong) UILabel  *statusTitleLabel;
@property (nonatomic, strong) UILabel  *statusDetailLabel;

// 预设区
@property (nonatomic, strong) UIView   *presetCard;
@property (nonatomic, strong) UILabel  *presetSectionLabel;
@property (nonatomic, strong) NSArray<UIButton *> *presetButtons;

// 频段区
@property (nonatomic, strong) UIView   *bandsCard;
@property (nonatomic, strong) UILabel  *bandsSectionLabel;
@property (nonatomic, strong) UILabel  *bandsBadgeLabel;
@property (nonatomic, strong) NSMutableArray<UISlider *> *bandSliders;
@property (nonatomic, strong) NSMutableArray<UILabel *>  *bandValueLabels;
@property (nonatomic, strong) NSMutableArray<UILabel *>  *bandIndexLabels;

// 结果区（Apply 结果展示）
@property (nonatomic, strong) UIView   *resultCard;
@property (nonatomic, strong) UILabel  *resultLabel;

// 底部 Apply
@property (nonatomic, strong) UIView   *applyBar;
@property (nonatomic, strong) UIButton *applyButton;

// 数据
@property (nonatomic, strong) NSArray<TSEqualizerModel *> *presetModels;
@property (nonatomic, strong) TSEqualizerModel *deviceModel;     // 设备当前生效模型（用于 Apply 失败回滚）
@property (nonatomic, strong) TSEqualizerModel *editingModel;    // 编辑中模型
@property (nonatomic, assign) BOOL isApplying;

@end

@implementation TSEqualizerVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadPresetsAndCurrent];
}

#pragma mark - Override Base Setup

- (void)initData {
    [super initData];
    self.title = @"Equalizer";
    _bandSliders     = [NSMutableArray array];
    _bandValueLabels = [NSMutableArray array];
    _bandIndexLabels = [NSMutableArray array];
}

- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;

    [self.view addSubview:self.statusCard];
    [self.statusCard addSubview:self.statusTitleLabel];
    [self.statusCard addSubview:self.statusDetailLabel];

    [self.view addSubview:self.presetCard];
    [self.presetCard addSubview:self.presetSectionLabel];
    [self buildPresetButtonsIntoCard];

    [self.view addSubview:self.bandsCard];
    [self.bandsCard addSubview:self.bandsSectionLabel];
    [self.bandsCard addSubview:self.bandsBadgeLabel];

    [self.view addSubview:self.resultCard];
    [self.resultCard addSubview:self.resultLabel];

    [self.view addSubview:self.applyBar];
    [self.applyBar addSubview:self.applyButton];
}

- (void)layoutViews {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    if (w <= 0) return;

    CGFloat top = self.ts_navigationBarTotalHeight;
    if (top <= 0) top = self.view.safeAreaInsets.top;

    // 状态卡
    self.statusCard.frame = CGRectMake(kPad, top + 8.f, w - kPad * 2, kStatusCardH);
    self.statusTitleLabel.frame  = CGRectMake(12.f, 12.f, w - kPad * 2 - 24.f, 22.f);
    self.statusDetailLabel.frame = CGRectMake(12.f, 36.f, w - kPad * 2 - 24.f, 22.f);

    // 预设卡
    CGFloat presetCardTop = CGRectGetMaxY(self.statusCard.frame) + 12.f;
    CGFloat presetCardH   = [self heightOfPresetCardWithWidth:w - kPad * 2];
    self.presetCard.frame = CGRectMake(kPad, presetCardTop, w - kPad * 2, presetCardH);
    self.presetSectionLabel.frame = CGRectMake(12.f, 10.f, w - kPad * 2 - 24.f, 20.f);
    [self layoutPresetButtons];

    // 频段卡
    CGFloat bandsCardTop = CGRectGetMaxY(self.presetCard.frame) + 12.f;
    self.bandsCard.frame = CGRectMake(kPad, bandsCardTop, w - kPad * 2, kBandsCardH);
    self.bandsSectionLabel.frame = CGRectMake(12.f, 10.f, 200.f, 20.f);
    [self.bandsBadgeLabel sizeToFit];
    CGFloat badgeW = MAX(56.f, CGRectGetWidth(self.bandsBadgeLabel.bounds) + 16.f);
    self.bandsBadgeLabel.frame = CGRectMake(CGRectGetWidth(self.bandsCard.bounds) - 12.f - badgeW,
                                            10.f, badgeW, 20.f);
    [self layoutBandSliders];

    // 结果卡
    CGFloat resultCardTop = CGRectGetMaxY(self.bandsCard.frame) + 12.f;
    self.resultCard.frame = CGRectMake(kPad, resultCardTop, w - kPad * 2, kResultCardH);
    self.resultLabel.frame = CGRectMake(12.f, 0, w - kPad * 2 - 24.f, kResultCardH);

    // 底部 Apply
    CGFloat bottomSafe = self.view.safeAreaInsets.bottom;
    CGFloat barH = kApplyBarH + bottomSafe;
    self.applyBar.frame  = CGRectMake(0, h - barH, w, barH);
    self.applyButton.frame = CGRectMake(kPad, 12.f, w - kPad * 2, kApplyBarH - 24.f);
}

#pragma mark - 私有方法

/// 取均衡器接口
- (id<TSEqualizerInterface>)equalizerInterface {
    return [TopStepComKit sharedInstance].equalizer;
}

/// 加载预设 + 设备当前模型
- (void)loadPresetsAndCurrent {
    if (!self.equalizerInterface) {
        [self showToast:@"Equalizer interface unavailable"];
        return;
    }

    self.presetModels = [self.equalizerInterface presetEqualizerModels] ?: @[];
    [self refreshPresetTitles];

    [self showLoading];
    TSLog(@"[TSEqualizerVC] getCurrentEqualizerModel: ->");
    __weak typeof(self) weakSelf = self;
    [self.equalizerInterface getCurrentEqualizerModel:^(TSEqualizerModel * _Nullable equalizerModel, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        TSLog(@"[TSEqualizerVC] getCurrentEqualizerModel: <- type=%lu, preset=%lu, gainCount=%lu, error=%@",
              (unsigned long)equalizerModel.equalizerType,
              (unsigned long)equalizerModel.presetType,
              (unsigned long)equalizerModel.gainValues.count,
              error.localizedDescription);
        [self hideLoading];
        if (error || !equalizerModel) {
            [self showToast:error.localizedDescription ?: @"Failed to fetch current EQ"];
            return;
        }
        self.deviceModel = equalizerModel;
        self.editingModel = [self copyEqualizerModel:equalizerModel];
        [self rebuildBandSlidersForGainCount:equalizerModel.gainValues.count];
        [self.view setNeedsLayout];
        [self refreshAllUI];
    }];
}

/// 用编辑模型刷新整体 UI
- (void)refreshAllUI {
    [self refreshStatusCard];
    [self refreshPresetSelection];
    [self refreshBandSliders];
    [self refreshApplyButton];
}

/// 状态卡：当前预设/自定义 + 频段数
- (void)refreshStatusCard {
    TSEqualizerModel *model = self.editingModel ?: self.deviceModel;
    NSString *displayName = [self displayNameForModel:model] ?: @"-";
    self.statusTitleLabel.text = [NSString stringWithFormat:@"Current: %@", displayName];

    NSString *typeText = (model.equalizerType == TSEqualizerTypeCustom) ? @"Custom" : @"Preset";
    NSUInteger bandCount = model.gainValues.count;
    self.statusDetailLabel.text = [NSString stringWithFormat:@"Type: %@ · %lu bands",
                                   typeText, (unsigned long)bandCount];
}

/// 预设按钮文案（语言跟随系统）
- (void)refreshPresetTitles {
    [self.presetButtons enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        TSEqualizerModel *preset = idx < self.presetModels.count ? self.presetModels[idx] : nil;
        NSString *title = [self displayNameForModel:preset];
        if (title.length == 0) {
            title = [self fallbackPresetTitleAtIndex:idx];
        }
        [btn setTitle:title forState:UIControlStateNormal];
    }];
}

/// 预设按钮高亮态：仅当编辑模型为预设且 presetType 匹配时高亮
- (void)refreshPresetSelection {
    TSEqualizerModel *model = self.editingModel;
    BOOL isPreset = model.equalizerType == TSEqualizerTypePreset;
    [self.presetButtons enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        TSEqualizerModel *preset = idx < self.presetModels.count ? self.presetModels[idx] : nil;
        BOOL selected = isPreset && preset.presetType == model.presetType;
        [self setPresetButton:btn selected:selected];
    }];
}

/// 频段滑条根据增益数组刷新值与 label
- (void)refreshBandSliders {
    NSArray<NSNumber *> *gains = self.editingModel.gainValues;
    [self.bandSliders enumerateObjectsUsingBlock:^(UISlider *slider, NSUInteger idx, BOOL *stop) {
        if (idx >= gains.count) return;
        NSInteger value = [self clampedDb:gains[idx].doubleValue];
        slider.value = value;
        UILabel *valueLabel = idx < self.bandValueLabels.count ? self.bandValueLabels[idx] : nil;
        valueLabel.text = [self dbDisplayString:value];
    }];
}

/// Apply 按钮可用态：编辑模型与设备模型不一致才可点
- (void)refreshApplyButton {
    BOOL dirty = ![self isEqualizerModel:self.editingModel equalTo:self.deviceModel];
    BOOL canApply = dirty && !self.isApplying && self.equalizerInterface != nil;
    self.applyButton.enabled = canApply;
    self.applyButton.alpha = canApply ? 1.f : 0.5f;
    NSString *title = self.isApplying ? @"Applying…" : @"Apply";
    [self.applyButton setTitle:title forState:UIControlStateNormal];
}

/// 根据上报的频段数动态创建滑条与对应标签
- (void)rebuildBandSlidersForGainCount:(NSUInteger)gainCount {
    for (UISlider *slider in self.bandSliders) [slider removeFromSuperview];
    for (UILabel *label in self.bandValueLabels) [label removeFromSuperview];
    for (UILabel *label in self.bandIndexLabels) [label removeFromSuperview];
    [self.bandSliders removeAllObjects];
    [self.bandValueLabels removeAllObjects];
    [self.bandIndexLabels removeAllObjects];

    for (NSUInteger idx = 0; idx < gainCount; idx++) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = -kSliderRangeDb;
        slider.maximumValue = kSliderRangeDb;
        slider.value = 0;
        slider.tintColor = TSColor_Primary;
        slider.tag = (NSInteger)idx;
        [slider addTarget:self action:@selector(onBandSliderValueChanged:)
         forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(onBandSliderTouchUp:)
         forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [self.bandsCard addSubview:slider];
        [self.bandSliders addObject:slider];

        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.font = [UIFont systemFontOfSize:11.f weight:UIFontWeightMedium];
        valueLabel.textColor = TSColor_TextPrimary;
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.text = @"0";
        [self.bandsCard addSubview:valueLabel];
        [self.bandValueLabels addObject:valueLabel];

        UILabel *indexLabel = [[UILabel alloc] init];
        indexLabel.font = TSFont_Caption;
        indexLabel.textColor = TSColor_TextSecondary;
        indexLabel.textAlignment = NSTextAlignmentCenter;
        indexLabel.text = [NSString stringWithFormat:@"B%lu", (unsigned long)(idx + 1)];
        [self.bandsCard addSubview:indexLabel];
        [self.bandIndexLabels addObject:indexLabel];
    }

    self.bandsBadgeLabel.text = (gainCount == 0) ? @"No bands"
        : [NSString stringWithFormat:@"%lu bands", (unsigned long)gainCount];
}

/// 频段滑条布局：每段一列竖向 UISlider（绕中心旋转 -90°），值上大下小
- (void)layoutBandSliders {
    NSUInteger count = self.bandSliders.count;
    if (count == 0) return;

    CGFloat cardW = CGRectGetWidth(self.bandsCard.bounds);
    CGFloat headerH = 40.f;          // section label 占高
    CGFloat valueLabelH = 14.f;      // 顶部数值
    CGFloat indexLabelH = 16.f;      // 底部频段编号
    CGFloat horizontalInset = 12.f;
    CGFloat verticalInset = 8.f;
    CGFloat sliderThickness = 36.f;  // 旋转后的可视横向宽度，给拨钮留空间

    CGFloat columnW = (cardW - horizontalInset * 2) / (CGFloat)count;
    CGFloat columnTop = headerH;
    CGFloat columnBottom = kBandsCardH - 8.f;
    CGFloat sliderAreaTop = columnTop + valueLabelH + verticalInset;
    CGFloat sliderAreaBottom = columnBottom - indexLabelH - verticalInset;
    CGFloat sliderLength = sliderAreaBottom - sliderAreaTop;
    if (sliderLength < 60.f) sliderLength = 60.f;

    for (NSUInteger idx = 0; idx < count; idx++) {
        CGFloat columnX = horizontalInset + columnW * idx;
        CGFloat columnCenterX = columnX + columnW / 2.f;
        CGFloat sliderCenterY = (sliderAreaTop + sliderAreaBottom) / 2.f;

        UILabel *valueLabel = self.bandValueLabels[idx];
        valueLabel.frame = CGRectMake(columnX, columnTop, columnW, valueLabelH);

        UISlider *slider = self.bandSliders[idx];
        // 先复位 transform 再设 frame，避免旋转态下设 frame 出现错位
        slider.transform = CGAffineTransformIdentity;
        slider.frame = CGRectMake(0, 0, sliderLength, sliderThickness);
        slider.center = CGPointMake(columnCenterX, sliderCenterY);
        slider.transform = CGAffineTransformMakeRotation(-M_PI_2);

        UILabel *indexLabel = self.bandIndexLabels[idx];
        indexLabel.frame = CGRectMake(columnX, columnBottom - indexLabelH, columnW, indexLabelH);
    }
}

/// 创建预设按钮（2 行 3 列）
- (void)buildPresetButtonsIntoCard {
    NSMutableArray<UIButton *> *btns = [NSMutableArray arrayWithCapacity:6];
    for (NSUInteger idx = 0; idx < 6; idx++) {
        UIButton *btn = [self makePresetButton];
        btn.tag = (NSInteger)idx;
        [btn addTarget:self action:@selector(onPresetTapped:)
      forControlEvents:UIControlEventTouchUpInside];
        [self.presetCard addSubview:btn];
        [btns addObject:btn];
    }
    self.presetButtons = [btns copy];
}

/// 预设按钮 2×3 网格布局
- (void)layoutPresetButtons {
    if (self.presetButtons.count == 0) return;
    CGFloat cardW = CGRectGetWidth(self.presetCard.bounds);
    CGFloat innerPad = 12.f;
    CGFloat top = 36.f;
    NSInteger columns = 3;
    CGFloat cellW = (cardW - innerPad * 2 - kPresetGridSpace * (columns - 1)) / columns;
    CGFloat cellH = kPresetCellH;

    [self.presetButtons enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        NSInteger row = idx / columns;
        NSInteger col = idx % columns;
        CGFloat x = innerPad + col * (cellW + kPresetGridSpace);
        CGFloat y = top + row * (cellH + kPresetGridSpace);
        btn.frame = CGRectMake(x, y, cellW, cellH);
    }];
}

/// 计算预设卡总高度
- (CGFloat)heightOfPresetCardWithWidth:(CGFloat)cardW {
    CGFloat top = 36.f;
    CGFloat innerBottom = 12.f;
    NSInteger rows = 2;
    return top + rows * kPresetCellH + (rows - 1) * kPresetGridSpace + innerBottom;
}

/// 取模型显示名（中文环境优先 chineseName）
- (NSString *)displayNameForModel:(TSEqualizerModel *)model {
    if (!model) return nil;
    BOOL preferChinese = [self preferChineseDisplay];
    if (preferChinese && model.chineseName.length > 0) return model.chineseName;
    if (model.name.length > 0) return model.name;
    if (model.chineseName.length > 0) return model.chineseName;
    return nil;
}

/// 当系统语言为中文时使用中文显示
- (BOOL)preferChineseDisplay {
    NSString *langCode = [[NSLocale preferredLanguages] firstObject];
    return [langCode hasPrefix:@"zh"];
}

/// 预设回退文案（接口未提供 name 时兜底）
- (NSString *)fallbackPresetTitleAtIndex:(NSUInteger)idx {
    NSArray<NSString *> *titles = @[ @"Default", @"Pop", @"Rock", @"Jazz", @"Classical", @"Country" ];
    return idx < titles.count ? titles[idx] : @"-";
}

/// 增益值钳制
/// 增益值钳制为 [-12, +12] 整数
- (NSInteger)clampedDb:(CGFloat)value {
    NSInteger rounded = (NSInteger)lround(value);
    if (rounded < (NSInteger)-kSliderRangeDb) rounded = (NSInteger)-kSliderRangeDb;
    if (rounded > (NSInteger)kSliderRangeDb)  rounded = (NSInteger)kSliderRangeDb;
    return rounded;
}

/// 频段数值文案：整数，正值带 +
- (NSString *)dbDisplayString:(NSInteger)value {
    if (value == 0) return @"0";
    return [NSString stringWithFormat:@"%+ld", (long)value];
}

/// 深拷贝当前模型，避免编辑直接污染设备模型
- (TSEqualizerModel *)copyEqualizerModel:(TSEqualizerModel *)source {
    TSEqualizerModel *target = [[TSEqualizerModel alloc] init];
    target.equalizerType = source.equalizerType;
    target.presetType    = source.presetType;
    target.gainValues    = [source.gainValues copy] ?: @[];
    target.name          = [source.name copy];
    target.chineseName   = [source.chineseName copy];
    return target;
}

/// 比较两个模型是否一致
- (BOOL)isEqualizerModel:(TSEqualizerModel *)lhs equalTo:(TSEqualizerModel *)rhs {
    if (lhs == rhs) return YES;
    if (!lhs || !rhs) return NO;
    if (lhs.equalizerType != rhs.equalizerType) return NO;
    if (lhs.equalizerType == TSEqualizerTypePreset && lhs.presetType != rhs.presetType) return NO;
    NSArray<NSNumber *> *l = lhs.gainValues ?: @[];
    NSArray<NSNumber *> *r = rhs.gainValues ?: @[];
    if (l.count != r.count) return NO;
    for (NSUInteger idx = 0; idx < l.count; idx++) {
        if (fabs(l[idx].doubleValue - r[idx].doubleValue) > 0.01) return NO;
    }
    return YES;
}

/// 创建预设按钮
- (UIButton *)makePresetButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    btn.layer.cornerRadius = 10.f;
    btn.layer.borderWidth = 1.f;
    [self setPresetButton:btn selected:NO];
    return btn;
}

/// 切换预设按钮选中态
- (void)setPresetButton:(UIButton *)btn selected:(BOOL)selected {
    if (selected) {
        btn.backgroundColor = TSColor_Primary;
        btn.layer.borderColor = TSColor_Primary.CGColor;
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    } else {
        btn.backgroundColor = TSColor_Card;
        btn.layer.borderColor = TSColor_Separator.CGColor;
        [btn setTitleColor:TSColor_TextPrimary forState:UIControlStateNormal];
    }
}

/// 展示 Apply 结果：success 绿底白字，failure 浅红底红字
- (void)showApplyResultSuccess:(BOOL)success message:(NSString *)message {
    NSString *text = message.length > 0 ? message : (success ? @"Apply succeeded" : @"Apply failed");
    self.resultLabel.text = text;
    if (success) {
        self.resultCard.backgroundColor = [UIColor colorWithRed:0.16f green:0.65f blue:0.27f alpha:1.f];
        self.resultLabel.textColor = UIColor.whiteColor;
    } else {
        self.resultCard.backgroundColor = [UIColor colorWithRed:1.00f green:0.92f blue:0.92f alpha:1.f];
        self.resultLabel.textColor = [UIColor colorWithRed:0.85f green:0.18f blue:0.18f alpha:1.f];
    }
    self.resultCard.hidden = NO;
}

/// 清除上一次 Apply 结果（用户开始新一次编辑时调用）
- (void)clearApplyResult {
    self.resultLabel.text = nil;
    self.resultCard.backgroundColor = [UIColor clearColor];
    self.resultCard.hidden = YES;
}

/// 简易 toast
- (void)showToast:(NSString *)msg {
    if (msg.length == 0) return;
    UIView *toast = [[UIView alloc] init];
    toast.backgroundColor = [UIColor colorWithWhite:0.15f alpha:0.9f];
    toast.layer.cornerRadius = 10.f;
    toast.alpha = 0;

    UILabel *label = [[UILabel alloc] init];
    label.text = msg;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;

    CGFloat maxW = CGRectGetWidth(self.view.bounds) - 80.f;
    CGSize sz = [label sizeThatFits:CGSizeMake(maxW - 32, CGFLOAT_MAX)];
    CGFloat tw = MIN(sz.width + 32, maxW);
    CGFloat th = sz.height + 20.f;
    toast.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - tw) / 2.f,
                             CGRectGetHeight(self.view.bounds) * 0.7f, tw, th);
    label.frame = CGRectMake(16, 10, tw - 32, sz.height);
    [toast addSubview:label];
    [self.view addSubview:toast];

    [UIView animateWithDuration:kToastFade animations:^{ toast.alpha = 1; } completion:^(BOOL _) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kToastDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:kToastFade animations:^{ toast.alpha = 0; } completion:^(BOOL __) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - 事件响应

- (void)onPresetTapped:(UIButton *)sender {
    NSInteger idx = sender.tag;
    if (idx < 0 || idx >= (NSInteger)self.presetModels.count) return;

    TSEqualizerModel *preset = self.presetModels[idx];
    if (preset.gainValues.count == 0) {
        [self showToast:@"Preset has no band data"];
        return;
    }

    if (preset.gainValues.count != self.editingModel.gainValues.count) {
        [self rebuildBandSlidersForGainCount:preset.gainValues.count];
        [self.view setNeedsLayout];
    }

    self.editingModel = [self copyEqualizerModel:preset];
    [self clearApplyResult];
    [self refreshAllUI];
}

- (void)onBandSliderValueChanged:(UISlider *)slider {
    NSInteger idx = slider.tag;
    if (idx < 0 || idx >= (NSInteger)self.editingModel.gainValues.count) return;

    NSMutableArray<NSNumber *> *gains = [self.editingModel.gainValues mutableCopy];
    NSInteger value = [self clampedDb:slider.value];
    gains[idx] = @(value);
    self.editingModel.gainValues = [gains copy];

    self.editingModel.equalizerType = TSEqualizerTypeCustom;
    self.editingModel.presetType    = TSEqualizerPresetTypeUnknown;

    UILabel *valueLabel = idx < (NSInteger)self.bandValueLabels.count ? self.bandValueLabels[idx] : nil;
    valueLabel.text = [self dbDisplayString:value];

    [self clearApplyResult];
    [self refreshStatusCard];
    [self refreshPresetSelection];
    [self refreshApplyButton];
}

- (void)onBandSliderTouchUp:(UISlider *)slider {
    NSInteger idx = slider.tag;
    if (idx < 0 || idx >= (NSInteger)self.editingModel.gainValues.count) return;
    NSMutableArray<NSNumber *> *gains = [self.editingModel.gainValues mutableCopy];
    NSInteger value = [self clampedDb:slider.value];
    gains[idx] = @(value);
    self.editingModel.gainValues = [gains copy];
    slider.value = value;
    [self refreshApplyButton];
}

- (void)onApplyTapped {
    if (self.isApplying) return;
    if (![self.editingModel isKindOfClass:[TSEqualizerModel class]]) return;

    NSError *modelError = [self.editingModel doesModelHasError];
    if (modelError) {
        [self showApplyResultSuccess:NO message:modelError.localizedDescription ?: @"Invalid equalizer"];
        return;
    }

    self.isApplying = YES;
    [self refreshApplyButton];

    TSEqualizerModel *toApply = [self copyEqualizerModel:self.editingModel];
    __weak typeof(self) weakSelf = self;
    [self.equalizerInterface setEqualizerModel:toApply
                                    completion:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        TSLog(@"[TSEqualizerVC] setEqualizerModel: <- success=%d, error=%@",
              success, error.localizedDescription);
        self.isApplying = NO;
        if (success) {
            self.deviceModel  = toApply;
            self.editingModel = [self copyEqualizerModel:toApply];
            [self showApplyResultSuccess:YES message:@"Apply succeeded"];
        } else {
            [self showApplyResultSuccess:NO message:error.localizedDescription ?: @"Apply failed"];
        }
        [self refreshAllUI];
    }];
}

#pragma mark - 属性懒加载

- (UIView *)statusCard {
    if (!_statusCard) {
        _statusCard = [[UIView alloc] init];
        _statusCard.backgroundColor = TSColor_Card;
        _statusCard.layer.cornerRadius = kCornerRadius;
    }
    return _statusCard;
}

- (UILabel *)statusTitleLabel {
    if (!_statusTitleLabel) {
        _statusTitleLabel = [[UILabel alloc] init];
        _statusTitleLabel.font = TSFont_H2;
        _statusTitleLabel.textColor = TSColor_TextPrimary;
    }
    return _statusTitleLabel;
}

- (UILabel *)statusDetailLabel {
    if (!_statusDetailLabel) {
        _statusDetailLabel = [[UILabel alloc] init];
        _statusDetailLabel.font = TSFont_Caption;
        _statusDetailLabel.textColor = TSColor_TextSecondary;
    }
    return _statusDetailLabel;
}

- (UIView *)presetCard {
    if (!_presetCard) {
        _presetCard = [[UIView alloc] init];
        _presetCard.backgroundColor = TSColor_Card;
        _presetCard.layer.cornerRadius = kCornerRadius;
    }
    return _presetCard;
}

- (UILabel *)presetSectionLabel {
    if (!_presetSectionLabel) {
        _presetSectionLabel = [[UILabel alloc] init];
        _presetSectionLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightSemibold];
        _presetSectionLabel.textColor = TSColor_TextPrimary;
        _presetSectionLabel.text = @"Presets";
    }
    return _presetSectionLabel;
}

- (UIView *)bandsCard {
    if (!_bandsCard) {
        _bandsCard = [[UIView alloc] init];
        _bandsCard.backgroundColor = TSColor_Card;
        _bandsCard.layer.cornerRadius = kCornerRadius;
    }
    return _bandsCard;
}

- (UILabel *)bandsSectionLabel {
    if (!_bandsSectionLabel) {
        _bandsSectionLabel = [[UILabel alloc] init];
        _bandsSectionLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightSemibold];
        _bandsSectionLabel.textColor = TSColor_TextPrimary;
        _bandsSectionLabel.text = @"Bands (单位：dB)";
    }
    return _bandsSectionLabel;
}

- (UILabel *)bandsBadgeLabel {
    if (!_bandsBadgeLabel) {
        _bandsBadgeLabel = [[UILabel alloc] init];
        _bandsBadgeLabel.font = TSFont_Caption;
        _bandsBadgeLabel.textColor = TSColor_TextSecondary;
        _bandsBadgeLabel.textAlignment = NSTextAlignmentRight;
        _bandsBadgeLabel.text = @"-";
    }
    return _bandsBadgeLabel;
}

- (UIView *)resultCard {
    if (!_resultCard) {
        _resultCard = [[UIView alloc] init];
        _resultCard.layer.cornerRadius = kCornerRadius;
        _resultCard.clipsToBounds = YES;
        _resultCard.hidden = YES;
    }
    return _resultCard;
}

- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
        _resultLabel.numberOfLines = 0;
        _resultLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _resultLabel;
}

- (UIView *)applyBar {
    if (!_applyBar) {
        _applyBar = [[UIView alloc] init];
        _applyBar.backgroundColor = TSColor_Card;
    }
    return _applyBar;
}

- (UIButton *)applyButton {
    if (!_applyButton) {
        _applyButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _applyButton.backgroundColor = TSColor_Primary;
        _applyButton.layer.cornerRadius = kCornerRadius;
        [_applyButton setTitle:@"Apply" forState:UIControlStateNormal];
        [_applyButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _applyButton.titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
        [_applyButton addTarget:self action:@selector(onApplyTapped)
               forControlEvents:UIControlEventTouchUpInside];
        _applyButton.enabled = NO;
        _applyButton.alpha = 0.5f;
    }
    return _applyButton;
}

@end
