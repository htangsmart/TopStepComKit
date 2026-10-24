//
//  TSAIAudioRouteSnapshot.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"
#import "TSAIFeatureDefines.h"

@class TSAIAudioRouteConfiguration;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Requested and effective route snapshot for one active AI session
 * @chinese 单个活动 AI 会话的请求路由与实际路由快照
 */
@interface TSAIAudioRouteSnapshot : NSObject <NSCopying>

/** @brief Feature owning the route @chinese 占用此路由的 AI 功能 */
@property (nonatomic, assign, readonly) TSAIFeatureOptions feature;

/** @brief Route requested by the App @chinese App 请求的路由 */
@property (nonatomic, copy, readonly) TSAIAudioRouteConfiguration *requestedRoute;

/** @brief Route selected by AIKit @chinese AIKit 实际选择的路由 */
@property (nonatomic, copy, readonly) TSAIAudioRouteConfiguration *effectiveRoute;

/** @brief Current route lifecycle state @chinese 当前路由生命周期状态 */
@property (nonatomic, assign, readonly) TSAIAudioRouteState state;

/** @brief Why the effective route differs from the requested route @chinese 实际路由与请求路由不同的原因 */
@property (nonatomic, assign, readonly) TSAIAudioRouteFallbackReason fallbackReason;

/** @brief Debug detail for the fallback (unavailable reason of the requested route) @chinese 回退的调试信息（请求路由不可用的原因） */
@property (nonatomic, copy, readonly, nullable) NSString *fallbackDetail;

/**
 * @brief Create a route snapshot
 * @chinese 创建路由快照
 * @param feature EN: Owning feature. CN: 所属功能。
 * @param requestedRoute EN: Requested route. CN: 请求路由。
 * @param effectiveRoute EN: Effective route. CN: 实际路由。
 * @param state EN: Route lifecycle state. CN: 路由生命周期状态。
 * @return EN: A new immutable snapshot. CN: 新的不可变快照。
 */
+ (instancetype)snapshotWithFeature:(TSAIFeatureOptions)feature
                     requestedRoute:(TSAIAudioRouteConfiguration *)requestedRoute
                     effectiveRoute:(TSAIAudioRouteConfiguration *)effectiveRoute
                              state:(TSAIAudioRouteState)state;

/**
 * @brief Create a route snapshot with fallback information
 * @chinese 创建带回退信息的路由快照
 * @param fallbackReason EN: Why the effective route differs. CN: 实际路由不同的原因。
 * @param fallbackDetail EN: Debug detail. CN: 调试信息。
 */
+ (instancetype)snapshotWithFeature:(TSAIFeatureOptions)feature
                     requestedRoute:(TSAIAudioRouteConfiguration *)requestedRoute
                     effectiveRoute:(TSAIAudioRouteConfiguration *)effectiveRoute
                              state:(TSAIAudioRouteState)state
                     fallbackReason:(TSAIAudioRouteFallbackReason)fallbackReason
                     fallbackDetail:(nullable NSString *)fallbackDetail;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
