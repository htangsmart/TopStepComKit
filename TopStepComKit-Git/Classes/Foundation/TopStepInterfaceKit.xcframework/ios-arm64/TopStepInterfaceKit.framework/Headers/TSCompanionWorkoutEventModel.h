//
//  TSCompanionWorkoutEventModel.h
//  TopStepInterfaceKit
//

#import "TSCompanionWorkoutDefines.h"
#import "TSKitBaseModel.h"
#import "TSSportSummaryModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Companion workout event model
 * @chinese 互联运动事件模型
 */
@interface TSCompanionWorkoutEventModel : TSKitBaseModel

/** @brief Event type @chinese 事件类型 */
@property (nonatomic, assign) TSCompanionWorkoutEvent event;

/** @brief Workout start time as Unix seconds @chinese 运动开始时间，Unix 秒 */
@property (nonatomic, assign) NSTimeInterval workoutStartTime;

/** @brief Unified workout type @chinese 统一运动类型 */
@property (nonatomic, assign) TSSportTypeEnum workoutType;

/** @brief Duration since workout start in seconds @chinese 从运动开始累计的时长，单位秒 */
@property (nonatomic, assign) NSInteger workoutDurationInSeconds;

@end

NS_ASSUME_NONNULL_END
