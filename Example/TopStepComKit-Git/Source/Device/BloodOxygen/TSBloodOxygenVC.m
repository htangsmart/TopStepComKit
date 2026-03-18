//
//  TSBloodOxygenVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBloodOxygenVC.h"
#import "TSBODayChartView.h"

static NSString *const kBOChartTypePreference = @"kBOChartTypePreference";

@interface TSBloodOxygenVC ()

// 日期选择
@property (nonatomic, strong) UIView *datePickerContainer;
@property (nonatomic, strong) UIButton *prevDayButton;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *nextDayButton;
@property (nonatomic, strong) UIButton *todayButton;

// 图表类型切换
@property (nonatomic, strong) UISegmentedControl *chartTypeSegment;

// 图表
@property (nonatomic, strong) TSBODayChartView *chartView;

// 统计卡片
@property (nonatomic, strong) UIView *statsCard;
@property (nonatomic, strong) UILabel *maxBOLabel;
@property (nonatomic, strong) UILabel *maxBOValueLabel;
@property (nonatomic, strong) UILabel *avgBOLabel;
@property (nonatomic, strong) UILabel *avgBOValueLabel;
@property (nonatomic, strong) UILabel *minBOLabel;
@property (nonatomic, strong) UILabel *minBOValueLabel;

// 数据
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) TSBODailyModel *dailyModel;

// 同步按钮
@property (nonatomic, strong) UIBarButtonItem *syncButton;
@property (nonatomic, assign) BOOL isSyncing;

@end

@implementation TSBloodOxygenVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"blood_oxygen.page_title");
    [self initData];
    [self setupViews];
    [self layoutViews];
    [self loadDataForCurrentDate];
}

#pragma mark - 初始化数据

/**
 * 初始化数据
 */
- (void)initData {
    self.currentDate = [NSDate date];
    self.isSyncing = NO;
}

#pragma mark - 构建视图

/**
 * 构建视图
 */
- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;

    // 导航栏同步按钮
    self.syncButton = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"sync.button")
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(onSyncButtonTapped)];
    self.navigationItem.rightBarButtonItem = self.syncButton;

    // 日期选择器容器
    [self.view addSubview:self.datePickerContainer];
    [self.datePickerContainer addSubview:self.prevDayButton];
    [self.datePickerContainer addSubview:self.dateLabel];
    [self.datePickerContainer addSubview:self.nextDayButton];
    [self.datePickerContainer addSubview:self.todayButton];

    // 图表类型切换
    [self.view addSubview:self.chartTypeSegment];

    // 图表
    [self.view addSubview:self.chartView];

    // 统计卡片
    [self.view addSubview:self.statsCard];
    [self.statsCard addSubview:self.maxBOLabel];
    [self.statsCard addSubview:self.maxBOValueLabel];
    [self.statsCard addSubview:self.avgBOLabel];
    [self.statsCard addSubview:self.avgBOValueLabel];
    [self.statsCard addSubview:self.minBOLabel];
    [self.statsCard addSubview:self.minBOValueLabel];
}

#pragma mark - 布局视图

/**
 * 布局视图
 */
