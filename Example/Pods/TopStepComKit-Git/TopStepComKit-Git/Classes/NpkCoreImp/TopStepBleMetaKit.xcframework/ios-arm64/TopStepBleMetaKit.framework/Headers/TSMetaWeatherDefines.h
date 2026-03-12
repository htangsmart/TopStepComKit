//
//  TSMetaWeatherDefines.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/11/17.
//

#ifndef TSMetaWeatherDefines_h
#define TSMetaWeatherDefines_h

#import <Foundation/Foundation.h>

#pragma mark - Weather Category (天气大类)

typedef NS_ENUM(NSInteger, TSWeatherCategory) {
    TSWeatherCategoryUnknown        = -1,   // 未知的 Unknown
    TSWeatherCategoryClear           = 0,    // 晴 Clear
    TSWeatherCategoryCloudy         = 1,    // 多云 Cloudy
    TSWeatherCategoryOvercast        = 2,    // 阴 Overcast
    TSWeatherCategoryRain            = 3,    // 雨 Rain
    TSWeatherCategoryHeavyRain       = 4,    // 大雨 Heavy Rain
    TSWeatherCategoryRainShower      = 5,    // 阵雨 Rain Shower
    TSWeatherCategorySnow            = 6,    // 雪 Snow
    TSWeatherCategoryHeavySnow       = 7,    // 大雪 Heavy Snow
    TSWeatherCategorySnowShower      = 8,    // 阵雪 Snow Shower
    TSWeatherCategoryHaze            = 9,    // 雾霾 Haze
    TSWeatherCategorySandDust        = 10,   // 沙尘，浮尘 Sand Dust
    TSWeatherCategorySmokeFog        = 11,   // 烟，雾 Smoke Fog
    TSWeatherCategoryWind            = 12,   // 风 Wind
    TSWeatherCategoryHailSleet       = 13,   // 冰雹，冰晶，霰 Hail Sleet
    TSWeatherCategoryFreezingRain    = 14,   // 冻雨,雨夹雪,雨夹冰雹 Freezing Rain
    TSWeatherCategoryThunderShower   = 15    // 雷阵雨 Thunder Shower
};

#pragma mark - Weather Subtype (天气子类型)

