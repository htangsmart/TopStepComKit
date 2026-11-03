//
//  TSAIChatAudioProcessor+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/10/28.
//

#import <Foundation/Foundation.h>

#import "TSAIPlaybackReferenceSource+Internal.h"

@class TSAIChatAudioProcessingConfiguration;
@class TSAIChatAudioProcessingSnapshot;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Monotonic arrival clock shared with playback references
 * @chinese 与播放参考共用的单调到达时钟
 * @return
 * EN: Mach absolute time converted to nanoseconds.
 * CN: 转换为纳秒的 Mach 单调时间。
 */
FOUNDATION_EXPORT uint64_t TSAIChatAudioMonotonicNanoseconds(void);

/**
 * @brief Session-owned external-PCM echo processing and speech admission
 * @chinese 单会话外部 PCM 回声处理与语音准入
 *
 * @discussion
 * [EN]: Input is 16 kHz mono Int16LE. Public methods enqueue work; callbacks run
 * on a dedicated processing queue. Arrival timestamps are estimated capture timing.
 * [CN]: 输入为 16 kHz 单声道 Int16LE；方法异步入队，回调位于专用处理队列。
 * 到达时间只表示估计采集时序，不是固件采集时刻。
 */
@interface TSAIChatAudioProcessor : NSObject <TSAIPlaybackReferenceObserver>

/**
 * @brief Processed PCM destination
 * @chinese 处理后 PCM 的接收入口
 * @discussion
 * [EN]: Called in input order before vendor VAD; masked samples retain duration.
 * [CN]: 按输入顺序在厂商 VAD 前交付；受抑制样本保持原时长。
 * @note
 * [EN]: May be nil; callers must not synchronously wait for the processing queue.
 * [CN]: 可为空；调用方不得同步等待处理队列。
 */
@property (atomic, copy, nullable) void (^pcmDataHandler)(NSData *pcmData);

/**
 * @brief Near-end onset notification for interrupting the current output
 * @chinese 用于打断当前输出的近端起声通知
 * @discussion
 * [EN]: Runs on the processing queue after processed speech admission. It does not
 * create a conversation round; buffered onset PCM still follows the normal path.
 * [CN]: 处理后语音准入时在处理队列通知；不创建业务轮次，缓存起句仍经正常链路交付。
 * @note
 * [EN]: Nullable; the owner validates the session before interrupting output.
 * [CN]: 可为空；所有者须校验会话后打断输出。
 */
@property (atomic, copy, nullable) void (^nearEndSpeechHandler)(void);

/**
 * @brief Effective processing-state destination
 * @chinese 实际处理状态的接收入口
 * @discussion
 * [EN]: State changes only, delivered on the processing queue.
 * [CN]: 仅状态变化时在处理队列交付。
 * @note
 * [EN]: UI consumers marshal callbacks to their own queue.
 * [CN]: UI 使用方自行切换到所需队列。
 */
@property (atomic, copy, nullable) void (^snapshotHandler)(TSAIChatAudioProcessingSnapshot *snapshot);

/**
 * @brief Whether a fresh no-input timeout may start
 * @chinese 是否允许开始完整的无输入倒计时
 * @discussion
 * [EN]: False while output is queued, playing, or its input tail is recovering.
 *       This flag does not disable voice interruption during playback.
 * [CN]: 输出排队、实际播放及输入尾部恢复期间为 NO；此标志不控制播放期间的语音打断。
 * @note
 * [EN]: Atomic snapshot; false after input finish, failure or stop.
 * [CN]: 原子快照；输入结束、失败或停止后为 NO。
 */
@property (atomic, assign, readonly) BOOL inputIdleTimingEligible;

/**
 * @brief No-input timing eligibility change destination
 * @chinese 无输入计时资格变化的接收入口
 * @discussion
 * [EN]: Delivered on the DSP queue; read the current flag immediately after binding.
 * [CN]: 在 DSP 队列交付；绑定后立即读取当前标志以覆盖绑定前的变化。
 * @note
 * [EN]: Nullable; the owner marshals to its session queue and checks generation.
 * [CN]: 可为空；所有者切换到会话队列并校验代次。
 */
@property (atomic, copy, nullable) void (^inputIdleTimingEligibilityHandler)(BOOL eligible);

/**
 * @brief Terminal processing failure destination
 * @chinese 处理链路终止错误的接收入口
 * @discussion
 * [EN]: At most once; pending audio is discarded and further input is rejected.
 * [CN]: 最多一次；丢弃待处理音频并拒绝后续输入。
 * @note
 * [EN]: The owner must terminate the vendor session; old VAD blocks cannot be withdrawn.
 * [CN]: 所有者须终止厂商会话，已提交的 VAD 块无法撤回。
 */
