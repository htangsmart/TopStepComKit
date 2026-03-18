//
//  TSDailyActivityVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSDailyActivityVC.h"
#import "TSDailyExerciseGoalVC.h"

// ─── 常量 ──────────────────────────────────────────────────────────────────

static const CGFloat kDateBarH       = 48.f;
static const CGFloat kHeroCardH      = 140.f;
static const CGFloat kRingItemW      = 72.f;
static const CGFloat kRingDiameter   = 56.f;
static const CGFloat kItemRowH       = 52.f;
static const CGFloat kSectionHeaderH = 40.f;
static const CGFloat kCardSpacing    = 12.f;
static const CGFloat kHPad           = 16.f;

// ─── TSActivityRingItem ────────────────────────────────────────────────────

@interface TSActivityRingItem : UIView
@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UIImageView  *iconView;
@property (nonatomic, strong) UILabel      *valueLabel;
@property (nonatomic, strong) UILabel      *unitLabel;
- (void)configureWithIcon:(NSString *)iconName color:(UIColor *)color unit:(NSString *)unit;
- (void)updateValue:(NSString *)value progress:(CGFloat)progress;
@end

@implementation TSActivityRingItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    // 轨道圆环
    self.trackLayer = [CAShapeLayer layer];
    self.trackLayer.fillColor   = [UIColor clearColor].CGColor;
    self.trackLayer.strokeColor = [TSColor_Separator CGColor];
    self.trackLayer.lineWidth   = 4.5;
    self.trackLayer.lineCap     = kCALineCapRound;
    [self.layer addSublayer:self.trackLayer];

    // 进度圆环
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.fillColor   = [UIColor clearColor].CGColor;
    self.progressLayer.lineWidth   = 4.5;
    self.progressLayer.lineCap     = kCALineCapRound;
    self.progressLayer.strokeEnd   = 0;
    [self.layer addSublayer:self.progressLayer];

    // 图标
    self.iconView = [[UIImageView alloc] init];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.iconView];

    // 数值
    self.valueLabel = [[UILabel alloc] init];
    self.valueLabel.font          = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    self.valueLabel.textColor     = TSColor_TextPrimary;
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.adjustsFontSizeToFitWidth = YES;
    self.valueLabel.minimumScaleFactor = 0.7;
    self.valueLabel.text = @"--";
    [self addSubview:self.valueLabel];

    // 单位
    self.unitLabel = [[UILabel alloc] init];
    self.unitLabel.font          = [UIFont systemFontOfSize:11];
    self.unitLabel.textColor     = TSColor_TextSecondary;
    self.unitLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.unitLabel];

    return self;
}

- (void)configureWithIcon:(NSString *)iconName color:(UIColor *)color unit:(NSString *)unit {
    self.progressLayer.strokeColor = color.CGColor;
    self.unitLabel.text = unit;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration
            configurationWithPointSize:16 weight:UIImageSymbolWeightMedium];
        self.iconView.image    = [UIImage systemImageNamed:iconName withConfiguration:cfg];
        self.iconView.tintColor = color;
    }
    [self setNeedsLayout];
}

- (void)updateValue:(NSString *)value progress:(CGFloat)progress {
    self.valueLabel.text       = value;
    self.progressLayer.strokeEnd = MIN(1.0, MAX(0, progress));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;

    // 圆环居中
    CGFloat ringX  = (w - kRingDiameter) / 2.f;
    CGFloat ringY  = 12.f;
    CGPoint center = CGPointMake(w / 2.f, ringY + kRingDiameter / 2.f);
    CGFloat radius = (kRingDiameter - 4.5) / 2.f;

    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:-M_PI_2
                                                      endAngle:3 * M_PI_2
                                                     clockwise:YES];
    self.trackLayer.path    = path.CGPath;
    self.progressLayer.path = path.CGPath;

    // 图标居中于圆环
    CGFloat iconSize = 18.f;
    self.iconView.frame = CGRectMake(ringX + (kRingDiameter - iconSize) / 2.f,
                                     ringY + (kRingDiameter - iconSize) / 2.f,
                                     iconSize, iconSize);

    // 数值在圆环下方
    CGFloat valueY = ringY + kRingDiameter + 6.f;
    self.valueLabel.frame = CGRectMake(2, valueY, w - 4, 20);

    // 单位在数值下方
    self.unitLabel.frame = CGRectMake(2, valueY + 20 + 2, w - 4, 15);
}

