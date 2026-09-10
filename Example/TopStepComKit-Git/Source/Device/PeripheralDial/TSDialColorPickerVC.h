//
//  TSDialColorPickerVC.h
//  TopStepComKit_Example
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/** @brief Shared color picker with explicit commit/cancel. @chinese 共用颜色选择器，明确确认与取消。 */
@interface TSDialColorPickerVC : TSBaseVC
/** @brief Confirmed color callback. @chinese 确认后颜色回调。 */
@property (nonatomic, copy, nullable) void (^onConfirm)(UIColor *color);
/** @brief Create a picker. @chinese 创建选色器。
 * @param color EN: Original color. CN: 原颜色。 @param subtitle EN: Editing target. CN: 编辑对象。
 * @return EN: Picker. CN: 选择器。 */
- (instancetype)initWithColor:(UIColor *)color subtitle:(NSString *)subtitle;
@end

NS_ASSUME_NONNULL_END
