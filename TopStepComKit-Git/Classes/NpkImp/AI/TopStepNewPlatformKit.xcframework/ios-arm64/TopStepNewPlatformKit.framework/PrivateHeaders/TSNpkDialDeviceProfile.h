//
//  TSNpkDialDeviceProfile.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TopStepInterfaceKit/TSPeripheralScreen.h>
#import "TSNpkPlatform.h"

@class TSPeripheral;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Snapshot of the device facts dial building depends on
 * @chinese 造包所依赖的设备信息快照
 *
 * @discussion
 * [EN]: Taken once when a build starts, so a disconnect in the middle of a build cannot change or blank these values.
 * [CN]: 造包开始时拍一次快照，造包过程中设备断开也不会让这些值变化或变空。
 */
@interface TSNpkDialDeviceProfile : NSObject

/**
 * @brief Device platform captured when creating the profile
 * @chinese 创建快照时捕获的设备平台
 *
 * @discussion
 * [EN]: A validated LVGL W30, LVGL 579X or GUI 579X device value. Unknown values cannot create a profile.
 * [CN]: 已校验的 LVGL W30、LVGL 579X 或 GUI 579X 设备平台；未知值不能生成快照。
 */
@property (nonatomic, assign, readonly) TSNpkPlatform platform;
/**
 * @brief Screen size in pixels
 * @chinese 屏幕像素尺寸
 *
 * @discussion
 * [EN]: Captured from screenInfo; both dimensions must be finite and greater than zero.
 * [CN]: 取自 screenInfo，宽高均须为有限正数，供背景资源和屏幕布局使用。
 */
@property (nonatomic, assign, readonly) CGSize screenSize;
/**
 * @brief Screen corner radius in pixels
 * @chinese 屏幕圆角半径，单位像素
 *
 * @discussion
 * [EN]: Captured from screenBorderRadius; finite and nonnegative. Zero means square corners.
 * [CN]: 取自 screenBorderRadius，须为有限非负数；0 表示直角。
 */
@property (nonatomic, assign, readonly) CGFloat screenCornerRadius;
/**
 * @brief Embedded dial preview size in pixels
 * @chinese 包内表盘预览图的像素尺寸
 *
 * @discussion
 * [EN]: Captured from dialPreviewSize; both dimensions must be finite and positive.
 * [CN]: 取自 dialPreviewSize，宽高均须为有限正数，不等同于手机预览图的输出合同。
 */
@property (nonatomic, assign, readonly) CGSize previewSize;
/**
 * @brief Embedded preview corner radius in pixels
 * @chinese 包内预览图圆角半径，单位像素
 *
 * @discussion
 * [EN]: Captured from dialPreviewBorderRadius; finite and nonnegative, with zero for square corners.
 * [CN]: 取自 dialPreviewBorderRadius，须为有限非负数；0 表示直角。
 */
@property (nonatomic, assign, readonly) CGFloat previewCornerRadius;
/**
 * @brief Raw dial feature bits
 * @chinese 原始表盘特性位
 *
 * @discussion
 * [EN]: Preserves npkDialFeatures at capture time, including bits not interpreted by this SDK.
 * [CN]: 保留捕获时的 npkDialFeatures，包括当前 SDK 尚未解释的位。
 */
@property (nonatomic, assign, readonly) NSUInteger rawFeatures;
/**
 * @brief Component presence captured from the feature bits
 * @chinese 从特性位捕获的组件存在状态
 *
 * @discussion
 * [EN]: YES when bit 0 of rawFeatures is 0; NO when it is 1. This fact is not the final build capability.
 * [CN]: rawFeatures 第 0 位为 0 时为 YES，为 1 时为 NO；该事实不等同于最终造包能力。
 */
@property (nonatomic, assign, readonly) BOOL hasComponent;
/**
 * @brief Video encoding size in pixels
 * @chinese 视频编码尺寸，单位像素
 *
 * @discussion
 * [EN]: Uses npkDialVideoSize when both dimensions are finite and positive; otherwise uses screenSize.
 * [CN]: npkDialVideoSize 宽高均为有限正数时使用原值，否则回退为 screenSize。
 */
