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
 * [EN]: Defines the gender values carried by user information. Unknown may be
 *       returned when a device has no recognized value; setting only accepts
 *       Female or Male.
 *
 * [CN]: 定义用户资料携带的性别值。设备没有可识别值时，读取结果可能为未知；
 *       设置时只接受女性或男性。
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
 * [EN]: Stores user profile data shared by the SDK. `validate` checks whether
 *       the data has a transport-safe structure. The provider selected by the
 *       connected device validates its setting range before transmission.
 *
 * [CN]: 存储 SDK 共用的用户资料数据。`validate` 负责校验数据是否具备可安全
 *       传输的结构，当前连接设备对应的 Provider 在发送前校验设置范围。
 */
@interface TSUserInfoModel : TSKitBaseModel

/**
 * @brief Application-side user identifier
 * @chinese 应用侧用户标识
 *
 * @discussion
 * [EN]: Metadata carried by the common model. Current device profile payloads
 *       do not transmit this field.
 * [CN]: 统一模型携带的应用侧元数据，当前设备资料设置载荷不传输此字段。
 */
@property (nonatomic, copy) NSString *userId;

/**
 * @brief User name
 * @chinese 用户姓名
 *
 * @discussion
 * [EN]: Application-side display name carried by the common model. Current
 *       device profile payloads do not transmit this field.
 * [CN]: 统一模型携带的应用侧显示名称，当前设备资料设置载荷不传输此字段。
 */
@property (nonatomic, copy) NSString *name;

/**
 * @brief User gender
 * @chinese 用户性别
 *
 * @discussion
 * [EN]: Uses `TSUserGender`. A read operation may return
 *       `TSUserGenderUnknown`, but setting user information only accepts
 *       `TSUserGenderFemale` or `TSUserGenderMale`.
 *
 * [CN]: 使用 `TSUserGender`。读取设备资料时可能返回
 *       `TSUserGenderUnknown`，设置用户资料时只接受
 *       `TSUserGenderFemale` 或 `TSUserGenderMale`。
 */
@property (nonatomic, assign) TSUserGender gender;

/**
 * @brief User age
 * @chinese 用户年龄
 *
 * @discussion
 * [EN]: Age in whole years. The property uses `UInt8`; `validate` does not
 *       impose an age range. Fit, NPK, and Fw accept 0-127 through
 *       `validateStandardDeviceRange`. Other providers validate their own limits.
 *
 * [CN]: 用户年龄，单位为整岁。属性类型为 `UInt8`，`validate` 不限制年龄范围。
 *       Fit、NPK、Fw 通过 `validateStandardDeviceRange` 接受 0-127 岁；
 *       其他 Provider 按各自协议范围校验。
 */
@property (nonatomic, assign) UInt8 age;

/**
 * @brief User height
 * @chinese 用户身高
 *
 * @discussion
 * [EN]: Height in centimeters. `validate` requires a finite nonnegative value.
 *       Fit, NPK, and Fw accept 0-256 cm through
 *       `validateStandardDeviceRange`. Other providers validate their own limits.
 *
 * [CN]: 用户身高，单位为厘米。`validate` 要求该值有限且不小于 0。
 *       Fit、NPK、Fw 通过 `validateStandardDeviceRange` 接受 0-256 厘米；
 *       其他 Provider 按各自协议范围校验。
 */
@property (nonatomic, assign) CGFloat height;

/**
 * @brief User weight
 * @chinese 用户体重
 *
 * @discussion
 * [EN]: Weight in kilograms. `validate` requires a finite nonnegative value.
 *       Fit, NPK, and Fw accept 0-512 kg through
 *       `validateStandardDeviceRange`. Other providers validate their own limits.
 *
 * [CN]: 用户体重，单位为千克。`validate` 要求该值有限且不小于 0。
 *       Fit、NPK、Fw 通过 `validateStandardDeviceRange` 接受 0-512 千克；
 *       其他 Provider 按各自协议范围校验。
 */
@property (nonatomic, assign) CGFloat weight;

/**
 * @brief Validate the transport structure of user information
 * @chinese 验证用户信息的传输结构
 *
 * @return
 * [EN]: Returns nil if validation succeeds, or an NSError if validation fails
 * [CN]: 验证成功返回 nil，验证失败返回 NSError 对象
 *
 * @discussion
 * [EN]: Gender must be Female or Male, and height and weight must be finite
 *       nonnegative values. This method does not validate age, provider ranges,
 *       human plausibility, or BMI policy.
 *
 * [CN]: 性别必须为女性或男性，身高和体重必须为有限的非负数。本方法不校验
 *       年龄、Provider 设置范围、人体合理性或 BMI 策略。
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
 * [EN]: Performs `validate`, then checks the range shared by Fit, NPK, and Fw:
 *       age 0-127, height 0-256 cm, and weight 0-512 kg. This method is intended
 *       for those provider implementations; app callers should handle the error
 *       returned by `setUserInfo:completion:` instead of selecting a provider rule.
 *
 * [CN]: 先执行 `validate`，再校验 Fit、NPK、Fw 共用范围：年龄 0-127 岁、
 *       身高 0-256 厘米、体重 0-512 千克。本方法供这三个 Provider 实现使用；
 *       App 调用方应处理 `setUserInfo:completion:` 返回的错误，不应自行选择
 *       Provider 校验规则。
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
