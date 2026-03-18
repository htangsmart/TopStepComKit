//
//  TSWeatherVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/18.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSWeatherVC.h"
#import <TopStepComKit/TopStepComKit.h>
#import <TopStepToolKit/TopStepToolKit.h>
#import "TSHourlyWeatherEditVC.h"
#import "TSDailyWeatherEditVC.h"

// ─── Design System ─────────────────────────────────────────────────────────
#define TSColor_Background      [UIColor colorWithRed:242/255.f green:242/255.f blue:247/255.f alpha:1.f]
#define TSColor_Card            [UIColor whiteColor]
#define TSColor_Primary         [UIColor colorWithRed:74/255.f green:144/255.f blue:226/255.f alpha:1.f]
#define TSColor_TextPrimary     [UIColor colorWithRed:28/255.f  green:28/255.f  blue:30/255.f  alpha:1.f]
#define TSColor_TextSecondary   [UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f]
#define TSColor_Success         [UIColor colorWithRed:52/255.f  green:199/255.f blue:89/255.f  alpha:1.f]
#define TSColor_Danger          [UIColor colorWithRed:255/255.f green:59/255.f  blue:48/255.f  alpha:1.f]
#define TSColor_Warning         [UIColor colorWithRed:255/255.f green:149/255.f blue:0/255.f   alpha:1.f]

#define TSSpacing_SM    8.f
#define TSSpacing_MD    16.f
#define TSSpacing_LG    24.f

#define TSRadius_MD     12.f

#define TSFont_H2       [UIFont systemFontOfSize:17.f weight:UIFontWeightSemibold]
#define TSFont_Body     [UIFont systemFontOfSize:15.f weight:UIFontWeightRegular]
#define TSFont_Caption  [UIFont systemFontOfSize:13.f weight:UIFontWeightRegular]

// ─── Constants ─────────────────────────────────────────────────────────────
static const CGFloat kCardPadding = 16.f;
static const CGFloat kRowHeight = 50.f;

// ─── Weather Code Mapping ──────────────────────────────────────────────────
static NSArray<NSDictionary *> *TSWeatherCodeOptions(void) {
    return @[
        @{@"name": TSLocalizedString(@"weather.cond.tornado"),              @"code": @(TSWeatherCodeTornado)},
        @{@"name": TSLocalizedString(@"weather.cond.tropical_storm"),       @"code": @(TSWeatherCodeTropicalStorm)},
        @{@"name": TSLocalizedString(@"weather.cond.hurricane"),            @"code": @(TSWeatherCodeHurricane)},
        @{@"name": TSLocalizedString(@"weather.cond.severe_storm"),         @"code": @(TSWeatherCodeStrongStorms)},
        @{@"name": TSLocalizedString(@"weather.cond.thunderstorm"),         @"code": @(TSWeatherCodeThunderstorms)},
        @{@"name": TSLocalizedString(@"weather.cond.rain_snow"),            @"code": @(TSWeatherCodeRainSnow)},
        @{@"name": TSLocalizedString(@"weather.cond.rain_hail"),            @"code": @(TSWeatherCodeRainSleet)},
        @{@"name": TSLocalizedString(@"weather.cond.sleet"),                @"code": @(TSWeatherCodeWintryMix)},
        @{@"name": TSLocalizedString(@"weather.cond.freezing_drizzle"),     @"code": @(TSWeatherCodeFreezingDrizzle)},
        @{@"name": TSLocalizedString(@"weather.cond.drizzle"),              @"code": @(TSWeatherCodeDrizzle)},
        @{@"name": TSLocalizedString(@"weather.cond.freezing_rain"),        @"code": @(TSWeatherCodeFreezingRain)},
        @{@"name": TSLocalizedString(@"weather.cond.showers"),              @"code": @(TSWeatherCodeShowers)},
        @{@"name": TSLocalizedString(@"weather.cond.rainy"),                @"code": @(TSWeatherCodeRain)},
        @{@"name": TSLocalizedString(@"weather.cond.light_snow"),           @"code": @(TSWeatherCodeFlurries)},
        @{@"name": TSLocalizedString(@"weather.cond.snow_showers"),         @"code": @(TSWeatherCodeSnowShowers)},
        @{@"name": TSLocalizedString(@"weather.cond.blowing_snow"),         @"code": @(TSWeatherCodeBlowingSnow)},
        @{@"name": TSLocalizedString(@"weather.cond.snow"),                 @"code": @(TSWeatherCodeSnow)},
        @{@"name": TSLocalizedString(@"weather.cond.hail"),                 @"code": @(TSWeatherCodeHail)},
        @{@"name": TSLocalizedString(@"weather.cond.sleet_pellets"),          @"code": @(TSWeatherCodeSleet)},
        @{@"name": TSLocalizedString(@"weather.cond.dust_storm"),           @"code": @(TSWeatherCodeDustSandstorm)},
        @{@"name": TSLocalizedString(@"weather.cond.foggy"),                @"code": @(TSWeatherCodeFoggy)},
        @{@"name": TSLocalizedString(@"weather.cond.haze"),                 @"code": @(TSWeatherCodeHaze)},
        @{@"name": TSLocalizedString(@"weather.cond.smoke"),                @"code": @(TSWeatherCodeSmoke)},
        @{@"name": TSLocalizedString(@"weather.cond.light_breeze"),         @"code": @(TSWeatherCodeBreezy)},
        @{@"name": TSLocalizedString(@"weather.cond.strong_wind"),          @"code": @(TSWeatherCodeWindy)},
        @{@"name": TSLocalizedString(@"weather.cond.ice_pellets"),          @"code": @(TSWeatherCodeFrigidIceCrystals)},
        @{@"name": TSLocalizedString(@"weather.cond.overcast"),             @"code": @(TSWeatherCodeOvercast)},
        @{@"name": TSLocalizedString(@"weather.cond.mostly_cloudy_n"),      @"code": @(TSWeatherCodeMostlyCloudyNight)},
        @{@"name": TSLocalizedString(@"weather.cond.mostly_cloudy_d"),      @"code": @(TSWeatherCodeMostlyCloudyDay)},
        @{@"name": TSLocalizedString(@"weather.cond.partly_cloudy_n"),      @"code": @(TSWeatherCodePartlyCloudyNight)},
        @{@"name": TSLocalizedString(@"weather.cond.partly_cloudy_d"),      @"code": @(TSWeatherCodePartlyCloudyDay)},
        @{@"name": TSLocalizedString(@"weather.cond.clear_night"),          @"code": @(TSWeatherCodeClearNight)},
        @{@"name": TSLocalizedString(@"weather.cond.sunny"),                @"code": @(TSWeatherCodeSunnyDay)},
        @{@"name": TSLocalizedString(@"weather.cond.partly_sunny_n"),       @"code": @(TSWeatherCodeFairNight)},
        @{@"name": TSLocalizedString(@"weather.cond.partly_sunny_d"),       @"code": @(TSWeatherCodeFairDay)},
        @{@"name": TSLocalizedString(@"weather.cond.rain_hail2"),           @"code": @(TSWeatherCodeMixedRainHail)},
        @{@"name": TSLocalizedString(@"weather.cond.hot"),                  @"code": @(TSWeatherCodeHot)},
        @{@"name": TSLocalizedString(@"weather.cond.scattered_storms"),     @"code": @(TSWeatherCodeIsolatedThunderstorms)},
        @{@"name": TSLocalizedString(@"weather.cond.storms_day"),           @"code": @(TSWeatherCodeScatteredStormDay)},
        @{@"name": TSLocalizedString(@"weather.cond.scattered_showers_day"),  @"code": @(TSWeatherCodeScatteredShowersDay)},
        @{@"name": TSLocalizedString(@"weather.cond.heavy_rain"),             @"code": @(TSWeatherCodeHeavyRain)},
        @{@"name": TSLocalizedString(@"weather.cond.scattered_snow_day"),     @"code": @(TSWeatherCodeScatteredSnowDay)},
        @{@"name": TSLocalizedString(@"weather.cond.heavy_snow"),             @"code": @(TSWeatherCodeHeavySnow)},
        @{@"name": TSLocalizedString(@"weather.cond.blizzard"),               @"code": @(TSWeatherCodeBlizzard)},
        @{@"name": TSLocalizedString(@"weather.cond.not_available"),          @"code": @(TSWeatherCodeNotAvailable)},
        @{@"name": TSLocalizedString(@"weather.cond.scattered_showers_night"),@"code": @(TSWeatherCodeScatteredShowersNight)},
        @{@"name": TSLocalizedString(@"weather.cond.scattered_snow_night"),   @"code": @(TSWeatherCodeScatteredSnowNight)},
        @{@"name": TSLocalizedString(@"weather.cond.scattered_storm_night"),  @"code": @(TSWeatherCodeScatteredStormNight)},
    ];
}

