//
//  TSDialBitmapEncoder.h
//  TopStepToolKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class UIImage;

NS_ASSUME_NONNULL_BEGIN

/** @brief Bitmap algorithm error domain. @chinese 表盘图片算法错误域。 */
FOUNDATION_EXPORT NSErrorDomain const TSDialBitmapErrorDomain;

/** @brief Bitmap algorithm failures. @chinese 表盘图片算法错误码。 */
typedef NS_ENUM(NSInteger, TSDialBitmapErrorCode) {
    TSDialBitmapErrorInvalidInput = 4301,
    TSDialBitmapErrorAllocationFailed = 4302,
    TSDialBitmapErrorEncodingFailed = 4303,
    TSDialBitmapErrorDecodeFailed = 4304,
};

/** @brief Explicit pixel container format. @chinese 显式像素容器格式，与设备平台编号无关。 */
typedef NS_ENUM(NSInteger, TSDialBitmapFormat) {
    TSDialBitmapFormatRGB565BMP = 0,
    TSDialBitmapFormatPAR = 1,
    TSDialBitmapFormatPARV3 = 2,
};

/** @brief Neutral bitmap encoding parameters. @chinese 与平台无关的图片编码参数。 */
@interface TSDialBitmapOptions : NSObject
/**
 * @brief Output bitmap container format
 * @chinese 输出图片容器格式
 *
 * @discussion
 * [EN]: Defaults to TSDialBitmapFormatPARV3. Select RGB565BMP, PAR or PARV3 explicitly;
 *       the encoder does not infer a format from device information.
 * [CN]: 默认 TSDialBitmapFormatPARV3，显式选择 RGB565BMP、PAR 或 PARV3，
 *       编码器不会根据设备信息推断格式。
 */
@property (nonatomic, assign) TSDialBitmapFormat format;
/**
 * @brief PAR encoder filter switch
 * @chinese PAR 编码滤镜开关
 *
 * @discussion
 * [EN]: Defaults to NO. Passed to the PAR backend; it does not affect RGB565 BMP encoding.
 * [CN]: 默认 NO，传递给 PAR 编码后端，不影响 RGB565 BMP 编码。
 */
@property (nonatomic, assign) BOOL useFilter;
/**
 * @brief Target pixel width before rotation
 * @chinese 旋转前的目标像素宽度
 *
 * @discussion
 * [EN]: Defaults to 0 and must be in 1...65535. Width multiplied by height must not
 *       exceed 16,000,000; UIImage input is center-cropped to these dimensions.
 * [CN]: 默认 0，必须设置为 1...65535，宽高乘积不得超过 1600 万；
 *       UIImage 输入会居中裁剪到该目标尺寸。
 */
@property (nonatomic, assign) NSUInteger width;
/**
 * @brief Target pixel height before rotation
 * @chinese 旋转前的目标像素高度
 *
 * @discussion
 * [EN]: Defaults to 0 and must be in 1...65535, subject to the same total pixel budget as width.
 * [CN]: 默认 0，必须设置为 1...65535，并与 width 一起满足总像素预算。
 */
@property (nonatomic, assign) NSUInteger height;
/**
 * @brief Clockwise rotation in quarter turns
 * @chinese 顺时针旋转的四分之一圈次数
 *
 * @discussion
 * [EN]: Defaults to 0 and accepts 0...3. Odd values swap the encoded width and height;
 *       encodeRGBAPixels requires 0 because that entry consumes prepared pixels.
 * [CN]: 默认 0，范围为 0...3，奇数值会交换编码宽高；
 *       encodeRGBAPixels 接收已准备好的像素，因此该入口要求为 0。
 */
@property (nonatomic, assign) NSInteger rotate;
/**
 * @brief Whether PAR output retains transparency
 * @chinese PAR 输出是否保留透明通道
 *
 * @discussion
 * [EN]: Defaults to NO. Applies to PAR formats; RGB565 BMP has no alpha channel.
 * [CN]: 默认 NO，仅适用于 PAR 格式；RGB565 BMP 不包含透明通道。
 */
@property (nonatomic, assign) BOOL isTransparent;
@end

/** @brief Encoded image and index metadata. @chinese 编码后的图片及图片索引元数据。 */
@interface TSDialEncodedBitmap : NSObject
/**
 * @brief Encoded bitmap payload
 * @chinese 编码后的图片载荷
 *
 * @discussion
 * [EN]: Filled after successful encoding. Contains bitmap bytes only, without a GUI index or OTA wrapper.
 * [CN]: 编码成功后填充，仅包含图片字节，不包含 GUI 索引或 OTA 外壳。
 */
