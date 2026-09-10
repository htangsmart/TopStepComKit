//
//  TSDialTimePositionView.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>
@class TSDialEditorState, TSCustomDialStyleConstraint;

NS_ASSUME_NONNULL_BEGIN

/** @brief Shared device-constrained position selector. @chinese 共用设备约束位置选择器。 */
@interface TSDialTimePositionView : UIView
/** @brief Position selection event. @chinese 位置选择事件。 */
@property (nonatomic, copy, nullable) void (^onPositionSelected)(NSInteger position);
/** @brief Height for all supported options. @chinese 全部可用选项所需高度。 */
@property (nonatomic, assign, readonly) CGFloat preferredHeight;
/** @brief Render supported options. @chinese 渲染可用位置。
 * @param state EN: Current values. CN: 当前值。 @param constraint EN: Device options. CN: 设备选项。 */
- (void)configureWithState:(TSDialEditorState *)state constraint:(nullable TSCustomDialStyleConstraint *)constraint;
@end

NS_ASSUME_NONNULL_END
