//
//  TSSportDataCombiner.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>

@class TSSportParseContext;
@class TSMetaSportItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Combines parsed sport samples into detail items by timestamp.
 * @chinese 按时间戳将已解析的运动样本合并为明细项。
 */
@interface TSSportDataCombiner : NSObject

/**
 * @brief Creates a detail item for each timestamp with a step, calorie, or distance sample.
 * @chinese 有步数、热量或距离样本的时间戳均生成明细项。
 *
 * @param context
 * EN: Context containing the parsed samples.
 * CN: 包含已解析样本的上下文。
 *
 * @return
 * EN: Items sorted by timestamp, with missing metrics defaulting to zero.
 * CN: 按时间戳升序排列的明细项，缺失指标默认为零。
 */
+ (NSArray<TSMetaSportItem *> *)combineFromContext:(TSSportParseContext *)context;

@end

NS_ASSUME_NONNULL_END
