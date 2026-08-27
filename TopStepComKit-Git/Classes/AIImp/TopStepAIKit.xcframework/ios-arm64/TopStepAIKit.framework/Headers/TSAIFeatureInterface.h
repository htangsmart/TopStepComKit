//
//  TSAIFeatureInterface.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/26.
//

#import "TSAIFeatureDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified AI feature-query interface
 * @chinese 统一 AI 功能查询接口
 *
 * @discussion
 * [EN]: A feature is an effective SDK business function derived from the
 *       Provider implementation, Provider SDK and required device capability.
 *       Transient state such as Context activation, authorization, permission,
 *       network reachability or task contention is not represented here.
 *       Device facts such as TSPeripheralAIAbility are mapped through the
 *       platform DeviceBridge and combined by the root Provider. A Context
 *       additionally requires its internal route for orchestrated features.
 * [CN]: Feature 是由 Provider 实现、Provider SDK 与必要设备能力共同形成的
 *       SDK 业务功能；Context 激活、鉴权、权限、网络和任务互斥等瞬时状态
 *       不由本协议表达。`TSPeripheralAIAbility` 等设备事实由平台
 *       DeviceBridge 映射，再由根 Provider 组合；对需要内部编排的功能，
 *       Context 还会检查对应路由是否已建立。
 */
@protocol TSAIFeatureInterface <NSObject>

/**
 * @brief Return whether every requested AI feature is supported
 * @chinese 返回是否支持全部指定的 AI 功能
 *
 * @param features
 * EN: One or more standardized AI features
 * CN: 一个或多个标准 AI 功能
 *
 * @return
 * EN: YES only when the input is non-empty, contains no unknown bit and every
 *     requested feature is supported
 * CN: 仅当输入非空、不含未知位且全部指定功能均受支持时返回 YES
 */
- (BOOL)supportsAIFeatures:(TSAIFeatureOptions)features;

@end

NS_ASSUME_NONNULL_END
