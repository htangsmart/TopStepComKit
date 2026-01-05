//
//  TSCustomDialTime.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/12/24.
//

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Custom dial time configuration model
 * @chinese 自定义表盘时间配置模型
 *
 * @discussion
 * [EN]: Represents the time display configuration for a custom watch face,
 *       including style image, position, area, and color settings.
 * [CN]: 表示自定义表盘的时间显示配置，包括样式图片、位置、区域和颜色设置。
 */
@interface TSCustomDialTime : TSKitBaseModel

/**
 * @brief Time style image
 * @chinese 时间样式图片
 *
 * @discussion
 * [EN]: UIImage object for the time display style.
 *       This property allows setting the style image directly without using timeImagePath.
 *       If both timeImage and timeImagePath are set, timeImage takes priority.
 *       This property is used together with the style property to determine the time display appearance.
 *       May be nil if not specified.
 * [CN]: 时间显示样式图片的UIImage对象。
 *       此属性允许直接设置样式图片，而不需要使用timeImagePath。
 *       如果同时设置了timeImage和timeImagePath，timeImage优先。
 *       此属性与style属性一起使用，用于确定时间显示的外观。
 *       如果未指定可能为nil。
 */
@property (nonatomic, strong, nullable) UIImage *timeImage;

/**
 * @brief Time style image file path
 * @chinese 时间样式图片文件路径
 *
 * @discussion
 * [EN]: Local file path of the time display style image.
 *       Used to load the time display style image for preview or rendering.
 *       If both timeImage and timeImagePath are set, timeImage takes priority.
 *       Supports absolute paths and relative paths (loaded from main bundle).
 *       This property is used together with the style property to determine the time display appearance.
 *       May be nil if not specified.
 * [CN]: 时间显示样式图片的本地文件路径。
 *       用于加载时间显示样式图片，用于预览或渲染。
 *       如果同时设置了timeImage和timeImagePath，timeImage优先。
 *       支持绝对路径和相对路径（从main bundle加载）。
 *       此属性与style属性一起使用，用于确定时间显示的外观。
 *       如果未指定可能为nil。
 */
@property (nonatomic, strong, nullable) NSString *timeImagePath;

/**
 * @brief Time display position
 * @chinese 时间显示位置
 *
 * @discussion
 * [EN]: Position of the time display on the watch face.
 *       Position options are defined in TSDialTimePosition enum:
 *       - Top, Bottom, Left, Right
 *       - TopLeft, BottomLeft, TopRight, BottomRight
 *       - Center
 *       This property is used as a fallback when timeRect is not set (CGRectZero).
 *       Default value is eTSDialTimePositionTop.
 * [CN]: 时间在表盘上的显示位置。
 *       位置选项在TSDialTimePosition枚举中定义：
 *       - 上方、下方、左方、右方
 *       - 左上、左下、右上、右下
 *       - 中间
 *       当timeRect未设置（为CGRectZero）时，将使用此属性。
 *       默认值为eTSDialTimePositionTop。
 */
@property (nonatomic, assign) TSDialTimePosition timePosition;

/**
 * @brief Time display area rectangle
 * @chinese 时间显示区域矩形
 *
 * @discussion
 * [EN]: Rectangle area where the time should be displayed on the watch face.
 *       This property has priority over timePosition.
 *       If timeRect is set (not CGRectZero), SDK will use this value directly.
 *       If timeRect is not set (CGRectZero), SDK will calculate the default position
 *       based on timePosition property.
 * [CN]: 时间在表盘上显示的矩形区域。
 *       此属性优先于timePosition。
 *       如果timeRect已设置（不为CGRectZero），SDK将直接使用此值。
 *       如果timeRect未设置（为CGRectZero），SDK将根据timePosition属性计算默认位置。
 */
@property (nonatomic, assign) CGRect timeRect;

/**
 * @brief Time display color
 * @chinese 时间显示颜色
 *
 * @discussion
 * [EN]: Color used for time display text.
 *       This property is optional. If the style image already contains color information,
 *       this property should not be set (nil).
 *       Only set this property when you need to apply a color filter to a monochrome style image.
 * [CN]: 用于时间显示文字的颜色。
 *       此属性是可选的。如果样式图片已经包含颜色信息，则不应设置此属性（nil）。
 *       仅在需要对单色样式图片应用颜色滤镜时设置此属性。
 */
@property (nonatomic, strong, nullable) UIColor *timeColor;

/**
 * @brief Time display style
 * @chinese 时间显示样式
 *
 * @discussion
 * [EN]: Style enumeration for time display appearance.
 *       Defines 7 different style options (style1 to style7) for customizing the time display.
 *       This property works together with timeImage/timeImagePath to determine the final appearance.
 *       Default value is eTSDialTimeStyle1.
 * [CN]: 时间显示外观的样式枚举。
 *       定义了7种不同的样式选项（style1到style7），用于自定义时间显示。
 *       此属性与timeImage/timeImagePath一起使用，以确定最终的外观。
 *       默认值为eTSDialTimeStyle1。
 */
@property (nonatomic, assign) TSDialTimeStyle style;


/**
 * @brief Get time style image
 * @chinese 获取时间样式图片
 *
 * @return
 * EN: UIImage object for the time style. If timeImage is set, returns timeImage.
 *     Otherwise, loads image from timeImagePath. Returns nil if both are not set.
 * CN: 时间样式图片的UIImage对象。如果timeImage已设置，返回timeImage。
 *     否则，从timeImagePath加载图片。如果两者都未设置则返回nil。
 *
 * @discussion
 * [EN]: This method returns the time style image with priority: timeImage > timeImagePath.
 *       Supports both absolute paths and relative paths (loaded from main bundle).
 * [CN]: 此方法返回时间样式图片，优先级：timeImage > timeImagePath。
 *       支持绝对路径和相对路径（从main bundle加载）。
 */
- (nullable UIImage *)timeStyleImage;

@end

NS_ASSUME_NONNULL_END
