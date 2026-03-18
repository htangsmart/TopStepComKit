//
//  TSDailyWeatherEditVC.m
//  TopStepComKit_Example
//
//  Created by AI on 2026/03/05.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSDailyWeatherEditVC.h"
#import <TopStepComKit/TopStepComKit.h>

// ─── Design System ─────────────────────────────────────────────────────────
#define TSColor_Background      [UIColor colorWithRed:242/255.f green:242/255.f blue:247/255.f alpha:1.f]
#define TSColor_Card            [UIColor whiteColor]
#define TSColor_Primary         [UIColor colorWithRed:74/255.f green:144/255.f blue:226/255.f alpha:1.f]
#define TSColor_TextPrimary     [UIColor colorWithRed:28/255.f  green:28/255.f  blue:30/255.f  alpha:1.f]
#define TSColor_TextSecondary   [UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f]
#define TSColor_Success         [UIColor colorWithRed:52/255.f  green:199/255.f blue:89/255.f  alpha:1.f]

#define TSSpacing_MD    16.f
#define TSRadius_MD     12.f
#define TSFont_H2       [UIFont systemFontOfSize:17.f weight:UIFontWeightSemibold]
#define TSFont_Body     [UIFont systemFontOfSize:15.f weight:UIFontWeightRegular]

static const CGFloat kRowHeight = 60.f;

// ─── Weather Code Options ──────────────────────────────────────────────────
static NSArray<NSDictionary *> *TSWeatherCodeOptions(void) {
    return @[
        // 极端天气
        @{@"name": @"🌪️ 龙卷风",       @"icon": @"🌪️"},
        @{@"name": @"🌀 热带风暴",       @"icon": @"🌀"},
        @{@"name": @"🌀 飓风",           @"icon": @"🌀"},
        @{@"name": @"⛈️ 强风暴",         @"icon": @"⛈️"},
        @{@"name": @"⛈️ 雷雨",           @"icon": @"⛈️"},
        // 混合降水
        @{@"name": @"🌨️ 雨雪",           @"icon": @"🌨️"},
        @{@"name": @"🌧️ 雨冰雹",         @"icon": @"🌧️"},
        @{@"name": @"🌨️ 雨夹雪",         @"icon": @"🌨️"},
        // 小雨
        @{@"name": @"🌧️ 冻毛毛雨",       @"icon": @"🌧️"},
        @{@"name": @"🌦️ 毛毛雨",         @"icon": @"🌦️"},
        @{@"name": @"🌧️ 冻雨",           @"icon": @"🌧️"},
        @{@"name": @"🌦️ 阵雨",           @"icon": @"🌦️"},
        @{@"name": @"🌧️ 雨天",           @"icon": @"🌧️"},
        // 雪
        @{@"name": @"🌨️ 小雪",           @"icon": @"🌨️"},
        @{@"name": @"🌨️ 阵雪",           @"icon": @"🌨️"},
        @{@"name": @"🌬️ 风吹雪",         @"icon": @"🌬️"},
        @{@"name": @"❄️ 雪",             @"icon": @"❄️"},
        // 其他降水
        @{@"name": @"🌨️ 冰雹",           @"icon": @"🌨️"},
        @{@"name": @"🌨️ 霰",             @"icon": @"🌨️"},
        // 能见度天气
        @{@"name": @"🌫️ 沙暴",           @"icon": @"🌫️"},
        @{@"name": @"🌫️ 有雾",           @"icon": @"🌫️"},
        @{@"name": @"🌫️ 霾",             @"icon": @"🌫️"},
        @{@"name": @"🌫️ 烟雾",           @"icon": @"🌫️"},
        // 风
        @{@"name": @"🍃 微风",           @"icon": @"🍃"},
        @{@"name": @"💨 大风",           @"icon": @"💨"},
        // 寒冷
        @{@"name": @"🥶 冰珠",           @"icon": @"🥶"},
        // 多云
        @{@"name": @"☁️ 阴天",           @"icon": @"☁️"},
        @{@"name": @"🌥️ 夜间大部多云",   @"icon": @"🌥️"},
        @{@"name": @"🌥️ 白天大部多云",   @"icon": @"🌥️"},
        @{@"name": @"⛅ 夜间局部多云",   @"icon": @"⛅"},
        @{@"name": @"⛅ 白天局部多云",   @"icon": @"⛅"},
        // 晴
        @{@"name": @"🌙 夜间晴天",       @"icon": @"🌙"},
        @{@"name": @"☀️ 晴天",           @"icon": @"☀️"},
        @{@"name": @"🌙 夜间晴时多云",   @"icon": @"🌙"},
        @{@"name": @"🌤️ 白天晴时多云",   @"icon": @"🌤️"},
        // 混合天气
        @{@"name": @"🌧️ 雨加冰雹",       @"icon": @"🌧️"},
        @{@"name": @"🌡️ 热",             @"icon": @"🌡️"},
        // 局部天气
        @{@"name": @"⛈️ 局部雷暴",       @"icon": @"⛈️"},
        @{@"name": @"⛈️ 白天局部雷阵雨", @"icon": @"⛈️"},
        @{@"name": @"🌦️ 白天零星阵雨",   @"icon": @"🌦️"},
        // 强降水
        @{@"name": @"🌧️ 暴雨",           @"icon": @"🌧️"},
        @{@"name": @"🌨️ 白天零星阵雪",   @"icon": @"🌨️"},
        @{@"name": @"❄️ 大雪",           @"icon": @"❄️"},
        @{@"name": @"❄️ 暴风雪",         @"icon": @"❄️"},
        // 其他
        @{@"name": @"❓ 无法使用",       @"icon": @"❓"},
        @{@"name": @"🌦️ 夜间零星阵雨",   @"icon": @"🌦️"},
        @{@"name": @"🌨️ 夜间零星阵雪",   @"icon": @"🌨️"},
        @{@"name": @"⛈️ 夜间局部雷阵雨", @"icon": @"⛈️"},
    ];
}

