//
//  UIImage+Tool.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/11/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Tool)

/**
 * @brief Crop bitmap to shape with black background padding
 * @chinese 根据形状裁剪bitmap，边缘补充黑色
 *
 * @param image
 * EN: Source image
 * CN: 源图片
 *
 * @param width
 * EN: Target width
 * CN: 目标宽度
 *
 * @param height
 * EN: Target height
 * CN: 目标高度
 *
 * @param cornerRadius
 * EN: Corner radius (0 for rectangle, positive for rounded rectangle, negative for circle)
 * CN: 圆角半径（0为矩形，正数为圆角矩形，负数为圆形）
 *
 * @return
 * EN: Cropped image with black background padding
 * CN: 裁剪后的图片，边缘补充黑色
 */
+ (nullable UIImage *)cropImage:(UIImage *)image
                                 width:(NSInteger)width
                                height:(NSInteger)height
                          cornerRadius:(CGFloat)cornerRadius;


/**
 * @brief Convert UIImage to RGBA data (for TSC compression)
 * @chinese 将UIImage转换为RGBA数据（用于TSC压缩）
 *
 * @param image
 * EN: Source image
 * CN: 源图片
 *
 * @return
 * EN: RGBA data, each pixel occupies 4 bytes (R, G, B, A), using big-endian byte order
 * CN: RGBA数据，每个像素占4个字节（R, G, B, A），使用大端字节序
 *
 * @discussion
 * [EN]: This method converts UIImage to RGBA data format suitable for TSC compression.
 *       Uses kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big for compatibility with TSC compressor.
 * [CN]: 此方法将UIImage转换为适用于TSC压缩的RGBA数据格式。
 *       使用 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big 以确保与TSC压缩器兼容。
 */
+ (nullable NSData *)imageRGBADataWithImage:(UIImage *)image;

/**
 * @brief Convert RGBA byte array to UIImage
 * @chinese 将RGBA字节数组转换为UIImage
 *
 * @param rgbaBytes
 * EN: RGBA byte array, each pixel occupies 4 bytes (R, G, B, A)
 * CN: RGBA字节数组，每个像素占4个字节（R, G, B, A）
 *
 * @param width
 * EN: Image width
 * CN: 图片宽度
 *
 * @param height
 * EN: Image height
 * CN: 图片高度
 *
 * @return
 * EN: Converted UIImage
 * CN: 转换后的UIImage
 */
+ (nullable UIImage *)rgbaBytesToBitmap:(NSData *)rgbaBytes
                                   width:(NSInteger)width
                                  height:(NSInteger)height;


/**
 * @brief Generate preview image by compositing sub image and processing
 * @chinese 通过合成子图片并处理生成预览图
 *
 * @param originImage
 * EN: Background image (base image)
 * CN: 背景图片（基础图片）
 *
 * @param imageSize
 * EN: Target preview image size
 * CN: 目标预览图尺寸
 *
 * @param cornerRadius
 * EN: Corner radius for the preview image
 * CN: 预览图圆角半径
 *
 * @param maxKBSize
 * EN: Maximum file size in KB (0 or negative value will use default 300KB)
 * CN: 最大文件大小（KB），0或负值将使用默认值300KB
 *
 * @param subImage
 * EN: Sub image to be composited onto the background image
 * CN: 要合成到背景图片上的子图片
 *
 * @param subRect
 * EN: Rectangle area where the sub image should be placed
 * CN: 子图片放置的矩形区域
 *
 * @param keepTransparentBackground
 * EN: If YES, areas outside the rounded clip remain transparent and PNG compression is preferred.
 *     If NO, uses black background outside the clip (legacy behavior).
 * CN: 为 YES 时圆角外侧透明且优先 PNG 压缩；为 NO 时使用黑色背景（默认/兼容旧行为）。
 *
 * @param completion
 * EN: Completion callback with result image and error
 * CN: 完成回调，返回结果图片和错误信息
 */
+ (void)previewImageWith:(UIImage *)originImage
               imageSize:(CGSize)imageSize
            cornerRadius:(CGFloat)cornerRadius
               maxKBSize:(CGFloat)maxKBSize
                subImage:(nullable UIImage *)subImage
                 subRect:(CGRect)subRect
 keepTransparentBackground:(BOOL)keepTransparentBackground
              completion:(void (^)(UIImage * _Nullable resultImage, NSError * _Nullable error))completion;

/**
 * @brief Generate a preview with explicit time-overlay control.
 * @chinese 显式控制时间图层的预览合成，处理完成后在主线程回调。
 * @param originImage EN: Background image. CN: 背景图片。
 * @param imageSize EN: Output pixel size. CN: 输出像素尺寸。
 * @param cornerRadius EN: Output corner radius. CN: 输出圆角。
 * @param maxKBSize EN: KB budget, default 300. CN: KB 上限，默认 300。
 * @param subImage EN: Optional time image. CN: 可选时间图片。
 * @param subRect EN: Time frame in background pixels. CN: 背景像素坐标中的时间区域。
 * @param renderTime EN: NO ignores the time image and frame. CN: NO 时忽略时间图片和区域。
 * @param keepTransparentBackground EN: Preserve transparent corners. CN: 是否保留透明圆角。
 * @param completion EN: Main-thread result callback. CN: 主线程结果回调。
 */
