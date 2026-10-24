#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN
/** @brief AVI conversion errors. @chinese AVI 转码错误域。 */
FOUNDATION_EXPORT NSErrorDomain const TSDialAVIErrorDomain;
/** @brief AVI error codes. @chinese AVI 转码错误码。 */
typedef NS_ERROR_ENUM(TSDialAVIErrorDomain, TSDialAVIErrorCode) {
    TSDialAVIErrorInvalidInput = 78001,
    TSDialAVIErrorUnavailable = 78002,
    TSDialAVIErrorConversionFailed = 78003,
    TSDialAVIErrorCancelled = 78004,
};
/** @brief Explicit audio conversion policy. @chinese 显式音轨处理规则。 */
typedef NS_ENUM(NSInteger, TSDialAVIAudioPolicy) {
    TSDialAVIAudioPolicyMuted = 0,
    TSDialAVIAudioPolicyPreserveFirstTrack = 1,
};
/** @brief Source interval and geometry contract. @chinese 输入时间区间与几何处理合同。 */
typedef NS_ENUM(NSInteger, TSDialAVIInputMode) {
    /** @brief Existing selected-range and filter behavior. @chinese 既有选段和滤镜处理行为。 */
    TSDialAVIInputModeSelectedRange = 0,
    /** @brief Encode the complete prepared source without geometry edits. @chinese 编码完整成品源，不编辑几何内容。 */
    TSDialAVIInputModePreparedWholeSource = 1,
};
/** @brief Media-only synchronous conversion request; no device or draft model. @chinese 仅包含媒体参数的同步转码请求，不引用设备或表盘草稿。 */
@interface TSDialAVIRequest : NSObject
/**
 * @brief Source processing contract
 * @chinese 输入处理合同
 *
 * @discussion
 * [EN]: Defaults to SelectedRange, preserving existing callers. PreparedWholeSource
 *       reads through EOF, requires targetSize to match orientation-corrected square-pixel
 *       frames, and rejects clip offsets, durations, geometry edits, custom filters and fps overrides.
 *       Audio policy and MJPEG quality remain device-format encoding parameters.
 * [CN]: 默认 SelectedRange，保持既有调用语义。PreparedWholeSource 读取到文件结束，
 *       要求方向校正后的方形像素帧严格匹配 targetSize，拒绝起点、时长、几何编辑、
 *       自定义滤镜和帧率覆盖；音轨规则与 MJPEG 质量仍属于设备格式编码参数。
 */
@property (nonatomic, assign) TSDialAVIInputMode inputMode;
/**
 * @brief Source video file URL
 * @chinese 源视频文件 URL
 *
 * @discussion
 * [EN]: Required local file URL. The source remains caller-owned and must differ
 *       from both output URLs after path normalization and symlink resolution.
 * [CN]: 必填本地文件 URL，源文件仍由调用方持有；规范化路径并解析符号链接后，
 *       必须与两个输出路径均不同。
 */
@property (nonatomic, copy) NSURL *inputURL;
/**
 * @brief Destination AVI file URL
 * @chinese AVI 输出文件 URL
 *
 * @discussion
 * [EN]: Required local file URL distinct from inputURL and coverURL. Use a dedicated
 *       path: failure or cancellation after validation and backend availability checks
 *       removes requested outputs. Rejected parameters or an unavailable backend do not clean them.
 * [CN]: 必填本地文件 URL，必须与 inputURL、coverURL 不同，并使用本次转码专用路径。
 *       参数校验和后端可用性检查通过后的失败或取消会清理请求输出；
 *       参数拒绝或后端不可用时不执行清理。
 */
@property (nonatomic, copy) NSURL *outputURL;
/**
 * @brief Optional destination for the first-frame JPEG
 * @chinese 可选的首帧 JPEG 输出位置
 *
 * @discussion
 * [EN]: Defaults to nil, disabling cover output. When set, use a separate local file URL.
 *       The generated filter takes the cover before outputRotate is applied to the AVI branch.
 * [CN]: 默认 nil，不生成封面；非空时使用独立本地文件 URL。
 *       自动生成的滤镜会在 AVI 分支应用 outputRotate 之前提取封面。
 */
