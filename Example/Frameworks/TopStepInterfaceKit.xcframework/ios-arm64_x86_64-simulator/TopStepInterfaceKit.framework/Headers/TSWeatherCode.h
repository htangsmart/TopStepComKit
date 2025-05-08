//
//  TSWeatherCode.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Weather type enumeration (Based on Yahoo Weather codes)
 * @chinese 天气类型枚举（基于Yahoo天气代码）
 */
typedef NS_ENUM(NSInteger, TSWeatherType) {
    // 未知天气 Unknown Weather
    TSWeatherTypeUnknown               = -1,   // 未知 Unknown

    // 极端天气 Extreme Weather
    TSWeatherTypeTornado               = 0,    // 龙卷风 Tornado
    TSWeatherTypeTropicalStorm         = 1,    // 热带风暴 Tropical Storm
    TSWeatherTypeHurricane             = 2,    // 飓风 Hurricane
    TSWeatherTypeStrongStorms          = 3,    // 强风暴 Strong Storms
    TSWeatherTypeThunderstorms         = 4,    // 雷雨 Thunderstorms

    // 混合降水 Mixed Precipitation
    TSWeatherTypeRainSnow              = 5,    // 雨雪 Rain Snow
    TSWeatherTypeRainSleet             = 6,    // 雨冰雹 Rain Sleet
    TSWeatherTypeWintryMix             = 7,    // 雨夹雪 Wintry Mix

    // 小雨 Light Rain
    TSWeatherTypeFreezingDrizzle       = 8,    // 冻毛毛雨 Freezing Drizzle
    TSWeatherTypeDrizzle               = 9,    // 毛毛雨 Drizzle
    TSWeatherTypeFreezingRain          = 10,   // 冻雨 Freezing Rain
    TSWeatherTypeShowers               = 11,   // 阵雨 Showers
    TSWeatherTypeRain                  = 12,   // 雨天 Rain

    // 雪 Snow
    TSWeatherTypeFlurries              = 13,   // 小雪 Flurries
    TSWeatherTypeSnowShowers           = 14,   // 阵雪 Snow Showers
    TSWeatherTypeBlowingSnow           = 15,   // 风吹雪 Blowing/Drifting Snow
    TSWeatherTypeSnow                  = 16,   // 雪 Snow

    // 其他降水 Other Precipitation
    TSWeatherTypeHail                  = 17,   // 冰雹 Hail
    TSWeatherTypeSleet                 = 18,   // 雨雪 Sleet

    // 能见度天气 Visibility Weather
    TSWeatherTypeDustSandstorm         = 19,   // 扬尘、沙暴 Blowing Dust/Sandstorm
    TSWeatherTypeFoggy                 = 20,   // 有雾 Foggy
    TSWeatherTypeHaze                  = 21,   // 霾 Haze
    TSWeatherTypeSmoke                 = 22,   // 烟雾 Smoke

    // 风 Wind
    TSWeatherTypeBreezy                = 23,   // 微风 Breezy
    TSWeatherTypeWindy                 = 24,   // 大风 Windy

    // 寒冷天气 Cold Weather
    TSWeatherTypeFrigidIceCrystals     = 25,   // 冰珠 Frigid/Ice Crystals

    // 多云 Cloudy
    TSWeatherTypeCloudy                = 26,   // 多云 Cloudy
    TSWeatherTypeMostlyCloudyNight     = 27,   // 夜间大部分多云 Mostly Cloudy (night)
    TSWeatherTypeMostlyCloudyDay       = 28,   // 白天多云间晴 Mostly Cloudy (day)
    TSWeatherTypePartlyCloudyNight     = 29,   // 夜间局部多云 Partly Cloudy (night)
    TSWeatherTypePartlyCloudyDay       = 30,   // 白天局部多云 Partly Cloudy (day)

    // 晴 Clear/Sunny
    TSWeatherTypeClearNight            = 31,   // 夜间晴天 Clear Night
    TSWeatherTypeSunnyDay              = 32,   // 晴天 Sunny Day
    TSWeatherTypeFairNight             = 33,   // 夜间晴时多云 Fair/Mostly Clear
    TSWeatherTypeFairDay               = 34,   // 白天晴时多云 Fair/Mostly Sunny

    // 混合天气 Mixed Weather
    TSWeatherTypeMixedRainHail         = 35,   // 雨加冰雹 Mixed Rain and Hail
    TSWeatherTypeHot                   = 36,   // 热 Hot

    // 局部天气 Isolated Weather
    TSWeatherTypeIsolatedThunderstorms = 37,   // 局部雷暴 Isolated Thunderstorms
    TSWeatherTypeScatteredStormDay     = 38,   // 白天局部雷阵雨 Scattered Thunderstorms (day)
    TSWeatherTypeScatteredShowersDay   = 39,   // 白天零星阵雨 Scattered Showers (day)

    // 强降水 Heavy Precipitation
    TSWeatherTypeHeavyRain             = 40,   // 暴雨 Heavy Rain
    TSWeatherTypeScatteredSnowDay      = 41,   // 白天零星阵雪 Scattered Snow Showers (day)
    TSWeatherTypeHeavySnow             = 42,   // 大雪 Heavy Snow
    TSWeatherTypeBlizzard              = 43,   // 暴风雪 Blizzard

    // 其他 Others
    TSWeatherTypeNotAvailable          = 44,   // 无法使用 Not Available
    TSWeatherTypeScatteredShowersNight = 45,   // 夜间零星阵雨 Scattered Showers (night)
    TSWeatherTypeScatteredSnowNight    = 46,   // 夜间零星阵雪 Scattered Snow Showers (night)
    TSWeatherTypeScatteredStormNight   = 47,   // 夜间局部雷阵雨 Scattered Thunderstorms (night)
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
@interface TSWeatherCode : NSObject

/**
 * @brief Weather type
 * @chinese 天气类型
 *
 * @discussion
 * EN: Weather type enumeration value
 *     Represents different weather conditions
 * CN: 天气类型枚举值
 *     表示不同的天气状况
 */
@property (nonatomic, assign) TSWeatherType type;

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
 * @brief Create weather code with type
 * @chinese 使用天气类型创建天气代码
 *
 * @param type Weather type / 天气类型
 * @return Weather code instance / 天气代码实例
 */
+ (instancetype)weatherCodeWithType:(TSWeatherType)type;

/**
 * @brief Get weather name for type
 * @chinese 获取天气类型对应的名称
 *
 * @param type Weather type / 天气类型
 * @return Weather name / 天气名称
 */
+ (NSString *)weatherNameForType:(TSWeatherType)type;

@end

NS_ASSUME_NONNULL_END
