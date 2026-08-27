//
//  TSCompanionWorkoutDeviceReportModel.h
//  TopStepInterfaceKit
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Periodic companion workout report sent from device to App
 * @chinese 设备发送给 App 的互联运动周期数据
 */
@interface TSCompanionWorkoutDeviceReportModel : TSKitBaseModel

/** @brief Workout start time as Unix seconds @chinese 运动开始时间，Unix 秒 */
@property (nonatomic, assign) NSTimeInterval workoutStartTime;

/** @brief Number of steps @chinese 累计步数；nil 表示未上报 */
@property (nonatomic, copy, nullable) NSNumber *numberOfSteps;

/** @brief Calories in kilocalories @chinese 累计热量，单位千卡；nil 表示未上报 */
@property (nonatomic, copy, nullable) NSNumber *caloriesInKilocalories;

/** @brief Current heart rate in BPM @chinese 当前心率，单位 BPM；nil 表示未上报 */
@property (nonatomic, copy, nullable) NSNumber *bpmValue;

/** @brief Duration in seconds @chinese 累计时长，单位秒；nil 表示未上报 */
@property (nonatomic, copy, nullable) NSNumber *workoutDurationInSeconds;

/** @brief Distance in meters @chinese 累计距离，单位米；nil 表示未上报 */
@property (nonatomic, copy, nullable) NSNumber *distanceInMeters;

/** @brief Average cadence in steps per minute @chinese 平均步频，单位步/分钟；nil 表示未上报 */
@property (nonatomic, copy, nullable) NSNumber *averageCadence;

/** @brief GPS pace in seconds per kilometer @chinese GPS 配速，单位秒/公里；nil 表示未上报 */
@property (nonatomic, copy, nullable) NSNumber *gpsPace;

/** @brief GPS speed in meters per second @chinese GPS 实时速度，单位米/秒；nil 表示未上报 */
@property (nonatomic, copy, nullable) NSNumber *gpsRealTimeSpeed;

@end

NS_ASSUME_NONNULL_END