// ─── Private Interface ─────────────────────────────────────────────────────
@interface TSWeatherVC () <UITextFieldDelegate>

// 滚动容器
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

// 顶部操作区
@property (nonatomic, strong) UIView *headerCard;
@property (nonatomic, strong) UISwitch *weatherSwitch;
@property (nonatomic, strong) UILabel *updateTimeLabel;
@property (nonatomic, strong) UIButton *randomButton;
@property (nonatomic, strong) UIButton *pushButton;

// 城市信息卡片
@property (nonatomic, strong) UIView *cityCard;
@property (nonatomic, strong) UIButton *cityNameButton;
@property (nonatomic, strong) UIButton *provinceButton;

// 当前天气卡片
@property (nonatomic, strong) UIView *currentWeatherCard;
@property (nonatomic, strong) UIButton *weatherCodeButton;
@property (nonatomic, strong) UISlider *temperatureSlider;
@property (nonatomic, strong) UILabel *temperatureLabel;
@property (nonatomic, strong) UISlider *minTempSlider;
@property (nonatomic, strong) UILabel *minTempLabel;
@property (nonatomic, strong) UISlider *maxTempSlider;
@property (nonatomic, strong) UILabel *maxTempLabel;
@property (nonatomic, strong) UISlider *windScaleSlider;
@property (nonatomic, strong) UILabel *windScaleLabel;
@property (nonatomic, strong) UISlider *windAngleSlider;
@property (nonatomic, strong) UILabel *windAngleLabel;
@property (nonatomic, strong) UISlider *windSpeedSlider;      // 风速滑块
@property (nonatomic, strong) UILabel *windSpeedLabel;        // 风速标签
@property (nonatomic, strong) UISlider *humiditySlider;
@property (nonatomic, strong) UILabel *humidityLabel;
@property (nonatomic, strong) UITextField *airPressureField;
@property (nonatomic, strong) UISlider *uvIndexSlider;
@property (nonatomic, strong) UILabel *uvIndexLabel;
@property (nonatomic, strong) UISlider *visibilitySlider;     // 能见度滑块
@property (nonatomic, strong) UILabel *visibilityLabel;       // 能见度标签

// 24小时预报卡片
@property (nonatomic, strong) UIView *hourlyCard;
@property (nonatomic, strong) UIScrollView *hourlyScrollView;
@property (nonatomic, strong) NSMutableArray<UIView *> *hourlyViews;

// 7天预报卡片
@property (nonatomic, strong) UIView *dailyCard;
@property (nonatomic, strong) NSMutableArray<UIView *> *dailyViews;

// 底部按钮
@property (nonatomic, strong) UIButton *bottomRandomButton;
@property (nonatomic, strong) UIButton *bottomPushButton;

// 加载指示器
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UIView *loadingOverlay;

// 数据模型
@property (nonatomic, strong) TopStepWeather *weatherModel;
@property (nonatomic, assign) TSWeatherCode selectedWeatherCode;
@property (nonatomic, strong) NSString *selectedCity;
@property (nonatomic, strong) NSString *selectedProvince;

@end

// ─── Implementation ────────────────────────────────────────────────────────
@implementation TSWeatherVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"weather.title");
    self.view.backgroundColor = TSColor_Background;

    [self initData];
    [self setupViews];
    [self layoutViews];
    [self fetchWeatherEnable];
}

#pragma mark - Init Data

- (void)initData {
    _weatherModel = [[TopStepWeather alloc] init];
    _selectedWeatherCode = TSWeatherCodeSunnyDay;
    _hourlyViews = [NSMutableArray array];
    _dailyViews = [NSMutableArray array];

    // 设置默认值
    TSWeatherCity *city = [TSWeatherCity cityWithName:@"深圳"];
    city.latitude = 22.5431;
    city.longitude = 114.0579;
    city.provinceName = @"广东省";
    city.countryName = @"中国";
    _weatherModel.city = city;
    _weatherModel.updateTimestamp = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Setup Views

- (void)setupViews {
    // 滚动容器
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = TSColor_Background;
    _scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:_scrollView];

    _contentView = [[UIView alloc] init];
    [_scrollView addSubview:_contentView];

    // 顶部操作区
    [self setupHeaderCard];

    // 城市信息卡片
    [self setupCityCard];

    // 当前天气卡片
    [self setupCurrentWeatherCard];

    // 7天预报卡片
    [self setupDailyCard];

    // 24小时预报卡片
    [self setupHourlyCard];

    // 底部按钮
    [self setupBottomButtons];

    // 加载指示器
    [self setupLoadingIndicator];
}

#pragma mark - Setup Header Card

