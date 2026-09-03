//
//  TSMapNamingModal.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Naming modal for the "download offline map" flow
 * @chinese 离线地图下载流程的命名弹窗
 *
 * @discussion
 * [EN]: An iOS-style centered modal with a title, a single text field (placeholder "请输出地图名称",
 *       max 20 chars), a cancel button and a confirm button. Validation is performed by the host on
 *       confirm; when validation fails the modal stays open and shows an inline red hint below the field.
 * [CN]: iOS 风格的居中弹窗，含标题、单个输入框（placeholder「请输出地图名称」，最多 20 字符）、取消按钮和确定按钮。
 *       校验在点击确定时由宿主执行；校验失败时弹窗保持打开，并在输入框下方展示内联红字提示。
 */
@interface TSMapNamingModal : UIView

/**
 * @brief Called when the user taps the confirm button
 * @chinese 用户点击确定按钮时回调
 *
 * @discussion
 * [EN]: The parameter is the trimmed input text. The host validates it and calls showError: to keep
 *       the modal open with a hint, or dismiss to close it.
 * [CN]: 参数为去除首尾空格后的输入文本。宿主对其校验后调用 showError: 保持弹窗并提示，或调用 dismiss 关闭。
 */
@property (nonatomic, copy, nullable) void (^onConfirm)(NSString *inputName);

/**
 * @brief Show the modal over a given view
 * @chinese 在指定视图上展示弹窗
 *
 * @param view
 * EN: The container view to present within (usually the controller's view)
 * CN: 承载弹窗的容器视图（通常是控制器的 view）
 */
- (void)showInView:(UIView *)view;

/**
 * @brief Show an inline error hint below the input field
 * @chinese 在输入框下方展示内联错误提示
 *
 * @param errorText
 * EN: The red hint text to show; the modal stays open
 * CN: 要展示的红色提示文本；弹窗保持打开
 */
- (void)showError:(NSString *)errorText;

/**
 * @brief Dismiss the modal
 * @chinese 关闭弹窗
 */
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
