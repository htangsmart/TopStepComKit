//
//  TSVideoProcessor.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Video processing utility class for dial video creation
 * @chinese 表盘视频处理的工具类
 *
 * @discussion
 * [EN]: This class provides functionality to process video files for custom dial creation.
 *       It extracts frames from video, crops them to target size, and converts them to MP4 format.
 * [CN]: 此类提供用于自定义表盘创建的视频文件处理功能。
 *       它从视频中提取帧，将其裁切成目标尺寸，并将其转换为MP4格式。
 */
@interface TSVideoProcessor : NSObject

/**
 * @brief Process video file: extract frames, crop to target size, and convert to MP4
 * @chinese 处理视频文件：提取帧、裁切成目标尺寸并转换为MP4
 *
 * @param videoFilePath
 * EN: Path to the source video file (must be MP4 format)
 * CN: 源视频文件路径（必须是MP4格式）
 *
 * @param targetSize
 * EN: Target size for cropped frames (width and height in pixels)
 * CN: 裁切后的目标尺寸（宽度和高度，单位像素）
 *
 * @param fps
 * EN: Target frame rate (frames per second) for output video
 * CN: 输出视频的目标帧率（每秒帧数）
 *
 * @param maxDuration
 * EN: Maximum duration in seconds. If source video is longer, only first maxDuration seconds will be processed.
 *     Maximum allowed value is 30 seconds.
 * CN: 最大时长（秒）。如果源视频更长，只处理前maxDuration秒。
 *     最大允许值为30秒。
 *
 * @param outputPath
 * EN: Output file path for the processed video (should end with .hex extension)
 * CN: 处理后的视频输出文件路径（应以.hex扩展名结尾）
 *
 * @param cornerRadius
 * EN: Corner radius for cropped frames (in pixels). Use 0 for rectangular frames.
 * CN: 裁切帧的圆角半径（单位像素）。使用0表示矩形帧。
 *
 * @param completion
 * EN: Completion callback block
 *     - isSuccess: YES if processing succeeded, NO if failed
 *     - error: Error object if processing failed, nil if successful
 * CN: 完成回调块
 *     - isSuccess: 处理成功返回YES，失败返回NO
 *     - error: 处理失败时的错误对象，成功时为nil
 *
 * @discussion
 * [EN]: This method processes a video file by:
 *       1. Extracting frames from the video at the specified frame rate
 *       2. Cropping each frame to the target size
 *       3. Converting the frame array to MP4 format
 *       4. Saving the result to the output path
 *       
 *       The processing is performed asynchronously on a background queue to avoid blocking the main thread.
 *       Only MP4 format videos are supported.
 * [CN]: 此方法通过以下步骤处理视频文件：
 *       1. 以指定的帧率从视频中提取帧
 *       2. 将每帧裁切成目标尺寸
 *       3. 将帧数组转换为MP4格式
 *       4. 将结果保存到输出路径
 *       
 *       处理在后台队列上异步执行，以避免阻塞主线程。
 *       仅支持MP4格式的视频。
 */
+ (void)processVideo:(NSString *)videoFilePath
          targetSize:(CGSize)targetSize
                 fps:(NSInteger)fps
         maxDuration:(NSTimeInterval)maxDuration
          outputPath:(NSString *)outputPath
        cornerRadius:(CGFloat)cornerRadius
          completion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