- (void)layoutViews {
    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    CGFloat safeTop = self.view.safeAreaInsets.top > 0 ? self.view.safeAreaInsets.top : 88;

    // 日期选择器
    self.datePickerContainer.frame = CGRectMake(0, safeTop, screenWidth, 60);

    CGFloat buttonWidth = 44;
    CGFloat spacing = 12;
    CGFloat labelWidth = screenWidth - buttonWidth * 3 - spacing * 4;

    self.prevDayButton.frame = CGRectMake(spacing, 15, buttonWidth, 30);
    self.dateLabel.frame = CGRectMake(CGRectGetMaxX(self.prevDayButton.frame) + spacing, 15, labelWidth, 30);
    self.nextDayButton.frame = CGRectMake(CGRectGetMaxX(self.dateLabel.frame) + spacing, 15, buttonWidth, 30);
    self.todayButton.frame = CGRectMake(screenWidth - buttonWidth - spacing, 15, buttonWidth, 30);

    // 图表类型切换
    CGFloat segmentY = CGRectGetMaxY(self.datePickerContainer.frame) + TSSpacing_MD;
    self.chartTypeSegment.frame = CGRectMake(TSSpacing_MD, segmentY, screenWidth - TSSpacing_MD * 2, 32);

    // 图表
    CGFloat chartY = CGRectGetMaxY(self.chartTypeSegment.frame) + TSSpacing_MD;
    CGFloat chartHeight = 240;
    self.chartView.frame = CGRectMake(TSSpacing_MD, chartY, screenWidth - TSSpacing_MD * 2, chartHeight);

    // 统计卡片
    CGFloat statsY = CGRectGetMaxY(self.chartView.frame) + TSSpacing_MD;
    CGFloat statsHeight = 100;
    self.statsCard.frame = CGRectMake(TSSpacing_MD, statsY, screenWidth - TSSpacing_MD * 2, statsHeight);

    CGFloat itemWidth = (CGRectGetWidth(self.statsCard.bounds) - TSSpacing_MD * 2) / 3;

    // 最高血氧
    self.maxBOLabel.frame = CGRectMake(0, TSSpacing_MD, itemWidth, 20);
    self.maxBOValueLabel.frame = CGRectMake(0, CGRectGetMaxY(self.maxBOLabel.frame) + 4, itemWidth, 40);

    // 平均血氧
    self.avgBOLabel.frame = CGRectMake(itemWidth, TSSpacing_MD, itemWidth, 20);
    self.avgBOValueLabel.frame = CGRectMake(itemWidth, CGRectGetMaxY(self.avgBOLabel.frame) + 4, itemWidth, 40);

    // 最低血氧
    self.minBOLabel.frame = CGRectMake(itemWidth * 2, TSSpacing_MD, itemWidth, 20);
    self.minBOValueLabel.frame = CGRectMake(itemWidth * 2, CGRectGetMaxY(self.minBOLabel.frame) + 4, itemWidth, 40);
}

#pragma mark - 事件处理

/**
 * 同步按钮点击
 */
- (void)onSyncButtonTapped {
    if (self.isSyncing) return;
    [self syncDataForCurrentDate];
}

/**
 * 前一天按钮点击
 */
- (void)onPrevDayButtonTapped {
    self.currentDate = [self dateByAddingDays:-1 toDate:self.currentDate];
    [self updateDateLabel];
    [self loadDataForCurrentDate];
}

/**
 * 后一天按钮点击
 */
- (void)onNextDayButtonTapped {
    NSDate *nextDay = [self dateByAddingDays:1 toDate:self.currentDate];
    if ([self isToday:nextDay] || [nextDay compare:[NSDate date]] == NSOrderedAscending) {
        self.currentDate = nextDay;
        [self updateDateLabel];
        [self loadDataForCurrentDate];
    }
}

/**
 * 今天按钮点击
 */
- (void)onTodayButtonTapped {
    self.currentDate = [NSDate date];
    [self updateDateLabel];
    [self loadDataForCurrentDate];
}

/**
 * 日期标签点击
 */
- (void)onDateLabelTapped {
    [self showDatePicker];
}

/**
 * 图表类型切换
 */
- (void)onChartTypeChanged:(UISegmentedControl *)segment {
    TSBOChartType chartType = (TSBOChartType)segment.selectedSegmentIndex;
    self.chartView.chartType = chartType;

    // 保存用户偏好
    [[NSUserDefaults standardUserDefaults] setInteger:chartType forKey:kBOChartTypePreference];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 数据加载

/**
 * 加载当前日期的数据
 */
- (void)loadDataForCurrentDate {
    [self syncDataForCurrentDate];
}

/**
 * 同步当前日期的数据
 */
- (void)syncDataForCurrentDate {
    if (self.isSyncing) return;

    self.isSyncing = YES;
    [self startSyncAnimation];

    NSTimeInterval startTime = [self startOfDay:self.currentDate];
    NSTimeInterval endTime = [self endOfDay:self.currentDate];

    __weak typeof(self) weakSelf = self;

    // 使用 SDK 的 syncDailyDataFromStartTime:endTime:completion: 方法
    [[[TopStepComKit sharedInstance] bloodOxygen] syncDailyDataFromStartTime:startTime endTime:endTime completion:^(NSArray<TSBODailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        if (dailyModels.count > 0) {
            strongSelf.dailyModel = dailyModels.firstObject;
        } else {
            strongSelf.dailyModel = nil;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.isSyncing = NO;
            [strongSelf stopSyncAnimation];
            [strongSelf updateUI];
        });
    }];
}

/**
 * 更新 UI
 */
