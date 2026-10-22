#import <Foundation/Foundation.h>
#import "TSECGMeasurementSummary.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TSECGMeasurementEventType) {
    TSECGMeasurementEventTypeStarted = 0,
    TSECGMeasurementEventTypeWaveform,
    TSECGMeasurementEventTypeLeadContact,
    TSECGMeasurementEventTypeMetrics,
    TSECGMeasurementEventTypeProgress,
    TSECGMeasurementEventTypeCompleted,
    TSECGMeasurementEventTypeFailed,
};

/// 只读取 type 对应字段。samples 为有符号微伏；指标 nil 表示未更新，0 表示不可用。
@interface TSECGMeasurementEvent : NSObject
@property (nonatomic, assign) TSECGMeasurementEventType type;
@property (nonatomic, assign) UInt16 samplingRate;
@property (nonatomic, assign) UInt16 expectedDurationInSeconds;
@property (nonatomic, assign) UInt32 sampleIndex;
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *samples;
@property (nonatomic, assign) BOOL leadContacted;
@property (nonatomic, strong, nullable) NSNumber *heartRate;
@property (nonatomic, strong, nullable) NSNumber *qtc;
@property (nonatomic, strong, nullable) NSNumber *rmssd;
@property (nonatomic, assign) UInt8 progress;
@property (nonatomic, strong, nullable) TSECGMeasurementSummary *summary;
@property (nonatomic, strong, nullable) NSNumber *reasonCode;
@end

typedef void (^TSECGMeasurementEventHandler)(TSECGMeasurementEvent *event);
typedef void (^TSECGMeasurementErrorHandler)(NSError *error);

NS_ASSUME_NONNULL_END
