//
//  TSAIBudsQuestionAnswerProvider+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/14.
//

#import "TSAIBudsQuestionAnswerProvider.h"

@class AIBudsAIAskingConfig;
@class TSAIBudsManager;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal construction and vendor seam for AIBuds question answering
 * @chinese AIBuds 问答的内部构造与厂商调用接缝
 */
@interface TSAIBudsQuestionAnswerProvider (Internal)

/**
 * @brief Create with a Context-owned manager
 * @chinese 使用 Context 持有的 Manager 创建
 *
 * @param manager EN: Context-owned manager. CN: Context 持有的 Manager。
 * @return EN: Provider instance, or nil for an invalid manager. CN: Provider 实例；Manager 无效时返回 nil。
 */
- (nullable instancetype)initWithManager:(TSAIBudsManager *)manager;

/**
 * @brief Invoke the AIBuds class facade for AI asking
 * @chinese 调用 AIBuds AI 问答类门面
 *
 * @return EN: Provider question identifier, if created. CN: 创建成功时的 Provider 问题标识。
 */
- (nullable NSString *)tsai_sendAIBudsQuestion:(NSString *)question
                                        config:(AIBudsAIAskingConfig *)config
                             onStartAnswering:(void (^ _Nullable)(NSString * _Nullable))onStartAnswering
                                      onAnswer:(void (^ _Nullable)(NSString *, NSString * _Nullable,
                                                                   NSString * _Nullable, BOOL))onAnswer
                              onFinishAnswering:(void (^ _Nullable)(NSString *))onFinishAnswering
                                        onError:(void (^ _Nullable)(NSString *, NSError *))onError;

@end

NS_ASSUME_NONNULL_END
