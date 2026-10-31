//
//  TSUserInfoModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/13.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief User gender enumeration
 * @chinese 用户性别枚举
 *
 * @discussion
 * [EN]: Represents Unknown, Female, or Male.
 * [CN]: 表示未知、女性或男性。
 */
typedef NS_ENUM(NSInteger, TSUserGender) {
    /**
     * @brief Unknown gender
     * @chinese 未知性别
     */
    TSUserGenderUnknown = -1,
    
    /**
     * @brief Female gender
     * @chinese 女性
     */
    TSUserGenderFemale = 0,
    
    /**
     * @brief Male gender
     * @chinese 男性
     */
    TSUserGenderMale = 1
};

/**
 * @brief User information model
 * @chinese 用户信息模型
 *
 * @discussion
 * [EN]: Stores the user's identity and profile information.
 * [CN]: 保存用户标识和个人资料。
 */
@interface TSUserInfoModel : TSKitBaseModel

/**
 * @brief Application-side user identifier
 * @chinese 应用侧用户标识
 *
 * @discussion
 * [EN]: Identifies the user associated with this profile.
 * [CN]: 标识本资料所属的用户。
 *
 * @note
 * [EN]: Assigned by the application.
 * [CN]: 由应用设置。
 */
@property (nonatomic, copy) NSString *userId;

/**
 * @brief User name
 * @chinese 用户姓名
 *
 * @discussion
 * [EN]: The user's display name.
 * [CN]: 用户的显示名称。
 *
 * @note
 * [EN]: May be empty when no name is provided.
 * [CN]: 未提供姓名时可为空。
 */
@property (nonatomic, copy) NSString *name;

/**
 * @brief User gender
 * @chinese 用户性别
 *
 * @discussion
 * [EN]: Uses the TSUserGender enumeration.
 * [CN]: 使用 TSUserGender 枚举表示用户性别。
 *
 * @note
 * [EN]: Unknown=-1, Female=0, Male=1.
 * [CN]: 未知=-1，女性=0，男性=1。
 */
@property (nonatomic, assign) TSUserGender gender;

/**
 * @brief User age
 * @chinese 用户年龄
 *
 * @discussion
 * [EN]: The user's age in whole years.
 * [CN]: 用户年龄，单位为整岁。
 *
 * @note
 * [EN]: Defaults to 0.
 * [CN]: 默认为 0。
 */
@property (nonatomic, assign) UInt8 age;

/**
 * @brief User birthday as a calendar date
 * @chinese 用户生日，表示日历日期
 *
 * @discussion
 * [EN]: A calendar date string, for example "1990/01/01".
 * [CN]: 日历日期字符串，例如 "1990/01/01"。
 *
 * @note
 * [EN]: Defaults to an empty string. Nil, an empty string, and "0" indicate
 *       that no birthday is provided.
 * [CN]: 默认为空字符串；nil、空字符串和 "0" 表示未提供生日。
 */
@property (nonatomic, copy, nullable) NSString *birthday;

/**
 * @brief User information update time in Unix seconds
 * @chinese 用户信息更新时间，单位为 Unix 秒
 *
 * @discussion
 * [EN]: Seconds elapsed since 1970-01-01 00:00:00 UTC.
 * [CN]: 自 1970-01-01 00:00:00 UTC 起经过的秒数。
 *
 * @note
 * [EN]: Defaults to 0 when unspecified. Set the current timestamp when editing
 *       the profile; fractional seconds are allowed.
 * [CN]: 未提供时默认为 0。编辑资料时应设置为当前时间戳，允许包含小数秒。
 */
@property (nonatomic, assign) NSTimeInterval updateTime;

/**
 * @brief User height
 * @chinese 用户身高
 *
 * @discussion
 * [EN]: The user's height in centimeters.
 * [CN]: 用户身高，单位为厘米。
 *
 * @note
 * [EN]: May include a fractional part.
 * [CN]: 可包含小数部分。
 */
@property (nonatomic, assign) CGFloat height;

/**
 * @brief User weight
 * @chinese 用户体重
 *
 * @discussion
 * [EN]: The user's weight in kilograms.
 * [CN]: 用户体重，单位为千克。
 *
 * @note
 * [EN]: May include a fractional part.
 * [CN]: 可包含小数部分。
 */
@property (nonatomic, assign) CGFloat weight;

/**
 * @brief Validate the basic user information values
 * @chinese 验证用户信息的基本有效性
 *
 * @return
 * [EN]: Returns nil if validation succeeds, or an NSError if validation fails
 * [CN]: 验证成功返回 nil，验证失败返回 NSError 对象
 *
 * @discussion
 * [EN]: Checks defined gender values, the birthday value type, and finite
 *       nonnegative height, weight, and update time. Does not impose a birthday
 *       format, whole-second precision, or product input ranges.
 *
 * [CN]: 只检查已定义的性别值、生日值类型，以及身高、体重、更新时间是否为
 *       有限非负数；不限制生日格式、小数秒或产品输入范围。
 */
- (nullable NSError *)validate;

/**
 * @brief Validate the standard device user information range
 * @chinese 验证标准设备用户信息范围
 *
 * @return
 * [EN]: Returns nil if validation succeeds, or an NSError if validation fails
 * [CN]: 验证成功返回 nil，验证失败返回 NSError 对象
 *
 * @discussion
 * [EN]: Performs validate, then checks age 0-127, height 0-256 cm, and weight
 *       0-512 kg. Application callers should handle the setting result.
 *
 * [CN]: 先执行 validate，再检查年龄 0-127 岁、身高 0-256 厘米、体重
 *       0-512 千克；应用调用方应处理设置结果。
 */
- (nullable NSError *)validateStandardDeviceRange;

/**
 * @brief Calculate the BMI value
 * @chinese 计算 BMI 值
 *
 * @return
 * [EN]: BMI value, or -1 if calculation fails
 * [CN]: BMI 值，计算失败时返回 -1
 *
 * @discussion
 * [EN]: BMI = weight (kg) / height (m)². Returns -1 when height or weight is
 *       nonfinite or nonpositive, or when the result cannot be represented.
 *       The calculated value does not participate in setting validation.
 *
 * [CN]: BMI = 体重（kg）/ 身高（m）²。身高或体重非有限、非正数，或结果
 *       无法表示时返回 -1。计算结果不参与用户资料设置校验。
 */
- (float)calculateBMI;

@end

NS_ASSUME_NONNULL_END
