//
//  TSDialTemplateSelectionView.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Template summary and actions inside installation confirmation.
 * @chinese 安装确认弹窗中的模板摘要与操作入口。
 * @discussion EN: Displays metadata only; the SDK validates template compatibility.
 * CN: 只展示文件元数据，模板兼容性由 SDK 校验。
 */
@interface TSDialTemplateSelectionView : UIView
/**
 * @brief Requests source or full path details.
 * @chinese 请求展示来源或完整路径。
 * @discussion EN: Invoked by the details button. CN: 点击详情按钮时调用。
 * @note EN: Capture the owner weakly. CN: 弱引用持有此视图的对象。
 */
@property (nonatomic, copy, nullable) void (^onDetails)(void);
/**
 * @brief Requests a change of template source.
 * @chinese 请求更换模板来源。
 * @discussion EN: Invoked by the change button. CN: 点击更换按钮时调用。
 * @note EN: Capture the owner weakly. CN: 弱引用持有此视图的对象。
 */
@property (nonatomic, copy, nullable) void (^onChange)(void);
/**
 * @brief Update file metadata and importing state.
 * @chinese 更新文件元数据与导入状态。
 * @param fileURL EN: Owned file URL, or nil for automatic. CN: 自有文件地址，自动模式为 nil。
 * @param name EN: Original filename. CN: 原始文件名。
 * @param importing EN: Whether file import is in progress. CN: 是否正在导入文件。
 */
- (void)configureWithFileURL:(nullable NSURL *)fileURL name:(nullable NSString *)name importing:(BOOL)importing;
/**
 * @brief Required height for the summary and its actions.
 * @chinese 摘要和操作按钮所需的高度。
 * @return EN: Height in points. CN: 点数高度。
 */
- (CGFloat)preferredHeight;
@end

NS_ASSUME_NONNULL_END
