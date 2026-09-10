//
//  TSDialCell.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>
@class TSPeripheralScreen;

NS_ASSUME_NONNULL_BEGIN

/** @brief HTML-style installed-face and draft tile. @chinese HTML 样式的设备表盘与草稿卡片。 */
@interface TSDialCell : UICollectionViewCell
/** @brief Device geometry. @chinese 设备屏幕形状与比例。 */
@property (nonatomic, strong, nullable) TSPeripheralScreen *screen;
/** @brief Current-face highlight. @chinese 当前表盘高亮。 */
@property (nonatomic, assign) BOOL current;
/** @brief Show management affordances. @chinese 显示管理操作。 */
@property (nonatomic, assign) BOOL managing;
/** @brief Whether this item may be uninstalled. @chinese 此项是否可卸载。 */
@property (nonatomic, assign) BOOL removable;
/** @brief Removal request; does not perform device operations. @chinese 删除请求，不直接操作设备。 */
@property (nonatomic, copy, nullable) void (^onRemove)(void);
/**
 * @brief Render a title, subtitle and an optional real thumbnail.
 * @chinese 展示标题、副标题和可选的真实缩略图。
 * @param title EN: Display name. CN: 展示名称。
 * @param subtitle EN: Source or draft state. CN: 来源或草稿状态。
 * @param image EN: Cached thumbnail; nil means unavailable. CN: 缓存缩略图，nil 表示暂无预览。
 */
- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(nullable UIImage *)image;
@end

NS_ASSUME_NONNULL_END
