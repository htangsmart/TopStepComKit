//
//  TSPeripheralScreen.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 * 外设形状枚举
 * 用于描述外设设备的物理形状特征
 */
typedef NS_ENUM(NSUInteger, TSPeriphShape) {
    /** 未知形状 */
    eTSPeriphShapeUnknow = 0,
    /** 圆形设备，如圆形手表等 */
    eTSPeriphShapeCircle = 1,
    /** 正方形设备，如方形手表等 */
    eTSPeriphShapeSquare = 2,
    /** 纵向长方形设备，如竖屏显示器等 */
    eTSPeriphShapeVerticalRectangle = 3,
    /** 横向长方形设备，如横屏显示器等 */
    eTSPeriphShapeTransverseRectangle = 4,
};

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Peripheral device screen information
 * @chinese 外设设备屏幕信息
 *
 * @discussion
 * [EN]: This class encapsulates screen-related information for peripheral devices,
 *       including physical screen properties (size, shape, border radius),
 *       dial preview image configuration (dimensions for watch face thumbnails),
 *       and video preview configuration (dimensions for video streams during camera mode).
 *       
 *       The class uses CGSize properties (screenSize, dialPreviewSize, videoPreviewSize)
 *       as the primary way to store dimensions, and provides convenience methods
 *       (screenWidth, screenHeight, etc.) to access individual width and height values.
 *       
 *       Key features:
 *       - Screen properties: shape, size, border radius
 *       - Dial preview properties: size for watch face thumbnails, border radius
 *       - Video preview properties: size for camera video streams, border radius
 *       - Convenience methods: access width/height individually from size properties
 *
 * [CN]: 该类封装了外设设备的屏幕相关信息，包括物理屏幕属性（尺寸、形状、圆角半径）、
 *       表盘预览图配置（用于表盘缩略图的尺寸）和视频预览配置（相机模式下视频流的尺寸）。
 *       
 *       该类使用CGSize属性（screenSize、dialPreviewSize、videoPreviewSize）
 *       作为存储尺寸的主要方式，并提供便利方法（screenWidth、screenHeight等）
 *       来访问单独的宽度和高度值。
 *       
 *       主要特性：
 *       - 屏幕属性：形状、尺寸、圆角半径
 *       - 表盘预览属性：表盘缩略图尺寸、圆角半径
 *       - 视频预览属性：相机视频流尺寸、圆角半径
 *       - 便利方法：从尺寸属性中单独访问宽度/高度
 */
@interface TSPeripheralScreen : NSObject

#pragma mark - 屏幕相关属性
/**
 * @brief Device shape used to identify the shape characteristics of the device.
 * @chinese 设备外形，用于标识设备的形状特征
 *
 * @discussion
 * [EN]: Used to describe the physical shape characteristics of the peripheral device.
 * [CN]: 用于描述外设设备的物理形状特征。
 *
 * @note
 * [EN]: This value should be a valid TSPeriphShape enumeration value.
 * [CN]: 该值应为有效的TSPeriphShape枚举值。
 */
@property (nonatomic,assign) TSPeriphShape shape;

/**
 * @brief Screen size of the device in pixels.
 * @chinese 设备屏幕尺寸，单位像素
 *
 * @discussion
 * [EN]: This property represents the screen size as a CGSize structure,
 *       combining both width and height. This is the primary property for
 *       storing screen dimensions. Use the convenience methods screenWidth()
 *       and screenHeight() to access individual width and height values.
 *       
 *       Example usage:
 *       - Setting: self.screenSize = CGSizeMake(390, 450);
 *       - Getting width: CGFloat width = [self screenWidth];
 *       - Getting height: CGFloat height = [self screenHeight];
 * [CN]: 此属性表示屏幕尺寸为CGSize结构，包含宽度和高度。
 *       这是存储屏幕尺寸的主要属性。使用便利方法screenWidth()和screenHeight()
 *       来访问单独的宽度和高度值。
 *       
 *       使用示例：
 *       - 设置：self.screenSize = CGSizeMake(390, 450);
 *       - 获取宽度：CGFloat width = [self screenWidth];
 *       - 获取高度：CGFloat height = [self screenHeight];
 *
 * @note
 * [EN]: This is the primary property for screen dimensions. The convenience methods
 *       screenWidth() and screenHeight() read from this property.
 * [CN]: 这是屏幕尺寸的主要属性。便利方法screenWidth()和screenHeight()从此属性读取。
 */
@property (nonatomic,assign) CGSize screenSize;

