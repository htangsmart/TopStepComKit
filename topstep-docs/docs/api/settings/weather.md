---
sidebar_position: 6
title: 天气
---

# 天气（TSWeather）

TopStepComKit iOS SDK 天气模块提供了完整的天气信息管理功能，支持获取、推送和控制天气数据的显示。

## 前提条件

1. 已成功初始化 TopStepComKit SDK
2. 设备已连接并配对
3. 具有访问天气接口的权限

## 数据模型

### TSWeatherCity（城市信息）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `cityName` | `NSString *` | 城市名称（必需）。城市的名称，如"北京"、"上海" |
| `cityCode` | `NSString *` | 城市代码（可选）。城市的唯一标识符，通常遵循国家/国际标准，如中国北京的代码为"101010100" |
| `latitude` | `double` | 纬度（可选）。城市中心的纬度，使用十进制度数，范围：-90.0到90.0（南纬为负，北纬为正） |
| `longitude` | `double` | 经度（可选）。城市中心的经度，使用十进制度数，范围：-180.0到180.0（西经为负，东经为正） |
| `provinceName` | `NSString *` | 省份/州名（可选）。城市所在的省份或州的名称，例如"广东省"、"加利福尼亚州" |
| `countryName` | `NSString *` | 国家名称（可选）。城市所在的国家名称，例如"中国"、"美国" |

### TSWeatherCodeModel（天气代码）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `code` | `TSWeatherCode` | 天气代码枚举值，表示不同的天气状况 |
| `name` | `NSString *` | 天气状况名称。天气状况的文字描述，例如"晴天"、"阳光明媚"、"多云"等 |

### TSWeatherDay（每日天气）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `timestamp` | `NSTimeInterval` | 天气信息的时间戳。Unix时间戳（秒），表示该天气信息的记录时间 |
| `dayCode` | `TSWeatherCodeModel *` | 白天天气代码信息。包含天气代码和对应的描述信息 |
| `nightCode` | `TSWeatherCodeModel *` | 夜间天气代码信息。夜间的天气代码和对应的描述信息 |
| `curTemperature` | `SInt8` | 当前温度。当前温度，单位：摄氏度 |
| `minTemperature` | `SInt8` | 最低温度。当天的最低温度，单位：摄氏度 |
| `maxTemperature` | `SInt8` | 最高温度。当天的最高温度，单位：摄氏度 |
| `airpressure` | `NSInteger` | 气压。大气压力，单位：百帕 |
| `windScale` | `UInt8` | 风力等级。风力等级（0-18），0级无风至18级17级以上 |
| `windAngle` | `NSInteger` | 风向角度。风向角度（0-359），0/360：北，90：东，180：南，270：西 |
| `windSpeed` | `UInt8` | 风速。风速，单位：米/秒 |
| `humidity` | `UInt8` | 湿度。相对湿度百分比（0-100） |
| `uvIndex` | `UInt8` | 紫外线指数。紫外线强度指数（0：无、1-2：很弱、3-4：弱、5-6：中等、7-8：强、9-10：很强、11：极强） |
| `visibility` | `CGFloat` | 能见度。能见度，单位：米 |

### TSWeatherHour（每小时天气）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `timestamp` | `NSTimeInterval` | 天气信息的时间戳。Unix时间戳（秒），表示该天气信息的记录时间 |
| `weatherCode` | `TSWeatherCodeModel *` | 天气代码信息。白天的天气代码和对应的描述信息 |
| `temperature` | `SInt8` | 温度。当前温度，单位：摄氏度 |
| `windScale` | `NSInteger` | 风力等级。风力等级（0-18），0级无风至18级17级以上 |
| `uvIndex` | `NSInteger` | 紫外线指数。紫外线强度指数（0：无、1-2：很弱、3-4：弱、5-6：中等、7-8：强、9-10：很强、11：极强） |
| `visibility` | `NSInteger` | 能见度。能见度，单位：米 |
| `humidity` | `NSInteger` | 湿度。相对湿度百分比（0-100） |

