//
//  TSDailyExerciseGoalVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSDailyExerciseGoalVC.h"

static const CGFloat kGoalRowH      = 60.f;
static const CGFloat kGoalCardPad   = 16.f;
static const CGFloat kStepperBtnSz  = 28.f;

typedef NS_ENUM(NSInteger, TSGoalField) {
    TSGoalFieldSteps = 0,
    TSGoalFieldCalories,
    TSGoalFieldDistance,
    TSGoalFieldActivityDuration,
    TSGoalFieldExerciseDuration,
    TSGoalFieldExerciseTimes,
    TSGoalFieldActivityTimes,
    TSGoalFieldCount,
};

@interface TSDailyExerciseGoalVC ()

// 滚动容器
@property (nonatomic, strong) UIScrollView *scrollView;
// 目标卡片
@property (nonatomic, strong) UIView *cardView;
// 底部保存按钮
@property (nonatomic, strong) UIButton *saveButton;
// 全屏加载指示器
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

// 当前目标数据
@property (nonatomic, strong) TSDailyActivityGoals *currentGoal;
// 是否有未保存修改
@property (nonatomic, assign) BOOL isDirty;

// 各行数值 label（按 TSGoalField 索引）
@property (nonatomic, strong) NSMutableArray<UILabel *> *valueLabels;
// 各行减号按钮
@property (nonatomic, strong) NSMutableArray<UIButton *> *minusButtons;
// 各行加号按钮
@property (nonatomic, strong) NSMutableArray<UIButton *> *plusButtons;
// 排序后的字段顺序（支持的在前）
@property (nonatomic, strong) NSArray<NSNumber *> *sortedFieldIndices;

@end

@implementation TSDailyExerciseGoalVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (CGRectGetWidth(self.view.bounds) > 0) {
        [self layoutViews];
    }
}

- (void)viewSafeAreaInsetsDidChange {
    // 由 viewDidLayoutSubviews 统一处理
}

#pragma mark - 公开方法

/**
 * 初始化标题
 */
- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"daily_goal.title");
}

/**
 * 构建卡片、各目标行、保存按钮、loading（不调用父类）
 */
- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.cardView];
    [self.view addSubview:self.saveButton];
    [self.view addSubview:self.loadingIndicator];

    [self buildGoalRows];
    [self fetchGoals];
}

/**
 * Frame 布局
 */
- (void)layoutViews {
    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    CGFloat screenH = CGRectGetHeight(self.view.bounds);
    if (screenW <= 0) return;

    CGFloat topInset    = self.ts_navigationBarTotalHeight;
    if (topInset <= 0) topInset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = MAX(self.view.safeAreaInsets.bottom, kGoalCardPad);

    CGFloat btnH = 50.f;
    CGFloat btnY = screenH - bottomInset - btnH;
    self.saveButton.frame = CGRectMake(kGoalCardPad, btnY, screenW - kGoalCardPad * 2, btnH);
    self.saveButton.layer.cornerRadius = TSRadius_MD;

    CGFloat scrollH = btnY - topInset - kGoalCardPad;
    self.scrollView.frame = CGRectMake(0, topInset, screenW, scrollH);

    CGFloat cardW = screenW - kGoalCardPad * 2;
    CGFloat cardH = kGoalRowH * TSGoalFieldCount;
    self.cardView.frame = CGRectMake(kGoalCardPad, kGoalCardPad, cardW, cardH);

    self.scrollView.contentSize = CGSizeMake(screenW, cardH + kGoalCardPad * 2);
    self.loadingIndicator.center = CGPointMake(screenW / 2.f, topInset + scrollH / 2.f);

    [self layoutGoalRows:cardW];
}

#pragma mark - 私有方法

/**
 * 构建所有目标行
 */
- (void)buildGoalRows {
    NSArray *configs = [self rowConfigs];
    for (NSInteger i = 0; i < TSGoalFieldCount; i++) {
        NSDictionary *cfg = configs[i];
        UIView *row = [self makeRowWithIcon:cfg[@"icon"] title:cfg[@"title"] unit:cfg[@"unit"] index:i];
        [self.cardView addSubview:row];
    }
}

/**
 * 布局所有目标行，支持的排在前面
 */