typedef NS_ENUM(NSInteger, TSWeatherSubtype) {
    // 未知天气 Unknown Weather
    TSWeatherSubtypeUnknown               = -1,   // 未知 Unknown
    
    // 极端天气 Extreme Weather
    TSWeatherSubtypeTornado               = 0,    // 龙卷风 Tornado
    TSWeatherSubtypeTropicalStorm         = 1,    // 热带风暴 Tropical Storm
    TSWeatherSubtypeHurricane             = 2,    // 飓风 Hurricane
    TSWeatherSubtypeStrongStorms          = 3,    // 强风暴 Strong Storms
    TSWeatherSubtypeThunderstorms         = 4,    // 雷雨 Thunderstorms
    
    // 混合降水 Mixed Precipitation
    TSWeatherSubtypeRainSnow              = 5,    // 雨雪 Rain Snow
    TSWeatherSubtypeRainSleet             = 6,    // 雨冰雹 Rain Sleet
    TSWeatherSubtypeWintryMix             = 7,    // 雨夹雪 Wintry Mix
    
    // 小雨 Light Rain
    TSWeatherSubtypeFreezingDrizzle       = 8,    // 冻毛毛雨 Freezing Drizzle
    TSWeatherSubtypeDrizzle               = 9,    // 毛毛雨 Drizzle
    TSWeatherSubtypeFreezingRain          = 10,   // 冻雨 Freezing Rain
    TSWeatherSubtypeShowers               = 11,   // 阵雨 Showers
    TSWeatherSubtypeRain                  = 12,   // 雨天 Rain
    
    // 雪 Snow
    TSWeatherSubtypeFlurries              = 13,   // 小雪 Flurries
    TSWeatherSubtypeSnowShowers           = 14,   // 阵雪 Snow Showers
    TSWeatherSubtypeBlowingSnow           = 15,   // 风吹雪 Blowing/Drifting Snow
    TSWeatherSubtypeSnow                  = 16,   // 雪 Snow
    
    // 其他降水 Other Precipitation
    TSWeatherSubtypeHail                  = 17,   // 冰雹 Hail
    TSWeatherSubtypeSleet                 = 18,   // 雨雪（霰） Sleet
    
    // 能见度天气 Visibility Weather
    TSWeatherSubtypeDustSandstorm         = 19,   // 扬尘、沙暴 Blowing Dust/Sandstorm
    TSWeatherSubtypeFoggy                 = 20,   // 有雾 Foggy
    TSWeatherSubtypeHaze                  = 21,   // 霾 Haze
    TSWeatherSubtypeSmoke                 = 22,   // 烟雾 Smoke
    
    // 风 Wind
    TSWeatherSubtypeBreezy                = 23,   // 微风 Breezy
    TSWeatherSubtypeWindy                 = 24,   // 大风 Windy
    
    // 寒冷天气 Cold Weather
    TSWeatherSubtypeFrigidIceCrystals     = 25,   // 冰珠 Frigid/Ice Crystals
    
    // 多云 Cloudy
    TSWeatherSubtypeOvercast              = 26,   // 多云 Overcast
    TSWeatherSubtypeMostlyCloudyNight     = 27,   // 夜间大部分多云 Mostly Cloudy (night)
    TSWeatherSubtypeMostlyCloudyDay       = 28,   // 白天大部分多云 Mostly Cloudy (day)
    TSWeatherSubtypePartlyCloudyNight     = 29,   // 夜间局部多云 Partly Cloudy (night)
    TSWeatherSubtypePartlyCloudyDay       = 30,   // 白天局部多云 Partly Cloudy (day)
    
    // 晴 Clear/Sunny
    TSWeatherSubtypeClearNight            = 31,   // 夜间晴天 Clear Night
    TSWeatherSubtypeSunnyDay              = 32,   // 白天晴天 Sunny Day
    TSWeatherSubtypeFairNight             = 33,   // 夜间晴时多云 Fair/Mostly Clear
    TSWeatherSubtypeFairDay               = 34,   // 白天晴时多云 Fair/Mostly Sunny
    
    // 混合天气 Mixed Weather
    TSWeatherSubtypeMixedRainHail         = 35,   // 雨加冰雹 Mixed Rain and Hail
    TSWeatherSubtypeHot                   = 36,   // 热 Hot
    
    // 局部天气 Isolated Weather
    TSWeatherSubtypeIsolatedThunderstorms = 37,   // 局部雷暴 Isolated Thunderstorms
    TSWeatherSubtypeScatteredStormDay     = 38,   // 白天局部雷阵雨 Scattered Thunderstorms (day)
    TSWeatherSubtypeScatteredShowersDay   = 39,   // 白天零星阵雨 Scattered Showers (day)
    
    // 强降水 Heavy Precipitation
    TSWeatherSubtypeHeavyRain             = 40,   // 暴雨 Heavy Rain
    TSWeatherSubtypeScatteredSnowDay      = 41,   // 白天零星阵雪 Scattered Snow Showers (day)
    TSWeatherSubtypeHeavySnow             = 42,   // 大雪 Heavy Snow
    TSWeatherSubtypeBlizzard              = 43,   // 暴风雪 Blizzard
    
    // 其他 Others
    TSWeatherSubtypeNotAvailable          = 44,   // 无法使用 Not Available
    TSWeatherSubtypeScatteredShowersNight = 45,   // 夜间零星阵雨 Scattered Showers (night)
    TSWeatherSubtypeScatteredSnowNight    = 46,   // 夜间零星阵雪 Scattered Snow Showers (night)
    TSWeatherSubtypeScatteredStormNight   = 47    // 夜间局部雷阵雨 Scattered Thunderstorms (night)
};

#endif /* TSMetaWeatherDefines_h */
