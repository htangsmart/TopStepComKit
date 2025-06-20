//
//  TSUserInfoModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMPersonalInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSUserInfoModel (SJ)

/**
 * @brief Convert WMPersonalInfoModel to TSUserInfoModel
 * @chinese 将WMPersonalInfoModel转换为TSUserInfoModel
 *
 * @param wmModel 
 * EN: WMPersonalInfoModel object to be converted
 * CN: 需要转换的WMPersonalInfoModel对象
 *
 * @return 
 * EN: Converted TSUserInfoModel object, nil if conversion fails
 * CN: 转换后的TSUserInfoModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts WMPersonalInfoModel to TSUserInfoModel:
 *     - Converts height and weight directly
 *     - Maps gender enums appropriately
 *     - Calculates age from birthDate
 * CN: 该方法将WMPersonalInfoModel转换为TSUserInfoModel：
 *     - 直接转换身高和体重
 *     - 适当映射性别枚举
 *     - 根据出生日期计算年龄
 */
+ (nullable TSUserInfoModel *)modelWithWMPersonalInfoModel:(nullable WMPersonalInfoModel *)wmModel;

/**
 * @brief Convert TSUserInfoModel to WMPersonalInfoModel
 * @chinese 将TSUserInfoModel转换为WMPersonalInfoModel
 *
 * @param tsModel 
 * EN: TSUserInfoModel object to be converted
 * CN: 需要转换的TSUserInfoModel对象
 *
 * @return 
 * EN: Converted WMPersonalInfoModel object, nil if conversion fails
 * CN: 转换后的WMPersonalInfoModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts TSUserInfoModel to WMPersonalInfoModel:
 *     - Converts height and weight directly
 *     - Maps gender enums appropriately
 *     - Calculates birthDate from age (sets to January 1st of the calculated year)
 * CN: 该方法将TSUserInfoModel转换为WMPersonalInfoModel：
 *     - 直接转换身高和体重
 *     - 适当映射性别枚举
 *     - 根据年龄计算出生日期（设置为计算年份的1月1日）
 */
+ (nullable WMPersonalInfoModel *)wmModelWithTSUserInfoModel:(nullable TSUserInfoModel *)tsModel;

@end

NS_ASSUME_NONNULL_END