/**
 * @brief Screen border radius of the device in pixels.
 * @chinese 设备屏幕圆角半径，单位像素
 *
 * @discussion
 * [EN]: Used to consider the screen border radius when drawing the UI.
 * [CN]: 用于绘制UI时考虑屏幕圆角。
 *
 * @note
 * [EN]: This value should be a non-negative number.
 * [CN]: 该值应为非负数。
 */
@property (nonatomic,assign) CGFloat screenBorderRadius;

/**
 * @brief Dial preview image size in pixels.
 * @chinese 表盘预览图尺寸，单位像素
 *
 * @discussion
 * [EN]: This property represents the dial preview image size as a CGSize structure,
 *       combining both width and height. This is the primary property for storing
 *       dial preview dimensions. The dial preview is used for displaying watch face
 *       thumbnails in the app UI. Use the convenience methods dialPreviewWidth()
 *       and dialPreviewHeight() to access individual width and height values.
 *       
 *       This is different from videoPreviewSize, which is used for camera video streaming.
 * [CN]: 此属性表示表盘预览图尺寸为CGSize结构，包含宽度和高度。
 *       这是存储表盘预览图尺寸的主要属性。表盘预览图用于在应用UI中显示表盘缩略图。
 *       使用便利方法dialPreviewWidth()和dialPreviewHeight()来访问单独的宽度和高度值。
 *       
 *       这与videoPreviewSize不同，videoPreviewSize用于相机视频流。
 *
 * @note
 * [EN]: This is the primary property for dial preview dimensions. The convenience methods
 *       dialPreviewWidth() and dialPreviewHeight() read from this property.
 * [CN]: 这是表盘预览图尺寸的主要属性。便利方法dialPreviewWidth()和dialPreviewHeight()从此属性读取。
 */
@property (nonatomic,assign) CGSize dialPreviewSize;

/**
 * @brief Corner radius of the dial preview image in pixels.
 * @chinese 表盘预览图圆角半径，单位像素
 *
 * @discussion
 * [EN]: Used for corner processing when displaying the dial preview image in the app UI.
 *       This helps match the visual appearance of the preview thumbnail to the device's
 *       screen characteristics.
 * [CN]: 用于在应用UI中显示表盘预览图时的圆角处理。
 *       这有助于使预览缩略图的视觉外观与设备的屏幕特征相匹配。
 *
 * @note
 * [EN]: This value should be a non-negative number.
 * [CN]: 该值应为非负数。
 */
@property (nonatomic,assign) CGFloat dialPreviewBorderRadius;

/**
 * @brief Video preview stream size in pixels.
 * @chinese 视频预览流尺寸，单位像素
 *
 * @discussion
 * [EN]: This property represents the video preview stream size as a CGSize structure,
 *       combining both width and height. This is the primary property for storing
 *       video preview dimensions. The video preview is used for camera video streaming
 *       during camera mode. Use the convenience methods videoPreviewWidth() and
 *       videoPreviewHeight() to access individual width and height values.
 *       
 *       This is different from dialPreviewSize, which is used for watch face thumbnails.
 * [CN]: 此属性表示视频预览流尺寸为CGSize结构，包含宽度和高度。
 *       这是存储视频预览流尺寸的主要属性。视频预览用于相机模式下的相机视频流。
 *       使用便利方法videoPreviewWidth()和videoPreviewHeight()来访问单独的宽度和高度值。
 *       
 *       这与dialPreviewSize不同，dialPreviewSize用于表盘缩略图。
 *
 * @note
 * [EN]: This is the primary property for video preview dimensions. The convenience methods
 *       videoPreviewWidth() and videoPreviewHeight() read from this property.
 * [CN]: 这是视频预览流尺寸的主要属性。便利方法videoPreviewWidth()和videoPreviewHeight()从此属性读取。
 */
@property (nonatomic,assign) CGSize videoPreviewSize;

/**
 * @brief Corner radius of the video preview stream in pixels.
 * @chinese 视频预览流圆角半径，单位像素
 *
 * @discussion
 * [EN]: Used for corner processing when displaying the video preview stream.
 *       This helps match the visual appearance of the preview to the device's
 *       screen characteristics.
 * [CN]: 用于显示视频预览流时的圆角处理。
 *       这有助于使预览的视觉外观与设备的屏幕特征相匹配。
 *
 * @note
 * [EN]: This value should be a non-negative number.
 * [CN]: 该值应为非负数。
 */
@property (nonatomic,assign) CGFloat videoPreviewBorderRadius;

#pragma mark - Convenience Methods

