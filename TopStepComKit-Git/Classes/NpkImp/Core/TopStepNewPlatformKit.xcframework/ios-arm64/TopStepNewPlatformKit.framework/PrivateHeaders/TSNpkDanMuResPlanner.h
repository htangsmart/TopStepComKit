#import "TSNpkResPlan.h"
@class TSNpkDialDanMuMaterial;
NS_ASSUME_NONNULL_BEGIN
/** @brief Assigns LVGL static/GIF resources after removing template placeholders. @chinese 删除模板占位后分配 LVGL 静态与 GIF 资源。 */
@interface TSNpkDanMuResPlanner : NSObject <TSNpkResPlanner>
/**
 * @brief Initialize with the already prepared material.
 * @chinese 使用已准备的素材初始化。
 * @param material EN: Shared material result. CN: 共享素材结果。
 * @return EN: Resource planner. CN: 资源规划器。
 */
- (instancetype)initWithMaterial:(TSNpkDialDanMuMaterial *)material;
@end
NS_ASSUME_NONNULL_END
