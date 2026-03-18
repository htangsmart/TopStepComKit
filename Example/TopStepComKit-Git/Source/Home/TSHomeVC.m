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
#import "TSBaseVC.h"
#import <TopStepComKit/TopStepComKit.h>

// 引入各健康页面
#import "TSHearRateVC.h"
#import "TSBloodPressureVC.h"
#import "TSBloodOxygenVC.h"
#import "TSStressVC.h"
#import "TSSleepVC.h"
#import "TSSportVC.h"
#import "TSDailyActivityVC.h"
#import "TSTemperatureVC.h"
#import "TSElectrocardioVC.h"

// ─── 三环视图 ───────────────────────────────────────────────────────────
@interface TSActivityRingsView : UIView
@property (nonatomic, assign) CGFloat stepsProgress;
@property (nonatomic, assign) CGFloat caloriesProgress;
@property (nonatomic, assign) CGFloat exerciseProgress;
@end

@interface TSActivityRingsView ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat targetStepsProgress;
@property (nonatomic, assign) CGFloat targetCaloriesProgress;
@property (nonatomic, assign) CGFloat targetExerciseProgress;
@property (nonatomic, assign) CFTimeInterval animationStartTime;
@end

@implementation TSActivityRingsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _stepsProgress = 0.0f;
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
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);
    CGPoint center = CGPointMake(w / 2.f, h / 2.f);

    CGFloat lineWidth = 8.f;
    CGFloat gap = 6.f;

    CGFloat outerRadius = MIN(w, h) / 2.f - lineWidth / 2.f - 10.f;
    [self drawRingAtCenter:center radius:outerRadius lineWidth:lineWidth progress:_stepsProgress color:TSColor_Primary inContext:ctx];

    CGFloat midRadius = outerRadius - lineWidth - gap;
    [self drawRingAtCenter:center radius:midRadius lineWidth:lineWidth progress:_caloriesProgress color:TSColor_Danger inContext:ctx];

    CGFloat innerRadius = midRadius - lineWidth - gap;
    [self drawRingAtCenter:center radius:innerRadius lineWidth:lineWidth progress:_exerciseProgress color:TSColor_Success inContext:ctx];
}

- (void)drawRingAtCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth progress:(CGFloat)progress color:(UIColor *)color inContext:(CGContextRef)ctx {
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
        CGFloat endAngle = startAngle + progress * M_PI * 2;
        CGContextAddArc(ctx, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextStrokePath(ctx);
    }
}

