#import <Foundation/Foundation.h>
#import <StarburstSdk/TextToImageCallback.h> 

NS_ASSUME_NONNULL_BEGIN

@interface TextToImageManager : NSObject

/**
 * 获取单例实例
 *
 * @return TextToImageManager 单例对象
 */
+ (instancetype)sharedInstance;

/**
 * 创建图片生成任务并自动轮询任务状态直到完成
 *
 * @param prompt 文本提示词，例如“阳光下的海边风景”
 * @param imageCount 生成的图片数量，建议范围 1~4
 * @param imageWidth 生成图片的宽度（像素）
 * @param imageHeight 生成图片的高度（像素）
 * @param callback 实现了 TextToImageCallback 协议的回调对象，用于接收任务事件
 *
 * @discussion 调用此方法会创建任务并自动定时查询任务进度，
 *             直到任务完成（成功或失败）或被取消。
 */
- (void)startTextToImage:(NSString *)prompt
              imageCount:(NSInteger)imageCount
              imageWidth:(NSInteger)imageWidth
             imageHeight:(NSInteger)imageHeight
                callback:(id<TextToImageCallback>)callback
    NS_SWIFT_NAME(startTextToImage(prompt:imageCount:imageWidth:imageHeight:callback:));

/**
 * 按任务 ID 持续轮询任务状态
 *
 * @param taskId 已创建任务的唯一标识
 * @param callback 回调对象，用于接收任务状态和结果
 *
 * @discussion 会持续查询任务状态直到任务完成，不会重新创建任务。
 */
- (void)queryByTaskId:(NSString *)taskId callback:(id<TextToImageCallback>)callback;

/**
 * 按任务 ID 查询一次任务状态
 *
 * @param taskId 已创建任务的唯一标识
 * @param callback 回调对象
 *
 * @discussion 与 queryByTaskId 不同，此方法只查询一次，不进行持续轮询。
 */
- (void)queryOnceByTaskId:(NSString *)taskId
                 callback:(id<TextToImageCallback>)callback
    NS_SWIFT_NAME(queryOnceByTaskId(_:callback:));

/**
 * 取消指定的图片生成任务
 *
 * @param taskId 要取消的任务 ID
 */
- (void)cancelTextToImage:(NSString *)taskId;

/**
 * 取消所有正在运行的图片生成任务
 */
- (void)cancelAllTasks;

/// 释放全部资源（不取消正运行任务）
- (void)releaseResources;

@end

NS_ASSUME_NONNULL_END
