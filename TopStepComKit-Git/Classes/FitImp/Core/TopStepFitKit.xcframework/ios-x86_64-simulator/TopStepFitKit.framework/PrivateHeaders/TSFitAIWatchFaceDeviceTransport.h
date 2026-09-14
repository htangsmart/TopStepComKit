//
//  TSFitAIWatchFaceDeviceTransport.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <UIKit/UIKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Completion for an AI watch-face device command
 * @chinese AI 表盘设备命令完成回调
 */
typedef void (^TSFitAIWatchFaceDeviceCompletion)(BOOL succeed, NSError *_Nullable error);

/**
 * @brief Progress for an AI watch-face photo transfer
 * @chinese AI 表盘图片传输进度回调
 */
typedef void (^TSFitAIWatchFacePhotoProgress)(CGFloat progress);

/**
 * @brief Completion for an AI watch-face photo transfer
 * @chinese AI 表盘图片传输完成回调
 */
typedef void (^TSFitAIWatchFacePhotoCompletion)(BOOL succeed,
                                                CGFloat averageSpeed,
                                                NSError *_Nullable error);

/**
 * @brief Low-level sender for FitCloud AI watch-face commands
 * @chinese FitCloud AI 表盘命令的底层发送抽象
 */
@protocol TSFitAIWatchFaceCommandSending <NSObject>

/**
 * @brief Send an ASR result through FitCloud
 * @chinese 通过 FitCloud 发送 ASR 结果
 * @param text EN: ASR text, or nil for failure. CN: ASR 文本，失败时可为 nil。
 * @param errorCode EN: FitCloud ASR result code. CN: FitCloud ASR 结果码。
 * @param completion EN: FitCloud command completion. CN: FitCloud 命令完成回调。
 */
- (void)sendASRResult:(nullable NSString *)text
             errorCode:(FitCloudASRErrorCode)errorCode
            completion:(nullable TSFitAIWatchFaceDeviceCompletion)completion;

/**
 * @brief Send an AI-generated photo through FitCloud
 * @chinese 通过 FitCloud 发送 AI 生成图片
 * @param image EN: Preview image to transfer. CN: 要传输的预览图片。
 * @param progress EN: Optional transfer progress. CN: 可选的传输进度。
 * @param completion EN: Optional transfer completion. CN: 可选的传输完成回调。
 */
- (void)sendAIGeneratedPhoto:(UIImage *)image
                     progress:(nullable TSFitAIWatchFacePhotoProgress)progress
                   completion:(nullable TSFitAIWatchFacePhotoCompletion)completion;

/**
 * @brief Send an AI photo-generation result through FitCloud
 * @chinese 通过 FitCloud 发送 AI 图片生成结果
 * @param resultCode EN: FitCloud generation result code. CN: FitCloud 生成结果码。
 * @param completion EN: Optional command completion. CN: 可选的命令完成回调。
 */
- (void)sendAIPhotoGenerationResult:(FITCLOUDAIPHOTOGENRESULT)resultCode
                          completion:(nullable TSFitAIWatchFaceDeviceCompletion)completion;

@end

/**
 * @brief Device transport used by the AI watch-face coordinator
 * @chinese AI 表盘协调器使用的设备传输抽象
 */
@protocol TSFitAIWatchFaceDeviceTransporting <TSFitAIWatchFaceCommandSending>
@end

/**
 * @brief FitCloud implementation of the AI watch-face device transport
 * @chinese AI 表盘设备传输的 FitCloud 实现
 */
@interface TSFitAIWatchFaceDeviceTransport : NSObject <TSFitAIWatchFaceDeviceTransporting>

/**
 * @brief Initialize with the production FitCloud sender
 * @chinese 使用生产 FitCloud 发送器初始化
 * @return EN: Initialized transport. CN: 初始化后的传输对象。
 */
- (instancetype)init;

/**
 * @brief Initialize with an injectable command sender
 * @chinese 使用可注入的命令发送器初始化
 * @param commandSender EN: Low-level command sender; must not be nil. CN: 底层命令发送器，不得为 nil。
 * @return EN: Initialized transport, or nil when the sender is missing. CN: 初始化后的传输对象，发送器缺失时为 nil。
 */
- (nullable instancetype)initWithCommandSender:
    (nullable id<TSFitAIWatchFaceCommandSending>)commandSender
    NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
