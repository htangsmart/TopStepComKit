//
//  TSWorldClockModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief World time model
 * @chinese 世界时间模型
 * 
 * @discussion 
 * EN: Used to represent timezone information and time display for different cities
 * CN: 用于表示不同城市的时区信息和时间显示
 */
@interface TSWorldClockModel : NSObject

@property (nonatomic,strong) NSString * colockId;

/**
 * City name
 * @chinese 城市名称
 * 
 * EN: For example: Beijing, Tokyo, London, etc.
 * CN: 例如：北京、东京、伦敦等
 */
@property (nonatomic, copy) NSString *cityName;

/**
 * Timezone identifier
 * @chinese 时区标识
 * 
 * EN: For example: Asia/Shanghai, Asia/Tokyo, Europe/London, etc.
 * CN: 例如：Asia/Shanghai、Asia/Tokyo、Europe/London等
 */
@property (nonatomic, copy) NSString *timeZone;

/**
 * UTC offset
 * @chinese UTC偏移量
 * 
 * EN: For example: +8.0 for UTC+8, -5.0 for UTC-5
 * CN: 例如：东八区为+8.0，西五区为-5.0
 */
@property (nonatomic, assign) float UTC;

/**
 * Daylight Saving Time flag
 * @chinese 夏令时标志
 * 
 * EN: YES indicates DST is active, NO indicates it's not
 * CN: YES表示当前处于夏令时，NO表示不是
 */
@property (nonatomic, assign) BOOL isDST;

/**
 * Time display format
 * @chinese 时间显示格式
 * 
 * EN: 12 for 12-hour format, 24 for 24-hour format
 * CN: 12表示12小时制，24表示24小时制
 */
@property (nonatomic, assign) NSInteger timeFormat;

/**
 * @brief Longitude of the city
 * @chinese 城市经度
 *
 * @discussion
 * [EN]: The longitude coordinate of the city. East longitude is positive, west longitude is negative.
 * [CN]: 城市的经度坐标。东经为正值，西经为负值。
 *
 * @note
 * [EN]: Range from -180.0 to 180.0 degrees.
 * [CN]: 范围从-180.0到180.0度。
 */
@property (nonatomic, assign) double longitude;

/**
 * @brief Latitude of the city
 * @chinese 城市纬度
 *
 * @discussion
 * [EN]: The latitude coordinate of the city. North latitude is positive, south latitude is negative.
 * [CN]: 城市的纬度坐标。北纬为正值，南纬为负值。
 *
 * @note
 * [EN]: Range from -90.0 to 90.0 degrees.
 * [CN]: 范围从-90.0到90.0度。
 */
@property (nonatomic, assign) double latitude;

/**
 * Create a world time model instance
 * @chinese 创建世界时间模型实例
 * 
 * @param cityName 
 * EN: City name
 * CN: 城市名称
 * 
 * @param timeZone 
 * EN: Timezone identifier
 * CN: 时区标识
 * 
 * @param UTC 
 * EN: UTC offset value
 * CN: UTC偏移量
 * 
 * @return 
 * EN: A new world time model instance
 * CN: 新的世界时间模型实例
 */
+ (instancetype)modelWithCityName:(NSString *)cityName
                        timeZone:(NSString *)timeZone
                            UTC:(float)UTC;

/**
 * Create a world time model instance with geographic coordinates
 * @chinese 创建带有地理坐标的世界时间模型实例
 * 
 * @param cityName 
 * EN: City name
 * CN: 城市名称
 * 
 * @param timeZone 
 * EN: Timezone identifier
 * CN: 时区标识
 * 
 * @param UTC 
 * EN: UTC offset value
 * CN: UTC偏移量
 * 
 * @param longitude 
 * EN: Longitude of the city (degrees)
 * CN: 城市经度（度）
 * 
 * @param latitude 
 * EN: Latitude of the city (degrees)
 * CN: 城市纬度（度）
 * 
 * @return 
 * EN: A new world time model instance with geographic coordinates
 * CN: 带有地理坐标的新世界时间模型实例
 */
+ (instancetype)modelWithCityName:(NSString *)cityName
                        timeZone:(NSString *)timeZone
                            UTC:(float)UTC
                      longitude:(double)longitude
                       latitude:(double)latitude;

@end

NS_ASSUME_NONNULL_END
