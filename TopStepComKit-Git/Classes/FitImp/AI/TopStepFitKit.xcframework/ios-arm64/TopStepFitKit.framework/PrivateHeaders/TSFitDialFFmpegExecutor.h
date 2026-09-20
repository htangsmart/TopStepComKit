//
//  TSFitDialFFmpegExecutor.h
//  TopStepFitKit
//

#import <Foundation/Foundation.h>
#import "TSFitDialVideoConverter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Execute dial video conversion with the linked FFmpeg 6 libraries.
 * @chinese 使用已链接的 FFmpeg 6 库执行表盘视频转换。
 * @discussion Accepts only argument layouts emitted by TSFitDialVideoConverter.
 * 只接收 TSFitDialVideoConverter 生成的参数布局；同步调用须放在工作队列。
 * Every call owns its decoder, filter graph and encoders, allowing independent tasks.
 * 每次调用独占解码器、滤镜图和编码器，任务之间不共享执行状态。
 */
@interface TSFitDialFFmpegExecutor : NSObject <TSFitDialVideoExecuting>
/**
 * @brief Check the linked codecs, muxers and required video filters.
 * @chinese 检查链接的编码器、封装器及必要视频滤镜。
 * @return EN: YES when the required backend is available. CN: 后端组件完整时返回 YES。
 */
+ (BOOL)isAvailable;

/**
 * @brief Run one converter argument vector and finish writing its outputs.
 * @chinese 执行一组转换参数，完成实际输出后返回。
 * @param arguments EN: Arguments emitted by the converter. CN: 转换器生成的参数。
 * @param error EN: Validation, codec, filter or file error. CN: 参数、编解码、滤镜或文件错误。
 * @return EN: YES only after outputs finish successfully. CN: 仅产物成功写完后返回 YES。
 */
- (BOOL)executeArguments:(NSArray<NSString *> *)arguments error:(NSError *_Nullable *_Nullable)error;
@end

NS_ASSUME_NONNULL_END
