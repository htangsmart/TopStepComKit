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
 * EN: Defines the possible gender values for user information:
 *     - Unknown: Gender not specified
 *     - Female: Female gender
 *     - Male: Male gender
 *     Used in user profile and health data calculations.
 *
 * CN: 定义用户信息中可能的性别值：
 *     - 未知：未指定性别
 *     - 女性：女性性别
 *     - 男性：男性性别
 *     用于用户档案和健康数据计算。
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
 * EN: This model stores and transfers basic user information,
 * CN: 该模型用于存储和传递用户的基本信息，
 */
@interface TSUserInfoModel : TSKitBaseModel

/**
 * @brief User name
 * @chinese 用户姓名
 *
 * @discussion
 * EN: The name of the user.
 *     Maximum length is 32 characters.
 *
 * CN: 用户的姓名。
 *     最大长度为32个字符。
 */
@property (nonatomic, copy) NSString *name;

/**
 * @brief User gender
 * @chinese 用户性别
 *
 * @discussion
 * EN: Gender of the user, using TSUserGender enum:
 *     - TSUserGenderUnknown: Gender not specified
 *     - TSUserGenderFemale: Female
 *     - TSUserGenderMale: Male
 *
 * CN: 用户的性别，使用 TSUserGender 枚举：
 *     - TSUserGenderUnknown: 未知性别
 *     - TSUserGenderFemale: 女性
 *     - TSUserGenderMale: 男性
 */
@property (nonatomic, assign) TSUserGender gender;

/**
 * @brief User age
 * @chinese 用户年龄
 *
 * @discussion
 * EN: Age of the user in years.
 *     Valid range: 3-120 years
 *
 * CN: 用户的年龄，以岁为单位。
 *     有效范围：3-120岁
 */
@property (nonatomic, assign) UInt8 age;

/**
 * @brief User height
 * @chinese 用户身高
 *
 * @discussion
 * EN: Height of the user in centimeters (cm).
 *     Valid range: 80-220 cm
 *
 * CN: 用户的身高，单位为厘米(cm)。
 *     有效范围：80-220厘米
 */
@property (nonatomic, assign) CGFloat height;

/**
 * @brief User weight
 * @chinese 用户体重
 *
 * @discussion
 * EN: Weight of the user in kilograms (kg).
 *     Valid range: 20-200 kg
 *
 * CN: 用户的体重，单位为千克(kg)。
 *     有效范围：20-200千克
 */
@property (nonatomic, assign) CGFloat weight;

/**
 * @brief Validate user information
 * @chinese 验证用户信息是否合法
 *
 * @return 
 * EN: Returns nil if validation succeeds, NSError object if validation fails
 * CN: 验证成功返回nil，验证失败返回NSError对象
 *
 * @discussion
 * EN: Validates if:
 *     - Age is within valid range (3-120 years)
 *     - Height is within valid range (80-220 cm)
 *     - Weight is within valid range (20-200 kg)
 *     - BMI is within reasonable range (13-80)
 *       Note: WHO standards for BMI classification:
 *       - Severe thinness: < 16
 *       - Moderate thinness: 16-16.9
 *       - Mild thinness: 17-18.4
 *       - Normal range: 18.5-24.9
 *       - Overweight: 25-29.9
 *       - Obese class I: 30-34.9
 *       - Obese class II: 35-39.9
 *       - Obese class III: ≥ 40
 *     Returns nil if all validations pass
 *     Returns NSError with detailed reason if any validation fails
 *
 * CN: 验证内容包括：
 *     - 年龄是否在有效范围内（3-120岁）
 *     - 身高是否在有效范围内（80-220厘米）
 *     - 体重是否在有效范围内（20-200千克）
 *     - BMI是否在合理范围内（13-80）
 *       注：WHO的BMI分类标准：
 *       - 重度消瘦：< 16
 *       - 中度消瘦：16-16.9
 *       - 轻度消瘦：17-18.4
 *       - 正常范围：18.5-24.9
 *       - 超重：25-29.9
 *       - 肥胖I度：30-34.9
 *       - 肥胖II度：35-39.9
 *       - 肥胖III度：≥ 40
 *     所有验证通过时返回nil
 *     任何验证失败时返回包含具体原因的NSError对象
 */
- (nullable NSError *)validate;

/**
 * @brief Calculate BMI value
 * @chinese 计算BMI值
 *
 * @return 
 * EN: BMI value, -1 if calculation fails
 * CN: BMI值，计算失败时返回-1
 *
 * @discussion
 * EN: BMI = weight(kg) / height(m)²
 *     Returns -1 if height or weight is invalid
 *
 * CN: BMI = 体重(kg) / 身高(m)²
 *     当身高或体重无效时返回-1
 */
- (float)calculateBMI;

@end

NS_ASSUME_NONNULL_END