@interface TSDailyWeatherEditVC () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;     // 滚动容器
@property (nonatomic, strong) UIView *contentView;          // 内容容器

@property (nonatomic, strong) UIButton *dayWeatherButton;   // 白天天气选择按钮
@property (nonatomic, strong) UIButton *nightWeatherButton; // 夜间天气选择按钮
@property (nonatomic, strong) UISlider *minTempSlider;      // 最低温度滑块
@property (nonatomic, strong) UILabel *minTempLabel;        // 最低温度标签
@property (nonatomic, strong) UISlider *maxTempSlider;      // 最高温度滑块
@property (nonatomic, strong) UILabel *maxTempLabel;        // 最高温度标签
@property (nonatomic, strong) UISlider *windSlider;         // 风力滑块
@property (nonatomic, strong) UILabel *windLabel;           // 风力标签
@property (nonatomic, strong) UIPickerView *timePicker;     // 时间选择器
@property (nonatomic, strong) UILabel *timeLabel;           // 时间显示标签

@property (nonatomic, strong) UIButton *saveButton;         // 保存按钮
@property (nonatomic, strong) UIButton *cancelButton;       // 取消按钮

@end

@implementation TSDailyWeatherEditVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"编辑 %@", _dateString];
    self.view.backgroundColor = TSColor_Background;

    // 添加导航栏按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelTapped)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(onSaveTapped)];

    [self setupViews];
    [self layoutViews];
    [self loadData];
}

#pragma mark - Setup Views

- (void)setupViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];

    // 白天天气行
    [self setupDayWeatherRow];

    // 夜间天气行
    [self setupNightWeatherRow];

    // 最低温度行
    [self setupMinTempRow];

    // 最高温度行
    [self setupMaxTempRow];

    // 风力行
    [self setupWindRow];

    // 时间选择行
    [self setupTimeRow];

    // 添加点击手势收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)setupDayWeatherRow {
    CGFloat yOffset = TSSpacing_MD;
    CGFloat width = self.view.bounds.size.width - TSSpacing_MD * 2;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"白天天气";
    titleLabel.font = TSFont_Body;
    titleLabel.textColor = TSColor_TextSecondary;
    titleLabel.frame = CGRectMake(TSSpacing_MD, yOffset, width, 20);
    [self.contentView addSubview:titleLabel];

    self.dayWeatherButton.frame = CGRectMake(TSSpacing_MD, yOffset + 28, width, 44);
    [self.contentView addSubview:self.dayWeatherButton];
}

