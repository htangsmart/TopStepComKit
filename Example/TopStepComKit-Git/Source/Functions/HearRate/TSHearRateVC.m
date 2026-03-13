//
//  TSHearRateVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSHearRateVC.h"
#import "TSHRDayChartView.h"

static NSString *const kHRChartTypePreference = @"kHRChartTypePreference";

@interface TSHearRateVC ()

// 日期选择
@property (nonatomic, strong) UIView *datePickerContainer;
@property (nonatomic, strong) UIButton *prevDayButton;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *nextDayButton;
@property (nonatomic, strong) UIButton *todayButton;

// 图表类型切换
@property (nonatomic, strong) UISegmentedControl *chartTypeSegment;

// 图表
@property (nonatomic, strong) TSHRDayChartView *chartView;

// 统计卡片
@property (nonatomic, strong) UIView *statsCard;
@property (nonatomic, strong) UILabel *maxHRLabel;
@property (nonatomic, strong) UILabel *maxHRValueLabel;
@property (nonatomic, strong) UILabel *restingHRLabel;
@property (nonatomic, strong) UILabel *restingHRValueLabel;
@property (nonatomic, strong) UILabel *minHRLabel;
@property (nonatomic, strong) UILabel *minHRValueLabel;

// 数据
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) TSHRDailyModel *dailyModel;

// 同步按钮
@property (nonatomic, strong) UIBarButtonItem *syncButton;
@property (nonatomic, assign) BOOL isSyncing;

@end

@implementation TSHearRateVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"心率";
    [self initData];
    [self setupViews];
    [self layoutViews];
    [self loadDataForCurrentDate];
}

#pragma mark - 初始化数据

- (void)initData {
    self.currentDate = [NSDate date];
    self.isSyncing = NO;
}

#pragma mark - 构建视图

- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;

    // 导航栏同步按钮
    self.syncButton = [[UIBarButtonItem alloc] initWithTitle:@"同步"
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
    [self.statsCard addSubview:self.maxHRLabel];
    [self.statsCard addSubview:self.maxHRValueLabel];
    [self.statsCard addSubview:self.restingHRLabel];
    [self.statsCard addSubview:self.restingHRValueLabel];
    [self.statsCard addSubview:self.minHRLabel];
    [self.statsCard addSubview:self.minHRValueLabel];
}

#pragma mark - 布局视图

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

    // 最大心率
    self.maxHRLabel.frame = CGRectMake(0, TSSpacing_MD, itemWidth, 20);
    self.maxHRValueLabel.frame = CGRectMake(0, CGRectGetMaxY(self.maxHRLabel.frame) + 4, itemWidth, 40);

    // 静息心率
    self.restingHRLabel.frame = CGRectMake(itemWidth, TSSpacing_MD, itemWidth, 20);
    self.restingHRValueLabel.frame = CGRectMake(itemWidth, CGRectGetMaxY(self.restingHRLabel.frame) + 4, itemWidth, 40);

    // 最小心率
    self.minHRLabel.frame = CGRectMake(itemWidth * 2, TSSpacing_MD, itemWidth, 20);
    self.minHRValueLabel.frame = CGRectMake(itemWidth * 2, CGRectGetMaxY(self.minHRLabel.frame) + 4, itemWidth, 40);
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
- (void)onPrevDayTapped {
    NSDate *prevDay = [self dateByAddingDays:-1 toDate:self.currentDate];
    self.currentDate = prevDay;
    [self updateDateDisplay];
    [self loadDataForCurrentDate];
}

/**
 * 后一天按钮点击
 */
- (void)onNextDayTapped {
    if ([self isToday:self.currentDate]) return;

    NSDate *nextDay = [self dateByAddingDays:1 toDate:self.currentDate];
    if ([nextDay compare:[NSDate date]] == NSOrderedDescending) return;

    self.currentDate = nextDay;
    [self updateDateDisplay];
    [self loadDataForCurrentDate];
}

/**
 * 今天按钮点击
 */
- (void)onTodayTapped {
    if ([self isToday:self.currentDate]) return;

    self.currentDate = [NSDate date];
    [self updateDateDisplay];
    [self loadDataForCurrentDate];
}

/**
 * 日期标签点击
 */
- (void)onDateLabelTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择日期" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.maximumDate = [NSDate date];
    datePicker.date = self.currentDate;
    if (@available(iOS 13.4, *)) {
        datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }

    UIViewController *pickerVC = [[UIViewController alloc] init];
    pickerVC.view = datePicker;
    pickerVC.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 216);
    [alert setValue:pickerVC forKey:@"contentViewController"];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.currentDate = datePicker.date;
        [self updateDateDisplay];
        [self loadDataForCurrentDate];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 图表类型切换
 */
