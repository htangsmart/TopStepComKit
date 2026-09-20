//
//  TSFitAIWatchFaceImageProcessor.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Images derived from one generated watch-face background
 * @chinese 单张 AI 背景图派生出的三类图片
 */
@interface TSFitAIWatchFaceProcessedImages : NSObject

/** @brief Preview sent to the watch for confirmation @chinese 发送到手表供确认的预览图 */
@property (nonatomic, strong, readonly) UIImage *watchPreviewImage;

/** @brief Full-size watch-face background @chinese 表盘全尺寸背景图 */
@property (nonatomic, strong, readonly) UIImage *backgroundImage;

/** @brief Watch-face package preview @chinese 表盘二进制包使用的预览图 */
@property (nonatomic, strong, readonly) UIImage *dialPreviewImage;

/**
 * @brief Create a processed image group
 * @chinese 创建派生图片组
 *
 * @param watchPreviewImage EN: Watch confirmation preview. CN: 手表确认预览图。
 * @param backgroundImage EN: Full-size background. CN: 全尺寸背景图。
 * @param dialPreviewImage EN: Dial package preview. CN: 表盘包预览图。
 * @return EN: An immutable image group. CN: 不可变图片组。
 */
- (instancetype)initWithWatchPreviewImage:(UIImage *)watchPreviewImage
                          backgroundImage:(UIImage *)backgroundImage
                         dialPreviewImage:(UIImage *)dialPreviewImage NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * @brief Aspect-fill and shape-aware image processor for AI watch faces
 * @chinese AI 表盘等比填充与形状适配图片处理器
 */
@interface TSFitAIWatchFaceImageProcessor : NSObject

/**
 * @brief Derive exact-size watch preview, background and dial preview images
 * @chinese 派生尺寸严格匹配的手表预览、背景和表盘预览图
 *
 * @param sourceImage EN: Original AI-generated image. CN: AI 生成的原图。
 * @param watchPreviewSize EN: Preview size requested by the watch. CN: 手表请求的预览尺寸。
 * @param shouldClipWatchPreviewToCircle
 * EN: Whether the watch preview should be clipped to a circle.
 * CN: 是否将手表预览图裁剪为圆形。
 * @param watchPreviewScreenCornerRadius
 * EN: Device screen corner radius for a rectangular preview, in screen coordinates.
 * CN: 方形预览使用的设备屏幕圆角半径，单位为屏幕坐标系像素。
 * @param screenSize EN: Connected device screen size. CN: 当前设备屏幕尺寸。
 * @param dialPreviewSize EN: Dial package preview size. CN: 表盘包预览尺寸。
 * @param error EN: Receives validation or rendering error. CN: 接收参数或渲染错误。
 * @return EN: Three aspect-filled images, or nil on failure. CN: 三张等比填充图片，失败时为 nil。
 */
- (nullable TSFitAIWatchFaceProcessedImages *)processSourceImage:(UIImage *)sourceImage
                                                watchPreviewSize:(CGSize)watchPreviewSize
                                        clipWatchPreviewToCircle:(BOOL)shouldClipWatchPreviewToCircle
                                   watchPreviewScreenCornerRadius:(CGFloat)watchPreviewScreenCornerRadius
                                                      screenSize:(CGSize)screenSize
                                                 dialPreviewSize:(CGSize)dialPreviewSize
                                                           error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
