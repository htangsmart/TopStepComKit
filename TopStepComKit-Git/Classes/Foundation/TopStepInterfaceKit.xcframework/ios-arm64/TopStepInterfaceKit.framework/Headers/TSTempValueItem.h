//
//  TSTempValueItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/4/17.
//

#import "TSHealthValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Temperature values captured in one sampling event
 * @chinese 单次采样事件的体温数据
 *
 * @discussion
 * [EN]: Body and wrist temperatures from the same event are stored in one item. A value of 0
 *       means that the corresponding component is unavailable.
 * [CN]: 同一次采样的体温和腕温保存在同一个条目中，数值 0 表示对应分量缺失。
 */
@interface TSTempValueItem : TSHealthValueItem <NSCopying>

/**
 * @brief Body temperature in degrees Celsius
 * @chinese 体温值，单位为摄氏度
 *
 * @discussion
 * [EN]: A positive value is valid. A value of 0 means body temperature is unavailable.
 * [CN]: 正数表示有效体温，0 表示缺失。
 */
@property (nonatomic, assign) CGFloat bodyTemperature;

/**
 * @brief Wrist temperature in degrees Celsius
 * @chinese 腕温值，单位为摄氏度
 *
 * @discussion
 * [EN]: A positive value is valid. A value of 0 means wrist temperature is unavailable.
 * [CN]: 正数表示有效腕温，0 表示缺失。
 */
@property (nonatomic, assign) CGFloat wristTemperature;

/**
 * @brief Indicates if the measurement was initiated by the user
 * @chinese 指示测量是否为用户主动发起
 *
 * @discussion
 * [EN]: A boolean value indicating whether the measurement was taken as initiated by the user.
 * [CN]: 布尔值，指示测量是否为用户主动发起的测量。
 */
@property (nonatomic, assign) BOOL isUserInitiated;

/**
 * @brief Convert one database row to a temperature sample
 * @chinese 将单条数据库记录转换为体温采样
 *
 * @param dict
 * EN: Database row containing paired temperature fields and sample metadata.
 * CN: 包含成对温度字段和采样元数据的数据库记录。
 *
 * @return
 * EN: A valid temperature sample, or nil when the row has no valid time or temperature value.
 * CN: 有效体温采样；记录无有效时间或两个温度都缺失时返回 nil。
 */
+ (nullable TSTempValueItem *)valueItemFromDBDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert database rows to temperature samples
 * @chinese 将数据库记录数组转换为体温采样数组
 *
 * @param dicts
 * EN: Database rows containing paired temperature fields.
 * CN: 包含成对温度字段的数据库记录数组。
 *
 * @return
 * EN: Valid samples in input order. Invalid rows are omitted.
 * CN: 按输入顺序返回有效采样，无效记录会被忽略。
 */
+ (NSArray<TSTempValueItem *> *)valueItemsFromDBDicts:(nullable NSArray<NSDictionary *> *)dicts;

/**
 * @brief Debug description of the paired temperature sample
 * @chinese 成对体温采样的调试描述
 *
 * @return
 * EN: A formatted description containing both values and sample metadata.
 * CN: 包含两个温度值及采样元数据的格式化描述。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