- (void)animateToStepsProgress:(CGFloat)steps caloriesProgress:(CGFloat)calories exerciseProgress:(CGFloat)exercise {
    _stepsProgress = 0.0f;
    _caloriesProgress = 0.0f;
    _exerciseProgress = 0.0f;
    _targetStepsProgress = MAX(0.0f, MIN(1.0f, steps));
    _targetCaloriesProgress = MAX(0.0f, MIN(1.0f, calories));
    _targetExerciseProgress = MAX(0.0f, MIN(1.0f, exercise));

    [self.displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(ts_animationTick:)];
    self.animationStartTime = CACurrentMediaTime();
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)ts_animationTick:(CADisplayLink *)link {
    static const CFTimeInterval kDuration = 0.8;
    CGFloat t = (CGFloat)MIN((CACurrentMediaTime() - self.animationStartTime) / kDuration, 1.0);
    CGFloat eased = 1.0f - (float)pow(1.0f - t, 3.0f); // ease-out cubic

    _stepsProgress = _targetStepsProgress * eased;
    _caloriesProgress = _targetCaloriesProgress * eased;
    _exerciseProgress = _targetExerciseProgress * eased;
    [self setNeedsDisplay];

    if (t >= 1.0f) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

@end
@interface TSHomeVC ()

@property (nonatomic, strong) UIScrollView   *scrollView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIView         *contentView;
@property (nonatomic, strong) UIView         *ringsContainer;
@property (nonatomic, strong) TSActivityRingsView *activityRingsView;
@property (nonatomic, strong) UILabel        *ringsLabel1;
@property (nonatomic, strong) UILabel        *ringsLabel2;
@property (nonatomic, strong) UILabel        *ringsLabel3;
@property (nonatomic, strong) UIView         *sportCardContainer;
@property (nonatomic, strong) UILabel        *sportCardTitleLabel;
@property (nonatomic, strong) UIView         *sportEmptyView;
@property (nonatomic, strong) NSMutableArray<TSSportItemView *> *sportItemViews;
@property (nonatomic, strong) NSMutableArray<TSHealthCardView *> *healthCards;
@property (nonatomic, strong) NSArray<TSHealthData *> *cachedHealthData;
@property (nonatomic, strong) TSActivityDailyModel *todayActivity;
@property (nonatomic, strong) NSArray<TSSportSummaryModel *> *todaySportRecords;

@end

@implementation TSHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.view.backgroundColor = TSColor_Background;
    [self ts_setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self ts_refreshAllCards];
    [self ts_refreshSportCard];
}

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

    self.ringsLabel1 = [self ts_createRingLabel];
    self.ringsLabel2 = [self ts_createRingLabel];
    self.ringsLabel3 = [self ts_createRingLabel];
    [container addSubview:self.ringsLabel1];
    [container addSubview:self.ringsLabel2];
    [container addSubview:self.ringsLabel3];

    self.ringsLabel1.attributedText = [self ts_dotLabelWithColor:TSColor_Primary text:@"步数: --"];
    self.ringsLabel2.attributedText = [self ts_dotLabelWithColor:TSColor_Danger text:@"卡路里: --"];
    self.ringsLabel3.attributedText = [self ts_dotLabelWithColor:TSColor_Success text:@"运动: --"];
}

- (UILabel *)ts_createRingLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightMedium];
    label.textColor = TSColor_TextSecondary;
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

/**
 * 设置运动卡片
 */
- (void)ts_setupSportCard {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = TSColor_Card;
    container.layer.cornerRadius = TSRadius_MD;
    [self.contentView addSubview:container];
    self.sportCardContainer = container;

    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
    titleLabel.textColor = TSColor_TextPrimary;
    titleLabel.text = @"运动";
    [container addSubview:titleLabel];
    self.sportCardTitleLabel = titleLabel;

    // 箭头
    UIImageView *arrowImageView = [[UIImageView alloc] init];
    arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    arrowImageView.tintColor = TSColor_TextSecondary;
    if (@available(iOS 13.0, *)) {
        arrowImageView.image = [UIImage systemImageNamed:@"chevron.right"];
    }
    [container addSubview:arrowImageView];
    arrowImageView.frame = CGRectMake(0, 0, 20.f, 20.f);
    arrowImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;

    // 空态视图
    [container addSubview:self.sportEmptyView];

    // 初始化运动条目数组
    self.sportItemViews = [NSMutableArray array];

    // 点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ts_handleSportCardTap)];
    [container addGestureRecognizer:tapGesture];
}

/**
 * 处理运动卡片点击
 */
- (void)ts_handleSportCardTap {
    TSSportVC *sportVC = [[TSSportVC alloc] init];
    [self.navigationController pushViewController:sportVC animated:YES];
}