- (void)layoutGoalRows:(CGFloat)cardW {
    if (cardW <= 0) return;

    // 若尚未排序（capability 未到），按默认顺序
    NSArray<NSNumber *> *order = self.sortedFieldIndices;
    if (!order || order.count != TSGoalFieldCount) {
        NSMutableArray *def = [NSMutableArray array];
        for (NSInteger k = 0; k < TSGoalFieldCount; k++) [def addObject:@(k)];
        order = def;
    }

    for (NSInteger pos = 0; pos < (NSInteger)order.count; pos++) {
        NSInteger i = [order[pos] integerValue];
        UIView *row = [self.cardView viewWithTag:200 + i];
        if (!row) continue;
        row.frame = CGRectMake(0, pos * kGoalRowH, cardW, kGoalRowH);

        UIView *line = [row viewWithTag:999];
        if (line) {
            line.hidden = (pos == TSGoalFieldCount - 1);
            line.frame  = CGRectMake(kGoalCardPad, kGoalRowH - 0.5f, cardW - kGoalCardPad, 0.5f);
        }

        UILabel *icon = [row viewWithTag:101];
        icon.frame = CGRectMake(kGoalCardPad, (kGoalRowH - 24.f) / 2.f, 24.f, 24.f);

        UILabel *titleLabel = [row viewWithTag:102];
        CGFloat titleX = kGoalCardPad + 24.f + 8.f;
        CGFloat titleW = cardW * 0.35f;
        titleLabel.frame = CGRectMake(titleX, 0, titleW, kGoalRowH);

        CGFloat plusX  = cardW - kGoalCardPad - kStepperBtnSz;
        CGFloat unitW  = 28.f;
        CGFloat unitX  = plusX - 4.f - unitW;
        CGFloat valueW = 52.f;
        CGFloat valueX = unitX - 4.f - valueW;
        CGFloat minusX = valueX - 4.f - kStepperBtnSz;

        UIButton *minus = self.minusButtons[i];
        minus.frame = CGRectMake(minusX, (kGoalRowH - kStepperBtnSz) / 2.f, kStepperBtnSz, kStepperBtnSz);
        minus.layer.cornerRadius = kStepperBtnSz / 2.f;

        UILabel *valueLabel = self.valueLabels[i];
        valueLabel.frame = CGRectMake(valueX, 0, valueW, kGoalRowH);

        UILabel *unitLabel = [row viewWithTag:103];
        unitLabel.frame = CGRectMake(unitX, 0, unitW, kGoalRowH);

        UIButton *plus = self.plusButtons[i];
        plus.frame = CGRectMake(plusX, (kGoalRowH - kStepperBtnSz) / 2.f, kStepperBtnSz, kStepperBtnSz);
        plus.layer.cornerRadius = kStepperBtnSz / 2.f;
    }
}

/**
 * 创建单行目标视图（含步进器）
 */
- (UIView *)makeRowWithIcon:(NSString *)icon title:(NSString *)title unit:(NSString *)unit index:(NSInteger)index {
    UIView *row = [[UIView alloc] init];
    row.backgroundColor = [UIColor clearColor];
    row.tag = 200 + index;

    UILabel *iconLabel      = [[UILabel alloc] init];
    iconLabel.text          = icon;
    iconLabel.font          = [UIFont systemFontOfSize:20.f];
    iconLabel.textAlignment = NSTextAlignmentCenter;
    iconLabel.tag           = 101;
    [row addSubview:iconLabel];

    UILabel *titleLabel     = [[UILabel alloc] init];
    titleLabel.text         = title;
    titleLabel.font         = TSFont_Body;
    titleLabel.textColor    = TSColor_TextPrimary;
    titleLabel.tag          = 102;
    [row addSubview:titleLabel];

    UILabel *valueLabel         = [[UILabel alloc] init];
    valueLabel.text             = @"--";
    valueLabel.font             = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    valueLabel.textColor        = TSColor_Primary;
    valueLabel.textAlignment    = NSTextAlignmentCenter;
    [self.valueLabels addObject:valueLabel];
    [row addSubview:valueLabel];

    UILabel *unitLabel      = [[UILabel alloc] init];
    unitLabel.text          = unit;
    unitLabel.font          = TSFont_Caption;
    unitLabel.textColor     = TSColor_TextSecondary;
    unitLabel.textAlignment = NSTextAlignmentLeft;
    unitLabel.tag           = 103;
    [row addSubview:unitLabel];

    UIButton *minusBtn = [self makeStepperButton:@"−" index:index isMinus:YES];
    [self.minusButtons addObject:minusBtn];
    [row addSubview:minusBtn];

    UIButton *plusBtn = [self makeStepperButton:@"+" index:index isMinus:NO];
    [self.plusButtons addObject:plusBtn];
    [row addSubview:plusBtn];

    UIView *line        = [[UIView alloc] init];
    line.backgroundColor = TSColor_Separator;
    line.tag            = 999;
    [row addSubview:line];

    return row;
}

