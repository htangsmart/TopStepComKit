//
//  TSAIDailyGuidanceGenerator.h
//  TopStepInterfaceKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TSSleepDailyModel;
@class TSHRVDailyModel;
@class TSActivityDailyModel;
@class TSAIDailyGuidanceResult;

/**
 * @brief Internal AI daily health guidance generator
 * @chinese AI每日健康引导内部生成器
 *
 * @discussion
 * [EN]: Internal stateless generator shared by SDK vendor implementations.
 * Apps should access daily guidance through [TopStepComKit sharedInstance].aiDailyGuidance.
 *
 * [CN]: SDK各厂商实现复用的内部无状态生成器。
 * App应通过[TopStepComKit sharedInstance].aiDailyGuidance访问每日健康引导能力。
 */
@interface TSAIDailyGuidanceGenerator : NSObject

+ (TSAIDailyGuidanceResult *)generateWithSleepModel:(nullable TSSleepDailyModel *)sleepModel
                                          hrvModel:(nullable TSHRVDailyModel *)hrvModel
                                     activityModel:(nullable TSActivityDailyModel *)activityModel;

@end

NS_ASSUME_NONNULL_END
