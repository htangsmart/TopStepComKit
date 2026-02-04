//
//  TSCustomDialItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/12/3.
//

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"
#import "TSCustomDialTime.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Dial item model
 * @chinese 表盘项模型
 *
 * @discussion
 * [EN]: Represents a single item in a watch face, containing resource information, item type, and time display configuration.
 *       Simplified model that contains dial type, resource path, background image, video, and time configuration.
 * [CN]: 表示表盘中的单个项，包含资源信息、项类型和时间显示配置。
 *       简化后的模型，包含表盘类型、资源路径、背景图片、视频和时间配置。
 */
@interface TSCustomDialItem : TSKitBaseModel

/**
 * @brief Dial type
 * @chinese 表盘项类型
 *
 * @discussion
 * [EN]: Type of the dial item resource:
 *       - eTSCustomDialSingleImage (1): Single image resource
 *       - eTSCustomDialMultipleImage (2): Multiple images resource
 *       - eTSCustomDialVideo (3): Video resource
 * [CN]: 表盘项资源的类型：
 *       - eTSCustomDialSingleImage (1): 单图片资源
 *       - eTSCustomDialMultipleImage (2): 多图片资源
 *       - eTSCustomDialVideo (3): 视频资源
 */
@property (nonatomic, assign) TSCustomDialType dialType;

/**
 * @brief Resource local path
 * @chinese 资源本地路径
 *
 * @discussion
 * [EN]: Local file path of the resource (image or video).
 *       - If dialType is image type (SingleImage or MultipleImage), this is the image file path
 *       - If dialType is video type, this is the video file path
 *       Supports absolute paths and relative paths (loaded from main bundle).
 * [CN]: 资源的本地文件路径（图片或视频）。
 *       - 如果dialType是图片类型（SingleImage或MultipleImage），这是图片文件路径
 *       - 如果dialType是视频类型，这是视频文件路径
 *       支持绝对路径和相对路径（从main bundle加载）。
 */
@property (nonatomic, copy, nullable) NSString *resourcePath;

/**
 * @brief Dial background image
 * @chinese 表盘背景图
 *
 * @discussion
 * [EN]: UIImage object for the dial background image.
 *       This property allows setting the image directly without using resourcePath.
 *       If both resourceImage and resourcePath are set, resourceImage takes priority.
 *       Note: This property is only used when dialType is image type (SingleImage or MultipleImage).
 *       When dialType is set to video type, this property will be automatically cleared.
 *       May be nil if not specified or when dialType is video type.
 * [CN]: 表盘背景图片的UIImage对象。
 *       此属性允许直接设置图片，而不需要使用resourcePath。
 *       如果同时设置了resourceImage和resourcePath，resourceImage优先。
 *       注意：此属性仅在dialType为图片类型（SingleImage或MultipleImage）时使用。
 *       当dialType设置为视频类型时，此属性会被自动清空。
 *       如果未指定或dialType为视频类型时可能为nil。
 */
@property (nonatomic, strong, nullable) UIImage *resourceImage;

/**
 * @brief Dial video data
 * @chinese 表盘视频
 *
 * @discussion
 * [EN]: NSData object containing video file data for the dial.
 *       This property allows setting the video data directly without using resourcePath.
 *       If both resourceVideo and resourcePath are set, resourceVideo takes priority.
 *       Note: This property is only used when dialType is eTSCustomDialVideo.
 *       When dialType is set to image type, this property will be automatically cleared.
 *       May be nil if not specified or when dialType is image type.
 * [CN]: 包含表盘视频文件数据的NSData对象。
 *       此属性允许直接设置视频数据，而不需要使用resourcePath。
 *       如果同时设置了resourceVideo和resourcePath，resourceVideo优先。
 *       注意：此属性仅在dialType为eTSCustomDialVideo时使用。
 *       当dialType设置为图片类型时，此属性会被自动清空。
 *       如果未指定或dialType为图片类型时可能为nil。
 */
@property (nonatomic, strong, nullable) NSData *resourceVideo;

/**
 * @brief Time display configuration
 * @chinese 时间显示配置
 *
 * @discussion
 * [EN]: TSCustomDialTime object containing time display configuration for the dial item.
 *       This property includes time style, position, area, color, and style image settings.
 *       This property is required and will be automatically initialized in init method.
 *       Cannot be nil. Must be set for every dial item.
 * [CN]: 包含表盘项时间显示配置的TSCustomDialTime对象。
 *       此属性包括时间样式、位置、区域、颜色和样式图片设置。
 *       此属性是必需的，会在init方法中自动初始化。
 *       不能为nil。每个表盘项都必须设置。
 */
@property (nonatomic, strong, nonnull) TSCustomDialTime *dialTime;

/**
 * @brief Get UIImage object from resource
 * @chinese 从资源获取UIImage对象
 *
 * @return
 * EN: UIImage object if dialType is image type and resource is available, nil otherwise
 * CN: 如果dialType是图片类型且资源可用则返回UIImage对象，否则返回nil
 *
 * @discussion
 * [EN]: This method returns the background image for the dial item.
 *       Priority: resourceImage > resourcePath (loaded from file).
 * [CN]: 此方法返回表盘项的背景图片。
 *       优先级：resourceImage > resourcePath（从文件加载）。
 */
- (nullable UIImage *)dialImage;

/**
 * @brief Get NSData object for video file
 * @chinese 获取视频文件的NSData对象
 *
 * @return
 * EN: NSData object containing video file data if dialType is video type and resource is available, nil otherwise
 * CN: 如果dialType是视频类型且资源可用则返回包含视频文件数据的NSData对象，否则返回nil
 *
 * @discussion
 * [EN]: This method returns the video data for the dial item.
 *       Priority: resourceVideo > resourcePath (loaded from file).
 * [CN]: 此方法返回表盘项的视频数据。
 *       优先级：resourceVideo > resourcePath（从文件加载）。
 */
- (nullable NSData *)dialVideo;

/**
 * @brief Get video file path
 * @chinese 获取视频文件路径
 *
 * @return
 * EN: Video file path if dialType is video type and resourcePath is valid, nil otherwise
 * CN: 如果dialType是视频类型且resourcePath有效则返回视频文件路径，否则返回nil
 */
- (nullable NSString *)videoFilePath;

@end

NS_ASSUME_NONNULL_END