@end

// ─── TSActivityHeroCard ────────────────────────────────────────────────────

@interface TSActivityHeroCard : UIView
@property (nonatomic, strong) UIScrollView *ringScrollView;
@property (nonatomic, strong) NSArray<TSActivityRingItem *> *ringItems;
@property (nonatomic, strong) NSArray<NSNumber *> *activityTypes;
- (void)configureWithTypes:(NSArray<NSNumber *> *)types;
- (void)updateWithModel:(TSActivityDailyModel *)model goals:(TSDailyActivityGoals *)goals;
@end

@implementation TSActivityHeroCard

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.backgroundColor    = TSColor_Card;
    self.layer.cornerRadius = TSRadius_MD;
    self.ringItems          = @[];
    self.activityTypes      = @[];

    self.ringScrollView = [[UIScrollView alloc] init];
    self.ringScrollView.showsHorizontalScrollIndicator = NO;
    self.ringScrollView.showsVerticalScrollIndicator   = NO;
    [self addSubview:self.ringScrollView];

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.ringScrollView.frame = self.bounds;

    NSInteger count = (NSInteger)self.ringItems.count;
    if (count == 0) return;

    CGFloat availW = self.bounds.size.width - kHPad * 2;
    CGFloat itemW  = MAX(kRingItemW, availW / count);
    CGFloat totalW = itemW * count;
    // 不足一屏时居中，超出时从左侧 padding 开始滚动
    CGFloat startX = (totalW < availW) ? (availW - totalW) / 2.f + kHPad : kHPad;
    CGFloat itemH  = self.bounds.size.height;

    for (NSInteger i = 0; i < count; i++) {
        self.ringItems[i].frame = CGRectMake(startX + i * itemW, 0, itemW, itemH);
    }
    self.ringScrollView.contentSize = CGSizeMake(
        MAX(startX + totalW + kHPad, self.bounds.size.width), itemH);
}

- (void)configureWithTypes:(NSArray<NSNumber *> *)types {
    for (TSActivityRingItem *item in self.ringItems) {
        [item removeFromSuperview];
    }
    self.activityTypes = types ?: @[];

    NSMutableArray<TSActivityRingItem *> *items = [NSMutableArray array];
    for (NSNumber *typeNum in self.activityTypes) {
        TSDailyActivityType type = (TSDailyActivityType)typeNum.integerValue;
        TSActivityRingItem *item = [[TSActivityRingItem alloc] init];
        item.tag = (NSInteger)type;
        [item configureWithIcon:[self ts_iconForType:type]
                          color:[self ts_colorForType:type]
                           unit:[self ts_unitForType:type]];
        [self.ringScrollView addSubview:item];
        [items addObject:item];
    }
    self.ringItems = items;
    [self setNeedsLayout];
}

- (void)updateWithModel:(TSActivityDailyModel *)model goals:(TSDailyActivityGoals *)goals {
    for (TSActivityRingItem *item in self.ringItems) {
        TSDailyActivityType type = (TSDailyActivityType)item.tag;
        if (!model) {
            [item updateValue:@"--" progress:0];
            continue;
        }
        NSInteger raw      = [self ts_rawValueForType:type model:model];
        NSInteger goalVal  = goals ? [self ts_goalForType:type goals:goals] : 0;
        NSString *display  = [self ts_displayValueForType:type rawValue:raw];
        CGFloat  progress  = (goalVal > 0) ? (CGFloat)raw / goalVal : 0;
        [item updateValue:display progress:progress];
    }
}

#pragma mark - 类型映射

- (NSString *)ts_iconForType:(TSDailyActivityType)type {
    switch (type) {
        case TSDailyActivityTypeStepCount:        return @"figure.walk";
        case TSDailyActivityTypeExerciseDuration: return @"figure.run";
        case TSDailyActivityTypeActivityCount:    return @"bolt.fill";
        case TSDailyActivityTypeActiveDuration:   return @"timer";
        case TSDailyActivityTypeDistance:         return @"location.fill";
        case TSDailyActivityTypeCalories:         return @"flame.fill";
        default:                                  return @"circle";
    }
}

