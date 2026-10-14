//
//  TSSportInstantaneousBlockParser.h
//  TopStepBleMetaKit
//

#import "TSSportBlockParser.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Generic parser for instantaneous value blocks (direct read, no delta calculation).
 * @chinese 瞬时值块通用解析器（直读值，不做差分计算）。
 *
 * @discussion
 * Handles blocks where each item is an independent measurement (not cumulative):
 * - 0x01 Heart Rate (bpm) - 1 byte
 * - 0x02 Speed (m/min) - 3 bytes
 * - 0x05 Step Frequency (steps/min) - 3 bytes
 * - 0x0A Pace (s/km) - 3 bytes
 *
 * All skip the first item (always 0) and read values directly without delta calculation.
 */
@interface TSSportInstantaneousBlockParser : NSObject <TSSportBlockParser>

- (instancetype)initWithBlockType:(uint8_t)blockType;

@end

NS_ASSUME_NONNULL_END
