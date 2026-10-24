//
//  TSDialEditorState.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>
#import <TopStepInterfaceKit/TSDialDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Audio selection applied by the Demo while exporting a prepared video
 * @chinese Demo 导出成品视频时使用的音轨选择
 *
 * @discussion
 * [EN]: This is App editing state, not an SDK build option. Automatic preserves
 *       the first source audio track only when the selected requirements allow audio.
 * [CN]: 这是 App 编辑状态，不是 SDK 造包参数。自动模式只在当前成品要求允许音轨时
 *       保留源文件首条音轨；无音轨源文件仍可导出。
 */
typedef NS_ENUM(NSInteger, TSDialEditorVideoAudioSelection) {
    TSDialEditorVideoAudioSelectionAutomatic = 0,
    TSDialEditorVideoAudioSelectionMuted = 1,
    TSDialEditorVideoAudioSelectionPreserveFirstTrack = 2
};

/**
 * @brief Editable session and local persistence for one watch face type.
 * @chinese 一种表盘类型的编辑会话与本地草稿。
 * @discussion EN: Images use name/image/source/crop. Confirmed video records also retain
 * videoCanvasSize/videoCanvasShape/videoCanvasRadius; missing values require crop confirmation.
 * Text items retain text/color/size/speed/position/right/gif.
 * CN: 图片保留名称、成品、原图和归一化裁切区域。视频另保留已确认画布的像素尺寸、形状、圆角，
 * 旧记录缺失时须重新确认；弹幕保留可编辑文字与各项设置，造包时再转换为 SDK 模型。
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
/** @brief Selected build quality; Default preserves the Provider policy. @chinese 造包画质，Default 保持 Provider 默认策略。 */
@property (nonatomic, assign) TSDialQuality quality;
/**
 * @brief Audio selection for the next App export
 * @chinese 下次 App 导出使用的音轨选择
 *
 * @discussion
 * [EN]: Defaults to Automatic. Stored independently of SDK enums. Devices that
 *       do not accept audio always receive a silent prepared video.
 * [CN]: 默认自动，与 SDK 枚举独立保存。不接受音轨的设备始终收到无音轨成品视频。
 */
@property (nonatomic, assign) TSDialEditorVideoAudioSelection videoAudioSelection;
/**
 * @brief Owned local source video
 * @chinese App 持有的源视频
 *
 * @discussion
 * [EN]: Editable source, never an installation export cache. Each installation
 *       exports a separate temporary file; cancelling it must not delete this source.
 * [CN]: 这是可再次编辑的源素材，不是安装用成品缓存；每次安装单独导出临时文件，
 *       取消任务不能删除此源文件。
 */
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
/**
 * @brief Owned local template file, or nil for SDK automatic selection.
 * @chinese App 持有的本地模板文件；nil 表示由 SDK 自动选择。
 * @discussion EN: Imported files are immutable inputs shared by installation snapshots.
 * CN: 导入的文件作为不可变输入，由安装快照共享；保存时使用自有目录的相对文件名。
 * @note EN: A missing file remains selected until explicitly replaced. CN: 文件丢失时保留选择，不自动改用默认模板。
 */
@property (nonatomic, strong, nullable) NSURL *templateFileURL;
/**
 * @brief Original display name of the selected template.
 * @chinese 所选模板的原始显示名称。
 * @discussion EN: Independent of the unique filename used for storage. CN: 与存储时使用的唯一文件名分开保留。
 * @note EN: Nil in automatic mode. CN: 自动模式下为 nil。
 */
@property (nonatomic, copy, nullable) NSString *templateName;
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
/**
 * @brief Import a nonempty regular template file with coordinated access.
 * @chinese 通过文件协调访问导入非空的普通模板文件。
 * @param url EN: Picked local file URL. CN: 选择器返回的本地文件地址。
 * @param error EN: Import failure. CN: 导入失败原因。
 * @return EN: Owned copy, or nil; SDK build validates device compatibility.
 * CN: 自有副本或 nil；设备兼容性由 SDK 造包校验。
 */
+ (nullable NSURL *)importTemplateAtURL:(NSURL *)url error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
