//
//  TSSleepItemModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSSleepItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepItemModel (Fw)

/**
 * @brief Convert array of dictionaries to array of TSSleepItemModel objects
 * @chinese 将字典数组转换为TSSleepItemModel对象数组
 *
 * @param dictArray 
 * EN: Array of dictionaries containing sleep data with structure:
 * {
 *   "d": {
 *     "s": timestamp,     // Start time
 *     "t": integer,       // Sleep stage type
 *     "d": integer,       // Duration (minutes)
 *     "m": integer,       // Reserved
 *     "in": timestamp     // Day start timestamp
 *   }
 * }
 * CN: 包含睡眠数据的字典数组，结构如下：
 * {
 *   "d": {
 *     "s": 时间戳,       // 开始时间
 *     "t": 整数,         // 睡眠阶段类型
 *     "d": 整数,         // 持续时间（分钟）
 *     "m": 整数,         // 保留字段
 *     "in": 时间戳       // 当天开始时间戳
 *   }
 * }
 *
 * @return 
 * EN: Array of converted TSSleepItemModel objects, nil if conversion fails
 * CN: 转换后的TSSleepItemModel对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSSleepItemModel *> *)sleepItemModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;

- (TSSleepStageType)isUsefulSleepState ;

+ (TSSleepPeriodType)periodTypeWithItem:(TSSleepItemModel *)item;

@end

NS_ASSUME_NONNULL_END
