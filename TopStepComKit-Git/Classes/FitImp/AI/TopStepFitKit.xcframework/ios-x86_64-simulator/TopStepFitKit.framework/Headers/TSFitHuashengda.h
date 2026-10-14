//
//  TSFitHuashengda.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/9/23.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief FitCloud implementation of TSHuashengdaInterface
 * @chinese TSHuashengdaInterface 的 FitCloud 实现
 *
 * @discussion
 * [EN]: Capabilities come from FitCloudKit firmware flags (withCustomLabels / withParentalControl / withClassroomMode /
 *       allowHabits / allowCountWatchAppUsage / allowCountWatchGamePlay / withSingleGameTop3GameRecord).
 *       FitCloudKit has no task flag, so task & reward is treated as supported on Huashengda firmware
 *       (parental mode or classroom mode present). Model mapping lives in TSHsdModels+Fit.
 *       All completions run on the main thread; unsupported features complete with
 *       TSERROR_NOTSUPPORT(kTSErrorDomainHuashengdaName) without sending.
 * [CN]: 能力取自 FitCloudKit 固件标志位（withCustomLabels / withParentalControl / withClassroomMode / allowHabits /
 *       allowCountWatchAppUsage / allowCountWatchGamePlay / withSingleGameTop3GameRecord）。
 *       FitCloudKit 没有任务能力位，任务&奖励按「华盛达固件」判定（支持家长模式或课堂模式）。模型映射见 TSHsdModels+Fit。
 *       所有回调在主线程；不支持的能力回调 TSERROR_NOTSUPPORT(kTSErrorDomainHuashengdaName)，不发包。
 */
@interface TSFitHuashengda : TSFitKitBase <TSHuashengdaInterface>

@end

NS_ASSUME_NONNULL_END