- (void)setupHeaderCard {
    _headerCard = [self createCardView];
    [_contentView addSubview:_headerCard];

    UILabel *switchLabel = [[UILabel alloc] init];
    switchLabel.text = TSLocalizedString(@"weather.toggle");
    switchLabel.font = TSFont_Body;
    switchLabel.textColor = TSColor_TextPrimary;
    [_headerCard addSubview:switchLabel];

    _weatherSwitch = [[UISwitch alloc] init];
    _weatherSwitch.onTintColor = TSColor_Success;
    [_weatherSwitch addTarget:self action:@selector(onWeatherSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [_headerCard addSubview:_weatherSwitch];

    _updateTimeLabel = [[UILabel alloc] init];
    _updateTimeLabel.text = TSLocalizedString(@"weather.last_update");
    _updateTimeLabel.font = TSFont_Caption;
    _updateTimeLabel.textColor = TSColor_TextSecondary;
    [_headerCard addSubview:_updateTimeLabel];

    _randomButton = [self createButtonWithTitle:TSLocalizedString(@"weather.random_btn") color:TSColor_Warning];
    [_randomButton addTarget:self action:@selector(onRandomTapped) forControlEvents:UIControlEventTouchUpInside];
    [_headerCard addSubview:_randomButton];

    _pushButton = [self createButtonWithTitle:TSLocalizedString(@"weather.push_btn") color:TSColor_Success];
    [_pushButton addTarget:self action:@selector(onPushTapped) forControlEvents:UIControlEventTouchUpInside];
    [_headerCard addSubview:_pushButton];

    CGFloat cardWidth = self.view.bounds.size.width - kCardPadding * 2;

    switchLabel.frame = CGRectMake(kCardPadding, 16, 100, 30);
    _weatherSwitch.frame = CGRectMake(kCardPadding + 100, 16, 51, 31);
    _updateTimeLabel.frame = CGRectMake(kCardPadding, 54, cardWidth - kCardPadding * 2, 20);

    CGFloat btnWidth = (cardWidth - kCardPadding * 3) / 2;
    _randomButton.frame = CGRectMake(kCardPadding, 82, btnWidth, 44);
    _pushButton.frame = CGRectMake(kCardPadding * 2 + btnWidth, 82, btnWidth, 44);
}

#pragma mark - Setup City Card

- (void)setupCityCard {
    _cityCard = [self createCardView];
    [_contentView addSubview:_cityCard];

    UILabel *titleLabel = [self createSectionTitleLabel:TSLocalizedString(@"weather.section.city")];
    [_cityCard addSubview:titleLabel];

    CGFloat yOffset = 50;
    CGFloat width = self.view.bounds.size.width - kCardPadding * 2;

    // 省份
    UILabel *provinceLabel = [self createLabel:TSLocalizedString(@"weather.province")];
    provinceLabel.frame = CGRectMake(kCardPadding, yOffset + 15, 80, 20);
    [_cityCard addSubview:provinceLabel];

    _provinceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _provinceButton.frame = CGRectMake(kCardPadding + 90, yOffset + 10, width - 90 - kCardPadding, 30);
    [_provinceButton setTitle:TSLocalizedString(@"weather.province_default") forState:UIControlStateNormal];
    [_provinceButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
    _provinceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_provinceButton addTarget:self action:@selector(onProvinceTapped) forControlEvents:UIControlEventTouchUpInside];
    [_cityCard addSubview:_provinceButton];
    yOffset += kRowHeight;

    // 城市名称
    UILabel *cityLabel = [self createLabel:TSLocalizedString(@"weather.city")];
    cityLabel.frame = CGRectMake(kCardPadding, yOffset + 15, 80, 20);
    [_cityCard addSubview:cityLabel];

    _cityNameButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _cityNameButton.frame = CGRectMake(kCardPadding + 90, yOffset + 10, width - 90 - kCardPadding, 30);
    [_cityNameButton setTitle:TSLocalizedString(@"weather.city_default") forState:UIControlStateNormal];
    [_cityNameButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
    _cityNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_cityNameButton addTarget:self action:@selector(onCityTapped) forControlEvents:UIControlEventTouchUpInside];
    [_cityCard addSubview:_cityNameButton];

    // 初始化选中值
    _selectedCity = @"深圳";
    _selectedProvince = @"广东省";
}

#pragma mark - Setup Current Weather Card

- (void)setupCurrentWeatherCard {
    _currentWeatherCard = [self createCardView];
    [_contentView addSubview:_currentWeatherCard];

    UILabel *titleLabel = [self createSectionTitleLabel:TSLocalizedString(@"weather.section.current")];
    [_currentWeatherCard addSubview:titleLabel];

    CGFloat yOffset = 50;
    CGFloat width = self.view.bounds.size.width - kCardPadding * 2;

    // 天气状况
    UILabel *weatherLabel = [self createLabel:TSLocalizedString(@"weather.current_cond")];
    weatherLabel.frame = CGRectMake(kCardPadding, yOffset + 15, 80, 20);
    [_currentWeatherCard addSubview:weatherLabel];

    _weatherCodeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _weatherCodeButton.frame = CGRectMake(kCardPadding + 90, yOffset + 10, width - 90 - kCardPadding, 30);
    [_weatherCodeButton setTitle:TSLocalizedString(@"weather.cond.sunny") forState:UIControlStateNormal];
    [_weatherCodeButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
    _weatherCodeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_weatherCodeButton addTarget:self action:@selector(onWeatherCodeTapped) forControlEvents:UIControlEventTouchUpInside];
    [_currentWeatherCard addSubview:_weatherCodeButton];
    yOffset += kRowHeight;

    // 当前温度
    _temperatureSlider = [[UISlider alloc] init];
    _temperatureLabel = [[UILabel alloc] init];
    [self createSliderInContainer:_currentWeatherCard label:TSLocalizedString(@"weather.current_temp") yOffset:yOffset slider:_temperatureSlider valueLabel:_temperatureLabel min:-20 max:50 value:25 unit:@"°C"];
    yOffset += kRowHeight;

    // 温度范围
    _minTempSlider = [[UISlider alloc] init];
    _minTempLabel = [[UILabel alloc] init];
    [self createSliderInContainer:_currentWeatherCard label:TSLocalizedString(@"weather.min_temp") yOffset:yOffset slider:_minTempSlider valueLabel:_minTempLabel min:-20 max:50 value:18 unit:@"°C"];
    yOffset += kRowHeight;

    _maxTempSlider = [[UISlider alloc] init];
    _maxTempLabel = [[UILabel alloc] init];
    [self createSliderInContainer:_currentWeatherCard label:TSLocalizedString(@"weather.max_temp") yOffset:yOffset slider:_maxTempSlider valueLabel:_maxTempLabel min:-20 max:50 value:30 unit:@"°C"];
    yOffset += kRowHeight;

    // 风力信息分隔
    UILabel *windTitle = [self createSectionTitleLabel:TSLocalizedString(@"weather.section.wind")];
    windTitle.frame = CGRectMake(0, yOffset, width, 40);
    windTitle.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightSemibold];
    [_currentWeatherCard addSubview:windTitle];
    yOffset += 40;

    _windScaleSlider = [[UISlider alloc] init];
    _windScaleLabel = [[UILabel alloc] init];
    [self createSliderInContainer:_currentWeatherCard label:TSLocalizedString(@"weather.wind_level") yOffset:yOffset slider:_windScaleSlider valueLabel:_windScaleLabel min:0 max:12 value:3 unit:@"级"];
    yOffset += kRowHeight;

    _windAngleSlider = [[UISlider alloc] init];
    _windAngleLabel = [[UILabel alloc] init];
    [self createSliderInContainer:_currentWeatherCard label:TSLocalizedString(@"weather.wind_direction") yOffset:yOffset slider:_windAngleSlider valueLabel:_windAngleLabel min:0 max:360 value:180 unit:@"°"];
    yOffset += kRowHeight;

    _windSpeedSlider = [[UISlider alloc] init];
    _windSpeedLabel = [[UILabel alloc] init];
    [self createSliderInContainer:_currentWeatherCard label:TSLocalizedString(@"weather.wind_speed") yOffset:yOffset slider:_windSpeedSlider valueLabel:_windSpeedLabel min:0 max:100 value:15 unit:@"m/s"];
    yOffset += kRowHeight;

    // 其他参数分隔
    UILabel *otherTitle = [self createSectionTitleLabel:TSLocalizedString(@"weather.section.other")];
    otherTitle.frame = CGRectMake(0, yOffset, width, 40);
    otherTitle.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightSemibold];
    [_currentWeatherCard addSubview:otherTitle];
    yOffset += 40;

    _humiditySlider = [[UISlider alloc] init];
    _humidityLabel = [[UILabel alloc] init];
    [self createSliderInContainer:_currentWeatherCard label:TSLocalizedString(@"weather.humidity") yOffset:yOffset slider:_humiditySlider valueLabel:_humidityLabel min:0 max:100 value:65 unit:@"%"];
    yOffset += kRowHeight;

    UILabel *airPressureLabel = [self createLabel:TSLocalizedString(@"weather.air_pressure")];
    airPressureLabel.frame = CGRectMake(kCardPadding, yOffset + 15, 80, 20);
    [_currentWeatherCard addSubview:airPressureLabel];

    _airPressureField = [[UITextField alloc] init];
    _airPressureField.frame = CGRectMake(kCardPadding + 90, yOffset + 10, width - 90 - kCardPadding - 50, 30);
    _airPressureField.borderStyle = UITextBorderStyleRoundedRect;
    _airPressureField.keyboardType = UIKeyboardTypeNumberPad;
    _airPressureField.text = @"1013";
    _airPressureField.delegate = self;
    _airPressureField.inputAccessoryView = [self createKeyboardToolbar];
    [_currentWeatherCard addSubview:_airPressureField];

    UILabel *airPressureUnit = [self createLabel:@"hPa"];
    airPressureUnit.frame = CGRectMake(width - 40, yOffset + 15, 40, 20);
    airPressureUnit.textAlignment = NSTextAlignmentRight;
    [_currentWeatherCard addSubview:airPressureUnit];
    yOffset += kRowHeight;

    _uvIndexSlider = [[UISlider alloc] init];
    _uvIndexLabel = [[UILabel alloc] init];
    [self createSliderInContainer:_currentWeatherCard label:TSLocalizedString(@"weather.uv_index") yOffset:yOffset slider:_uvIndexSlider valueLabel:_uvIndexLabel min:0 max:11 value:5 unit:@"级"];
    yOffset += kRowHeight;

    _visibilitySlider = [[UISlider alloc] init];
    _visibilityLabel = [[UILabel alloc] init];
    [self createSliderInContainer:_currentWeatherCard label:TSLocalizedString(@"weather.visibility") yOffset:yOffset slider:_visibilitySlider valueLabel:_visibilityLabel min:0 max:20000 value:15000 unit:@"m"];
}

#pragma mark - Setup Hourly Card