- (UIColor *)ts_colorForType:(TSDailyActivityType)type {
    switch (type) {
        case TSDailyActivityTypeStepCount:        return TSColor_Primary;
        case TSDailyActivityTypeExerciseDuration: return [UIColor systemGreenColor];
        case TSDailyActivityTypeActivityCount:    return [UIColor systemOrangeColor];
        case TSDailyActivityTypeActiveDuration:   return [UIColor systemPurpleColor];
        case TSDailyActivityTypeDistance:         return [UIColor systemBlueColor];
        case TSDailyActivityTypeCalories:         return [UIColor systemRedColor];
        default:                                  return TSColor_TextSecondary;
    }
}

- (NSString *)ts_unitForType:(TSDailyActivityType)type {
    switch (type) {
        case TSDailyActivityTypeStepCount:        return TSLocalizedString(@"activity.unit.steps");
        case TSDailyActivityTypeExerciseDuration: return TSLocalizedString(@"activity.unit.min");
        case TSDailyActivityTypeActivityCount:    return TSLocalizedString(@"activity.unit.times");
        case TSDailyActivityTypeActiveDuration:   return TSLocalizedString(@"activity.unit.min");
        case TSDailyActivityTypeDistance:         return @"km";
        case TSDailyActivityTypeCalories:         return TSLocalizedString(@"activity.unit.kcal");
        default:                                  return @"";
    }
}

- (NSInteger)ts_rawValueForType:(TSDailyActivityType)type model:(TSActivityDailyModel *)model {
    switch (type) {
        case TSDailyActivityTypeStepCount:        return model.steps;
        case TSDailyActivityTypeExerciseDuration: return model.exercisesDuration;
        case TSDailyActivityTypeActivityCount:    return model.activityTimes;
        case TSDailyActivityTypeActiveDuration:   return model.activityDuration;
        case TSDailyActivityTypeDistance:         return model.distance;
        case TSDailyActivityTypeCalories:         return model.calories;
        default:                                  return 0;
    }
}

- (NSInteger)ts_goalForType:(TSDailyActivityType)type goals:(TSDailyActivityGoals *)goals {
    switch (type) {
        case TSDailyActivityTypeStepCount:        return goals.stepsGoal;
        case TSDailyActivityTypeExerciseDuration: return goals.exerciseDurationGoal * 60;
        case TSDailyActivityTypeActivityCount:    return goals.activityTimesGoal;
        case TSDailyActivityTypeActiveDuration:   return goals.activityDurationGoal * 60;
        case TSDailyActivityTypeDistance:         return goals.distanceGoal;
        case TSDailyActivityTypeCalories:         return goals.caloriesGoal;
        default:                                  return 0;
    }
}

- (NSString *)ts_displayValueForType:(TSDailyActivityType)type rawValue:(NSInteger)raw {
    switch (type) {
        case TSDailyActivityTypeExerciseDuration:
        case TSDailyActivityTypeActiveDuration:
            return [NSString stringWithFormat:@"%ld", (long)(raw / 60)];
        case TSDailyActivityTypeDistance:
            return [NSString stringWithFormat:@"%.1f", raw / 1000.0];
        default:
            return [NSString stringWithFormat:@"%ld", (long)raw];
    }
}

@end

// ─── TSDailyActivityVC ────────────────────────────────────────────────────

@interface TSDailyActivityVC () <UITableViewDelegate, UITableViewDataSource>

/** 当前选中日期（当天 00:00:00） */
@property (nonatomic, strong) NSDate *selectedDate;
/** 设备支持的活动类型 */
@property (nonatomic, strong) NSArray<NSNumber *> *supportedTypes;
/** 当前数据 */
@property (nonatomic, strong) TSActivityDailyModel *dailyModel;
/** 目标 */
@property (nonatomic, strong) TSDailyActivityGoals *goals;
/** 活动记录列表 */
@property (nonatomic, strong) NSArray<TSDailyActivityItem *> *activityItems;

/** 日期导航栏 */
@property (nonatomic, strong) UIView   *dateBar;
@property (nonatomic, strong) UIButton *prevDayButton;
@property (nonatomic, strong) UIButton *nextDayButton;
@property (nonatomic, strong) UILabel  *dateLabel;

/** 滚动容器 */
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView       *contentView;

/** 多指标圆环卡片 */
@property (nonatomic, strong) TSActivityHeroCard *heroCard;

/** 活动记录 TableView */
@property (nonatomic, strong) UITableView *itemsTableView;

