//
//  TSFitDialBitmapEncoder.h
//  TopStepFitKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class UIImage;

NS_ASSUME_NONNULL_BEGIN

/** @brief Bitmap algorithm error domain. @chinese 表盘图片算法错误域。 */
FOUNDATION_EXPORT NSErrorDomain const TSFitDialBitmapErrorDomain;

/** @brief Bitmap algorithm failures. @chinese 表盘图片算法错误码。 */
typedef NS_ENUM(NSInteger, TSFitDialBitmapErrorCode) {
    TSFitDialBitmapErrorInvalidInput = 4301,
    TSFitDialBitmapErrorAllocationFailed = 4302,
    TSFitDialBitmapErrorEncodingFailed = 4303,
    TSFitDialBitmapErrorDecodeFailed = 4304,
};

/** @brief FitCloud bitmap encoding parameters. @chinese FitCloud 图片编码参数。 */
@interface TSFitDialBitmapOptions : NSObject
/** @brief Platform: 3 for 568X, 4 for 579X. @chinese 平台：3 为 568X，4 为 579X。 */
@property (nonatomic, assign) NSInteger platform;
/** @brief Logical pixel width before rotation. @chinese 旋转前的逻辑像素宽度。 */
@property (nonatomic, assign) NSUInteger width;
/** @brief Logical pixel height before rotation. @chinese 旋转前的逻辑像素高度。 */
@property (nonatomic, assign) NSUInteger height;
/** @brief Clockwise quarter turns, 0 through 3. @chinese 顺时针旋转次数，每次 90 度，范围 0～3。 */
@property (nonatomic, assign) NSInteger rotate;
/** @brief Encode an alpha-bearing PAR image. @chinese 是否编码带透明通道的 PAR 图片。 */
@property (nonatomic, assign) BOOL isTransparent;
@end

/** @brief Encoded image and index metadata. @chinese 编码后的图片及图片索引元数据。 */
@interface TSFitDialEncodedBitmap : NSObject
/** @brief Encoded resource bytes. @chinese 编码后的资源字节。 */
@property (nonatomic, copy, readonly) NSData *data;
/** @brief Pixel width after rotation. @chinese 旋转后的像素宽度。 */
@property (nonatomic, assign, readonly) NSUInteger width;
/** @brief Pixel height after rotation. @chinese 旋转后的像素高度。 */
@property (nonatomic, assign, readonly) NSUInteger height;
/** @brief Compression: 1 PAR, 2 transparent PAR, 5 RGB565 BMP. @chinese 压缩类型：1 PAR、2 透明 PAR、5 RGB565 BMP。 */
@property (nonatomic, assign, readonly) uint8_t compressType;
@end

/** @brief Android screen shaping parameters. @chinese Android 屏幕形状处理参数。 */
@interface TSFitDialShapeOptions : NSObject
/** @brief Output pixel width. @chinese 输出像素宽度。 */
@property (nonatomic, assign) NSUInteger width;
/** @brief Output pixel height. @chinese 输出像素高度。 */
@property (nonatomic, assign) NSUInteger height;
/** @brief Use a circle centered at (width/2,width/2). @chinese 使用以宽度一半为圆心横纵坐标的圆形。 */
@property (nonatomic, assign) BOOL isCircle;
/** @brief Rectangle corner radius in pixels. @chinese 矩形圆角半径，单位像素。 */
@property (nonatomic, assign) CGFloat cornerRadius;
@end

/** @brief Style overlay placement for a preview. @chinese 预览样式叠加参数。 */
@interface TSFitDialPreviewOptions : NSObject
/** @brief Style bitmap; nil preserves the background. @chinese 样式图片；为空时保留背景。 */
@property (nonatomic, strong, nullable) UIImage *styleImage;
/** @brief Style left edge in pixels. @chinese 样式左边缘，单位像素。 */
@property (nonatomic, assign) CGFloat styleX;
/** @brief Style top edge in pixels. @chinese 样式上边缘，单位像素。 */
@property (nonatomic, assign) CGFloat styleY;
/** @brief Style destination width. @chinese 样式目标宽度。 */
@property (nonatomic, assign) CGFloat styleWidth;
/** @brief Style destination height. @chinese 样式目标高度。 */
@property (nonatomic, assign) CGFloat styleHeight;
/** @brief Optional packed AARRGGBB SRC_IN tint. @chinese 可选 AARRGGBB 格式 SRC_IN 着色值。 */
@property (nonatomic, copy, nullable) NSNumber *styleARGBColor;
@end

/** @brief Transparent canvas placement parameters. @chinese 透明画布图片放置参数。 */
@interface TSFitDialImagePlacementOptions : NSObject
/** @brief Canvas pixel width. @chinese 画布像素宽度。 */
@property (nonatomic, assign) NSUInteger width;
/** @brief Canvas pixel height. @chinese 画布像素高度。 */
@property (nonatomic, assign) NSUInteger height;
/** @brief Image rectangle in top-left pixel coordinates. @chinese 左上角为原点的图片像素矩形。 */
@property (nonatomic, assign) CGRect imageRect;
@end

/** @brief Stateless synchronous FitCloud pixel algorithms. @chinese 无共享状态的同步 FitCloud 像素算法。 */
@interface TSFitDialBitmapEncoder : NSObject
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
+ (nullable TSFitDialEncodedBitmap *)encodeImage:(UIImage *)image
                                       options:(TSFitDialBitmapOptions *)options
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
                               options:(TSFitDialBitmapOptions *)options
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
                                options:(TSFitDialShapeOptions *)options
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
                                   options:(TSFitDialPreviewOptions *)options
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
                                options:(TSFitDialImagePlacementOptions *)options
                                  error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