- (void)setupHourlyCard {
    _hourlyCard = [self createCardView];
    [_contentView addSubview:_hourlyCard];

    UILabel *titleLabel = [self createSectionTitleLabel:TSLocalizedString(@"weather.section.hourly")];
    [_hourlyCard addSubview:titleLabel];

    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    addButton.frame = CGRectMake(self.view.bounds.size.width - kCardPadding * 2 - 60, 10, 60, 30);
    [addButton setTitle:TSLocalizedString(@"weather.add_btn") forState:UIControlStateNormal];
    addButton.titleLabel.font = TSFont_Caption;
    [addButton addTarget:self action:@selector(onAddHourlyTapped) forControlEvents:UIControlEventTouchUpInside];
    [_hourlyCard addSubview:addButton];

    _hourlyScrollView = [[UIScrollView alloc] init];
    _hourlyScrollView.frame = CGRectMake(0, 50, self.view.bounds.size.width - kCardPadding * 2, 120);
    _hourlyScrollView.showsHorizontalScrollIndicator = NO;
    [_hourlyCard addSubview:_hourlyScrollView];

    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = TSLocalizedString(@"weather.edit_hint");
    tipLabel.font = TSFont_Caption;
    tipLabel.textColor = TSColor_TextSecondary;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.frame = CGRectMake(0, 170, self.view.bounds.size.width - kCardPadding * 2, 20);
    [_hourlyCard addSubview:tipLabel];

    // 自动生成24小时天气
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger currentHour = [calendar component:NSCalendarUnitHour fromDate:now];

    for (NSInteger i = 0; i < 24; i++) {
        NSInteger hour = (currentHour + i) % 24;
        [self addHourlyForecastView:hour];
    }
}

#pragma mark - Setup Daily Card

- (void)setupDailyCard {
    _dailyCard = [self createCardView];
    [_contentView addSubview:_dailyCard];

    UILabel *titleLabel = [self createSectionTitleLabel:TSLocalizedString(@"weather.section.daily")];
    [_dailyCard addSubview:titleLabel];

    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    addButton.frame = CGRectMake(self.view.bounds.size.width - kCardPadding * 2 - 60, 10, 60, 30);
    [addButton setTitle:TSLocalizedString(@"weather.add_btn") forState:UIControlStateNormal];
    addButton.titleLabel.font = TSFont_Caption;
    [addButton addTarget:self action:@selector(onAddDailyTapped) forControlEvents:UIControlEventTouchUpInside];
    [_dailyCard addSubview:addButton];

    // 初始添加6天预报
    for (int i = 0; i < 6; i++) {
        [self addDailyForecastView:i];
    }
}

#pragma mark - Setup Bottom Buttons

- (void)setupBottomButtons {
    _bottomRandomButton = [self createButtonWithTitle:TSLocalizedString(@"weather.random_btn") color:TSColor_Warning];
    [_bottomRandomButton addTarget:self action:@selector(onRandomTapped) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_bottomRandomButton];

    _bottomPushButton = [self createButtonWithTitle:TSLocalizedString(@"weather.push_btn") color:TSColor_Success];
    [_bottomPushButton addTarget:self action:@selector(onPushTapped) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_bottomPushButton];
}

#pragma mark - Setup Loading Indicator

- (void)setupLoadingIndicator {
    _loadingOverlay = [[UIView alloc] init];
    _loadingOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _loadingOverlay.hidden = YES;
    [self.view addSubview:_loadingOverlay];

    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingIndicator.center = self.view.center;
    [_loadingOverlay addSubview:_loadingIndicator];

    UILabel *loadingLabel = [[UILabel alloc] init];
    loadingLabel.text = TSLocalizedString(@"weather.pushing");
    loadingLabel.font = TSFont_Body;
    loadingLabel.textColor = UIColor.whiteColor;
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.frame = CGRectMake(0, _loadingIndicator.center.y + 40, self.view.bounds.size.width, 30);
    [_loadingOverlay addSubview:loadingLabel];
}

#pragma mark - Layout Views

- (void)layoutViews {
    CGFloat width = self.view.bounds.size.width;

    _scrollView.frame = self.view.bounds;
    _loadingOverlay.frame = self.view.bounds;

    CGFloat yOffset = TSSpacing_MD;

    // 顶部操作区
    _headerCard.frame = CGRectMake(kCardPadding, yOffset, width - kCardPadding * 2, 142);
    yOffset += 142 + TSSpacing_MD;

    // 城市信息卡片
    _cityCard.frame = CGRectMake(kCardPadding, yOffset, width - kCardPadding * 2, 50 + kRowHeight * 2);
    yOffset += 50 + kRowHeight * 2 + TSSpacing_MD;

    // 当前天气卡片
    _currentWeatherCard.frame = CGRectMake(kCardPadding, yOffset, width - kCardPadding * 2, 690);
    yOffset += 690 + TSSpacing_MD;

    // 7天预报卡片
    CGFloat dailyHeight = 50 + _dailyViews.count * 70 + TSSpacing_MD;
    _dailyCard.frame = CGRectMake(kCardPadding, yOffset, width - kCardPadding * 2, dailyHeight);
    yOffset += dailyHeight + TSSpacing_MD;

    // 24小时预报卡片
    _hourlyCard.frame = CGRectMake(kCardPadding, yOffset, width - kCardPadding * 2, 200);
    yOffset += 200 + TSSpacing_MD;

    // 底部按钮
    CGFloat btnWidth = (width - kCardPadding * 3) / 2;
    _bottomRandomButton.frame = CGRectMake(kCardPadding, yOffset, btnWidth, 50);
    _bottomPushButton.frame = CGRectMake(kCardPadding * 2 + btnWidth, yOffset, btnWidth, 50);
    yOffset += 50 + TSSpacing_LG;

    _contentView.frame = CGRectMake(0, 0, width, yOffset);
    _scrollView.contentSize = CGSizeMake(width, yOffset);
}

#pragma mark - Helper Methods

- (UIView *)createCardView {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = TSColor_Card;
    card.layer.cornerRadius = TSRadius_MD;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    card.layer.shadowOpacity = 0.1;
    card.layer.shadowRadius = 4;
    return card;
}

- (UIToolbar *)createKeyboardToolbar {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    toolbar.barStyle = UIBarStyleDefault;

    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.done") style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];

    toolbar.items = @[flexSpace, doneButton];
    [toolbar sizeToFit];

    return toolbar;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (UILabel *)createSectionTitleLabel:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = TSFont_H2;
    label.textColor = TSColor_TextPrimary;
    label.frame = CGRectMake(kCardPadding, 10, self.view.bounds.size.width - kCardPadding * 4, 30);
    return label;
}

- (UILabel *)createLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = TSFont_Body;
    label.textColor = TSColor_TextSecondary;
    return label;
}

- (UIButton *)createButtonWithTitle:(NSString *)title color:(UIColor *)color {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.backgroundColor = color;
    button.layer.cornerRadius = 8;
    button.titleLabel.font = TSFont_Body;
    return button;
}

- (UITextField *)addFormRow:(UIView *)container label:(NSString *)labelText yOffset:(CGFloat)yOffset placeholder:(NSString *)placeholder {
    CGFloat width = self.view.bounds.size.width - kCardPadding * 2;

    UILabel *label = [self createLabel:labelText];
    label.frame = CGRectMake(kCardPadding, yOffset + 15, 80, 20);
    [container addSubview:label];

    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectMake(kCardPadding + 90, yOffset + 10, width - 90 - kCardPadding, 30);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = placeholder;
    textField.delegate = self;
    [container addSubview:textField];

    return textField;
}

