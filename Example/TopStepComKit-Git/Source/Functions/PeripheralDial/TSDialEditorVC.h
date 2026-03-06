//
//  TSDialEditorVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Watch face editor view controller — final step of the custom dial creation flow
 * @chinese 表盘编辑控制器 — 自定义表盘制作流程的最后一步
 *
 * @discussion
 * [EN]: Displays a live preview of the custom dial with the user's chosen background
 *       (image or video). Allows selection of time display position (top/bottom/left/right)
 *       and time text color. Pushes the configured custom dial to the device when the
 *       user taps "设置为当前表盘". Dismisses the entire navigation controller on success.
 * [CN]: 展示带用户选定背景（图片或视频）的表盘实时预览。
 *       支持选择时间显示位置（上/下/左/右）和时间文字颜色。
 *       用户点击「设置为当前表盘」后将自定义表盘推送至设备，
 *       成功后关闭整个导航控制器。
 */
@interface TSDialEditorVC : TSBaseVC

/**
 * @brief Initialize with a static background image.
 * @chinese 使用静态背景图片初始化。
 *
 * @param image
 * EN: Cropped background image for the custom dial.
 * CN: 自定义表盘的已裁剪背景图片。
 *
 * @param dialSize
 * EN: Target dial size in pixels (used to validate push compatibility).
 * CN: 目标表盘像素尺寸（用于推送兼容性校验）。
 *
 * @return
 * EN: A new TSDialEditorVC configured for single-image dial.
 * CN: 配置为单图表盘的新 TSDialEditorVC 实例。
 */
- (instancetype)initWithImage:(UIImage *)image dialSize:(CGSize)dialSize;

/**
 * @brief Initialize with a background video.
 * @chinese 使用背景视频初始化。
 *
 * @param videoURL
 * EN: URL of the trimmed background video for the custom video dial.
 * CN: 自定义视频表盘的已裁剪背景视频 URL。
 *
 * @param dialSize
 * EN: Target dial size in pixels.
 * CN: 目标表盘像素尺寸。
 *
 * @return
 * EN: A new TSDialEditorVC configured for video dial.
 * CN: 配置为视频表盘的新 TSDialEditorVC 实例。
 */
- (instancetype)initWithVideoURL:(NSURL *)videoURL dialSize:(CGSize)dialSize;

/**
 * @brief Callback invoked after the custom dial is successfully pushed.
 * @chinese 自定义表盘成功推送后的回调。
 *
 * @discussion
 * [EN]: Called on the main thread after the navigation controller is dismissed.
 *       Typically used to refresh the parent TSPeripheralDialVC.
 * [CN]: 在导航控制器 dismiss 之后在主线程调用，通常用于刷新 TSPeripheralDialVC。
 */
@property (nonatomic, copy, nullable) void(^onPushSuccess)(void);

@end

NS_ASSUME_NONNULL_END
