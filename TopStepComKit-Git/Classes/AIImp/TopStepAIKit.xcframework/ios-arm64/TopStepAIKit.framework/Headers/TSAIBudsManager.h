//
//  TSAIBudsManager.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/23.
//

#import <Foundation/Foundation.h>

#import "TSAIBudsConfiguration.h"
#import "TSAIContextDefines.h"
#import "TSAIContractDefines.h"

@class AIBudsAIDeviceInfoModel;
@protocol TSAIDeviceBridge;

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSAIBudsDataReceiver)(NSData *data);
typedef void(^TSAIBudsAuthorizationStateDidChangeHandler)(TSAIAuthorizationState state);

/**
 * @brief Context-owned AIBuds AI manager
 * @chinese Context 独立持有的 AIBuds AI 管理器
 *
 * @discussion
 * [EN]: Owns one Context's vendor, device and authentication state. The
 *       underlying vendor SDK may still use process-wide objects.
 * [CN]: 持有单个 Context 的厂商、设备与鉴权状态。底层厂商 SDK 仍可能使用进程级对象。
 */
@interface TSAIBudsManager : NSObject

/**
 * @brief Current manager configuration
 * @chinese 当前管理器配置
 */
@property (nonatomic, strong, readonly, nullable) TSAIBudsConfiguration *configuration;

/**
 * @brief Device bridge bound to this manager
 * @chinese 当前管理器绑定的设备桥接器
 */
@property (nonatomic, weak, readonly, nullable) id<TSAIDeviceBridge> deviceBridge;

/**
 * @brief Whether the AI manager has been configured
 * @chinese AI 管理器是否已完成配置
 */
@property (nonatomic, assign, readonly) BOOL isConfigured;

/**
 * @brief Whether this manager is attached to the global AIBuds runtime
 * @chinese 当前管理器是否已接入全局 AIBuds Runtime
 */
@property (nonatomic, assign, readonly) BOOL isInitialized;

/**
 * @brief Current provider authorization state
 * @chinese 当前 Provider 鉴权状态
 */
@property (nonatomic, assign, readonly) TSAIAuthorizationState authorizationState;

/**
 * @brief Callback for sending StarBurst bridge data
 * @chinese 发送 StarBurst 桥接数据的回调
 */
@property (nonatomic, copy, nullable) TSAIBudsDataReceiver dataReceiver;

/**
 * @brief Callback invoked when authorization state changes
 * @chinese 鉴权状态变化时调用的回调
 */
@property (nonatomic, copy, nullable)
    TSAIBudsAuthorizationStateDidChangeHandler authorizationStateDidChangeHandler;

/**
 * @brief Initialize a Context-owned manager
 * @chinese 创建一个 Context 独立持有的管理器
 *
 * @return
 * EN: A new manager instance
 * CN: 新的管理器实例
 */
- (instancetype)init;

/**
 * @brief Attach one Context to the process-wide AIBuds runtime
 * @chinese 将一个 Context 接入进程级 AIBuds Runtime
 *
 * @param configuration EN: AIBuds configuration. CN: AIBuds 配置。
 * @param deviceBridge
 * EN: Context-owned device bridge, held weakly.
 * CN: Context 持有的设备桥接器，本类弱引用。
 * @param completion EN: Runtime attachment completion. CN: Runtime 接入完成回调。
 */
- (void)initializeWithConfiguration:(TSAIBudsConfiguration *)configuration
                       deviceBridge:(id<TSAIDeviceBridge>)deviceBridge
                         completion:(TSAICompletionBlock)completion;

/**
 * @brief Whether a vendor SDK is linked into current app
 * @chinese 指定厂商 SDK 是否已链接到当前 App
 *
 * @param vendor
 * EN: AI vendor
 * CN: AI 厂商
 *
 * @return
 * EN: YES if linked
 * CN: 已链接返回 YES
 */
- (BOOL)isVendorLinked:(TSAIBudsVendorType)vendor;

/**
 * @brief Authenticate the AI service with device information when required
 * @chinese 使用设备信息按需鉴权 AI 服务
 *
 * @param deviceInfo
 * EN: AIBuds AI device information
 * CN: AIBuds AI 设备信息
 *
 * @param completion
 * EN: App-initiated mode reports the final result; device-initiated mode
 *     reports request acceptance, while authorizationState reports the result.
 * CN: App 发起模式回调最终结果；设备发起模式仅回调请求已受理，真实结果由
 *     authorizationState 上报。
 */
- (void)authenticateWithDeviceInfo:(AIBudsAIDeviceInfoModel *)deviceInfo
                        completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Prepare device-side authentication
 * @chinese 准备设备侧鉴权
 *
 * @param identifier EN: Current device identifier. CN: 当前设备标识。
 * @param dataReceiver EN: Optional bridge data receiver. CN: 可选的桥接数据接收回调。
 */
- (void)prepareAIAuthWithIdentifier:(NSString *)identifier
                       dataReceiver:(nullable TSAIBudsDataReceiver)dataReceiver;

/**
 * @brief Forward authentication data received from the device
 * @chinese 转发设备上报的鉴权数据
 *
 * @param data EN: Raw authentication data. CN: 原始鉴权数据。
 */
- (void)sendDeviceData:(NSData *)data;

/**
 * @brief Notify the vendor SDK that the current device connected
 * @chinese 通知厂商 SDK 当前设备已连接
 */
- (void)sendDeviceConnect;

/**
 * @brief Notify the vendor SDK that the current device disconnected
 * @chinese 通知厂商 SDK 当前设备已断开
 */
- (void)sendDeviceDisconnect;

/**
 * @brief Release all Context-owned bindings and reset state
 * @chinese 释放全部 Context 绑定并重置状态
 *
 * @discussion
 * [EN]: Invalidates delayed callbacks, detaches device blocks, reports
 *       Disconnected, then clears the state-change handler.
 * [CN]: 使迟到回调失效、解绑设备 Block、回报 Disconnected，随后清除状态变化回调。
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
