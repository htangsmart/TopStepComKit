//
//  TSMakeCustomDialVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Make and push custom watch face entry view controller
 * @chinese 制作并推送自定义表盘入口控制器
 *
 * @discussion
 * [EN]: Entry coordinator for the custom dial creation flow.
 *       Shows supported single-image, album, video and DanMu entry cards,
 *       then restores the independent session in one TSDialEditorVC.
 *       Must be presented inside a UINavigationController.
 * [CN]: 自定义表盘制作流程的入口协调器。
 *       显示设备支持的单图、多图、视频与弹幕入口卡片，
 *       各类型独立保留会话，进入统一的 TSDialEditorVC。
 *       必须在 UINavigationController 内呈现。
 */
@interface TSMakeCustomDialVC : TSBaseVC

/**
 * @brief Callback invoked after the custom dial is successfully pushed to the device.
 * @chinese 自定义表盘成功推送到设备后的回调。
 *
 * @discussion
 * [EN]: Called on the main thread when installation and current selection succeed.
 *       Use this to refresh the parent page.
 * [CN]: 安装并设置当前表盘成功后在主线程调用，用于刷新父页面，不自动关闭导航。
 */
@property (nonatomic, copy, nullable) void(^onPushSuccess)(void);

@end

NS_ASSUME_NONNULL_END
