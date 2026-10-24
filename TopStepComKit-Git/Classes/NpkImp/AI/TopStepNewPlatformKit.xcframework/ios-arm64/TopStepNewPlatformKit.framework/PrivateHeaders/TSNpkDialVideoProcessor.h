#import <UIKit/UIKit.h>
@class TSDialDraft, TSNpkDialDeviceProfile;
NS_ASSUME_NONNULL_BEGIN
/** @brief Actual encoded media and matching first frame. @chinese 实际编码媒体和匹配首帧。 */
@interface TSNpkDialVideoResult : NSObject
/**
 * @brief Completed video file path
 * @chinese 已完成的视频文件路径
 *
 * @discussion
 * [EN]: Task-directory output: 0.hex for W30, 0.avi for 579X; LVGL 579X AVI includes LGEX metadata.
 * [CN]: 位于任务目录；W30 为 0.hex，579X 为 0.avi，其中 LVGL 579X 的 AVI 带 LGEX 元数据。
 */
@property (nonatomic, copy, readonly) NSString *filePath;
/**
 * @brief First-frame cover of the prepared video
 * @chinese 成品视频首帧封面
 *
 * @discussion
 * [EN]: Non-nil on success, at encoded frame size without a time-style overlay.
 *       Screen and preview adaptation belongs to the preview renderer.
 * [CN]: 成功时非空，保持编码帧尺寸且未叠加时间样式；屏幕及预览适配由预览渲染器负责。
 */
@property (nonatomic, strong, readonly) UIImage *coverImage;
/**
 * @brief Actual encoded frame size
 * @chinese 实际编码帧尺寸
 *
 * @discussion
 * [EN]: Must equal the prepared input requirements and cover dimensions; may differ from screen size.
 * [CN]: 须与成品输入规格及封面尺寸一致，可能与屏幕尺寸不同。
 */
@property (nonatomic, assign, readonly) CGSize encodedSize;
/**
 * @brief Number of encoded video frames
 * @chinese 实际编码的视频帧数
 *
 * @discussion
 * [EN]: Returned by the HEX backend or AVI transcoder after successful encoding; does not count audio chunks.
 * [CN]: 编码成功后由 HEX 后端或 AVI 转码器返回，不包含音频块数量。
 */
@property (nonatomic, assign, readonly) NSUInteger frameCount;
/**
 * @brief Encoded video duration in milliseconds
 * @chinese 编码视频时长，单位毫秒
 *
 * @discussion
 * [EN]: W30 derives it from encoded frame count and output frame rate; 579X uses the AVI transcoder result.
 * [CN]: W30 按输出帧数和输出帧率计算；579X 使用 AVI 转码结果。设备帧时间量化可能产生舍入差异。
 */
@property (nonatomic, assign, readonly) NSInteger durationMillis;
@end
/** @brief Three NPK video contracts over shared encoders. @chinese 基于共享编码器的 NPK 三类视频合同。 */
@interface TSNpkDialVideoProcessor : NSObject
/** @brief Validate and encode a complete prepared video on a worker queue.
 * @chinese 在工作线程校验并编码完整成品视频，不选段、裁剪或添加遮罩。
 * @param draft EN: Frozen normalized draft. CN: 冻结的归一草稿。
 * @param profile EN: Frozen device facts. CN: 冻结设备事实。
 * @param directory EN: Task-owned output directory. CN: 任务持有的输出目录。
 * @param cancellationCheck EN: Cancellation probe. CN: 取消检查。
 * @param error EN: Processing error. CN: 处理错误。
 * @return EN: Completed result or nil. CN: 完成结果或 nil。 */
+ (nullable TSNpkDialVideoResult *)processDraft:(TSDialDraft *)draft profile:(TSNpkDialDeviceProfile *)profile
    directory:(NSString *)directory cancellationCheck:(nullable BOOL (^)(void))cancellationCheck error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
