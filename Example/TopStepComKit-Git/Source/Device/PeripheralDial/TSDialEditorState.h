//
//  TSDialEditorState.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>
#import <TopStepInterfaceKit/TSDialDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Editable session and local persistence for one watch face type.
 * @chinese 一种表盘类型的编辑会话与本地草稿。
 * @discussion EN: Images use name/image/source/crop; text items retain text/color/size/speed/position/right/gif.
 * CN: 图片保留名称、成品、原图和归一化裁切区域；弹幕保留可编辑文字与各项设置，造包时再转换为 SDK 模型。
 */
@interface TSDialEditorState : NSObject <NSCopying>
/** @brief Immutable session type. @chinese 会话表盘类型。 */
@property (nonatomic, assign, readonly) TSDialDraftType draftType;
/** @brief Image records. @chinese 图片记录。 */
@property (nonatomic, copy) NSArray<NSDictionary *> *images;
/** @brief DanMu records. @chinese 弹幕记录。 */
@property (nonatomic, copy) NSArray<NSDictionary *> *textItems;
/** @brief Selected material. @chinese 当前选择素材。 */
@property (nonatomic, assign) NSUInteger selectedImage;
/** @brief Selected DanMu item. @chinese 当前选择弹幕。 */
@property (nonatomic, assign) NSUInteger selectedText;
/** @brief Shared time style identifier. @chinese 共用时间样式标识。 */
@property (nonatomic, assign) TSDialTimeStyle timeStyle;
/** @brief Shared time position. @chinese 共用时间位置。 */
@property (nonatomic, assign) TSDialTimePosition timePosition;
/** @brief Opaque HEX color. @chinese 不透明 HEX 颜色。 */
@property (nonatomic, copy) NSString *timeColor;
/** @brief Custom color selection. @chinese 自定义颜色选中状态。 */
@property (nonatomic, assign) BOOL customTimeColor;
/** @brief Time visibility. @chinese 时间可见状态。 */
@property (nonatomic, assign) BOOL showsTime;
/** @brief Slideshow interval in seconds. @chinese 轮播间隔秒数。 */
@property (nonatomic, assign) NSInteger interval;
/** @brief Owned local source video. @chinese App 持有的源视频。 */
@property (nonatomic, strong, nullable) NSURL *videoURL;
/** @brief Video name. @chinese 视频名称。 */
@property (nonatomic, copy) NSString *videoName;
/** @brief Full source duration. @chinese 原片时长。 */
@property (nonatomic, assign) NSTimeInterval videoDuration;
/** @brief Selected clip start. @chinese 片段开始秒数。 */
@property (nonatomic, assign) NSTimeInterval videoStart;
/** @brief Selected clip end. @chinese 片段结束秒数。 */
@property (nonatomic, assign) NSTimeInterval videoEnd;
/** @brief Compatible device pixel size. @chinese 素材所适配的设备像素尺寸。 */
@property (nonatomic, assign) CGSize screenSize;
/** @brief Create or restore a session. @chinese 创建或恢复草稿。 @param type EN: Type. CN: 类型。 @return EN: Session. CN: 会话。 */
+ (instancetype)stateForType:(TSDialDraftType)type;
/**
 * @brief List types with a saved local draft without creating default sessions.
 * @chinese 列出已保存的本地草稿类型，不创建默认会话。
 * @return EN: Saved draft type numbers. CN: 已保存的草稿类型编号。
 */
+ (NSArray<NSNumber *> *)savedDraftTypes;
/**
 * @brief Read a small background thumbnail from a saved draft on a worker queue.
 * @chinese 在工作队列读取已保存草稿的背景缩略图。
 * @param type EN: Saved draft type. CN: 已保存的草稿类型。
 * @return EN: Background thumbnail, or nil. CN: 背景缩略图，无图时为 nil。
 */
+ (nullable UIImage *)savedThumbnailForType:(TSDialDraftType)type;
/** @brief Create default DanMu. @chinese 创建默认弹幕。 @return EN: Record. CN: 记录。 */
+ (NSDictionary *)defaultText;
/** @brief Available background resources. @chinese 内置背景资源。 @return EN: Image records. CN: 图片记录。 */
+ (NSArray<NSDictionary *> *)backgrounds;
/** @brief Save atomically. @chinese 原子保存草稿。 @param error EN: Failure. CN: 失败原因。 @return EN: Saved. CN: 是否成功。 */
- (BOOL)saveWithError:(NSError **)error;
/** @brief Copy a picked file before its URL expires. @chinese 在选择器 URL 失效前复制文件。
 * @param url EN: Source URL. CN: 原地址。 @param error EN: Failure. CN: 失败原因。 @return EN: Owned URL. CN: 自有文件地址。 */
+ (nullable NSURL *)importFile:(NSURL *)url error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