### TopStepWeather（天气信息）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `timestamp` | `NSTimeInterval` | 天气信息的时间戳。Unix时间戳（秒），表示该天气信息的记录时间 |
| `updateTimestamp` | `NSTimeInterval` | 天气信息时间戳。天气信息最后更新时的Unix时间戳（秒） |
| `sunriseTime` | `NSTimeInterval` | 日出时间。Unix时间戳（秒），表示当天的日出时间，不可用时为0 |
| `sunsetTime` | `NSTimeInterval` | 日落时间。Unix时间戳（秒），表示当天的日落时间，不可用时为0 |
| `city` | `TSWeatherCity *` | 城市信息。包含正在报告天气的城市信息 |
| `dayCode` | `TSWeatherCodeModel *` | 天气代码信息。包含天气代码和对应的描述信息 |
| `nightCode` | `TSWeatherCodeModel *` | 夜间天气代码信息。夜间的天气代码和对应的描述信息，可选 |
| `minTemperature` | `SInt8` | 最低温度。当天的最低温度，单位：摄氏度 |
| `maxTemperature` | `SInt8` | 最高温度。当天的最高温度，单位：摄氏度 |
| `curTemperature` | `SInt8` | 当前温度。当前温度，单位：摄氏度 |
| `airpressure` | `NSInteger` | 气压。大气压力，单位：百帕（hPa） |
| `quality` | `NSInteger` | 空气质量。空气质量指数（AQI）数值（0：优、1：良、2：轻度污染、3：中度污染、4：重度污染、5：严重污染） |
| `humidity` | `NSInteger` | 湿度。相对湿度百分比（0-100） |
| `uvIndex` | `NSInteger` | 紫外线指数。紫外线强度指数（0：无、1-2：很弱、3-4：弱、5-6：中等、7-8：强、9-10：很强、11：极强） |
| `windAngle` | `CGFloat` | 风向角度。风向角度（0-359），0/360：北，90：东，180：南，270：西 |
| `windScale` | `NSInteger` | 风力等级。风力等级（0-18），0级无风至18级17级以上 |
| `windSpeed` | `CGFloat` | 风速。风速，单位：米/秒 |
| `visibility` | `CGFloat` | 能见度。能见度，单位：米 |
| `futhureSevenDays` | `NSArray<TSWeatherDay *> *` | 未来七天天气预报。未来七天的天气预报（包含当天），TSWeatherDay对象数组，按日期排序 |
| `futhure24Hours` | `NSArray<TSWeatherHour *> *` | 未来24小时天气预报。未来24小时的天气预报（包含当前小时），TSWeatherHour对象数组，按时间排序 |

## 枚举与常量

### TSWeatherCode（天气代码枚举）

| 枚举值 | 说明 |
|--------|------|
| `TSWeatherCodeUnknown` | 未知天气 |
| `TSWeatherCodeTornado` | 龙卷风 |
| `TSWeatherCodeTropicalStorm` | 热带风暴 |
| `TSWeatherCodeHurricane` | 飓风 |
| `TSWeatherCodeStrongStorms` | 强风暴 |
| `TSWeatherCodeThunderstorms` | 雷雨 |
| `TSWeatherCodeRainSnow` | 雨雪 |
| `TSWeatherCodeRainSleet` | 雨冰雹 |
| `TSWeatherCodeWintryMix` | 雨夹雪 |
| `TSWeatherCodeFreezingDrizzle` | 冻毛毛雨 |
| `TSWeatherCodeDrizzle` | 毛毛雨 |
| `TSWeatherCodeFreezingRain` | 冻雨 |
| `TSWeatherCodeShowers` | 阵雨 |
| `TSWeatherCodeRain` | 雨天 |
| `TSWeatherCodeFlurries` | 小雪 |
| `TSWeatherCodeSnowShowers` | 阵雪 |
| `TSWeatherCodeBlowingSnow` | 风吹雪 |
| `TSWeatherCodeSnow` | 雪 |
| `TSWeatherCodeHail` | 冰雹 |
| `TSWeatherCodeSleet` | 雨雪（霰） |
| `TSWeatherCodeDustSandstorm` | 扬尘、沙暴 |
| `TSWeatherCodeFoggy` | 有雾 |
| `TSWeatherCodeHaze` | 霾 |
| `TSWeatherCodeSmoke` | 烟雾 |
| `TSWeatherCodeBreezy` | 微风 |
| `TSWeatherCodeWindy` | 大风 |
| `TSWeatherCodeFrigidIceCrystals` | 冰珠 |
| `TSWeatherCodeOvercast` | 多云 |
| `TSWeatherCodeMostlyCloudyNight` | 夜间大部分多云 |
| `TSWeatherCodeMostlyCloudyDay` | 白天大部分多云 |
| `TSWeatherCodePartlyCloudyNight` | 夜间局部多云 |
| `TSWeatherCodePartlyCloudyDay` | 白天局部多云 |
| `TSWeatherCodeClearNight` | 夜间晴天 |
| `TSWeatherCodeSunnyDay` | 白天晴天 |
| `TSWeatherCodeFairNight` | 夜间晴时多云 |
| `TSWeatherCodeFairDay` | 白天晴时多云 |
| `TSWeatherCodeMixedRainHail` | 雨加冰雹 |
| `TSWeatherCodeHot` | 热 |
| `TSWeatherCodeIsolatedThunderstorms` | 局部雷暴 |
| `TSWeatherCodeScatteredStormDay` | 白天局部雷阵雨 |
| `TSWeatherCodeScatteredShowersDay` | 白天零星阵雨 |
| `TSWeatherCodeHeavyRain` | 暴雨 |
| `TSWeatherCodeScatteredSnowDay` | 白天零星阵雪 |
| `TSWeatherCodeHeavySnow` | 大雪 |
| `TSWeatherCodeBlizzard` | 暴风雪 |
| `TSWeatherCodeNotAvailable` | 无法使用 |
| `TSWeatherCodeScatteredShowersNight` | 夜间零星阵雨 |
| `TSWeatherCodeScatteredSnowNight` | 夜间零星阵雪 |
| `TSWeatherCodeScatteredStormNight` | 夜间局部雷阵雨 |

