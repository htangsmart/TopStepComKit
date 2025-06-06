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

@end

NS_ASSUME_NONNULL_END