@property (nonatomic, copy, readonly) NSData *data;
/**
 * @brief Encoded pixel width
 * @chinese 编码后的像素宽度
 *
 * @discussion
 * [EN]: Actual output width after rotation; use this value when writing the image index.
 * [CN]: 应用旋转后的实际输出宽度，写入图片索引时使用该值。
 */
@property (nonatomic, assign, readonly) NSUInteger width;
/**
 * @brief Encoded pixel height
 * @chinese 编码后的像素高度
 *
 * @discussion
 * [EN]: Actual output height after rotation; use this value when writing the image index.
 * [CN]: 应用旋转后的实际输出高度，写入图片索引时使用该值。
 */
@property (nonatomic, assign, readonly) NSUInteger height;
/**
 * @brief Actual encoded bitmap format
 * @chinese 实际编码的图片格式
 *
 * @discussion
 * [EN]: Identifies the container in data. GUI colorType and compressType are resolved by the packing layer.
 * [CN]: 标识 data 的容器格式；GUI 的 colorType 和 compressType 由打包层另行确定。
 */
@property (nonatomic, assign, readonly) TSDialBitmapFormat format;
@end

/** @brief Android screen shaping parameters. @chinese Android 屏幕形状处理参数。 */
@interface TSDialShapeOptions : NSObject
/**
 * @brief Shaped output width in pixels
 * @chinese 形状处理后的输出像素宽度
 *
 * @discussion
 * [EN]: Defaults to 0. Requires 1...65535 and width * height no greater than 16,000,000.
 * [CN]: 默认 0，要求为 1...65535，且宽高乘积不超过 1600 万。
 */
@property (nonatomic, assign) NSUInteger width;
/**
 * @brief Shaped output height in pixels
 * @chinese 形状处理后的输出像素高度
 *
 * @discussion
 * [EN]: Defaults to 0. Requires 1...65535, within the shared pixel budget; input is stretched to this canvas.
 * [CN]: 默认 0，要求为 1...65535 并满足总像素预算；输入图片会拉伸到该画布尺寸。
 */
@property (nonatomic, assign) NSUInteger height;
/**
 * @brief Whether to use the Android-compatible circle mask
 * @chinese 是否使用与 Android 一致的圆形遮罩
 *
 * @discussion
 * [EN]: Defaults to NO. When YES, the circle uses width as its diameter and is
 *       centered at (width/2, width/2); cornerRadius does not shape the mask.
 * [CN]: 默认 NO；为 YES 时以 width 为直径，圆心为 (width/2, width/2)，
 *       此时不使用 cornerRadius 构造遮罩。
 */
@property (nonatomic, assign) BOOL isCircle;
/**
 * @brief Rectangle corner radius in target pixels
 * @chinese 矩形圆角半径，单位为目标像素
 *
 * @discussion
 * [EN]: Defaults to 0. Must be finite and nonnegative; rectangle shaping clamps
 *       it to half the smaller canvas dimension.
 * [CN]: 默认 0，必须为有限非负值；矩形处理时限制到画布较短边的一半。
 */
@property (nonatomic, assign) CGFloat cornerRadius;
@end

/** @brief Style overlay placement for a preview. @chinese 预览样式叠加参数。 */
@interface TSDialPreviewOptions : NSObject
/**
 * @brief Style image overlaid on the preview
 * @chinese 叠加到预览中的样式图片
 *
 * @discussion
 * [EN]: Defaults to nil, leaving the background unchanged. A style whose pixel
 *       size matches the background covers the full canvas and ignores the placement fields.
 * [CN]: 默认 nil，保留背景；若样式图与背景像素尺寸相同，则覆盖整个画布，忽略放置位置和尺寸字段。
 */
@property (nonatomic, strong, nullable) UIImage *styleImage;
/**
 * @brief Style left edge in background pixel coordinates
 * @chinese 背景像素坐标系中的样式左边缘
 *
 * @discussion
 * [EN]: Defaults to 0. Must be finite for a non-full-screen style; out-of-canvas portions are clipped.
 * [CN]: 默认 0，非全屏样式要求为有限值，超出画布的部分会被裁掉。
 */
