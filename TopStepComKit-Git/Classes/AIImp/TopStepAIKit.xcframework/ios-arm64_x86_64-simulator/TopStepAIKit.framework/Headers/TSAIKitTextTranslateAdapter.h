//
//  TSAIKitTextTranslateAdapter.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/23.
//

#import <Foundation/Foundation.h>
#import "TSAITranslateInterface.h"

@class TSAIContext;
@protocol TSAITranslateProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Shared AI text translate adapter
 * @chinese 通用 AI 文本翻译适配器
 */
@interface TSAIKitTextTranslateAdapter : NSObject <TSAITranslateInterface>

/**
 * @brief Create a translation adapter bound to one Context
 * @chinese 创建绑定到指定 Context 的翻译适配器
 *
 * @param context
 * EN: Context that owns this adapter
 * CN: 持有当前适配器的 Context
 *
 * @param translateProvider
 * EN: Translation Provider created for the same Context
 * CN: 为同一 Context 创建的翻译 Provider
 *
 * @return
 * EN: A Context-bound translation adapter
 * CN: 绑定到 Context 的翻译适配器
 */
- (instancetype)initWithContext:(TSAIContext *)context
              translateProvider:(id<TSAITranslateProvider>)translateProvider
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Translate text in a streaming manner
 * @chinese 以流式方式翻译文本
 *
 * @param text
 * EN: Source text to translate
 * CN: 待翻译文本
 *
 * @param config
 * EN: Translate configuration
 * CN: 翻译配置
 *
 * @param onPartialResult
 * EN: Partial-result callback
 * CN: 中间结果回调
 *
 * @param completion
 * EN: Completion callback
 * CN: 完成回调
 *
 * @return
 * EN: Task identifier used for cancellation
 * CN: 用于取消任务的任务标识
 */
- (NSString *)translateText:(NSString *)text
                     config:(TSAITranslateConfig *)config
            onPartialResult:(TSAITranslatePartialBlock _Nullable)onPartialResult
                 completion:(TSAITranslateCompletionBlock _Nullable)completion;

/**
 * @brief Cancel a running translate task
 * @chinese 取消一个进行中的翻译任务
 *
 * @param taskId
 * EN: Task identifier returned by translate API
 * CN: 翻译接口返回的任务标识
 */
- (void)cancelTranslationWithTaskId:(NSString *)taskId;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
