//
//  TSHomeVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHomeVC.h"
#import "TSHealthCardView.h"
#import "TSSportItemView.h"

#import <TopStepComKit/TopStepComKit.h>

#import "TSHearRateVC.h"
#import "TSBloodPressureVC.h"
#import "TSBloodOxygenVC.h"
#import "TSStressVC.h"
#import "TSSleepVC.h"
#import "TSSportVC.h"
#import "TSDailyActivityVC.h"
#import "TSTemperatureVC.h"
#import "TSElectrocardioVC.h"

// 布局常量
static const CGFloat kRingsContainerHeight  = 180.f;
static const CGFloat kRingsViewSize         = 130.f;
static const CGFloat kRingsViewLeading      = 16.f;
static const CGFloat kRingsLabelSpacing     = 12.f;
static const CGFloat kRingsLabelHeight      = 16.f;
static const CGFloat kSportTitleHeight      = 20.f;
static const CGFloat kSportItemHeight       = 64.f;
static const CGFloat kSportItemSpacing      = 8.f;
static const CGFloat kSportCardInset        = 12.f;
static const CGFloat kSportCardEmptyHeight  = 130.f;
static const CGFloat kEmptyIconSize         = 40.f;
static const NSInteger kSportMaxDisplayCount = 3;

// ─── 三环视图 ─────────────────────────────────────────────────────────────

@interface TSActivityRingsView : UIView

@property (nonatomic, assign) CGFloat stepsProgress;
@property (nonatomic, assign) CGFloat caloriesProgress;
@property (nonatomic, assign) CGFloat exerciseProgress;

- (void)animateToStepsProgress:(CGFloat)steps caloriesProgress:(CGFloat)calories exerciseProgress:(CGFloat)exercise;

@end

@interface TSActivityRingsView ()

@property (nonatomic, strong) CADisplayLink  *displayLink;
@property (nonatomic, assign) CGFloat         targetStepsProgress;
@property (nonatomic, assign) CGFloat         targetCaloriesProgress;
@property (nonatomic, assign) CGFloat         targetExerciseProgress;
@property (nonatomic, assign) CFTimeInterval  animationStartTime;

@end

@implementation TSActivityRingsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor  = [UIColor clearColor];
        _stepsProgress    = 0.0f;
        _caloriesProgress = 0.0f;
        _exerciseProgress = 0.0f;
    }
    return self;
}

- (void)setStepsProgress:(CGFloat)stepsProgress {
    _stepsProgress = MAX(0.0f, MIN(1.0f, stepsProgress));
    [self setNeedsDisplay];
}

- (void)setCaloriesProgress:(CGFloat)caloriesProgress {
    _caloriesProgress = MAX(0.0f, MIN(1.0f, caloriesProgress));
    [self setNeedsDisplay];
}

- (void)setExerciseProgress:(CGFloat)exerciseProgress {
    _exerciseProgress = MAX(0.0f, MIN(1.0f, exerciseProgress));
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat w        = CGRectGetWidth(rect);
    CGFloat h        = CGRectGetHeight(rect);
    CGPoint center   = CGPointMake(w / 2.f, h / 2.f);

    CGFloat lineWidth   = 8.f;
    CGFloat gap         = 6.f;
    CGFloat outerRadius = MIN(w, h) / 2.f - lineWidth / 2.f - 10.f;

    [self drawRingAtCenter:center radius:outerRadius lineWidth:lineWidth progress:_stepsProgress    color:TSColor_Primary inContext:ctx];
    [self drawRingAtCenter:center radius:outerRadius - lineWidth - gap lineWidth:lineWidth progress:_caloriesProgress color:TSColor_Danger  inContext:ctx];
    [self drawRingAtCenter:center radius:outerRadius - (lineWidth + gap) * 2 lineWidth:lineWidth progress:_exerciseProgress color:TSColor_Success inContext:ctx];
}