- (void)createSliderInContainer:(UIView *)container label:(NSString *)labelText yOffset:(CGFloat)yOffset slider:(UISlider *)slider valueLabel:(UILabel *)valueLabel min:(float)min max:(float)max value:(float)value unit:(NSString *)unit {
    CGFloat containerWidth = self.view.bounds.size.width - kCardPadding * 2;  // 卡片内容宽度

    UILabel *label = [self createLabel:labelText];
    label.frame = CGRectMake(kCardPadding, yOffset + 15, 80, 20);
    [container addSubview:label];

    // 滑块：从标签右侧开始，到单位标签左侧结束
    slider.frame = CGRectMake(kCardPadding + 90, yOffset + 15, containerWidth - 90 - kCardPadding - 65, 20);
    slider.minimumValue = min;
    slider.maximumValue = max;
    slider.value = value;
    slider.tintColor = TSColor_Primary;
    [slider addTarget:self action:@selector(onSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [container addSubview:slider];

    // 单位标签：距离卡片右边缘 kCardPadding
    valueLabel.frame = CGRectMake(containerWidth - 55, yOffset + 15, 55, 20);
    valueLabel.text = [NSString stringWithFormat:@"%.0f%@", value, unit];
    valueLabel.font = TSFont_Body;
    valueLabel.textColor = TSColor_Primary;
    valueLabel.textAlignment = NSTextAlignmentRight;
    [container addSubview:valueLabel];
}

- (void)addHourlyForecastView:(NSInteger)hour {
    CGFloat xOffset = _hourlyViews.count * 90;

    UIView *hourView = [[UIView alloc] init];
    hourView.frame = CGRectMake(xOffset, 0, 80, 110);
    hourView.backgroundColor = TSColor_Background;
    hourView.layer.cornerRadius = 8;
    hourView.tag = 2000 + hour;
    [_hourlyScrollView addSubview:hourView];
    [_hourlyViews addObject:hourView];

    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = [NSString stringWithFormat:@"%02ld:00", (long)hour];
    timeLabel.font = TSFont_Caption;
    timeLabel.textColor = TSColor_TextPrimary;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.frame = CGRectMake(0, 8, 80, 16);
    timeLabel.tag = 1;
    [hourView addSubview:timeLabel];

    // 随机天气图标
    NSArray *weatherOptions = TSWeatherCodeOptions();
    NSDictionary *randomWeather = weatherOptions[arc4random_uniform((uint32_t)weatherOptions.count)];
    NSString *weatherIcon = [randomWeather[@"name"] componentsSeparatedByString:@" "].firstObject;

    UILabel *weatherIconLabel = [[UILabel alloc] init];
    weatherIconLabel.text = weatherIcon;
    weatherIconLabel.font = [UIFont systemFontOfSize:24];
    weatherIconLabel.textAlignment = NSTextAlignmentCenter;
    weatherIconLabel.frame = CGRectMake(0, 28, 80, 30);
    weatherIconLabel.tag = 2;
    [hourView addSubview:weatherIconLabel];

    NSInteger randomTemp = 15 + arc4random_uniform(20);
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.text = [NSString stringWithFormat:@"%ld°C", (long)randomTemp];
    tempLabel.font = TSFont_Body;
    tempLabel.textColor = TSColor_Primary;
    tempLabel.textAlignment = NSTextAlignmentCenter;
    tempLabel.frame = CGRectMake(0, 62, 80, 20);
    tempLabel.tag = 3;
    [hourView addSubview:tempLabel];

    NSInteger randomWind = arc4random_uniform(6);
    UILabel *windLabel = [[UILabel alloc] init];
        windLabel.text = [NSString stringWithFormat:TSLocalizedString(@"weather.wind_hourly_format"), (long)randomWind];
    windLabel.font = TSFont_Caption;
    windLabel.textColor = TSColor_TextSecondary;
    windLabel.textAlignment = NSTextAlignmentCenter;
    windLabel.frame = CGRectMake(0, 86, 80, 16);
    windLabel.tag = 4;
    [hourView addSubview:windLabel];

    // 添加删除按钮（右上角）
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    deleteButton.frame = CGRectMake(60, 2, 18, 18);
    [deleteButton setTitle:@"×" forState:UIControlStateNormal];
    [deleteButton setTitleColor:TSColor_Danger forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    deleteButton.backgroundColor = [UIColor whiteColor];
    deleteButton.layer.cornerRadius = 9;
    deleteButton.tag = 100;
    [deleteButton addTarget:self action:@selector(onHourlyDeleteTapped:) forControlEvents:UIControlEventTouchUpInside];
    [hourView addSubview:deleteButton];

    // 点击编辑
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHourlyViewTapped:)];
    [hourView addGestureRecognizer:tap];

    _hourlyScrollView.contentSize = CGSizeMake((_hourlyViews.count) * 90, 110);
}

- (void)addDailyForecastView:(NSInteger)index {
    CGFloat width = self.view.bounds.size.width - kCardPadding * 2;
    CGFloat yOffset = 50 + index * 70;

    UIView *dayView = [[UIView alloc] init];
    dayView.frame = CGRectMake(0, yOffset, width, 60);
    dayView.backgroundColor = TSColor_Background;
    dayView.layer.cornerRadius = 8;
    dayView.tag = 1000 + index;
    [_dailyCard addSubview:dayView];
    [_dailyViews addObject:dayView];

    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:86400 * (index + 1)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd";
    NSString *dateStr = [formatter stringFromDate:date];

    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.text = index == 0 ? [NSString stringWithFormat:TSLocalizedString(@"weather.tomorrow"), dateStr] : dateStr;
    dateLabel.font = TSFont_Body;
    dateLabel.textColor = TSColor_TextPrimary;
    dateLabel.frame = CGRectMake(kCardPadding, 10, 100, 20);
    dateLabel.tag = 10;
    [dayView addSubview:dateLabel];

    // 随机白天和夜间天气图标
    NSArray *weatherOptions = TSWeatherCodeOptions();
    NSDictionary *randomDayWeather = weatherOptions[arc4random_uniform((uint32_t)weatherOptions.count)];
    NSString *dayIcon = [randomDayWeather[@"name"] componentsSeparatedByString:@" "].firstObject;

    NSDictionary *randomNightWeather = weatherOptions[arc4random_uniform((uint32_t)weatherOptions.count)];
    NSString *nightIcon = [randomNightWeather[@"name"] componentsSeparatedByString:@" "].firstObject;

    UILabel *weatherLabel = [[UILabel alloc] init];
    weatherLabel.text = [NSString stringWithFormat:@"%@→%@", dayIcon, nightIcon];
    weatherLabel.font = TSFont_Body;
    weatherLabel.frame = CGRectMake(kCardPadding, 35, 60, 20);
    weatherLabel.tag = 11;
    [dayView addSubview:weatherLabel];

    // 随机温度
    NSInteger minTemp = 15 + arc4random_uniform(10);
    NSInteger maxTemp = minTemp + 8 + arc4random_uniform(8);
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.text = [NSString stringWithFormat:@"%ld°C ~ %ld°C", (long)minTemp, (long)maxTemp];
    tempLabel.font = TSFont_Caption;
    tempLabel.textColor = TSColor_TextSecondary;
    tempLabel.frame = CGRectMake(kCardPadding + 70, 35, 100, 20);
    tempLabel.tag = 12;
    [dayView addSubview:tempLabel];

    // 随机风力
    NSInteger windScale = arc4random_uniform(6);
    UILabel *windLabel = [[UILabel alloc] init];
    windLabel.text = [NSString stringWithFormat:TSLocalizedString(@"weather.wind_daily_format"), (long)windScale];
    windLabel.font = TSFont_Caption;
    windLabel.textColor = TSColor_TextSecondary;
    windLabel.frame = CGRectMake(width - kCardPadding - 80, 35, 80, 20);
    windLabel.textAlignment = NSTextAlignmentRight;
    windLabel.tag = 13;
    [dayView addSubview:windLabel];

    // 添加删除按钮（右上角）
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    deleteButton.frame = CGRectMake(width - 30, 5, 25, 25);
    [deleteButton setTitle:@"×" forState:UIControlStateNormal];
    [deleteButton setTitleColor:TSColor_Danger forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    deleteButton.backgroundColor = [UIColor whiteColor];
    deleteButton.layer.cornerRadius = 12.5;
    [deleteButton addTarget:self action:@selector(onDailyDeleteTapped:) forControlEvents:UIControlEventTouchUpInside];
    [dayView addSubview:deleteButton];

    // 点击编辑
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDailyViewTapped:)];
    [dayView addGestureRecognizer:tap];
}

#pragma mark - Actions

- (void)onWeatherSwitchChanged:(UISwitch *)sender {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] weather] setWeatherEnable:sender.isOn completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [weakSelf showToast:sender.isOn ? TSLocalizedString(@"weather.toggle_on") : TSLocalizedString(@"weather.toggle_off")];
        } else {
            [weakSelf showToast:[NSString stringWithFormat:TSLocalizedString(@"weather.op_failed_format"), error.localizedDescription]];
            sender.on = !sender.isOn;
        }
    }];
}

- (void)onPushTapped {
    [self collectWeatherData];
    [self showLoading:YES];
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] weather] pushWeather:_weatherModel completion:^(BOOL success, NSError * _Nullable error) {
        [weakSelf showLoading:NO];
        if (success) {
            [weakSelf showToast:TSLocalizedString(@"weather.push_success")];
            [weakSelf refreshTimeLabel];
        } else {
            [weakSelf showToast:[NSString stringWithFormat:TSLocalizedString(@"weather.push_failed_format"), error.localizedDescription]];
        }
    }];
}

- (void)onRandomTapped {
    [self generateRandomWeatherData];
    [self showToast:TSLocalizedString(@"weather.random_success")];
}