- (void)onChartTypeChanged:(UISegmentedControl *)segment {
    TSHRChartType chartType = segment.selectedSegmentIndex == 0 ? TSHRChartTypeBar : TSHRChartTypeLine;
    self.chartView.chartType = chartType;

    // 保存用户偏好
    [[NSUserDefaults standardUserDefaults] setInteger:chartType forKey:kHRChartTypePreference];
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

    // 同步每日汇总（包含 allMeasuredItems、maxHRItem、minHRItem、restingItems）
    [[[TopStepComKit sharedInstance] heartRate] syncDailyDataFromStartTime:startTime endTime:endTime completion:^(NSArray<TSHRDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        if (dailyModels.count > 0) {
            strongSelf.dailyModel = dailyModels.firstObject;
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
    if (self.dailyModel) {
        NSInteger maxBPM = self.dailyModel.maxBPM;
        NSInteger minBPM = self.dailyModel.minBPM;
        NSInteger restingBPM = 0;

        if (self.dailyModel.restingItems.count > 0) {
            TSHRValueItem *lastResting = self.dailyModel.restingItems.lastObject;
            restingBPM = lastResting.hrValue;
        }

        self.maxHRValueLabel.text = maxBPM > 0 ? [NSString stringWithFormat:@"%ld", (long)maxBPM] : @"--";
        self.minHRValueLabel.text = minBPM > 0 ? [NSString stringWithFormat:@"%ld", (long)minBPM] : @"--";
        self.restingHRValueLabel.text = restingBPM > 0 ? [NSString stringWithFormat:@"%ld", (long)restingBPM] : @"--";
    } else {
        self.maxHRValueLabel.text = @"--";
        self.minHRValueLabel.text = @"--";
        self.restingHRValueLabel.text = @"--";
    }
}

/**
 * 更新图表
 */
- (void)updateChart {
    NSArray<TSHRValueItem *> *items = [self.dailyModel allMeasuredItems] ?: @[];
    [self.chartView configureWithItems:items date:self.currentDate];
}

/**
 * 更新日期显示
 */
- (void)updateDateDisplay {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日";
    NSString *dateStr = [formatter stringFromDate:self.currentDate];

    if ([self isToday:self.currentDate]) {
        self.dateLabel.text = [NSString stringWithFormat:@"%@（今天）", dateStr];
        self.nextDayButton.enabled = NO;
        self.nextDayButton.alpha = 0.3;
        self.todayButton.hidden = YES;
    } else {
        self.dateLabel.text = dateStr;
        self.nextDayButton.enabled = YES;
        self.nextDayButton.alpha = 1.0;
        self.todayButton.hidden = NO;
    }
}

/**
 * 开始同步动画
 */
- (void)startSyncAnimation {
    self.syncButton.enabled = NO;
    self.syncButton.title = @"同步中...";
}

/**
 * 停止同步动画
 */
- (void)stopSyncAnimation {
    self.syncButton.enabled = YES;
    self.syncButton.title = @"同步";
}

#pragma mark - 日期工具

/**
 * 判断是否是今天
 */
- (BOOL)isToday:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar isDateInToday:date];
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
 * 获取某天的开始时间戳
 */
- (NSTimeInterval)startOfDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startOfDay = [calendar startOfDayForDate:date];
    return [startOfDay timeIntervalSince1970];
}

/**
 * 获取某天的结束时间戳
 */
- (NSTimeInterval)endOfDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startOfDay = [calendar startOfDayForDate:date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    components.second = -1;
    NSDate *endOfDay = [calendar dateByAddingComponents:components toDate:startOfDay options:0];
    return [endOfDay timeIntervalSince1970];
}

#pragma mark - 懒加载

- (UIView *)datePickerContainer {
    if (!_datePickerContainer) {
        _datePickerContainer = [[UIView alloc] init];
        _datePickerContainer.backgroundColor = TSColor_Card;
    }
    return _datePickerContainer;
}

- (UIButton *)prevDayButton {
    if (!_prevDayButton) {
        _prevDayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_prevDayButton setTitle:@"◀" forState:UIControlStateNormal];
        _prevDayButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_prevDayButton addTarget:self action:@selector(onPrevDayTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _prevDayButton;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = TSFont_H2;
        _dateLabel.textColor = TSColor_TextPrimary;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.userInteractionEnabled = YES;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDateLabelTapped)];
        [_dateLabel addGestureRecognizer:tap];

        [self updateDateDisplay];
    }
    return _dateLabel;
}

