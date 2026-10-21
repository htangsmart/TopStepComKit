//
//  TSHearRateVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSHearRateVC.h"
#import "TSHRAlertCoordinator.h"
#import "TSHRDayChartView.h"

static NSString *const kHRChartTypePreference = @"kHRChartTypePreference";

@interface TSHearRateVC ()

// 页面内容支持小屏及横屏滚动
@property (nonatomic, strong) UIScrollView *contentScrollView;

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

// 只读告警调试信息，不负责注册 SDK 监听
@property (nonatomic, strong) UIView *alertDebugCard;
@property (nonatomic, strong) UILabel *alertDebugTitleLabel;
@property (nonatomic, strong) UILabel *alertStatusLabel;
@property (nonatomic, strong) UILabel *alertErrorLabel;
@property (nonatomic, strong) UIButton *latestAlertButton;
@property (nonatomic, strong) UILabel *alertDebugHintLabel;

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
    self.title = TSLocalizedString(@"hr.page_title");
    [self initData];
    [self setupViews];
    [self layoutViews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAlertCoordinatorUpdated:)
                                                 name:TSHRAlertCoordinatorDidUpdateNotification
                                               object:[TSHRAlertCoordinator sharedInstance]];
    [self updateAlertDebugCard];
    [self loadDataForCurrentDate];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TSHRAlertCoordinatorDidUpdateNotification
                                                  object:[TSHRAlertCoordinator sharedInstance]];
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
    self.syncButton = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"sync.button")
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(onSyncButtonTapped)];
    self.navigationItem.rightBarButtonItem = self.syncButton;

    [self.view addSubview:self.contentScrollView];

    // 日期选择器容器
    [self.contentScrollView addSubview:self.datePickerContainer];
    [self.datePickerContainer addSubview:self.prevDayButton];
    [self.datePickerContainer addSubview:self.dateLabel];
    [self.datePickerContainer addSubview:self.nextDayButton];
    [self.datePickerContainer addSubview:self.todayButton];

    // 图表类型切换
    [self.contentScrollView addSubview:self.chartTypeSegment];

    // 图表
    [self.contentScrollView addSubview:self.chartView];

    // 统计卡片
    [self.contentScrollView addSubview:self.statsCard];
    [self.statsCard addSubview:self.maxHRLabel];
    [self.statsCard addSubview:self.maxHRValueLabel];
    [self.statsCard addSubview:self.restingHRLabel];
    [self.statsCard addSubview:self.restingHRValueLabel];
    [self.statsCard addSubview:self.minHRLabel];
    [self.statsCard addSubview:self.minHRValueLabel];

    // 监听生命周期由 App 协调器管理，页面只呈现快照
    [self.contentScrollView addSubview:self.alertDebugCard];
    [self.alertDebugCard addSubview:self.alertDebugTitleLabel];
    [self.alertDebugCard addSubview:self.alertStatusLabel];
    [self.alertDebugCard addSubview:self.alertErrorLabel];
    [self.alertDebugCard addSubview:self.latestAlertButton];
    [self.alertDebugCard addSubview:self.alertDebugHintLabel];
}

#pragma mark - 布局视图

- (void)layoutViews {
    CGRect contentFrame = self.view.safeAreaLayoutGuide.layoutFrame;
    self.contentScrollView.frame = contentFrame;
    CGFloat screenWidth = CGRectGetWidth(contentFrame);

    // 日期选择器
    self.datePickerContainer.frame = CGRectMake(0, 0, screenWidth, 60);

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

    [self layoutAlertDebugCard];
    CGFloat contentHeight = CGRectGetMaxY(self.alertDebugCard.frame) + TSSpacing_MD;
    self.contentScrollView.contentSize = CGSizeMake(screenWidth, contentHeight);
}

