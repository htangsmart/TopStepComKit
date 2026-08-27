//
//  TSAIBudsChatAudioIngress+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Chat audio ingress lifecycle @chinese 对话音频入口生命周期 */
typedef NS_ENUM(NSInteger, TSAIBudsChatAudioIngressState) {
    TSAIBudsChatAudioIngressStateIdle = 0,
    TSAIBudsChatAudioIngressStatePrebuffering,
    TSAIBudsChatAudioIngressStateStarting,
    TSAIBudsChatAudioIngressStateStreaming,
    TSAIBudsChatAudioIngressStateDraining,
    TSAIBudsChatAudioIngressStateClosed,
};

/** @brief Result of accepting one PCM chunk @chinese 接收单个 PCM 分片的结果 */
typedef NS_ENUM(NSInteger, TSAIBudsChatAudioIngressAppendResult) {
    TSAIBudsChatAudioIngressAppendResultRejected = 0,
    TSAIBudsChatAudioIngressAppendResultBuffered,
    TSAIBudsChatAudioIngressAppendResultForwarded,
    TSAIBudsChatAudioIngressAppendResultOverflow,
};

/** @brief Bounded ingress timing and memory limits @chinese 有界入口的时序与内存限制 */
typedef struct {
    NSUInteger maximumBufferedBytes;
    NSUInteger maximumBufferedChunks;
    NSTimeInterval drainQuietInterval;
    NSTimeInterval drainHardTimeout;
    NSTimeInterval startupTimeout;
} TSAIBudsChatAudioIngressConfiguration;

typedef void (^TSAIBudsChatPCMAppendBlock)(NSData *pcmData);
typedef void (^TSAIBudsChatStopReadyBlock)(NSUInteger generation,
                                           NSString *taskIdentifier);
typedef void (^TSAIBudsChatStartupTimeoutBlock)(NSUInteger generation,
                                                NSString *taskIdentifier);

/**
 * @brief Queue-confined bounded ingress for device chat PCM
 * @chinese 限定在串行队列上的设备对话 PCM 有界入口
 */
@interface TSAIBudsChatAudioIngress : NSObject

/** @brief Current ingress state @chinese 当前入口状态 */
@property (nonatomic, assign, readonly) TSAIBudsChatAudioIngressState state;
/** @brief Monotonic input generation @chinese 单调递增的输入代际 */
@property (nonatomic, assign, readonly) NSUInteger generation;
/** @brief Bound App task identifier @chinese 已绑定的 App 任务标识 */
@property (nonatomic, copy, readonly, nullable) NSString *taskIdentifier;
/** @brief Retained PCM byte count @chinese 当前缓存 PCM 字节数 */
@property (nonatomic, assign, readonly) NSUInteger bufferedBytes;
/** @brief Retained PCM chunk count @chinese 当前缓存 PCM 分片数 */
@property (nonatomic, assign, readonly) NSUInteger bufferedChunkCount;
/** @brief Peak retained PCM bytes @chinese PCM 缓存峰值字节数 */
@property (nonatomic, assign, readonly) NSUInteger peakBufferedBytes;
/** @brief Total received PCM bytes @chinese 累计接收 PCM 字节数 */
@property (nonatomic, assign, readonly) NSUInteger receivedBytes;
/** @brief Total forwarded PCM bytes @chinese 累计转发 PCM 字节数 */
@property (nonatomic, assign, readonly) NSUInteger forwardedBytes;
/** @brief Total rejected PCM bytes @chinese 累计拒绝 PCM 字节数 */
@property (nonatomic, assign, readonly) NSUInteger rejectedBytes;
/** @brief Whether the bounded buffer overflowed @chinese 有界缓存是否已溢出 */
@property (nonatomic, assign, readonly, getter=isOverflowed) BOOL overflowed;
/** @brief Whether graceful stop was requested @chinese 是否已请求优雅停止 */
@property (nonatomic, assign, readonly, getter=isStopRequested) BOOL stopRequested;
/** @brief Whether stop-ready was signaled @chinese 是否已发出停止就绪通知 */
@property (nonatomic, assign, readonly, getter=isStopSignaled) BOOL stopSignaled;

/**
 * @brief Create a queue-confined bounded audio ingress
 * @chinese 创建限定在串行队列上的有界音频入口
 * @param executionQueue EN: Serial execution queue. CN: 串行执行队列。
 * @param configuration EN: Timing and memory limits. CN: 时序与内存限制。
 * @param stopReadyBlock EN: Exactly-once stop-ready callback. CN: 精确一次的停止就绪回调。
 * @param startupTimeoutBlock EN: Session startup timeout callback. CN: 会话启动超时回调。
 * @return EN: A configured ingress. CN: 配置完成的音频入口。
 */
- (instancetype)initWithExecutionQueue:(dispatch_queue_t)executionQueue
                         configuration:(TSAIBudsChatAudioIngressConfiguration)configuration
                         stopReadyBlock:(TSAIBudsChatStopReadyBlock)stopReadyBlock
                    startupTimeoutBlock:(TSAIBudsChatStartupTimeoutBlock)startupTimeoutBlock
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Prepare a generation before the App starts a task
 * @chinese 在 App 启动任务前准备一代缓存
 * @return EN: Active generation. CN: 当前有效代际。
 */
- (NSUInteger)beginDeviceInput;

/**
 * @brief Bind the App task to the current input generation
 * @chinese 将 App 任务绑定到当前输入代际
 * @param taskIdentifier EN: App task identifier. CN: App 任务标识。
 * @return EN: Bound generation, or zero on conflict. CN: 绑定代际，冲突时返回零。
 */
- (NSUInteger)bindTaskIdentifier:(NSString *)taskIdentifier;

/**
 * @brief Accept one PCM chunk
 * @chinese 接收一个 PCM 分片
 * @param pcmData EN: PCM bytes owned by the caller. CN: 调用方持有的 PCM 字节。
 * @return EN: Buffering or forwarding result. CN: 缓存或转发结果。
 */
- (TSAIBudsChatAudioIngressAppendResult)appendPCMData:(NSData *)pcmData;

/**
 * @brief Attach the vendor appender and flush buffered PCM
 * @chinese 绑定底层写入器并冲刷缓存 PCM
 * @param pcmAppender EN: Vendor PCM append block. CN: 底层 PCM 写入回调。
 * @param taskIdentifier EN: App task identifier. CN: App 任务标识。
 * @param generation EN: Expected input generation. CN: 期望的输入代际。
 * @return EN: YES when the matching session was attached. CN: 匹配会话绑定成功时返回 YES。
 */
- (BOOL)attachPCMAppender:(TSAIBudsChatPCMAppendBlock)pcmAppender
           taskIdentifier:(NSString *)taskIdentifier
               generation:(NSUInteger)generation;

/**
 * @brief Mark the device input stream as ended
 * @chinese 标记设备输入流结束
 */
- (void)markDeviceInputEnded;

/**
 * @brief Request graceful stop after the drain boundary
 * @chinese 请求在冲刷边界后优雅停止
 * @param taskIdentifier EN: App task identifier. CN: App 任务标识。
 * @param generation EN: Expected input generation. CN: 期望的输入代际。
 */
- (void)requestGracefulStopForTaskIdentifier:(NSString *)taskIdentifier
                                   generation:(NSUInteger)generation;

/**
 * @brief Clear the current generation and cancel timers
 * @chinese 清理当前代并取消定时器
 */
- (void)reset;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