- (void)setupNightWeatherRow {
    CGFloat yOffset = TSSpacing_MD + kRowHeight + TSSpacing_MD;
    CGFloat width = self.view.bounds.size.width - TSSpacing_MD * 2;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"夜间天气";
    titleLabel.font = TSFont_Body;
    titleLabel.textColor = TSColor_TextSecondary;
    titleLabel.frame = CGRectMake(TSSpacing_MD, yOffset, width, 20);
    [self.contentView addSubview:titleLabel];

    self.nightWeatherButton.frame = CGRectMake(TSSpacing_MD, yOffset + 28, width, 44);
    [self.contentView addSubview:self.nightWeatherButton];
}

- (void)setupMinTempRow {
    CGFloat yOffset = TSSpacing_MD + (kRowHeight + TSSpacing_MD) * 2;
    CGFloat width = self.view.bounds.size.width - TSSpacing_MD * 2;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"最低温度";
    titleLabel.font = TSFont_Body;
    titleLabel.textColor = TSColor_TextSecondary;
    titleLabel.frame = CGRectMake(TSSpacing_MD, yOffset, 100, 20);
    [self.contentView addSubview:titleLabel];

    self.minTempLabel.frame = CGRectMake(width - 60 + TSSpacing_MD, yOffset, 60, 20);
    [self.contentView addSubview:self.minTempLabel];

    self.minTempSlider.frame = CGRectMake(TSSpacing_MD, yOffset + 28, width, 30);
    [self.contentView addSubview:self.minTempSlider];
}

- (void)setupMaxTempRow {
    CGFloat yOffset = TSSpacing_MD + (kRowHeight + TSSpacing_MD) * 3;
    CGFloat width = self.view.bounds.size.width - TSSpacing_MD * 2;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"最高温度";
    titleLabel.font = TSFont_Body;
    titleLabel.textColor = TSColor_TextSecondary;
    titleLabel.frame = CGRectMake(TSSpacing_MD, yOffset, 100, 20);
    [self.contentView addSubview:titleLabel];

    self.maxTempLabel.frame = CGRectMake(width - 60 + TSSpacing_MD, yOffset, 60, 20);
    [self.contentView addSubview:self.maxTempLabel];

    self.maxTempSlider.frame = CGRectMake(TSSpacing_MD, yOffset + 28, width, 30);
    [self.contentView addSubview:self.maxTempSlider];
}

- (void)setupWindRow {
    CGFloat yOffset = TSSpacing_MD + (kRowHeight + TSSpacing_MD) * 4;
    CGFloat width = self.view.bounds.size.width - TSSpacing_MD * 2;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"风力等级";
    titleLabel.font = TSFont_Body;
    titleLabel.textColor = TSColor_TextSecondary;
    titleLabel.frame = CGRectMake(TSSpacing_MD, yOffset, 100, 20);
    [self.contentView addSubview:titleLabel];

    self.windLabel.frame = CGRectMake(width - 60 + TSSpacing_MD, yOffset, 60, 20);
    [self.contentView addSubview:self.windLabel];

    self.windSlider.frame = CGRectMake(TSSpacing_MD, yOffset + 28, width, 30);
    [self.contentView addSubview:self.windSlider];
}

- (void)setupTimeRow {
    CGFloat yOffset = TSSpacing_MD + (kRowHeight + TSSpacing_MD) * 5;
    CGFloat width = self.view.bounds.size.width - TSSpacing_MD * 2;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"时间";
    titleLabel.font = TSFont_Body;
    titleLabel.textColor = TSColor_TextSecondary;
    titleLabel.frame = CGRectMake(TSSpacing_MD, yOffset, 100, 20);
    [self.contentView addSubview:titleLabel];

    self.timeLabel.frame = CGRectMake(width - 80 + TSSpacing_MD, yOffset, 80, 20);
    [self.contentView addSubview:self.timeLabel];

    self.timePicker.frame = CGRectMake(TSSpacing_MD, yOffset + 28, width, 120);
    [self.contentView addSubview:self.timePicker];
}

#pragma mark - Layout

- (void)layoutViews {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;

    self.scrollView.frame = self.view.bounds;

    CGFloat contentHeight = TSSpacing_MD + (kRowHeight + TSSpacing_MD) * 5 + 150 + TSSpacing_MD;
    self.contentView.frame = CGRectMake(0, 0, width, contentHeight);
    self.scrollView.contentSize = CGSizeMake(width, contentHeight);
}

