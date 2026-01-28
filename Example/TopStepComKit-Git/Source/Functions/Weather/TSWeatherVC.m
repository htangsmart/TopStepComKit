//
//  TSWeatherVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/18.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSWeatherVC.h"

@interface TSWeatherVC ()

@end

@implementation TSWeatherVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"天气设置";
}

#pragma mark - Callback

- (void)registerCallBack {
}

#pragma mark - TableView DataSource & Delegate

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"打开天气"],
        [TSValueModel valueWithName:@"关闭天气"],
        [TSValueModel valueWithName:@"获取天气开关状态"],
        [TSValueModel valueWithName:@"设置天气数据"],
        [TSValueModel valueWithName:@"获取天气数据"],

    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self openWeather];
    }else if (indexPath.row == 1){
        [self closeWeather];
    }else if (indexPath.row == 2){
        [self getWeatherEnable];
    }else if(indexPath.row == 3){
        [self setWeather];
    } else{
        [self getWeatherInfo];
    }
}

#pragma mark - Private Methods

// 生成随机温度
- (NSInteger)randomTemperatureWithMin:(NSInteger)min max:(NSInteger)max {
    return min + arc4random_uniform((int)(max - min + 1));
}

// 生成随机天气代码
- (TSWeatherCode)randomWeatherCode {
    // 选择一些常见的天气代码
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

// 创建示例天气数据
- (TopStepWeather *)weather {
    TSLog(@"[TSWeatherVC] 开始构造天气数据");
    
    // 创建天气模型
    TopStepWeather *weatherModel = [[TopStepWeather alloc] init];
    
    // 设置城市信息
    TSWeatherCity *city = [TSWeatherCity cityWithName:@"深圳"];
    city.latitude = 22.5431;
    city.longitude = 114.0579;
    city.provinceName = @"广东省";
    city.countryName = @"中国";
    weatherModel.city = city;
    
    // 设置时间戳
    weatherModel.updateTimestamp = [[NSDate date] timeIntervalSince1970];
    
    // 创建今天的天气
    
    weatherModel.dayCode = [TSWeatherCodeModel weatherCodeWithCode:[self randomWeatherCode]];
//    weatherModel.nightCode = [TSWeatherCode weatherCodeWithCode:[self randomWeatherCode]];
//    weatherModel.curTemperature = [self randomTemperatureWithMin:20 max:30];
//    weatherModel.minTemperature = [self randomTemperatureWithMin:15 max:20];
//    weatherModel.maxTemperature = [self randomTemperatureWithMin:30 max:35];
    weatherModel.airpressure = 1013;
    weatherModel.windScale = arc4random_uniform(6);  // 0-5级风
    weatherModel.windAngle = arc4random_uniform(360);
    weatherModel.windSpeed = arc4random_uniform(20);
    weatherModel.humidity = 40 + arc4random_uniform(41);  // 40-80%
    weatherModel.uvIndex = arc4random_uniform(11);  // 0-10
    weatherModel.visibility = 10000 + arc4random_uniform(20000);  // 10-30km
    
    // 打印今天的天气详情
    TSLog(@"[TSWeatherVC] 今天天气详情：");
    TSLog(@"[TSWeatherVC] - 白天天气: %@", weatherModel.dayCode.name);
//    TSLog(@"[TSWeatherVC] - 夜间天气: %@", weatherModel.nightCode.name);
    TSLog(@"[TSWeatherVC] - 当前温度: %ld℃", (long)weatherModel.curTemperature);
    TSLog(@"[TSWeatherVC] - 温度范围: %ld℃ ~ %ld℃", (long)weatherModel.minTemperature, (long)weatherModel.maxTemperature);
    TSLog(@"[TSWeatherVC] - 风力等级: %ld级", (long)weatherModel.windScale);
    TSLog(@"[TSWeatherVC] - 风向角度: %ld°", (long)weatherModel.windAngle);
    TSLog(@"[TSWeatherVC] - 风速: %ld m/s", (long)weatherModel.windSpeed);
    TSLog(@"[TSWeatherVC] - 湿度: %ld%%", (long)weatherModel.humidity);
    TSLog(@"[TSWeatherVC] - 紫外线指数: %ld", (long)weatherModel.uvIndex);
    TSLog(@"[TSWeatherVC] - 能见度: %.1f km", weatherModel.visibility/1000.0);
    
    // 创建未来7天天气预报
    NSMutableArray *futureWeather = [NSMutableArray array];
    TSLog(@"[TSWeatherVC] 未来7天天气预报：");
    for (int i = 0; i < 6; i++) {
        TSWeatherDay *dayModel = [[TSWeatherDay alloc] init];
        dayModel.dayCode = [TSWeatherCodeModel weatherCodeWithCode:[self randomWeatherCode]];
        dayModel.nightCode = [TSWeatherCodeModel weatherCodeWithCode:[self randomWeatherCode]];

        dayModel.minTemperature = [self randomTemperatureWithMin:15 max:20];
        dayModel.maxTemperature = [self randomTemperatureWithMin:25 max:35];
        dayModel.windScale = arc4random_uniform(6);
        [futureWeather addObject:dayModel];
        
        // 打印每天的天气预报
        TSLog(@"[TSWeatherVC] 第%d天:", i + 1);
        TSLog(@"[TSWeatherVC] - 白天天气: %@", dayModel.dayCode.name);
        TSLog(@"[TSWeatherVC] - 夜间天气: %@", dayModel.nightCode.name);
        TSLog(@"[TSWeatherVC] - 温度范围: %ld℃ ~ %ld℃", (long)dayModel.minTemperature, (long)dayModel.maxTemperature);
        TSLog(@"[TSWeatherVC] - 风力等级: %ld级", (long)dayModel.windScale);
    }
    weatherModel.futhureSevenDays = futureWeather;
    
    // 创建24小时天气预报
    NSMutableArray *hourlyWeather = [NSMutableArray array];
//    for (int i = 0; i < 24; i++) {
//        TSWeatherHourModel *hourModel = [[TSWeatherHourModel alloc] init];
//        hourModel.weatherCode = [TSWeatherCodeModel weatherCodeWithCode:[self randomWeatherCode]];
//
//        hourModel.temperature = [self randomTemperatureWithMin:18 max:32];
//        hourModel.windScale = arc4random_uniform(6);
//        hourModel.uvIndex = arc4random_uniform(11);
//        hourModel.visibility = 10000 + arc4random_uniform(20000);
//        [hourlyWeather addObject:hourModel];
//
//        TSLog(@"[TSWeatherVC] 第%d小时:", i + 1);
//        TSLog(@"[TSWeatherVC] - 小时天气: %@", hourModel.weatherCode.name);
//        TSLog(@"[TSWeatherVC] - 温度范围: %ld℃", (long)hourModel.temperature);
//        TSLog(@"[TSWeatherVC] - 风力等级: %ld级", (long)hourModel.windScale);
//
//    }
    weatherModel.futhure24Hours = hourlyWeather;
    TSLog(@"[TSWeatherVC] 天气数据构造完成：");
    TSLog(@"[TSWeatherVC] 城市: %@", weatherModel.city.cityName);
    TSLog(@"[TSWeatherVC] 未来天气预报: %lu天", (unsigned long)weatherModel.futhureSevenDays.count);
    TSLog(@"[TSWeatherVC] 小时预报: %lu小时", (unsigned long)weatherModel.futhure24Hours.count);
    
    return weatherModel;
}

#pragma mark - Network Methods

- (void)openWeather {
    TSLog(@"[TSWeatherVC] 开始打开天气功能");
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] weather] setWeatherEnable:YES completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        if (!success) {
            TSLog(@"[TSWeatherVC] 打开天气功能失败: %@", error.localizedDescription);
            [TSToast showText:error.localizedDescription onView:weakSelf.view dismissAfterDelay:2.0f];
            return;
        }
        
        TSLog(@"[TSWeatherVC] 打开天气功能成功");
        [TSToast showText:@"打开天气功能成功" onView:weakSelf.view dismissAfterDelay:1.0f];
    }];
}

