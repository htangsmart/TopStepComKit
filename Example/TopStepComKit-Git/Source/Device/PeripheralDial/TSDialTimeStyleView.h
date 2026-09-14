//
//  TSDialTimeStyleView.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>
@class TSDialEditorState, TSCustomDialStyleConstraint;

NS_ASSUME_NONNULL_BEGIN

/** @brief Reusable time style and color section. @chinese 可复用的时间样式与颜色区域。 */
@interface TSDialTimeStyleView : UIView
/** @brief Style selection event. @chinese 样式选择事件。 */
@property (nonatomic, copy, nullable) void (^onStyleSelected)(NSInteger style);
/** @brief Preset color event. @chinese 预设颜色事件。 */
@property (nonatomic, copy, nullable) void (^onColorSelected)(NSString *hex);
/** @brief Open the shared picker. @chinese 请求打开共用选色器。 */
@property (nonatomic, copy, nullable) void (^onCustomColorRequested)(void);
/** @brief Time visibility event. @chinese 时间可见状态事件。 */
@property (nonatomic, copy, nullable) void (^onVisibilityChanged)(BOOL visible);
/** @brief Required section height. @chinese 当前所需高度。 */
@property (nonatomic, assign, readonly) CGFloat preferredHeight;
/** @brief Render values without changing state. @chinese 渲染状态，不修改草稿。
 * @param state EN: Editor state. CN: 编辑状态。 @param constraint EN: Device options. CN: 设备选项。
 * @param images EN: Images keyed by style. CN: 样式图片。 */
- (void)configureWithState:(TSDialEditorState *)state
               constraint:(nullable TSCustomDialStyleConstraint *)constraint
                   images:(NSDictionary<NSNumber *, UIImage *> *)images;
@end

NS_ASSUME_NONNULL_END
