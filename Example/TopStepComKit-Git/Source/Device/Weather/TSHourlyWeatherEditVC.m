//
//  TSHourlyWeatherEditVC.m
//  TopStepComKit_Example
//
//  Created by AI on 2026/03/05.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHourlyWeatherEditVC.h"
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
        @{@"name": TSLocalizedString(@"weather.cond.sunny"),    @"icon": @"☀️"},
        @{@"name": TSLocalizedString(@"weather.cond.cloudy"),   @"icon": @"⛅"},
        @{@"name": TSLocalizedString(@"weather.cond.overcast"), @"icon": @"☁️"},
        @{@"name": TSLocalizedString(@"weather.cond.rainy2"),   @"icon": @"🌧️"},
        @{@"name": TSLocalizedString(@"weather.cond.showers"),  @"icon": @"🌦️"},
        @{@"name": TSLocalizedString(@"weather.cond.thunderstorm2"), @"icon": @"⛈️"},
        @{@"name": TSLocalizedString(@"weather.cond.snow"),     @"icon": @"❄️"}
    ];
}

@interface TSHourlyWeatherEditVC ()

@property (nonatomic, strong) UIScrollView *scrollView;  // 滚动容器
@property (nonatomic, strong) UIView *contentView;       // 内容容器

@property (nonatomic, strong) UIButton *weatherButton;   // 天气选择按钮
@property (nonatomic, strong) UISlider *tempSlider;      // 温度滑块
@property (nonatomic, strong) UILabel *tempLabel;        // 温度标签
@property (nonatomic, strong) UISlider *windSlider;      // 风力滑块
@property (nonatomic, strong) UILabel *windLabel;        // 风力标签

@property (nonatomic, strong) UIButton *saveButton;      // 保存按钮
@property (nonatomic, strong) UIButton *cancelButton;    // 取消按钮

@end

@implementation TSHourlyWeatherEditVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:TSLocalizedString(@"weather.edit_hourly_title"), _hourTime];
    self.view.backgroundColor = TSColor_Background;

    // 添加导航栏按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.cancel") style:UIBarButtonItemStylePlain target:self action:@selector(onCancelTapped)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.save") style:UIBarButtonItemStyleDone target:self action:@selector(onSaveTapped)];

    [self setupViews];
    [self layoutViews];
    [self loadData];
}

#pragma mark - Setup Views

- (void)setupViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];

    // 天气类型行
    [self setupWeatherRow];

    // 温度行
    [self setupTemperatureRow];

    // 风力行
    [self setupWindRow];

    // 添加点击手势收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)setupWeatherRow {
    CGFloat yOffset = TSSpacing_MD;
    CGFloat width = self.view.bounds.size.width - TSSpacing_MD * 2;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TSLocalizedString(@"weather.weather_type");
    titleLabel.font = TSFont_Body;
    titleLabel.textColor = TSColor_TextSecondary;
    titleLabel.frame = CGRectMake(TSSpacing_MD, yOffset, width, 20);
    [self.contentView addSubview:titleLabel];

    self.weatherButton.frame = CGRectMake(TSSpacing_MD, yOffset + 28, width, 44);
    [self.contentView addSubview:self.weatherButton];
}

- (void)setupTemperatureRow {
    CGFloat yOffset = TSSpacing_MD + kRowHeight + TSSpacing_MD;
    CGFloat width = self.view.bounds.size.width - TSSpacing_MD * 2;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TSLocalizedString(@"weather.temperature");
    titleLabel.font = TSFont_Body;
    titleLabel.textColor = TSColor_TextSecondary;
    titleLabel.frame = CGRectMake(TSSpacing_MD, yOffset, 100, 20);
    [self.contentView addSubview:titleLabel];

    self.tempLabel.frame = CGRectMake(width - 60 + TSSpacing_MD, yOffset, 60, 20);
    [self.contentView addSubview:self.tempLabel];

    self.tempSlider.frame = CGRectMake(TSSpacing_MD, yOffset + 28, width, 30);
    [self.contentView addSubview:self.tempSlider];
}

- (void)setupWindRow {
    CGFloat yOffset = TSSpacing_MD + (kRowHeight + TSSpacing_MD) * 2;
    CGFloat width = self.view.bounds.size.width - TSSpacing_MD * 2;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TSLocalizedString(@"weather.wind_level");
    titleLabel.font = TSFont_Body;
    titleLabel.textColor = TSColor_TextSecondary;
    titleLabel.frame = CGRectMake(TSSpacing_MD, yOffset, 100, 20);
    [self.contentView addSubview:titleLabel];

    self.windLabel.frame = CGRectMake(width - 60 + TSSpacing_MD, yOffset, 60, 20);
    [self.contentView addSubview:self.windLabel];

    self.windSlider.frame = CGRectMake(TSSpacing_MD, yOffset + 28, width, 30);
    [self.contentView addSubview:self.windSlider];
}