@property (nonatomic, copy, nullable) NSURL *coverURL;
/**
 * @brief Clip start offset in milliseconds
 * @chinese 截取起点，单位毫秒
 *
 * @discussion
 * [EN]: Defaults to 0. SelectedRange accepts nonnegative offsets together with
 *       durationMillis; PreparedWholeSource requires 0.
 * [CN]: 默认 0；SelectedRange 接受非负值并与 durationMillis 确定片段，
 *       PreparedWholeSource 必须为 0。
 */
@property (nonatomic, assign) int64_t offsetMillis;
/**
 * @brief Requested clip duration in milliseconds
 * @chinese 请求截取的时长，单位毫秒
 *
 * @discussion
 * [EN]: Defaults to 0. SelectedRange requires a positive resolved duration;
 *       PreparedWholeSource requires 0 and determines completion from source EOF.
 * [CN]: 默认 0；SelectedRange 要求已解析出的正数时长，
 *       PreparedWholeSource 必须为 0，并以源文件结束作为完成条件。
 */
@property (nonatomic, assign) int64_t durationMillis;
/**
 * @brief Output dimensions before rotation
 * @chinese 旋转前的输出尺寸
 *
 * @discussion
 * [EN]: Defaults to CGSizeZero. Without a custom filterGraph, each dimension must
 *       be a positive even integer in 2...65535 pixels; a custom graph defines its own geometry.
 *       PreparedWholeSource validates exact oriented source dimensions and never scales to this size.
 * [CN]: 默认 CGSizeZero；未提供自定义 filterGraph 时，宽高必须为 2...65535
 *       范围内的正偶数像素；自定义滤镜图自行确定几何尺寸。
 *       PreparedWholeSource 校验方向校正后的源尺寸严格相等，不进行缩放。
 */
@property (nonatomic, assign) CGSize targetSize;
/**
 * @brief Scaling policy when no explicit crop is supplied
 * @chinese 未指定裁剪区域时的缩放规则
 *
 * @discussion
 * [EN]: Defaults to YES for center-fill cropping. NO stretches the whole frame.
 *       Used by the generated graph only when cropRect is CGRectZero.
 *       Must be NO in PreparedWholeSource.
 * [CN]: 默认 YES，居中裁剪填满；NO 表示整帧拉伸。
 *       仅在自动生成滤镜且 cropRect 为 CGRectZero 时使用。
 *       PreparedWholeSource 必须为 NO。
 */
@property (nonatomic, assign) BOOL aspectFill;
/**
 * @brief Whether to apply a circular mask
 * @chinese 是否应用圆形遮罩
 *
 * @discussion
 * [EN]: Defaults to NO. The generated graph applies a black-edge circle before
 *       output rotation; when YES, it takes precedence over cornerRadius.
 *       Must be NO in PreparedWholeSource.
 * [CN]: 默认 NO；自动生成的滤镜在输出旋转前写入圆形黑边遮罩，
 *       为 YES 时优先于 cornerRadius。
 *       PreparedWholeSource 必须为 NO。
 */
@property (nonatomic, assign) BOOL circle;
/**
 * @brief Rounded rectangle radius in target pixels
 * @chinese 目标像素坐标中的矩形圆角半径
 *
 * @discussion
 * [EN]: Defaults to 0. Must be finite and in 0...65535; the generated rectangular
 *       mask clamps the effective radius to half the shorter target dimension.
 *       Must be 0 in PreparedWholeSource.
 * [CN]: 默认 0，必须是 0...65535 范围内的有限值；
 *       自动生成矩形遮罩时，有效半径限制到目标较短边的一半。
 *       PreparedWholeSource 必须为 0。
 */
@property (nonatomic, assign) CGFloat cornerRadius;
/**
 * @brief Crop rectangle after source orientation correction
 * @chinese 源视频方向修正后的裁剪矩形
 *
 * @discussion
 * [EN]: Defaults to CGRectZero, selecting aspectFill behavior. An explicit rectangle
 *       uses finite integer pixel coordinates, nonnegative origins and positive dimensions;
 *       CGRectNull is not accepted. A custom filterGraph controls its own cropping.
 *       PreparedWholeSource requires CGRectZero.
 * [CN]: 默认 CGRectZero，使用 aspectFill 规则；显式矩形使用有限整数像素，
 *       原点非负、宽高为正，不接受 CGRectNull。自定义 filterGraph 自行控制裁剪。
 *       PreparedWholeSource 必须为 CGRectZero。
 */