- (void)drawRingAtCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth progress:(CGFloat)progress color:(UIColor *)color inContext:(CGContextRef)ctx {
    // 背景圆弧
    CGContextSetStrokeColorWithColor(ctx, [TSColor_Separator CGColor]);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextAddArc(ctx, center.x, center.y, radius, 0, M_PI * 2, 0);
    CGContextStrokePath(ctx);

    if (progress > 0.001f) {
        CGContextSetStrokeColorWithColor(ctx, [color CGColor]);
        CGContextSetLineWidth(ctx, lineWidth);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGFloat startAngle = -M_PI_2;
        CGFloat endAngle   = startAngle + progress * M_PI * 2;
        CGContextAddArc(ctx, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextStrokePath(ctx);
    }
}

- (void)animateToStepsProgress:(CGFloat)steps caloriesProgress:(CGFloat)calories exerciseProgress:(CGFloat)exercise {
    _stepsProgress    = 0.0f;
    _caloriesProgress = 0.0f;
    _exerciseProgress = 0.0f;
    _targetStepsProgress    = MAX(0.0f, MIN(1.0f, steps));
    _targetCaloriesProgress = MAX(0.0f, MIN(1.0f, calories));
    _targetExerciseProgress = MAX(0.0f, MIN(1.0f, exercise));

    [self.displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(ts_animationTick:)];
    self.animationStartTime = CACurrentMediaTime();
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)ts_animationTick:(CADisplayLink *)link {
    static const CFTimeInterval kDuration = 0.8;
    CGFloat t     = (CGFloat)MIN((CACurrentMediaTime() - self.animationStartTime) / kDuration, 1.0);
    CGFloat eased = 1.0f - (float)pow(1.0f - t, 3.0f); // ease-out cubic

    _stepsProgress    = _targetStepsProgress    * eased;
    _caloriesProgress = _targetCaloriesProgress * eased;
    _exerciseProgress = _targetExerciseProgress * eased;
    [self setNeedsDisplay];

    if (t >= 1.0f) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

@end

// ─── TSHomeVC ─────────────────────────────────────────────────────────────

@interface TSHomeVC ()

// 滚动容器
@property (nonatomic, strong) UIScrollView         *scrollView;
@property (nonatomic, strong) UIRefreshControl     *refreshControl;
@property (nonatomic, strong) UIView               *contentView;

// 活动三环区
@property (nonatomic, strong) UIView               *ringsContainer;
@property (nonatomic, strong) TSActivityRingsView  *activityRingsView;
@property (nonatomic, strong) UILabel              *stepsRingLabel;
@property (nonatomic, strong) UILabel              *caloriesRingLabel;
@property (nonatomic, strong) UILabel              *exerciseRingLabel;

// 运动卡片区
@property (nonatomic, strong) UIView               *sportCardContainer;
@property (nonatomic, strong) UILabel              *sportCardTitleLabel;
@property (nonatomic, strong) UIImageView          *sportArrowImageView;
@property (nonatomic, strong) UIView               *sportEmptyView;
@property (nonatomic, strong) UIImageView          *sportEmptyIconView;
@property (nonatomic, strong) UILabel              *sportEmptyTitleLabel;
@property (nonatomic, strong) UILabel              *sportEmptySubtitleLabel;
@property (nonatomic, strong) NSMutableArray<TSSportItemView *> *sportItemViews;

// 健康卡片区
@property (nonatomic, strong) NSMutableArray<TSHealthCardView *> *healthCards;

// 数据缓存
@property (nonatomic, strong) NSArray<TSHealthData *>        *cachedHealthData;
@property (nonatomic, strong) TSActivityDailyModel           *todayActivity;
@property (nonatomic, strong) NSArray<TSSportSummaryModel *> *todaySportRecords;

@end

@implementation TSHomeVC

#pragma mark - 生命周期

- (instancetype)init {
    self = [super init];
    if (self) {
        // 一级页面，不隐藏 TabBar
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"tab.home");
    self.view.backgroundColor = TSColor_Background;
    [self ts_setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self ts_refreshAllCards];
    [self ts_refreshSportCard];
}

#pragma mark - 私有方法

/**
 * 初始化所有子视图
 */
- (void)ts_setupViews {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = TSColor_Background;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(ts_handleRefresh) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.refreshControl];

    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];

    [self ts_setupActivityRingsView];
    [self ts_setupSportCard];
    [self ts_setupHealthCards];
}

