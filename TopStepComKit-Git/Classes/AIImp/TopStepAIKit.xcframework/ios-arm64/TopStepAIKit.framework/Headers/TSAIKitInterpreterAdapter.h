//
//  TSAIKitInterpreterAdapter.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/30.
//

#import "TSAIInterpreterInterface.h"

@class TSAIContext;
@protocol TSAIInterpreterProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified simultaneous interpretation facade
 * @chinese 统一同声传译门面
 */
@interface TSAIKitInterpreterAdapter : NSObject <TSAIInterpreterInterface>

/**
 * @brief Create an interpreter adapter bound to one Context
 * @chinese 创建绑定到指定 Context 的同声传译适配器
 *
 * @param context
 * EN: Context that owns this adapter
 * CN: 持有当前适配器的 Context
 *
 * @param interpreterProvider
 * EN: Interpreter Provider created for the same Context
 * CN: 为同一 Context 创建的同声传译 Provider
 *
 * @return
 * EN: A Context-bound interpreter adapter
 * CN: 绑定到 Context 的同声传译适配器
 */
- (instancetype)initWithContext:(TSAIContext *)context
            interpreterProvider:(id<TSAIInterpreterProvider>)interpreterProvider
    NS_DESIGNATED_INITIALIZER;

/** App 持有手机双工引擎，SDK 只处理外部 PCM 和返回 TTS；完成回调不代表 App 已播完。 */
- (NSString *)startExternalPCMInterpretationWithConfig:(TSAIInterpreterConfig *)config
                                             onContent:(nullable TSAIInterpreterContentBlock)onContent
                                               onEvent:(nullable TSAIInterpreterEventBlock)onEvent
                                            completion:(nullable TSAIInterpreterCompletionBlock)completion
    NS_SWIFT_NAME(startExternalPCMInterpretation(config:onContent:onEvent:completion:));

/** 有序提交 16 kHz 单声道 Int16LE；每轮仅提交一次 isFinal。 */
- (void)appendExternalPCM:(nullable NSData *)data taskId:(NSString *)taskId isFinal:(BOOL)isFinal
    NS_SWIFT_NAME(appendExternalPCM(_:taskId:isFinal:));

/** 异常取消，支持 final 后取消；实际释放仍由原 completion 确认。 */
- (void)cancelExternalPCMWithTaskId:(NSString *)taskId
    NS_SWIFT_NAME(cancelExternalPCM(taskId:));

/** App 音频引擎已释放；与 SDK completion 汇合后解除 SDK 路由占用。 */
- (void)releaseExternalPCMWithTaskId:(NSString *)taskId
    NS_SWIFT_NAME(releaseExternalPCM(taskId:));

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
