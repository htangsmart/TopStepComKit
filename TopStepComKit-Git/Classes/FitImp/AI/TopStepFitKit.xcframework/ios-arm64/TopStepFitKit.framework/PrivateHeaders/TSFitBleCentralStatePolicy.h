//
//  TSFitBleCentralStatePolicy.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/31.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TSFitBleCentralStateDecision) {
    TSFitBleCentralStateDecisionProceed = 0,
    TSFitBleCentralStateDecisionWait,
    TSFitBleCentralStateDecisionFail,
};

/**
 * @brief Central-state policy for FitCloudKit connection readiness.
 * @chinese FitCloudKit 蓝牙中心状态决策，保持连接流程与错误映射一致。
 */
@interface TSFitBleCentralStatePolicy : NSObject

/**
 * @brief Resolve the connection action for a central state.
 * @chinese 返回当前中心状态对应的连接动作。
 * @param state FitCloudKit central state. / FitCloudKit 蓝牙中心状态。
 * @return Connection readiness decision. / 连接就绪决策。
 */
+ (TSFitBleCentralStateDecision)decisionForState:(FITCLOUDBLECENTRALSTATE)state;

/**
 * @brief Resolve the unified Bluetooth error for a central state.
 * @chinese 返回当前中心状态对应的统一蓝牙错误码。
 * @param state FitCloudKit central state. / FitCloudKit 蓝牙中心状态。
 * @return Unified Bluetooth error code. / 统一蓝牙错误码。
 */
+ (TSBleConnectionError)errorCodeForState:(FITCLOUDBLECENTRALSTATE)state;

@end

NS_ASSUME_NONNULL_END