/**
 * 初始化活动三环视图
 */
- (void)ts_setupActivityRingsView {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = TSColor_Card;
    container.layer.cornerRadius = TSRadius_MD;
    UITapGestureRecognizer *ringsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ts_activityRingsTapped)];
    [container addGestureRecognizer:ringsTap];
    [self.contentView addSubview:container];
    self.ringsContainer = container;

    TSActivityRingsView *rings = [[TSActivityRingsView alloc] init];
    rings.userInteractionEnabled = NO;
    [container addSubview:rings];
    self.activityRingsView = rings;

    self.stepsRingLabel    = [self ts_createRingLabel];
    self.caloriesRingLabel = [self ts_createRingLabel];
    self.exerciseRingLabel = [self ts_createRingLabel];
    [container addSubview:self.stepsRingLabel];
    [container addSubview:self.caloriesRingLabel];
    [container addSubview:self.exerciseRingLabel];

    self.stepsRingLabel.attributedText    = [self ts_dotLabelWithColor:TSColor_Primary text:@"--"];
    self.caloriesRingLabel.attributedText = [self ts_dotLabelWithColor:TSColor_Danger  text:@"--"];
    self.exerciseRingLabel.attributedText = [self ts_dotLabelWithColor:TSColor_Success text:@"--"];
}

/**
 * 创建三环旁的统计标签
 */
- (UILabel *)ts_createRingLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightMedium];
    label.textColor = TSColor_TextSecondary;
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

/**
 * 初始化运动卡片
 */
- (void)ts_setupSportCard {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = TSColor_Card;
    container.layer.cornerRadius = TSRadius_MD;
    [self.contentView addSubview:container];
    self.sportCardContainer = container;

    UILabel *cardTitleLabel = [[UILabel alloc] init];
    cardTitleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
    cardTitleLabel.textColor = TSColor_TextPrimary;
    cardTitleLabel.text = TSLocalizedString(@"home.sport.title");
    [container addSubview:cardTitleLabel];
    self.sportCardTitleLabel = cardTitleLabel;

    UIImageView *arrowImageView = [[UIImageView alloc] init];
    arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    arrowImageView.tintColor = TSColor_TextSecondary;
    if (@available(iOS 13.0, *)) {
        arrowImageView.image = [UIImage systemImageNamed:@"chevron.right"];
    }
    [container addSubview:arrowImageView];
    self.sportArrowImageView = arrowImageView;

    [container addSubview:self.sportEmptyView];

    self.sportItemViews = [NSMutableArray array];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ts_handleSportCardTap)];
    [container addGestureRecognizer:tapGesture];
}

/**
 * 初始化健康卡片列表
 */
