//
//  TSWeatherCodeModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Weather code enumeration (Based on Yahoo Weather codes)
 * @chinese 天气代码枚举（基于Yahoo天气代码）
 */
typedef NS_ENUM(NSInteger, TSWeatherCode) {
    // 未知天气 Unknown Weather
    TSWeatherCodeUnknown               = -1,   // 未知 Unknown

    // 极端天气 Extreme Weather
    TSWeatherCodeTornado               = 0,    // 龙卷风 Tornado
    TSWeatherCodeTropicalStorm         = 1,    // 热带风暴 Tropical Storm
    TSWeatherCodeHurricane             = 2,    // 飓风 Hurricane
    TSWeatherCodeStrongStorms          = 3,    // 强风暴 Strong Storms
    TSWeatherCodeThunderstorms         = 4,    // 雷雨 Thunderstorms

    // 混合降水 Mixed Precipitation
    TSWeatherCodeRainSnow              = 5,    // 雨雪 Rain Snow
    TSWeatherCodeRainSleet             = 6,    // 雨冰雹 Rain Sleet
    TSWeatherCodeWintryMix             = 7,    // 雨夹雪 Wintry Mix

    // 小雨 Light Rain
    TSWeatherCodeFreezingDrizzle       = 8,    // 冻毛毛雨 Freezing Drizzle
    TSWeatherCodeDrizzle               = 9,    // 毛毛雨 Drizzle
    TSWeatherCodeFreezingRain          = 10,   // 冻雨 Freezing Rain
    TSWeatherCodeShowers               = 11,   // 阵雨 Showers
    TSWeatherCodeRain                  = 12,   // 雨天 Rain

    // 雪 Snow
    TSWeatherCodeFlurries              = 13,   // 小雪 Flurries
    TSWeatherCodeSnowShowers           = 14,   // 阵雪 Snow Showers
    TSWeatherCodeBlowingSnow           = 15,   // 风吹雪 Blowing/Drifting Snow
    TSWeatherCodeSnow                  = 16,   // 雪 Snow

    // 其他降水 Other Precipitation
    TSWeatherCodeHail                  = 17,   // 冰雹 Hail
    TSWeatherCodeSleet                 = 18,   // 雨雪（霰） Sleet

    // 能见度天气 Visibility Weather
    TSWeatherCodeDustSandstorm         = 19,   // 扬尘、沙暴 Blowing Dust/Sandstorm
    TSWeatherCodeFoggy                 = 20,   // 有雾 Foggy
    TSWeatherCodeHaze                  = 21,   // 霾 Haze
    TSWeatherCodeSmoke                 = 22,   // 烟雾 Smoke

    // 风 Wind
    TSWeatherCodeBreezy                = 23,   // 微风 Breezy
    TSWeatherCodeWindy                 = 24,   // 大风 Windy

    // 寒冷天气 Cold Weather
    TSWeatherCodeFrigidIceCrystals     = 25,   // 冰珠 Frigid/Ice Crystals

    // 多云 Cloudy
    TSWeatherCodeOvercast              = 26,   // 多云 Overcast
    TSWeatherCodeMostlyCloudyNight     = 27,   // 夜间大部分多云 Mostly Cloudy (night)
    TSWeatherCodeMostlyCloudyDay       = 28,   // 白天大部分多云 Mostly Cloudy (day)
    TSWeatherCodePartlyCloudyNight     = 29,   // 夜间局部多云 Partly Cloudy (night)
    TSWeatherCodePartlyCloudyDay       = 30,   // 白天局部多云 Partly Cloudy (day)

    // 晴 Clear/Sunny
    TSWeatherCodeClearNight            = 31,   // 夜间晴天 Clear Night
    TSWeatherCodeSunnyDay              = 32,   // 白天晴天 Sunny Day
    TSWeatherCodeFairNight             = 33,   // 夜间晴时多云 Fair/Mostly Clear
    TSWeatherCodeFairDay               = 34,   // 白天晴时多云 Fair/Mostly Sunny

    // 混合天气 Mixed Weather
    TSWeatherCodeMixedRainHail         = 35,   // 雨加冰雹 Mixed Rain and Hail
    TSWeatherCodeHot                   = 36,   // 热 Hot

    // 局部天气 Isolated Weather
    TSWeatherCodeIsolatedThunderstorms = 37,   // 局部雷暴 Isolated Thunderstorms
    TSWeatherCodeScatteredStormDay     = 38,   // 白天局部雷阵雨 Scattered Thunderstorms (day)
    TSWeatherCodeScatteredShowersDay   = 39,   // 白天零星阵雨 Scattered Showers (day)

    // 强降水 Heavy Precipitation
    TSWeatherCodeHeavyRain             = 40,   // 暴雨 Heavy Rain
    TSWeatherCodeScatteredSnowDay      = 41,   // 白天零星阵雪 Scattered Snow Showers (day)
    TSWeatherCodeHeavySnow             = 42,   // 大雪 Heavy Snow
    TSWeatherCodeBlizzard              = 43,   // 暴风雪 Blizzard

    // 其他 Others
    TSWeatherCodeNotAvailable          = 44,   // 无法使用 Not Available
    TSWeatherCodeScatteredShowersNight = 45,   // 夜间零星阵雨 Scattered Showers (night)
    TSWeatherCodeScatteredSnowNight    = 46,   // 夜间零星阵雪 Scattered Snow Showers (night)
    TSWeatherCodeScatteredStormNight   = 47,   // 夜间局部雷阵雨 Scattered Thunderstorms (night)
    
    
};

/**
 * @brief Weather code model
 * @chinese 天气代码模型
 *
 * @discussion
 * EN: This model represents a weather condition code and its description.
 *     Used to identify and describe different weather conditions.
 *     For example: code 0 = Clear, code 1 = Sunny, etc.
 * CN: 该模型表示天气状况代码及其描述。
 *     用于标识和描述不同的天气状况。
 *     例如：代码0 = 晴天，代码1 = 阳光明媚等。
 */
@interface TSWeatherCodeModel : TSKitBaseModel

/**
 * @brief Weather code
 * @chinese 天气代码
 *
 * @discussion
 * EN: Weather code enumeration value
 *     Represents different weather conditions
 * CN: 天气代码枚举值
 *     表示不同的天气状况
 */
@property (nonatomic, assign) TSWeatherCode code;

/**
 * @brief Weather condition name
 * @chinese 天气状况名称
 *
 * @discussion
 * EN: Text description of the weather condition
 *     For example: "Clear", "Sunny", "Cloudy", etc.
 * CN: 天气状况的文字描述
 *     例如："晴天"、"阳光明媚"、"多云"等
 */
@property (nonatomic, copy) NSString *name;

/**
 * @brief Create weather code with code
 * @chinese 使用天气代码创建天气代码实例
 *
 * @param code Weather code / 天气代码
 * @return Weather code instance / 天气代码实例
 */
+ (instancetype)weatherCodeWithCode:(TSWeatherCode)code;

/**
 * @brief Get weather name for code
 * @chinese 获取天气代码对应的名称
 *
 * @param code Weather code / 天气代码
 * @return Weather name / 天气名称
 */
+ (NSString *)weatherNameForCode:(TSWeatherCode)code;

@end

NS_ASSUME_NONNULL_END
