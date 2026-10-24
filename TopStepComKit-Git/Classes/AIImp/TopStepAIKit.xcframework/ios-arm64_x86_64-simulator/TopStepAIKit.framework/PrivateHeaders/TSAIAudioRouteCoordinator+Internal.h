//
//  TSAIAudioRouteCoordinator+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"
#import "TSAIAudioRoutingInterface.h"
#import "TSAIDeviceBridge.h"

@class TSAIAudioRouteConfiguration;
@class TSAIDeviceEarbudsStatus;
@protocol TSAISystemAudioDriver;
@protocol TSAIAudioSessionControlling;

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
 * @brief Features whose Provider accepts phone-captured PCM (external PCM entry)
 * @chinese Provider 具备外部 PCM 入口、可由手机侧采集的功能
 *
 * @discussion
 * EN: Set by the Context after binding Providers. Together with the product's companion earbuds
 *     it decides whether the phone can capture the earbuds microphone (HFP) for a feature.
 * CN: 由 Context 在绑定 Provider 后设置；与产品是否带配套耳机共同决定某功能能否由手机采集耳机麦（HFP）。
 */
@property (atomic, assign) TSAIFeatureOptions hostCaptureFeatures;

/**
 * @brief Whether AIKit may manage the audio session for earbuds capture, default YES
 * @chinese 是否允许 AIKit 为耳机采集管理音频会话，默认 YES
 *
 * @discussion
 * EN: NO when the App manages the audio session itself (AppManaged policy).
 * CN: App 自行管理音频会话（AppManaged 策略）时为 NO。
 */
@property (atomic, assign) BOOL hostEarbudsCaptureAllowed;

/**
 * @brief Latest wear state reported by the charging case, nil before the first report
 * @chinese 充电仓最近一次上报的佩戴状态；首次上报前为 nil
 */
@property (atomic, strong, nullable) TSAIDeviceEarbudsStatus *earbudsStatus;

/**
 * @brief Audio session read when computing the earbuds microphone status (tests inject one)
 * @chinese 计算耳机麦克风状态时读取的音频会话（默认系统会话，单测注入）
 */
@property (atomic, strong) id<TSAIAudioSessionControlling> earbudsAudioSession;

/**
 * @brief Start observing earbuds wear state, audio route and App activation (idempotent)
 * @chinese 开始监听耳机佩戴状态、音频路由与 App 回到前台（幂等）
 *
 * @discussion
 * EN: Called by the Context after Providers are bound; posts the initial statuses.
 * CN: 由 Context 在绑定 Provider 后调用；会发出初始状态通知。
 */
- (void)startObservingEarbuds;

/**
 * @brief Stop observing earbuds state (Context teardown)
 * @chinese 停止监听耳机状态（Context 销毁时调用；设备断开不调用，重连后继续发通知）
 */
- (void)stopObservingEarbuds;

/**
 * @brief Recompute the earbuds microphone status of every earbuds feature and post changes
 * @chinese 重新计算各耳机功能的耳机麦克风状态，变化时发通知
 */
- (void)publishEarbudsMicrophoneStatusIfChanged;

/**
 * @brief Whether an AI audio session currently holds the route
 * @chinese 当前是否有 AI 音频会话占用路由
 */
- (BOOL)hasActiveSession;

/**
 * @brief Hold the route exclusively for a feature without a route capability table
 * @chinese 为没有路由能力表的功能（如麦克风语音识别）独占路由
 *
 * @discussion
 * EN: Other AI audio sessions get 1007 while held; release with endSessionWithIdentifier:.
 * CN: 占用期间其他 AI 音频会话返回 1007；用 endSessionWithIdentifier: 释放。
 */
- (BOOL)beginExclusiveSessionForFeature:(TSAIFeatureOptions)feature
                                  route:(TSAIAudioRouteConfiguration *)route
                      sessionIdentifier:(NSString *)sessionIdentifier
                                  error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Whether the connected device can report the earbuds wearing state
 * @chinese 已连接设备能否上报耳机佩戴状态
 */
- (BOOL)isEarbudsStatusAvailable;

/**
 * @brief Whether the device AI audio channel is SCO (the device itself owns the HFP link)
 * @chinese 设备 AI 音频通道是否为 SCO（HFP 链路由设备本身提供，如 SCO 固件手表）
 */
