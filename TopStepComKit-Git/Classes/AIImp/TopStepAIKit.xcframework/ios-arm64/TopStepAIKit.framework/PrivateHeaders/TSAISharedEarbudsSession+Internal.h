//
//  TSAISharedEarbudsSession+Internal.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/16.
//

#import <Foundation/Foundation.h>

#import "TSAISystemAudioDriver+Internal.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One earbuds microphone (HFP) session held across many rounds
 * @chinese 跨多轮持有的一次耳机麦克风（HFP）会话
 *
 * @discussion
 * EN: Used by conversation translation: HFP is brought up once for the whole conversation instead
 *     of per round (each bring-up costs 0.5–2 s and an A2DP/HFP switch). Rounds that capture the
 *     earbuds attach a PCM consumer; all phone-side playback of the conversation goes through
 *     `driver` (SCO output). Captured PCM is dropped while no consumer is attached.
 * CN: 供对话翻译使用：整场只拉起一次 HFP，而不是每轮拉起（每次 0.5～2 秒且伴随 A2DP/HFP 切换）。
 *     用耳机收音的轮次挂上 PCM 消费者；整场的手机侧播放都经 `driver`（SCO 输出）。
 *     没有消费者时采到的数据丢弃。
 */
@interface TSAISharedEarbudsSession : NSObject

/** @brief Earbuds driver (capture + playback) @chinese 耳机驱动（采集与播放） */
@property (nonatomic, strong, readonly) id<TSAISystemAudioDriver> driver;

/** @brief Whether the earbuds microphone is routed @chinese 耳机麦克风是否已就绪 */
@property (atomic, assign, readonly, getter=isReady) BOOL ready;

/** @brief Start or runtime failure; rounds needing the earbuds fail with it @chinese 启动或运行期失败；需要耳机的轮次以它失败 */
@property (atomic, strong, readonly, nullable) NSError *failureError;

/**
 * @brief Called once on the main queue when the input fails after Ready (runtime loss)
 * @chinese 就绪之后输入失败（运行期丢失）时在主线程回调一次
 *
 * @discussion
 * EN: Start failures are reported through the start completion only. Set before starting.
 * CN: 启动失败只经 start 的 completion 回调。需在启动前设置。
 */
@property (nonatomic, copy, nullable) void (^runtimeFailureHandler)(NSError *error);

/**
 * @brief Create a session over an earbuds driver
 * @chinese 基于耳机驱动创建会话
 */
- (instancetype)initWithDriver:(id<TSAISystemAudioDriver>)driver NS_DESIGNATED_INITIALIZER;

/**
 * @brief Start capture with earbuds playback (asynchronous)
 * @chinese 开始采集并启用耳机播放（异步）
 *
 * @param completion
 * EN: Called once on the main queue: nil when Ready, otherwise the error
 * CN: 在主线程回调一次：就绪时为 nil，否则为错误
 */
- (void)startWithCompletion:(nullable void (^)(NSError * _Nullable error))completion;

/**
 * @brief Attach the PCM consumer of the current earbuds round (replaces any previous one)
 * @chinese 挂上当前耳机轮次的 PCM 消费者（替换之前的）
 *
 * @param consumer EN: Called on a capture thread. CN: 在采集线程回调。
 * @param failureHandler
 * EN: Called once if the input fails while attached (or immediately if it already failed)
 * CN: 挂载期间输入失败时回调一次（已失败时立即回调）
 * @return EN: Token for detaching. CN: 用于卸载的令牌。
 */
- (NSUInteger)attachPCMConsumer:(void (^)(NSData *pcmData))consumer
                 failureHandler:(nullable void (^)(NSError *error))failureHandler;

/** @brief Detach the consumer identified by the token (ignored when replaced) @chinese 卸载令牌对应的消费者（已被替换时忽略） */
- (void)detachPCMConsumerWithToken:(NSUInteger)token;

/** @brief Stop capture and playback and release the earbuds (idempotent) @chinese 停止采集与播放并释放耳机（幂等） */
- (void)stop;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
