#import <UIKit/UIKit.h>
@class TSNpkDialBuildContext, TSNpkDialStyleResource, TSNpkDialGuiTemplateSnapshot;
NS_ASSUME_NONNULL_BEGIN
/** @brief GUI preview composition without changing background resources. @chinese 不修改背景资源的 GUI 预览合成。 */
@interface TSNpkDialGuiPreviewRenderer : NSObject
/** @brief Shape a screen background. @chinese 处理屏幕背景形状。
 * @param image EN: Source pixels. CN: 源图片。
 * @param context EN: Frozen device facts. CN: 冻结设备事实。
 * @param error EN: Pixel error. CN: 像素处理错误。
 * @return EN: Shaped screen image. CN: 处理后的屏幕图片。 */
+ (nullable UIImage *)background:(UIImage *)image context:(TSNpkDialBuildContext *)context error:(NSError **)error;
/**
 * @brief Compose a template preview using the prepared component settings
 * @chinese 使用已准备的组件配置合成模板预览
 *
 * @param background
 * EN: Shaped background without a time overlay.
 * CN: 未叠加时间的已处理背景。
 * @param context
 * EN: The build task, including an optional explicit preview.
 * CN: 构建任务，可包含调用方明确提供的成品预览。
 * @param snapshot
 * EN: The same prepared template used by the package writer.
 * CN: 与写包使用的同一已准备模板。
 * @param error
 * EN: Missing asset or composition error.
 * CN: 素材缺失或合成错误。
 * @return
 * EN: Preview at the device preview size; background pixels are not changed.
 * CN: 设备预览尺寸的图片，不修改背景像素。
 */
+ (nullable UIImage *)previewWithBackground:(UIImage *)background context:(TSNpkDialBuildContext *)context
    templateSnapshot:(TSNpkDialGuiTemplateSnapshot *)snapshot error:(NSError **)error;
/** @brief Compose the preview from actual rendered pixels. @chinese 使用真实处理结果合成预览。
 * @param background EN: Processed background. CN: 已处理背景。
 * @param context EN: Build input. CN: 构建输入。
 * @param resource EN: Selected template metadata. CN: 模板元数据。
 * @param generated EN: Whether style tint is supported. CN: 是否采用支持染色的新生成路径。
 * @param error EN: Composition error. CN: 合成错误。
 * @return EN: Preview at the captured preview size. CN: 快照预览尺寸的图片。 */
+ (nullable UIImage *)previewWithBackground:(UIImage *)background context:(TSNpkDialBuildContext *)context
    resource:(TSNpkDialStyleResource *)resource generated:(BOOL)generated error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
