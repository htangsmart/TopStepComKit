//
//  TSDialInstallSlotPicker.h
//  TopStepComKit_Example
//
//  Created by Claude on 2026/10/14.
//
//  文件说明:
//  安装表盘前让用户选择表盘位：设备支持指定表盘位时列出可安装的位，
//  否则直接按自动选位继续。

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Result of slot picking
 * @chinese 选位结果回调
 *
 * @param options
 * EN: nil means automatic selection; otherwise the user-picked target slot.
 * CN: 为 nil 表示自动选位；否则为用户选择的目标表盘位。
 *
 * @param cancelled
 * EN: YES when the user dismissed the picker, another pick is in progress, or the picker cannot be presented.
 * CN: 用户取消、已有选位进行中或无法弹出选择框时为 YES；调用方此时不应开始安装。
 */
typedef void (^TSDialInstallSlotPickerCompletion)(TSDialInstallOptions *_Nullable options, BOOL cancelled);

/**
 * @brief Watch face install slot picker for the demo
 * @chinese Demo 表盘安装选位器
 */
@interface TSDialInstallSlotPicker : NSObject

/**
 * @brief Let the user pick an install slot
 * @chinese 让用户选择安装表盘位
 *
 * @param viewController
 * EN: Presenting view controller.
 * CN: 用于弹出选择框的控制器。
 *
 * @param sourceView
 * EN: Anchor view for iPad popover; nil uses the controller's view.
 * CN: iPad 弹出框的锚点视图；为 nil 时使用控制器的 view。
 *
 * @param completion
 * EN: Called on the main thread exactly once.
 * CN: 在主线程回调且只回调一次。
 *
 * @discussion
 * EN: When isSupportInstallToSlot is NO or slots cannot be read, completes immediately with nil
 *     options (automatic selection) so the caller keeps the original install flow.
 * CN: isSupportInstallToSlot 为 NO 或读取表盘位失败时，立即以 nil（自动选位）回调，
 *     调用方保持原安装流程。
 */
+ (void)pickFromViewController:(UIViewController *)viewController
                    sourceView:(nullable UIView *)sourceView
                    completion:(TSDialInstallSlotPickerCompletion)completion;

@end

NS_ASSUME_NONNULL_END
