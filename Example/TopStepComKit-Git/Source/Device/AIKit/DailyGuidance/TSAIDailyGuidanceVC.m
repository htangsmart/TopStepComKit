//
//  TSAIDailyGuidanceVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/9.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIDailyGuidanceVC.h"

#import <TopStepComKit/TopStepComKit.h>

#import "TSAIGuidanceResultCard.h"

// 三项得分字段索引
typedef NS_ENUM(NSInteger, TSGuidanceField) {
    TSGuidanceFieldSleep = 0,   // 睡眠得分（0-100）
    TSGuidanceFieldHRV,         // HRV 得分（0-100）
    TSGuidanceFieldActivity,    // 活动得分（0-10）
    TSGuidanceFieldCount,
};

static const CGFloat kPad     = 16.f;   // 页面与卡片内边距
static const CGFloat kRowH    = 62.f;   // 单个得分行高
static const CGFloat kBtnH    = 48.f;   // 主按钮高度
static const CGFloat kPresetH = 38.f;   // 预设按钮高度

@interface TSAIDailyGuidanceVC ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView       *formCard;      // 三项得分卡片
@property (nonatomic, strong) NSArray<NSDictionary *> *fields;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *values;
@property (nonatomic, strong) NSMutableArray<UISlider *> *sliders;
@property (nonatomic, strong) NSMutableArray<UILabel *>  *titleLabels;
@property (nonatomic, strong) NSMutableArray<UILabel *>  *valueLabels;
@property (nonatomic, strong) NSArray<UIButton *> *presetButtons;
@property (nonatomic, strong) UIButton *generateButton;
@property (nonatomic, strong) TSAIGuidanceResultCard *resultCard;

@end

@implementation TSAIDailyGuidanceVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.fields = @[
        @{@"title": TSLocalizedString(@"ai_guidance.field.sleep_score"),    @"min": @0, @"max": @100, @"def": @84,  @"dec": @0},
        @{@"title": TSLocalizedString(@"ai_guidance.field.hrv_score"),       @"min": @0, @"max": @100, @"def": @74,  @"dec": @0},
        @{@"title": TSLocalizedString(@"ai_guidance.field.activity_score"),  @"min": @0, @"max": @10,  @"def": @8.6, @"dec": @1},
    ];
    self.values = [NSMutableArray array];
    for (NSDictionary *field in self.fields) {
        [self.values addObject:field[@"def"]];
    }
}