- (BOOL)isDeviceAudioChannelSCO;

/**
 * @brief Complete AI audio channel currently declared by the connected device
 * @chinese 已连接设备当前声明的完整 AI 音频通道；未连接时为 Unknown
 */
- (TSAIDeviceBridgeChatAudioChannel)deviceAudioChannel;

/**
 * @brief Whether the phone can capture the companion earbuds microphone for a feature
 * @chinese 某功能能否由手机采集配套耳机麦克风
 *
 * @discussion
 * EN: Connected, product has companion earbuds, the feature's Provider accepts external PCM,
 *     and AIKit manages the audio session. Static support only; whether the earbuds are worn
 *     right now is checked when the session starts.
 * CN: 已连接、产品带配套耳机、该功能的 Provider 有外部 PCM 入口、且由 AIKit 管理音频会话。
 *     只表示静态支持；耳机此刻是否可用在会话开始时校验。
 */
- (BOOL)isHostEarbudsCaptureSupportedForFeature:(TSAIFeatureOptions)feature;

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
 * @brief Resolve an exact route without acquiring a session lease
 * @chinese 解析精确路由但不占用会话资源
 * @param feature EN: Exactly one audio AI feature. CN: 单个音频 AI 功能。
 * @param configuration EN: Requested route; nil means legacy automatic route. CN: 请求路由；nil 表示旧版自动路由。
 * @param error EN: Resolution error. CN: 路由解析错误。
 * @return EN: Resolved route without side effects, or nil. CN: 无副作用的解析结果；失败时为 nil。
 */
- (nullable TSAIAudioRouteConfiguration *)resolveRouteForFeature:
        (TSAIFeatureOptions)feature
                                               configuration:
        (nullable TSAIAudioRouteConfiguration *)configuration
                                                       error:
        (NSError * _Nullable * _Nullable)error;

/**
 * @brief Resolve an exact route and report why it differs from the request
 * @chinese 解析精确路由，并返回实际路由与请求不同的原因
 * @param fallbackReason EN: Receives the fallback reason; may be NULL. CN: 回退原因，可为 NULL。
 * @param fallbackDetail EN: Receives the unavailable reason of the requested pair; may be NULL. CN: 请求路由不可用的原因，可为 NULL。
 */
- (nullable TSAIAudioRouteConfiguration *)resolveRouteForFeature:
        (TSAIFeatureOptions)feature
                                               configuration:
        (nullable TSAIAudioRouteConfiguration *)configuration
                                              fallbackReason:
        (nullable TSAIAudioRouteFallbackReason *)fallbackReason
                                              fallbackDetail:
        (NSString * _Nullable * _Nullable)fallbackDetail
                                                       error:
        (NSError * _Nullable * _Nullable)error;

/**
 * @brief Acquire an already-resolved exact route while recording the original request
 * @chinese 占用已解析的精确路由，快照中保留调用方的原始请求与回退原因
 *
 * @discussion
 * EN: Used when a facade resolves first (to coordinate with the device) and acquires later.
 *     The exact route is re-validated with the Fail policy.
 * CN: 门面先解析（用于与设备协同）、后占用时使用；精确路由按 Fail 策略重新校验。
 */
- (nullable TSAIAudioRouteConfiguration *)beginSessionForFeature:
        (TSAIFeatureOptions)feature
                                                   exactRoute:
        (TSAIAudioRouteConfiguration *)exactRoute
                                               requestedRoute:
        (nullable TSAIAudioRouteConfiguration *)requestedRoute
                                               fallbackReason:
        (TSAIAudioRouteFallbackReason)fallbackReason
                                               fallbackDetail:
        (nullable NSString *)fallbackDetail
                                            sessionIdentifier:(NSString *)sessionIdentifier
                                                        error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Return whether the host can prepare a requested device-session route
 * @chinese 返回 Host 是否能够准备请求的设备会话路由
 * @param feature EN: Exact audio feature identity. CN: 精确音频功能标识。
 * @param configuration EN: Fully resolved requested route. CN: 已完整解析的请求路由。
 * @return EN: YES when required host transports exist before device activation. CN: 设备激活前所需 Host 传输均存在时返回 YES。
 */
- (BOOL)canPrepareDeviceSessionRouteForFeature:(TSAIFeatureOptions)feature
                                 configuration:(TSAIAudioRouteConfiguration *)configuration;

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
