//
//  TSFitDialVideoConverter.h
//  TopStepFitKit
//
//  Android compatibility baseline: 3410b96937b91cc88527d29402a1de6c709ce17f.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Video algorithm error domain. @chinese 视频算法错误域。 */
FOUNDATION_EXPORT NSErrorDomain const TSFitDialVideoErrorDomain;

/** @brief Video preparation errors. @chinese 视频准备错误。 */
typedef NS_ENUM(NSInteger, TSFitDialVideoErrorCode) {
    TSFitDialVideoErrorInvalidInput = 8701,
    TSFitDialVideoErrorFileOperation = 8702,
    TSFitDialVideoErrorExecution = 8703,
    TSFitDialVideoErrorMissingOutput = 8704,
    TSFitDialVideoErrorSizeLimit = 8705,
};

/**
 * @brief Injectable synchronous FFmpeg argument executor.
 * @chinese 可注入的同步 FFmpeg 参数执行器，FitKit/Video 提供 libav 实现。
 * @discussion Arguments exclude the executable name and must be passed directly to FFmpeg, without shell parsing.
 * 参数不含可执行文件名称，必须直接传给 FFmpeg，不得经过 shell 解析。执行完成后才能返回。
 */
@protocol TSFitDialVideoExecuting <NSObject>
/**
 * @brief Execute FFmpeg arguments synchronously. @chinese 同步执行 FFmpeg 参数。
 * @param arguments EN: Individual arguments, including unquoted paths. CN: 独立参数，路径不加外层引号。
 * @param error EN: Optional execution failure. CN: 可选执行错误。
 * @return EN: YES after successful completion. CN: 成功完成后返回 YES。
 */
- (BOOL)executeArguments:(NSArray<NSString *> *)arguments error:(NSError *_Nullable *_Nullable)error;
@end

/**
 * @brief Independent local video inputs and device geometry.
 * @chinese 独立的本地视频输入与设备几何参数。
 * @discussion The converter snapshots these inputs. One working directory must belong to exactly one task.
 * 转换器会复制参数快照；每个工作目录必须由单个任务独占。调用方负责清理任务目录。
 */
@interface TSFitDialVideoRequest : NSObject <NSCopying>
/** @brief Local source MP4 URL. @chinese 本地源 MP4 地址。 */
@property (nonatomic, strong, nullable) NSURL *inputURL;
/** @brief Exclusive local file URL directory for 0.avi and cover.jpg. @chinese 必须为本地 file URL 的独占任务目录，输出 0.avi 与 cover.jpg。 */
@property (nonatomic, strong, nullable) NSURL *workingDirectoryURL;
/** @brief Logical device width in pixels. @chinese 设备逻辑宽度，单位为像素。 */
@property (nonatomic, assign) NSInteger shapeWidth;
/** @brief Logical device height in pixels. @chinese 设备逻辑高度，单位为像素。 */
@property (nonatomic, assign) NSInteger shapeHeight;
/** @brief Device corner radius, retained without proportional rescaling. @chinese 设备圆角半径，不随编码尺寸等比缩小。 */
@property (nonatomic, assign) NSInteger cornerRadius;
/** @brief Circular mask; overrides cornerRadius. @chinese 使用圆形遮罩，此时忽略圆角半径。 */
@property (nonatomic, assign, getter=isCircle) BOOL circle;
/** @brief Extra clockwise device rotation: 0, 1, 2, 3. @chinese 设备额外顺时针旋转：0、1、2、3。 */
@property (nonatomic, assign) NSInteger outputRotate;
/** @brief Integer crop in source autorotated coordinates; CGRectNull means none. @chinese 源视频自动旋转后的整数裁剪区域；CGRectNull 表示不裁剪。 */
@property (nonatomic, assign) CGRect videoCropRect;
/** @brief Start offset in milliseconds; values below zero become zero. @chinese 起始偏移毫秒数，负数按零处理。 */
@property (nonatomic, assign) int64_t offsetMillis;
/** @brief Requested duration; nonpositive uses maximumDurationMillis. @chinese 期望时长，非正数使用最大时长。 */
@property (nonatomic, assign) int64_t durationMillis;
/** @brief Device maximum duration in milliseconds; default 5000. @chinese 设备最大时长毫秒数，默认 5000。 */
@property (nonatomic, assign) int64_t maximumDurationMillis;
@end

/**
 * @brief Completed conversion and the actual compression parameters.
 * @chinese 完成转换的产物与实际压缩参数。
 * @discussion The JPEG keeps logical orientation. Only AVI pixels receive outputRotate.
 * JPEG 保持逻辑朝向，只有 AVI 像素应用设备额外旋转。时长为实际使用的裁切参数，不代表探测后的媒体时长。
 */
