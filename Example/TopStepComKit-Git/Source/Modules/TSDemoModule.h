//
//  TSDemoModule.h
//  TopStepComKit_Example
//
//  Created by Claude on 2026/10/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSDeviceConnectionSnapshot;
@class TSValueModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device menu sections that optional modules can append items to
 * @chinese 可选模块可以追加菜单项的设备菜单分组
 */
typedef NS_ENUM(NSInteger, TSDemoModuleMenuSection) {
    /// EN: Device features. CN: 设备功能
    TSDemoModuleMenuSectionFeatures = 0,
    /// EN: System settings. CN: 系统设置
    TSDemoModuleMenuSectionSettings = 1,
    /// EN: Customer customizations. CN: 定制功能
    TSDemoModuleMenuSectionCustom = 2,
};

/**
 * @brief Capabilities the main project provides to optional modules
 * @chinese 主工程提供给可选模块的能力
 *
 * @discussion
 * [EN]: Implemented by TSAppDelegate. Modules talk to the main project only through this protocol,
 *       never by importing main-project controllers directly.
 * [CN]: 由 TSAppDelegate 实现。模块只通过本协议使用主工程能力，不直接引用主工程的页面控制器。
 */
@protocol TSDemoModuleHost <NSObject>

/**
 * @brief Root tab bar controller of the main interface
 * @chinese 主界面的根 TabBar 控制器
 *
 * @discussion
 * [EN]: Nil before the main interface is created.
 * [CN]: 主界面创建之前为 nil。
 */
@property (nonatomic, strong, readonly, nullable) UITabBarController *rootTabBarController;

/**
 * @brief Whether public network access has been verified
 * @chinese 公网访问是否已探测成功
 *
 * @discussion
 * [EN]: YES once the wireless-data authorization probe succeeds; stays YES afterwards.
 * [CN]: 无线数据授权探测成功后为 YES，此后保持 YES。
 */
@property (nonatomic, assign, readonly) BOOL isPublicNetworkAccessAvailable;

/**
 * @brief Return the device tab navigation controller when a page can be presented now
 * @chinese 当前可以展示页面时返回设备标签页的导航控制器
 *
 * @param featureName
 * EN: Feature name used only in logs
 * CN: 功能名称，仅用于日志
 *
 * @return
 * EN: Device navigation controller; nil when the app is inactive or tabs are not loaded yet, retry later
 * CN: 设备标签页导航控制器；App 未激活或标签页尚未加载时返回 nil，调用方应稍后重试
 */
- (nullable UINavigationController *)deviceNavigationControllerForPresentation:(NSString *)featureName;

/**
 * @brief Request public network access for a module that needs the network
 * @chinese 需要公网的模块请求公网访问
 *
 * @discussion
 * [EN]: Resets the backoff and probes immediately (an in-flight probe is reused). On failure the host
 *       retries with backoff until it succeeds or reaches the limit. Results arrive through
 *       -publicNetworkAccessDidUpdate:. No-op once access is available.
 * [CN]: 重置退避后立即探测（正在探测则复用）。失败后按退避自动重试，直到成功或达到上限。
 *       结果通过 -publicNetworkAccessDidUpdate: 回调。公网已可用时不做任何事。
 */
- (void)requestPublicNetworkAccess;

@end

/**
 * @brief Entry point of an optional Demo module
 * @chinese Demo 可选模块的入口
 *
 * @discussion
 * [EN]: Each optional module lives in Source/Modules/<Name>/ and provides one entry class conforming
 *       to this protocol, registered by class name in TSDemoModuleCenter. All hooks are optional and
 *       always called on the main thread; adding a new hook never breaks existing modules.
 * [CN]: 每个可选模块放在 Source/Modules/<名字>/ 下，提供一个遵循本协议的入口类，并在 TSDemoModuleCenter
 *       的类名清单中登记。所有钩子都是可选的，并且总在主线程调用；新增钩子不影响已有模块。
 */
@protocol TSDemoModule <NSObject>

@required

/**
 * @brief Module name, same as the key in the Podfile module switches
 * @chinese 模块名，与 Podfile 模块开关中的键一致
 *
 * @return
 * EN: Module name such as @"AI"
 * CN: 模块名，例如 @"AI"
 */
+ (NSString *)moduleName;

/**
 * @brief Create the module with the host capabilities
 * @chinese 使用主工程能力创建模块
 *
 * @param host
 * EN: Capabilities provided by the main project, held weakly by the module
 * CN: 主工程提供的能力，模块应弱引用持有
 *
 * @return
 * EN: Module instance
 * CN: 模块实例
 */
- (instancetype)initWithHost:(id<TSDemoModuleHost>)host;

@optional

/**
 * @brief Called after the main tab bar has loaded its tabs
 * @chinese 主 TabBar 完成标签页加载后调用
 */
- (void)mainInterfaceDidLoad;

/**
 * @brief Called each time the app becomes active
 * @chinese 每次 App 回到活跃状态时调用
 */
- (void)applicationDidBecomeActive;

/**
 * @brief Called when a public network probe finishes
 * @chinese 公网探测有结果时调用
 *
 * @param isAvailable
 * EN: YES if public network access is available
 * CN: 公网是否可用
 */
- (void)publicNetworkAccessDidUpdate:(BOOL)isAvailable;

/**
 * @brief Called when the network path changes from unavailable to available
 * @chinese 网络路径由不可用恢复为可用时调用
 */
- (void)networkPathDidBecomeReachable;

/**
 * @brief Called once for each new ready device session
 * @chinese 每个新的设备就绪会话调用一次
 *
 * @param snapshot
 * EN: Ready connection snapshot, already de-duplicated by connection generation
 * CN: 就绪的连接快照，已按连接代次去重
 */
- (void)deviceDidBecomeReady:(TSDeviceConnectionSnapshot *)snapshot;

/**
 * @brief Called when a previously ready device session ends
 * @chinese 之前就绪的设备会话结束时调用
 */
- (void)deviceDidBecomeUnavailable;

/**
 * @brief Called after the device binding record is cleared
 * @chinese 设备绑定记录被清除后调用
 */
- (void)deviceBindingDidClear;

/**
 * @brief Menu items appended to the end of a device menu section
 * @chinese 追加到设备菜单分组末尾的菜单项
 *
 * @param section
 * EN: Target menu section
 * CN: 目标菜单分组
 *
 * @param snapshot
 * EN: Current connection snapshot, used to decide whether items are enabled
 * CN: 当前连接快照，用于判断菜单项是否可用
 *
 * @return
 * EN: Items to append; empty array for none
 * CN: 要追加的菜单项；没有则返回空数组
 */
- (NSArray<TSValueModel *> *)deviceMenuItemsForSection:(TSDemoModuleMenuSection)section
                                              snapshot:(TSDeviceConnectionSnapshot *)snapshot;

@end

NS_ASSUME_NONNULL_END
