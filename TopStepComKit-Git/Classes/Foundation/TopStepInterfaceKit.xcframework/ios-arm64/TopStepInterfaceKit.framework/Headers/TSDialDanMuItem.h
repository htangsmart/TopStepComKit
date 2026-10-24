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

/**
 * @brief Required static image for this scrolling item
 * @chinese 当前弹幕资源项的必填静态图片
 *
 * @discussion
 * [EN]: Supplied by initWithImage:. Must be a nonempty UIImage without an animated
 *       images array. The original pixel size is used for layout; it need not fill
 *       the screen. Model copies share the image, so keep its content unchanged.
 * [CN]: 由 initWithImage: 提供，必须是非空且不含动画 images 数组的 UIImage。
 *       布局使用原始像素尺寸，不要求铺满屏幕；模型复制时共享图片，应保持内容不变。
 */
@property (nonatomic, strong, readonly) UIImage *image;

/**
 * @brief Horizontal coordinate of the static image
 * @chinese 静态图片的横向坐标
 *
 * @discussion
 * [EN]: Defaults to Start with offset 0. Uses screen pixels and a valid
 *       TSDialDanMuAnchor; offset must be in -524288...524287.
 *       Negative offsets and positions outside the screen are allowed.
 * [CN]: 默认 Start 锚点、偏移 0，采用屏幕像素和有效的 TSDialDanMuAnchor。
 *       offset 范围为 -524288...524287，允许负偏移及屏幕外位置。
 */
@property (nonatomic, assign) TSDialDanMuCoordinate imageX;

/**
 * @brief Vertical coordinate of the static image
 * @chinese 静态图片的纵向坐标
 *
 * @discussion
 * [EN]: Defaults to Center with offset 0. Non-absolute anchors align the original
 *       image height within the screen before adding the signed pixel offset.
 *       A valid anchor and offset in -524288...524287 are required.
 * [CN]: 默认 Center 锚点、偏移 0。非 Absolute 锚点先按原始图片高度在屏幕内对齐，
 *       再加有符号像素偏移；锚点必须有效，offset 范围为 -524288...524287。
 */
@property (nonatomic, assign) TSDialDanMuCoordinate imageY;

/**
 * @brief Scrolling speed in pixels per second
 * @chinese 滚动速度，单位像素每秒
 *
 * @discussion
 * [EN]: Defaults to 60. Must be finite and strictly positive; zero, negative values,
 *       NaN, and infinity are invalid. The Provider converts this semantic speed to
 *       its supported timing representation during build.
 * [CN]: 默认 60，必须为有限正数；0、负数、NaN 和无穷值均无效。
 *       Provider 在造包时将该语义速度转换为设备支持的计时表示。
 */
@property (nonatomic, assign) float walkSpeed;

/**
 * @brief Whether the image scrolls from left to right
 * @chinese 图片是否从左向右滚动
 *
 * @discussion
 * [EN]: Defaults to NO for right-to-left scrolling. YES selects left-to-right
 *       scrolling; speed remains the positive magnitude in walkSpeed.
 * [CN]: 默认 NO，表示从右向左滚动；YES 表示从左向右滚动。
 *       方向与速度分开设置，walkSpeed 始终使用正数大小。
 */
@property (nonatomic, assign) BOOL leftToRight;

/**
 * @brief Optional absolute path to a local GIF animation
 * @chinese 可选的本地 GIF 动画绝对路径
 *
 * @discussion
 * [EN]: Defaults to nil for a static-only item. A nonnil value must be an absolute
 *       path to an existing, readable file rather than a directory; an empty string
 *       is invalid. GIF decoding and platform frame constraints are handled during
 *       build. Keep the source unchanged until completion; the SDK does not delete it.
 * [CN]: 默认 nil，表示仅静态资源。非 nil 时必须为已存在、可读文件的绝对路径，
 *       不能是目录或空字符串。GIF 解码及平台帧数约束在造包时处理。
 *       完成前应保持源文件不变，SDK 不删除该调用方文件。
 */
@property (nonatomic, copy, nullable) NSString *animationFilePath;

/**
 * @brief Horizontal coordinate of the associated GIF animation
 * @chinese 关联 GIF 动画的横向坐标
 *
 * @discussion
 * [EN]: Defaults to Center with offset 0 and uses the same semantic pixel coordinate
 *       rules as imageX. A valid anchor and offset in -524288...524287 are required,
 *       including when animationFilePath is nil.
 * [CN]: 默认 Center 锚点、偏移 0，采用与 imageX 相同的语义像素坐标规则。
 *       即使 animationFilePath 为 nil，锚点也必须有效，
 *       offset 仍需在 -524288...524287 范围内。
 */
@property (nonatomic, assign) TSDialDanMuCoordinate animationX;

/**
 * @brief Vertical coordinate of the associated GIF animation
 * @chinese 关联 GIF 动画的纵向坐标
 *
 * @discussion
 * [EN]: Defaults to Center with offset 0 and uses the same semantic pixel coordinate
 *       rules as imageY. Negative offsets and off-screen positions are allowed
 *       within -524288...524287; this field is validated even for static-only items.
 * [CN]: 默认 Center 锚点、偏移 0，采用与 imageY 相同的语义像素坐标规则。
 *       在 -524288...524287 内允许负偏移和屏幕外位置；
 *       即使资源项只有静态图片，也会校验本字段。
 */
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