- (void)ts_setupHealthCards {
    self.healthCards = [NSMutableArray array];

    NSArray *configs = @[
        @{@"icon": @"heart.fill",         @"color": TSColor_Danger,  @"title": @"心率",   @"vc": [TSHearRateVC class]},
        @{@"icon": @"waveform",           @"color": TSColor_Primary, @"title": @"血压",   @"vc": [TSBloodPressureVC class]},
        @{@"icon": @"drop.fill",          @"color": TSColor_Danger,  @"title": @"血氧",   @"vc": [TSBloodOxygenVC class]},
        @{@"icon": @"brain.head.profile", @"color": TSColor_Purple,  @"title": @"压力",   @"vc": [TSStressVC class]},
        @{@"icon": @"bed.double.fill",    @"color": TSColor_Indigo,  @"title": @"睡眠",   @"vc": [TSSleepVC class]},
        @{@"icon": @"figure.walk",        @"color": TSColor_Teal,    @"title": @"步数",   @"vc": [TSDailyActivityVC class]},
        @{@"icon": @"thermometer",        @"color": TSColor_Warning, @"title": @"体温",   @"vc": [TSTemperatureVC class]},
        @{@"icon": @"waveform.path.ecg",  @"color": TSColor_Danger,  @"title": @"心电",   @"vc": [TSElectrocardioVC class]},
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

    CGFloat margin = TSSpacing_MD;
    CGFloat contentW = screenW - margin * 2;
    CGFloat yOffset = margin;

    CGFloat ringsH = 180.f;
    self.ringsContainer.frame = CGRectMake(margin, yOffset, contentW, ringsH);

    CGFloat ringsSize = 130.f;
    CGFloat ringsX = 16.f;
    self.activityRingsView.frame = CGRectMake(ringsX, (ringsH - ringsSize) / 2.f, ringsSize, ringsSize);

    CGFloat labelX = CGRectGetMaxX(self.activityRingsView.frame) + 16.f;
    CGFloat labelW = contentW - labelX - 16.f;
    CGFloat labelH = 16.f;
    CGFloat labelsBlockH = labelH * 3 + 12.f * 2;
    CGFloat labelStartY = (ringsH - labelsBlockH) / 2.f;

    self.ringsLabel1.frame = CGRectMake(labelX, labelStartY, labelW, labelH);
    self.ringsLabel2.frame = CGRectMake(labelX, labelStartY + labelH + 12.f, labelW, labelH);
    self.ringsLabel3.frame = CGRectMake(labelX, labelStartY + (labelH + 12.f) * 2, labelW, labelH);

    yOffset += ringsH + TSSpacing_LG;

    // 运动卡片布局
    CGFloat sportCardY = yOffset;
    CGFloat sportCardW = contentW;
    CGFloat sportCardH = 0.f;

    // 标题区域
    CGFloat titleY = 16.f;
    self.sportCardTitleLabel.frame = CGRectMake(16.f, titleY, 100.f, 20.f);

    // 箭头（右上角）
    UIImageView *arrowView = nil;
    for (UIView *subview in self.sportCardContainer.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            arrowView = (UIImageView *)subview;
            break;
        }
    }
    if (arrowView) {
        arrowView.frame = CGRectMake(contentW - 36.f, titleY, 20.f, 20.f);
    }

    // 判断是否有运动数据
    if (self.todaySportRecords.count == 0) {
        // 空态：固定高度 130pt
        sportCardH = 130.f;
        self.sportEmptyView.hidden = NO;

        // 空态视图从标题下方开始到卡片底部
        CGFloat emptyViewY = CGRectGetMaxY(self.sportCardTitleLabel.frame) + 8.f;
        CGFloat emptyViewH = sportCardH - emptyViewY;
        self.sportEmptyView.frame = CGRectMake(0, emptyViewY, contentW, emptyViewH);

        // 布局空态视图内部元素（相对于 emptyView 自身坐标系）
        UIImageView *iconView = [self.sportEmptyView viewWithTag:201];
        UILabel *titleLabel = [self.sportEmptyView viewWithTag:202];
        UILabel *subtitleLabel = [self.sportEmptyView viewWithTag:203];

        // 从 emptyView 底部往上计算：副文案距离 emptyView 底部 15pt
        CGFloat bottomMargin = 15.f;
        CGFloat subtitleH = 16.f;
        CGFloat subtitleY = emptyViewH - bottomMargin - subtitleH;
        subtitleLabel.frame = CGRectMake(0, subtitleY, contentW, subtitleH);

        // 主文案在副文案上方 4pt
        CGFloat titleH = 20.f;
        CGFloat titleY = subtitleY - 4.f - titleH;
        titleLabel.frame = CGRectMake(0, titleY, contentW, titleH);

        // 图标在主文案上方 8pt
        CGFloat iconSize = 40.f;
        CGFloat iconY = titleY - 8.f - iconSize;
        iconView.frame = CGRectMake((contentW - iconSize) / 2.f, iconY, iconSize, iconSize);

        // 隐藏所有运动条目
        for (TSSportItemView *itemView in self.sportItemViews) {
            itemView.hidden = YES;
        }
    } else {
        // 有数据：动态高度
        self.sportEmptyView.hidden = YES;

        CGFloat itemY = CGRectGetMaxY(self.sportCardTitleLabel.frame) + 10.f;
        CGFloat cardH = 64.f;
        CGFloat cardGap = 8.f;
        CGFloat cardMargin = 12.f;

        // 显示最多 3 条记录
        NSInteger displayCount = MIN(self.todaySportRecords.count, 3);

        for (NSInteger i = 0; i < displayCount; i++) {
            TSSportItemView *itemView = nil;

            if (i < self.sportItemViews.count) {
                itemView = self.sportItemViews[i];
            } else {
                itemView = [[TSSportItemView alloc] init];
                [self.sportCardContainer addSubview:itemView];
                [self.sportItemViews addObject:itemView];
            }

            itemView.hidden = NO;
            itemView.frame = CGRectMake(cardMargin, itemY + i * (cardH + cardGap), contentW - cardMargin * 2, cardH);
            [itemView updateWithSummary:self.todaySportRecords[i]];
        }

        // 隐藏多余的 itemView
        for (NSInteger i = displayCount; i < self.sportItemViews.count; i++) {
            self.sportItemViews[i].hidden = YES;
        }

        sportCardH = itemY + displayCount * (cardH + cardGap) - cardGap + 12.f;
    }

    self.sportCardContainer.frame = CGRectMake(margin, sportCardY, sportCardW, sportCardH);
    yOffset += sportCardH + TSSpacing_LG;

    CGFloat cardSpacing = TSSpacing_MD;
    CGFloat cardW = (contentW - cardSpacing) / 2.f;
    CGFloat cardH = cardW;

    NSInteger col = 0;
    NSInteger row = 0;
    for (TSHealthCardView *card in self.healthCards) {
        CGFloat x = margin + col * (cardW + cardSpacing);
        CGFloat y = yOffset + row * (cardH + cardSpacing);
        card.frame = CGRectMake(x, y, cardW, cardH);
        col++;
        if (col >= 2) {
            col = 0;
            row++;
        }
    }

    NSInteger totalRows = (self.healthCards.count + 1) / 2;
    CGFloat contentH = yOffset + totalRows * (cardH + cardSpacing) + margin;
    self.contentView.frame = CGRectMake(0, 0, screenW, contentH);
    self.scrollView.contentSize = CGSizeMake(screenW, contentH);
}

