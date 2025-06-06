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

// 生成随机天气类型
- (TSWeatherType)randomWeatherType {
    // 选择一些常见的天气类型
    TSWeatherType commonTypes[] = {
        TSWeatherTypeSunnyDay,
        TSWeatherTypeCloudy,
        TSWeatherTypePartlyCloudyDay,
        TSWeatherTypeRain,
        TSWeatherTypeShowers,
        TSWeatherTypeThunderstorms
    };
    int count = sizeof(commonTypes) / sizeof(commonTypes[0]);
    return commonTypes[arc4random_uniform(count)];
}

// 创建示例天气数据
- (TSWeatherModel *)weather {
    TSLog(@"[TSWeatherVC] 开始构造天气数据");
    
    // 创建天气模型
    TSWeatherModel *weatherModel = [[TSWeatherModel alloc] init];
    
    // 设置城市信息
    TSCity *city = [TSCity cityWithName:@"深圳"];
    city.latitude = 22.5431;
    city.longitude = 114.0579;
    city.provinceName = @"广东省";
    city.countryName = @"中国";
    weatherModel.city = city;
    
    // 设置时间戳
    weatherModel.updateTimestamp = [[NSDate date] timeIntervalSince1970];
    
    // 创建今天的天气
    TSWeatherDayModel *today = [[TSWeatherDayModel alloc] init];
    today.weatherCode = [TSWeatherCode weatherCodeWithType:[self randomWeatherType]];
    today.nightCode = [TSWeatherCode weatherCodeWithType:[self randomWeatherType]];
    today.curTemperature = [self randomTemperatureWithMin:20 max:30];
    today.minTemperature = [self randomTemperatureWithMin:15 max:20];
    today.maxTemperature = [self randomTemperatureWithMin:30 max:35];
    today.airpressure = 1013;
    today.windScale = arc4random_uniform(6);  // 0-5级风
    today.windAngle = arc4random_uniform(360);
    today.windSpeed = arc4random_uniform(20);
    today.humidity = 40 + arc4random_uniform(41);  // 40-80%
    today.uvIndex = arc4random_uniform(11);  // 0-10
    today.visibility = 10000 + arc4random_uniform(20000);  // 10-30km
    weatherModel.today = today;
    
    // 打印今天的天气详情
    TSLog(@"[TSWeatherVC] 今天天气详情：");
    TSLog(@"[TSWeatherVC] - 白天天气: %@", today.weatherCode.name);
    TSLog(@"[TSWeatherVC] - 夜间天气: %@", today.nightCode.name);
    TSLog(@"[TSWeatherVC] - 当前温度: %ld℃", (long)today.curTemperature);
    TSLog(@"[TSWeatherVC] - 温度范围: %ld℃ ~ %ld℃", (long)today.minTemperature, (long)today.maxTemperature);
    TSLog(@"[TSWeatherVC] - 风力等级: %ld级", (long)today.windScale);
    TSLog(@"[TSWeatherVC] - 风向角度: %ld°", (long)today.windAngle);
    TSLog(@"[TSWeatherVC] - 风速: %ld m/s", (long)today.windSpeed);
    TSLog(@"[TSWeatherVC] - 湿度: %ld%%", (long)today.humidity);
    TSLog(@"[TSWeatherVC] - 紫外线指数: %ld", (long)today.uvIndex);
    TSLog(@"[TSWeatherVC] - 能见度: %.1f km", today.visibility/1000.0);
    
    // 创建未来7天天气预报
    NSMutableArray *futureWeather = [NSMutableArray array];
    TSLog(@"[TSWeatherVC] 未来7天天气预报：");
    for (int i = 0; i < 7; i++) {
        TSWeatherDayModel *dayModel = [[TSWeatherDayModel alloc] init];
        dayModel.weatherCode = [TSWeatherCode weatherCodeWithType:[self randomWeatherType]];
        dayModel.nightCode = [TSWeatherCode weatherCodeWithType:[self randomWeatherType]];
        dayModel.minTemperature = [self randomTemperatureWithMin:15 max:20];
        dayModel.maxTemperature = [self randomTemperatureWithMin:25 max:35];
        dayModel.windScale = arc4random_uniform(6);
        [futureWeather addObject:dayModel];
        
        // 打印每天的天气预报
        TSLog(@"[TSWeatherVC] 第%d天:", i + 1);
        TSLog(@"[TSWeatherVC] - 白天天气: %@", dayModel.weatherCode.name);
        TSLog(@"[TSWeatherVC] - 夜间天气: %@", dayModel.nightCode.name);
        TSLog(@"[TSWeatherVC] - 温度范围: %ld℃ ~ %ld℃", (long)dayModel.minTemperature, (long)dayModel.maxTemperature);
        TSLog(@"[TSWeatherVC] - 风力等级: %ld级", (long)dayModel.windScale);
    }
    weatherModel.futhureSevenDays = futureWeather;
    
    // 创建24小时天气预报
    NSMutableArray *hourlyWeather = [NSMutableArray array];
    for (int i = 0; i < 24; i++) {
        TSWeatherHourModel *hourModel = [[TSWeatherHourModel alloc] init];
        hourModel.weatherCode = [TSWeatherCode weatherCodeWithType:[self randomWeatherType]];
        hourModel.temperature = [self randomTemperatureWithMin:18 max:32];
        hourModel.windScale = arc4random_uniform(6);
        hourModel.uvIndex = arc4random_uniform(11);
        hourModel.visibility = 10000 + arc4random_uniform(20000);
        [hourlyWeather addObject:hourModel];
        
        TSLog(@"[TSWeatherVC] 第%d小时:", i + 1);
        TSLog(@"[TSWeatherVC] - 小时天气: %@", hourModel.weatherCode.name);
        TSLog(@"[TSWeatherVC] - 温度范围: %ld℃", (long)hourModel.temperature);
        TSLog(@"[TSWeatherVC] - 风力等级: %ld级", (long)hourModel.windScale);

    }
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
    [[[TopStepComKit sharedInstance] weather] getWeatherEnableCompletion:^(BOOL enabled, NSError * _Nullable error) {
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
    [[[TopStepComKit sharedInstance] weather] getWeatherCompletion:^(TSWeatherModel * _Nullable weather, NSError * _Nullable error) {
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
    [[[TopStepComKit sharedInstance] weather] setWeather:[self weather] completion:^(BOOL success, NSError * _Nullable error) {
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
