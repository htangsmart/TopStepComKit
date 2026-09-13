#import <Foundation/Foundation.h>

@class UIImage;
@class TSFitDialShapeOptions;
@class TSFitDialDanMuPackItem;

NS_ASSUME_NONNULL_BEGIN

/** @brief DanMu resource preparation errors. @chinese 弹幕资源准备错误域。 */
FOUNDATION_EXPORT NSErrorDomain const TSFitDialDanMuErrorDomain;
/** @brief DanMu preparation failure codes. @chinese 弹幕准备错误码。 */
typedef NS_ERROR_ENUM(TSFitDialDanMuErrorDomain, TSFitDialDanMuErrorCode) {
    TSFitDialDanMuErrorInvalidParameter = 77001,
    TSFitDialDanMuErrorAllocationFailed = 77002,
};

/** @brief In-memory source for one Android-style DanMu item. @chinese 一条 Android 弹幕的内存资源输入。 */
@interface TSFitDialDanMuSource : NSObject
/** @brief Required decoded static image. @chinese 必需的已解码静态图。 */
@property (nonatomic, strong, nullable) UIImage *image;
/** @brief Android encoded X; defaults to start edge. @chinese Android 编码横坐标，默认起始边缘。 */
@property (nonatomic, assign) int32_t imageX;
/** @brief Android encoded Y; defaults to center. @chinese Android 编码纵坐标，默认居中。 */
@property (nonatomic, assign) int32_t imageY;
/** @brief Scroll speed; defaults to 60 pixels/second. @chinese 滚动速度，默认每秒 60 像素。 */
@property (nonatomic, assign) float walkSpeed;
/** @brief Left-to-right flag; defaults to NO. @chinese 是否从左向右，默认 NO。 */
@property (nonatomic, assign) BOOL leftToRight;
/** @brief Optional complete local GIF bytes. @chinese 可选的完整本地 GIF 字节。 */
@property (nonatomic, copy, nullable) NSData *animationData;
/** @brief Android encoded animation X; defaults to center. @chinese Android 编码动画横坐标，默认居中。 */
@property (nonatomic, assign) int32_t animationX;
/** @brief Android encoded animation Y; defaults to center. @chinese Android 编码动画纵坐标，默认居中。 */
@property (nonatomic, assign) int32_t animationY;
@end

/** @brief Prepared background, static preview and ordered packing inputs. @chinese 准备完成的背景、静态预览及有序打包输入。 */
@interface TSFitDialPreparedDanMu : NSObject
/** @brief Opaque shaped background; transparent image pixels composite over black. @chinese 不透明且已处理形状的背景，图片透明像素合成到黑色。 */
@property (nonatomic, strong, readonly) UIImage *backgroundImage;
/** @brief Background plus static images only, at their resolved X/Y positions. @chinese 仅叠加静态图片的预览，使用解析后的横纵坐标。 */
@property (nonatomic, strong, readonly) UIImage *previewImage;
/** @brief Ordered items; each animation frame occupies the full transparent screen. @chinese 有序弹幕，每个关联帧占据完整透明屏幕。 */
@property (nonatomic, copy, readonly) NSArray<TSFitDialDanMuPackItem *> *items;
@end

/** @brief Synchronous DanMu layout and GIF preparation independent of existing Dial models. @chinese 独立于现有 Dial 模型的同步弹幕布局和 GIF 准备算法。 */
@interface TSFitDialDanMuRenderer : NSObject
/**
 * @brief Prepare static positions, GIF disposal frames and full-screen placement in input order.
 * @chinese 按输入顺序准备静态位置、GIF disposal 帧及全屏放置；在工作队列调用，调用期间不得修改输入。
 * @param sources EN: Nonempty decoded local source list. CN: 非空的本地已解码资源列表。
 * @param backgroundColor EN: Packed AARRGGBB; alpha is ignored. CN: AARRGGBB 颜色，忽略透明度。
 * @param shape EN: Device geometry including physical corner radius. CN: 含实际圆角半径的设备形状。
 * @param error EN: Optional decode/layout failure. CN: 可选解码或布局错误。
 * @return EN: Ready-to-pack resources; nil on failure. CN: 待打包资源，失败返回 nil。
 */
+ (nullable TSFitDialPreparedDanMu *)prepareSources:(NSArray<TSFitDialDanMuSource *> *)sources
                                   backgroundColor:(uint32_t)backgroundColor
                                             shape:(TSFitDialShapeOptions *)shape
                                             error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Prepare DanMu over a caller-supplied image using the same layout and GIF rules.
 * @chinese 使用调用方背景图片准备弹幕，复用相同的布局和 GIF 规则；图片背景为 iOS 输入扩展。
 * @param sources EN: Nonempty decoded source list. CN: 非空的已解码资源列表。
 * @param backgroundImage EN: Logical background before screen shaping. CN: 屏幕形状处理前的逻辑背景。
 * @param shape EN: Device screen geometry. CN: 设备屏幕形状。
 * @param error EN: Optional decode or layout failure. CN: 可选解码或布局错误。
 * @return EN: Complete ordered resources, or nil. CN: 完整有序资源，失败返回 nil。
 */
+ (nullable TSFitDialPreparedDanMu *)prepareSources:(NSArray<TSFitDialDanMuSource *> *)sources
                                   backgroundImage:(UIImage *)backgroundImage
                                             shape:(TSFitDialShapeOptions *)shape
                                             error:(NSError *_Nullable *_Nullable)error;
@end

NS_ASSUME_NONNULL_END
