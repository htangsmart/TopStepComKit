#import <Foundation/Foundation.h>
@class TSNpkDialBuildContext, TSNpkDialStyleResource, TSDialArtifact;
NS_ASSUME_NONNULL_BEGIN
/** @brief Template-free GUI resource graph generation. @chinese 无模板 GUI 资源图生成。 */
@interface TSNpkDialGuiGeneratedBuilder : NSObject
/** @brief Generate one of the four no-component modes. @chinese 生成无组件四模式之一。
 * @param context EN: Frozen build input. CN: 冻结构建输入。
 * @param resource EN: Optional cloud style metadata. CN: 云样式元数据。
 * @param error EN: Build error. CN: 构建错误。
 * @return EN: Task-local artifact, publication is owned by the entry. CN: 任务内产物，由入口发布。 */
+ (nullable TSDialArtifact *)buildWithContext:(TSNpkDialBuildContext *)context
    templateResource:(TSNpkDialStyleResource *)resource error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
