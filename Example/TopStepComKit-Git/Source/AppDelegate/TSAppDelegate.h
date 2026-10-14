//
//  TSAppDelegate.h
//  TopStepComKit
//
//  Created by rd@hetangsmart.com on 12/23/2024.
//  Copyright (c) 2024 rd@hetangsmart.com. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

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

@end

NS_ASSUME_NONNULL_END
