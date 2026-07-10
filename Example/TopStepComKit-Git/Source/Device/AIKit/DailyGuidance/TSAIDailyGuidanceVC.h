//
//  TSAIDailyGuidanceVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/9.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI daily health guidance demo page
 * @chinese AI 每日健康引导 Demo 页
 *
 * @discussion
 * [EN]: Lets the tester assemble sleep / HRV / activity health models via sliders,
 *       then calls [TopStepComKit sharedInstance].aiDailyGuidance
 *       generateWithSleepModel:hrvModel:activityModel: and renders the result.
 *       The SDK computes the internal scores; this page only supplies raw model
 *       fields, matching the "always go through the ComKit interface" rule.
 * [CN]: 测试者通过滑块拼装睡眠 / HRV / 活动健康模型，随后调用
 *       [TopStepComKit sharedInstance].aiDailyGuidance 的
 *       generateWithSleepModel:hrvModel:activityModel: 并展示结果。
 *       得分由 SDK 内部计算，本页只提供原始模型字段，符合「必须通过 ComKit 接口」规范。
 */
@interface TSAIDailyGuidanceVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