- (void)onWeatherCodeTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"weather.select_condition") message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    for (NSDictionary *option in TSWeatherCodeOptions()) {
        [alert addAction:[UIAlertAction actionWithTitle:option[@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectedWeatherCode = [option[@"code"] integerValue];
            [self.weatherCodeButton setTitle:option[@"name"] forState:UIControlStateNormal];
        }]];
    }

    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onCityTapped {
    NSArray *cities = [self citiesForProvince:_selectedProvince];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"weather.select_city") message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    for (NSString *city in cities) {
        [alert addAction:[UIAlertAction actionWithTitle:city style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectedCity = city;
            [self.cityNameButton setTitle:[NSString stringWithFormat:@"%@ ▼", city] forState:UIControlStateNormal];
        }]];
    }

    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onProvinceTapped {
    NSArray *provinces = @[@"广东省", @"北京市", @"上海市", @"浙江省", @"江苏省", @"四川省", @"湖北省", @"陕西省", @"重庆市"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"weather.select_province") message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    for (NSString *province in provinces) {
        [alert addAction:[UIAlertAction actionWithTitle:province style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectedProvince = province;
            [self.provinceButton setTitle:[NSString stringWithFormat:@"%@ ▼", province] forState:UIControlStateNormal];

            // 刷新城市列表
            NSArray *cities = [self citiesForProvince:province];
            self.selectedCity = cities.firstObject;
            [self.cityNameButton setTitle:[NSString stringWithFormat:@"%@ ▼", self.selectedCity] forState:UIControlStateNormal];
        }]];
    }

    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSArray *)citiesForProvince:(NSString *)province {
    NSDictionary *provinceCities = @{
        @"广东省": @[@"深圳", @"广州", @"东莞", @"佛山", @"珠海"],
        @"北京市": @[@"北京"],
        @"上海市": @[@"上海"],
        @"浙江省": @[@"杭州", @"宁波", @"温州", @"绍兴"],
        @"江苏省": @[@"南京", @"苏州", @"无锡", @"常州"],
        @"四川省": @[@"成都", @"绵阳", @"德阳"],
        @"湖北省": @[@"武汉", @"宜昌", @"襄阳"],
        @"陕西省": @[@"西安", @"咸阳", @"宝鸡"],
        @"重庆市": @[@"重庆"]
    };
    return provinceCities[province] ?: @[TSLocalizedString(@"weather.unknown_city")];
}

- (void)onSliderChanged:(UISlider *)slider {
    if (slider == _temperatureSlider) {
        _temperatureLabel.text = [NSString stringWithFormat:@"%.0f°C", slider.value];
    } else if (slider == _minTempSlider) {
        _minTempLabel.text = [NSString stringWithFormat:@"%.0f°C", slider.value];
    } else if (slider == _maxTempSlider) {
        _maxTempLabel.text = [NSString stringWithFormat:@"%.0f°C", slider.value];
    } else if (slider == _windScaleSlider) {
        _windScaleLabel.text = [NSString stringWithFormat:@"%.0f%@", slider.value, TSLocalizedString(@"weather.unit_level")];
    } else if (slider == _windAngleSlider) {
        _windAngleLabel.text = [NSString stringWithFormat:@"%.0f°", slider.value];
    } else if (slider == _windSpeedSlider) {
        _windSpeedLabel.text = [NSString stringWithFormat:@"%.0fm/s", slider.value];
    } else if (slider == _humiditySlider) {
        _humidityLabel.text = [NSString stringWithFormat:@"%.0f%%", slider.value];
    } else if (slider == _uvIndexSlider) {
        _uvIndexLabel.text = [NSString stringWithFormat:@"%.0f%@", slider.value, TSLocalizedString(@"weather.unit_level")];
    } else if (slider == _visibilitySlider) {
        _visibilityLabel.text = [NSString stringWithFormat:@"%.0fm", slider.value];
    }
}

- (void)onDailyDeleteTapped:(UIButton *)button {
    UIView *dayView = button.superview;

    [UIView animateWithDuration:0.3 animations:^{
        dayView.alpha = 0;
        dayView.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [dayView removeFromSuperview];
        [self.dailyViews removeObject:dayView];
        [self relayoutDailyViews];
        [self showToast:TSLocalizedString(@"weather.deleted")];
    }];
}

- (void)onAddHourlyTapped {
    if (_hourlyViews.count >= 24) {
        [self showToast:TSLocalizedString(@"weather.max_hourly")];
        return;
    }
    NSInteger hour = _hourlyViews.count;
    [self addHourlyForecastView:hour];
    [self layoutViews];
}

- (void)onAddDailyTapped {
    if (_dailyViews.count >= 7) {
        [self showToast:TSLocalizedString(@"weather.max_daily")];
        return;
    }
    [self addDailyForecastView:_dailyViews.count];
    [self layoutViews];
}

- (void)onHourlyDeleteTapped:(UIButton *)button {
    UIView *hourView = button.superview;

    [UIView animateWithDuration:0.3 animations:^{
        hourView.alpha = 0;
        hourView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        [hourView removeFromSuperview];
        [self.hourlyViews removeObject:hourView];
        [self relayoutHourlyViews];
        [self showToast:TSLocalizedString(@"weather.deleted")];
    }];
}

- (void)onHourlyViewTapped:(UITapGestureRecognizer *)gesture {
    UIView *hourView = gesture.view;
    UILabel *timeLabel = [hourView viewWithTag:1];
    UILabel *iconLabel = [hourView viewWithTag:2];
    UILabel *tempLabel = [hourView viewWithTag:3];
    UILabel *windLabel = [hourView viewWithTag:4];

    TSHourlyWeatherEditVC *editVC = [[TSHourlyWeatherEditVC alloc] init];
    editVC.hourTime = timeLabel.text;
    editVC.weatherIcon = iconLabel.text;

    NSString *tempStr = [tempLabel.text stringByReplacingOccurrencesOfString:@"°C" withString:@""];
    editVC.temperature = [tempStr integerValue];

    NSString *windStr = [[windLabel.text stringByReplacingOccurrencesOfString:@"风" withString:@""] stringByReplacingOccurrencesOfString:@"级" withString:@""];
    editVC.windScale = [windStr integerValue];

    __weak typeof(hourView) weakHourView = hourView;
    __weak typeof(self) weakSelf = self;
    editVC.completion = ^(NSString *weatherIcon, NSInteger temperature, NSInteger windScale) {
        UILabel *iconLabel = [weakHourView viewWithTag:2];
        iconLabel.text = weatherIcon;

        UILabel *tempLabel = [weakHourView viewWithTag:3];
        tempLabel.text = [NSString stringWithFormat:@"%ld°C", (long)temperature];

        UILabel *windLabel = [weakHourView viewWithTag:4];
        windLabel.text = [NSString stringWithFormat:TSLocalizedString(@"weather.wind_hourly_format"), (long)windScale];

        [weakSelf showToast:TSLocalizedString(@"weather.save_success")];
    };

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editVC];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)onDailyViewTapped:(UITapGestureRecognizer *)gesture {
    UIView *dayView = gesture.view;
    UILabel *dateLabel = [dayView viewWithTag:10];

    // 解析当前数据
    NSString *dayIcon = @"☀️";
    NSString *nightIcon = @"🌙";
    NSInteger minTemp = 18;
    NSInteger maxTemp = 28;
    NSInteger windScale = 3;

    // 从UI中提取当前值
    for (UIView *subview in dayView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            if (label.frame.origin.y == 35) {
                if (label.frame.origin.x == kCardPadding) {
                    // 天气图标
                    NSArray *icons = [label.text componentsSeparatedByString:@"→"];
                    if (icons.count == 2) {
                        dayIcon = icons[0];
                        nightIcon = icons[1];
                    }
                } else if (label.frame.origin.x == kCardPadding + 70) {
                    // 温度
                    NSString *tempStr = label.text;
                    NSArray *temps = [tempStr componentsSeparatedByString:@" ~ "];
                    if (temps.count == 2) {
                        minTemp = [[temps[0] stringByReplacingOccurrencesOfString:@"°C" withString:@""] integerValue];
                        maxTemp = [[temps[1] stringByReplacingOccurrencesOfString:@"°C" withString:@""] integerValue];
                    }
                } else {
                    // 风力
                    NSString *windStr = [[label.text stringByReplacingOccurrencesOfString:@"风力" withString:@""] stringByReplacingOccurrencesOfString:@"级" withString:@""];
                    windScale = [windStr integerValue];
                }
            }
        }
    }

    TSDailyWeatherEditVC *editVC = [[TSDailyWeatherEditVC alloc] init];
    editVC.dateString = dateLabel.text;
    editVC.dayIcon = dayIcon;
    editVC.nightIcon = nightIcon;
    editVC.minTemp = minTemp;
    editVC.maxTemp = maxTemp;
    editVC.windScale = windScale;

    __weak typeof(dayView) weakDayView = dayView;
    __weak typeof(self) weakSelf = self;
    editVC.completion = ^(NSString *dayIcon, NSString *nightIcon, NSInteger minTemp, NSInteger maxTemp, NSInteger windScale, NSInteger hour, NSInteger minute) {
        CGFloat width = weakSelf.view.bounds.size.width - kCardPadding * 2;

        // 更新UI
        for (UIView *subview in weakDayView.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)subview;
                if (label.frame.origin.x == kCardPadding && label.frame.origin.y == 35) {
                    label.text = [NSString stringWithFormat:@"%@→%@", dayIcon, nightIcon];
                } else if (label.frame.origin.x == kCardPadding + 70 && label.frame.origin.y == 35) {
                    label.text = [NSString stringWithFormat:@"%ld°C ~ %ld°C", (long)minTemp, (long)maxTemp];
                } else if (label.frame.origin.x == width - kCardPadding - 80 && label.frame.origin.y == 35) {
                    label.text = [NSString stringWithFormat:TSLocalizedString(@"weather.wind_daily_format"), (long)windScale];
                }
            }
        }

        [weakSelf showToast:TSLocalizedString(@"weather.save_success")];
    };

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editVC];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)relayoutHourlyViews {
    for (NSInteger i = 0; i < _hourlyViews.count; i++) {
        UIView *view = _hourlyViews[i];
        [UIView animateWithDuration:0.3 animations:^{
            view.frame = CGRectMake(i * 90, 0, 80, 110);
            view.transform = CGAffineTransformIdentity;
            view.alpha = 1;
        }];
    }
    _hourlyScrollView.contentSize = CGSizeMake(_hourlyViews.count * 90, 110);
}

