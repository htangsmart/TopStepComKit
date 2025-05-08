//
//  TSFitDialModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/18.
//
//  文件说明:
//  中科系列设备表盘模型，定义了表盘的版本、显示状态、图片资源等属性

#import <UIKit/UIKit.h>
#import "TSDialModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Fit series watch face model
 * @chinese 中科系列表盘模型
 *
 * @discussion
 * EN: This class defines specific properties for Fit series device watch faces.
 *     Inherits from TSDialModel and adds Fit-specific features.
 *     Used for managing watch faces on Fit series devices.
 *
 * CN: 该类定义了中科系列设备表盘的特定属性。
 *     继承自TSDialModel并添加了中科系列特有的功能。
 *     用于管理中科系列设备的表盘。
 */
@interface TSFitDialModel : TSDialModel

/**
 * @brief Watch face version number
 * @chinese 表盘版本号
 *
 * @discussion
 * EN: Version number of the watch face.
 *     Used for compatibility checking and updates.
 *     Higher version numbers indicate newer watch faces.
 *
 * CN: 表盘的版本号。
 *     用于兼容性检查和更新。
 *     更高的版本号表示更新的表盘。
 */
@property (nonatomic, assign) NSInteger version;

/**
 * @brief Watch face visibility flag
 * @chinese 表盘可见性标志
 *
 * @discussion
 * EN: Controls whether the watch face is visible in the selection list.
 *     YES: Watch face is hidden
 *     NO: Watch face is visible
 *     Used for managing watch face visibility in the UI.
 *
 * CN: 控制表盘在选择列表中是否可见。
 *     YES: 表盘被隐藏
 *     NO: 表盘可见
 *     用于管理表盘在UI中的可见性。
 */
@property (nonatomic, assign) BOOL hidden;

/**
 * @brief Watch face main image
 * @chinese 表盘主图片
 *
 * @discussion
 * EN: The main image of the watch face.
 *     Requirements:
 *     - Resolution must match device screen
 *     - Format must be compatible with device
 *     - Size should not exceed device limits
 *
 * CN: 表盘的主图片。
 *     要求：
 *     - 分辨率必须匹配设备屏幕
 *     - 格式必须与设备兼容
 *     - 大小不应超过设备限制
 */
@property (nonatomic, strong) UIImage *dialImage;

/**
 * @brief Watch face preview image
 * @chinese 表盘预览图片
 *
 * @discussion
 * EN: Preview image shown in the watch face selection interface.
 *     Usually a smaller version of the main image.
 *     Used for quick loading and preview purposes.
 *
 * CN: 在表盘选择界面显示的预览图片。
 *     通常是主图片的缩小版本。
 *     用于快速加载和预览目的。
 */
@property (nonatomic, strong) UIImage *dialPreviewImage;

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
 * @brief Time style index
 * @chinese 时间样式索引
 *
 * @discussion
 * EN: Index of the time display style.
 *     Different indices represent different time display formats.
 *     Available styles depend on device capabilities.
 *
 * CN: 时间显示样式的索引。
 *     不同的索引代表不同的时间显示格式。
 *     可用的样式取决于设备能力。
 */
@property (nonatomic, assign) NSInteger timeStyleIndex;

@end

NS_ASSUME_NONNULL_END
