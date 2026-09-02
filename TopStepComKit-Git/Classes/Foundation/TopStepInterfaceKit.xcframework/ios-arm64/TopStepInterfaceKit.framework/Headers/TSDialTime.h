//
//  TSDialTime.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/12/24.
//

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Dial time configuration model
 * @chinese 表盘时间配置模型
 *
 * @discussion
 * [EN]: Describes how the time element is rendered on one dial resource, including
 *       style image, position, rect, color and style id.
 * [CN]: 描述一个表盘资源上的时间元素渲染方式，包括样式图片、位置、区域、颜色和样式 id。
 */
@interface TSDialTime : TSKitBaseModel <NSCopying>

/**
 * @brief Time style image
 * @chinese 时间样式图片
 *
 * @discussion
 * [EN]: Optional image object for the time style. Takes priority over timeImagePath.
 *       Its pixel size is used as the default time area size when timeRect is CGRectZero.
 * [CN]: 可选时间样式图片，优先级高于 timeImagePath。timeRect 为 CGRectZero 时，
 *       其像素尺寸作为默认时间区域尺寸。
 */
@property (nonatomic, strong, nullable, readonly) UIImage *timeImage;

/**
 * @brief Time style image file path
 * @chinese 时间样式图片文件路径
 *
 * @discussion
 * [EN]: Optional local or bundle-relative image path. Used only when timeImage is nil.
 * [CN]: 可选本地路径或 bundle 相对路径，仅在 timeImage 为空时使用。
 */
@property (nonatomic, copy, nullable, readonly) NSString *timeImagePath;

/**
 * @brief Time display position
 * @chinese 时间显示位置
 *
 * @discussion
 * [EN]: Fallback layout position when timeRect is CGRectZero. Default is top.
 * [CN]: timeRect 为 CGRectZero 时使用的备用布局位置，默认在上方。
 */
@property (nonatomic, assign, readonly) TSDialTimePosition timePosition;

/**
 * @brief Time display area rectangle
 * @chinese 时间显示区域矩形
 *
 * @discussion
 * [EN]: Explicit time area in the background image pixel coordinate system. Takes
 *       priority over timePosition. CGRectZero means the SDK calculates the area.
 * [CN]: 背景图像素坐标系中的明确时间区域，优先级高于 timePosition。
 *       CGRectZero 表示由 SDK 自动计算。
 */
@property (nonatomic, assign, readonly) CGRect timeRect;

/**
 * @brief Time display color
 * @chinese 时间显示颜色
 *
 * @discussion
 * [EN]: Optional tint color for monochrome time images. Leave nil for pre-colored images.
 * [CN]: 单色时间图片的可选着色颜色；图片已带颜色时保持 nil。
 */
@property (nonatomic, strong, nullable, readonly) UIColor *timeColor;

/**
 * @brief Time display style
 * @chinese 时间显示样式
 *
 * @discussion
 * [EN]: Optional style id used by devices/templates that support built-in time styles.
 *       Default is eTSDialTimeStyle1.
 * [CN]: 支持内置时间样式的设备/模板使用的可选样式 id，默认 eTSDialTimeStyle1。
 */
@property (nonatomic, assign, readonly) TSDialTimeStyle style;

/**
 * @brief Designated initializer
 * @chinese 指定初始化方法
 *
 * @param timeImage
 * EN: Optional time style image. Takes priority over timeImagePath.
 * CN: 可选时间样式图片，优先级高于 timeImagePath。
 *
 * @param timeImagePath
 * EN: Optional local or bundle-relative image path.
 * CN: 可选本地路径或 bundle 相对路径。
 *
 * @param timePosition
 * EN: Fallback layout position when timeRect is CGRectZero.
 * CN: timeRect 为 CGRectZero 时使用的备用布局位置。
 *
 * @param timeRect
 * EN: Explicit time area in background image pixel coordinates.
 * CN: 背景图像素坐标系中的明确时间区域。
 *
 * @param timeColor
 * EN: Optional tint color for monochrome time images.
 * CN: 单色时间图片的可选着色颜色。
 *
 * @param style
 * EN: Optional style id for supported devices/templates.
 * CN: 支持设备/模板使用的可选样式 id。
 *
 * @return
 * EN: Initialized time configuration.
 * CN: 初始化完成的时间配置。
 */
- (instancetype)initWithTimeImage:(nullable UIImage *)timeImage
                    timeImagePath:(nullable NSString *)timeImagePath
                      timePosition:(TSDialTimePosition)timePosition
                          timeRect:(CGRect)timeRect
                         timeColor:(nullable UIColor *)timeColor
                             style:(TSDialTimeStyle)style NS_DESIGNATED_INITIALIZER;

/**
 * @brief Disable default init method
 * @chinese 禁用默认初始化方法
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Disable new method
 * @chinese 禁用 new 方法
 */
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Get time style image
 * @chinese 获取时间样式图片
 *
 * @return
 * EN: timeImage if set, otherwise image loaded from timeImagePath, or nil.
 * CN: 优先返回 timeImage；否则从 timeImagePath 加载；均无则返回 nil。
 */
- (nullable UIImage *)timeStyleImage;

@end

NS_ASSUME_NONNULL_END
