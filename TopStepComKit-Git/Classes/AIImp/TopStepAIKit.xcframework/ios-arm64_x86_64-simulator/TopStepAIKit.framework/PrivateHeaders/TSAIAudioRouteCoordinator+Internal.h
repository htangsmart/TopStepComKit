//
//  TSAIAudioRouteCoordinator+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRoutingInterface.h"
#import "TSAIDeviceBridge.h"

@class TSAIAudioRouteConfiguration;
@protocol TSAISystemAudioDriver;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Resolves and freezes one complete route for each AI session
 * @chinese 为每个 AI 会话解析并冻结一条完整音频路由
 */
@interface TSAIAudioRouteCoordinator : NSObject <TSAIAudioRoutingInterface>

/**
 * @brief Create a coordinator bound to one device bridge
 * @chinese 创建绑定单个设备 Bridge 的路由协调器
 * @param deviceBridge EN: Active device bridge. CN: 当前设备 Bridge。
 * @return EN: A route coordinator. CN: 音频路由协调器。
 */
- (instancetype)initWithDeviceBridge:(id<TSAIDeviceBridge>)deviceBridge;

/**
 * @brief Create a coordinator with system-audio capability discovery
 * @chinese 创建带系统音频能力发现的路由协调器
 */
- (instancetype)initWithDeviceBridge:(id<TSAIDeviceBridge>)deviceBridge
                   systemAudioDriver:(nullable id<TSAISystemAudioDriver>)systemAudioDriver
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Resolve, acquire and freeze a route for one session
 * @chinese 为单次会话解析、占用并冻结音频路由
 * @param feature EN: Exactly one audio AI feature. CN: 单个音频 AI 功能。
 * @param configuration EN: Requested route; nil means legacy automatic route. CN: 请求路由；nil 表示旧版自动路由。
 * @param sessionIdentifier EN: Stable session lease identifier. CN: 稳定的会话占用标识。
 * @param error EN: Resolution error. CN: 路由解析错误。
 * @return EN: Frozen effective route, or nil on failure. CN: 冻结后的实际路由；失败时为 nil。
 */
- (nullable TSAIAudioRouteConfiguration *)beginSessionForFeature:
        (TSAIFeatureOptions)feature
                                                configuration:
        (nullable TSAIAudioRouteConfiguration *)configuration
                                           sessionIdentifier:(NSString *)sessionIdentifier
                                                       error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Release a previously acquired route
 * @chinese 释放已占用的音频路由
 * @param sessionIdentifier EN: Session lease identifier. CN: 会话占用标识。
 */
- (void)endSessionWithIdentifier:(NSString *)sessionIdentifier;

/**
 * @brief Mark an acquired route as interrupted without releasing its session lease
 * @chinese 将已占用路由标记为中断，但保留当前会话占用
 * @param sessionIdentifier EN: Session lease identifier. CN: 会话占用标识。
 */
- (void)markSessionInterruptedWithIdentifier:(NSString *)sessionIdentifier;

/**
 * @brief Update the latest complete route reported by a device event
 * @chinese 更新设备事件最近上报的完整路由
 * @param audioChannel EN: Reported complete device channel. CN: 上报的完整设备通道。
 */
- (void)updateReportedDeviceAudioChannel:
    (TSAIDeviceBridgeChatAudioChannel)audioChannel;

/** @brief Refresh route capabilities after device state changes @chinese 设备状态变化后刷新路由能力 */
- (void)refreshCapabilities;

/** @brief Invalidate every active route @chinese 使全部活动路由失效 */
- (void)invalidate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