- (UIButton *)nextDayButton {
    if (!_nextDayButton) {
        _nextDayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_nextDayButton setTitle:@"▶" forState:UIControlStateNormal];
        _nextDayButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_nextDayButton addTarget:self action:@selector(onNextDayTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextDayButton;
}

- (UIButton *)todayButton {
    if (!_todayButton) {
        _todayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_todayButton setTitle:@"今天" forState:UIControlStateNormal];
        _todayButton.titleLabel.font = TSFont_Caption;
        [_todayButton addTarget:self action:@selector(onTodayTapped) forControlEvents:UIControlEventTouchUpInside];
        _todayButton.hidden = YES;
    }
    return _todayButton;
}

- (UISegmentedControl *)chartTypeSegment {
    if (!_chartTypeSegment) {
        _chartTypeSegment = [[UISegmentedControl alloc] initWithItems:@[@"柱状图", @"折线图"]];

        // 读取用户偏好
        NSInteger savedType = [[NSUserDefaults standardUserDefaults] integerForKey:kHRChartTypePreference];
        _chartTypeSegment.selectedSegmentIndex = savedType;

        [_chartTypeSegment addTarget:self action:@selector(onChartTypeChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _chartTypeSegment;
}

- (TSHRDayChartView *)chartView {
    if (!_chartView) {
        _chartView = [[TSHRDayChartView alloc] init];
        _chartView.backgroundColor = TSColor_Card;
        _chartView.layer.cornerRadius = TSRadius_MD;
        _chartView.layer.masksToBounds = YES;

        // 设置初始图表类型
        NSInteger savedType = [[NSUserDefaults standardUserDefaults] integerForKey:kHRChartTypePreference];
        _chartView.chartType = savedType;
    }
    return _chartView;
}

- (UIView *)statsCard {
    if (!_statsCard) {
        _statsCard = [[UIView alloc] init];
        _statsCard.backgroundColor = TSColor_Card;
        _statsCard.layer.cornerRadius = TSRadius_MD;
        _statsCard.layer.shadowColor = [UIColor blackColor].CGColor;
        _statsCard.layer.shadowOffset = CGSizeMake(0, 2);
        _statsCard.layer.shadowOpacity = 0.05;
        _statsCard.layer.shadowRadius = 8;
    }
    return _statsCard;
}

- (UILabel *)maxHRLabel {
    if (!_maxHRLabel) {
        _maxHRLabel = [[UILabel alloc] init];
        _maxHRLabel.text = @"最大心率";
        _maxHRLabel.font = TSFont_Caption;
        _maxHRLabel.textColor = TSColor_TextSecondary;
        _maxHRLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _maxHRLabel;
}

- (UILabel *)maxHRValueLabel {
    if (!_maxHRValueLabel) {
        _maxHRValueLabel = [[UILabel alloc] init];
        _maxHRValueLabel.text = @"--";
        _maxHRValueLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _maxHRValueLabel.textColor = TSColor_Danger;
        _maxHRValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _maxHRValueLabel;
}

- (UILabel *)restingHRLabel {
    if (!_restingHRLabel) {
        _restingHRLabel = [[UILabel alloc] init];
        _restingHRLabel.text = @"静息心率";
        _restingHRLabel.font = TSFont_Caption;
        _restingHRLabel.textColor = TSColor_TextSecondary;
        _restingHRLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _restingHRLabel;
}

- (UILabel *)restingHRValueLabel {
    if (!_restingHRValueLabel) {
        _restingHRValueLabel = [[UILabel alloc] init];
        _restingHRValueLabel.text = @"--";
        _restingHRValueLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _restingHRValueLabel.textColor = TSColor_Success;
        _restingHRValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _restingHRValueLabel;
}

- (UILabel *)minHRLabel {
    if (!_minHRLabel) {
        _minHRLabel = [[UILabel alloc] init];
        _minHRLabel.text = @"最小心率";
        _minHRLabel.font = TSFont_Caption;
        _minHRLabel.textColor = TSColor_TextSecondary;
        _minHRLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _minHRLabel;
}

- (UILabel *)minHRValueLabel {
    if (!_minHRValueLabel) {
        _minHRValueLabel = [[UILabel alloc] init];
        _minHRValueLabel.text = @"--";
        _minHRValueLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _minHRValueLabel.textColor = TSColor_Primary;
        _minHRValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _minHRValueLabel;
}

@end
