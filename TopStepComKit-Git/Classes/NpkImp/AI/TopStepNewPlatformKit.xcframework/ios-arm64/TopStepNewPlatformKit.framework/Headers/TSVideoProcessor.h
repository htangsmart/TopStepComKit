#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN
/** @brief Parameters for the existing H.264 HEX backend. @chinese 既有 H.264 HEX 后端参数。 */
@interface TSVideoProcessorOptions : NSObject
/**
 * @brief Local source video path
 * @chinese 本地源视频路径
 *
 * @discussion
 * [EN]: Caller-supplied existing file. Required before processing and must differ
 *       from outputPath after path normalization and symbolic-link resolution.
 * [CN]: 调用方提供的现有文件路径；处理前必须赋值，规范化并解析符号链接后
 *       不能与 outputPath 指向同一路径。
 */
@property (nonatomic, copy) NSString *sourcePath;
/**
 * @brief Destination HEX file path
 * @chinese 目标 HEX 文件路径
 *
 * @discussion
 * [EN]: Required task-owned output path. Failed or cancelled processing removes the output at this path.
 * [CN]: 必填且应由当前任务独占；处理失败或取消时会删除此路径的输出文件。
 */
@property (nonatomic, copy) NSString *outputPath;
/**
 * @brief Encoded frame size in pixels
 * @chinese 编码帧尺寸，单位像素
 *
 * @discussion
 * [EN]: Required integer pixel size, from 1 through 65535 on each axis. Every
 *       orientation-corrected source frame must match exactly; no resizing or masking is performed.
 * [CN]: 必填整数像素尺寸，宽高范围为 1...65535；方向校正后的每帧必须严格匹配，
 *       此后端不缩放、裁剪或添加遮罩。
 */
@property (nonatomic, assign) CGSize targetSize;
/**
 * @brief Source-frame extraction rate
 * @chinese 源视频抽帧频率
 *
 * @discussion
 * [EN]: Frames per second; defaults to 20. Must be at least frameRate and no greater than 60.
 * [CN]: 单位为帧/秒，默认 20；不得小于 frameRate，且不得超过 60。
 */
@property (nonatomic, assign) NSInteger captureFrameRate;
/**
 * @brief Encoded playback frame rate
 * @chinese 编码后的播放帧率
 *
 * @discussion
 * [EN]: Defaults to 20 frames per second, valid from 1 through 60. The whole
 *       video is sampled at this rate; its final partial interval occupies one output frame.
 * [CN]: 默认 20 帧/秒，有效范围为 1...60；对完整视频按时间采样，
 *       不足一帧的尾部区间保留一帧，输出时长最多增加不足一帧。
 */
@property (nonatomic, assign) NSInteger frameRate;
/**
 * @brief Native encoder bitrate parameter
 * @chinese 原生编码器码率参数
 *
 * @discussion
 * [EN]: Positive value passed unchanged to XEncoder, defaulting to 1000. Units follow that backend API.
 * [CN]: 须为正数，默认 1000，原样传给 XEncoder；单位遵循该后端 API，不在此层换算。
 */
@property (nonatomic, assign) NSInteger bitrate;
/**
 * @brief Cooperative cancellation check
 * @chinese 协作取消检查
 *
 * @discussion
 * [EN]: Nil disables cancellation checks. YES stops at the next checkpoint; an active native encode finishes before return.
 * [CN]: nil 表示不检查；返回 YES 后在下一检查点停止，已开始的原生编码结束后才返回并清理。
 */
@property (nonatomic, copy, nullable) BOOL (^isCancelled)(void);
@end

/** @brief W30 JPEG-frame to H.264 HEX encoder. @chinese W30 JPEG 帧到 H.264 HEX 编码器。 */
@interface TSVideoProcessor : NSObject
/** @brief Encode a prepared whole video of at most 30 seconds as HEX. @chinese 将不超过 30 秒的完整成品视频编码为 HEX。
 * @param options EN: Parameters. CN: 参数。
 * @param coverImage EN: First orientation-corrected source frame. CN: 方向校正后的首张源视频帧。
 * @param frameCount EN: Actually encoded frame count. CN: 实际编码帧数。
 * @param error EN: Processing error. CN: 处理错误。
 * @return EN: Success after native encoder exit. CN: 原生编码退出后返回结果。 */
+ (BOOL)processWithOptions:(TSVideoProcessorOptions *)options coverImage:(UIImage *_Nullable *_Nullable)coverImage
    frameCount:(NSUInteger *_Nullable)frameCount error:(NSError **)error;
/** @brief Legacy asynchronous HEX entry, retaining bitrate 1000. @chinese 保留码率 1000 的旧异步 HEX 入口。
 * @param videoFilePath EN: MP4 source. CN: MP4 源文件。
 * @param targetSize EN: Output size. CN: 输出尺寸。
 * @param fps EN: Frame rate. CN: 帧率。
 * @param outputPath EN: HEX output. CN: HEX 输出。
 * @param completion EN: Main-thread result. CN: 主线程结果。 */
+ (void)processVideo:(NSString *)videoFilePath targetSize:(CGSize)targetSize fps:(NSInteger)fps
    outputPath:(NSString *)outputPath completion:(void (^)(BOOL success, NSError *_Nullable error))completion;
/**
 * @brief Source-compatible prepared-video adapter for the legacy selector
 * @chinese 保留旧选择子的成品视频兼容入口
 *
 * @param videoFilePath EN: Local MP4 source. CN: 本地 MP4 源文件。
 * @param targetSize EN: Exact orientation-corrected pixel size. CN: 方向校正后须严格匹配的像素尺寸。
 * @param fps EN: Output frames per second, from 1 through 60. CN: 输出帧率，范围 1...60。
 * @param maxDuration EN: Input duration limit in seconds, greater than zero and no more than 30.
 *                    CN: 输入时长上限，单位秒，须大于 0 且不超过 30。
 * @param outputPath EN: Task-owned HEX output path. CN: 当前任务独占的 HEX 输出路径。
 * @param cornerRadius EN: Must be zero; a nonzero value is rejected. CN: 必须为 0，非零值会被拒绝。
 * @param completion EN: Result delivered on the main thread. CN: 在主线程返回处理结果。
 *
 * @discussion
 * [EN]: The whole prepared video is encoded. An overlong source or a requested corner
 *       mask fails explicitly; this adapter never trims, crops, resizes, or masks frames.
 * [CN]: 编码完整成品视频；源视频超长或请求圆角遮罩时明确失败，
 *       此兼容入口不会截取片段、裁剪、缩放或添加遮罩。
 */
+ (void)processVideo:(NSString *)videoFilePath targetSize:(CGSize)targetSize fps:(NSInteger)fps
    maxDuration:(NSTimeInterval)maxDuration outputPath:(NSString *)outputPath cornerRadius:(CGFloat)cornerRadius
    completion:(void (^)(BOOL success, NSError *_Nullable error))completion
    DEPRECATED_MSG_ATTRIBUTE("Provide a prepared whole video and use processVideo:targetSize:fps:outputPath:completion:.");
@end
NS_ASSUME_NONNULL_END
