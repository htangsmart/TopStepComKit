//
//  TSAIPlaybackReferenceSource+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/10/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TSAIPlaybackReferenceSource;

/**
 * @brief Sample timing on the monotonic Mach clock
 * @chinese 基于 Mach 单调时钟的样本时序
 */
typedef struct {
    uint64_t hostTimeNanoseconds;
    uint64_t sampleIndex;
    NSUInteger generation;
    BOOL discontinuous;
} TSAIPlaybackReferenceTiming;

/**
 * @brief PCM actually consumed by the output render callback
 * @chinese 输出渲染回调实际消费的 PCM
 */
@interface TSAIPlaybackReferenceFrame : NSObject

/**
 * @brief Rendered 16 kHz mono Int16LE PCM
 * @chinese 已渲染的 16 kHz 单声道 Int16LE PCM
 *
 * @discussion
 * [EN]: Includes software gain and limiting; silence is represented by zero samples.
 * [CN]: 包含软件增益与限幅，静音用零样本表示。
 *
 * @note
 * [EN]: Immutable, nonempty; does not include hardware output volume or acoustic latency.
 * [CN]: 不可变且非空，不包含硬件输出音量与声学延迟。
 */
@property (nonatomic, copy, readonly) NSData *pcmData;

/**
 * @brief Mach host time of the first rendered sample, in nanoseconds
 * @chinese 首个渲染样本的 Mach 主机时刻，单位纳秒
 *
 * @discussion
 * [EN]: Shares the mach_absolute_time clock used by capture arrival timestamps.
 * [CN]: 与采集到达时间使用相同的 mach_absolute_time 时钟。
 *
 * @note
 * [EN]: Render time is not the instant sound reaches the remote microphone.
 * [CN]: 渲染时刻不等于声音到达远端麦克风的时刻。
 */
@property (nonatomic, assign, readonly) uint64_t hostTimeNanoseconds;

/**
 * @brief Index of the first rendered sample
 * @chinese 首个渲染样本的索引
 *
 * @discussion
 * [EN]: Counts samples, including rendered silence, within the running output engine.
 * [CN]: 在本次输出引擎运行期间按样本计数，包含渲染的静音。
 *
 * @note
 * [EN]: Restarts when the engine is recreated.
 * [CN]: 引擎重建时重新计数。
 */
@property (nonatomic, assign, readonly) uint64_t sampleIndex;

/**
 * @brief Voice associated with the rendered samples
 * @chinese 渲染样本所属的语音标识
 *
 * @discussion
 * [EN]: Empty for idle rendered silence.
 * [CN]: 空闲静音使用空字符串。
 *
 * @note
 * [EN]: One frame never spans two voice identifiers.
 * [CN]: 一帧不会跨越两个语音标识。
 */
@property (nonatomic, copy, readonly) NSString *voiceIdentifier;

/**
 * @brief Owning audio-processing generation
 * @chinese 所属音频处理代次
 *
 * @discussion
 * [EN]: Copied from the source when playback starts.
 * [CN]: 播放启动时从源复制。
 *
 * @note
 * [EN]: Consumers reject frames from retired generations.
 * [CN]: 消费方拒绝已经作废代次的数据。
 */
@property (nonatomic, assign, readonly) NSUInteger generation;

/**
 * @brief Whether reference continuity was lost before this frame
 * @chinese 本帧之前参考音频是否失去连续性
 *
 * @discussion
 * [EN]: Signals overflow, invalid render timing or an output discontinuity.
 * [CN]: 表示溢出、无效渲染时间或输出不连续。
 *
 * @note
 * [EN]: Requires delay-estimator recovery; never silently assume continuity.
 * [CN]: 需要恢复延迟估计，不得默认为连续数据。
 */
@property (nonatomic, assign, readonly) BOOL discontinuous;

/**
 * @brief Create an immutable rendered frame
 * @chinese 创建不可变渲染帧
 *
 * @param pcmData
 * EN: Rendered PCM.
 * CN: 已渲染 PCM。
 *
 * @param voiceIdentifier
 * EN: Voice identifier or empty for silence.
 * CN: 语音标识，静音为空。
 *
 * @param timing
 * EN: Monotonic render timing.
 * CN: 单调渲染时序。
 *
 * @return
 * EN: Immutable frame.
 * CN: 不可变帧。
 */
- (instancetype)initWithPCMData:(NSData *)pcmData
                voiceIdentifier:(NSString *)voiceIdentifier
                         timing:(TSAIPlaybackReferenceTiming)timing;
@end

/**
 * @brief Ordered reference observer called on a non-real-time serial queue
 * @chinese 在非实时串行队列按序回调的播放参考观察者
 */
