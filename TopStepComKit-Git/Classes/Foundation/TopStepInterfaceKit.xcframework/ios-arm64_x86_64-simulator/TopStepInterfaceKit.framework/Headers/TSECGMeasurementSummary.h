#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 心电实时测量最终结果；可选指标的 nil 表示设备未提供。
@interface TSECGMeasurementSummary : NSObject
@property (nonatomic, assign) UInt8 averageHeartRate;
@property (nonatomic, assign) UInt8 maximumHeartRate;
@property (nonatomic, assign) UInt8 minimumHeartRate;
@property (nonatomic, assign) UInt16 actualDurationInSeconds;
@property (nonatomic, assign) UInt8 normalHeartRatePercentage;
@property (nonatomic, assign) UInt8 fastHeartRatePercentage;
@property (nonatomic, assign) UInt8 slowHeartRatePercentage;
/// QTc 和 RMSSD 单位为毫秒。
@property (nonatomic, strong, nullable) NSNumber *qtc;
@property (nonatomic, strong, nullable) NSNumber *rmssd;
/// QRS 幅度单位为毫伏，时长单位为毫秒。
@property (nonatomic, strong, nullable) NSNumber *qrsAmplitude;
@property (nonatomic, strong, nullable) NSNumber *qrsDuration;
@end

NS_ASSUME_NONNULL_END
