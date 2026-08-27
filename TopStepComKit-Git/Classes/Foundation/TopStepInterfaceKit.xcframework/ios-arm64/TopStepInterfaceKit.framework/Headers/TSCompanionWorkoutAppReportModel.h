//
//  TSCompanionWorkoutAppReportModel.h
//  TopStepInterfaceKit
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Periodic companion workout report sent from App to device
 * @chinese App 发送给设备的互联运动周期数据
 */
@interface TSCompanionWorkoutAppReportModel : TSKitBaseModel

/** @brief Workout start time as Unix seconds @chinese 运动开始时间，Unix 秒 */
@property (nonatomic, assign) NSTimeInterval workoutStartTime;

/** @brief Duration in seconds @chinese 累计时长，单位秒 */
@property (nonatomic, assign) NSInteger workoutDurationInSeconds;

/** @brief Distance in meters @chinese 累计距离，单位米；nil 表示未上报 */
@property (nonatomic, copy, nullable) NSNumber *distanceInMeters;

/** @brief Calories in kilocalories @chinese 累计热量，单位千卡；nil 表示未上报 */
@property (nonatomic, copy, nullable) NSNumber *caloriesInKilocalories;

/** @brief Current pace in seconds per kilometer @chinese 当前配速，单位秒/公里；nil 表示未上报 */
@property (nonatomic, copy, nullable) NSNumber *currentPace;

/** @brief Number of steps @chinese 累计步数；nil 表示未上报 */
@property (nonatomic, copy, nullable) NSNumber *numberOfSteps;

@end

NS_ASSUME_NONNULL_END
