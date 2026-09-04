//
//  TSAICapabilityInterface.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

@class TSAIStartEligibility;
@class TSAIStartRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Exact eligibility interface for starting AI operations
 * @chinese AI 操作启动前的精确资格校验接口
 *
 * @discussion
 * [EN]: Callers must use this result as the authorization boundary before any
 *       Provider, audio or device side effect. Legacy feature queries are not
 *       start authorization.
 * [CN]: 调用方必须在任何 Provider、音频或设备副作用前以本结果作为授权边界；
 *       Legacy Feature 查询不能用于启动授权。
 */
@protocol TSAICapabilityInterface <NSObject>

/**
 * @brief Evaluate whether one complete AI start request can start now
 * @chinese 校验一个完整 AI 启动请求当前是否可以发起
 *
 * @param request
 * EN: Immutable request including optional exact device coordination
 * CN: 包含可选精确设备协同信息的不可变请求
 *
 * @return
 * EN: Binary eligibility result and an exact error when unsupported
 * CN: 二态资格结果；不支持时携带准确错误
 */
- (TSAIStartEligibility *)startEligibilityForRequest:(TSAIStartRequest *)request;

@end

NS_ASSUME_NONNULL_END