- (void)ts_setupHealthCards {
    self.healthCards = [NSMutableArray array];

    NSArray *configs = @[
        @{@"icon": @"heart.fill",         @"color": TSColor_Danger,  @"title": TSLocalizedString(@"health.heart_rate"),    @"vc": [TSHearRateVC class]},
        @{@"icon": @"waveform",           @"color": TSColor_Primary, @"title": TSLocalizedString(@"health.blood_pressure"), @"vc": [TSBloodPressureVC class]},
        @{@"icon": @"drop.fill",          @"color": TSColor_Danger,  @"title": TSLocalizedString(@"health.blood_oxygen"),   @"vc": [TSBloodOxygenVC class]},
        @{@"icon": @"brain.head.profile", @"color": TSColor_Purple,  @"title": TSLocalizedString(@"health.stress"),         @"vc": [TSStressVC class]},
        @{@"icon": @"bed.double.fill",    @"color": TSColor_Indigo,  @"title": TSLocalizedString(@"health.sleep"),          @"vc": [TSSleepVC class]},
        @{@"icon": @"figure.walk",        @"color": TSColor_Teal,    @"title": TSLocalizedString(@"health.steps"),          @"vc": [TSDailyActivityVC class]},
        @{@"icon": @"thermometer",        @"color": TSColor_Warning, @"title": TSLocalizedString(@"health.temperature"),    @"vc": [TSTemperatureVC class]},
        @{@"icon": @"waveform.path.ecg",  @"color": TSColor_Danger,  @"title": TSLocalizedString(@"health.ecg"),            @"vc": [TSElectrocardioVC class]},
    ];

    for (NSDictionary *cfg in configs) {
        TSHealthCardView *card = [TSHealthCardView cardWithIconName:cfg[@"icon"]
                                                          iconColor:cfg[@"color"]
                                                              title:cfg[@"title"]
                                                              value:@"--"];
        __weak typeof(self) weakSelf = self;
        card.onTap = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            Class vcClass = cfg[@"vc"];
            UIViewController *vc = [[vcClass alloc] init];
            [strongSelf.navigationController pushViewController:vc animated:YES];
        };
        [self.contentView addSubview:card];
        [self.healthCards addObject:card];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat topOffset = 0;
    if (@available(iOS 11.0, *)) {
        topOffset = self.view.safeAreaInsets.top;
    }
    if (topOffset == 0) topOffset = 64;

    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    CGFloat screenH = CGRectGetHeight(self.view.bounds);
    self.scrollView.frame = CGRectMake(0, topOffset, screenW, screenH - topOffset);

    CGFloat margin   = TSSpacing_MD;
    CGFloat contentW = screenW - margin * 2;
    CGFloat yOffset  = margin;

    // 活动三环布局
    self.ringsContainer.frame = CGRectMake(margin, yOffset, contentW, kRingsContainerHeight);

    self.activityRingsView.frame = CGRectMake(kRingsViewLeading,
                                              (kRingsContainerHeight - kRingsViewSize) / 2.f,
                                              kRingsViewSize, kRingsViewSize);

    CGFloat labelX      = CGRectGetMaxX(self.activityRingsView.frame) + kRingsViewLeading;
    CGFloat labelW      = contentW - labelX - kRingsViewLeading;
    CGFloat labelsBlockH = kRingsLabelHeight * 3 + kRingsLabelSpacing * 2;
    CGFloat labelStartY = (kRingsContainerHeight - labelsBlockH) / 2.f;

    self.stepsRingLabel.frame    = CGRectMake(labelX, labelStartY, labelW, kRingsLabelHeight);
    self.caloriesRingLabel.frame = CGRectMake(labelX, labelStartY +  kRingsLabelHeight + kRingsLabelSpacing,      labelW, kRingsLabelHeight);
    self.exerciseRingLabel.frame = CGRectMake(labelX, labelStartY + (kRingsLabelHeight + kRingsLabelSpacing) * 2, labelW, kRingsLabelHeight);

    yOffset += kRingsContainerHeight + TSSpacing_LG;

    // 运动卡片布局
    CGFloat sportCardY = yOffset;
    self.sportCardTitleLabel.frame = CGRectMake(kSportCardInset, kSportCardInset, 100.f, kSportTitleHeight);
    self.sportArrowImageView.frame = CGRectMake(contentW - kSportCardInset - 20.f, kSportCardInset, 20.f, 20.f);

    CGFloat sportCardH;
    if (self.todaySportRecords.count == 0) {
        sportCardH = kSportCardEmptyHeight;
        self.sportEmptyView.hidden = NO;

        CGFloat emptyViewY = CGRectGetMaxY(self.sportCardTitleLabel.frame) + 8.f;
        CGFloat emptyViewH = sportCardH - emptyViewY;
        self.sportEmptyView.frame = CGRectMake(0, emptyViewY, contentW, emptyViewH);

        // 从底部往上定位空态内部元素
        CGFloat subtitleH = 16.f;
        CGFloat subtitleY = emptyViewH - 15.f - subtitleH;
        self.sportEmptySubtitleLabel.frame = CGRectMake(0, subtitleY, contentW, subtitleH);

        CGFloat emptyTitleH = 20.f;
        CGFloat emptyTitleY = subtitleY - 4.f - emptyTitleH;
        self.sportEmptyTitleLabel.frame = CGRectMake(0, emptyTitleY, contentW, emptyTitleH);

        CGFloat iconY = emptyTitleY - 8.f - kEmptyIconSize;
        self.sportEmptyIconView.frame = CGRectMake((contentW - kEmptyIconSize) / 2.f, iconY, kEmptyIconSize, kEmptyIconSize);

        for (TSSportItemView *itemView in self.sportItemViews) {
            itemView.hidden = YES;
        }
    } else {
        self.sportEmptyView.hidden = YES;

        CGFloat itemY        = CGRectGetMaxY(self.sportCardTitleLabel.frame) + 10.f;
        NSInteger displayCount = MIN((NSInteger)self.todaySportRecords.count, kSportMaxDisplayCount);

        for (NSInteger idx = 0; idx < displayCount; idx++) {
            TSSportItemView *itemView;
            if (idx < (NSInteger)self.sportItemViews.count) {
                itemView = self.sportItemViews[idx];
            } else {
                itemView = [[TSSportItemView alloc] init];
                [self.sportCardContainer addSubview:itemView];
                [self.sportItemViews addObject:itemView];
            }
            itemView.hidden = NO;
            itemView.frame  = CGRectMake(kSportCardInset,
                                         itemY + idx * (kSportItemHeight + kSportItemSpacing),
                                         contentW - kSportCardInset * 2,
                                         kSportItemHeight);
            [itemView updateWithSummary:self.todaySportRecords[idx]];
        }
        for (NSInteger idx = displayCount; idx < (NSInteger)self.sportItemViews.count; idx++) {
            self.sportItemViews[idx].hidden = YES;
        }

        sportCardH = itemY + displayCount * (kSportItemHeight + kSportItemSpacing) - kSportItemSpacing + kSportCardInset;
    }

    self.sportCardContainer.frame = CGRectMake(margin, sportCardY, contentW, sportCardH);
    yOffset += sportCardH + TSSpacing_LG;

    // 健康卡片网格布局（2 列）
    CGFloat cardSpacing = TSSpacing_MD;
    CGFloat cardW = (contentW - cardSpacing) / 2.f;
    CGFloat cardH = cardW;

    NSInteger col = 0, row = 0;
    for (TSHealthCardView *card in self.healthCards) {
        card.frame = CGRectMake(margin + col * (cardW + cardSpacing),
                                yOffset + row * (cardH + cardSpacing),
                                cardW, cardH);
        col++;
        if (col >= 2) { col = 0; row++; }
    }

    NSInteger totalRows = ((NSInteger)self.healthCards.count + 1) / 2;
    CGFloat contentH = yOffset + totalRows * (cardH + cardSpacing) + margin;
    self.contentView.frame = CGRectMake(0, 0, screenW, contentH);
    self.scrollView.contentSize = CGSizeMake(screenW, contentH);
}

