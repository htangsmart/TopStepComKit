#import <Foundation/Foundation.h>
@class TSNpkDialBuildContext, TSNpkDialStyleResource, TSDialArtifact;
NS_ASSUME_NONNULL_BEGIN
/** @brief GUI-only build routing using captured facts. @chinese 根据捕获事实分派 GUI 构建。 */
@interface TSNpkDialGuiPackageBuilder : NSObject
/** @brief Build a task-local GUI BIN and matching preview. @chinese 构建任务内 GUI BIN 及对应预览。
 * @param context EN: Frozen normalized input. CN: 冻结归一输入。
 * @param resource EN: Resolved typed template. CN: 已解析类型化模板。
 * @param error EN: Build failure. CN: 构建失败。
 * @return EN: Complete artifact, publication belongs to the caller. CN: 完整产物，由调用入口发布。 */
+ (nullable TSDialArtifact *)buildWithContext:(TSNpkDialBuildContext *)context
    templateResource:(TSNpkDialStyleResource *)resource error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
