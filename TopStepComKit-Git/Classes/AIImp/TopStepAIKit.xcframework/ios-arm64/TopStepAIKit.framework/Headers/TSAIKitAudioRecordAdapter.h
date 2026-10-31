//
//  TSAIKitAudioRecordAdapter.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/30.
//

#import "TSAudioRecordInterface.h"

@class TSAIContext;
@class TSAIStartRequest;
@protocol TSAIAudioRecordProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified AI audio recording facade
 * @chinese 统一 AI 录音门面
 */
@interface TSAIKitAudioRecordAdapter : NSObject <TSAudioRecordInterface>

/**
 * @brief Create an audio recording adapter bound to one Context
 * @chinese 创建绑定到指定 Context 的录音适配器
 *
 * @param context
 * EN: Context that owns this adapter
 * CN: 持有当前适配器的 Context
 *
 * @param audioRecordProvider
 * EN: Audio recording Provider created for the same Context
 * CN: 为同一 Context 创建的录音 Provider
 *
 * @return
 * EN: A Context-bound audio recording adapter
 * CN: 绑定到 Context 的录音适配器
 */
- (instancetype)initWithContext:(TSAIContext *)context
            audioRecordProvider:(id<TSAIAudioRecordProvider>)audioRecordProvider
    NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
/**
 * @brief Cancel local preparation after the orchestrator claims cancellation
 * @chinese 编排器取得取消权后回滚本地准备资源
 * @param request EN: Exact request. CN: 精确请求。
 * @param failure EN: Cancellation reason. CN: 取消原因。
 * @param completion EN: Local rollback result. CN: 本地回滚结果。
 */
- (void)cancelPreparationForRequest:(TSAIStartRequest *)request
                            failure:(NSError *)failure
                         completion:(TSAICompletionBlock)completion;

/**
 * @brief Append PCM to the exact prepared device recording
 * @chinese 向精确的已准备设备录音追加PCM
 *
 * @param pcmData
 * EN: Incremental 16 kHz mono Int16LE audio, copied at entry.
 * CN: 入口复制的16kHz单声道Int16LE增量音频。
 *
 * @param request
 * EN: Original immutable recording request; stale objects are ignored.
 * CN: 原始不可变录音请求；过期对象忽略。
 */
- (void)appendDevicePCMData:(NSData *)pcmData request:(TSAIStartRequest *)request;

/**
 * @brief Finish the original recording input after the last PCM
 * @chinese 最后一份PCM之后结束原录音输入
 *
 * @param request
 * EN: Original request; repeated input completion does not stop a later recording.
 * CN: 原请求；重复输入完成不能停止后来录音。
 */
- (void)finishDeviceInputForRequest:(TSAIStartRequest *)request;

/**
 * @brief End only the original device recording after device termination
 * @chinese 设备终止后仅结束原设备录音
 *
 * @param request
 * EN: Original immutable request whose transport has terminated.
 * CN: 传输已经终止的原不可变请求。
 *
 * @param error
 * EN: Original termination reason, or nil for an expected device close.
 * CN: 原终止原因；预期设备关闭时可为nil。
 */
- (void)endDeviceRecordingForRequest:(TSAIStartRequest *)request error:(nullable NSError *)error;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
