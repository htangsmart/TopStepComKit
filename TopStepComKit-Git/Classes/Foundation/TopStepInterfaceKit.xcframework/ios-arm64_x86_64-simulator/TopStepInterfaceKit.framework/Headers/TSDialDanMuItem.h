//
//  TSDialDanMuItem.h
//  TopStepInterfaceKit
//
//  Created by Codex on 2026/9/10.
//

#import "TSKitBaseModel.h"

@class UIImage;

NS_ASSUME_NONNULL_BEGIN

/** @brief Anchor for one layout axis. @chinese 单个布局轴的定位锚点。 */
typedef NS_ENUM(NSInteger, TSDialDanMuAnchor) {
    /// Absolute top-left pixel coordinate / 左上角绝对像素坐标
    TSDialDanMuAnchorAbsolute = 0,
    /// Left for X, top for Y / 横轴左对齐，纵轴顶对齐
    TSDialDanMuAnchorStart = 1,
    /// Center the content on this axis / 内容在当前轴居中
    TSDialDanMuAnchorCenter = 2,
    /// Right for X, bottom for Y / 横轴右对齐，纵轴底对齐
    TSDialDanMuAnchorEnd = 3
};

/**
 * @brief A semantic pixel coordinate without vendor encoding.
 * @chinese 不包含厂商位编码的语义像素坐标。
 * @discussion
 * [EN]: Absolute uses offset as the top-left coordinate. Other anchors align the original
 *       content size within the screen, then add offset. Offset range is -524288...524287.
 * [CN]: Absolute 将 offset 作为左上角坐标；其他锚点先按内容原始尺寸在屏幕中对齐，
 *       再加 offset。offset 范围为 -524288...524287，允许负数及屏幕外位置。
 */
typedef struct {
    /** @brief Axis anchor. @chinese 当前轴的锚点。 */
    TSDialDanMuAnchor anchor;
    /** @brief Absolute pixel or signed pixel offset. @chinese 绝对像素值或有符号像素偏移。 */
    NSInteger offset;
} TSDialDanMuCoordinate;

/**
 * @brief Create a semantic coordinate.
 * @chinese 创建语义坐标。
 * @param anchor EN: Axis anchor. CN: 当前轴锚点。
 * @param offset EN: Signed integer pixels. CN: 有符号整数像素。
 * @return EN: Coordinate validated during draft validation. CN: 在草稿校验时验证的坐标。
 */
NS_INLINE TSDialDanMuCoordinate TSDialDanMuCoordinateMake(TSDialDanMuAnchor anchor, NSInteger offset) {
    TSDialDanMuCoordinate coordinate = {anchor, offset};
    return coordinate;
}

/**
 * @brief One scrolling image and its optional bound GIF animation.
 * @chinese 一条滚动图片及其可选关联 GIF 动画。
 * @discussion
 * [EN]: The SDK uses the static image at its original pixel size. Coordinates use screen
 *       pixels. Keep referenced files readable and unchanged until the build completes.
 *       Copying retains immutable images and copies values; it does not duplicate files.
 * [CN]: SDK 按静态图片原始像素尺寸处理，坐标采用屏幕像素。调用方应保证关联文件
 *       在造包完成前可读且不变；复制模型保留不可变图片、复制值字段，不复制磁盘文件。
 */
@interface TSDialDanMuItem : TSKitBaseModel <NSCopying>

/** @brief Required static image. @chinese 必填静态图片。 */
@property (nonatomic, strong, readonly) UIImage *image;

/** @brief Image X; defaults to Start with zero offset. @chinese 静态图横坐标，默认左对齐且偏移为 0。 */
@property (nonatomic, assign) TSDialDanMuCoordinate imageX;

/** @brief Image Y; defaults to Center with zero offset. @chinese 静态图纵坐标，默认居中且偏移为 0。 */
@property (nonatomic, assign) TSDialDanMuCoordinate imageY;

/** @brief Finite positive speed in pixels/second; defaults to 60. @chinese 有限正数速度，单位像素/秒，默认 60。 */
@property (nonatomic, assign) float walkSpeed;

/** @brief Move left to right; defaults to NO. @chinese 是否从左向右移动，默认 NO。 */
@property (nonatomic, assign) BOOL leftToRight;

/**
 * @brief Optional absolute path to a readable local GIF file.
 * @chinese 可选的本地可读 GIF 文件绝对路径。
 * @discussion
 * [EN]: GIF decoding occurs during build. The SDK never removes the caller's source file.
 * [CN]: GIF 解码在造包时执行，SDK 不删除调用方提供的源文件。
 */
@property (nonatomic, copy, nullable) NSString *animationFilePath;

/** @brief GIF X; defaults to Center with zero offset. @chinese GIF 横坐标，默认居中且偏移为 0。 */
@property (nonatomic, assign) TSDialDanMuCoordinate animationX;

/** @brief GIF Y; defaults to Center with zero offset. @chinese GIF 纵坐标，默认居中且偏移为 0。 */
@property (nonatomic, assign) TSDialDanMuCoordinate animationY;

/**
 * @brief Initialize an item with its static image.
 * @chinese 使用静态图片初始化弹幕资源项。
 * @param image EN: Required static image at its original pixel size. CN: 必填的原始像素尺寸静态图片。
 * @return EN: Item with default layout and scrolling values. CN: 使用默认布局和滚动参数的资源项。
 */
- (instancetype)initWithImage:(UIImage *)image NS_DESIGNATED_INITIALIZER;

/** @brief Disable default initialization. @chinese 禁用默认初始化。 */
- (instancetype)init NS_UNAVAILABLE;

/** @brief Disable new. @chinese 禁用 new。 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
