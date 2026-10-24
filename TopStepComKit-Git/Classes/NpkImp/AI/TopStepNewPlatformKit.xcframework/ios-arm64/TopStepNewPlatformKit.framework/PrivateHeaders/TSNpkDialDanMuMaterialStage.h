#import <UIKit/UIKit.h>
#import "TSNpkDialBuildStage.h"

@class TSDialDanMuItem;
NS_ASSUME_NONNULL_BEGIN

/** @brief Prepared native-size LVGL item. @chinese 已准备的原尺寸 LVGL 弹幕素材。 */
@interface TSNpkDialDanMuMaterialItem : NSObject
/**
 * @brief DanMu item from the working draft
 * @chinese 工作草稿中的弹幕项
 *
 * @discussion
 * [EN]: Retains the normalized source item for speed, direction and animation references; this material stage does not copy it again.
 * [CN]: 保留归一后的源项，供读取速度、方向与动画引用；素材阶段不会再次复制该对象。
 */
@property (nonatomic, strong) TSDialDanMuItem *source;
/**
 * @brief Static scrolling bitmap
 * @chinese 静态滚动图片
 *
 * @discussion
 * [EN]: Uses source.image at native pixel size; W30 non-lossless odd widths lose the rightmost column, while width one is rejected.
 * [CN]: 使用 source.image 原始像素尺寸；W30 非无损档遇奇数宽度裁去最右一列，宽度为 1 时拒绝处理。
 */
@property (nonatomic, strong) UIImage *image;
/**
 * @brief Resolved static-image position
 * @chinese 解析后的静态图片位置
 *
 * @discussion
 * [EN]: Screen-pixel coordinates after anchor and offset resolution using the prepared image size; may be negative for scrolling.
 * [CN]: 按处理后图片尺寸解析锚点并叠加偏移所得的屏幕像素坐标；为滚动可出现负值。
 */
@property (nonatomic, assign) CGPoint imagePosition;
/**
 * @brief Resolved GIF canvas position
 * @chinese 解析后的 GIF 画布位置
 *
 * @discussion
 * [EN]: Screen-pixel coordinates based on the full GIF canvas; remains CGPointZero and is unused when framePaths is empty.
 * [CN]: 按 GIF 完整画布解析的屏幕像素坐标；framePaths 为空时保持 CGPointZero 且不使用。
 */
@property (nonatomic, assign) CGPoint animationPosition;
/**
 * @brief Cached full GIF frame paths
 * @chinese 完整 GIF 帧的缓存路径
 *
 * @discussion
 * [EN]: Task-owned PNG files in playback order, produced one frame at a time; empty when the item has no animation.
 * [CN]: 按播放顺序逐帧生成的任务 PNG 文件；没有动画时为空数组，由任务工作目录统一清理。
 */
@property (nonatomic, copy) NSArray<NSString *> *framePaths;
/**
 * @brief Full GIF canvas size in pixels
 * @chinese GIF 完整画布尺寸，单位像素
 *
 * @discussion
 * [EN]: Taken from the first composited GIF frame and used for every cached frame; zero and unused without animation.
 * [CN]: 取自首个合成后 GIF 完整帧，用于所有缓存帧的资源尺寸；无动画时为零且不使用。
 */
@property (nonatomic, assign) CGSize animationSize;
/**
 * @brief Uniform animation frame interval in milliseconds
 * @chinese 动画统一帧间隔，单位毫秒
 *
 * @discussion
 * [EN]: Integer mean of decoded frame durations, clamped to at least 1 and validated through INT32_MAX; zero without animation.
 * [CN]: 解码帧时长总和除以帧数并向下取整，最少 1、最大 INT32_MAX；无动画时为 0。
 */
@property (nonatomic, assign) NSUInteger intervalMillis;
@end

/** @brief Shared result consumed by preview/resource/screen stages. @chinese 供预览、资源与屏幕阶段共享的素材结果。 */
@interface TSNpkDialDanMuMaterial : NSObject
/**
 * @brief Prepared DanMu items in draft order
 * @chinese 按草稿顺序准备的弹幕素材项
 *
 * @discussion
 * [EN]: Nonempty after successful preparation; shared by preview, resource planning and screen editing during the same task.
 * [CN]: 素材准备成功后非空；同一任务的预览、资源规划与屏幕编辑复用此顺序。
 */
@property (nonatomic, copy) NSArray<TSNpkDialDanMuMaterialItem *> *items;
@end

/** @brief Prepares LVGL scrolling images and GIF frames. @chinese 准备 LVGL 滚动图片与 GIF 帧。 */
@interface TSNpkDialDanMuMaterialStage : NSObject <TSNpkDialBuildStage>
@end
NS_ASSUME_NONNULL_END