@property (nonatomic, assign) CGFloat styleX;
/**
 * @brief Style top edge in background pixel coordinates
 * @chinese 背景像素坐标系中的样式上边缘
 *
 * @discussion
 * [EN]: Defaults to 0. Must be finite for a non-full-screen style; the origin is the top-left corner.
 * [CN]: 默认 0，非全屏样式要求为有限值，坐标原点为背景左上角。
 */
@property (nonatomic, assign) CGFloat styleY;
/**
 * @brief Style destination width in pixels
 * @chinese 样式的目标像素宽度
 *
 * @discussion
 * [EN]: Defaults to 0. A non-full-screen style requires a finite positive value;
 *       its pixels are resized to the specified destination rectangle.
 * [CN]: 默认 0，非全屏样式要求为有限正值；样式像素会缩放至指定目标矩形。
 */
@property (nonatomic, assign) CGFloat styleWidth;
/**
 * @brief Style destination height in pixels
 * @chinese 样式的目标像素高度
 *
 * @discussion
 * [EN]: Defaults to 0. A non-full-screen style requires a finite positive value.
 * [CN]: 默认 0，非全屏样式要求为有限正值。
 */
@property (nonatomic, assign) CGFloat styleHeight;
/**
 * @brief Optional style tint in packed AARRGGBB format
 * @chinese 可选的 AARRGGBB 格式样式着色值
 *
 * @discussion
 * [EN]: Defaults to nil, preserving the style colors. A nonnil NSNumber supplies its
 *       unsigned 32-bit value for SRC_IN tinting; this does not tint the background.
 * [CN]: 默认 nil，保留样式原色；非空时读取 NSNumber 的 32 位无符号值进行 SRC_IN 着色，
 *       不对背景着色。
 */
@property (nonatomic, copy, nullable) NSNumber *styleARGBColor;
@end

/** @brief Transparent canvas placement parameters. @chinese 透明画布图片放置参数。 */
@interface TSDialImagePlacementOptions : NSObject
/**
 * @brief Transparent canvas width in pixels
 * @chinese 透明画布的像素宽度
 *
 * @discussion
 * [EN]: Defaults to 0. Requires 1...65535 and width * height no greater than 16,000,000.
 * [CN]: 默认 0，要求为 1...65535，且宽高乘积不超过 1600 万。
 */
@property (nonatomic, assign) NSUInteger width;
/**
 * @brief Transparent canvas height in pixels
 * @chinese 透明画布的像素高度
 *
 * @discussion
 * [EN]: Defaults to 0. Requires 1...65535, within the shared pixel budget.
 * [CN]: 默认 0，要求为 1...65535，并满足总像素预算。
 */
@property (nonatomic, assign) NSUInteger height;
/**
 * @brief Destination image rectangle on the transparent canvas
 * @chinese 图片在透明画布上的目标矩形
 *
 * @discussion
 * [EN]: Defaults to CGRectZero, which must be replaced before use. Coordinates must
 *       be finite and dimensions positive; the origin is the top-left canvas corner.
 * [CN]: 默认 CGRectZero，使用前必须设置；坐标必须有限，宽高必须为正，
 *       原点为画布左上角。
 */
@property (nonatomic, assign) CGRect imageRect;
@end

/** @brief Stateless synchronous pixel algorithms. @chinese 无共享状态的同步像素算法。 */
@interface TSDialBitmapEncoder : NSObject
/**
 * @brief Encode top-to-bottom straight RGBA pixels without cropping or rotation.
 * @chinese 编码从上到下的非预乘 RGBA 像素，不裁剪、不旋转。
 * @param pixels EN: Exactly width * height * 4 bytes. CN: 精确为宽 × 高 × 4 字节。
 * @param options EN: Format, dimensions, alpha and filter; rotate must be zero. CN: 格式、尺寸、透明及滤镜参数；旋转必须为零。
 * @param error EN: Validation or encoding failure. CN: 校验或编码错误。
 * @return EN: Encoded resource or nil. CN: 编码结果，失败返回 nil。
 */
+ (nullable TSDialEncodedBitmap *)encodeRGBAPixels:(NSData *)pixels
                                         options:(TSDialBitmapOptions *)options
                                           error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Resolve Core Image pixels without redrawing an existing CGImage-backed image.
 * @chinese 解析 Core Image 像素；已有 CGImage 的图片原样返回，不重复绘制。
 * @param image EN: Static image with finite pixel dimensions. CN: 像素尺寸有限的静态图片。
 * @param error EN: Invalid geometry or rasterization failure. CN: 几何参数或光栅化错误。
 * @return EN: Original CGImage-backed image, or a scale-one raster in display orientation; nil on failure.
 * CN: 原有 CGImage 图片，或按显示方向生成的 scale=1 像素图；失败返回 nil。
 */
