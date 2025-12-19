//
//  TSSJDialModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/18.
//
//  文件说明:
//  伸聚系列设备表盘模型，定义了表盘的时间位置、当前状态、背景图片等属性

#import "TSDialModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief SJ series watch face model
 * @chinese 伸聚系列表盘模型
 *
 * @discussion
 * EN: This class defines specific properties for SJ series device watch faces.
 *     Inherits from TSDialModel and adds SJ-specific features.
 *     Used for managing watch faces on SJ series devices.
 *
 * CN: 该类定义了伸聚系列设备表盘的特定属性。
 *     继承自TSDialModel并添加了伸聚系列特有的功能。
 *     用于管理伸聚系列设备的表盘。
 */
@interface TSSJDialModel : TSDialModel

/**
 * @brief Time display position
 * @chinese 时间显示位置
 *
 * @discussion
 * EN: Defines where the time is displayed on the watch face.
 *     Position options are defined in TSDialTimePosition enum.
 *     Must be compatible with the watch face design.
 *
 * CN: 定义时间在表盘上的显示位置。
 *     位置选项在TSDialTimePosition枚举中定义。
 *     必须与表盘设计兼容。
 */
@property (nonatomic, assign) TSDialTimePosition timePosition;


/**
 * @brief Watch face background image
 * @chinese 表盘背景图片
 *
 * @discussion
 * EN: The background image of the watch face.
 *     Requirements:
 *     - Resolution must match device screen
 *     - Format must be compatible with device
 *     - Size should not exceed device limits
 *
 * CN: 表盘的背景图片。
 *     要求：
 *     - 分辨率必须匹配设备屏幕
 *     - 格式必须与设备兼容
 *     - 大小不应超过设备限制
 */
@property (nonatomic, strong) UIImage *backgroundImage;

/**
 * @brief Watch face text overlay image
 * @chinese 表盘文字叠加图片
 *
 * @discussion
 * EN: Image containing text overlays for the watch face.
 *     Used for displaying custom text elements.
 *     Must be transparent where no text is present.
 *
 * CN: 包含表盘文字叠加层的图片。
 *     用于显示自定义文字元素。
 *     非文字区域必须透明。
 */
@property (nonatomic, strong) UIImage *textImage;

/**
 * @brief Watch face text color
 * @chinese 表盘文字颜色
 *
 * @discussion
 * EN: Color used for text elements on the watch face.
 *     Applied to time display and other text components.
 *     Should provide good contrast with the background.
 *
 * CN: 表盘上文字元素使用的颜色。
 *     应用于时间显示和其他文字组件。
 *     应与背景形成良好的对比度。
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 * @brief Watch face time display position
 * @chinese 表盘时间显示位置
 *
 * @discussion
 * EN: Defines the position of the time display on the watch face.
 *     Position options are defined in TSDialTimePosition enum.
 *     Must be compatible with the overall watch face layout.
 *
 * CN: 定义时间在表盘上的显示位置。
 *     位置选项在TSDialTimePosition枚举中定义。
 *     必须与整体表盘布局兼容。
 */
@property (nonatomic, assign) TSDialTimePosition dialTimePosition;

@end

NS_ASSUME_NONNULL_END
