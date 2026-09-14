//
//  TSVideoDialCreator+Preview.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/30.
//

#import "TSVideoDialCreator.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSVideoDialCreator (Preview)

/**
 * @brief Process the preview image and write it into the dial bin
 * @chinese 处理预览图并写入表盘 bin 文件
 *
 * @param draft
 * EN: Video dial draft.
 * CN: 视频表盘草稿。
 *
 * @param videoFilePath
 * EN: Local video file path used to extract the first frame when needed.
 * CN: 缺少预览图时用于提取第一帧的视频本地路径。
 *
 * @param binFilePath
 * EN: Target dial bin file path.
 * CN: 目标表盘 bin 文件路径。
 *
 * @param completion
 * EN: Completion callback containing the processing result.
 * CN: 返回处理结果的完成回调。
 */
+ (void)processPreviewImage:(TSDialDraft *)draft
              videoFilePath:(NSString *)videoFilePath
                binFilePath:(NSString *)binFilePath
                 completion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