@property (nonatomic, assign, readonly) CGSize videoSize;
/**
 * @brief Video corner radius in target pixels
 * @chinese 视频目标画布中的圆角半径，单位像素
 *
 * @discussion
 * [EN]: Uses a finite nonnegative video radius only with valid video dimensions; otherwise uses screenCornerRadius.
 * [CN]: 仅当视频尺寸有效且视频圆角为有限非负数时使用原值，否则回退为 screenCornerRadius。
 */
@property (nonatomic, assign, readonly) CGFloat videoCornerRadius;
/**
 * @brief Captured screen shape
 * @chinese 捕获的屏幕外形
 *
 * @discussion
 * [EN]: Copies screenInfo.shape for shape-sensitive preview and media rendering.
 * [CN]: 复制 screenInfo.shape，供依赖外形的预览与媒体渲染使用。
 */
@property (nonatomic, assign, readonly) TSPeriphShape screenShape;
/**
 * @brief Captured device identifier
 * @chinese 捕获时的设备标识
 *
 * @discussion
 * [EN]: Uses systemInfo.uuid, then mac when nil, then an empty string; it is not the build task token.
 * [CN]: 优先使用 systemInfo.uuid，为 nil 时依次回退至 mac 和空字符串；不是构建任务标识。
 */
@property (nonatomic, copy, readonly) NSString *peripheralIdentifier;
/**
 * @brief Raw face-push support
 * @chinese 原始表盘推送能力
 *
 * @discussion
 * [EN]: Copies isSupportFacePush; the capability resolver combines this fact with platform restrictions.
 * [CN]: 复制 isSupportFacePush；能力解析器还会结合平台限制决定可用功能。
 */
@property (nonatomic, assign, readonly) BOOL supportsFacePush;
/**
 * @brief Raw custom-face support
 * @chinese 原始自定义表盘能力
 *
 * @discussion
 * [EN]: Copies isSupportCustomFace at capture time; it does not independently authorize every build mode.
 * [CN]: 复制捕获时的 isSupportCustomFace，不单独代表所有造包模式均可用。
 */
@property (nonatomic, assign, readonly) BOOL supportsCustomFace;
/**
 * @brief Raw slideshow support
 * @chinese 原始相册表盘能力
 *
 * @discussion
 * [EN]: Copies isSupportSlideshowFace; component and platform rules are applied separately.
 * [CN]: 复制 isSupportSlideshowFace，组件与平台规则由能力解析器另行处理。
 */
@property (nonatomic, assign, readonly) BOOL supportsSlideshow;
/**
 * @brief Captured installable dial count limit
 * @chinese 捕获的可安装表盘数量上限
 *
 * @discussion
 * [EN]: Copies maxPushDialCount, converting TSUnLimitNum to -1 to represent no declared count limit.
 * [CN]: 取自 maxPushDialCount；TSUnLimitNum 转为 -1，表示未声明数量上限。
 */
@property (nonatomic, assign, readonly) NSInteger maxInstallCount;
/**
 * @brief Captured built-in dial count limit
 * @chinese 捕获的内置表盘数量上限
 *
 * @discussion
 * [EN]: Copies maxInnerDialCount, converting TSUnLimitNum to -1; it is a count rather than a slot identifier.
 * [CN]: 取自 maxInnerDialCount，TSUnLimitNum 转为 -1；此值表示数量而非槽位编号。
 */
@property (nonatomic, assign, readonly) NSInteger maxInnerCount;

/**
 * @brief Snapshot of the currently connected peripheral
 * @chinese 对当前已连接设备拍快照
 *
 * @return EN: nil when no device is connected or its screen information is invalid. CN: 未连接设备或屏幕信息无效时返回 nil。
 */
+ (nullable instancetype)currentProfileWithError:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Snapshot of a given peripheral
 * @chinese 对指定设备拍快照
 */
+ (nullable instancetype)profileWithPeripheral:(nullable TSPeripheral *)peripheral
                                         error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