#pragma mark - Load Data

- (void)loadData {
    // 设置白天天气按钮
    for (NSDictionary *option in TSWeatherCodeOptions()) {
        if ([option[@"icon"] isEqualToString:_dayIcon]) {
            [self.dayWeatherButton setTitle:option[@"name"] forState:UIControlStateNormal];
            break;
        }
    }

    // 设置夜间天气按钮
    for (NSDictionary *option in TSWeatherCodeOptions()) {
        if ([option[@"icon"] isEqualToString:_nightIcon]) {
            [self.nightWeatherButton setTitle:option[@"name"] forState:UIControlStateNormal];
            break;
        }
    }

    // 设置温度
    self.minTempSlider.value = _minTemp;
    self.minTempLabel.text = [NSString stringWithFormat:@"%ld°C", (long)_minTemp];

    self.maxTempSlider.value = _maxTemp;
    self.maxTempLabel.text = [NSString stringWithFormat:@"%ld°C", (long)_maxTemp];

    // 设置风力
    self.windSlider.value = _windScale;
    self.windLabel.text = [NSString stringWithFormat:@"%ld级", (long)_windScale];

    // 设置时间
    [self.timePicker selectRow:_hour inComponent:0 animated:NO];
    [self.timePicker selectRow:_minute inComponent:1 animated:NO];
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)_hour, (long)_minute];
}

#pragma mark - Actions

- (void)onDayWeatherButtonTapped {
    [self showWeatherPickerWithTitle:@"选择白天天气" completion:^(NSString *icon, NSString *name) {
        self.dayIcon = icon;
        [self.dayWeatherButton setTitle:name forState:UIControlStateNormal];
    }];
}

- (void)onNightWeatherButtonTapped {
    [self showWeatherPickerWithTitle:@"选择夜间天气" completion:^(NSString *icon, NSString *name) {
        self.nightIcon = icon;
        [self.nightWeatherButton setTitle:name forState:UIControlStateNormal];
    }];
}

- (void)showWeatherPickerWithTitle:(NSString *)title completion:(void(^)(NSString *icon, NSString *name))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    for (NSDictionary *option in TSWeatherCodeOptions()) {
        [alert addAction:[UIAlertAction actionWithTitle:option[@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (completion) {
                completion(option[@"icon"], option[@"name"]);
            }
        }]];
    }

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onMinTempSliderChanged:(UISlider *)slider {
    NSInteger temp = (NSInteger)slider.value;
    self.minTempLabel.text = [NSString stringWithFormat:@"%ld°C", (long)temp];
}

- (void)onMaxTempSliderChanged:(UISlider *)slider {
    NSInteger temp = (NSInteger)slider.value;
    self.maxTempLabel.text = [NSString stringWithFormat:@"%ld°C", (long)temp];
}

- (void)onWindSliderChanged:(UISlider *)slider {
    NSInteger wind = (NSInteger)slider.value;
    self.windLabel.text = [NSString stringWithFormat:@"%ld级", (long)wind];
}

- (void)onCancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSaveTapped {
    if (self.completion) {
        NSInteger minTemp = (NSInteger)self.minTempSlider.value;
        NSInteger maxTemp = (NSInteger)self.maxTempSlider.value;
        NSInteger wind = (NSInteger)self.windSlider.value;
        NSInteger hour = [self.timePicker selectedRowInComponent:0];
        NSInteger minute = [self.timePicker selectedRowInComponent:1];
        self.completion(self.dayIcon, self.nightIcon, minTemp, maxTemp, wind, hour, minute);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Lazy Loading

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = TSColor_Background;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = TSColor_Background;
    }
    return _contentView;
}