@property (atomic, copy, nullable) void (^failureHandler)(NSError *error);

/**
 * @brief Most recent immutable processing snapshot
 * @chinese 最近一次不可变处理快照
 * @discussion
 * [EN]: Can be read from any queue.
 * [CN]: 可在任意队列读取。
 * @note
 * [EN]: ReadyIdle is normal before the first playback reference exists.
 * [CN]: 首次播放参考出现前 ReadyIdle 为正常状态。
 */
@property (atomic, copy, readonly) TSAIChatAudioProcessingSnapshot *snapshot;

/**
 * @brief Stored terminal error, including failures before callbacks were attached
 * @chinese 保存终止错误，包含绑定回调前发生的失败
 * @discussion
 * [EN]: A subsequently assigned failure handler receives this error once.
 * [CN]: 后续设置的错误回调会收到此错误一次。
 * @note
 * [EN]: Nil before failure; stop without failure does not create an error.
 * [CN]: 失败前为 nil；正常停止不生成错误。
 */
@property (atomic, strong, readonly, nullable) NSError *terminalError;

/**
 * @brief Create one processing generation
 * @chinese 创建一代音频处理器
 * @param configuration
 * EN: Copied session settings.
 * CN: 复制保存的会话配置。
 * @param generation
 * EN: Generation also assigned to the playback-reference source.
 * CN: 同时赋给播放参考源的代次。
 * @param allowsUserInterrupt
 * EN: Whether continuous voice interruption was requested.
 * CN: 是否请求连续对话语音打断。
 * @param error
 * EN: Audio-processing initialization failure.
 * CN: 音频处理初始化失败。
 * @return
 * EN: A processor, or nil when the requested contract cannot be established.
 * CN: 处理器；无法建立所请求契约时为 nil。
 */
- (nullable instancetype)initWithConfiguration:(TSAIChatAudioProcessingConfiguration *)configuration
                                    generation:(NSUInteger)generation
                           allowsUserInterrupt:(BOOL)allowsUserInterrupt
                                         error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Update whether the started output backend supports actual references
 * @chinese 更新已启动输出后端是否支持真实参考
 * @param available
 * EN: Actual backend activation result, not selector availability.
 * CN: 实际后端激活结果，不是方法是否存在。
 */
- (void)setReferenceBackendAvailable:(BOOL)available;

/**
 * @brief Use vendor speech feedback only to protect noise-floor learning
 * @chinese 仅用厂商语音反馈保护噪声底学习
 * @param active
 * EN: Whether the vendor currently considers a user utterance active.
 * CN: 厂商当前是否认为用户语句尚未结束。
 */
- (void)setVendorSpeechActive:(BOOL)active;

/**
 * @brief Terminate when the active output path fails
 * @chinese 活动输出链路故障时终止处理会话
 * @param error
 * EN: Driver failure; its description is retained in the processing error.
 * CN: 驱动错误；其描述保留在处理错误中。
 */
- (void)reportPlaybackFailure:(NSError *)error;

/**
 * @brief Append captured PCM with its earliest host-arrival timestamp
 * @chinese 追加带最早主机到达时间的采集 PCM
 * @param pcmData
 * EN: Complete Int16 samples; odd-length data fails the session.
 * CN: 完整 Int16 样本；奇数字节会使会话失败。
 * @param arrivalNanoseconds
 * EN: End-of-chunk arrival on the shared monotonic clock.
 * CN: 同一单调时钟上的分片到达时刻，按分片末端估计。
 */
- (void)appendPCMData:(NSData *)pcmData receivedAtNanoseconds:(uint64_t)arrivalNanoseconds;

/** @brief Protect input before output is queued @chinese 输出入队前保护输入 */
- (void)prepareForPlayback;

/**
 * @brief Flush pending audio while keeping continuous input open
 * @chinese 冲刷待交付音频并继续接收连续输入
 * @param completion
 * EN: Runs after the admitted PCM on the processing queue.
 * CN: 在处理队列已准入 PCM 交付后执行。
 */
- (void)flushInputWithCompletion:(dispatch_block_t)completion;

/**
 * @brief Flush admitted input before input-finished or vendor stop
 * @chinese 输入结束或停止厂商前冲刷已准入音频
 * @param completion
 * EN: Runs after PCM callbacks on the processing queue, once.
 * CN: 在处理队列的 PCM 回调之后执行一次。
 */
- (void)finishInputWithCompletion:(dispatch_block_t)completion;

/** @brief Invalidate pending work and references @chinese 作废待处理任务及参考 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