+ (void)previewImageWith:(UIImage *)originImage
               imageSize:(CGSize)imageSize
            cornerRadius:(CGFloat)cornerRadius
               maxKBSize:(CGFloat)maxKBSize
                subImage:(nullable UIImage *)subImage
                 subRect:(CGRect)subRect
              renderTime:(BOOL)renderTime
keepTransparentBackground:(BOOL)keepTransparentBackground
              completion:(void (^)(UIImage *_Nullable resultImage, NSError *_Nullable error))completion;

/**
 * @brief Compose and process a preview synchronously on the calling worker queue.
 * @chinese 在调用方工作队列同步合成预览，复用异步入口的缩放、圆角及压缩规则。
 * @param originImage EN: Background. CN: 背景图。
 * @param imageSize EN: Output pixels. CN: 输出像素尺寸。
 * @param cornerRadius EN: Output corner radius. CN: 输出圆角。
 * @param maxKBSize EN: Byte budget in KB; defaults to 300. CN: KB 上限，默认 300。
 * @param subImage EN: Optional overlay. CN: 可选叠加图片。
 * @param subRect EN: Overlay frame in background pixels. CN: 背景像素坐标中的叠加区域。
 * @param renderTime EN: Whether to composite the supplied time overlay. CN: 是否绘制传入的时间图层。
 * @param keepTransparentBackground EN: Preserve transparent corners. CN: 是否保留透明圆角。
 * @param error EN: Failure details. CN: 错误信息。
 * @return EN: Processed preview or nil. CN: 处理后的预览，失败为 nil。
 */
+ (nullable UIImage *)composedPreviewImageWith:(UIImage *)originImage
                                    imageSize:(CGSize)imageSize
                                 cornerRadius:(CGFloat)cornerRadius
                                    maxKBSize:(CGFloat)maxKBSize
                                     subImage:(nullable UIImage *)subImage
                                      subRect:(CGRect)subRect
                                   renderTime:(BOOL)renderTime
                    keepTransparentBackground:(BOOL)keepTransparentBackground
                                        error:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Generate preview image (defaults to black background outside rounded area)
 * @chinese 生成预览图（圆角外侧默认黑色背景）
 */
+ (void)previewImageWith:(UIImage *)originImage imageSize:(CGSize)imageSize cornerRadius:(CGFloat)cornerRadius maxKBSize:(CGFloat)maxKBSize subImage:(UIImage *)subImage subRect:(CGRect)subRect completion:(void (^)(UIImage * _Nullable resultImage, NSError * _Nullable error))completion;

+ (void)dealImage:(UIImage *)targetImage
        imageSize:(CGSize)imageSize
     cornerRadius:(CGFloat)cornerRadius
        maxKBSize:(CGFloat)maxKBSize
keepTransparentBackground:(BOOL)keepTransparentBackground
       completion:(void (^)(UIImage * _Nullable previewImage, NSError *_Nullable error))completion;

+ (void)dealImage:(UIImage *)targetImage imageSize:(CGSize)imageSize cornerRadius:(CGFloat)cornerRadius maxKBSize:(CGFloat)maxKBSize completion:(void (^)(UIImage * _Nullable previewImage,NSError *_Nullable error ))completion;

/**
 * @brief Tint image with specified color
 * @chinese 用指定颜色对图片进行着色
 *
 * @param tintColor
 * EN: Color to tint the image with
 * CN: 用于着色的颜色
 *
 * @return
 * EN: New image tinted with the specified color, nil if failed
 * CN: 着色后的新图片，失败返回nil
 *
 * @discussion
 * [EN]: This method tints all non-transparent pixels in the image with the specified color,
 *       while preserving the original alpha channel. The original image's shape and transparency
 *       are maintained, only the color is changed.
 *       This is useful for changing icon colors or applying color filters to images.
 * [CN]: 此方法用指定颜色对图片中所有非透明像素进行着色，同时保留原始的alpha通道。
 *       原图的形状和透明度保持不变，只改变颜色。
 *       适用于改变图标颜色或对图片应用颜色滤镜。
 *
 * @example
 * // 将白色图标改为黄色
 * UIImage *originalImage = [UIImage imageNamed:@"icon"];
 * UIImage *yellowImage = [originalImage imageTintedWithColor:[UIColor yellowColor]];
 */
- (nullable UIImage *)imageTintedWithColor:(UIColor *)tintColor;

@end

NS_ASSUME_NONNULL_END
