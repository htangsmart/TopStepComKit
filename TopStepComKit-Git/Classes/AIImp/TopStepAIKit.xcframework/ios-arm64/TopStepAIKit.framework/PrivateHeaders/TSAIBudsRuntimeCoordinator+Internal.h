//
//  TSAIBudsRuntimeCoordinator+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/14.
//

#import <Foundation/Foundation.h>

#import "TSAIBudsConfiguration.h"
#import "TSAIContractDefines.h"

@class AIBudsAIDeviceInfoModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Process-wide AIBuds runtime state
 * @chinese 进程级 AIBuds Runtime 状态
 */
typedef NS_ENUM(NSInteger, TSAIBudsRuntimeState) {
    /// Runtime has not been initialized (Runtime 尚未初始化)
    TSAIBudsRuntimeStateUninitialized = 0,
    /// Runtime initialization is in progress (Runtime 正在初始化)
    TSAIBudsRuntimeStateInitializing,
    /// Runtime has been initialized (Runtime 已初始化)
    TSAIBudsRuntimeStateInitialized,
};

/**
 * @brief Authentication mode exposed by the AIBuds runtime driver
 * @chinese AIBuds Runtime Driver 暴露的鉴权模式
 */
typedef NS_ENUM(NSInteger, TSAIBudsRuntimeAuthenticationMode) {
    /// Unknown authentication mode (未知鉴权模式)
    TSAIBudsRuntimeAuthenticationModeUnknown = -1,
    /// Authentication is not required (无需鉴权)
    TSAIBudsRuntimeAuthenticationModeNone = 0,
    /// Authentication is initiated by the device (设备发起鉴权)
    TSAIBudsRuntimeAuthenticationModeDeviceInitiated,
    /// Authentication is initiated by the App (App 发起鉴权)
    TSAIBudsRuntimeAuthenticationModeAppInitiated,
};

/**
 * @brief Driver boundary for process-wide AIBuds SDK operations
 * @chinese 进程级 AIBuds SDK 操作的 Driver 边界
 *
 * @discussion
 * [EN]: Production code uses the system driver. Tests inject an isolated fake
 *       driver without mutating the process-wide production singleton.
 * [CN]: 生产环境使用系统 Driver。测试通过独立实例注入 Fake Driver，
 *       不修改进程级生产单例。
 */
@protocol TSAIBudsRuntimeDriver <NSObject>

/**
 * @brief Return all linked built-in vendors
 * @chinese 返回全部已链接的内置厂商
 *
 * @return EN: Linked vendor mask. CN: 已链接厂商掩码。
 */
- (TSAIBudsVendorType)linkedVendorMask;

/**
 * @brief Initialize AIBudsAISDK with the selected linked vendors
 * @chinese 使用选中的已链接厂商初始化 AIBudsAISDK
 *
 * @param vendorMask EN: Vendor mask to register. CN: 需要注册的厂商掩码。
 * @return EN: YES when initialization succeeds. CN: 初始化成功返回 YES。
 */
- (BOOL)initializeRuntimeWithVendorMask:(TSAIBudsVendorType)vendorMask;

/**
 * @brief Select the process-wide AI service vendor
 * @chinese 选择进程级 AI 服务厂商
 *
 * @param vendor EN: Exactly one vendor. CN: 唯一目标厂商。
 */
- (void)setServiceVendor:(TSAIBudsVendorType)vendor;

/**
 * @brief Return the process-wide AI service vendor
 * @chinese 返回进程级 AI 服务厂商
 *
 * @return EN: Current vendor. CN: 当前厂商。
 */
- (TSAIBudsVendorType)serviceVendor;

/**
 * @brief Store device information in the process-wide SDK context
 * @chinese 在进程级 SDK Context 中保存设备信息
 *
 * @param deviceInfo EN: Current device information. CN: 当前设备信息。
 */
- (void)setDeviceInfo:(AIBudsAIDeviceInfoModel *)deviceInfo;

/**
 * @brief Return the authentication mode for a vendor
 * @chinese 返回指定厂商的鉴权模式
 *
 * @param vendor EN: Target vendor. CN: 目标厂商。
 * @return EN: Authentication mode. CN: 鉴权模式。
 */
- (TSAIBudsRuntimeAuthenticationMode)authenticationModeForVendor:(TSAIBudsVendorType)vendor;

/**
 * @brief Return the vendor SDK authentication snapshot
 * @chinese 返回厂商 SDK 的鉴权快照
 *
 * @param vendor EN: Target vendor. CN: 目标厂商。
 * @return EN: Vendor-reported authentication state. CN: 厂商上报的鉴权状态。
 */
- (BOOL)isAuthenticatedForVendor:(TSAIBudsVendorType)vendor;

/**
 * @brief Start App-initiated device authentication
 * @chinese 发起 App 侧设备鉴权
 *
 * @param deviceInfo EN: Current device information. CN: 当前设备信息。
 * @param vendor EN: Target vendor. CN: 目标厂商。
 * @param completion EN: Vendor authentication completion. CN: 厂商鉴权完成回调。
 */
- (void)authenticateDevice:(AIBudsAIDeviceInfoModel *)deviceInfo
                 forVendor:(TSAIBudsVendorType)vendor
                completion:(nullable TSAICompletionBlock)completion;

@end