#pragma mark - Layout

- (void)layoutViews {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;

    self.scrollView.frame = self.view.bounds;

    CGFloat contentHeight = TSSpacing_MD + (kRowHeight + TSSpacing_MD) * 3;
    self.contentView.frame = CGRectMake(0, 0, width, contentHeight);
    self.scrollView.contentSize = CGSizeMake(width, contentHeight);
}

#pragma mark - Load Data

- (void)loadData {
    // 设置天气按钮标题
    for (NSDictionary *option in TSWeatherCodeOptions()) {
        if ([option[@"icon"] isEqualToString:_weatherIcon]) {
            [self.weatherButton setTitle:option[@"name"] forState:UIControlStateNormal];
            break;
        }
    }

    // 设置温度
    self.tempSlider.value = _temperature;
    self.tempLabel.text = [NSString stringWithFormat:@"%ld°C", (long)_temperature];

    // 设置风力
    self.windSlider.value = _windScale;
    self.windLabel.text = [NSString stringWithFormat:TSLocalizedString(@"weather.level_format"), (long)_windScale];
}

#pragma mark - Actions

- (void)onWeatherButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"weather.select_weather_type") message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    for (NSDictionary *option in TSWeatherCodeOptions()) {
        [alert addAction:[UIAlertAction actionWithTitle:option[@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.weatherIcon = option[@"icon"];
            [self.weatherButton setTitle:option[@"name"] forState:UIControlStateNormal];
        }]];
    }

    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onTempSliderChanged:(UISlider *)slider {
    NSInteger temp = (NSInteger)slider.value;
    self.tempLabel.text = [NSString stringWithFormat:@"%ld°C", (long)temp];
}

- (void)onWindSliderChanged:(UISlider *)slider {
    NSInteger wind = (NSInteger)slider.value;
    self.windLabel.text = [NSString stringWithFormat:TSLocalizedString(@"weather.level_format"), (long)wind];
}

- (void)onCancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSaveTapped {
    if (self.completion) {
        NSInteger temp = (NSInteger)self.tempSlider.value;
        NSInteger wind = (NSInteger)self.windSlider.value;
        self.completion(self.weatherIcon, temp, wind);
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

- (UIButton *)weatherButton {
    if (!_weatherButton) {
        _weatherButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_weatherButton setTitle:TSLocalizedString(@"weather.select_weather") forState:UIControlStateNormal];
        [_weatherButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _weatherButton.backgroundColor = TSColor_Card;
        _weatherButton.layer.cornerRadius = TSRadius_MD;
        _weatherButton.titleLabel.font = TSFont_Body;
        _weatherButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_weatherButton addTarget:self action:@selector(onWeatherButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _weatherButton;
}

- (UISlider *)tempSlider {
    if (!_tempSlider) {
        _tempSlider = [[UISlider alloc] init];
        _tempSlider.minimumValue = -20;
        _tempSlider.maximumValue = 50;
        _tempSlider.value = 25;
        _tempSlider.tintColor = TSColor_Primary;
        [_tempSlider addTarget:self action:@selector(onTempSliderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _tempSlider;
}

- (UILabel *)tempLabel {
    if (!_tempLabel) {
        _tempLabel = [[UILabel alloc] init];
        _tempLabel.text = @"25°C";
        _tempLabel.font = TSFont_Body;
        _tempLabel.textColor = TSColor_Primary;
        _tempLabel.textAlignment = NSTextAlignmentRight;
    }
    return _tempLabel;
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
        _windLabel.text = [NSString stringWithFormat:TSLocalizedString(@"weather.level_format"), 3];
        _windLabel.font = TSFont_Body;
        _windLabel.textColor = TSColor_Primary;
        _windLabel.textAlignment = NSTextAlignmentRight;
    }
    return _windLabel;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_saveButton setTitle:TSLocalizedString(@"general.save") forState:UIControlStateNormal];
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
        [_cancelButton setTitle:TSLocalizedString(@"general.cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:TSColor_TextPrimary forState:UIControlStateNormal];
        _cancelButton.backgroundColor = TSColor_Card;
        _cancelButton.layer.cornerRadius = 8;
        _cancelButton.titleLabel.font = TSFont_Body;
        [_cancelButton addTarget:self action:@selector(onCancelTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

@end