/**
 * 创建步进器按钮
 */
- (UIButton *)makeStepperButton:(NSString *)title index:(NSInteger)index isMinus:(BOOL)isMinus {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:TSColor_Primary forState:UIControlStateNormal];
    [btn setTitleColor:TSColor_Gray forState:UIControlStateDisabled];
    btn.titleLabel.font   = [UIFont systemFontOfSize:18.f weight:UIFontWeightLight];
    btn.layer.borderColor = TSColor_Primary.CGColor;
    btn.layer.borderWidth = 1.5f;
    btn.backgroundColor   = [UIColor clearColor];
    btn.tag = isMinus ? (300 + index) : (400 + index);
    SEL action = isMinus ? @selector(onMinusTapped:) : @selector(onPlusTapped:);
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

/**
 * 从设备获取每日运动目标，并根据 capability 更新支持状态
 */
- (void)fetchGoals {
    self.cardView.alpha   = 0;
    self.saveButton.alpha = 0;
    [self.loadingIndicator startAnimating];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] dailyActivity] fetchDailyExerciseGoalsWithCompletion:^(TSDailyActivityGoals *_Nullable goalsModel, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            if (goalsModel) {
                weakSelf.currentGoal = goalsModel;
                weakSelf.isDirty     = NO;
                [weakSelf applyCapabilityState];
                [weakSelf reloadValueLabels];
                [weakSelf updateSaveButtonState];
                [UIView animateWithDuration:0.25 animations:^{
                    weakSelf.cardView.alpha   = 1;
                    weakSelf.saveButton.alpha = 1;
                }];
            } else {
                [weakSelf showFetchFailAlertWithMessage:error.localizedDescription ?: TSLocalizedString(@"daily_goal.fetch_failed")];
            }
        });
    }];
}

/**
 * 根据 capability.dailyActivityAbility 禁用不支持的行，并将支持的行排在前面
 */
- (void)applyCapabilityState {
    TSDailyActivityAbility *ability = [[TopStepComKit sharedInstance] connectedPeripheral].capability.dailyActivityAbility;

    NSArray<NSNumber *> *activityTypes = @[
        @(TSDailyActivityTypeStepCount),
        @(TSDailyActivityTypeCalories),
        @(TSDailyActivityTypeDistance),
        @(TSDailyActivityTypeActiveDuration),
        @(TSDailyActivityTypeExerciseDuration),
        @(TSDailyActivityTypeActivityCount),
        @(TSDailyActivityTypeActivityCount),
    ];

    NSMutableArray *supported   = [NSMutableArray array];
    NSMutableArray *unsupported = [NSMutableArray array];

    for (NSInteger i = 0; i < TSGoalFieldCount; i++) {
        TSDailyActivityType type = (TSDailyActivityType)[activityTypes[i] integerValue];
        BOOL isSupported = !ability || [ability isSupportActivityType:type];
        [self setRow:i enabled:isSupported];
        if (isSupported) {
            [supported addObject:@(i)];
        } else {
            [unsupported addObject:@(i)];
        }
    }

    NSMutableArray *sorted = [NSMutableArray arrayWithArray:supported];
    [sorted addObjectsFromArray:unsupported];
    self.sortedFieldIndices = [sorted copy];

    [self layoutGoalRows:CGRectGetWidth(self.cardView.bounds)];
}

/**
 * 设置某行的启用/禁用状态
 */
- (void)setRow:(NSInteger)index enabled:(BOOL)enabled {
    UIView *row = [self.cardView viewWithTag:200 + index];
    UILabel *titleLabel  = [row viewWithTag:102];
    UILabel *valueLabel  = self.valueLabels[index];
    UILabel *unitLabel   = [row viewWithTag:103];
    UILabel *iconLabel   = [row viewWithTag:101];

    UIColor *textColor   = enabled ? TSColor_TextPrimary : TSColor_Gray;
    UIColor *valueColor  = enabled ? TSColor_Primary     : TSColor_Gray;

    titleLabel.textColor = textColor;
    iconLabel.alpha      = enabled ? 1.f : 0.4f;
    valueLabel.textColor = valueColor;
    unitLabel.textColor  = enabled ? TSColor_TextSecondary : TSColor_Gray;

    self.minusButtons[index].enabled = enabled;
    self.plusButtons[index].enabled  = enabled;

    UIButton *minus = self.minusButtons[index];
    UIButton *plus  = self.plusButtons[index];
    UIColor *borderColor = enabled ? TSColor_Primary : TSColor_Gray;
    minus.layer.borderColor = borderColor.CGColor;
    plus.layer.borderColor  = borderColor.CGColor;
}

