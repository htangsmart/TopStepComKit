//
//  TSSleepVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSSleepVC.h"
#import "TSSleepChartView.h"

@interface TSSleepVC ()

// 日期选择
@property (nonatomic, strong) UIView *datePickerContainer;
@property (nonatomic, strong) UIButton *prevDayButton;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *nextDayButton;
@property (nonatomic, strong) UIButton *todayButton;

// 汇总卡片
@property (nonatomic, strong) UIView *summaryCard;
@property (nonatomic, strong) UILabel *totalDurationLabel;
@property (nonatomic, strong) UILabel *totalDurationValueLabel;
@property (nonatomic, strong) UILabel *sleepStartLabel;
@property (nonatomic, strong) UILabel *sleepStartValueLabel;
@property (nonatomic, strong) UILabel *sleepEndLabel;
@property (nonatomic, strong) UILabel *sleepEndValueLabel;
@property (nonatomic, strong) UILabel *qualityLabel;
@property (nonatomic, strong) UILabel *qualityValueLabel;

// 图表
@property (nonatomic, strong) TSSleepChartView *chartView;

// 阶段卡片
@property (nonatomic, strong) UIView *stageCard;
@property (nonatomic, strong) UILabel *deepLabel;
@property (nonatomic, strong) UILabel *deepValueLabel;
@property (nonatomic, strong) UILabel *lightLabel;
@property (nonatomic, strong) UILabel *lightValueLabel;
@property (nonatomic, strong) UILabel *remLabel;
@property (nonatomic, strong) UILabel *remValueLabel;
@property (nonatomic, strong) UILabel *awakeLabel;
@property (nonatomic, strong) UILabel *awakeValueLabel;

// 数据
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) TSSleepSegment *nightSleep;

// 同步按钮
@property (nonatomic, strong) UIBarButtonItem *syncButton;
@property (nonatomic, assign) BOOL isSyncing;

@end