// 按文字内容计算调试卡片高度，避免错误信息和本地化文案被截断
- (void)layoutAlertDebugCard {
    CGFloat cardWidth = CGRectGetWidth(self.statsCard.frame);
    CGFloat textWidth = MAX(0, cardWidth - TSSpacing_MD * 2);
    CGFloat contentY = TSSpacing_MD;
    NSArray<UILabel *> *statusLabels = @[self.alertDebugTitleLabel, self.alertStatusLabel, self.alertErrorLabel];
    for (UILabel *label in statusLabels) {
        if (label.hidden) {
            label.frame = CGRectZero;
            continue;
        }
        CGFloat labelHeight = ceil([label sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height);
        label.frame = CGRectMake(TSSpacing_MD, contentY, textWidth, labelHeight);
        contentY += labelHeight + TSSpacing_SM;
    }
    CGFloat latestHeight = MAX(44, ceil([self.latestAlertButton.titleLabel
                                       sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height) + TSSpacing_MD);
    self.latestAlertButton.frame = CGRectMake(TSSpacing_MD, contentY, textWidth, latestHeight);
    contentY += latestHeight + TSSpacing_SM;
    CGFloat hintHeight = ceil([self.alertDebugHintLabel sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height);
    self.alertDebugHintLabel.frame = CGRectMake(TSSpacing_MD, contentY, textWidth, hintHeight);
    self.alertDebugCard.frame = CGRectMake(TSSpacing_MD, CGRectGetMaxY(self.statsCard.frame) + TSSpacing_MD,
                                          cardWidth, contentY + hintHeight + TSSpacing_MD);
}

#pragma mark - 事件处理

// 协调器保证在主线程通知，页面只刷新状态和最近一次回调
- (void)onAlertCoordinatorUpdated:(NSNotification *)notification {
    [self updateAlertDebugCard];
}

// 展示回调模型原始语义，接收时间不作为异常开始时间
- (void)onLatestAlertTapped {
    TSHRAlertModel *alert = [TSHRAlertCoordinator sharedInstance].latestAlert;
    if (!alert || self.presentedViewController) {
        return;
    }
    NSString *message = [NSString stringWithFormat:TSLocalizedString(@"hr.alert.detail.fields_format"),
                         [self formattedReceiveTimeForAlert:alert], [self modeTextForAlert:alert],
                         [self typeTextForAlert:alert], (unsigned int)alert.hrValue, [self thresholdTextForAlert:alert]];
    message = [message stringByAppendingFormat:@"\n\n%@", TSLocalizedString(@"hr.alert.detail.explanation")];
    UIAlertController *detail = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"hr.alert.detail.title")
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [detail addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.close")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:detail animated:YES completion:nil];
}

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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"hr.select_date") message:nil preferredStyle:UIAlertControllerStyleActionSheet];

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

    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.currentDate = datePicker.date;
        [self updateDateDisplay];
        [self loadDataForCurrentDate];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];

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

// 直接读取 App 快照，进入页面不会注册或清除监听
- (void)updateAlertDebugCard {
    TSHRAlertCoordinator *coordinator = [TSHRAlertCoordinator sharedInstance];
    NSString *statusKey = @"hr.alert.status.waiting";
    UIColor *statusColor = TSColor_TextSecondary;
    switch (coordinator.listenerStatus) {
        case TSHRAlertListenerStatusWaitingForDevice:
            break;
        case TSHRAlertListenerStatusNotSupported:
            statusKey = @"hr.alert.status.unsupported";
            break;
        case TSHRAlertListenerStatusListening:
            statusKey = @"hr.alert.status.listening";
            statusColor = TSColor_Success;
            break;
        case TSHRAlertListenerStatusFailed:
            statusKey = @"hr.alert.status.failed";
            statusColor = TSColor_Warning;
            break;
    }
    self.alertStatusLabel.text = [NSString stringWithFormat:TSLocalizedString(@"hr.alert.debug.status_format"),
                                 TSLocalizedString(statusKey)];
    self.alertStatusLabel.textColor = statusColor;
    BOOL showError = coordinator.listenerStatus == TSHRAlertListenerStatusFailed;
    self.alertErrorLabel.hidden = !showError;
    self.alertErrorLabel.text = showError ? (coordinator.listenerError.localizedDescription ?:
                                            TSLocalizedString(@"general.unknown_error")) : nil;

    TSHRAlertModel *alert = coordinator.latestAlert;
    NSString *latestText = TSLocalizedString(@"hr.alert.debug.empty");
    if (alert) {
        latestText = [NSString stringWithFormat:TSLocalizedString(@"hr.alert.debug.latest_format"),
                      [self formattedReceiveTimeForAlert:alert], [self modeTextForAlert:alert],
                      [self typeTextForAlert:alert], (unsigned int)alert.hrValue, [self thresholdTextForAlert:alert]];
    }
    [self.latestAlertButton setTitle:latestText forState:UIControlStateNormal];
    self.latestAlertButton.enabled = alert != nil;
    self.latestAlertButton.accessibilityHint = alert ? TSLocalizedString(@"hr.alert.debug.detail_hint") : nil;
    [self.view setNeedsLayout];
}