- (void)setupViews {
    [super setupViews];
    self.view.backgroundColor = TSColor_Background;
    [self.view addSubview:self.scrollView];

    self.sliders     = [NSMutableArray array];
    self.titleLabels = [NSMutableArray array];
    self.valueLabels = [NSMutableArray array];

    // 三项得分卡片
    self.formCard = [[UIView alloc] init];
    self.formCard.backgroundColor = TSColor_Card;
    self.formCard.layer.cornerRadius = TSRadius_MD;
    self.formCard.clipsToBounds = YES;
    [self.scrollView addSubview:self.formCard];

    for (NSInteger idx = 0; idx < (NSInteger)self.fields.count; idx++) {
        NSDictionary *field = self.fields[idx];

        UILabel *title = [[UILabel alloc] init];
        title.font = [UIFont systemFontOfSize:15.f];
        title.textColor = TSColor_TextPrimary;
        title.text = field[@"title"];
        [self.formCard addSubview:title];
        [self.titleLabels addObject:title];

        UILabel *value = [[UILabel alloc] init];
        value.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightSemibold];
        value.textColor = TSColor_Primary;
        value.textAlignment = NSTextAlignmentRight;
        [self.formCard addSubview:value];
        [self.valueLabels addObject:value];

        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = [field[@"min"] floatValue];
        slider.maximumValue = [field[@"max"] floatValue];
        slider.value        = [self.values[idx] floatValue];
        slider.minimumTrackTintColor = TSColor_Primary;
        slider.tag = idx;
        [slider addTarget:self action:@selector(ts_sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self.formCard addSubview:slider];
        [self.sliders addObject:slider];

        [self ts_updateValueLabelAtIndex:idx];
    }

    // 生成按钮
    self.generateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.generateButton.backgroundColor = TSColor_Primary;
    self.generateButton.layer.cornerRadius = TSRadius_MD;
    [self.generateButton setTitle:TSLocalizedString(@"ai_guidance.generate") forState:UIControlStateNormal];
    [self.generateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.generateButton.titleLabel.font = [UIFont systemFontOfSize:17.f weight:UIFontWeightSemibold];
    [self.generateButton addTarget:self action:@selector(ts_generateTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.generateButton];

    // 预设按钮
    NSArray<NSString *> *presetKeys = @[@"ai_guidance.preset.load",
                                        @"ai_guidance.preset.sleep",
                                        @"ai_guidance.preset.good"];
    NSMutableArray *presets = [NSMutableArray array];
    for (NSInteger idx = 0; idx < (NSInteger)presetKeys.count; idx++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.backgroundColor = TSColor_Card;
        button.layer.cornerRadius = 8.f;
        button.layer.borderWidth = 1.f;
        button.layer.borderColor = TSColor_Separator.CGColor;
        [button setTitle:TSLocalizedString(presetKeys[idx]) forState:UIControlStateNormal];
        [button setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13.f];
        button.tag = idx;
        [button addTarget:self action:@selector(ts_presetTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        [presets addObject:button];
    }
    self.presetButtons = presets;

    // 结果卡片
    self.resultCard = [[TSAIGuidanceResultCard alloc] initWithFrame:CGRectZero];
    self.resultCard.cardTitle = TSLocalizedString(@"ai_guidance.result");
    [self.scrollView addSubview:self.resultCard];

    // 首次用默认得分生成一份结果
    [self ts_generate];
}

#pragma mark - 交互

// 滑块拖动
- (void)ts_sliderChanged:(UISlider *)slider {
    NSInteger idx = slider.tag;
    NSInteger dec = [self.fields[idx][@"dec"] integerValue];
    CGFloat snapped = dec == 1 ? round(slider.value * 10.f) / 10.f : round(slider.value);
    self.values[idx] = @(snapped);
    [self ts_updateValueLabelAtIndex:idx];
}

// 预设点击：套用一组三项得分并生成
- (void)ts_presetTapped:(UIButton *)button {
    // 每组：睡眠得分 / HRV 得分 / 活动得分
    NSArray<NSArray<NSNumber *> *> *presets = @[
        @[@82, @62, @8.8],   // 负荷偏高：活动高但恢复弱
        @[@48, @76, @5.2],   // 睡眠偏低
        @[@88, @92, @6.4],   // 整体良好
    ];
    NSArray<NSNumber *> *preset = presets[button.tag];
    for (NSInteger idx = 0; idx < (NSInteger)self.fields.count; idx++) {
        self.values[idx] = preset[idx];
        self.sliders[idx].value = preset[idx].floatValue;
        [self ts_updateValueLabelAtIndex:idx];
    }
    [self ts_generate];
}

// 生成按钮点击
- (void)ts_generateTapped {
    [self ts_generate];
}

// 刷新某项得分数值标签
- (void)ts_updateValueLabelAtIndex:(NSInteger)idx {
    NSInteger dec = [self.fields[idx][@"dec"] integerValue];
    CGFloat value = [self.values[idx] floatValue];
    self.valueLabels[idx].text = dec == 1 ? [NSString stringWithFormat:@"%.1f", value]
                                          : [NSString stringWithFormat:@"%.0f", value];
}

#pragma mark - 生成引导

// 由三项得分反推健康模型并真正调用 SDK 生成引导
- (void)ts_generate {
    id<TSAIDailyGuidanceInterface> guidance = [[TopStepComKit sharedInstance] aiDailyGuidance];
    if (!guidance) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_guidance.unavailable")];
        return;
    }

    TSAIDailyGuidanceResult *result = [guidance generateWithSleepModel:[self ts_sleepModelForScore:[self.values[TSGuidanceFieldSleep] doubleValue]]
                                                              hrvModel:[self ts_hrvModelForScore:[self.values[TSGuidanceFieldHRV] doubleValue]]
                                                         activityModel:[self ts_activityModelForScore:[self.values[TSGuidanceFieldActivity] doubleValue]]];
    [self.resultCard configureWithMainText:result.mainText
                               actionItems:result.actionItems
                                disclaimer:result.disclaimer];
    [self.view setNeedsLayout];
}

// 睡眠：SDK 算法非线性，按 good/normal/poor 三档构造，保证档位与得分一致
- (TSSleepDailyModel *)ts_sleepModelForScore:(CGFloat)score {
    TSSleepSummary *summary = [[TSSleepSummary alloc] init];
    if (score >= 80.f) {
        summary.totalSleepDuration  = 8.0 * 3600.0;
        summary.deepSleepPercentage = 25;
        summary.awakePercentage     = 3;
    } else if (score >= 60.f) {
        summary.totalSleepDuration  = 6.5 * 3600.0;
        summary.deepSleepPercentage = 15;
        summary.awakePercentage     = 8;
    } else {
        summary.totalSleepDuration  = 4.0 * 3600.0;
        summary.deepSleepPercentage = 10;
        summary.awakePercentage     = 22;
    }
    TSSleepDailyModel *model = [[TSSleepDailyModel alloc] init];
    model.dailySummary = summary;
    return model;
}

// HRV：恢复得分 = avgValue / baseline * 100，取 baseline=100 即精确对应得分
- (TSHRVDailyModel *)ts_hrvModelForScore:(CGFloat)score {
    TSHRVDailyModel *model = [[TSHRVDailyModel alloc] init];
    model.baseline = 100;
    model.avgValue = (UInt16)round(score);
    return model;
}

// 活动：按 SDK 线性公式反推步数/运动时长/卡路里，使 SDK 重算得分等于输入
- (TSActivityDailyModel *)ts_activityModelForScore:(CGFloat)score {
    CGFloat stepPart = MIN(score, 4.f);
    CGFloat durPart  = MAX(0.f, MIN(score - 4.f, 3.f));
    CGFloat kcalPart = MAX(0.f, MIN(score - 7.f, 3.f));

    NSInteger steps             = (NSInteger)(stepPart / 4.f * 10000.f);
    NSInteger exercisesDuration = (NSInteger)(durPart / 3.f * 90.f * 60.f);
    NSInteger calories          = (NSInteger)(kcalPart / 3.f * 500.f * 1000.f);

    return [[TSActivityDailyModel alloc] initWithStartTime:0
                                                   endTime:0
                                                  duration:0
                                             activityItems:@[]
                                                     steps:steps
                                                  calories:calories
                                                  distance:0
                                          activityDuration:0
                                         exercisesDuration:exercisesDuration
                                            exercisesTimes:0
                                             activityTimes:0];
}

#pragma mark - 布局

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

- (void)layoutViews {
    [super layoutViews];

    CGFloat topInset = 0;
    if (@available(iOS 11.0, *)) {
        topInset = self.view.safeAreaInsets.top;
    }
    if (topInset == 0) topInset = 64;

    CGFloat screenW  = CGRectGetWidth(self.view.bounds);
    CGFloat screenH  = CGRectGetHeight(self.view.bounds);
    self.scrollView.frame = CGRectMake(0, topInset, screenW, screenH - topInset);

    CGFloat contentW = screenW - kPad * 2;
    CGFloat y = kPad;

    // 三项得分卡片
    CGFloat cardH = self.fields.count * kRowH;
    self.formCard.frame = CGRectMake(kPad, y, contentW, cardH);
    for (NSInteger idx = 0; idx < (NSInteger)self.fields.count; idx++) {
        CGFloat rowY = idx * kRowH;
        self.titleLabels[idx].frame = CGRectMake(kPad, rowY + 10.f, contentW * 0.5f, 20.f);
        self.valueLabels[idx].frame = CGRectMake(contentW * 0.5f - kPad, rowY + 10.f, contentW * 0.5f, 20.f);
        self.sliders[idx].frame     = CGRectMake(kPad, rowY + 32.f, contentW - kPad * 2, 24.f);
    }
    y += cardH + kPad;

    // 生成按钮
    self.generateButton.frame = CGRectMake(kPad, y, contentW, kBtnH);
    y += kBtnH + 12.f;

    // 预设按钮（三等分）
    CGFloat gap     = 8.f;
    CGFloat presetW = (contentW - gap * 2) / 3.f;
    for (NSInteger idx = 0; idx < (NSInteger)self.presetButtons.count; idx++) {
        self.presetButtons[idx].frame = CGRectMake(kPad + idx * (presetW + gap), y, presetW, kPresetH);
    }
    y += kPresetH + kPad;

    // 结果卡片（高度随内容变化）
    CGFloat resultH = [self.resultCard heightForWidth:contentW];
    self.resultCard.frame = CGRectMake(kPad, y, contentW, resultH);
    y += resultH + kPad;

    self.scrollView.contentSize = CGSizeMake(screenW, y);
}

#pragma mark - 懒加载

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor              = TSColor_Background;
        _scrollView.alwaysBounceVertical         = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

@end