/**
 * 下拉刷新：同步今日数据
 */
- (void)ts_handleRefresh {
    TopStepComKit *sdk = [TopStepComKit sharedInstance];
    TSPeripheral  *peripheral = sdk.connectedPeripheral;

    if (!peripheral) {
        [self.refreshControl endRefreshing];
        [self ts_refreshAllCards];
        [self ts_refreshActivityRings];
        return;
    }

    NSDate *nowDate       = [NSDate date];
    NSTimeInterval now    = [nowDate timeIntervalSince1970];
    NSDate *startOfToday  = [[NSCalendar currentCalendar] startOfDayForDate:nowDate];
    NSTimeInterval currentDay = [startOfToday timeIntervalSince1970];

    TSDataSyncConfig *config = [[TSDataSyncConfig alloc] init];
    config.granularity = TSDataGranularityDay;
    config.startTime   = currentDay;
    config.endTime     = now;
    config.options     = TSDataSyncOptionAll;

    __weak typeof(self) weakSelf = self;
    [[sdk dataSync] syncDataWithConfig:config completion:^(NSArray<TSHealthData *> *results, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (results) {
                strongSelf.cachedHealthData = results;
                [strongSelf ts_refreshAllCards];
            }
            [strongSelf ts_refreshActivityRings];
            [strongSelf ts_refreshSportCard];
            [strongSelf.refreshControl endRefreshing];
        });
    }];
}

/**
 * 三环点击：进入日常活动页
 */
