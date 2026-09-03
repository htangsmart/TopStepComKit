//
//  TSAIAudioRouteCapability.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"
#import "TSAIFeatureDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Capability and current availability of one complete audio route
 * @chinese 一条完整音频路由的能力及当前可用状态
 */
@interface TSAIAudioRouteCapability : NSObject <NSCopying>

/** @brief Input side of the complete route @chinese 完整路由的输入侧 */
@property (nonatomic, assign, readonly) TSAIAudioInputChannel inputChannel;

/** @brief Output side of the complete route @chinese 完整路由的输出侧 */
@property (nonatomic, assign, readonly) TSAIAudioOutputChannel outputChannel;

/** @brief Features supported by this route @chinese 此路由支持的业务能力 */
@property (nonatomic, assign, readonly) TSAIFeatureOptions supportedFeatures;

/** @brief Whether the route is currently available @chinese 此路由当前是否可用 */
@property (nonatomic, assign, readonly) BOOL isAvailable;

/** @brief Whether the route can run full duplex @chinese 此路由是否支持全双工 */
@property (nonatomic, assign, readonly) BOOL supportsFullDuplex;

/** @brief Effective echo-cancellation mode @chinese 实际回声消除方式 */
@property (nonatomic, assign, readonly) TSAIAudioEchoCancellationMode echoCancellationMode;

/** @brief Diagnostic reason when unavailable @chinese 不可用时的诊断原因 */
@property (nonatomic, copy, readonly, nullable) NSString *unavailableReason;

/**
 * @brief Create a complete route capability
 * @chinese 创建完整路由能力
 * @param inputChannel EN: Input channel. CN: 输入通道。
 * @param outputChannel EN: Output channel. CN: 输出通道。
 * @param supportedFeatures EN: Supported AI features. CN: 支持的 AI 功能。
 * @param isAvailable EN: Current availability. CN: 当前是否可用。
 * @param supportsFullDuplex EN: Full-duplex support. CN: 是否支持全双工。
 * @param echoCancellationMode EN: Echo-cancellation mode. CN: 回声消除方式。
 * @param unavailableReason EN: Optional diagnostic reason. CN: 可选的不可用诊断原因。
 * @return EN: A new immutable capability. CN: 新的不可变能力对象。
 */
+ (instancetype)capabilityWithInputChannel:(TSAIAudioInputChannel)inputChannel
                             outputChannel:(TSAIAudioOutputChannel)outputChannel
                         supportedFeatures:(TSAIFeatureOptions)supportedFeatures
                               isAvailable:(BOOL)isAvailable
                        supportsFullDuplex:(BOOL)supportsFullDuplex
                      echoCancellationMode:(TSAIAudioEchoCancellationMode)echoCancellationMode
                         unavailableReason:(nullable NSString *)unavailableReason;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
