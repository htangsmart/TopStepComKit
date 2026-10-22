#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@class TSNpkScreenDocument;
@class TSNpkDialDanMuMaterial;
NS_ASSUME_NONNULL_BEGIN
/** @brief Rebuilds the LVGL scrolling/animation binding graph. @chinese 重建 LVGL 滚动与动画绑定图。 */
@interface TSNpkDanMuScreenEditor : NSObject
/**
 * @brief Apply prepared resources and quantized motion to a template.
 * @chinese 将已准备的资源与量化运动应用到模板。
 * @param material EN: Prepared native-size images. CN: 已准备的原尺寸素材。
 * @param indexes EN: Static resource index for each item. CN: 各项静态图片的资源索引。
 * @param screenSize EN: Device screen in pixels. CN: 设备屏幕像素尺寸。
 * @param backgroundIndex EN: Fixed image background index. CN: 固定图片背景索引。
 * @param document EN: Mutable template document. CN: 可变模板文档。
 * @param error EN: Invalid graph or motion details. CN: 无效绑定图或运动信息。
 * @return EN: YES after a complete graph replacement. CN: 完整替换绑定图后返回 YES。
 */
+ (BOOL)applyMaterial:(TSNpkDialDanMuMaterial *)material tableIndexes:(NSArray<NSNumber *> *)indexes backgroundIndex:(NSUInteger)backgroundIndex screenSize:(CGSize)screenSize document:(TSNpkScreenDocument *)document error:(NSError *_Nullable *_Nullable)error;
@end
NS_ASSUME_NONNULL_END
