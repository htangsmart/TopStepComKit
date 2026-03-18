//
//  TSStressVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSStressVC.h"
#import "TSStressDayChartView.h"

static NSString *const kStressChartTypePreference = @"kStressChartTypePreference";

@interface TSStressVC ()

// 日期选择
@property (nonatomic, strong) UIView *datePickerContainer;
@property (nonatomic, strong) UIButton *prevDayButton;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *nextDayButton;
@property (nonatomic, strong) UIButton *todayButton;

// 图表类型切换
@property (nonatomic, strong) UISegmentedControl *chartTypeSegment;

// 图表
@property (nonatomic, strong) TSStressDayChartView *chartView;

// 统计卡片
@property (nonatomic, strong) UIView *statsCard;
@property (nonatomic, strong) UILabel *maxStressLabel;
@property (nonatomic, strong) UILabel *maxStressValueLabel;
@property (nonatomic, strong) UILabel *avgStressLabel;
@property (nonatomic, strong) UILabel *avgStressValueLabel;
@property (nonatomic, strong) UILabel *minStressLabel;
@property (nonatomic, strong) UILabel *minStressValueLabel;

// 数据
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) TSStressDailyModel *dailyModel;

// 同步按钮
@property (nonatomic, strong) UIBarButtonItem *syncButton;
@property (nonatomic, assign) BOOL isSyncing;

@end

@implementation TSStressVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"stress.title");
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
    self.syncButton = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.sync")
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
    [self.statsCard addSubview:self.maxStressLabel];
    [self.statsCard addSubview:self.maxStressValueLabel];
    [self.statsCard addSubview:self.avgStressLabel];
    [self.statsCard addSubview:self.avgStressValueLabel];
    [self.statsCard addSubview:self.minStressLabel];
    [self.statsCard addSubview:self.minStressValueLabel];
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

    self.maxStressLabel.frame = CGRectMake(0, TSSpacing_MD, itemWidth, 20);
    self.maxStressValueLabel.frame = CGRectMake(0, CGRectGetMaxY(self.maxStressLabel.frame) + 4, itemWidth, 40);

    self.avgStressLabel.frame = CGRectMake(itemWidth, TSSpacing_MD, itemWidth, 20);
    self.avgStressValueLabel.frame = CGRectMake(itemWidth, CGRectGetMaxY(self.avgStressLabel.frame) + 4, itemWidth, 40);

    self.minStressLabel.frame = CGRectMake(itemWidth * 2, TSSpacing_MD, itemWidth, 20);
    self.minStressValueLabel.frame = CGRectMake(itemWidth * 2, CGRectGetMaxY(self.minStressLabel.frame) + 4, itemWidth, 40);
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
    TSStressChartType chartType = (TSStressChartType)segment.selectedSegmentIndex;
    self.chartView.chartType = chartType;

    [[NSUserDefaults standardUserDefaults] setInteger:chartType forKey:kStressChartTypePreference];
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

    [[[TopStepComKit sharedInstance] stress] syncDailyDataFromStartTime:startTime endTime:endTime completion:^(NSArray<TSStressDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        strongSelf.dailyModel = dailyModels.firstObject;

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
        UInt8 maxVal = [self.dailyModel maxStress];
        UInt8 minVal = [self.dailyModel minStress];

        NSArray<TSStressValueItem *> *allItems = [self.dailyModel allMeasuredItems];
        NSInteger sum = 0;
        for (TSStressValueItem *item in allItems) {
            sum += item.stressValue;
        }
        NSInteger avgVal = allItems.count > 0 ? (sum / allItems.count) : 0;

        self.maxStressValueLabel.text = [NSString stringWithFormat:@"%d", maxVal];
        self.avgStressValueLabel.text = [NSString stringWithFormat:@"%ld", (long)avgVal];
        self.minStressValueLabel.text = [NSString stringWithFormat:@"%d", minVal];
    } else {
        self.maxStressValueLabel.text = @"--";
        self.avgStressValueLabel.text = @"--";
        self.minStressValueLabel.text = @"--";
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.maximumDate = [NSDate date];
    datePicker.date = self.currentDate;
    if (@available(iOS 13.4, *)) {
        datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    datePicker.frame = CGRectMake(0, 0, alert.view.bounds.size.width - 32, 216);
    [alert.view addSubview:datePicker];

    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.currentDate = datePicker.date;
        [self updateDateLabel];
        [self loadDataForCurrentDate];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 更新日期标签
 */
- (void)updateDateLabel {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    self.dateLabel.text = [formatter stringFromDate:self.currentDate];

    self.nextDayButton.enabled = ![self isToday:self.currentDate];
    self.todayButton.hidden = [self isToday:self.currentDate];
}

#pragma mark - 同步动画

/**
 * 开始同步动画
 */
- (void)startSyncAnimation {
    self.syncButton.enabled = NO;
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
    if (@available(iOS 13.0, *)) {
        style = UIActivityIndicatorViewStyleMedium;
    }
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    [indicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];
}

/**
 * 停止同步动画
 */
- (void)stopSyncAnimation {
    self.syncButton.enabled = YES;
    self.navigationItem.rightBarButtonItem = self.syncButton;
}

#pragma mark - 日期工具方法

/**
 * 获取日期当天开始时间戳
 */
- (NSTimeInterval)startOfDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    return [[calendar dateFromComponents:components] timeIntervalSince1970];
}

/**
 * 获取日期当天结束时间戳
 */
- (NSTimeInterval)endOfDay:(NSDate *)date {
    return [self startOfDay:date] + 24 * 3600 - 1;
}

/**
 * 日期加减天数
 */
- (NSDate *)dateByAddingDays:(NSInteger)days toDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = days;
    return [calendar dateByAddingComponents:components toDate:date options:0];
}

/**
 * 判断是否为今天
 */
- (BOOL)isToday:(NSDate *)date {
    return [[NSCalendar currentCalendar] isDateInToday:date];
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
        _prevDayButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_prevDayButton addTarget:self action:@selector(onPrevDayButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _prevDayButton;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.font = [UIFont systemFontOfSize:15];
        _dateLabel.textColor = TSColor_TextPrimary;
        _dateLabel.userInteractionEnabled = YES;

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        _dateLabel.text = [formatter stringFromDate:[NSDate date]];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDateLabelTapped)];
        [_dateLabel addGestureRecognizer:tap];
    }
    return _dateLabel;
}

