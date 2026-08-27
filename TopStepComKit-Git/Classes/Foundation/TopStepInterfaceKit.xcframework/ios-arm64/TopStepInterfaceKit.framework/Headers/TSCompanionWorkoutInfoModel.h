//
//  TSCompanionWorkoutInfoModel.h
//  TopStepInterfaceKit
//

#import "TSCompanionWorkoutDefines.h"
#import "TSKitBaseModel.h"
#import "TSSportSummaryModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Current companion workout information
 * @chinese 当前互联运动信息
 */
@interface TSCompanionWorkoutInfoModel : TSKitBaseModel

/** @brief Workout start time as Unix seconds @chinese 运动开始时间，Unix 秒 */
@property (nonatomic, assign) NSTimeInterval workoutStartTime;

/** @brief Unified workout type @chinese 统一运动类型 */
@property (nonatomic, assign) TSSportTypeEnum workoutType;

/** @brief Current workout state @chinese 当前运动状态 */
@property (nonatomic, assign) TSCompanionWorkoutState state;

/** @brief Workout initiator @chinese 运动发起方 */
@property (nonatomic, assign) TSCompanionWorkoutInitiator initiator;

@end

NS_ASSUME_NONNULL_END