@property (nonatomic, assign) CGRect cropRect;
/**
 * @brief Clockwise output rotation in quarter turns
 * @chinese 顺时针输出旋转的四分之一圈次数
 *
 * @discussion
 * [EN]: Defaults to 0 and accepts 0...3. The generated AVI graph applies rotation
 *       after scaling and masking; odd values swap the encoded dimensions.
 *       Must be 0 in PreparedWholeSource; source display-matrix interpretation is retained.
 * [CN]: 默认 0，范围为 0...3；自动生成的 AVI 滤镜在缩放及遮罩后旋转，
 *       奇数值会交换编码宽高。
 *       PreparedWholeSource 必须为 0，仍保留源显示矩阵的正确解释。
 */
@property (nonatomic, assign) NSInteger outputRotate;
/**
 * @brief Requested output frames per second
 * @chinese 请求的输出帧率，单位帧每秒
 *
 * @discussion
 * [EN]: Defaults to 0, using the detected source rate. Positive values must be
 *       in 1...240; the generated graph resamples frames to that rate.
 *       PreparedWholeSource requires 0 and retains the source timing.
 * [CN]: 默认 0，使用检测到的源帧率；正值范围为 1...240，
 *       自动生成的滤镜会将帧重采样至该帧率。
 *       PreparedWholeSource 必须为 0，保留源时间轴。
 */
@property (nonatomic, assign) NSInteger frameRate;
/**
 * @brief MJPEG quantization parameter
 * @chinese MJPEG 量化参数
 *
 * @discussion
 * [EN]: Defaults to 10 and must be in 1...31. This is an encoder quantizer,
 *       not a percentage or the public dial quality enum.
 * [CN]: 默认 10，必须在 1...31 范围内；这是编码器量化参数，
 *       不是百分比，也不是公共表盘质量枚举。
 */
@property (nonatomic, assign) NSInteger jpegQuality;
/**
 * @brief Output audio policy
 * @chinese 输出音轨规则
 *
 * @discussion
 * [EN]: Defaults to Muted. PreserveFirstTrack converts the first audio track to
 *       mono 16 kHz, 16-bit PCM; absence of a source track still permits silent output.
 * [CN]: 默认 Muted；PreserveFirstTrack 将第一音轨转为单声道 16 kHz、16 位 PCM，
 *       源视频没有音轨时仍允许生成无声输出。
 */
@property (nonatomic, assign) TSDialAVIAudioPolicy audioPolicy;
/**
 * @brief Cooperative cancellation probe
 * @chinese 协作取消检查回调
 *
 * @discussion
 * [EN]: Defaults to nil. Called during synchronous conversion and libav interruption
 *       checks; YES requests cancellation. Keep the block fast and do not assume the main thread.
 * [CN]: 默认 nil；在同步转码和 libav 中断检查期间调用，返回 YES 请求取消。
 *       回调应快速返回，不能假定在主线程执行。
 */
@property (nonatomic, copy, nullable) BOOL (^isCancelled)(void);
/**
 * @brief Optional fully resolved libav video filter graph
 * @chinese 可选的已完整解析 libav 视频滤镜图
 *
 * @discussion
 * [EN]: Defaults to nil. A nonempty graph replaces automatic crop, scale, mask and
 *       rotation construction. The adapter must supply the intended geometry and output labels.
 *       PreparedWholeSource rejects nonempty custom graphs.
 * [CN]: 默认 nil；非空图会替代自动裁剪、缩放、遮罩和旋转构造，
 *       适配器须自行提供所需几何处理和输出标签。
 *       PreparedWholeSource 不允许非空自定义滤镜图。
 */
@property (nonatomic, copy, nullable) NSString *filterGraph;
/**
 * @brief Video output label for the filter graph
 * @chinese 滤镜图的视频输出标签
 *
 * @discussion
 * [EN]: Nil resolves to [dial_avi]. A supplied label must include brackets, such as
 *       [vavi], and match the custom graph output; an empty string is invalid.
 * [CN]: nil 使用 [dial_avi]；显式标签必须包含方括号，例如 [vavi]，
 *       并匹配自定义滤镜图输出，空字符串无效。
 */