- (void)relayoutDailyViews {
    CGFloat width = self.view.bounds.size.width - kCardPadding * 2;
    for (NSInteger i = 0; i < _dailyViews.count; i++) {
        UIView *view = _dailyViews[i];
        CGFloat yOffset = 50 + i * 70;

        // 更新日期标签
        UILabel *dateLabel = [view viewWithTag:10];
        if (dateLabel && i == 0) {
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:86400];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MM/dd";
            NSString *dateStr = [formatter stringFromDate:date];
            dateLabel.text = [NSString stringWithFormat:TSLocalizedString(@"weather.tomorrow"), dateStr];
        }

        [UIView animateWithDuration:0.3 animations:^{
            view.frame = CGRectMake(0, yOffset, width, 60);
            view.transform = CGAffineTransformIdentity;
            view.alpha = 1;
        }];
    }
    [self layoutViews];
}

#pragma mark - Data Methods

- (void)collectWeatherData {
    // 收集城市信息
    TSWeatherCity *city = [TSWeatherCity cityWithName:_selectedCity ?: @"深圳"];
    city.latitude = 22.5431;  // 默认深圳坐标
    city.longitude = 114.0579;
    city.provinceName = _selectedProvince;
    city.countryName = @"中国";
    _weatherModel.city = city;

    // 收集当前天气
    _weatherModel.dayCode = [TSWeatherCodeModel weatherCodeWithCode:_selectedWeatherCode];
    _weatherModel.curTemperature = (NSInteger)_temperatureSlider.value;
    _weatherModel.minTemperature = (NSInteger)_minTempSlider.value;
    _weatherModel.maxTemperature = (NSInteger)_maxTempSlider.value;
    _weatherModel.windScale = (NSInteger)_windScaleSlider.value;
    _weatherModel.windAngle = (NSInteger)_windAngleSlider.value;
    _weatherModel.windSpeed = (NSInteger)_windSpeedSlider.value;
    _weatherModel.humidity = (NSInteger)_humiditySlider.value;
    _weatherModel.airpressure = [_airPressureField.text integerValue];
    _weatherModel.uvIndex = (NSInteger)_uvIndexSlider.value;
    _weatherModel.visibility = (NSInteger)_visibilitySlider.value;
    _weatherModel.updateTimestamp = [[NSDate date] timeIntervalSince1970];

    // 收集7天预报
    NSMutableArray *futureWeather = [NSMutableArray array];
    for (UIView *dayView in _dailyViews) {
        TSWeatherDay *dayModel = [[TSWeatherDay alloc] init];

        // 从 tag=11 的 weatherLabel 读取天气图标（格式：dayIcon→nightIcon）
        UILabel *weatherLabel = (UILabel *)[dayView viewWithTag:11];
        NSArray<NSString *> *icons = [weatherLabel.text componentsSeparatedByString:@"→"];
        NSString *dayIcon = icons.count > 0 ? icons[0] : @"☀️";
        NSString *nightIcon = icons.count > 1 ? icons[1] : @"🌙";

        // 根据图标找对应 code
        TSWeatherCode dayCode = TSWeatherCodeSunnyDay;
        TSWeatherCode nightCode = TSWeatherCodeClearNight;
        for (NSDictionary *option in TSWeatherCodeOptions()) {
            NSString *optionIcon = [option[@"name"] componentsSeparatedByString:@" "].firstObject;
            if ([optionIcon isEqualToString:dayIcon]) dayCode = [option[@"code"] integerValue];
            if ([optionIcon isEqualToString:nightIcon]) nightCode = [option[@"code"] integerValue];
        }
        dayModel.dayCode = [TSWeatherCodeModel weatherCodeWithCode:dayCode];
        dayModel.nightCode = [TSWeatherCodeModel weatherCodeWithCode:nightCode];

        // 从 tag=12 的 tempLabel 读取温度（格式：minTemp°C ~ maxTemp°C）
        UILabel *tempLabel = (UILabel *)[dayView viewWithTag:12];
        NSArray<NSString *> *temps = [tempLabel.text componentsSeparatedByString:@" ~ "];
        dayModel.minTemperature = temps.count > 0 ? [[temps[0] stringByReplacingOccurrencesOfString:@"°C" withString:@""] integerValue] : 15;
        dayModel.maxTemperature = temps.count > 1 ? [[temps[1] stringByReplacingOccurrencesOfString:@"°C" withString:@""] integerValue] : 25;

        // 从 tag=13 的 windLabel 读取风力（格式：风力N级）
        UILabel *windLabel = (UILabel *)[dayView viewWithTag:13];
        NSString *windStr = [windLabel.text stringByReplacingOccurrencesOfString:@"风力" withString:@""];
        windStr = [windStr stringByReplacingOccurrencesOfString:@"级" withString:@""];
        dayModel.windScale = [windStr integerValue];

        [futureWeather addObject:dayModel];
    }
    _weatherModel.futhureSevenDays = futureWeather;

    // 收集24小时预报
    NSMutableArray *futureHours = [NSMutableArray array];
    for (UIView *hourView in _hourlyViews) {
        // tag=1: 时间（HH:00）
        UILabel *timeLabel = (UILabel *)[hourView viewWithTag:1];
        NSInteger hour = [[timeLabel.text stringByReplacingOccurrencesOfString:@":00" withString:@""] integerValue];

        // tag=2: 天气图标（emoji）
        UILabel *iconLabel = (UILabel *)[hourView viewWithTag:2];
        TSWeatherCode code = TSWeatherCodeSunnyDay;
        for (NSDictionary *option in TSWeatherCodeOptions()) {
            NSString *optionIcon = [option[@"name"] componentsSeparatedByString:@" "].firstObject;
            if ([optionIcon isEqualToString:iconLabel.text]) {
                code = [option[@"code"] integerValue];
                break;
            }
        }

        // tag=3: 温度（N°C）
        UILabel *tempLabel = (UILabel *)[hourView viewWithTag:3];
        NSInteger temp = [[tempLabel.text stringByReplacingOccurrencesOfString:@"°C" withString:@""] integerValue];

        // tag=4: 风力（风N级）
        UILabel *windLabel = (UILabel *)[hourView viewWithTag:4];
        NSString *windStr = [[windLabel.text stringByReplacingOccurrencesOfString:@"风" withString:@""] stringByReplacingOccurrencesOfString:@"级" withString:@""];
        NSInteger wind = [windStr integerValue];

        TSWeatherHour *hourModel = [TSWeatherHour modelWithCode:[TSWeatherCodeModel weatherCodeWithCode:code]
                                                    temperature:(SInt8)temp
                                                      windScale:wind];

        // 设置时间戳（今天的对应小时）
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *today = [calendar startOfDayForDate:[NSDate date]];
        hourModel.timestamp = [today timeIntervalSince1970] + hour * 3600;

        [futureHours addObject:hourModel];
    }
    _weatherModel.futhure24Hours = futureHours;
}

