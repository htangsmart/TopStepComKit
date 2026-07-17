//
//  TSSportCumulativeBlockParser.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>
#import "TSSportBlockParser.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified parser for cumulative data blocks: 0x07 (steps), 0x08 (distance), 0x09 (calories).
 * @chinese 统一处理累加数据块：0x07（步数）、0x08（距离）、0x09（卡路里）。
 *
 * Computes incremental values by subtracting adjacent cumulative readings.
 * Appends results to the corresponding array in context.
 */
@interface TSSportCumulativeBlockParser : NSObject <TSSportBlockParser>

/// Initialize with the block type this instance will handle (0x07, 0x08, or 0x09)
- (instancetype)initWithBlockType:(uint8_t)blockType;

@end

NS_ASSUME_NONNULL_END
