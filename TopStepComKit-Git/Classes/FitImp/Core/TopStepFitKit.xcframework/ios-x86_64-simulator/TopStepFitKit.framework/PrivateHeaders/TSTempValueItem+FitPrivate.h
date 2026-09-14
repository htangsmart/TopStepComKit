//
//  TSTempValueItem+FitPrivate.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/20.
//

#import "TSTempValueItem+Fit.h"

@class FitCloudBTRecordObject;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal Fit historical-temperature conversion
 * @chinese Fit 历史体温内部转换
 */
@interface TSTempValueItem (FitPrivate)

/**
 * @brief Convert FitCloud temperature records to database rows
 * @chinese 将 FitCloud 体温记录转换为数据库行
 *
 * @param records
 * EN: FitCloud temperature records
 * CN: FitCloud 体温记录
 *
 * @return
 * EN: Composite temperature database rows
 * CN: 复合体温数据库行
 */
+ (NSArray<NSDictionary *> *)tempDictsWithFitCloudBTRecords:(nullable NSArray<FitCloudBTRecordObject *> *)records;

@end

NS_ASSUME_NONNULL_END
