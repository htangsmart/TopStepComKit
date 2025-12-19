//
//  TSCustomDialItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/12/3.
//

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Dial item model
 * @chinese 表盘项模型
 *
 * @discussion
 * [EN]: Represents a single item in a watch face, containing resource information,
 *       time position, time color, and item type.
 * [CN]: 表示表盘中的单个项，包含资源信息、时间位置、时间颜色和项类型。
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
@property (nonatomic, assign) TSCustomDialType itemType;


/**
 * @brief Resource path
 * @chinese 资源地址
 *
 * @discussion
 * [EN]: Local file path or URL of the resource (image or video).
 *       Used to access the resource file for the dial item.
 * [CN]: 资源的本地文件路径或URL（图片或视频）。
 *       用于访问表盘项的资源文件。
 */
@property (nonatomic, copy, nullable) NSString *resourcePath;

/**
 * @brief Resource image object
 * @chinese 资源图片对象
 *
 * @discussion
 * [EN]: Direct UIImage object for the dial item resource.
 *       This property allows setting the image directly without using resourcePath.
 *       If both resourceImage and resourcePath are set, resourceImage takes priority.
 *       May be nil if not specified.
 * [CN]: 表盘项资源的直接UIImage对象。
 *       此属性允许直接设置图片，而不需要使用resourcePath。
 *       如果同时设置了resourceImage和resourcePath，resourceImage优先。
 *       如果未指定可能为nil。
 */
@property (nonatomic, strong, nullable) UIImage *resourceImage;

/**
 * @brief Time display position point
 * @chinese 时间显示位置坐标点
 *
 * @discussion
 * [EN]: The top-left corner point of the time display on the watch face.
 *       This property has priority over timePosition.
 *       If timepoint is set (not CGPointZero), SDK will use this value.
 *       If timepoint is not set (CGPointZero), SDK will use timePosition instead.
 * [CN]: 时间在表盘上显示的左上角坐标点。
 *       此属性优先于timePosition。
 *       如果timepoint已设置（不为CGPointZero），SDK将使用此值。
 *       如果timepoint未设置（为CGPointZero），SDK将使用timePosition代替。
 */
@property (nonatomic, assign) CGPoint timepoint;

/**
 * @brief Time display position
 * @chinese 时间显示位置
 *
 * @discussion
 * [EN]: Position of the time display on the watch face.
 *       Position options are defined in TSDialTimePosition enum:
 *       - Left, Top, Right, Bottom
 *       - TopLeft, BottomLeft, TopRight, BottomRight
 *       - Center
 *       This property is used as a fallback when timepoint is not set (CGPointZero).
 *       Default value is eTSDialTimePositionTop.
 * [CN]: 时间在表盘上的显示位置。
 *       位置选项在TSDialTimePosition枚举中定义：
 *       - 左方、上方、右方、下方
 *       - 左上、左下、右上、右下
 *       - 中间
 *       当timepoint未设置（为CGPointZero）时，将使用此属性。
 *       默认值为eTSDialTimePositionTop。
 */
@property (nonatomic, assign) TSDialTimePosition timePosition;


/**
 * @brief Style index
 * @chinese 样式索引
 *
 * @discussion
 * [EN]: Index of the time display style in the style array.
 *       Used to select a specific style from the available styles.
 *       Default value is 0.
 * [CN]: 时间显示样式在样式数组中的索引。
 *       用于从可用样式中选择特定样式。
 *       默认值为0。
 */
@property (nonatomic, assign) NSInteger styleIndex;

/**
 * @brief Style image file path
 * @chinese 样式图片文件路径
 *
 * @discussion
 * [EN]: Local file path of the time display style image.
 *       Used to load the time display style image for preview or rendering.
 *       Supports absolute paths and relative paths (loaded from main bundle).
 *       May be nil if not specified.
 * [CN]: 时间显示样式图片的本地文件路径。
 *       用于加载时间显示样式图片，用于预览或渲染。
 *       支持绝对路径和相对路径（从main bundle加载）。
 *       如果未指定可能为nil。
 */
@property (nonatomic, strong, nullable) NSString *styleImagePath;

/**
 * @brief Style image object
 * @chinese 样式图片对象
 *
 * @discussion
 * [EN]: Direct UIImage object for the time display style image.
 *       This property allows setting the style image directly without using styleImagePath.
 *       If both styleImage and styleImagePath are set, styleImage takes priority.
 *       May be nil if not specified.
 * [CN]: 时间显示样式图片的直接UIImage对象。
 *       此属性允许直接设置样式图片，而不需要使用styleImagePath。
 *       如果同时设置了styleImage和styleImagePath，styleImage优先。
 *       如果未指定可能为nil。
 */
@property (nonatomic, strong, nullable) UIImage *styleImage;

/**
 * @brief Get UIImage object from resource path
 * @chinese 从资源路径获取UIImage对象
 *
 * @return
 * EN: UIImage object if itemType is image type and resourcePath is valid, nil otherwise
 * CN: 如果itemType是图片类型且resourcePath有效则返回UIImage对象，否则返回nil
 */
- (nullable UIImage *)dialImage;

/**
 * @brief Get NSData object for video file from resource path
 * @chinese 从资源路径获取视频文件的NSData对象
 *
 * @return
 * EN: NSData object containing video file data if itemType is video type and resourcePath is valid, nil otherwise
 * CN: 如果itemType是视频类型且resourcePath有效则返回包含视频文件数据的NSData对象，否则返回nil
 */
- (nullable NSData *)dialVideo;

/**
 * @brief Get video file path from resource path
 * @chinese 从资源路径获取视频文件路径
 *
 * @return
 * EN: Video file path if itemType is video type and resourcePath is valid, nil otherwise
 * CN: 如果itemType是视频类型且resourcePath有效则返回视频文件路径，否则返回nil
 */
- (nullable NSString *)videoFilePath;

/**
 * @brief Get UIImage object for time display style image
 * @chinese 获取时间显示样式图片的UIImage对象
 *
 * @return
 * EN: UIImage object if styleImagePath is valid, nil otherwise
 * CN: 如果styleImagePath有效则返回UIImage对象，否则返回nil
 *
 * @discussion
 * [EN]: This method loads the time display style image from the styleImagePath.
 *       The image is used for displaying time on the watch face preview.
 *       Supports absolute paths and relative paths (loaded from main bundle).
 *       If styleImagePath is nil or empty, returns nil.
 * [CN]: 此方法从styleImagePath加载时间显示样式图片。
 *       该图片用于在表盘预览中显示时间。
 *       支持绝对路径和相对路径（从main bundle加载）。
 *       如果styleImagePath为nil或空，返回nil。
 */
- (nullable UIImage *)dialTimeImage;

@end

NS_ASSUME_NONNULL_END
