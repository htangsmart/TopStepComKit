//
//  TSSleepDataProcessor.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/20.
//

#import <Foundation/Foundation.h>
#import "TSSleepDailyModel.h"
#import "TSSleepDetailItem.h"
#import "TSSleepStatisticsStrategy.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sleep data processor class
 * @chinese 睡眠数据处理类
 *
 * @discussion
 * [EN]: This class is responsible for processing raw sleep detail items and generating
 * TSSleepDailyModel with sleep segments and summary according to different statistics rules.
 *
 * [CN]: 该类负责处理原始睡眠详情条目，并根据不同的统计规则生成
 * 包含睡眠段和汇总的 TSSleepDailyModel。
 */
@interface TSSleepDataProcessor : NSObject

+ (NSArray<TSSleepDailyModel *> *)processWithStatisticsRule:(TSSleepStatisticsRule)statisticsRule
                                                   rawItems:(NSArray<TSSleepDetailItem *> *)rawItems ;

@end

NS_ASSUME_NONNULL_END

