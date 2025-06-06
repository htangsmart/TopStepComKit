//
//  TSSportSummaryModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSportSummaryModel (Fw)

/**
 * @brief Convert a single dictionary to TSSportSummaryModel object
 * @chinese 将单个字典转换为TSSportSummaryModel对象
 *
 * @param dict 
 * EN: Dictionary containing sport summary data with:
 * - ts: Timestamp for the record
 * - d: Dictionary containing detailed sport metrics
 * CN: 包含运动总结数据的字典，包含：
 * - ts: 记录的时间戳
 * - d: 包含详细运动指标的字典
 *
 * @return 
 * EN: Converted TSSportSummaryModel object, nil if conversion fails
 * CN: 转换后的TSSportSummaryModel对象，转换失败时返回nil
 */
+ (nullable TSSportSummaryModel *)sportSummaryModelWithFwDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert array of dictionaries to array of TSSportSummaryModel objects
 * @chinese 将字典数组转换为TSSportSummaryModel对象数组
 *
 * @param dictArray 
 * EN: Array of dictionaries containing sport summary data
 * CN: 包含运动总结数据的字典数组
 *
 * @return 
 * EN: Array of converted TSSportSummaryModel objects, nil if conversion fails
 * CN: 转换后的TSSportSummaryModel对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSSportSummaryModel *> *)sportSummaryModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;

@end

NS_ASSUME_NONNULL_END