/** 加载菊花 */
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation TSDailyActivityVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"activity.title");
    self.view.backgroundColor = TSColor_Background;
    self.selectedDate  = [self ts_startOfDay:[NSDate date]];
    self.activityItems = @[];
    self.supportedTypes = @[];

    [self ts_setupNavBar];
    [self ts_setupDateBar];
    [self ts_setupScrollView];
    [self ts_setupHeroCard];
    [self ts_setupItemsTableView];
    [self ts_setupLoadingIndicator];
    [self ts_fetchSupportedTypesThenLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;

    self.dateBar.frame    = CGRectMake(0, topOffset, w, kDateBarH);
    self.scrollView.frame = CGRectMake(0, topOffset + kDateBarH,
                                       w, h - topOffset - kDateBarH);
    [self ts_layoutContentView];
}

#pragma mark - 导航栏

- (void)ts_setupNavBar {
    UIBarButtonItem *goalBtn = [[UIBarButtonItem alloc]
        initWithImage:[UIImage systemImageNamed:@"target"]
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(ts_openGoals)];
    self.navigationItem.rightBarButtonItem = goalBtn;
}

#pragma mark - 日期导航栏

- (void)ts_setupDateBar {
    self.dateBar = [[UIView alloc] init];
    self.dateBar.backgroundColor = TSColor_Card;

    UIView *line = [[UIView alloc] init];
    line.backgroundColor  = TSColor_Separator;
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.dateBar addSubview:line];

    self.prevDayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.prevDayButton setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    self.prevDayButton.tintColor = TSColor_Primary;
    [self.prevDayButton addTarget:self action:@selector(ts_prevDay) forControlEvents:UIControlEventTouchUpInside];
    [self.dateBar addSubview:self.prevDayButton];

    self.nextDayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextDayButton setImage:[UIImage systemImageNamed:@"chevron.right"] forState:UIControlStateNormal];
    self.nextDayButton.tintColor = TSColor_Primary;
    [self.nextDayButton addTarget:self action:@selector(ts_nextDay) forControlEvents:UIControlEventTouchUpInside];
    [self.dateBar addSubview:self.nextDayButton];

    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font          = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.dateLabel.textColor     = TSColor_TextPrimary;
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.dateBar addSubview:self.dateLabel];

    [self ts_updateDateLabel];
    [self ts_updateNextButtonState];
    [self.view addSubview:self.dateBar];

    CGFloat btnW = 44.f;
    CGFloat vw   = self.view.bounds.size.width;
    self.prevDayButton.frame = CGRectMake(0, 0, btnW, kDateBarH);
    self.nextDayButton.frame = CGRectMake(vw - btnW, 0, btnW, kDateBarH);
    self.dateLabel.frame     = CGRectMake(btnW, 0, vw - btnW * 2, kDateBarH);
    line.frame               = CGRectMake(0, kDateBarH - 0.5, vw, 0.5);
}

#pragma mark - ScrollView & 内容区

- (void)ts_setupScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor      = TSColor_Background;
    self.scrollView.alwaysBounceVertical = YES;

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(ts_onPullRefresh:) forControlEvents:UIControlEventValueChanged];
    self.scrollView.refreshControl = refresh;

    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = TSColor_Background;
    [self.scrollView addSubview:self.contentView];
    [self.view addSubview:self.scrollView];
}

- (void)ts_setupHeroCard {
    self.heroCard = [[TSActivityHeroCard alloc] init];
    [self.contentView addSubview:self.heroCard];
}

- (void)ts_setupItemsTableView {
    self.itemsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.itemsTableView.delegate        = self;
    self.itemsTableView.dataSource      = self;
    self.itemsTableView.backgroundColor = TSColor_Card;
    self.itemsTableView.separatorColor  = TSColor_Separator;
    self.itemsTableView.separatorInset  = UIEdgeInsetsMake(0, 16, 0, 0);
    self.itemsTableView.scrollEnabled   = NO;
    self.itemsTableView.layer.cornerRadius = TSRadius_MD;
    if (@available(iOS 15.0, *)) {
        self.itemsTableView.sectionHeaderTopPadding = 0;
    }
    [self.contentView addSubview:self.itemsTableView];
}

- (void)ts_setupLoadingIndicator {
    self.loadingIndicator = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.color            = TSColor_Primary;
    self.loadingIndicator.hidesWhenStopped = YES;
    self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin  |
                                             UIViewAutoresizingFlexibleBottomMargin |
                                             UIViewAutoresizingFlexibleLeftMargin  |
                                             UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.loadingIndicator];
}