// 按本地时区显示 SDK 接收时间，保留日期以免跨天混淆
- (NSString *)formattedReceiveTimeForAlert:(TSHRAlertModel *)alert {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:alert.receiveTime]];
}

// 从单一告警类型读取心率模式，未知或组合值不推断场景
- (NSString *)modeTextForAlert:(TSHRAlertModel *)alert {
    switch (alert.type) {
        case TSHRAlertTypeDynamicHigh:
        case TSHRAlertTypeDynamicLow:
            return TSLocalizedString(@"hr.alert.detail.dynamic");
        case TSHRAlertTypeStaticHigh:
        case TSHRAlertTypeStaticLow:
            return TSLocalizedString(@"hr.alert.detail.static");
        case TSHRAlertTypeUnknown:
        default:
            return TSLocalizedString(@"general.unknown");
    }
}

// 告警类型由设备决定，不用配置阈值重新判定
- (NSString *)typeTextForAlert:(TSHRAlertModel *)alert {
    switch (alert.type) {
        case TSHRAlertTypeDynamicHigh:
        case TSHRAlertTypeStaticHigh:
            return TSLocalizedString(@"hr.alert.detail.high");
        case TSHRAlertTypeDynamicLow:
        case TSHRAlertTypeStaticLow:
            return TSLocalizedString(@"hr.alert.detail.low");
        case TSHRAlertTypeUnknown:
        default:
            return TSLocalizedString(@"general.unknown");
    }
}

