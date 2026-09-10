//
//  TSDialDanMuView.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>
@class TSDialEditorState;

NS_ASSUME_NONNULL_BEGIN

/** @brief Editable DanMu text controls. @chinese 弹幕内容编辑控件。 */
@interface TSDialDanMuView : UIView
/** @brief Select one line. @chinese 选择一条弹幕。 */
@property (nonatomic, copy, nullable) void (^onSelectText)(NSUInteger index);
/** @brief Add a line. @chinese 添加一条弹幕。 */
@property (nonatomic, copy, nullable) void (^onAddText)(void);
/** @brief Remove the selected line. @chinese 删除当前弹幕。 */
@property (nonatomic, copy, nullable) void (^onRemoveText)(void);
/** @brief Change a field. @chinese 修改字段。 */
@property (nonatomic, copy, nullable) void (^onValueChanged)(NSString *key, id value);
/** @brief Open text color picker. @chinese 打开文字选色器。 */
@property (nonatomic, copy, nullable) void (^onChooseColor)(void);
/** @brief Choose GIF. @chinese 选择 GIF。 */
@property (nonatomic, copy, nullable) void (^onChooseGIF)(void);
/** @brief Remove GIF. @chinese 移除 GIF。 */
@property (nonatomic, copy, nullable) void (^onRemoveGIF)(void);
/** @brief Render the selected line. @chinese 渲染选中弹幕。 @param state EN: State. CN: 状态。 */
- (void)configureWithState:(TSDialEditorState *)state;
@end

NS_ASSUME_NONNULL_END
