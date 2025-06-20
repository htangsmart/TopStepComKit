//
//  TSDailyActivityGoalsModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMSportGoalModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSDailyActivityGoalsModel (SJ)

/**
 * @brief Convert TSDailyActivityGoalsModel to WMSportGoalModel
 * @chinese 将TSDailyActivityGoalsModel转换为WMSportGoalModel
 *
 * @param tsModel 
 * EN: TSDailyActivityGoalsModel object to be converted
 * CN: 需要转换的TSDailyActivityGoalsModel对象
 *
 * @return 
 * EN: Converted WMSportGoalModel object, nil if conversion fails
 * CN: 转换后的WMSportGoalModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts TSDailyActivityGoalsModel to WMSportGoalModel:
 *     - Converts steps goal directly
 *     - Converts calories goal directly (both in kcal)
 *     - Converts distance goal directly (both in meters)
 *     - Converts activity duration goal directly (both in minutes)
 * CN: 该方法将TSDailyActivityGoalsModel转换为WMSportGoalModel：
 *     - 直接转换步数目标
 *     - 直接转换卡路里目标（都以千卡为单位）
 *     - 直接转换距离目标（都以米为单位）
 *     - 直接转换活动时长目标（都以分钟为单位）
 */
+ (nullable WMSportGoalModel *)wmModelWithTSDailyActivityGoalsModel:(nullable TSDailyActivityGoalsModel *)tsModel;

/**
 * @brief Convert WMSportGoalModel to TSDailyActivityGoalsModel
 * @chinese 将WMSportGoalModel转换为TSDailyActivityGoalsModel
 *
 * @param wmModel 
 * EN: WMSportGoalModel object to be converted
 * CN: 需要转换的WMSportGoalModel对象
 *
 * @return 
 * EN: Converted TSDailyActivityGoalsModel object, nil if conversion fails
 * CN: 转换后的TSDailyActivityGoalsModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts WMSportGoalModel to TSDailyActivityGoalsModel:
 *     - Converts steps goal directly
 *     - Converts calories goal directly (both in kcal)
 *     - Converts distance goal directly (both in meters)
 *     - Converts activity duration goal directly (both in minutes)
 * CN: 该方法将WMSportGoalModel转换为TSDailyActivityGoalsModel：
 *     - 直接转换步数目标
 *     - 直接转换卡路里目标（都以千卡为单位）
 *     - 直接转换距离目标（都以米为单位）
 *     - 直接转换活动时长目标（都以分钟为单位）
 */
+ (nullable TSDailyActivityGoalsModel *)modelWithWMSportGoalModel:(nullable WMSportGoalModel *)wmModel;

@end

NS_ASSUME_NONNULL_END
