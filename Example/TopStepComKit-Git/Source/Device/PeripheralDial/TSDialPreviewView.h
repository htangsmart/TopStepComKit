//
//  TSDialPreviewView.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>
@class TSDialEditorState, TSCustomDialStyleConstraint, TSPeripheralScreen;

NS_ASSUME_NONNULL_BEGIN

/** @brief Shared rectangular/round watch preview and playback. @chinese 共用方表、圆表预览与播放。 */
@interface TSDialPreviewView : UIView
/** @brief Enlarged preview request. @chinese 放大预览请求。 */
@property (nonatomic, copy, nullable) void (^onExpandRequested)(void);
/** @brief User playback preference. @chinese 用户播放选择。 */
@property (nonatomic, assign, getter=isPlaying) BOOL playing;
/** @brief Enlarged presentation. @chinese 放大展示模式。 */
@property (nonatomic, assign) BOOL enlarged;
/** @brief Watch scale for an installed preview. @chinese 已安装预览的表壳比例，默认 0.67。 */
@property (nonatomic, assign) CGFloat installedPreviewScale;
/**
 * @brief Display an installed face without adding editor time or animation layers.
 * @chinese 展示已安装表盘成品，不叠加编辑器时间和动画。
 * @param image EN: Cached composite preview; nil displays unavailable state. CN: 缓存成品图，nil 显示暂无预览。
 * @param screen EN: Device geometry, if known. CN: 已知的设备屏幕信息。
 */
- (void)configureWithInstalledImage:(nullable UIImage *)image screen:(nullable TSPeripheralScreen *)screen;
/** @brief Render shared configuration. @chinese 渲染共用配置。
 * @param state EN: Editor state. CN: 编辑状态。 @param screen EN: Device geometry. CN: 设备几何信息。
 * @param constraint EN: Time options. CN: 时间选项。 @param timeImage EN: Selected style image. CN: 选中样式图。 */
- (void)configureWithState:(TSDialEditorState *)state screen:(TSPeripheralScreen *)screen
               constraint:(nullable TSCustomDialStyleConstraint *)constraint timeImage:(nullable UIImage *)timeImage;
/** @brief Pause resources without changing user preference. @chinese 暂停资源但保留播放选择。 */
- (void)suspend;
/** @brief Resume according to user preference. @chinese 按用户选择恢复播放。 */
- (void)resume;
@end

NS_ASSUME_NONNULL_END