- (void)updateUI {
    [self updateStatsCard];
    [self updateChart];
}

/**
 * 更新统计卡片
 */
- (void)updateStatsCard {
    if (self.dailyModel && self.dailyModel.allMeasuredItems.count > 0) {
        UInt8 maxVal = [self.dailyModel maxOxygenValue];
        UInt8 minVal = [self.dailyModel minOxygenValue];

        // 计算平均值
        NSArray<TSBOValueItem *> *allItems = [self.dailyModel allMeasuredItems];
        NSInteger sum = 0;
        for (TSBOValueItem *item in allItems) {
            sum += item.oxyValue;
        }
        NSInteger avgVal = allItems.count > 0 ? (sum / allItems.count) : 0;

        self.maxBOValueLabel.text = [NSString stringWithFormat:@"%d%%", maxVal];
        self.avgBOValueLabel.text = [NSString stringWithFormat:@"%ld%%", (long)avgVal];
        self.minBOValueLabel.text = [NSString stringWithFormat:@"%d%%", minVal];
    } else {
        self.maxBOValueLabel.text = TSLocalizedString(@"chart.placeholder");
        self.avgBOValueLabel.text = TSLocalizedString(@"chart.placeholder");
        self.minBOValueLabel.text = TSLocalizedString(@"chart.placeholder");
    }
}

/**
 * 更新图表
 */
- (void)updateChart {
    NSArray *items = self.dailyModel ? [self.dailyModel allMeasuredItems] : @[];
    [self.chartView configureWithItems:items date:self.currentDate];
}

#pragma mark - 日期选择器

/**
 * 显示日期选择器
 */
- (void)showDatePicker {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.date = self.currentDate;
    datePicker.maximumDate = [NSDate date];
    datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    datePicker.frame = CGRectMake(0, 0, CGRectGetWidth(alert.view.bounds), 216);

    [alert.view addSubview:datePicker];

    __weak typeof(self) weakSelf = self;
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.currentDate = datePicker.date;
        [strongSelf updateDateLabel];
        [strongSelf loadDataForCurrentDate];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alert addAction:confirmAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UI 更新

/**
 * 更新日期标签
 */
- (void)updateDateLabel {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    self.dateLabel.text = [formatter stringFromDate:self.currentDate];

    // 更新今天按钮显示状态
    self.todayButton.hidden = [self isToday:self.currentDate];

    // 更新后一天按钮状态
    NSDate *nextDay = [self dateByAddingDays:1 toDate:self.currentDate];
    self.nextDayButton.enabled = ([nextDay compare:[NSDate date]] != NSOrderedDescending);
    self.nextDayButton.alpha = self.nextDayButton.enabled ? 1.0 : 0.3;
}

/**
 * 开始同步动画
 */
- (void)startSyncAnimation {
    self.syncButton.enabled = NO;
}

/**
 * 停止同步动画
 */
- (void)stopSyncAnimation {
    self.syncButton.enabled = YES;
}

#pragma mark - 日期工具方法

/**
 * 获取日期的开始时间戳
 */
- (NSTimeInterval)startOfDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDate *startOfDay = [calendar dateFromComponents:components];
    return [startOfDay timeIntervalSince1970];
}

/**
 * 获取日期的结束时间戳
 */
- (NSTimeInterval)endOfDay:(NSDate *)date {
    return [self startOfDay:date] + 24 * 3600 - 1;
}

/**
 * 日期加减天数
 */
- (NSDate *)dateByAddingDays:(NSInteger)days toDate:(NSDate *)date {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = days;
    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:0];
}

/**
 * 判断是否为今天
 */
- (BOOL)isToday:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar isDateInToday:date];
}

#pragma mark - 懒加载

- (UIView *)datePickerContainer {
    if (!_datePickerContainer) {
        _datePickerContainer = [[UIView alloc] init];
        _datePickerContainer.backgroundColor = [UIColor whiteColor];
    }
    return _datePickerContainer;
}

- (UIButton *)prevDayButton {
    if (!_prevDayButton) {
        _prevDayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_prevDayButton setTitle:@"◀" forState:UIControlStateNormal];
        _prevDayButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_prevDayButton addTarget:self action:@selector(onPrevDayButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _prevDayButton;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont systemFontOfSize:15];
        _dateLabel.textColor = TSColor_TextPrimary;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.userInteractionEnabled = YES;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDateLabelTapped)];
        [_dateLabel addGestureRecognizer:tap];

        [self updateDateLabel];
    }
    return _dateLabel;
}

