//
//  TSAIKitInterpreterAdapter.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/30.
//

#import "TSAIInterpreterInterface.h"
#import "TSAIAudioRouteDefines.h"

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

/**
 * @brief Prepare and retain the conversation's phone microphone
 * @chinese 准备并持有对话翻译的手机麦克风
 * @param outputChannel EN: None or BuiltInSpeaker. CN: 不播放或手机扬声器。
 * @param completion EN: Called once after the engine and first PCM are ready, or with an error.
 *                   CN: 引擎和首段 PCM 均就绪后回调一次，失败时返回错误。
 * @param failureHandler EN: Main-queue runtime failure callback after readiness.
 *                       CN: 就绪之后的运行期失败回调，在主线程执行。
 */
- (void)prepareConversationPhoneCaptureWithOutputChannel:(TSAIAudioOutputChannel)outputChannel
                                             completion:(void (^)(NSError * _Nullable error))completion
                                         failureHandler:(void (^)(NSError *error))failureHandler;

/**
 * @brief Release the exact prepared phone microphone lease
 * @chinese 释放预备手机麦克风对应的精确租约
 */
- (void)stopConversationPhoneCapture;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