- (void)closeWeather {
    TSLog(@"[TSWeatherVC] 开始关闭天气功能");
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] weather] setWeatherEnable:NO completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        if (!success) {
            TSLog(@"[TSWeatherVC] 关闭天气功能失败: %@", error.localizedDescription);
            [TSToast showText:error.localizedDescription onView:weakSelf.view dismissAfterDelay:2.0f];
            return;
        }
        
        TSLog(@"[TSWeatherVC] 关闭天气功能成功");
        [TSToast showText:@"关闭天气功能成功" onView:weakSelf.view dismissAfterDelay:1.0f];
    }];
}

- (void)getWeatherEnable{
    
    TSLog(@"[TSWeatherVC] 获取天气开关状态");
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self) weakSelf = self;
    
    [[[TopStepComKit sharedInstance] weather] fetchWeatherEnableWithCompletion:^(BOOL enabled, NSError * _Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        if (error) {
            TSLog(@"[TSWeatherVC] 获取天气状态失败: %@", error.localizedDescription);
            [TSToast showText:error.localizedDescription onView:weakSelf.view dismissAfterDelay:2.0f];
            return;
        }
        
        TSLog(@"[TSWeatherVC] 获取天气状态成功");
        [TSToast showText:@"获取天气状态成功" onView:weakSelf.view dismissAfterDelay:1.0f];

    }];
}

- (void)getWeatherInfo{
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] weather] fetchWeatherWithCompletion:^(TopStepWeather * _Nullable weather, NSError * _Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        if (error) {
            TSLog(@"[TSWeatherVC] 获取天气状态失败: %@", error.localizedDescription);
            [TSToast showText:error.localizedDescription onView:weakSelf.view dismissAfterDelay:2.0f];
            return;
        }
        [TSToast showText:@"获取天气成功" onView:weakSelf.view dismissAfterDelay:1.0f];
        TSLog(@"天气信息获取成功：%@",weather.debugDescription);
    }];
}

- (void)setWeather {
    TSLog(@"[TSWeatherVC] 开始设置天气信息");
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] weather] pushWeather:[self weather] completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        if (!success) {
            TSLog(@"[TSWeatherVC] 设置天气失败: %@", error.localizedDescription);
            [TSToast showText:error.localizedDescription onView:weakSelf.view dismissAfterDelay:2.0f];
            return;
        }
        
        TSLog(@"[TSWeatherVC] 设置天气成功");
        [TSToast showText:@"设置天气成功" onView:weakSelf.view dismissAfterDelay:1.0f];
    }];
}

@end
