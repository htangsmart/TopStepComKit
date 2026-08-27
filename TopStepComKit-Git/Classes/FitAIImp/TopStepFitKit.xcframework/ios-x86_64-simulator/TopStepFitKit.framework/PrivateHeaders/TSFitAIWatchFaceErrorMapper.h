//
//  TSFitAIWatchFaceErrorMapper.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>
#import <FitCloudKit/FitCloudKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Maps AI and network errors to the FitCloud watch protocol
 * @chinese 将 AI 与网络错误映射为 FitCloud 手表协议错误码
 */
@interface TSFitAIWatchFaceErrorMapper : NSObject

/**
 * @brief Map an ASR error
 * @chinese 映射语音识别错误
 *
 * @param error EN: Source error, or nil for success. CN: 原始错误；成功时为 nil。
 * @return EN: FitCloud ASR result code. CN: FitCloud ASR 结果码。
 */
+ (FitCloudASRErrorCode)asrErrorCodeForError:(nullable NSError *)error;

/**
 * @brief Map an image-generation error
 * @chinese 映射图片生成错误
 *
 * @param error EN: Source error, or nil for success. CN: 原始错误；成功时为 nil。
 * @return EN: FitCloud AI photo generation result code. CN: FitCloud AI 图片生成结果码。
 */
+ (FITCLOUDAIPHOTOGENRESULT)photoGenerationResultForError:(nullable NSError *)error;

/**
 * @brief Determine whether an error represents unavailable connectivity
 * @chinese 判断错误是否表示网络连接不可用
 *
 * @param error EN: Error to inspect. CN: 待检查错误。
 * @return EN: YES for an offline network error. CN: 离线网络错误返回 YES。
 */
+ (BOOL)isNetworkUnavailableError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