- (void)ts_activityRingsTapped {
    TSDailyActivityVC *dailyActivityVC = [[TSDailyActivityVC alloc] init];
    [self.navigationController pushViewController:dailyActivityVC animated:YES];
}

/**
 * 运动卡片点击：进入运动页
 */
- (void)ts_handleSportCardTap {
    TSSportVC *sportVC = [[TSSportVC alloc] init];
    [self.navigationController pushViewController:sportVC animated:YES];
}

/**
 * 从缓存数据刷新活动三环
 */
- (void)ts_refreshActivityRings {
    TSHealthData *activityData = [TSHealthData findHealthDataWithOption:TSDataSyncOptionDailyActivity fromArray:self.cachedHealthData];
    TSActivityDailyModel *todayActivity = (TSActivityDailyModel *)activityData.healthValues.lastObject;

    if (!todayActivity) {
        self.activityRingsView.stepsProgress    = 0.0f;
        self.activityRingsView.caloriesProgress = 0.0f;
        self.activityRingsView.exerciseProgress = 0.0f;
        self.stepsRingLabel.attributedText    = [self ts_dotLabelWithColor:TSColor_Primary text:@"--"];
        self.caloriesRingLabel.attributedText = [self ts_dotLabelWithColor:TSColor_Danger  text:@"--"];
        self.exerciseRingLabel.attributedText = [self ts_dotLabelWithColor:TSColor_Success text:@"--"];
        return;
    }

    self.todayActivity = todayActivity;
    [self ts_updateRingsWithActivity:todayActivity];

    // 异步获取运动目标，用于计算环形进度比例
    TopStepComKit *sdk = [TopStepComKit sharedInstance];
    __weak typeof(self) weakSelf = self;
    [[sdk dailyActivity] fetchDailyExerciseGoalsWithCompletion:^(TSDailyActivityGoals *goals, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || !goals) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf ts_updateRingsWithActivity:strongSelf.todayActivity goals:goals];
        });
    }];
}

/**
 * 仅用数值更新三环标签（无目标值时）
 */
- (void)ts_updateRingsWithActivity:(TSActivityDailyModel *)activity {
    NSInteger steps        = activity.steps;
    NSInteger calories     = activity.calories;
    NSInteger exerciseMins = activity.exercisesDuration / 60;

    self.stepsRingLabel.attributedText    = [self ts_dotLabelWithColor:TSColor_Primary text:[NSString stringWithFormat:TSLocalizedString(@"rings.steps.format"),    (long)steps]];
    self.caloriesRingLabel.attributedText = [self ts_dotLabelWithColor:TSColor_Danger  text:[NSString stringWithFormat:TSLocalizedString(@"rings.calories.format"), (long)calories]];
    self.exerciseRingLabel.attributedText = [self ts_dotLabelWithColor:TSColor_Success text:[NSString stringWithFormat:TSLocalizedString(@"rings.exercise.format"), (long)exerciseMins]];
}

/**
 * 用数值和目标值更新三环标签与进度
 */
- (void)ts_updateRingsWithActivity:(TSActivityDailyModel *)activity goals:(TSDailyActivityGoals *)goals {
    NSInteger steps        = activity.steps;
    NSInteger calories     = activity.calories;
    NSInteger exerciseMins = activity.exercisesDuration / 60;

    self.stepsRingLabel.attributedText    = [self ts_dotLabelWithColor:TSColor_Primary text:[NSString stringWithFormat:TSLocalizedString(@"rings.steps.goal_format"),    (long)steps,        (long)goals.stepsGoal]];
    self.caloriesRingLabel.attributedText = [self ts_dotLabelWithColor:TSColor_Danger  text:[NSString stringWithFormat:TSLocalizedString(@"rings.calories.goal_format"), (long)calories,     (long)goals.caloriesGoal]];
    self.exerciseRingLabel.attributedText = [self ts_dotLabelWithColor:TSColor_Success text:[NSString stringWithFormat:TSLocalizedString(@"rings.exercise.goal_format"), (long)exerciseMins, (long)goals.exerciseDurationGoal]];

    CGFloat stepsProgress    = goals.stepsGoal             > 0 ? (CGFloat)steps        / goals.stepsGoal             : 0.0f;
    CGFloat caloriesProgress = goals.caloriesGoal          > 0 ? (CGFloat)calories     / goals.caloriesGoal          : 0.0f;
    CGFloat exerciseProgress = goals.exerciseDurationGoal  > 0 ? (CGFloat)exerciseMins / goals.exerciseDurationGoal  : 0.0f;

    [self.activityRingsView animateToStepsProgress:stepsProgress caloriesProgress:caloriesProgress exerciseProgress:exerciseProgress];
}

