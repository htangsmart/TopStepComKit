//
//  TSWorldClockModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

/**
 * @brief World clock model for managing time zone information
 * @chinese 世界时钟模型，用于管理时区信息
 *
 * @discussion
 * [EN]: This class manages world clock information including:
 *       - Time zone selection and management
 *       - Local time conversion
 *       - City and region information
 * 
 * [CN]: 该类管理世界时钟信息，包括：
 *       - 时区选择和管理
 *       - 本地时间转换
 *       - 城市和地区信息
 */

#import "TSKitBaseModel.h"
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
@interface TSWorldClockModel : TSKitBaseModel

/**
 * @brief Unique identifier for the clock entry
 * @chinese 时钟条目的唯一标识符
 *
 * @discussion
 * [EN]: A unique ID for each world clock entry. Value range is [0, supportMaxWorldClockCount - 1].
 * - When calling addWorldClock:completion:, leave this field unset (0 is acceptable);
 *   the SDK will automatically assign the first available clockId.
 * - When calling deleteWorldClockWithId:completion:, use the clockId read from
 *   the list returned by getAllWorldClocksCompletion:.
 *
 * [CN]: 每个世界时钟条目的唯一 ID，取值范围为 [0, supportMaxWorldClockCount - 1]。
 * - 调用 addWorldClock:completion: 时无需设置此字段（填 0 即可），
 *   SDK 会自动分配第一个可用的 clockId。
 * - 调用 deleteWorldClockWithId:completion: 时，需使用从
 *   getAllWorldClocksCompletion: 返回列表中读取的 clockId。
 */
@property (nonatomic, assign) UInt8 clockId;

/**
 * @brief City name
 * @chinese 城市名称
 *
 * @discussion
 * [EN]: The name of the city for the world clock.
 * Maximum byte length is determined by TSWorldClockInterface's supportMaxCityNameLength.
 * Note: One Chinese character typically takes 3 bytes in UTF-8 encoding.
 * [CN]: 世界时钟对应的城市名称。
 * 最大字节长度由 TSWorldClockInterface 的 supportMaxCityNameLength 决定。
 * 注意：一个中文字符通常在 UTF-8 编码中占用 3 字节。
 */
@property (nonatomic, copy) NSString *cityName;

/**
 * @brief Time zone identifier
 * @chinese 时区标识符
 *
 * @discussion
 * [EN]: The time zone identifier (e.g., "Asia/Shanghai")
 * [CN]: 时区标识符（例如："Asia/Shanghai"）
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
 * @brief Validate an array of world clock models
 * @chinese 校验世界时钟模型数组
 *
 * @param worldClocks
 * EN: Array of TSWorldClockModel to validate
 * CN: 要校验的 TSWorldClockModel 数组
 *
 * @param maxCityNameLength
 * EN: Maximum byte length for cityName. Pass 0 to skip the length check.
 * CN: cityName 的最大字节长度。传 0 表示不校验长度。
 *
 * @return
 * EN: NSError if any model fails validation, nil if all pass
 * CN: 任意一个模型校验失败返回 NSError，全部通过返回 nil
 */
+ (NSError * _Nullable)validateWorldClocks:(NSArray<TSWorldClockModel *> *)worldClocks
                         maxCityNameLength:(NSInteger)maxCityNameLength;

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

// Disable init, new, and copy methods
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
