//
//  TSNpkAIDailyGuidance.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2026/7/1.
//

#import "TSNpkKitBase.h"
#import <TopStepInterfaceKit/TSAIDailyGuidanceInterface.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI daily health guidance implementation
 * @chinese AI每日健康引导实现类
 *
 * @discussion
 * [EN]: TopStepNewPlatformKit implementation of TSAIDailyGuidanceInterface.
 * This class is created by the SDK protocol factory and should be accessed through TopStepComKit.aiDailyGuidance.
 *
 * [CN]: TopStepNewPlatformKit 对 TSAIDailyGuidanceInterface 的实现。
 * 该类由SDK协议工厂创建，业务侧应通过 TopStepComKit.aiDailyGuidance 访问。
 */
@interface TSNpkAIDailyGuidance : TSNpkKitBase <TSAIDailyGuidanceInterface>

@end

NS_ASSUME_NONNULL_END
