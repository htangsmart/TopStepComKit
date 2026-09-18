//
//  TSSportModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSportModel (Fw)

/**
 * @brief Convert sport summary and detail data to TSSportModel objects
 * @chinese 将运动总结和详情数据转换为TSSportModel对象
 *
 * @param summaryArray 
 * EN: Array of dictionaries containing sport summary data
 * CN: 包含运动总结数据的字典数组
 *
 * @param detailArray 
 * EN: Array of dictionaries containing sport detail items
 * CN: 包含运动详情数据的字典数组
 *
 * @return 
 * EN: Array of converted TSSportModel objects, nil if conversion fails
 * CN: 转换后的TSSportModel对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSSportModel *> *)sportModelsWithSummaryArray:(nullable NSArray<NSDictionary *> *)summaryArray
                                                         detailArray:(nullable NSArray<NSDictionary *> *)detailArray;

/**
 * @brief Convert TSSportModel array to dictionary arrays for database insertion
 * @chinese 将TSSportModel数组转换为数据库插入用的字典数组（包含摘要、详情、心率三个表）
 *
 * @param sportModels
 * EN: Array of TSSportModel objects to be converted
 * CN: 需要转换的TSSportModel对象数组
 *
 * @return
 * EN: Dictionary with keys: @"summary" (TSSportRecordTable), @"detail" (TSSportDetailItemTable), @"heartRate" (TSSportHeartRateTable)
 * CN: 字典，包含三个键：@"summary"（运动记录表）、@"detail"（运动详情表）、@"heartRate"（运动心率表）
 */
+ (NSDictionary<NSString *, NSArray<NSDictionary *> *> *)dictionaryArraysFromSportModels:(NSArray<TSSportModel *> *)sportModels;

@end

NS_ASSUME_NONNULL_END
