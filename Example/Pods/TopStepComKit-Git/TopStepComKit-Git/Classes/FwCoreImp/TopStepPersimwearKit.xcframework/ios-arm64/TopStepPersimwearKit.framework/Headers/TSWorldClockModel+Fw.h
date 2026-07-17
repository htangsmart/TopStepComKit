//
//  TSWorldClockModel+Fw.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWorldClockModel (Fw)

/**
 * @brief Convert TSWorldClockModel array to dictionary array
 * @chinese 将TSWorldClockModel数组转换为字典数组
 *
 * @param models 
 * EN: Array of TSWorldClockModel objects to be converted
 * CN: 需要转换的TSWorldClockModel对象数组
 *
 * @return 
 * EN: Array of dictionaries in the format:
 * [
 *     { city: "ShenZhen", zone: "Asia/shanghai", utc: 1.0 },  // First row is current city
 *     { city: "algiers", zone: "Asia/shanghai", utc: -8.5 },  // Second row is other cities
 *     ...
 * ]
 * CN: 返回格式如下的字典数组：
 * [
 *     { city: "ShenZhen", zone: "Asia/shanghai", utc: 1.0 },  // 第一行为当前城市
 *     { city: "algiers", zone: "Asia/shanghai", utc: -8.5 },  // 第二行为其他城市
 *     ...
 * ]
 */
+ (NSArray<NSDictionary *> *)worldTimeModelsToFwDictArray:(NSArray<TSWorldClockModel *> *)models;

/**
 * @brief Convert dictionary array to TSWorldClockModel array
 * @chinese 将字典数组转换为TSWorldClockModel数组
 *
 * @param dictArray 
 * EN: Array of dictionaries in the format:
 * [
 *     { city: "ShenZhen", zone: "Asia/shanghai", utc: 1.0 },  // First row is current city
 *     { city: "algiers", zone: "Asia/shanghai", utc: -8.5 },  // Second row is other cities
 *     ...
 * ]
 * CN: 格式如下的字典数组：
 * [
 *     { city: "ShenZhen", zone: "Asia/shanghai", utc: 1.0 },  // 第一行为当前城市
 *     { city: "algiers", zone: "Asia/shanghai", utc: -8.5 },  // 第二行为其他城市
 *     ...
 * ]
 *
 * @return 
 * EN: Array of TSWorldClockModel objects, empty array if conversion fails
 * CN: TSWorldClockModel对象数组，转换失败时返回空数组
 */
+ (NSArray<TSWorldClockModel *> *)fwDictArrayToWorldTimeModels:(NSArray<NSDictionary *> *)dictArray;

@end

NS_ASSUME_NONNULL_END