+ (nullable UIImage *)imageByRasterizingImage:(UIImage *)image error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Decode original file pixels without applying EXIF orientation, matching Android BitmapFactory.
 * @chinese 按 Android BitmapFactory 读取文件原始像素，不应用 EXIF 方向；严格对齐文件路径时使用此入口。
 * @param data EN: Local encoded image bytes. CN: 本地编码图片字节。
 * @param error EN: Read or decode failure. CN: 读取或解码失败信息。
 * @return EN: Original pixel dimensions with scale=1 and OrientationUp, or nil.
 * CN: 保留原始像素宽高，scale 为 1、方向为 Up 的图片，失败返回 nil。
 */
+ (nullable UIImage *)decodeImageData:(NSData *)data error:(NSError * _Nullable * _Nullable)error;
/**
 * @brief Center-crop, rotate, and encode a bitmap using Android packing rules.
 * @chinese 按 Android 打包规则居中裁剪、旋转并编码图片，可在后台调用；显式 UIImage 会规范化显示方向。
 * @param image EN: Source image. CN: 原始图片。
 * @param options EN: Encoding parameters. CN: 编码参数。
 * @param error EN: Failure details. CN: 失败信息。
 * @return EN: Encoded resource, or nil. CN: 编码资源，失败返回 nil。
 */
+ (nullable TSDialEncodedBitmap *)encodeImage:(UIImage *)image
                                       options:(TSDialBitmapOptions *)options
                                         error:(NSError * _Nullable * _Nullable)error;
/**
 * @brief Normalize, center-crop and rotate into straight A,R,G,B bytes.
 * @chinese 规范化、居中裁剪并旋转为非预乘 A、R、G、B 字节，用于跨端像素核对。
 * @param image EN: Source image. CN: 原始图片。
 * @param options EN: Logical size and rotation. CN: 逻辑尺寸及旋转参数。
 * @param error EN: Failure details. CN: 失败信息。
 * @return EN: Top-to-bottom straight ARGB bytes, or nil. CN: 从上到下的非预乘 ARGB 字节，失败返回 nil。
 */
+ (nullable NSData *)ARGBPixelsForImage:(UIImage *)image
                               options:(TSDialBitmapOptions *)options
                                 error:(NSError * _Nullable * _Nullable)error;
/**
 * @brief Stretch into a shape and composite edges over black.
 * @chinese 非等比拉伸至指定形状，边缘与透明区域合成到黑色背景。
 * @param image EN: Source image. CN: 原始图片。
 * @param options EN: Shape parameters. CN: 形状参数。
 * @param error EN: Failure details. CN: 失败信息。
 * @return EN: Shaped bitmap, or nil. CN: 形状处理后的图片，失败返回 nil。
 */
+ (nullable UIImage *)imageByShapingImage:(UIImage *)image
                                options:(TSDialShapeOptions *)options
                                  error:(NSError * _Nullable * _Nullable)error;
/**
 * @brief Overlay a style, preserving Android's full-screen style special case.
 * @chinese 叠加样式，并保留 Android 对全屏样式直接覆盖的特殊规则。
 * @param background EN: Background image. CN: 背景图片。
 * @param options EN: Overlay parameters. CN: 叠加参数。
 * @param error EN: Failure details. CN: 失败信息。
 * @return EN: Preview bitmap, or nil. CN: 预览图片，失败返回 nil。
 */
+ (nullable UIImage *)previewWithBackground:(UIImage *)background
                                   options:(TSDialPreviewOptions *)options
                                     error:(NSError * _Nullable * _Nullable)error;
/**
 * @brief Place an image on a transparent screen canvas.
 * @chinese 将图片绘制到透明屏幕画布，用于关联 GIF 帧及弹幕预览。
 * @param image EN: Source image. CN: 原始图片。
 * @param options EN: Canvas and placement. CN: 画布和放置位置。
 * @param error EN: Failure details. CN: 失败信息。
 * @return EN: Composed bitmap, or nil. CN: 合成图片，失败返回 nil。
 */
+ (nullable UIImage *)imageByPlacingImage:(UIImage *)image
                                options:(TSDialImagePlacementOptions *)options
                                  error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
