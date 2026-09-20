#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class UIImage;
@class TSFitDialHeader;
@class TSFitDialBin;

NS_ASSUME_NONNULL_BEGIN

/** @brief Resource packing error domain. @chinese 资源编排错误域。 */
FOUNDATION_EXPORT NSErrorDomain const TSFitDialPackErrorDomain;
/** @brief Resource packing errors. @chinese 资源编排错误码。 */
typedef NS_ERROR_ENUM(TSFitDialPackErrorDomain, TSFitDialPackErrorCode) {
    TSFitDialPackErrorInvalidParameter = 76001,
    TSFitDialPackErrorCapacityExceeded = 76002,
};

/** @brief Prepared scrolling text image and its optional full-screen frames. @chinese 准备好的滚动弹幕图片及可选全屏关联帧。 */
@interface TSFitDialDanMuPackItem : NSObject
/** @brief Static image at its original pixel dimensions. @chinese 保持原始像素尺寸的静态图片。 */
@property (nonatomic, strong, nullable) UIImage *image;
/** @brief Resolved top position; encoded within 0...65535. @chinese 解析后的顶部坐标，编码时限制为 0～65535。 */
@property (nonatomic, assign) NSInteger top;
/** @brief Scroll speed in float pixels per second. @chinese 单精度像素每秒滚动速度。 */
@property (nonatomic, assign) float walkSpeed;
/** @brief YES scrolls left to right. @chinese YES 表示从左向右。 */
@property (nonatomic, assign) BOOL leftToRight;
/** @brief Frames already placed on transparent full-screen canvases; only counts 3...255 are retained. @chinese 已放入透明全屏画布的帧，仅保留帧数为 3～255 的动画。 */
@property (nonatomic, copy) NSArray<UIImage *> *animationFrames;
@end

/**
 * @brief Incremental Android-compatible resource packer for 568X and 579X.
 * @chinese 面向 568X 和 579X、与 Android 一致的增量资源打包器。
 * @discussion Synchronous and confined to one worker queue. Shape inputs before adding; add the preview first.
 * 同步执行，同一实例仅在同一工作队列使用。先完成形状处理，再添加资源；预览应第一个添加。
 * A failed add leaves the existing resource graph unchanged. This class does not access device state or existing Dial models.
 * 添加失败不会改变已有资源图。本类不读取设备状态，也不依赖现有 Dial 模型。
 */
@interface TSFitDialPack : NSObject
/**
 * @brief Initialize with a copied, validated header for a generated dial.
 * @chinese 复制并校验自动生成表盘的头部参数。
 * @param header EN: Resolved header; corner must be zero because shaping is baked into pixels. CN: 已解析的头部，形状已写入像素，因此 corner 必须为零。
 * @param error EN: Optional validation failure. CN: 可选校验错误。
 * @return EN: Independent packer, or nil. CN: 独立打包器，失败返回 nil。
 */
- (nullable instancetype)initWithHeader:(TSFitDialHeader *)header error:(NSError *_Nullable *_Nullable)error NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
/**
 * @brief Add an opaque preview as ICON/PREVIEW.
 * @chinese 按 ICON/PREVIEW 添加不透明预览。
 * @param image EN: Full preview with optional style overlay. CN: 可包含样式叠加的完整预览。
 * @param size EN: Integer logical target pixels, normally screen width/height times 2/3. CN: 整数逻辑目标像素，通常为屏幕宽高的 2/3。
 * @param error EN: Optional encoding error. CN: 可选编码错误。
 * @return EN: Whether the resource and control were added. CN: 是否成功添加资源和控件。
 */
- (BOOL)addPreviewImage:(UIImage *)image size:(CGSize)size error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Add a shaped opaque background as IMAGE/DEFAULT.
 * @chinese 按 IMAGE/DEFAULT 添加已处理形状的不透明背景。
 * @param image EN: Shaped background at logical screen size. CN: 屏幕逻辑尺寸且已处理形状的背景。
 * @param error EN: Optional encoding error. CN: 可选编码错误。
 * @return EN: Whether insertion succeeded. CN: 是否添加成功。
 */
- (BOOL)addBackgroundImage:(UIImage *)image error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Add up to ten contiguous opaque frames and one GIF/MULTI_FRAME control.
 * @chinese 添加最多十个连续不透明帧及一个 GIF/MULTI_FRAME 控件。
 * @param images EN: Shaped backgrounds; empty input is a successful no-op. CN: 已处理形状的背景，空数组成功且不添加内容。
 * @param milliseconds EN: Signed 32-bit interval; nonpositive writes 20. CN: 32 位有符号间隔，非正数写入 20。
 * @param error EN: Optional encoding error. CN: 可选编码错误。
 * @return EN: Whether insertion succeeded. CN: 是否添加成功。
 */
- (BOOL)addBackgroundImages:(NSArray<UIImage *> *)images
       intervalMilliseconds:(int32_t)milliseconds
                      error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Add already encoded AVI bytes as compression 8 and GIF/AVI_VIDEO.
 * @chinese 按压缩类型 8 和 GIF/AVI_VIDEO 添加已编码 AVI 字节。
 * @param data EN: Nonempty MJPEG AVI bytes; media encoding is performed separately. CN: 非空 MJPEG AVI 字节，媒体编码独立完成。
 * @param size EN: Encoded pixel dimensions after device rotation; no further rotation is applied. CN: 已应用设备旋转后的编码像素尺寸，不再旋转。
 * @param error EN: Optional argument error. CN: 可选参数错误。
 * @return EN: Whether insertion succeeded. CN: 是否添加成功。
 */
- (BOOL)addVideoData:(NSData *)data size:(CGSize)size error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Add a transparent static image immediately followed by valid related frames.
 * @chinese 添加透明静态图并紧接有效关联帧，生成 GIF/DANMU 控件。
 * @param item EN: Prepared static image, vertical position and animation. CN: 准备好的静态图、纵坐标与动画。
 * @param error EN: Optional encoding error. CN: 可选编码错误。
 * @return EN: Whether all resources were inserted atomically. CN: 是否整体添加成功。
 */
- (BOOL)addDanMuItem:(TSFitDialDanMuPackItem *)item error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Compute 1024 + 0x9D20 + 4 + each aligned image payload size.
 * @chinese 计算 1024 + 0x9D20 + 4 加各图片四字节对齐后的载荷大小。
 * @return EN: Estimated complete OTA length. CN: 完整 OTA 估算长度。
 */
- (uint64_t)estimatedOTASize;
/**
 * @brief Return an independent TBUI/OTA snapshot with no generated font records.
 * @chinese 返回独立的 TBUI/OTA 快照，不生成字体记录。
 * @return EN: Serializable graph snapshot. CN: 可序列化资源图快照。
 */
- (TSFitDialBin *)result;
@end

NS_ASSUME_NONNULL_END
