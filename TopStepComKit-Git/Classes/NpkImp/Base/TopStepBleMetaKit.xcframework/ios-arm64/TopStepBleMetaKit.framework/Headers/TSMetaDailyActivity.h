//
//  TSMetaDailyActivity.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/4.
//

#import "TSBusinessBase.h"
#import "PbConfigParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaDailyActivity : TSBusinessBase

/**
 * @brief Fetch daily exercise configs
 * @chinese 获取每日活动目标配置
 *
 * @param completion
 * [EN]: Completion callback returning TSMetaDailyConfig or error
 * [CN]: 返回 TSMetaGoalsModel 或错误的完成回调
 */
+ (void)fetchDailyActivityConfigsWithCompletion:(void(^)(TSMetaDailyConfig *_Nullable config, NSError *_Nullable error))completion;

/**
 * @brief Push daily exercise configs
 * @chinese 设置每日活动目标配置
 *
 * @param config
 * [EN]: Goals configuration to push (TSMetaDailyConfig)
 * [CN]: 需要推送的目标配置（TSMetaGoalsModel）
 *
 * @param completion
 * [EN]: Completion callback indicating success or error
 * [CN]: 指示成功或错误的完成回调
 */
+ (void)pushDailyActivityConfigs:(TSMetaDailyConfig *)config
            completion:(void(^)(BOOL success, NSError *_Nullable error))completion;

/**
 * @brief Register daily exercise config change notification
 * @chinese 注册每日活动目标变更通知
 *
 * @param completion
 * [EN]: Completion callback returning updated TSMetaDailyConfig or error
 * [CN]: 返回变更后的 TSMetaDailyConfig 或错误
 */
 + (void)registerDailyActivityConfigsDidChange:(void(^)(TSMetaDailyConfig *_Nullable config, NSError *_Nullable error))completion;



@end

NS_ASSUME_NONNULL_END
