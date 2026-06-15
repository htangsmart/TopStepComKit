//
//  TSAITranslateResult.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Streaming translate final result
 * @chinese 流式翻译最终结果
 *
 * @discussion
 * [EN]: Delivered exactly once via the completion handler when the whole
 *       translation has finished. `translatedText` is the full final
 *       translation; intermediate updates are received via the
 *       partial-result callback. `sourceText` echoes the original input
 *       so callers can persist a self-contained record without keeping
 *       the request payload.
 * [CN]: 翻译完成时通过 completion 回调一次。`translatedText` 为完整译文；
 *       中间过程文本通过 partial 回调接收。
 *       `sourceText` 回显原文，便于调用方落库时保留自包含记录，
 *       而无需额外保存请求文本。
 */
@interface TSAITranslateResult : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by the translate API)
 * @chinese 任务唯一标识（与翻译接口同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Original source text (echo of the request)
 * @chinese 原始输入文本（请求回显）
 */
@property (nonatomic, copy) NSString *sourceText;

/**
 * @brief Full translated text
 * @chinese 完整译文
 */
@property (nonatomic, copy) NSString *translatedText;

/**
 * @brief Backend-detected source language
 * @chinese 后端检测到的源语言
 *
 * @discussion
 * [EN]: When `TSAITranslateConfig.sourceLanguage` is `Auto`, this carries
 *       the language the backend actually detected. When the caller
 *       specified a concrete source language, this echoes that value.
 * [CN]: 当 `TSAITranslateConfig.sourceLanguage` 为 `Auto` 时，
 *       该字段为后端实际检测到的语言；调用方显式指定时，回显该值。
 */
@property (nonatomic, assign) TSAILanguage detectedSourceLanguage;

@end

NS_ASSUME_NONNULL_END