/**
 * @brief Get screen width
 * @chinese 获取屏幕宽度
 *
 * @return Screen width in pixels
 * @chinese 屏幕宽度，单位像素
 *
 * @discussion
 * [EN]: This convenience method returns the width component of the screenSize property.
 *       It's equivalent to accessing self.screenSize.width directly.
 *       
 *       Example: CGFloat width = [screen screenWidth];
 * [CN]: 此便利方法返回screenSize属性的宽度分量。
 *       等同于直接访问self.screenSize.width。
 *       
 *       示例：CGFloat width = [screen screenWidth];
 */
- (CGFloat)screenWidth;

/**
 * @brief Get screen height
 * @chinese 获取屏幕高度
 *
 * @return Screen height in pixels
 * @chinese 屏幕高度，单位像素
 *
 * @discussion
 * [EN]: This convenience method returns the height component of the screenSize property.
 *       It's equivalent to accessing self.screenSize.height directly.
 *       
 *       Example: CGFloat height = [screen screenHeight];
 * [CN]: 此便利方法返回screenSize属性的高度分量。
 *       等同于直接访问self.screenSize.height。
 *       
 *       示例：CGFloat height = [screen screenHeight];
 */
- (CGFloat)screenHeight;

/**
 * @brief Get dial preview width
 * @chinese 获取表盘预览图宽度
 *
 * @return Dial preview width in pixels
 * @chinese 表盘预览图宽度，单位像素
 *
 * @discussion
 * [EN]: This convenience method returns the width component of the dialPreviewSize property.
 *       It's equivalent to accessing self.dialPreviewSize.width directly.
 *       
 *       The dial preview is used for displaying watch face thumbnails in the app UI.
 *       
 *       Example: CGFloat width = [screen dialPreviewWidth];
 * [CN]: 此便利方法返回dialPreviewSize属性的宽度分量。
 *       等同于直接访问self.dialPreviewSize.width。
 *       
 *       表盘预览图用于在应用UI中显示表盘缩略图。
 *       
 *       示例：CGFloat width = [screen dialPreviewWidth];
 */
- (CGFloat)dialPreviewWidth;

/**
 * @brief Get dial preview height
 * @chinese 获取表盘预览图高度
 *
 * @return Dial preview height in pixels
 * @chinese 表盘预览图高度，单位像素
 *
 * @discussion
 * [EN]: This convenience method returns the height component of the dialPreviewSize property.
 *       It's equivalent to accessing self.dialPreviewSize.height directly.
 *       
 *       The dial preview is used for displaying watch face thumbnails in the app UI.
 *       
 *       Example: CGFloat height = [screen dialPreviewHeight];
 * [CN]: 此便利方法返回dialPreviewSize属性的高度分量。
 *       等同于直接访问self.dialPreviewSize.height。
 *       
 *       表盘预览图用于在应用UI中显示表盘缩略图。
 *       
 *       示例：CGFloat height = [screen dialPreviewHeight];
 */
- (CGFloat)dialPreviewHeight;

/**
 * @brief Get video preview width
 * @chinese 获取视频预览宽度
 *
 * @return Video preview width in pixels
 * @chinese 视频预览宽度，单位像素
 *
 * @discussion
 * [EN]: This convenience method returns the width component of the videoPreviewSize property.
 *       It's equivalent to accessing self.videoPreviewSize.width directly.
 *       
 *       The video preview is used for camera video streaming during camera mode.
 *       
 *       Example: CGFloat width = [screen videoPreviewWidth];
 * [CN]: 此便利方法返回videoPreviewSize属性的宽度分量。
 *       等同于直接访问self.videoPreviewSize.width。
 *       
 *       视频预览用于相机模式下的相机视频流。
 *       
 *       示例：CGFloat width = [screen videoPreviewWidth];
 */
- (CGFloat)videoPreviewWidth;

/**
 * @brief Get video preview height
 * @chinese 获取视频预览高度
 *
 * @return Video preview height in pixels
 * @chinese 视频预览高度，单位像素
 *
 * @discussion
 * [EN]: This convenience method returns the height component of the videoPreviewSize property.
 *       It's equivalent to accessing self.videoPreviewSize.height directly.
 *       
 *       The video preview is used for camera video streaming during camera mode.
 *       
 *       Example: CGFloat height = [screen videoPreviewHeight];
 * [CN]: 此便利方法返回videoPreviewSize属性的高度分量。
 *       等同于直接访问self.videoPreviewSize.height。
 *       
 *       视频预览用于相机模式下的相机视频流。
 *       
 *       示例：CGFloat height = [screen videoPreviewHeight];
 */
- (CGFloat)videoPreviewHeight;



@end

NS_ASSUME_NONNULL_END
