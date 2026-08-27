//
//  TSCustomDialStyleConstraint.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/8/17.
//

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"
#import "TSPeripheralScreen.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Custom watch face time-style option
 * @chinese 自定义表盘时间样式选项
 */
@interface TSCustomDialStyleOption : TSKitBaseModel

/**
 * @brief Semantic time style
 * @chinese 语义化时间样式
 */
@property (nonatomic, assign, readonly) TSDialTimeStyle style;

/**
 * @brief Preview image URL
 * @chinese 预览图片地址
 *
 * @discussion
 * [EN]: The URL is either an HTTPS resource or a file URL owned by the SDK bundle.
 * [CN]: 地址只能是 HTTPS 资源或 SDK Bundle 持有的本地文件地址。
 */
@property (nonatomic, strong, readonly) NSURL *previewImageURL;

/**
 * @brief Style size in device pixels
 * @chinese 样式在设备像素坐标系中的尺寸
 */
@property (nonatomic, assign, readonly) CGSize size;

/**
 * @brief Initialize a time-style option
 * @chinese 初始化时间样式选项
 *
 * @param style EN: Semantic time style. CN: 语义化时间样式。
 * @param previewImageURL EN: Preview image URL. CN: 预览图片地址。
 * @param size EN: Style size in device pixels. CN: 样式的设备像素尺寸。
 * @return EN: Initialized option. CN: 初始化后的选项。
 */
- (instancetype)initWithStyle:(TSDialTimeStyle)style
              previewImageURL:(NSURL *)previewImageURL
                         size:(CGSize)size NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * @brief Custom watch face time-position option
 * @chinese 自定义表盘时间位置选项
 */
@interface TSCustomDialPositionOption : TSKitBaseModel

/**
 * @brief Semantic time position
 * @chinese 语义化时间位置
 */
@property (nonatomic, assign, readonly) TSDialTimePosition position;

/**
 * @brief Preview frame in the watch face screen coordinate system
 * @chinese 表盘屏幕坐标系中的预览区域
 */
@property (nonatomic, assign, readonly) CGRect frame;

/**
 * @brief Initialize a time-position option
 * @chinese 初始化时间位置选项
 *
 * @param position EN: Semantic time position. CN: 语义化时间位置。
 * @param frame EN: Preview frame in device pixels. CN: 设备像素坐标系中的预览区域。
 * @return EN: Initialized option. CN: 初始化后的选项。
 */
- (instancetype)initWithPosition:(TSDialTimePosition)position
                           frame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * @brief Custom watch face style constraint snapshot
 * @chinese 自定义表盘样式约束快照
 *
 * @discussion
 * [EN]: Contains provider-neutral style and position options for the currently connected device.
 *       Provider request parameters and template resources are intentionally not exposed.
 * [CN]: 包含当前连接设备的 Provider 无关样式与位置选项。
 *       不对外暴露 Provider 请求参数和模板资源。
 */
@interface TSCustomDialStyleConstraint : TSKitBaseModel

/**
 * @brief Watch face screen size in pixels
 * @chinese 表盘屏幕像素尺寸
 */
@property (nonatomic, assign, readonly) CGSize screenSize;

/**
 * @brief Watch face screen shape
 * @chinese 表盘屏幕形状
 */
@property (nonatomic, assign, readonly) TSPeriphShape screenShape;

/**
 * @brief Available time-style options
 * @chinese 可用的时间样式选项
 *
 * @note
 * [EN]: The array may be empty when the device supports background-only custom watch faces.
 * [CN]: 设备只支持纯背景自定义表盘时，数组可以为空。
 */
@property (nonatomic, copy, readonly) NSArray<TSCustomDialStyleOption *> *styles;

/**
 * @brief Available semantic time-position options
 * @chinese 可用的语义化时间位置选项
 */
@property (nonatomic, copy, readonly) NSArray<TSCustomDialPositionOption *> *positions;

/**
 * @brief Whether a caller may tint the time style
 * @chinese 是否允许调用方修改时间样式颜色
 */
@property (nonatomic, assign, readonly) BOOL allowColorTint;

/**
 * @brief Initialize a custom watch face style constraint
 * @chinese 初始化自定义表盘样式约束
 *
 * @param screenSize EN: Watch face screen size in pixels. CN: 表盘屏幕像素尺寸。
 * @param screenShape EN: Watch face screen shape. CN: 表盘屏幕形状。
 * @param styles EN: Available time-style options. CN: 可用时间样式选项。
 * @param positions EN: Available semantic time-position options. CN: 可用语义化时间位置选项。
 * @param allowColorTint EN: Whether time-style tinting is supported. CN: 是否支持时间样式着色。
 * @return EN: Initialized constraint snapshot. CN: 初始化后的约束快照。
 */
- (instancetype)initWithScreenSize:(CGSize)screenSize
                       screenShape:(TSPeriphShape)screenShape
                            styles:(NSArray<TSCustomDialStyleOption *> *)styles
                         positions:(NSArray<TSCustomDialPositionOption *> *)positions
                    allowColorTint:(BOOL)allowColorTint NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
