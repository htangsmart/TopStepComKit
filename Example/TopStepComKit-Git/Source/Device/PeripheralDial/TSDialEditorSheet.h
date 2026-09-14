//
//  TSDialEditorSheet.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Shared HTML-style bottom panel. @chinese HTML 样式共用底部面板。 */
@interface TSDialEditorSheet : UIView
/** @brief Content container. @chinese 内容容器。 */
@property (nonatomic, strong, readonly) UIView *contentView;
/** @brief Panel title. @chinese 面板标题。 */
@property (nonatomic, copy) NSString *title;
/** @brief Requested content height. @chinese 内容所需高度。 */
@property (nonatomic, assign) CGFloat contentHeight;
/** @brief Horizontal content margin, defaults to 20 points. @chinese 内容水平边距，默认 20 点；详情预览可设为 0。 */
@property (nonatomic, assign) CGFloat horizontalContentInset;
/** @brief Stack the primary button above a text secondary action. @chinese 主按钮独占一行，次操作在下方显示为文字；默认关闭。 */
@property (nonatomic, assign) BOOL stacksActions;
/** @brief Allow close and background tap. @chinese 允许关闭和点击背景退出。 */
@property (nonatomic, assign) BOOL allowsDismissal;
/** @brief Primary action. @chinese 主操作。 */
@property (nonatomic, strong, readonly) UIButton *primaryButton;
/** @brief Secondary action. @chinese 次操作。 */
@property (nonatomic, strong, readonly) UIButton *secondaryButton;
/** @brief Primary callback. @chinese 主操作回调。 */
@property (nonatomic, copy, nullable) void (^onPrimary)(void);
/** @brief Secondary callback. @chinese 次操作回调。 */
@property (nonatomic, copy, nullable) void (^onSecondary)(void);
/** @brief Dismiss callback. @chinese 关闭回调。 */
@property (nonatomic, copy, nullable) void (^onDismiss)(void);
/** @brief Present in a view. @chinese 在页面中呈现。 @param view EN: Host. CN: 宿主。 */
- (void)showInView:(UIView *)view;
/** @brief Remove the panel. @chinese 关闭面板。 */
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