- (void)ts_layoutContentView {
    CGFloat w = self.scrollView.bounds.size.width;
    if (w <= 0) return;
    CGFloat yOffset = kCardSpacing;

    self.heroCard.frame = CGRectMake(kHPad, yOffset, w - kHPad * 2, kHeroCardH);
    yOffset += kHeroCardH + kCardSpacing;

    NSInteger rowCount = MAX(1, (NSInteger)self.activityItems.count);
    CGFloat tableH = kSectionHeaderH + rowCount * kItemRowH;
    self.itemsTableView.frame = CGRectMake(kHPad, yOffset, w - kHPad * 2, tableH);
    yOffset += tableH + kCardSpacing;

    self.contentView.frame      = CGRectMake(0, 0, w, yOffset);
    self.scrollView.contentSize = CGSizeMake(w, yOffset);

    self.loadingIndicator.center = CGPointMake(w / 2.f,
        self.scrollView.bounds.size.height / 2.f);
}

#pragma mark - 数据加载

- (void)ts_fetchSupportedTypesThenLoad {
    [self.loadingIndicator startAnimating];
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] dailyActivity]
     fetchSupportedDailyActivityTypesWithCompletion:^(NSArray<NSNumber *> *activityTypes, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.supportedTypes = activityTypes.count > 0 ? activityTypes
                : @[@(TSDailyActivityTypeStepCount),
                    @(TSDailyActivityTypeCalories),
                    @(TSDailyActivityTypeDistance),
                    @(TSDailyActivityTypeActiveDuration)];
            [weakSelf.heroCard configureWithTypes:weakSelf.supportedTypes];
            [weakSelf ts_fetchGoalsThenSync];
        });
    }];
}

- (void)ts_fetchGoalsThenSync {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] dailyActivity]
     fetchDailyExerciseGoalsWithCompletion:^(TSDailyActivityGoals *goalsModel, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.goals = goalsModel;
            [weakSelf ts_syncCurrentDay];
        });
    }];
}

- (void)ts_syncCurrentDay {
    NSDate *start = self.selectedDate;
    NSDate *end   = [NSDate dateWithTimeInterval:86399 sinceDate:start];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] dailyActivity]
     syncDailyDataFromStartTime:start.timeIntervalSince1970
                        endTime:end.timeIntervalSince1970
                     completion:^(NSArray<TSActivityDailyModel *> *dailyModels, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            [weakSelf.scrollView.refreshControl endRefreshing];

            if (error) {
                TSLog(@"[TSDailyActivityVC] sync error: %@", error);
                [weakSelf ts_showToast:@"同步失败，请重试"];
                return;
            }

            TSActivityDailyModel *model = dailyModels.firstObject;
            weakSelf.dailyModel    = model;
            weakSelf.activityItems = model.activityItems ?: @[];
            [weakSelf.heroCard updateWithModel:model goals:weakSelf.goals];
            [weakSelf.itemsTableView reloadData];
            [weakSelf ts_layoutContentView];
        });
    }];
}

#pragma mark - 日期操作

- (void)ts_prevDay {
    self.selectedDate = [NSDate dateWithTimeInterval:-86400 sinceDate:self.selectedDate];
    [self ts_updateDateLabel];
    [self ts_updateNextButtonState];
    [self ts_startSyncWithLoading];
}

- (void)ts_nextDay {
    NSDate *next  = [NSDate dateWithTimeInterval:86400 sinceDate:self.selectedDate];
    NSDate *today = [self ts_startOfDay:[NSDate date]];
    if ([next compare:today] == NSOrderedDescending) return;
    self.selectedDate = next;
    [self ts_updateDateLabel];
    [self ts_updateNextButtonState];
    [self ts_startSyncWithLoading];
}

- (void)ts_startSyncWithLoading {
    self.dailyModel    = nil;
    self.activityItems = @[];
    [self.heroCard updateWithModel:nil goals:nil];
    [self.itemsTableView reloadData];
    [self.loadingIndicator startAnimating];
    [self ts_syncCurrentDay];
}

- (void)ts_updateDateLabel {
    NSDate *today     = [self ts_startOfDay:[NSDate date]];
    NSDate *yesterday = [NSDate dateWithTimeInterval:-86400 sinceDate:today];

    if ([self.selectedDate isEqualToDate:today]) {
        self.dateLabel.text = TSLocalizedString(@"activity.today");
    } else if ([self.selectedDate isEqualToDate:yesterday]) {
        self.dateLabel.text = TSLocalizedString(@"activity.yesterday");
    } else {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"M月d日 EEEE";
        fmt.locale     = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
        self.dateLabel.text = [fmt stringFromDate:self.selectedDate];
    }
}