// 未知配置阈值以文字呈现，不使用零作为占位值
- (NSString *)thresholdTextForAlert:(TSHRAlertModel *)alert {
    if (!alert.threshold) {
        return TSLocalizedString(@"hr.alert.detail.threshold_unknown");
    }
    return [NSString stringWithFormat:TSLocalizedString(@"hr.alert.detail.threshold_format"), alert.threshold];
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

        self.maxHRValueLabel.text = maxBPM > 0 ? [NSString stringWithFormat:@"%ld", (long)maxBPM] : TSLocalizedString(@"chart.placeholder");
        self.minHRValueLabel.text = minBPM > 0 ? [NSString stringWithFormat:@"%ld", (long)minBPM] : TSLocalizedString(@"chart.placeholder");
        self.restingHRValueLabel.text = restingBPM > 0 ? [NSString stringWithFormat:@"%ld", (long)restingBPM] : TSLocalizedString(@"chart.placeholder");
    } else {
        self.maxHRValueLabel.text = TSLocalizedString(@"chart.placeholder");
        self.minHRValueLabel.text = TSLocalizedString(@"chart.placeholder");
        self.restingHRValueLabel.text = TSLocalizedString(@"chart.placeholder");
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
    formatter.dateFormat = TSLocalizedString(@"hr.date_format");
    NSString *dateStr = [formatter stringFromDate:self.currentDate];

    if ([self isToday:self.currentDate]) {
        self.dateLabel.text = [NSString stringWithFormat:TSLocalizedString(@"hr.date_with_today_format"), dateStr, TSLocalizedString(@"hr.today")];
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
    self.syncButton.title = TSLocalizedString(@"sync.syncing");
}

/**
 * 停止同步动画
 */
- (void)stopSyncAnimation {
    self.syncButton.enabled = YES;
    self.syncButton.title = TSLocalizedString(@"sync.button");
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

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.alwaysBounceVertical = YES;
        _contentScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _contentScrollView;
}

- (UIView *)alertDebugCard {
    if (!_alertDebugCard) {
        _alertDebugCard = [[UIView alloc] init];
        _alertDebugCard.backgroundColor = TSColor_Card;
        _alertDebugCard.layer.cornerRadius = TSRadius_MD;
    }
    return _alertDebugCard;
}

- (UILabel *)alertDebugTitleLabel {
    if (!_alertDebugTitleLabel) {
        _alertDebugTitleLabel = [[UILabel alloc] init];
        _alertDebugTitleLabel.text = TSLocalizedString(@"hr.alert.debug.title");
        _alertDebugTitleLabel.font = TSFont_H2;
        _alertDebugTitleLabel.textColor = TSColor_TextPrimary;
        _alertDebugTitleLabel.numberOfLines = 0;
    }
    return _alertDebugTitleLabel;
}

- (UILabel *)alertStatusLabel {
    if (!_alertStatusLabel) {
        _alertStatusLabel = [[UILabel alloc] init];
        _alertStatusLabel.font = TSFont_Body;
        _alertStatusLabel.textColor = TSColor_TextSecondary;
        _alertStatusLabel.numberOfLines = 0;
    }
    return _alertStatusLabel;
}

- (UILabel *)alertErrorLabel {
    if (!_alertErrorLabel) {
        _alertErrorLabel = [[UILabel alloc] init];
        _alertErrorLabel.font = TSFont_Caption;
        _alertErrorLabel.textColor = TSColor_TextSecondary;
        _alertErrorLabel.numberOfLines = 0;
        _alertErrorLabel.hidden = YES;
    }
    return _alertErrorLabel;
}

- (UIButton *)latestAlertButton {
    if (!_latestAlertButton) {
        _latestAlertButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _latestAlertButton.titleLabel.font = TSFont_Body;
        _latestAlertButton.titleLabel.numberOfLines = 0;
        _latestAlertButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _latestAlertButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _latestAlertButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_latestAlertButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        [_latestAlertButton setTitleColor:TSColor_TextSecondary forState:UIControlStateDisabled];
        [_latestAlertButton addTarget:self action:@selector(onLatestAlertTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _latestAlertButton;
}

- (UILabel *)alertDebugHintLabel {
    if (!_alertDebugHintLabel) {
        _alertDebugHintLabel = [[UILabel alloc] init];
        _alertDebugHintLabel.text = TSLocalizedString(@"hr.alert.debug.hint");
        _alertDebugHintLabel.font = TSFont_Caption;
        _alertDebugHintLabel.textColor = TSColor_TextSecondary;
        _alertDebugHintLabel.numberOfLines = 0;
    }
    return _alertDebugHintLabel;
}

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
        [_todayButton setTitle:TSLocalizedString(@"hr.today") forState:UIControlStateNormal];
        _todayButton.titleLabel.font = TSFont_Caption;
        [_todayButton addTarget:self action:@selector(onTodayTapped) forControlEvents:UIControlEventTouchUpInside];
        _todayButton.hidden = YES;
    }
    return _todayButton;
}

- (UISegmentedControl *)chartTypeSegment {
    if (!_chartTypeSegment) {
        _chartTypeSegment = [[UISegmentedControl alloc] initWithItems:@[TSLocalizedString(@"stress.bar_chart"), TSLocalizedString(@"stress.line_chart")]];

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
        _maxHRLabel.text = TSLocalizedString(@"hr.max");
        _maxHRLabel.font = TSFont_Caption;
        _maxHRLabel.textColor = TSColor_TextSecondary;
        _maxHRLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _maxHRLabel;
}

- (UILabel *)maxHRValueLabel {
    if (!_maxHRValueLabel) {
        _maxHRValueLabel = [[UILabel alloc] init];
        _maxHRValueLabel.text = TSLocalizedString(@"chart.placeholder");
        _maxHRValueLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _maxHRValueLabel.textColor = TSColor_Danger;
        _maxHRValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _maxHRValueLabel;
}

- (UILabel *)restingHRLabel {
    if (!_restingHRLabel) {
        _restingHRLabel = [[UILabel alloc] init];
        _restingHRLabel.text = TSLocalizedString(@"hr.resting");
        _restingHRLabel.font = TSFont_Caption;
        _restingHRLabel.textColor = TSColor_TextSecondary;
        _restingHRLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _restingHRLabel;
}

- (UILabel *)restingHRValueLabel {
    if (!_restingHRValueLabel) {
        _restingHRValueLabel = [[UILabel alloc] init];
        _restingHRValueLabel.text = TSLocalizedString(@"chart.placeholder");
        _restingHRValueLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _restingHRValueLabel.textColor = TSColor_Success;
        _restingHRValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _restingHRValueLabel;
}

- (UILabel *)minHRLabel {
    if (!_minHRLabel) {
        _minHRLabel = [[UILabel alloc] init];
        _minHRLabel.text = TSLocalizedString(@"hr.min");
        _minHRLabel.font = TSFont_Caption;
        _minHRLabel.textColor = TSColor_TextSecondary;
        _minHRLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _minHRLabel;
}

- (UILabel *)minHRValueLabel {
    if (!_minHRValueLabel) {
        _minHRValueLabel = [[UILabel alloc] init];
        _minHRValueLabel.text = TSLocalizedString(@"chart.placeholder");
        _minHRValueLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _minHRValueLabel.textColor = TSColor_Primary;
        _minHRValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _minHRValueLabel;
}

@end