/**
 * 构造带彩色圆点前缀的富文本
 */
- (NSAttributedString *)ts_dotLabelWithColor:(UIColor *)color text:(NSString *)text {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    [attr appendAttributedString:[[NSAttributedString alloc] initWithString:@"● " attributes:@{
        NSForegroundColorAttributeName: color,
        NSFontAttributeName: [UIFont systemFontOfSize:10.f]
    }]];
    [attr appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:@{
        NSForegroundColorAttributeName: TSColor_TextSecondary,
        NSFontAttributeName: [UIFont systemFontOfSize:13.f weight:UIFontWeightMedium]
    }]];
    return attr;
}

/**
 * 刷新所有健康卡片的数据与可用状态
 */
- (void)ts_refreshAllCards {
    TopStepComKit    *sdk        = [TopStepComKit sharedInstance];
    TSPeripheral     *peripheral = sdk.connectedPeripheral;
    TSFeatureAbility *ability    = peripheral.capability.featureAbility;
    BOOL hasDevice = (peripheral != nil);

    NSArray *cardConfigs = @[
        @{@"ability": @(hasDevice && ability.isSupportHeartRate),     @"option": @(TSDataSyncOptionHeartRate)},
        @{@"ability": @(hasDevice && ability.isSupportBloodPressure), @"option": @(TSDataSyncOptionBloodPressure)},
        @{@"ability": @(hasDevice && ability.isSupportBloodOxygen),   @"option": @(TSDataSyncOptionBloodOxygen)},
        @{@"ability": @(hasDevice && ability.isSupportStress),        @"option": @(TSDataSyncOptionStress)},
        @{@"ability": @(hasDevice && ability.isSupportSleep),         @"option": @(TSDataSyncOptionSleep)},
        @{@"ability": @(hasDevice && ability.isSupportDailyActivity), @"option": @(TSDataSyncOptionDailyActivity)},
        @{@"ability": @(hasDevice && ability.isSupportTemperature),   @"option": @(TSDataSyncOptionTemperature)},
        @{@"ability": @(hasDevice && ability.isSupportECG),           @"option": @(TSDataSyncOptionECG)},
    ];

    for (NSInteger i = 0; i < (NSInteger)self.healthCards.count && i < (NSInteger)cardConfigs.count; i++) {
        TSHealthCardView *card = self.healthCards[i];
        NSDictionary     *cfg  = cardConfigs[i];
        BOOL enabled = [cfg[@"ability"] boolValue];
        card.enabled      = enabled;
        card.disableReason = hasDevice ? 1 : 0; // 0=设备未连接，1=设备不支持

        if (enabled && self.cachedHealthData) {
            TSDataSyncOption option = [cfg[@"option"] unsignedIntegerValue];
            card.valueText = [self ts_getLatestValueForOption:option] ?: @"--";
        } else {
            card.valueText = @"--";
        }
    }
}

/**
 * 取指定数据类型的最新展示文本
 */