- (void)ts_updateNextButtonState {
    NSDate *today    = [self ts_startOfDay:[NSDate date]];
    NSDate *next     = [NSDate dateWithTimeInterval:86400 sinceDate:self.selectedDate];
    BOOL canGoNext   = ([next compare:today] != NSOrderedDescending);
    self.nextDayButton.enabled   = canGoNext;
    self.nextDayButton.tintColor = canGoNext ? TSColor_Primary : TSColor_TextSecondary;
}

- (void)ts_onPullRefresh:(UIRefreshControl *)sender {
    [self ts_syncCurrentDay];
}

#pragma mark - 目标设��

- (void)ts_openGoals {
    TSDailyExerciseGoalVC *vc = [[TSDailyExerciseGoalVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activityItems.count > 0 ? (NSInteger)self.activityItems.count : 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                              tableView.bounds.size.width, kSectionHeaderH)];
    header.backgroundColor = TSColor_Card;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0,
                                                               header.bounds.size.width - 32, kSectionHeaderH)];
    label.text      = TSLocalizedString(@"activity.records");
    label.font      = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    label.textColor = TSColor_TextSecondary;
    [header addSubview:label];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeaderH - 0.5,
                                                            header.bounds.size.width, 0.5)];
    line.backgroundColor = TSColor_Separator;
    [header addSubview:line];

    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSectionHeaderH;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"kTSActivityItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.backgroundColor           = TSColor_Card;
        cell.selectionStyle            = UITableViewCellSelectionStyleNone;
        cell.textLabel.font            = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        cell.textLabel.textColor       = TSColor_TextPrimary;
        cell.detailTextLabel.font      = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = TSColor_TextSecondary;
    }

    if (self.activityItems.count == 0) {
        cell.textLabel.text       = TSLocalizedString(@"activity.no_records");
        cell.detailTextLabel.text = @"";
        cell.imageView.image      = nil;
        return cell;
    }

    TSDailyActivityItem *item = self.activityItems[indexPath.row];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm";
    NSString *timeRange = [NSString stringWithFormat:@"%@ - %@",
                           [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:item.startTime]],
                           [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:item.endTime]]];

    NSString *distanceStr = item.distance >= 1000
        ? [NSString stringWithFormat:@"%.1fkm", item.distance / 1000.0]
        : [NSString stringWithFormat:@"%ldm", (long)item.distance];

    cell.textLabel.text       = [NSString stringWithFormat:@"%@  ·  %ld%@", timeRange, (long)item.steps, TSLocalizedString(@"activity.unit.steps")];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld%@  %ld%@  %@",
                                 (long)(item.duration / 60), TSLocalizedString(@"activity.unit.min"), (long)item.calories, TSLocalizedString(@"activity.unit.kcal"), distanceStr];
    if (@available(iOS 13.0, *)) {
        cell.imageView.image     = [UIImage systemImageNamed:@"figure.walk"];
        cell.imageView.tintColor = TSColor_Primary;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kItemRowH;
}

#pragma mark - 工具方法

- (NSDate *)ts_startOfDay:(NSDate *)date {
    return [[NSCalendar currentCalendar] startOfDayForDate:date];
}

- (void)ts_showToast:(NSString *)message {
    UILabel *toast = [[UILabel alloc] init];
    toast.text            = message;
    toast.font            = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    toast.textColor       = UIColor.whiteColor;
    toast.textAlignment   = NSTextAlignmentCenter;
    toast.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    toast.layer.cornerRadius  = 18;
    toast.layer.masksToBounds = YES;
    toast.alpha = 0;

    CGFloat hPad = 20, vPad = 10;
    CGSize sz = [message boundingRectWithSize:CGSizeMake(280, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName: toast.font}
                                      context:nil].size;
    CGFloat tw = sz.width + hPad * 2;
    CGFloat th = sz.height + vPad * 2;
    toast.frame = CGRectMake((self.view.bounds.size.width - tw) / 2,
                             self.view.bounds.size.height - th - 60 - self.view.safeAreaInsets.bottom,
                             tw, th);
    [self.view addSubview:toast];
    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1; } completion:^(BOOL _) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{ toast.alpha = 0; }
                             completion:^(BOOL __) { [toast removeFromSuperview]; }];
        });
    }];
}

@end
