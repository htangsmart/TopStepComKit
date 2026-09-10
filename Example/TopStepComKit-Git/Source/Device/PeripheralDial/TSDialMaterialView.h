//
//  TSDialMaterialView.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>
@class TSDialEditorState;

NS_ASSUME_NONNULL_BEGIN

/** @brief Type-specific material controls. @chinese 各类型素材编辑控件。 */
@interface TSDialMaterialView : UIView
/** @brief Choose photos, YES appends. @chinese 选择照片，YES 表示追加。 */
@property (nonatomic, copy, nullable) void (^onChoosePhotos)(BOOL append);
/** @brief Crop selected photo. @chinese 裁切当前照片。 */
@property (nonatomic, copy, nullable) void (^onCrop)(void);
/** @brief Select photo. @chinese 选择照片。 */
@property (nonatomic, copy, nullable) void (^onSelectImage)(NSUInteger index);
/** @brief Delete photo. @chinese 删除照片。 */
@property (nonatomic, copy, nullable) void (^onDeleteImage)(NSUInteger index);
/** @brief Move selected photo. @chinese 移动当前照片。 */
@property (nonatomic, copy, nullable) void (^onMoveImage)(NSInteger delta);
/** @brief Slideshow interval. @chinese 轮播间隔。 */
@property (nonatomic, copy, nullable) void (^onIntervalChanged)(NSInteger seconds);
/** @brief Choose video. @chinese 选择视频。 */
@property (nonatomic, copy, nullable) void (^onChooseVideo)(void);
/** @brief Trim values. @chinese 片段区间变化。 */
@property (nonatomic, copy, nullable) void (^onTrimChanged)(NSTimeInterval start, NSTimeInterval end);
/** @brief Needed height. @chinese 所需高度。 */
@property (nonatomic, assign, readonly) CGFloat preferredHeight;
/** @brief Render material settings. @chinese 渲染素材设置。
 * @param state EN: State. CN: 状态。 @param limits EN: maxImages/maxDuration. CN: 数量及时长上限。
 * @param thumbnails EN: Video frames. CN: 视频缩略帧。 */
- (void)configureWithState:(TSDialEditorState *)state limits:(NSDictionary *)limits thumbnails:(NSArray<UIImage *> *)thumbnails;
@end

NS_ASSUME_NONNULL_END