- (UIButton *)dayWeatherButton {
    if (!_dayWeatherButton) {
        _dayWeatherButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_dayWeatherButton setTitle:@"选择白天天气 ▼" forState:UIControlStateNormal];
        [_dayWeatherButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _dayWeatherButton.backgroundColor = TSColor_Card;
        _dayWeatherButton.layer.cornerRadius = TSRadius_MD;
        _dayWeatherButton.titleLabel.font = TSFont_Body;
        _dayWeatherButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_dayWeatherButton addTarget:self action:@selector(onDayWeatherButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dayWeatherButton;
}

- (UIButton *)nightWeatherButton {
    if (!_nightWeatherButton) {
        _nightWeatherButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_nightWeatherButton setTitle:@"选择夜间天气 ▼" forState:UIControlStateNormal];
        [_nightWeatherButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _nightWeatherButton.backgroundColor = TSColor_Card;
        _nightWeatherButton.layer.cornerRadius = TSRadius_MD;
        _nightWeatherButton.titleLabel.font = TSFont_Body;
        _nightWeatherButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_nightWeatherButton addTarget:self action:@selector(onNightWeatherButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nightWeatherButton;
}

- (UISlider *)minTempSlider {
    if (!_minTempSlider) {
        _minTempSlider = [[UISlider alloc] init];
        _minTempSlider.minimumValue = -20;
        _minTempSlider.maximumValue = 50;
        _minTempSlider.value = 18;
        _minTempSlider.tintColor = TSColor_Primary;
        [_minTempSlider addTarget:self action:@selector(onMinTempSliderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _minTempSlider;
}

- (UILabel *)minTempLabel {
    if (!_minTempLabel) {
        _minTempLabel = [[UILabel alloc] init];
        _minTempLabel.text = @"18°C";
        _minTempLabel.font = TSFont_Body;
        _minTempLabel.textColor = TSColor_Primary;
        _minTempLabel.textAlignment = NSTextAlignmentRight;
    }
    return _minTempLabel;
}

- (UISlider *)maxTempSlider {
    if (!_maxTempSlider) {
        _maxTempSlider = [[UISlider alloc] init];
        _maxTempSlider.minimumValue = -20;
        _maxTempSlider.maximumValue = 50;
        _maxTempSlider.value = 28;
        _maxTempSlider.tintColor = TSColor_Primary;
        [_maxTempSlider addTarget:self action:@selector(onMaxTempSliderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _maxTempSlider;
}

- (UILabel *)maxTempLabel {
    if (!_maxTempLabel) {
        _maxTempLabel = [[UILabel alloc] init];
        _maxTempLabel.text = @"28°C";
        _maxTempLabel.font = TSFont_Body;
        _maxTempLabel.textColor = TSColor_Primary;
        _maxTempLabel.textAlignment = NSTextAlignmentRight;
    }
    return _maxTempLabel;
}

- (UISlider *)windSlider {
    if (!_windSlider) {
        _windSlider = [[UISlider alloc] init];
        _windSlider.minimumValue = 0;
        _windSlider.maximumValue = 12;
        _windSlider.value = 3;
        _windSlider.tintColor = TSColor_Primary;
        [_windSlider addTarget:self action:@selector(onWindSliderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _windSlider;
}

- (UILabel *)windLabel {
    if (!_windLabel) {
        _windLabel = [[UILabel alloc] init];
        _windLabel.text = @"3级";
        _windLabel.font = TSFont_Body;
        _windLabel.textColor = TSColor_Primary;
        _windLabel.textAlignment = NSTextAlignmentRight;
    }
    return _windLabel;
}

- (UIPickerView *)timePicker {
    if (!_timePicker) {
        _timePicker = [[UIPickerView alloc] init];
        _timePicker.dataSource = self;
        _timePicker.delegate = self;
    }
    return _timePicker;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.text = @"00:00";
        _timeLabel.font = TSFont_Body;
        _timeLabel.textColor = TSColor_Primary;
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _saveButton.backgroundColor = TSColor_Success;
        _saveButton.layer.cornerRadius = 8;
        _saveButton.titleLabel.font = TSFont_Body;
        [_saveButton addTarget:self action:@selector(onSaveTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:TSColor_TextPrimary forState:UIControlStateNormal];
        _cancelButton.backgroundColor = TSColor_Card;
        _cancelButton.layer.cornerRadius = 8;
        _cancelButton.titleLabel.font = TSFont_Body;
        [_cancelButton addTarget:self action:@selector(onCancelTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2; // 小时 + 分钟
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return component == 0 ? 24 : 60;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return component == 0
        ? [NSString stringWithFormat:@"%02ld时", (long)row]
        : [NSString stringWithFormat:@"%02ld分", (long)row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger hour = [pickerView selectedRowInComponent:0];
    NSInteger minute = [pickerView selectedRowInComponent:1];
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)hour, (long)minute];
}

@end