- (UIButton *)nextDayButton {
    if (!_nextDayButton) {
        _nextDayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_nextDayButton setTitle:@"▶" forState:UIControlStateNormal];
        _nextDayButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_nextDayButton addTarget:self action:@selector(onNextDayButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextDayButton;
}

- (UIButton *)todayButton {
    if (!_todayButton) {
        _todayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_todayButton setTitle:TSLocalizedString(@"bo.today") forState:UIControlStateNormal];
        _todayButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_todayButton addTarget:self action:@selector(onTodayButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _todayButton.hidden = YES;
    }
    return _todayButton;
}

- (UISegmentedControl *)chartTypeSegment {
    if (!_chartTypeSegment) {
        _chartTypeSegment = [[UISegmentedControl alloc] initWithItems:@[TSLocalizedString(@"stress.bar_chart"), TSLocalizedString(@"stress.line_chart")]];

        // 读取用户偏好
        NSInteger savedType = [[NSUserDefaults standardUserDefaults] integerForKey:kBOChartTypePreference];
        _chartTypeSegment.selectedSegmentIndex = savedType;

        [_chartTypeSegment addTarget:self action:@selector(onChartTypeChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _chartTypeSegment;
}

- (TSBODayChartView *)chartView {
    if (!_chartView) {
        _chartView = [[TSBODayChartView alloc] init];

        // 读取用户偏好
        NSInteger savedType = [[NSUserDefaults standardUserDefaults] integerForKey:kBOChartTypePreference];
        _chartView.chartType = (TSBOChartType)savedType;
    }
    return _chartView;
}

- (UIView *)statsCard {
    if (!_statsCard) {
        _statsCard = [[UIView alloc] init];
        _statsCard.backgroundColor = [UIColor whiteColor];
        _statsCard.layer.cornerRadius = 12;
        _statsCard.layer.masksToBounds = YES;
    }
    return _statsCard;
}

- (UILabel *)maxBOLabel {
    if (!_maxBOLabel) {
        _maxBOLabel = [[UILabel alloc] init];
        _maxBOLabel.text = TSLocalizedString(@"bo.max");
        _maxBOLabel.font = TSFont_Caption;
        _maxBOLabel.textColor = TSColor_TextSecondary;
        _maxBOLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _maxBOLabel;
}

- (UILabel *)maxBOValueLabel {
    if (!_maxBOValueLabel) {
        _maxBOValueLabel = [[UILabel alloc] init];
        _maxBOValueLabel.text = TSLocalizedString(@"chart.placeholder");
        _maxBOValueLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _maxBOValueLabel.textColor = TSColor_Success;
        _maxBOValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _maxBOValueLabel;
}

- (UILabel *)avgBOLabel {
    if (!_avgBOLabel) {
        _avgBOLabel = [[UILabel alloc] init];
        _avgBOLabel.text = TSLocalizedString(@"bo.avg");
        _avgBOLabel.font = TSFont_Caption;
        _avgBOLabel.textColor = TSColor_TextSecondary;
        _avgBOLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _avgBOLabel;
}

- (UILabel *)avgBOValueLabel {
    if (!_avgBOValueLabel) {
        _avgBOValueLabel = [[UILabel alloc] init];
        _avgBOValueLabel.text = TSLocalizedString(@"chart.placeholder");
        _avgBOValueLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _avgBOValueLabel.textColor = TSColor_Primary;
        _avgBOValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _avgBOValueLabel;
}

- (UILabel *)minBOLabel {
    if (!_minBOLabel) {
        _minBOLabel = [[UILabel alloc] init];
        _minBOLabel.text = TSLocalizedString(@"bo.min");
        _minBOLabel.font = TSFont_Caption;
        _minBOLabel.textColor = TSColor_TextSecondary;
        _minBOLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _minBOLabel;
}

- (UILabel *)minBOValueLabel {
    if (!_minBOValueLabel) {
        _minBOValueLabel = [[UILabel alloc] init];
        _minBOValueLabel.text = TSLocalizedString(@"chart.placeholder");
        _minBOValueLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _minBOValueLabel.textColor = TSColor_Danger;
        _minBOValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _minBOValueLabel;
}

@end
