//
//  TSSportParseContext.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>
#import "PbSportDetail.pbobjc.h"

@class TSSportBinaryReader;

// Internal temporary models (V2 module private, not exposed externally)
@interface TSSportStepItemV2 : NSObject
@property (nonatomic, assign) int64_t timestampSeconds;
@property (nonatomic, assign) int32_t duration;
@property (nonatomic, assign) int32_t steps;
@end

@interface TSSportCalorieItemV2 : NSObject
@property (nonatomic, assign) int64_t timestampSeconds;
@property (nonatomic, assign) int32_t duration;
@property (nonatomic, assign) int32_t calories;  // raw value (divide by 1000 for kCal)
@end

@interface TSSportDistanceItemV2 : NSObject
@property (nonatomic, assign) int64_t timestampSeconds;
@property (nonatomic, assign) int32_t duration;
@property (nonatomic, assign) int32_t distance;  // meters
@end

@interface TSSportStepFreqItemV2 : NSObject
@property (nonatomic, assign) int64_t timestampSeconds;
@property (nonatomic, assign) int32_t duration;
@property (nonatomic, assign) int32_t stepFreq;  // steps per minute
@end

@interface TSSportPaceItemV2 : NSObject
@property (nonatomic, assign) int64_t timestampSeconds;
@property (nonatomic, assign) int32_t duration;
@property (nonatomic, assign) int32_t pace;  // seconds per kilometer
@end

@interface TSSportSpeedItemV2 : NSObject
@property (nonatomic, assign) int64_t timestampSeconds;
@property (nonatomic, assign) int32_t duration;
@property (nonatomic, assign) int32_t speed;  // meters per minute
@end

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Encapsulates all state during sport detail file parsing.
 * @chinese 封装运动详情文件解析过程中的所有状态。
 */
@interface TSSportParseContext : NSObject

// --- Input ---
@property (nonatomic, strong) TSSportBinaryReader *reader;
@property (nonatomic, assign) int64_t startTimeSeconds;
@property (nonatomic, assign) int32_t duration;
@property (nonatomic, assign) BOOL isV2;

// --- Parse cursor ---
@property (nonatomic, assign) NSUInteger currentOffset;

// --- Current block header (set by TSSportFileParser before calling each block parser) ---
@property (nonatomic, assign) uint8_t currentBlockType;
@property (nonatomic, assign) uint16_t currentBlockStartTime;
@property (nonatomic, assign) uint8_t currentItemLength;
@property (nonatomic, assign) uint8_t currentItemCount;

// --- Accumulated parsed data ---
@property (nonatomic, strong) TSMetaSportDetailConfig *config;
@property (nonatomic, strong) NSMutableArray<TSMetaSportHeartRateItem *> *hrItems;
@property (nonatomic, strong) NSMutableArray<TSSportStepItemV2 *> *stepItems;
@property (nonatomic, strong) NSMutableArray<TSSportCalorieItemV2 *> *calItems;
@property (nonatomic, strong) NSMutableArray<TSSportDistanceItemV2 *> *distItems;
@property (nonatomic, strong) NSMutableArray<TSSportStepFreqItemV2 *> *stepFreqItems;
@property (nonatomic, strong) NSMutableArray<TSSportPaceItemV2 *> *paceItems;
@property (nonatomic, strong) NSMutableArray<TSSportSpeedItemV2 *> *speedItems;

- (instancetype)initWithReader:(TSSportBinaryReader *)reader
              startTimeSeconds:(int64_t)startTimeSeconds
                      duration:(int32_t)duration;

@end

NS_ASSUME_NONNULL_END