/**
 * 刷新所有数值 label
 */
- (void)reloadValueLabels {
    NSArray *values = [self currentGoalValues];
    for (NSInteger i = 0; i < TSGoalFieldCount; i++) {
        self.valueLabels[i].text = [NSString stringWithFormat:@"%@", values[i]];
    }
}

/**
 * 获取当前目标各字段值数组
 */
- (NSArray<NSNumber *> *)currentGoalValues {
    return @[
        @(self.currentGoal.stepsGoal),
        @(self.currentGoal.caloriesGoal),
        @(self.currentGoal.distanceGoal),
        @(self.currentGoal.activityDurationGoal),
        @(self.currentGoal.exerciseDurationGoal),
        @(self.currentGoal.exerciseTimesGoal),
        @(self.currentGoal.activityTimesGoal),
    ];
}

/**
 * 点击减号按钮
 */
- (void)onMinusTapped:(UIButton *)sender {
    NSInteger index = sender.tag - 300;
    NSArray *steps  = [self stepValues];
    NSInteger step  = [steps[index] integerValue];
    NSInteger cur   = [self.valueLabels[index].text integerValue];
    [self applyValue:MAX(0, cur - step) toField:index];
}

/**
 * 点击加号按钮
 */
- (void)onPlusTapped:(UIButton *)sender {
    NSInteger index = sender.tag - 400;
    NSArray *steps  = [self stepValues];
    NSInteger step  = [steps[index] integerValue];
    NSInteger cur   = [self.valueLabels[index].text integerValue];
    [self applyValue:cur + step toField:index];
}

/**
 * 将值写入对应字段并刷新 UI
 */
- (void)applyValue:(NSInteger)value toField:(NSInteger)index {
    switch ((TSGoalField)index) {
        case TSGoalFieldSteps:            self.currentGoal.stepsGoal            = value; break;
        case TSGoalFieldCalories:         self.currentGoal.caloriesGoal         = value; break;
        case TSGoalFieldDistance:         self.currentGoal.distanceGoal         = value; break;
        case TSGoalFieldActivityDuration: self.currentGoal.activityDurationGoal = value; break;
        case TSGoalFieldExerciseDuration: self.currentGoal.exerciseDurationGoal = value; break;
        case TSGoalFieldExerciseTimes:    self.currentGoal.exerciseTimesGoal    = value; break;
        case TSGoalFieldActivityTimes:    self.currentGoal.activityTimesGoal    = value; break;
        case TSGoalFieldCount: break;
    }
    self.valueLabels[index].text = [NSString stringWithFormat:@"%ld", (long)value];
    self.isDirty = YES;
    [self updateSaveButtonState];
}

/**
 * 保存目标到设备
 */
- (void)onSaveTapped {
    if (!self.currentGoal) return;
    self.saveButton.enabled = NO;
    [self.saveButton setTitle:TSLocalizedString(@"general.saving") forState:UIControlStateNormal];
    self.saveButton.backgroundColor = TSColor_Gray;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] dailyActivity] pushDailyExerciseGoals:self.currentGoal completion:^(BOOL success, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                weakSelf.isDirty = NO;
                [weakSelf updateSaveButtonState];
                [weakSelf showToast:TSLocalizedString(@"daily_goal.save_success")];
            } else {
                [weakSelf updateSaveButtonState];
                [weakSelf showAlertWithMsg:error.localizedDescription ?: TSLocalizedString(@"daily_goal.save_failed")];
            }
        });
    }];
}

/**
 * 更新保存按钮状态
 */
- (void)updateSaveButtonState {
    self.saveButton.enabled         = self.isDirty;
    self.saveButton.backgroundColor = self.isDirty ? TSColor_Primary : TSColor_Gray;
    [self.saveButton setTitle:self.isDirty ? TSLocalizedString(@"daily_goal.save_to_device") : TSLocalizedString(@"general.synced") forState:UIControlStateNormal];
}

/**
 * 获取失败弹窗（含重试）
 */
- (void)showFetchFailAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"daily_goal.fetch_failed")
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.retry") style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        [weakSelf fetchGoals];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 底部 Toast 提示
 */