## 回调类型

| 回调类型 | 说明 |
|---------|------|
| `void (^)(TopStepWeather *_Nullable weather, NSError *_Nullable error)` | 获取天气信息的完成回调。weather：包含所有天气数据的天气信息模型；error：获取失败时的错误信息，成功时为nil |
| `void (^)(BOOL success, NSError *_Nullable error)` | 设置天气信息的完成回调。success：是否操作成功；error：操作失败时的错误信息，成功时为nil |
| `void (^)(BOOL enabled, NSError *_Nullable error)` | 获取天气开关状态的完成回调。enabled：天气功能是否启用；error：获取失败时的错误信息，成功时为nil |

## 接口方法

### 获取天气信息

获取设备中的当前天气信息，包括当前天气状况、每日预报、每小时预报和位置信息。

```objc
- (void)fetchWeatherWithCompletion:(void (^)(TopStepWeather *_Nullable weather, NSError *_Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TopStepWeather *_Nullable weather, NSError *_Nullable error)` | 获取完成的回调。weather：包含所有天气数据的天气信息模型；error：获取失败时的错误信息，成功时为nil |

**代码示例：**

```objc
id<TSWeatherInterface> weather = [TopStepComKit sharedInstance].weather;

[weather fetchWeatherWithCompletion:^(TopStepWeather * _Nullable weather, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取天气信息失败: %@", error.localizedDescription);
    } else {
        TSLog(@"城市: %@", weather.city.cityName);
        TSLog(@"当前温度: %d°C", weather.curTemperature);
        TSLog(@"最高温度: %d°C", weather.maxTemperature);
        TSLog(@"最低温度: %d°C", weather.minTemperature);
        TSLog(@"白天天气: %@", weather.dayCode.name);
        TSLog(@"夜间天气: %@", weather.nightCode.name);
        TSLog(@"风速: %.0f m/s", weather.windSpeed);
        TSLog(@"湿度: %ld%%", (long)weather.humidity);
    }
}];
```

### 推送天气信息

将天气信息同步到设备，包括当前天气状况、每日预报和每小时预报。

```objc
- (void)pushWeather:(TopStepWeather *)weather completion:(TSCompletionBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `weather` | `TopStepWeather *` | 包含所有天气数据的天气信息模型 |
| `completion` | `TSCompletionBlock` | 设置完成的回调。success：是否设置成功；error：设置失败时的错误信息，成功时为nil |

**代码示例：**

```objc
id<TSWeatherInterface> weather = [TopStepComKit sharedInstance].weather;

// 创建城市信息
TSWeatherCity *city = [TSWeatherCity cityWithName:@"北京"];
city.latitude = 39.9042;
city.longitude = 116.4074;
city.provinceName = @"北京市";
city.countryName = @"中国";

// 创建天气代码
TSWeatherCodeModel *dayCode = [TSWeatherCodeModel weatherCodeWithCode:TSWeatherCodeSunnyDay];
TSWeatherCodeModel *nightCode = [TSWeatherCodeModel weatherCodeWithCode:TSWeatherCodeClearNight];