@protocol TSAIPlaybackReferenceObserver <NSObject>
/**
 * @brief Receive rendered samples
 * @chinese 接收渲染样本
 *
 * @param source
 * EN: Output source.
 * CN: 输出源。
 *
 * @param frame
 * EN: Rendered reference frame.
 * CN: 已渲染参考帧。
 */
- (void)playbackReferenceSource:(id<TSAIPlaybackReferenceSource>)source
                didRenderFrame:(TSAIPlaybackReferenceFrame *)frame;
/**
 * @brief First voice sample entered rendering
 * @chinese 首个语音样本进入渲染
 *
 * @param source
 * EN: Output source.
 * CN: 输出源。
 *
 * @param voiceIdentifier
 * EN: Voice identifier.
 * CN: 语音标识。
 *
 * @param generation
 * EN: Processing generation.
 * CN: 处理代次。
 *
 * @param hostTimeNanoseconds
 * EN: Render host time.
 * CN: 渲染主机时间。
 */
- (void)playbackReferenceSource:(id<TSAIPlaybackReferenceSource>)source
                 didStartVoice:(NSString *)voiceIdentifier
                    generation:(NSUInteger)generation
           hostTimeNanoseconds:(uint64_t)hostTimeNanoseconds;
/**
 * @brief Last voice sample completed rendering or playback was cancelled
 * @chinese 语音渲染完成或播放取消
 *
 * @param source
 * EN: Output source.
 * CN: 输出源。
 *
 * @param voiceIdentifier
 * EN: Voice identifier.
 * CN: 语音标识。
 *
 * @param generation
 * EN: Processing generation.
 * CN: 处理代次。
 *
 * @param hostTimeNanoseconds
 * EN: Render boundary host time.
 * CN: 渲染边界主机时间。
 */
- (void)playbackReferenceSource:(id<TSAIPlaybackReferenceSource>)source
                  didStopVoice:(NSString *)voiceIdentifier
                    generation:(NSUInteger)generation
           hostTimeNanoseconds:(uint64_t)hostTimeNanoseconds;
@end

/**
 * @brief Optional observable playback configuration
 * @chinese 可选的可观测播放配置
 */
@protocol TSAIPlaybackReferenceSource <NSObject>
/**
 * @brief Reference observer
 * @chinese 播放参考观察者
 *
 * @discussion
 * [EN]: Configure before starting; the engine holds a weak snapshot for its lifetime.
 * [CN]: 在启动前配置，引擎在本次生命周期内保存弱引用快照。
 *
 * @note
 * [EN]: Nil by default; callbacks never run on the render thread.
 * [CN]: 默认为空，回调不在渲染线程执行。
 */
@property (atomic, weak, nullable) id<TSAIPlaybackReferenceObserver> referenceObserver;
/**
 * @brief Generation captured by the next engine start
 * @chinese 下次引擎启动采用的代次
 *
 * @discussion
 * [EN]: Set to the owning processing session generation before beginning the lease.
 * [CN]: 在开始租约前设置为所属处理会话的代次。
 *
 * @note
 * [EN]: Defaults to zero; changing it does not retag an already running engine.
 * [CN]: 默认为零，修改属性不会改变已经运行引擎的数据标记。
 */
@property (atomic, assign) NSUInteger referenceGeneration;
/**
 * @brief Request an observable backend before starting
 * @chinese 启动前请求可观测后端
 *
 * @discussion
 * [EN]: Applied only to supported routes by the driver.
 * [CN]: 由驱动仅对支持的路由应用。
 *
 * @note
 * [EN]: Defaults to NO; this request alone does not mean references are available.
 * [CN]: 默认为 NO，仅设置请求不代表参考已经可用。
 */
@property (nonatomic, assign) BOOL observablePlaybackRequested;
/**
 * @brief Whether the active engine supplies render references
 * @chinese 当前引擎是否提供渲染参考
 *
 * @discussion
 * [EN]: Query after successful start and when handling runtime output errors.
 * [CN]: 启动成功后及处理输出运行期错误时查询。
 *
 * @note
 * [EN]: NO before start or after failure; YES does not certify acoustic AEC performance.
 * [CN]: 启动前或失效后为 NO，YES 不代表声学 AEC 效果已经验证。
 */
@property (atomic, assign, readonly) BOOL playbackReferenceAvailable;
/**
 * @brief Whether the actual system output-volume setting is zero
 * @chinese 系统实际输出音量设置是否为零
 *
 * @discussion
 * [EN]: Cached outside the render thread from AVAudioSession.outputVolume.
 * [CN]: 在渲染线程以外从 AVAudioSession.outputVolume 更新缓存。
 *
 * @note
 * [EN]: NO for an inactive/nonobservable backend; this is not an absolute sound-pressure estimate.
 * [CN]: 非活动或不可观测后端返回 NO，不代表能够估算绝对声压。
 */
@property (atomic, assign, readonly) BOOL playbackOutputMuted;
@end

NS_ASSUME_NONNULL_END