/**
 * @brief Process-wide AIBuds runtime coordinator
 * @chinese 进程级 AIBuds Runtime 协调器
 *
 * @discussion
 * [EN]: Initializes AIBudsAISDK once after success, registers every linked
 *       built-in vendor, and serializes global vendor-dependent operations.
 * [CN]: AIBudsAISDK 成功后仅初始化一次，注册全部已链接内置厂商，
 *       并串行化依赖全局厂商路由的操作。
 */
@interface TSAIBudsRuntimeCoordinator : NSObject

/**
 * @brief Current runtime state
 * @chinese 当前 Runtime 状态
 */
@property (nonatomic, assign, readonly) TSAIBudsRuntimeState runtimeState;

/**
 * @brief Vendors registered during successful initialization
 * @chinese 成功初始化时注册的厂商集合
 */
@property (nonatomic, assign, readonly) TSAIBudsVendorType registeredVendorMask;

/**
 * @brief Vendor currently selected by the underlying SDK
 * @chinese 底层 SDK 当前选中的厂商
 */
@property (nonatomic, assign, readonly) TSAIBudsVendorType currentVendor;

/**
 * @brief Return the production process-wide coordinator
 * @chinese 返回生产环境进程级协调器
 *
 * @return EN: Shared coordinator. CN: 共享协调器。
 */
+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Create an isolated coordinator with an injected driver
 * @chinese 使用注入 Driver 创建独立协调器
 *
 * @param driver EN: Runtime driver. CN: Runtime Driver。
 * @return EN: Isolated coordinator instance. CN: 独立协调器实例。
 */
- (instancetype)initWithDriver:(id<TSAIBudsRuntimeDriver>)driver NS_DESIGNATED_INITIALIZER;

/**
 * @brief Whether all requested vendors are linked
 * @chinese 请求的厂商是否均已链接
 *
 * @param vendor EN: Requested vendor mask. CN: 请求的厂商掩码。
 * @return EN: YES when every requested vendor is linked. CN: 请求厂商均已链接时返回 YES。
 */
- (BOOL)isVendorLinked:(TSAIBudsVendorType)vendor;

/**
 * @brief Ensure the runtime is ready and select one Context vendor
 * @chinese 确保 Runtime 可用并选择一个 Context 厂商
 *
 * @param vendor EN: Exactly one Context vendor. CN: 唯一 Context 厂商。
 * @param error EN: Stable TopStepAIKit error on failure. CN: 失败时的稳定 TopStepAIKit 错误。
 * @return EN: YES when the vendor is active. CN: 厂商激活成功返回 YES。
 */
- (BOOL)activateVendor:(TSAIBudsVendorType)vendor
                 error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Whether the underlying SDK currently routes to a vendor
 * @chinese 底层 SDK 当前是否路由到指定厂商
 *
 * @param vendor EN: Exactly one vendor. CN: 唯一目标厂商。
 * @return EN: YES when the route matches. CN: 路由匹配时返回 YES。
 */
- (BOOL)isVendorActive:(TSAIBudsVendorType)vendor;

/**
 * @brief Perform one synchronous operation under an atomic vendor route
 * @chinese 在原子厂商路由下执行一个同步操作
 *
 * @param vendor EN: Exactly one vendor. CN: 唯一目标厂商。
 * @param operation
 * EN: Non-escaping synchronous operation executed after selecting the vendor.
 * CN: 选择厂商后执行的非逃逸同步操作。
 * @param error EN: Stable TopStepAIKit error on failure. CN: 失败时的稳定 TopStepAIKit 错误。
 * @return EN: YES when the operation was executed. CN: 操作已执行返回 YES。
 */
- (BOOL)performOperationForVendor:(TSAIBudsVendorType)vendor
                        operation:(void (NS_NOESCAPE ^)(void))operation
                            error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Select a vendor and store current device information
 * @chinese 选择厂商并保存当前设备信息
 * @param deviceInfo EN: Current device information. CN: 当前设备信息。
 * @param vendor EN: Exactly one vendor. CN: 唯一目标厂商。
 * @param error EN: Stable TopStepAIKit error on failure. CN: 失败时的稳定错误。
 * @return EN: YES when device information is stored. CN: 设备信息保存成功返回 YES。
 */
- (BOOL)prepareDeviceInfo:(AIBudsAIDeviceInfoModel *)deviceInfo
                forVendor:(TSAIBudsVendorType)vendor
                    error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Prepare and optionally start authentication for the current device
 * @chinese 为当前设备准备并按需发起鉴权
 *
 * @param vendor EN: Exactly one vendor. CN: 唯一目标厂商。
 * @param deviceInfo EN: Current device information. CN: 当前设备信息。
 * @param authenticationMode
 * EN: Output authentication mode. Unknown on failure.
 * CN: 输出鉴权模式。失败时为 Unknown。
 * @param completion
 * EN: Completion used only by App-initiated authentication.
 * CN: 仅用于 App 发起鉴权的完成回调。
 * @param error EN: Stable TopStepAIKit error on synchronous failure. CN: 同步失败错误。
 * @return EN: YES when authentication preparation succeeds. CN: 鉴权准备成功返回 YES。
 */
- (BOOL)beginAuthenticationForVendor:(TSAIBudsVendorType)vendor
                          deviceInfo:(AIBudsAIDeviceInfoModel *)deviceInfo
                  authenticationMode:(TSAIBudsRuntimeAuthenticationMode * _Nullable)authenticationMode
                          completion:(nullable TSAICompletionBlock)completion
                               error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
