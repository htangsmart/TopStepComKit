//
//  TSDemoModuleCenter.h
//  TopStepComKit_Example
//
//  Created by Claude on 2026/10/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TSDemoModule.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Registry of optional Demo modules and dispatcher of main-project events
 * @chinese Demo 可选模块的注册表，并把主工程事件转发给各模块
 *
 * @discussion
 * [EN]: Modules are looked up by class name with NSClassFromString. A module whose sources were excluded
 *       by the Podfile switch simply does not exist at runtime and is skipped, so the main project never
 *       needs #if or direct references to optional modules.
 * [CN]: 按类名用 NSClassFromString 查找模块。被 Podfile 开关排除的模块运行时不存在，会被自动跳过，
 *       因此主工程不需要 #if，也不直接引用任何可选模块。
 */
@interface TSDemoModuleCenter : NSObject <NSCopying, NSMutableCopying>

/**
 * @brief Shared module center
 * @chinese 模块中心单例
 *
 * @return
 * EN: Shared instance
 * CN: 单例
 */
+ (instancetype)sharedInstance;

/**
 * @brief Modules loaded into this build, in registration order
 * @chinese 当前构建中已加载的模块，按登记顺序排列
 */
@property (nonatomic, copy, readonly) NSArray<id<TSDemoModule>> *modules;

/**
 * @brief Create all modules compiled into this build
 * @chinese 创建当前构建中已编译进来的全部模块
 *
 * @param host
 * EN: Capabilities provided by the main project
 * CN: 主工程提供的能力
 *
 * @discussion
 * [EN]: Call once on the main thread before the device coordinator starts, so that modules never miss
 *       the first device-ready event. Later calls are ignored.
 * [CN]: 在设备协调器启动之前于主线程调用一次，保证模块不会错过第一次设备就绪事件。重复调用会被忽略。
 */
- (void)startWithHost:(id<TSDemoModuleHost>)host;

/**
 * @brief Find a loaded module by name
 * @chinese 按模块名查找已加载的模块
 *
 * @param moduleName
 * EN: Module name such as @"AI"
 * CN: 模块名，例如 @"AI"
 *
 * @return
 * EN: Module instance; nil when the module is not compiled into this build
 * CN: 模块实例；该模块没有编译进当前构建时返回 nil
 */
- (nullable id<TSDemoModule>)moduleNamed:(NSString *)moduleName;

/**
 * @brief Forward that the main tab bar has loaded its tabs
 * @chinese 转发「主 TabBar 已完成标签页加载」
 */
- (void)notifyMainInterfaceDidLoad;

/**
 * @brief Forward that the app became active
 * @chinese 转发「App 回到活跃状态」
 */
- (void)notifyApplicationDidBecomeActive;

/**
 * @brief Forward a public network probe result
 * @chinese 转发公网探测结果
 *
 * @param isAvailable
 * EN: YES if public network access is available
 * CN: 公网是否可用
 */
- (void)notifyPublicNetworkAccessDidUpdate:(BOOL)isAvailable;

/**
 * @brief Forward that the network path became reachable again
 * @chinese 转发「网络路径恢复可用」
 */
- (void)notifyNetworkPathDidBecomeReachable;

/**
 * @brief Forward a new ready device session
 * @chinese 转发新的设备就绪会话
 *
 * @param snapshot
 * EN: Ready connection snapshot, de-duplicated by connection generation
 * CN: 就绪的连接快照，已按连接代次去重
 */
- (void)notifyDeviceDidBecomeReady:(TSDeviceConnectionSnapshot *)snapshot;

/**
 * @brief Forward that a ready device session ended
 * @chinese 转发「已就绪的设备会话结束」
 */
- (void)notifyDeviceDidBecomeUnavailable;

/**
 * @brief Forward that the device binding was cleared
 * @chinese 转发「设备绑定记录已清除」
 */
- (void)notifyDeviceBindingDidClear;

/**
 * @brief Collect module menu items for a device menu section
 * @chinese 汇总各模块为某个设备菜单分组提供的菜单项
 *
 * @param section
 * EN: Target menu section
 * CN: 目标菜单分组
 *
 * @param snapshot
 * EN: Current connection snapshot
 * CN: 当前连接快照
 *
 * @return
 * EN: Items from all modules in registration order; empty when no module contributes
 * CN: 按登记顺序汇总的菜单项；没有模块提供时为空数组
 */
- (NSArray<TSValueModel *> *)deviceMenuItemsForSection:(TSDemoModuleMenuSection)section
                                              snapshot:(TSDeviceConnectionSnapshot *)snapshot;

@end

NS_ASSUME_NONNULL_END