@implementation TSSleepVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"睡眠";
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

    // 汇总卡片
    [self.view addSubview:self.summaryCard];
    [self.summaryCard addSubview:self.totalDurationLabel];
    [self.summaryCard addSubview:self.totalDurationValueLabel];
    [self.summaryCard addSubview:self.sleepStartLabel];
    [self.summaryCard addSubview:self.sleepStartValueLabel];
    [self.summaryCard addSubview:self.sleepEndLabel];
    [self.summaryCard addSubview:self.sleepEndValueLabel];
    [self.summaryCard addSubview:self.qualityLabel];
    [self.summaryCard addSubview:self.qualityValueLabel];

    // 图表
    [self.view addSubview:self.chartView];

    // 阶段卡片
    [self.view addSubview:self.stageCard];
    [self.stageCard addSubview:self.deepLabel];
    [self.stageCard addSubview:self.deepValueLabel];
    [self.stageCard addSubview:self.lightLabel];
    [self.stageCard addSubview:self.lightValueLabel];
    [self.stageCard addSubview:self.remLabel];
    [self.stageCard addSubview:self.remValueLabel];
    [self.stageCard addSubview:self.awakeLabel];
    [self.stageCard addSubview:self.awakeValueLabel];
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

    // 汇总卡片
    CGFloat summaryY = CGRectGetMaxY(self.datePickerContainer.frame) + TSSpacing_MD;
    CGFloat summaryHeight = 100;
    self.summaryCard.frame = CGRectMake(TSSpacing_MD, summaryY, screenWidth - TSSpacing_MD * 2, summaryHeight);

    CGFloat itemWidth = (CGRectGetWidth(self.summaryCard.bounds) - TSSpacing_MD * 2) / 4;

    self.totalDurationLabel.frame = CGRectMake(0, TSSpacing_MD, itemWidth, 20);
    self.totalDurationValueLabel.frame = CGRectMake(0, CGRectGetMaxY(self.totalDurationLabel.frame) + 4, itemWidth, 40);

    self.sleepStartLabel.frame = CGRectMake(itemWidth, TSSpacing_MD, itemWidth, 20);
    self.sleepStartValueLabel.frame = CGRectMake(itemWidth, CGRectGetMaxY(self.sleepStartLabel.frame) + 4, itemWidth, 40);

    self.sleepEndLabel.frame = CGRectMake(itemWidth * 2, TSSpacing_MD, itemWidth, 20);
    self.sleepEndValueLabel.frame = CGRectMake(itemWidth * 2, CGRectGetMaxY(self.sleepEndLabel.frame) + 4, itemWidth, 40);

    self.qualityLabel.frame = CGRectMake(itemWidth * 3, TSSpacing_MD, itemWidth, 20);
    self.qualityValueLabel.frame = CGRectMake(itemWidth * 3, CGRectGetMaxY(self.qualityLabel.frame) + 4, itemWidth, 40);

    // 图表
    CGFloat chartY = CGRectGetMaxY(self.summaryCard.frame) + TSSpacing_MD;
    CGFloat chartHeight = 180;
    self.chartView.frame = CGRectMake(TSSpacing_MD, chartY, screenWidth - TSSpacing_MD * 2, chartHeight);

    // 阶段卡片
    CGFloat stageY = CGRectGetMaxY(self.chartView.frame) + TSSpacing_MD;
    CGFloat stageHeight = 100;
    self.stageCard.frame = CGRectMake(TSSpacing_MD, stageY, screenWidth - TSSpacing_MD * 2, stageHeight);

    CGFloat stageItemWidth = (CGRectGetWidth(self.stageCard.bounds) - TSSpacing_MD * 2) / 4;

    self.deepLabel.frame = CGRectMake(0, TSSpacing_MD, stageItemWidth, 20);
    self.deepValueLabel.frame = CGRectMake(0, CGRectGetMaxY(self.deepLabel.frame) + 4, stageItemWidth, 40);

    self.lightLabel.frame = CGRectMake(stageItemWidth, TSSpacing_MD, stageItemWidth, 20);
    self.lightValueLabel.frame = CGRectMake(stageItemWidth, CGRectGetMaxY(self.lightLabel.frame) + 4, stageItemWidth, 40);

    self.remLabel.frame = CGRectMake(stageItemWidth * 2, TSSpacing_MD, stageItemWidth, 20);
    self.remValueLabel.frame = CGRectMake(stageItemWidth * 2, CGRectGetMaxY(self.remLabel.frame) + 4, stageItemWidth, 40);

    self.awakeLabel.frame = CGRectMake(stageItemWidth * 3, TSSpacing_MD, stageItemWidth, 20);
    self.awakeValueLabel.frame = CGRectMake(stageItemWidth * 3, CGRectGetMaxY(self.awakeLabel.frame) + 4, stageItemWidth, 40);
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

    [[[TopStepComKit sharedInstance] sleep] syncDailyDataFromStartTime:startTime endTime:endTime completion:^(NSArray<TSSleepDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        // 只取夜间睡眠
        TSSleepDailyModel *model = dailyModels.firstObject;
        strongSelf.nightSleep = model.nightSleeps.firstObject;

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
    [self updateSummaryCard];
    [self updateChart];
    [self updateStageCard];
}

/**
 * 更新汇总卡片
 */
- (void)updateSummaryCard {
    if (self.nightSleep && self.nightSleep.summary) {
        TSSleepSummary *summary = self.nightSleep.summary;

        // 总时长
        self.totalDurationValueLabel.text = [self formatDuration:summary.totalSleepDuration];

        // 入睡时间
        self.sleepStartValueLabel.text = [self formatTime:summary.startTime];

        // 醒来时间
        self.sleepEndValueLabel.text = [self formatTime:summary.endTime];

        // 睡眠质量
        NSInteger quality = summary.qualityScore;
        NSString *qualityText = @"--";
        if (quality >= 80) {
            qualityText = @"优秀";
        } else if (quality >= 60) {
            qualityText = @"良好";
        } else if (quality >= 40) {
            qualityText = @"一般";
        } else if (quality > 0) {
            qualityText = @"较差";
        }
        self.qualityValueLabel.text = qualityText;
    } else {
        self.totalDurationValueLabel.text = @"--";
        self.sleepStartValueLabel.text = @"--";
        self.sleepEndValueLabel.text = @"--";
        self.qualityValueLabel.text = @"--";
    }
}

/**
 * 更新图表
 */
- (void)updateChart {
    NSArray *items = self.nightSleep ? self.nightSleep.detailItems : @[];
    [self.chartView configureWithItems:items date:self.currentDate];
}

/**
 * 更新阶段卡片
 */
- (void)updateStageCard {
    if (self.nightSleep && self.nightSleep.summary) {
        TSSleepSummary *summary = self.nightSleep.summary;

        self.deepValueLabel.text = [self formatDuration:summary.deepSleepDuration];
        self.lightValueLabel.text = [self formatDuration:summary.lightSleepDuration];
        self.remValueLabel.text = [self formatDuration:summary.remDuration];
        self.awakeValueLabel.text = [self formatDuration:summary.awakeDuration];
    } else {
        self.deepValueLabel.text = @"--";
        self.lightValueLabel.text = @"--";
        self.remValueLabel.text = @"--";
        self.awakeValueLabel.text = @"--";
    }
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

    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.currentDate = datePicker.date;
        [self updateDateLabel];
        [self loadDataForCurrentDate];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

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

#pragma mark - 格式化工具

/**
 * 格式化时长（秒 → "X小时Y分"）
 */
- (NSString *)formatDuration:(NSInteger)seconds {
    if (seconds <= 0) return @"0分";

    NSInteger hours = seconds / 3600;
    NSInteger minutes = (seconds % 3600) / 60;

    if (hours > 0 && minutes > 0) {
        return [NSString stringWithFormat:@"%ld小时%ld分", (long)hours, (long)minutes];
    } else if (hours > 0) {
        return [NSString stringWithFormat:@"%ld小时", (long)hours];
    } else {
        return [NSString stringWithFormat:@"%ld分", (long)minutes];
    }
}

/**
 * 格式化时间戳（时间戳 → "HH:mm"）
 */
- (NSString *)formatTime:(NSTimeInterval)timestamp {
    if (timestamp <= 0) return @"--";

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    return [formatter stringFromDate:date];
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
        [_todayButton setTitle:@"今天" forState:UIControlStateNormal];
        _todayButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _todayButton.hidden = YES;
        [_todayButton addTarget:self action:@selector(onTodayButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _todayButton;
}

- (UIView *)summaryCard {
    if (!_summaryCard) {
        _summaryCard = [[UIView alloc] init];
        _summaryCard.backgroundColor = [UIColor whiteColor];
        _summaryCard.layer.cornerRadius = 12;
        _summaryCard.layer.masksToBounds = YES;
    }
    return _summaryCard;
}

- (UILabel *)totalDurationLabel {
    if (!_totalDurationLabel) {
        _totalDurationLabel = [[UILabel alloc] init];
        _totalDurationLabel.text = @"总时长";
        _totalDurationLabel.font = TSFont_Caption;
        _totalDurationLabel.textColor = TSColor_TextSecondary;
        _totalDurationLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalDurationLabel;
}

- (UILabel *)totalDurationValueLabel {
    if (!_totalDurationValueLabel) {
        _totalDurationValueLabel = [[UILabel alloc] init];
        _totalDurationValueLabel.text = @"--";
        _totalDurationValueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _totalDurationValueLabel.textColor = TSColor_Primary;
        _totalDurationValueLabel.textAlignment = NSTextAlignmentCenter;
        _totalDurationValueLabel.numberOfLines = 0;
    }
    return _totalDurationValueLabel;
}

- (UILabel *)sleepStartLabel {
    if (!_sleepStartLabel) {
        _sleepStartLabel = [[UILabel alloc] init];
        _sleepStartLabel.text = @"入睡";
        _sleepStartLabel.font = TSFont_Caption;
        _sleepStartLabel.textColor = TSColor_TextSecondary;
        _sleepStartLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _sleepStartLabel;
}

- (UILabel *)sleepStartValueLabel {
    if (!_sleepStartValueLabel) {
        _sleepStartValueLabel = [[UILabel alloc] init];
        _sleepStartValueLabel.text = @"--";
        _sleepStartValueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _sleepStartValueLabel.textColor = TSColor_TextPrimary;
        _sleepStartValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _sleepStartValueLabel;
}

- (UILabel *)sleepEndLabel {
    if (!_sleepEndLabel) {
        _sleepEndLabel = [[UILabel alloc] init];
        _sleepEndLabel.text = @"醒来";
        _sleepEndLabel.font = TSFont_Caption;
        _sleepEndLabel.textColor = TSColor_TextSecondary;
        _sleepEndLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _sleepEndLabel;
}

- (UILabel *)sleepEndValueLabel {
    if (!_sleepEndValueLabel) {
        _sleepEndValueLabel = [[UILabel alloc] init];
        _sleepEndValueLabel.text = @"--";
        _sleepEndValueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _sleepEndValueLabel.textColor = TSColor_TextPrimary;
        _sleepEndValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _sleepEndValueLabel;
}

- (UILabel *)qualityLabel {
    if (!_qualityLabel) {
        _qualityLabel = [[UILabel alloc] init];
        _qualityLabel.text = @"质量";
        _qualityLabel.font = TSFont_Caption;
        _qualityLabel.textColor = TSColor_TextSecondary;
        _qualityLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _qualityLabel;
}

- (UILabel *)qualityValueLabel {
    if (!_qualityValueLabel) {
        _qualityValueLabel = [[UILabel alloc] init];
        _qualityValueLabel.text = @"--";
        _qualityValueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _qualityValueLabel.textColor = TSColor_Success;
        _qualityValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _qualityValueLabel;
}

- (TSSleepChartView *)chartView {
    if (!_chartView) {
        _chartView = [[TSSleepChartView alloc] init];
    }
    return _chartView;
}

- (UIView *)stageCard {
    if (!_stageCard) {
        _stageCard = [[UIView alloc] init];
        _stageCard.backgroundColor = [UIColor whiteColor];
        _stageCard.layer.cornerRadius = 12;
        _stageCard.layer.masksToBounds = YES;
    }
    return _stageCard;
}

- (UILabel *)deepLabel {
    if (!_deepLabel) {
        _deepLabel = [[UILabel alloc] init];
        _deepLabel.text = @"深睡";
        _deepLabel.font = TSFont_Caption;
        _deepLabel.textColor = TSColor_TextSecondary;
        _deepLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _deepLabel;
}

- (UILabel *)deepValueLabel {
    if (!_deepValueLabel) {
        _deepValueLabel = [[UILabel alloc] init];
        _deepValueLabel.text = @"--";
        _deepValueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _deepValueLabel.textColor = [UIColor colorWithRed:0x1E/255.0 green:0x3A/255.0 blue:0x8A/255.0 alpha:1.0];
        _deepValueLabel.textAlignment = NSTextAlignmentCenter;
        _deepValueLabel.numberOfLines = 0;
    }
    return _deepValueLabel;
}

- (UILabel *)lightLabel {
    if (!_lightLabel) {
        _lightLabel = [[UILabel alloc] init];
        _lightLabel.text = @"浅睡";
        _lightLabel.font = TSFont_Caption;
        _lightLabel.textColor = TSColor_TextSecondary;
        _lightLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _lightLabel;
}

- (UILabel *)lightValueLabel {
    if (!_lightValueLabel) {
        _lightValueLabel = [[UILabel alloc] init];
        _lightValueLabel.text = @"--";
        _lightValueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _lightValueLabel.textColor = [UIColor colorWithRed:0x60/255.0 green:0xA5/255.0 blue:0xFA/255.0 alpha:1.0];
        _lightValueLabel.textAlignment = NSTextAlignmentCenter;
        _lightValueLabel.numberOfLines = 0;
    }
    return _lightValueLabel;
}

- (UILabel *)remLabel {
    if (!_remLabel) {
        _remLabel = [[UILabel alloc] init];
        _remLabel.text = @"REM";
        _remLabel.font = TSFont_Caption;
        _remLabel.textColor = TSColor_TextSecondary;
        _remLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _remLabel;
}

- (UILabel *)remValueLabel {
    if (!_remValueLabel) {
        _remValueLabel = [[UILabel alloc] init];
        _remValueLabel.text = @"--";
        _remValueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _remValueLabel.textColor = [UIColor colorWithRed:0xA8/255.0 green:0x55/255.0 blue:0xF7/255.0 alpha:1.0];
        _remValueLabel.textAlignment = NSTextAlignmentCenter;
        _remValueLabel.numberOfLines = 0;
    }
    return _remValueLabel;
}

- (UILabel *)awakeLabel {
    if (!_awakeLabel) {
        _awakeLabel = [[UILabel alloc] init];
        _awakeLabel.text = @"清醒";
        _awakeLabel.font = TSFont_Caption;
        _awakeLabel.textColor = TSColor_TextSecondary;
        _awakeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _awakeLabel;
}

- (UILabel *)awakeValueLabel {
    if (!_awakeValueLabel) {
        _awakeValueLabel = [[UILabel alloc] init];
        _awakeValueLabel.text = @"--";
        _awakeValueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _awakeValueLabel.textColor = [UIColor colorWithRed:0xD1/255.0 green:0xD5/255.0 blue:0xDB/255.0 alpha:1.0];
        _awakeValueLabel.textAlignment = NSTextAlignmentCenter;
        _awakeValueLabel.numberOfLines = 0;
    }
    return _awakeValueLabel;
}

@end