- (void)updateUIWithWeatherModel:(TopStepWeather *)weather {
    if (!weather) return;

    // 更新城市信息
    _selectedCity = weather.city.cityName;
    _selectedProvince = weather.city.provinceName;
    [_cityNameButton setTitle:[NSString stringWithFormat:@"%@ ▼", _selectedCity] forState:UIControlStateNormal];
    [_provinceButton setTitle:[NSString stringWithFormat:@"%@ ▼", _selectedProvince] forState:UIControlStateNormal];

    // 更新当前天气
    if (weather.dayCode) {
        _selectedWeatherCode = weather.dayCode.code;
        for (NSDictionary *option in TSWeatherCodeOptions()) {
            if ([option[@"code"] integerValue] == weather.dayCode.code) {
                [_weatherCodeButton setTitle:option[@"name"] forState:UIControlStateNormal];
                break;
            }
        }
    }

    _temperatureSlider.value = weather.curTemperature;
    _temperatureLabel.text = [NSString stringWithFormat:@"%.0f°C", (float)weather.curTemperature];

    _minTempSlider.value = weather.minTemperature;
    _minTempLabel.text = [NSString stringWithFormat:@"%.0f°C", (float)weather.minTemperature];

    _maxTempSlider.value = weather.maxTemperature;
    _maxTempLabel.text = [NSString stringWithFormat:@"%.0f°C", (float)weather.maxTemperature];

    _windScaleSlider.value = weather.windScale;
    _windScaleLabel.text = [NSString stringWithFormat:@"%.0f%@", (float)weather.windScale, TSLocalizedString(@"weather.unit_level")];

    _windAngleSlider.value = weather.windAngle;
    _windAngleLabel.text = [NSString stringWithFormat:@"%.0f°", (float)weather.windAngle];

    _windSpeedSlider.value = weather.windSpeed;
    _windSpeedLabel.text = [NSString stringWithFormat:@"%.0fm/s", (float)weather.windSpeed];

    _humiditySlider.value = weather.humidity;
    _humidityLabel.text = [NSString stringWithFormat:@"%.0f%%", (float)weather.humidity];

    _airPressureField.text = [NSString stringWithFormat:@"%ld", (long)weather.airpressure];

    _uvIndexSlider.value = weather.uvIndex;
    _uvIndexLabel.text = [NSString stringWithFormat:@"%.0f%@", (float)weather.uvIndex, TSLocalizedString(@"weather.unit_level")];

    _visibilitySlider.value = weather.visibility;
    _visibilityLabel.text = [NSString stringWithFormat:@"%.0fm", (float)weather.visibility];

    [self updateTimeLabel];
}

- (void)generateRandomWeatherData {
    // 随机城市信息
    _selectedCity = @"深圳";
    _selectedProvince = @"广东省";
    [_cityNameButton setTitle:TSLocalizedString(@"weather.city_default") forState:UIControlStateNormal];
    [_provinceButton setTitle:TSLocalizedString(@"weather.province_default") forState:UIControlStateNormal];

    // 随机天气状况
    NSArray *options = TSWeatherCodeOptions();
    NSDictionary *randomOption = options[arc4random_uniform((uint32_t)options.count)];
    _selectedWeatherCode = [randomOption[@"code"] integerValue];
    [_weatherCodeButton setTitle:randomOption[@"name"] forState:UIControlStateNormal];

    // 随机温度
    float temp = [self randomTemperatureWithMin:20 max:30];
    _temperatureSlider.value = temp;
    _temperatureLabel.text = [NSString stringWithFormat:@"%.0f°C", temp];

    float minTemp = [self randomTemperatureWithMin:15 max:20];
    _minTempSlider.value = minTemp;
    _minTempLabel.text = [NSString stringWithFormat:@"%.0f°C", minTemp];

    float maxTemp = [self randomTemperatureWithMin:30 max:35];
    _maxTempSlider.value = maxTemp;
    _maxTempLabel.text = [NSString stringWithFormat:@"%.0f°C", maxTemp];

    // 随机风力
    float windScale = arc4random_uniform(6);
    _windScaleSlider.value = windScale;
    _windScaleLabel.text = [NSString stringWithFormat:@"%.0f%@", windScale, TSLocalizedString(@"weather.unit_level")];

    float windAngle = arc4random_uniform(360);
    _windAngleSlider.value = windAngle;
    _windAngleLabel.text = [NSString stringWithFormat:@"%.0f°", windAngle];

    float windSpeed = arc4random_uniform(100);
    _windSpeedSlider.value = windSpeed;
    _windSpeedLabel.text = [NSString stringWithFormat:@"%.0fm/s", windSpeed];

    // 随机其他参数
    float humidity = 40 + arc4random_uniform(41);
    _humiditySlider.value = humidity;
    _humidityLabel.text = [NSString stringWithFormat:@"%.0f%%", humidity];

    _airPressureField.text = @"1013";

    float uvIndex = arc4random_uniform(11);
    _uvIndexSlider.value = uvIndex;
    _uvIndexLabel.text = [NSString stringWithFormat:@"%.0f%@", uvIndex, TSLocalizedString(@"weather.unit_level")];

    float visibility = 1000 + arc4random_uniform(19000);
    _visibilitySlider.value = visibility;
    _visibilityLabel.text = [NSString stringWithFormat:@"%.0fm", visibility];
}

- (NSInteger)randomTemperatureWithMin:(NSInteger)min max:(NSInteger)max {
    return min + arc4random_uniform((int)(max - min + 1));
}

- (TSWeatherCode)randomWeatherCode {
    TSWeatherCode commonCodes[] = {
        TSWeatherCodeSunnyDay,
        TSWeatherCodeOvercast,
        TSWeatherCodePartlyCloudyDay,
        TSWeatherCodeRain,
        TSWeatherCodeShowers,
        TSWeatherCodeThunderstorms
    };
    int count = sizeof(commonCodes) / sizeof(commonCodes[0]);
    return commonCodes[arc4random_uniform(count)];
}

#pragma mark - Network Methods

- (void)fetchWeatherEnable {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] weather] fetchWeatherEnableWithCompletion:^(BOOL enabled, NSError * _Nullable error) {
        if (!error) {
            weakSelf.weatherSwitch.on = enabled;
        }
    }];
}

#pragma mark - UI Helper Methods

- (void)showLoading:(BOOL)show {
    _loadingOverlay.hidden = !show;
    if (show) {
        [_loadingIndicator startAnimating];
    } else {
        [_loadingIndicator stopAnimating];
    }
}

- (void)showToast:(NSString *)text {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (!window) return;

    UILabel *toast = [[UILabel alloc] init];
    toast.text = text;
    toast.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    toast.textColor = UIColor.whiteColor;
    toast.textAlignment = NSTextAlignmentCenter;
    toast.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    toast.layer.cornerRadius = 8;
    toast.clipsToBounds = YES;

    CGFloat tw = [toast sizeThatFits:CGSizeMake(300, 40)].width + 32;
    toast.frame = CGRectMake((window.bounds.size.width - tw) / 2.f,
                              window.bounds.size.height * 0.75f, tw, 40);
    toast.alpha = 0;
    [window addSubview:toast];

    [UIView animateWithDuration:0.2 animations:^{ toast.alpha = 1; } completion:^(BOOL _) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{ toast.alpha = 0; }
                            completion:^(BOOL __) { [toast removeFromSuperview]; }];
        });
    }];
}

- (void)refreshTimeLabel {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *timeStr = [formatter stringFromDate:[NSDate date]];
    _updateTimeLabel.text = [NSString stringWithFormat:TSLocalizedString(@"weather.last_update_format"), timeStr];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
