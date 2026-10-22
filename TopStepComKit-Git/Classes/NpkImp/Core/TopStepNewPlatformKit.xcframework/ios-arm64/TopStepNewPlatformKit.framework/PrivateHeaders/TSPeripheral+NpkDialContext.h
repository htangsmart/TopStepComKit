//
//  TSPeripheral+NpkDialContext.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import "TSNpkPlatform.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief NPK-private dial request context attached to a peripheral
 * @chinese 绑定到外设的 NPK 私有表盘请求上下文
 */
@interface TSPeripheral (NpkDialContext)

/**
 * @brief Device platform reported by the NPK protocol
 * @chinese NPK 协议上报的设备平台
 *
 * @discussion
 * [EN]: Read npkHasDialContext before use; zero is a valid W30 LVGL value
 *       and does not indicate whether device information has been received.
 * [CN]: 使用前需检查 npkHasDialContext；零是合法的 W30 LVGL 平台值，
 *       不能据此判断是否已收到设备信息。
 */
@property (nonatomic, assign) TSNpkPlatform npkDialPlatform;

/**
 * @brief Raw dial feature bitmap reported by the device
 * @chinese 设备上报的原始表盘特性位图
 *
 * @discussion
 * [EN]: Preserves every bit. A clear bit 0 indicates component presence;
 *       use npkHasDialContext to distinguish an assigned zero from missing information.
 * [CN]: 保留全部原始位；bit0 为零表示存在组件。
 *       需通过 npkHasDialContext 区分已赋值的零与尚未收到的信息。
 */
@property (nonatomic, assign) NSUInteger npkDialFeatures;

/**
 * @brief Whether both raw dial fields have been assigned
 * @chinese 是否已赋值两个原始表盘字段
 *
 * @discussion
 * [EN]: YES once platform and features both have stored values, including zero.
 *       This checks presence only; platform support and dimensions are validated separately.
 * [CN]: platform 和 features 均已存值时为 YES，零值也视为已赋值。
 *       这里只检查存在性，平台支持情况及尺寸合法性另行校验。
 */
@property (nonatomic, assign, readonly) BOOL npkHasDialContext;
/**
 * @brief Optional raw video dimensions in pixels
 * @chinese 可选的原始视频像素尺寸
 *
 * @discussion
 * [EN]: Independent of camera preview size and initially CGSizeZero. The device
 *       profile falls back to screen dimensions when these values are not finite and positive.
 * [CN]: 独立于相机预览尺寸，初始为 CGSizeZero；
 *       宽高不是有限正值时，设备快照回退到屏幕尺寸。
 */
@property (nonatomic, assign) CGSize npkDialVideoSize;
/**
 * @brief Raw video corner radius in target pixels
 * @chinese 原始视频圆角半径，单位为目标像素
 *
 * @discussion
 * [EN]: Initially 0. The profile uses this when video dimensions are valid and the
 *       radius is finite and nonnegative; otherwise it uses the screen corner radius.
 * [CN]: 初始 0；视频尺寸有效且半径为有限非负值时，快照使用本值，
 *       否则使用屏幕圆角半径。
 */
@property (nonatomic, assign) CGFloat npkDialVideoCornerRadius;

@end

NS_ASSUME_NONNULL_END