// 创建天气信息
TopStepWeather *weather = [[TopStepWeather alloc] init];
weather.city = city;
weather.dayCode = dayCode;
weather.nightCode = nightCode;
weather.curTemperature = 25;
weather.minTemperature = 18;
weather.maxTemperature = 28;
weather.humidity = 65;
weather.windScale = 3;
weather.windSpeed = 5.0;
weather.airpressure = 1013;
weather.uvIndex = 6;
weather.visibility = 10000;
weather.sunriseTime = [[NSDate dateWithTimeIntervalSinceNow:3600*6] timeIntervalSince1970];
weather.sunsetTime = [[NSDate dateWithTimeIntervalSinceNow:3600*18] timeIntervalSince1970];

// 创建每日预报
TSWeatherDay *day1 = [TSWeatherDay modelWithDayCode:dayCode
                                            nightCode:nightCode
                                              curTemp:25
                                              minTemp:18
                                              maxTemp:28];
weather.futhureSevenDays = @[day1];

// 创建每小时预报
TSWeatherHour *hour1 = [TSWeatherHour modelWithCode:dayCode
                                         temperature:25
                                           windScale:3];
weather.futhure24Hours = @[hour1];

// 推送天气信息
[weather pushWeather:weather completion:^(BOOL success, NSError * _Nullable error) {
    if (error) {
        TSLog(@"推送天气信息失败: %@", error.localizedDescription);
    } else {
        TSLog(@"推送天气信息成功");
    }
}];
```

### 设置天气功能开关

控制设备是否显示天气信息。禁用时，设备将不会显示任何天气信息；启用时，如果有天气信息，设备将显示天气信息。

```objc
- (void)setWeatherEnable:(BOOL)enable completion:(TSCompletionBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `enable` | `BOOL` | 是否启用天气功能。YES：启用天气功能；NO：禁用天气功能 |
| `completion` | `TSCompletionBlock` | 设置完成的回调。success：是否设置成功；error：设置失败时的错误信息，成功时为nil |

**代码示例：**

```objc
id<TSWeatherInterface> weather = [TopStepComKit sharedInstance].weather;

// 启用天气功能
[weather setWeatherEnable:YES completion:^(BOOL success, NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置天气功能失败: %@", error.localizedDescription);
    } else {
        TSLog(@"天气功能已启用");
    }
}];
```

### 获取天气功能开关状态

获取设备中当前天气显示功能的状态，该状态表明设备当前是否正在显示天气信息。

```objc
- (void)fetchWeatherEnableWithCompletion:(void (^)(BOOL enabled, NSError *_Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(BOOL enabled, NSError *_Nullable error)` | 获取完成的回调。enabled：天气功能是否启用；error：获取失败时的错误信息，成功时为nil |

**代码示例：**

```objc
id<TSWeatherInterface> weather = [TopStepComKit sharedInstance].weather;

[weather fetchWeatherEnableWithCompletion:^(BOOL enabled, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取天气功能状态失败: %@", error.localizedDescription);
    } else {
        if (enabled) {
            TSLog(@"天气功能已启用");
        } else {
            TSLog(@"天气功能已禁用");
        }
    }
}];
```

## 注意事项

1. **权限要求**：在使用天气接口前，确保已获得访问天气接口的权限
2. **城市名称必需**：`TSWeatherCity` 中的 `cityName` 属性为必需，其他属性均为可选
3. **时间戳格式**：所有时间戳均为 Unix 时间戳（秒），不是毫秒
4. **温度单位**：所有温度值均使用摄氏度（°C）
5. **风力等级**：风力等级范围为 0-18，其中 0 级表示无风，18 级表示 17 级以上
6. **湿度范围**：湿度为相对湿度百分比，范围为 0-100
7. **紫外线指数**：紫外线指数范围为 0-11，0 表示无紫外线，11 表示极强紫外线
8. **空气质量**：空气质量指数（AQI）范围为 0-5，分别表示优、良、轻度污染、中度污染、重度污染和严重污染
9. **预报数据**：`futhureSevenDays` 包含未来七天的预报（包含当天），`futhure24Hours` 包含未来 24 小时的预报（包含当前小时），均按时间顺序排列
10. **夜间天气信息**：`nightCode` 属性为可选，如果夜间天气信息不可用可设为 nil