@interface TSFitDialVideoResult : NSObject
/** @brief Encoded MJPEG AVI location. @chinese 编码后 MJPEG AVI 地址。 */
@property (nonatomic, strong, readonly) NSURL *aviURL;
/** @brief Initial logical-orientation cover JPEG. @chinese 初次编码生成的逻辑朝向封面 JPEG。 */
@property (nonatomic, strong, readonly) NSURL *coverURL;
/** @brief Logical encoding width. @chinese 逻辑编码宽度。 */
@property (nonatomic, assign, readonly) NSInteger encodeWidth;
/** @brief Logical encoding height. @chinese 逻辑编码高度。 */
@property (nonatomic, assign, readonly) NSInteger encodeHeight;
/** @brief Rotated AVI pixel width for the image index. @chinese 旋转后的 AVI 像素宽度，用于资源索引。 */
@property (nonatomic, assign, readonly) NSInteger packedWidth;
/** @brief Rotated AVI pixel height for the image index. @chinese 旋转后的 AVI 像素高度，用于资源索引。 */
@property (nonatomic, assign, readonly) NSInteger packedHeight;
/** @brief Effective start offset in milliseconds. @chinese 实际起始偏移毫秒数。 */
@property (nonatomic, assign, readonly) int64_t offsetMillis;
/** @brief Effective requested clip duration in milliseconds. @chinese 实际采用的裁切时长毫秒数。 */
@property (nonatomic, assign, readonly) int64_t durationMillis;
/** @brief FFmpeg q:v value: larger means lower quality. @chinese FFmpeg q:v 数值，越大质量越低。 */
@property (nonatomic, assign, readonly) NSInteger jpegQuality;
/** @brief Encoded AVI file length before binary alignment. @chinese AVI 文件字节数，不含表盘二进制对齐填充。 */
@property (nonatomic, assign, readonly) uint64_t byteCount;
/** @brief Creation is limited to the converter. @chinese 仅允许转换器创建结果。 */
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * @brief Android-compatible MJPEG AVI command construction and size reduction.
 * @chinese 与 Android 一致的 MJPEG AVI 参数构造与限容降级算法。
 * @discussion Call synchronously on a worker queue. The optional FitKit/Video component supplies a libav executor.
 * 在工作队列同步调用；可选 FitKit/Video 组件提供 libav 执行器，不执行 shell。
 * 并发任务必须使用独立目录及支持并发的执行器。
 */
@interface TSFitDialVideoConverter : NSObject
/**
 * @brief Initialize with a host FFmpeg executor. @chinese 注入宿主 FFmpeg 执行器。
 * @param executor EN: Synchronous execution backend. CN: 同步执行后端。
 * @return EN: Configured converter. CN: 配置完成的转换器。
 */
- (instancetype)initWithExecutor:(id<TSFitDialVideoExecuting>)executor NS_DESIGNATED_INITIALIZER;
/** @brief Use initWithExecutor:. @chinese 请使用 initWithExecutor:。 */
- (instancetype)init NS_UNAVAILABLE;
/**
 * @brief Compute integer dimensions with Android's area/side/minimum rules.
 * @chinese 按 Android 面积、边长与最小边规则计算整数尺寸，不额外进行偶数取整。
 * @param shapeSize EN: Positive integer device dimensions. CN: 正整数设备尺寸。
 * @param error EN: Optional invalid-input error. CN: 可选参数错误。
 * @return EN: Logical encode size, or CGSizeZero on error. CN: 逻辑编码尺寸，错误时为 CGSizeZero。
 */
+ (CGSize)encodeSizeForShapeSize:(CGSize)shapeSize error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Return the rotated AVI dimensions. @chinese 获取额外旋转后的 AVI 尺寸。
 * @param encodeSize EN: Logical encoding size. CN: 逻辑编码尺寸。
 * @param outputRotate EN: Rotation value from 0 through 3. CN: 0 到 3 的旋转值。
 * @return EN: Width and height swap for 1 and 3. CN: 旋转值为 1 和 3 时交换宽高。
 */
+ (CGSize)packedSizeForEncodeSize:(CGSize)encodeSize outputRotate:(NSInteger)outputRotate;
/**
 * @brief Produce initial q:v=5 AVI plus a logical-orientation first-frame JPEG.
 * @chinese 生成初始 q:v=5 AVI 与逻辑朝向的首帧 JPEG。
 * @param request EN: Local input and independent output directory. CN: 本地输入与独立输出目录。
 * @param error EN: Optional preparation/conversion failure. CN: 可选准备或转换错误。
 * @return EN: Output metadata or nil. CN: 产物信息，失败为 nil。
 */
- (nullable TSFitDialVideoResult *)startVideoWithRequest:(TSFitDialVideoRequest *)request
                                                 error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Fit AVI bytes into the budget after preview and fixed package overhead.
 * @chinese 在预览及包固定开销已扣除的预算内重新压缩 AVI。
 * @discussion Starts retries at q:v=5, then 6...15, scale 0.85, duration 0.8 down to 1000ms.
 * 重试从 q:v=5 开始，依次 6...15、尺寸乘 0.85、时长乘 0.8（最少 1000ms）；不重置质量，不重建封面。
 * @param result EN: Original startVideoWithRequest: output. CN: startVideoWithRequest: 的原始产物。
 * @param maxBytes EN: AVI-only positive byte budget, before four-byte alignment. CN: 正数 AVI 字节预算，不预扣四字节对齐。
 * @param error EN: Optional execution or exhausted-budget error. CN: 可选执行错误或限容失败。
 * @return EN: Original or recompressed metadata; nil on failure. CN: 原产物或重压缩信息，失败为 nil。
 */
- (nullable TSFitDialVideoResult *)fitVideoResult:(TSFitDialVideoResult *)result
                                       maxBytes:(uint64_t)maxBytes
                                          error:(NSError *_Nullable *_Nullable)error;
@end

NS_ASSUME_NONNULL_END