- (void)ts_handleRefresh {
    TopStepComKit *sdk = [TopStepComKit sharedInstance];
    TSPeripheral *peripheral = sdk.connectedPeripheral;

    if (!peripheral) {
        [self.refreshControl endRefreshing];
        [self ts_refreshAllCards];
        [self ts_refreshActivityRings];
        return;
    }

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval sevenDaysAgo = now - (7 * 24 * 60 * 60);

    TSDataSyncConfig *config = [[TSDataSyncConfig alloc] init];
    config.granularity = TSDataGranularityDay;
    config.startTime   = sevenDaysAgo;
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

- (void)ts_refreshActivityRings {
    // 从缓存数据中取今日活动数据，不再重复查询设备
    TSHealthData *activityData = [TSHealthData findHealthDataWithOption:TSDataSyncOptionDailyActivity fromArray:self.cachedHealthData];
    TSActivityDailyModel *todayActivity = (TSActivityDailyModel *)activityData.healthValues.lastObject;

    if (!todayActivity) {
        self.activityRingsView.stepsProgress = 0.0f;
        self.activityRingsView.caloriesProgress = 0.0f;
        self.activityRingsView.exerciseProgress = 0.0f;
        self.ringsLabel1.attributedText = [self ts_dotLabelWithColor:TSColor_Primary text:@"步数: --"];
        self.ringsLabel2.attributedText = [self ts_dotLabelWithColor:TSColor_Danger text:@"卡路里: --"];
        self.ringsLabel3.attributedText = [self ts_dotLabelWithColor:TSColor_Success text:@"运动: --"];
        return;
    }

    self.todayActivity = todayActivity;
    [self ts_updateRingsWithActivity:todayActivity];

    // 目标值需要从设备读取，用于计算环的进度
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

- (void)ts_updateRingsWithActivity:(TSActivityDailyModel *)activity {
    NSInteger steps = activity.steps;
    NSInteger calories = activity.calories;
    NSInteger exerciseMins = activity.exercisesDuration / 60;

    self.ringsLabel1.attributedText = [self ts_dotLabelWithColor:TSColor_Primary text:[NSString stringWithFormat:@"步数: %ld", (long)steps]];
    self.ringsLabel2.attributedText = [self ts_dotLabelWithColor:TSColor_Danger text:[NSString stringWithFormat:@"卡路里: %ld", (long)calories]];
    self.ringsLabel3.attributedText = [self ts_dotLabelWithColor:TSColor_Success text:[NSString stringWithFormat:@"运动: %ld 分钟", (long)exerciseMins]];
}

- (void)ts_updateRingsWithActivity:(TSActivityDailyModel *)activity goals:(TSDailyActivityGoals *)goals {
    NSInteger steps = activity.steps;
    NSInteger calories = activity.calories;
    NSInteger exerciseMins = activity.exercisesDuration / 60;

    self.ringsLabel1.attributedText = [self ts_dotLabelWithColor:TSColor_Primary text:[NSString stringWithFormat:@"步数: %ld / %ld", (long)steps, (long)goals.stepsGoal]];
    self.ringsLabel2.attributedText = [self ts_dotLabelWithColor:TSColor_Danger text:[NSString stringWithFormat:@"卡路里: %ld / %ld", (long)calories, (long)goals.caloriesGoal]];
    self.ringsLabel3.attributedText = [self ts_dotLabelWithColor:TSColor_Success text:[NSString stringWithFormat:@"运动: %ld / %ld 分钟", (long)exerciseMins, (long)goals.exerciseDurationGoal]];

    CGFloat stepsProgress = goals.stepsGoal > 0 ? (CGFloat)steps / goals.stepsGoal : 0.0f;
    CGFloat caloriesProgress = goals.caloriesGoal > 0 ? (CGFloat)calories / goals.caloriesGoal : 0.0f;
    CGFloat exerciseProgress = goals.exerciseDurationGoal > 0 ? (CGFloat)exerciseMins / goals.exerciseDurationGoal : 0.0f;

    [self.activityRingsView animateToStepsProgress:stepsProgress caloriesProgress:caloriesProgress exerciseProgress:exerciseProgress];
}

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

- (void)ts_refreshAllCards {
    TopStepComKit *sdk = [TopStepComKit sharedInstance];
    TSPeripheral *peripheral = sdk.connectedPeripheral;
    TSFeatureAbility *ability = peripheral.capability.featureAbility;
    BOOL hasDevice = (peripheral != nil);

    NSArray *cardConfigs = @[
        @{@"ability": @(hasDevice && ability.isSupportHeartRate), @"option": @(TSDataSyncOptionHeartRate)},
        @{@"ability": @(hasDevice && ability.isSupportBloodPressure), @"option": @(TSDataSyncOptionBloodPressure)},
        @{@"ability": @(hasDevice && ability.isSupportBloodOxygen), @"option": @(TSDataSyncOptionBloodOxygen)},
        @{@"ability": @(hasDevice && ability.isSupportStress), @"option": @(TSDataSyncOptionStress)},
        @{@"ability": @(hasDevice && ability.isSupportSleep), @"option": @(TSDataSyncOptionSleep)},
        @{@"ability": @(hasDevice && ability.isSupportDailyActivity), @"option": @(TSDataSyncOptionDailyActivity)},
        @{@"ability": @(hasDevice && ability.isSupportTemperature), @"option": @(TSDataSyncOptionTemperature)},
        @{@"ability": @(hasDevice && ability.isSupportECG), @"option": @(TSDataSyncOptionECG)}
    ];

    for (NSInteger i = 0; i < self.healthCards.count && i < cardConfigs.count; i++) {
        TSHealthCardView *card = self.healthCards[i];
        NSDictionary *cfg = cardConfigs[i];
        BOOL enabled = [cfg[@"ability"] boolValue];
        card.enabled = enabled;

        // 设置禁用原因：0 = 设备未连接, 1 = 设备不支持
        if (!hasDevice) {
            card.disableReason = 0; // 设备未连接
        } else {
            card.disableReason = 1; // 设备不支持该功能
        }

        if (enabled && self.cachedHealthData) {
            TSDataSyncOption option = [cfg[@"option"] unsignedIntegerValue];
            NSString *value = [self ts_getLatestValueForOption:option];
            card.valueText = value ?: @"--";
        } else {
            card.valueText = @"--";
        }
    }
}

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
            NSInteger hours = mins / 60;
            NSInteger remainMins = mins % 60;
            return [NSString stringWithFormat:@"%ldh%ldm", (long)hours, (long)remainMins];
        }
        case TSDataSyncOptionSport: {
            // sportCount 暂未使用
            break;
        }
        case TSDataSyncOptionDailyActivity: {
            TSActivityDailyModel *activityModel = (TSActivityDailyModel *)latestDay;
            return [NSString stringWithFormat:@"%ld 步", (long)activityModel.steps];
        }
        case TSDataSyncOptionTemperature: {
            TSTempDailyModel *tempModel = (TSTempDailyModel *)latestDay;
            if (tempModel.maxBodyTempItem) {
                return [NSString stringWithFormat:@"%.1f°C", tempModel.maxBodyTempItem.temperature];
            }
            return nil;
        }
        case TSDataSyncOptionECG: {
            return [NSString stringWithFormat:@"%ld 次", (long)healthData.healthValues.count];
        }
        default:
            return nil;
    }
    return nil;
}

/**
 * 从缓存数据中刷新运动卡片
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

#pragma mark - 懒加载

- (UIView *)sportEmptyView {
    if (!_sportEmptyView) {
        _sportEmptyView = [[UIView alloc] init];
        _sportEmptyView.backgroundColor = [UIColor clearColor];

        // 大图标
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.tintColor = [TSColor_TextSecondary colorWithAlphaComponent:0.3f];
        iconView.tag = 201;
        if (@available(iOS 13.0, *)) {
            iconView.image = [UIImage systemImageNamed:@"figure.run"];
        }
        [_sportEmptyView addSubview:iconView];

        // 主文案
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:14.f];
        titleLabel.textColor = TSColor_TextSecondary;
        titleLabel.text = @"今日还没有运动记录";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.tag = 202;
        [_sportEmptyView addSubview:titleLabel];

        // 副文案
        UILabel *subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.font = [UIFont systemFontOfSize:12.f];
        subtitleLabel.textColor = [TSColor_TextSecondary colorWithAlphaComponent:0.6f];
        subtitleLabel.text = @"戴上手表，开始运动吧";
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleLabel.tag = 203;
        [_sportEmptyView addSubview:subtitleLabel];
    }
    return _sportEmptyView;
}

@end