- (NSString *)ts_getLatestValueForOption:(TSDataSyncOption)option {
    TSHealthData *healthData = [TSHealthData findHealthDataWithOption:option fromArray:self.cachedHealthData];
    if (!healthData || healthData.healthValues.count == 0) {
        return nil;
    }

    TSHealthValueModel *latestDay = healthData.healthValues.lastObject;

    switch (option) {
        case TSDataSyncOptionHeartRate: {
            TSHRDailyModel *hrModel = (TSHRDailyModel *)latestDay;
            return [NSString stringWithFormat:@"%ld bpm", (long)hrModel.maxBPM];
        }
        case TSDataSyncOptionBloodPressure: {
            TSBPDailyModel *bpModel = (TSBPDailyModel *)latestDay;
            return [NSString stringWithFormat:@"%ld/%ld", (long)bpModel.maxSystolic, (long)bpModel.maxDiastolic];
        }
        case TSDataSyncOptionBloodOxygen: {
            TSBODailyModel *boModel = (TSBODailyModel *)latestDay;
            return [NSString stringWithFormat:@"%ld%%", (long)boModel.maxOxygenValue];
        }
        case TSDataSyncOptionStress: {
            TSStressDailyModel *stressModel = (TSStressDailyModel *)latestDay;
            return [NSString stringWithFormat:@"%ld", (long)stressModel.maxStress];
        }
        case TSDataSyncOptionSleep: {
            TSSleepDailyModel *sleepModel = (TSSleepDailyModel *)latestDay;
            NSInteger mins = sleepModel.dailySummary.duration / 60;
            return [NSString stringWithFormat:@"%ldh%ldm", (long)(mins / 60), (long)(mins % 60)];
        }
        case TSDataSyncOptionDailyActivity: {
            TSActivityDailyModel *activityModel = (TSActivityDailyModel *)latestDay;
            return [NSString stringWithFormat:@"%ld %@", (long)activityModel.steps, TSLocalizedString(@"activity.unit.steps")];
        }
        case TSDataSyncOptionTemperature: {
            TSTempDailyModel *tempModel = (TSTempDailyModel *)latestDay;
            if (tempModel.maxBodyTempItem) {
                return [NSString stringWithFormat:@"%.1f°C", tempModel.maxBodyTempItem.temperature];
            }
            return nil;
        }
        case TSDataSyncOptionECG: {
            return [NSString stringWithFormat:@"%ld %@", (long)healthData.healthValues.count, TSLocalizedString(@"activity.unit.times")];
        }
        default:
            return nil;
    }
}

/**
 * 从缓存数据刷新运动卡片
 */
- (void)ts_refreshSportCard {
    TSHealthData *sportData = [TSHealthData findHealthDataWithOption:TSDataSyncOptionSport fromArray:self.cachedHealthData];

    NSMutableArray<TSSportSummaryModel *> *summaries = [NSMutableArray array];
    for (TSSportModel *sport in sportData.healthValues) {
        if (sport.summary) {
            [summaries addObject:sport.summary];
        }
    }
    self.todaySportRecords = summaries;

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

#pragma mark - 属性（懒加载）

- (UIView *)sportEmptyView {
    if (!_sportEmptyView) {
        _sportEmptyView = [[UIView alloc] init];
        _sportEmptyView.backgroundColor = [UIColor clearColor];

        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.tintColor = [TSColor_TextSecondary colorWithAlphaComponent:0.3f];
        if (@available(iOS 13.0, *)) {
            iconView.image = [UIImage systemImageNamed:@"figure.run"];
        }
        [_sportEmptyView addSubview:iconView];
        _sportEmptyIconView = iconView;

        UILabel *emptyTitleLabel = [[UILabel alloc] init];
        emptyTitleLabel.font = [UIFont systemFontOfSize:14.f];
        emptyTitleLabel.textColor = TSColor_TextSecondary;
        emptyTitleLabel.text = TSLocalizedString(@"home.sport.empty.title");
        emptyTitleLabel.textAlignment = NSTextAlignmentCenter;
        [_sportEmptyView addSubview:emptyTitleLabel];
        _sportEmptyTitleLabel = emptyTitleLabel;

        UILabel *emptySubtitleLabel = [[UILabel alloc] init];
        emptySubtitleLabel.font = [UIFont systemFontOfSize:12.f];
        emptySubtitleLabel.textColor = [TSColor_TextSecondary colorWithAlphaComponent:0.6f];
        emptySubtitleLabel.text = TSLocalizedString(@"home.sport.empty.subtitle");
        emptySubtitleLabel.textAlignment = NSTextAlignmentCenter;
        [_sportEmptyView addSubview:emptySubtitleLabel];
        _sportEmptySubtitleLabel = emptySubtitleLabel;
    }
    return _sportEmptyView;
}

@end
