//
//  TSCity.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief City model for weather information
 * @chinese 天气信息的城市模型
 *
 * @discussion
 * EN: This model represents a city for weather information
 *     Only cityName is required, all other properties are optional
 *     Used for weather information queries and display
 * CN: 该模型表示天气信息的城市
 *     仅城市名称(cityName)为必需属性，其他属性都是可选的
 *     用于天气信息查询和显示
 */
@interface TSCity : NSObject

/**
 * @brief City name (Required)
 * @chinese 城市名称（必需）
 *
 * @discussion
 * EN: The name of the city, e.g., "Beijing", "Shanghai"
 *     This is the only required property
 * CN: 城市的名称，如"北京"、"上海"
 *     这是唯一的必需属性
 */
@property (nonatomic, copy) NSString *cityName;

/**
 * @brief City code (Optional)
 * @chinese 城市代码（可选）
 *
 * @discussion
 * EN: Unique identifier for the city, usually follows national/international standards
 *     e.g., "101010100" for Beijing in China
 * CN: 城市的唯一标识符，通常遵循国家/国际标准
 *     例如，中国北京的代码为"101010100"
 */
@property (nonatomic, copy, nullable) NSString *cityCode;

/**
 * @brief Latitude (Optional)
 * @chinese 纬度（可选）
 *
 * @discussion
 * EN: Latitude of the city center in decimal degrees
 *     Range: -90.0 to 90.0 (negative for South, positive for North)
 * CN: 城市中心的纬度，使用十进制度数
 *     范围：-90.0到90.0（南纬为负，北纬为正）
 */
@property (nonatomic, assign) double latitude;

/**
 * @brief Longitude (Optional)
 * @chinese 经度（可选）
 *
 * @discussion
 * EN: Longitude of the city center in decimal degrees
 *     Range: -180.0 to 180.0 (negative for West, positive for East)
 * CN: 城市中心的经度，使用十进制度数
 *     范围：-180.0到180.0（西经为负，东经为正）
 */
@property (nonatomic, assign) double longitude;

/**
 * @brief Province/State name (Optional)
 * @chinese 省份/州名（可选）
 *
 * @discussion
 * EN: Name of the province or state where the city is located
 *     e.g., "Guangdong", "California"
 * CN: 城市所在的省份或州的名称
 *     例如，"广东省"、"加利福尼亚州"
 */
@property (nonatomic, copy, nullable) NSString *provinceName;

/**
 * @brief Country name (Optional)
 * @chinese 国家名称（可选）
 *
 * @discussion
 * EN: Name of the country where the city is located
 *     e.g., "China", "United States"
 * CN: 城市所在的国家名称
 *     例如，"中国"、"美国"
 */
@property (nonatomic, copy, nullable) NSString *countryName;

/**
 * @brief Time zone (Optional)
 * @chinese 时区（可选）
 *
 * @discussion
 * EN: Time zone identifier for the city
 *     e.g., "Asia/Shanghai", "America/Los_Angeles"
 * CN: 城市的时区标识符
 *     例如，"Asia/Shanghai"、"America/Los_Angeles"
 */
@property (nonatomic, copy, nullable) NSString *timeZone;

/**
 * @brief Create a city model with name (Required)
 * @chinese 使用城市名称创建城市模型（必需）
 *
 * @param cityName City name / 城市名称
 * @return A new city model instance / 新的城市模型实例
 */
+ (instancetype)cityWithName:(NSString *)cityName;

/**
 * @brief Create a city model with name and location (Optional)
 * @chinese 使用城市名称和位置创建城市模型（可选）
 *
 * @param cityName City name / 城市名称
 * @param latitude Latitude / 纬度
 * @param longitude Longitude / 经度
 * @return A new city model instance / 新的城市模型实例
 */
+ (instancetype)cityWithName:(NSString *)cityName
                    latitude:(double)latitude
                   longitude:(double)longitude;

@end

NS_ASSUME_NONNULL_END