- (void)showToast:(NSString *)message {
    UILabel *toast        = [[UILabel alloc] init];
    toast.text            = message;
    toast.font            = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    toast.textColor       = [UIColor whiteColor];
    toast.textAlignment   = NSTextAlignmentCenter;
    toast.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    toast.layer.cornerRadius  = 18.f;
    toast.layer.masksToBounds = YES;
    toast.numberOfLines   = 0;
    toast.alpha           = 0;

    CGFloat hPad  = TSSpacing_LG, vPad = TSSpacing_SM;
    CGFloat maxW  = self.view.bounds.size.width - TSSpacing_XL * 2;
    CGSize textSz = [message boundingRectWithSize:CGSizeMake(maxW - hPad * 2, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: toast.font}
                                          context:nil].size;
    CGFloat w = textSz.width + hPad * 2;
    CGFloat h = textSz.height + vPad * 2;
    CGFloat x = (self.view.bounds.size.width - w) / 2.f;
    CGFloat y = self.view.bounds.size.height - h - TSSpacing_XL - self.view.safeAreaInsets.bottom;
    toast.frame = CGRectMake(x, y, w, h);

    [self.view addSubview:toast];
    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1; } completion:^(BOOL f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{ toast.alpha = 0; } completion:^(BOOL done) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

/**
 * 各行配置（图标、标题、单位）
 */
- (NSArray<NSDictionary *> *)rowConfigs {
    return @[
        @{@"icon": @"🦶", @"title": TSLocalizedString(@"daily_goal.steps_title"),     @"unit": TSLocalizedString(@"daily_goal.unit_steps")},
        @{@"icon": @"🔥", @"title": TSLocalizedString(@"daily_goal.calories_title"),   @"unit": TSLocalizedString(@"daily_goal.unit_kcal")},
        @{@"icon": @"📍", @"title": TSLocalizedString(@"daily_goal.distance_title"),     @"unit": TSLocalizedString(@"daily_goal.unit_meters")},
        @{@"icon": @"⏱",  @"title": TSLocalizedString(@"daily_goal.active_duration_title"), @"unit": TSLocalizedString(@"daily_goal.unit_minutes")},
        @{@"icon": @"🏃", @"title": TSLocalizedString(@"daily_goal.exercise_duration_title"), @"unit": TSLocalizedString(@"daily_goal.unit_minutes")},
        @{@"icon": @"🔁", @"title": TSLocalizedString(@"daily_goal.exercise_count_title"), @"unit": TSLocalizedString(@"daily_goal.unit_times")},
        @{@"icon": @"📊", @"title": TSLocalizedString(@"daily_goal.active_count_title"), @"unit": TSLocalizedString(@"daily_goal.unit_times")},
    ];
}

/**
 * 各字段步进量
 */
- (NSArray<NSNumber *> *)stepValues {
    return @[@500, @50, @500, @5, @5, @1, @1];
}

#pragma mark - 属性（懒加载）

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor      = TSColor_Background;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor     = TSColor_Card;
        _cardView.layer.cornerRadius  = TSRadius_MD;
        _cardView.layer.shadowColor   = [UIColor blackColor].CGColor;
        _cardView.layer.shadowOpacity = 0.06f;
        _cardView.layer.shadowOffset  = CGSizeMake(0, 2);
        _cardView.layer.shadowRadius  = 8.f;
    }
    return _cardView;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_saveButton setTitle:TSLocalizedString(@"general.synced") forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveButton.titleLabel.font     = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
        _saveButton.backgroundColor     = TSColor_Gray;
        _saveButton.layer.cornerRadius  = TSRadius_MD;
        _saveButton.layer.masksToBounds = YES;
        _saveButton.enabled             = NO;
        [_saveButton addTarget:self action:@selector(onSaveTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        _loadingIndicator.color            = TSColor_Primary;
        _loadingIndicator.hidesWhenStopped = YES;
    }
    return _loadingIndicator;
}

- (NSMutableArray<UILabel *> *)valueLabels {
    if (!_valueLabels) { _valueLabels = [NSMutableArray array]; }
    return _valueLabels;
}

- (NSMutableArray<UIButton *> *)minusButtons {
    if (!_minusButtons) { _minusButtons = [NSMutableArray array]; }
    return _minusButtons;
}

- (NSMutableArray<UIButton *> *)plusButtons {
    if (!_plusButtons) { _plusButtons = [NSMutableArray array]; }
    return _plusButtons;
}

@end