@property (nonatomic, copy, nullable) NSString *videoOutputLabel;
/**
 * @brief Cover output label for the filter graph
 * @chinese 滤镜图的封面输出标签
 *
 * @discussion
 * [EN]: Nil resolves to [dial_cover]. When coverURL is set, a supplied label must
 *       include brackets and identify the graph's JPEG branch.
 * [CN]: nil 使用 [dial_cover]；设置 coverURL 时，显式标签必须包含方括号，
 *       并指向滤镜图中的 JPEG 分支。
 */
@property (nonatomic, copy, nullable) NSString *coverOutputLabel;
@end

/** @brief Completed file metadata. @chinese 完成文件的实际媒体元数据。 */
@interface TSDialAVIResult : NSObject
/**
 * @brief Completed AVI output URL
 * @chinese 已完成的 AVI 输出 URL
 *
 * @discussion
 * [EN]: Set to the request's outputURL on successful conversion; the caller manages the finished file.
 * [CN]: 转码成功后设置为请求的 outputURL，完成文件由调用方管理。
 */
@property (nonatomic, copy, readonly) NSURL *aviURL;
/**
 * @brief Completed first-frame JPEG URL
 * @chinese 已完成的首帧 JPEG URL
 *
 * @discussion
 * [EN]: Matches the requested coverURL after success; nil when no cover was requested.
 * [CN]: 成功后对应请求的 coverURL；未请求封面时为 nil。
 */
@property (nonatomic, copy, readonly, nullable) NSURL *coverURL;
/**
 * @brief Actual AVI encoded dimensions
 * @chinese AVI 的实际编码尺寸
 *
 * @discussion
 * [EN]: Pixel dimensions obtained from the encoder after filtering and rotation;
 *       they may differ from targetSize and from the cover dimensions.
 * [CN]: 从编码器取得的滤镜和旋转后像素尺寸，可能与 targetSize 及封面尺寸不同。
 */
@property (nonatomic, assign, readonly) CGSize encodedSize;
/**
 * @brief Total frames written to the AVI
 * @chinese 实际写入 AVI 的总帧数
 *
 * @discussion
 * [EN]: Read from the completed file's avih header rather than inferred from the requested duration.
 * [CN]: 从完成文件的 avih 头读取，不根据请求时长推算。
 */
@property (nonatomic, assign, readonly) NSUInteger totalFrames;
/**
 * @brief Duration derived from the completed AVI frame timing
 * @chinese 根据已完成 AVI 帧时序计算的时长
 *
 * @discussion
 * [EN]: Calculated from the actual frame count and per-frame timing, rounded to
 *       milliseconds. It need not equal the requested clip duration exactly.
 * [CN]: 根据实际帧数与每帧时序计算，并四舍五入到毫秒，不保证与请求截取时长完全相等。
 */
@property (nonatomic, assign, readonly) int64_t durationMillis;
/**
 * @brief Whether the output contains a PCM audio stream
 * @chinese 输出是否包含 PCM 音轨
 *
 * @discussion
 * [EN]: Describes the actual muxed stream. A PreserveFirstTrack request can still
 *       produce NO when the source has no audio track.
 * [CN]: 表示实际封装的音轨结果；即使请求 PreserveFirstTrack，
 *       源视频无音轨时仍可能为 NO。
 */
@property (nonatomic, assign, readonly) BOOL hasAudio;
@end

/** @brief Isolated synchronous libav AVI transcoder. @chinese 使用独立 libav 会话的同步 AVI 转码器。 */
@interface TSDialAVITranscoder : NSObject
/** @brief Check linked codecs and filters. @chinese 检查链接的编码器与滤镜。 @return EN: Availability. CN: 是否可用。 */
+ (BOOL)isAvailable;
/** @brief Transcode and clean requested outputs on failure. @chinese 转码，失败时清理本次输出。
 * @param request EN: Media parameters. CN: 媒体参数。
 * @param error EN: Conversion error. CN: 转码错误。
 * @return EN: Completed metadata, or nil. CN: 完成元数据，失败返回 nil。
 */
- (nullable TSDialAVIResult *)transcodeRequest:(TSDialAVIRequest *)request error:(NSError *_Nullable *_Nullable)error;
@end
NS_ASSUME_NONNULL_END
