//
//  TSAIDailyGuidanceInterface.h
//  TopStepInterfaceKit
//

#import <Foundation/Foundation.h>
#import "TSKitBaseInterface.h"
#import "TSAIDailyGuidanceResult.h"

NS_ASSUME_NONNULL_BEGIN

@class TSSleepDailyModel;
@class TSActivityDailyModel;
@class TSHRVDailyModel;

/**
 * @brief AI daily health guidance interface protocol
 * @chinese AI每日健康引导接口协议
 *
 * @discussion
 * [EN]: This protocol defines the public SDK entry for daily health guidance.
 * Apps can either pass SDK health models directly, or ask the active vendor
 * implementation to query today's daily health data internally and generate a result.
 *
 * [CN]: 该协议定义每日健康引导的公开SDK入口。
 * App可以直接传入SDK健康模型生成结果，也可以让当前厂商实现内部查询今日健康日数据后生成结果。
 */
@protocol TSAIDailyGuidanceInterface <TSKitBaseInterface>

/**
 * @brief Query today's daily data internally and generate daily guidance
 * @chinese 内部查询今日健康日数据并生成每日健康引导
 *
 * @param completion
 * EN: Callback block returning the generated result or query error.
 * CN: 返回生成结果或查询错误的回调block。
 *
 * @discussion
 * [EN]: The active vendor implementation queries today's sleep, HRV and daily activity
 * models through its own data layer, then generates guidance with the same local rules.
 * Completion may be called asynchronously.
 *
 * [CN]: 当前厂商实现会通过自身数据层查询今日睡眠、HRV和日常活动模型，然后使用相同本地规则生成健康引导。
 * completion可能异步回调。
 */
- (void)generateWithCompletion:(void (^)(TSAIDailyGuidanceResult *_Nullable result, NSError *_Nullable error))completion;

/**
 * @brief Generate daily guidance directly from SDK health models
 * @chinese 直接根据SDK健康模型生成每日健康引导
 *
 * @param sleepModel
 * EN: Daily sleep model. Pass nil when sleep data is unavailable.
 * CN: 日睡眠模型。无睡眠数据时传nil。
 *
 * @param hrvModel
 * EN: Daily HRV model. Pass nil when HRV or recovery data is unavailable.
 * CN: 每日HRV模型。无HRV或恢复数据时传nil。
 *
 * @param activityModel
 * EN: Daily activity model. Pass nil when activity data is unavailable.
 * CN: 日常活动模型。无活动数据时传nil。
 *
 * @return
 * EN: Generated TSAIDailyGuidanceResult instance.
 * CN: 生成后的TSAIDailyGuidanceResult实例。
 *
 * @discussion
 * [EN]: The SDK calculates internal sleep, recovery and activity intensity scores from
 * the input models, but those intermediate scores are not exposed in the result.
 *
 * [CN]: SDK会根据传入模型在内部计算睡眠、恢复和活动强度得分，但不会在结果中暴露这些中间分数。
 */
- (TSAIDailyGuidanceResult *)generateWithSleepModel:(nullable TSSleepDailyModel *)sleepModel
                                           hrvModel:(nullable TSHRVDailyModel *)hrvModel
                                      activityModel:(nullable TSActivityDailyModel *)activityModel;

@end

NS_ASSUME_NONNULL_END
