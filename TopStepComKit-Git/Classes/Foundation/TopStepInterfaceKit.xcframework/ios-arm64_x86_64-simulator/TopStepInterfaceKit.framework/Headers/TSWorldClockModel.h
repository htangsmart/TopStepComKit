//
//  TSWorldClockModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <Foundation/Foundation.h>
#import "TSComEnumDefines.h"
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

/**
 * @brief Unique identifier for the clock entry
 * @chinese 时钟条目的唯一标识符
 *
 * @discussion
 * [EN]: A unique ID assigned to each world clock entry, value range is 0-255
 * [CN]: 分配给每个世界时钟条目的唯一ID，取值范围为0-255
 *
 * @note
 * [EN]: The ID is a random number between 0 and 255
 * [CN]: ID是一个0到255之间的随机数
 */
@property (nonatomic, assign) UInt8 clockId;

/**
 * @brief Name of the city for the world clock
 * @chinese 世界时钟对应的城市名称
 *
 * @discussion
 * [EN]: The name of the city this world clock represents
 * [CN]: 该世界时钟所代表的城市名称
 */
@property (nonatomic, copy) NSString *cityName;

/**
 * @brief IANA time zone identifier for the world clock
 * @chinese 世界时钟的IANA时区标识符
 *
 * @discussion
 * [EN]: The IANA time zone identifier (e.g., "Asia/Shanghai", "America/New_York")
 * [CN]: IANA时区标识符（例如："Asia/Shanghai", "America/New_York"）
 */
@property (nonatomic, copy) NSString *timeZoneIdentifier;

/**
 * @brief UTC offset in seconds
 * @chinese UTC偏移量（秒）
 *
 * @discussion
 * [EN]: The UTC offset in seconds for this time zone, range is -43200 to +43200
 * [CN]: 该时区的UTC偏移量（以秒为单位），范围为-43200到+43200
 *
 * @note
 * [EN]: Positive values indicate time zones ahead of UTC (e.g., +28800 for UTC+8),
 *       negative values indicate time zones behind UTC (e.g., -18000 for UTC-5)
 * [CN]: 正值表示比UTC快（例如：+28800表示UTC+8），
 *       负值表示比UTC慢（例如：-18000表示UTC-5）
 */
@property (nonatomic, assign) NSInteger utcOffsetInSeconds;


/**
 * @brief Time display format
 * @chinese 时间显示格式
 *
 * @discussion
 * [EN]: The format used to display time
 * [CN]: 用于显示时间的格式
 *
 * @note
 * [EN]: TSTimeFormat12Hour for 12-hour format, TSTimeFormat24Hour for 24-hour format
 * [CN]: TSTimeFormat12Hour表示12小时制，TSTimeFormat24Hour 表示24小时制
 */
@property (nonatomic, assign) TSTimeFormat timeFormat NS_UNAVAILABLE;

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
 *
 * @warning
 * [EN]: This property is temporarily unavailable and should not be used.
 * [CN]: 此属性暂不可用，请勿使用。
 */
@property (nonatomic, assign) double longitude NS_UNAVAILABLE;

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
 *
 * @warning
 * [EN]: This property is temporarily unavailable and should not be used.
 * [CN]: 此属性暂不可用，请勿使用。
 */
@property (nonatomic, assign) double latitude NS_UNAVAILABLE;

/**
 * @brief Create a new world clock model instance
 * @chinese 创建一个新的世界时钟模型实例
 *
 * @param clockId The unique identifier for the clock entry (0-255)
 * @param cityName The name of the city
 * @param timeZoneIdentifier The IANA time zone identifier
 * @param utcOffsetInSeconds The UTC offset in seconds (-43200 to +43200)
 *
 * @return A new TPSWorldClockModel instance
 */
+ (instancetype)modelWithClockId:(UInt8)clockId
                        cityName:(NSString *)cityName
              timeZoneIdentifier:(NSString *)timeZoneIdentifier
              utcOffsetInSeconds:(NSInteger)utcOffsetInSeconds;


/**
 * @brief Create a world time model instance with geographic coordinates
 * @chinese 创建带有地理坐标的世界时间模型实例
 *
 * @return
 * EN: A new world time model instance with geographic coordinates, nil if required parameters are invalid
 * CN: 带有地理坐标的新世界时间模型实例，如果必传参数无效则返回nil
 */
+ (instancetype)modelWithClockId:(NSInteger)clockId
                        cityName:(NSString *)cityName
              timeZoneIdentifier:(NSString *)timeZoneIdentifier
              utcOffsetInSeconds:(NSInteger)utcOffsetInSeconds
                      timeFormat:(double)timeFormat
                       longitude:(double)longitude
                        latitude:(double)latitude;

/**
 * @brief Compare if two world clock models are equal
 * @chinese 比较两个世界时钟模型是否相同
 *
 * @param otherModel
 * EN: The other world clock model to compare with
 * CN: 要比较的另一个世界时钟模型
 *
 * @return
 * EN: YES if the models are equal, NO otherwise
 * CN: 如果模型相同返回YES，否则返回NO
 *
 * @discussion
 * [EN]: Two world clock models are considered equal if they have the same clockId, cityName, timeZone, and UTC values.
 * [CN]: 如果两个世界时钟模型具有相同的clockId、cityName、timeZone和UTC值，则认为它们相同。
 */
- (BOOL)isEqualToWorldClockModel:(TSWorldClockModel *)otherModel;

@end

NS_ASSUME_NONNULL_END