- (UIButton *)nextDayButton {
    if (!_nextDayButton) {
        _nextDayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_nextDayButton setTitle:@"▶" forState:UIControlStateNormal];
        _nextDayButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _nextDayButton.enabled = NO;
        [_nextDayButton addTarget:self action:@selector(onNextDayButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextDayButton;
}

- (UIButton *)todayButton {
    if (!_todayButton) {
        _todayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_todayButton setTitle:TSLocalizedString(@"stress.today") forState:UIControlStateNormal];
        _todayButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _todayButton.hidden = YES;
        [_todayButton addTarget:self action:@selector(onTodayButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _todayButton;
}

- (UISegmentedControl *)chartTypeSegment {
    if (!_chartTypeSegment) {
        _chartTypeSegment = [[UISegmentedControl alloc] initWithItems:@[TSLocalizedString(@"stress.bar_chart"), TSLocalizedString(@"stress.line_chart")]];
        NSInteger savedType = [[NSUserDefaults standardUserDefaults] integerForKey:kStressChartTypePreference];
        _chartTypeSegment.selectedSegmentIndex = savedType;
        [_chartTypeSegment addTarget:self action:@selector(onChartTypeChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _chartTypeSegment;
}

- (TSStressDayChartView *)chartView {
    if (!_chartView) {
        _chartView = [[TSStressDayChartView alloc] init];
        NSInteger savedType = [[NSUserDefaults standardUserDefaults] integerForKey:kStressChartTypePreference];
        _chartView.chartType = (TSStressChartType)savedType;
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

- (UILabel *)maxStressLabel {
    if (!_maxStressLabel) {
        _maxStressLabel = [[UILabel alloc] init];
        _maxStressLabel.text = TSLocalizedString(@"stress.max");
        _maxStressLabel.font = TSFont_Caption;
        _maxStressLabel.textColor = TSColor_TextSecondary;
        _maxStressLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _maxStressLabel;
}

- (UILabel *)maxStressValueLabel {
    if (!_maxStressValueLabel) {
        _maxStressValueLabel = [[UILabel alloc] init];
        _maxStressValueLabel.text = @"--";
        _maxStressValueLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _maxStressValueLabel.textColor = TSColor_Danger;
        _maxStressValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _maxStressValueLabel;
}

- (UILabel *)avgStressLabel {
    if (!_avgStressLabel) {
        _avgStressLabel = [[UILabel alloc] init];
        _avgStressLabel.text = TSLocalizedString(@"stress.avg");
        _avgStressLabel.font = TSFont_Caption;
        _avgStressLabel.textColor = TSColor_TextSecondary;
        _avgStressLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _avgStressLabel;
}

- (UILabel *)avgStressValueLabel {
    if (!_avgStressValueLabel) {
        _avgStressValueLabel = [[UILabel alloc] init];
        _avgStressValueLabel.text = @"--";
        _avgStressValueLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _avgStressValueLabel.textColor = TSColor_Primary;
        _avgStressValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _avgStressValueLabel;
}

- (UILabel *)minStressLabel {
    if (!_minStressLabel) {
        _minStressLabel = [[UILabel alloc] init];
        _minStressLabel.text = TSLocalizedString(@"stress.min");
        _minStressLabel.font = TSFont_Caption;
        _minStressLabel.textColor = TSColor_TextSecondary;
        _minStressLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _minStressLabel;
}

- (UILabel *)minStressValueLabel {
    if (!_minStressValueLabel) {
        _minStressValueLabel = [[UILabel alloc] init];
        _minStressValueLabel.text = @"--";
        _minStressValueLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _minStressValueLabel.textColor = TSColor_Success;
        _minStressValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _minStressValueLabel;
}

@end
