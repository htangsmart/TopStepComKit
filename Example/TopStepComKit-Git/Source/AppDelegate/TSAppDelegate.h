//
//  TSAppDelegate.h
//  TopStepComKit
//
//  Created by rd@hetangsmart.com on 12/23/2024.
//  Copyright (c) 2024 rd@hetangsmart.com. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/** @brief AI selection status changed on the main thread @chinese 主线程交付AI选择状态变化 */
FOUNDATION_EXPORT NSNotificationName const TSAIProviderSelectionDidChangeNotification;

@interface TSAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

/**
 * @brief Configure the initial interface for the specified application window
 * @chinese 为指定应用窗口配置初始界面
 *
 * @param window
 * EN: Window associated with the connected scene
 * CN: 与已连接场景关联的窗口
 */
- (void)configureInitialInterfaceWithWindow:(UIWindow *)window;

/**
 * @brief Retry the AI preparation flow (network probe / context activation / authentication) if it has not completed
 * @chinese 若 AI 准备流程（公网探测 / Context 激活 / 鉴权）尚未完成，则立即重试
 *
 * @discussion
 * EN: Call this when the user enters an AI feature while the AI context is not ready yet.
 *     Pending backoff retries are discarded and the flow restarts immediately; it is a no-op
 *     when no device is ready or the current device is already authenticated.
 * CN: 用户进入 AI 功能但 AI Context 尚未就绪时调用。会作废挂起的退避重试并立即重走流程；
 *     设备未就绪或当前设备已完成最终鉴权时不做任何事。
 */
- (void)retryAIPreparationIfNeeded;

/**
 * @brief Whether an in-memory YanJie configuration overrides device recommendations
 * @chinese 是否由内存中的岩界配置覆盖设备推荐
 */
@property (nonatomic, assign, readonly) BOOL usesExplicitYanJieConfiguration;

/**
 * @brief Safe current selection or activation status without credentials
 * @chinese 不包含凭证的当前选择或激活状态
 */
@property (nonatomic, copy, readonly) NSString *aiProviderSelectionStatus;

/**
 * @brief Copy the in-memory configuration when the product is installed
 * @chinese 已安装对应产品时复制内存配置
 * @return
 * EN: An opaque configuration snapshot, or nil in automatic mode.
 * CN: 不透明配置快照，自动模式为nil。
 */
- (nullable id)yanJieConfigurationSnapshot;

/**
 * @brief Select YanJie after normal Context teardown and start activation when connected
 * @chinese 正常停用旧Context后选择岩界，设备已连接时启动激活
 * @param configuration
 * EN: Installed YanJie configuration; credentials remain in memory only.
 * CN: 已安装的岩界配置，凭证仅保留在内存。
 * @param completion
 * EN: Selection/cleanup result on main; activation status is published separately.
 * CN: 主线程交付选择及清理结果，激活状态单独发布。
 */
- (void)selectYanJieConfiguration:(id)configuration completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

/**
 * @brief Restore device-recommended AIBuds selection after Context teardown
 * @chinese 正常停用Context后恢复设备推荐的AIBuds自动选择
 * @param completion
 * EN: Selection/cleanup result on main; missing AIBuds products fail explicitly.
 * CN: 主线程交付选择及清理结果，未安装AIBuds产品时明确失败。
 */
- (void)selectAutomaticAIProviderWithCompletion:(void (^)(BOOL success, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
