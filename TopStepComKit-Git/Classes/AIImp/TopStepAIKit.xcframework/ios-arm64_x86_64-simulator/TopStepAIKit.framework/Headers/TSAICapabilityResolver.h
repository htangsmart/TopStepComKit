//
//  TSAICapabilityResolver.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAIContextDefines.h"

@class TSAIStartEligibility;
@class TSAIStartRequest;
@protocol TSAIDeviceAICapabilityProviding;
@protocol TSAIServiceCapabilityProviding;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Pure resolver combining service, device and runtime start requirements
 * @chinese 组合服务、设备与运行时启动要求的纯资格解析器
 */
@interface TSAICapabilityResolver : NSObject

/**
 * @brief Create a resolver from independent capability providers
 * @chinese 使用相互独立的能力提供者创建解析器
 * @param serviceCapabilityProvider EN: AI service capability provider. CN: AI 服务能力提供者。
 * @param deviceCapabilityProvider EN: Device capability provider, or nil. CN: 设备能力提供者，可为 nil。
 * @return EN: Initialized resolver. CN: 初始化后的解析器。
 */
- (instancetype)initWithServiceCapabilityProvider:
        (nullable id<TSAIServiceCapabilityProviding>)serviceCapabilityProvider
                            deviceCapabilityProvider:
        (nullable id<TSAIDeviceAICapabilityProviding>)deviceCapabilityProvider
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Evaluate a complete request without causing side effects
 * @chinese 在不产生副作用的前提下校验完整请求
 * @param request EN: Immutable start request. CN: 不可变启动请求。
 * @param contextState EN: Current Context state. CN: 当前 Context 状态。
 * @param authorizationState EN: Current Provider authorization. CN: 当前 Provider 鉴权状态。
 * @param deviceConnected EN: Current device connection fact. CN: 当前设备连接事实。
 * @param hostRouteSupported EN: Whether the exact host route is available. CN: 精确 Host 路由是否可用。
 * @param deviceSessionTransportAvailable EN: Whether the bridge can synchronize sessions. CN: Bridge 是否具备会话同步传输。
 * @param deviceHandlerAvailable EN: Whether a device-origin handler is registered. CN: 是否已注册设备发起处理器。
 * @return EN: Exact binary eligibility. CN: 精确的二态启动资格。
 */
- (TSAIStartEligibility *)eligibilityForRequest:(TSAIStartRequest *)request
                                   contextState:(TSAIContextState)contextState
                             authorizationState:(TSAIAuthorizationState)authorizationState
                                deviceConnected:(BOOL)deviceConnected
                             hostRouteSupported:(BOOL)hostRouteSupported
                deviceSessionTransportAvailable:(BOOL)deviceSessionTransportAvailable
                         deviceHandlerAvailable:(BOOL)deviceHandlerAvailable;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
