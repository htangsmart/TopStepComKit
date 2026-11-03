//
//  TSAIObservableVoicePlayer.h
//  TopStepAIKit
//
//  Created by Codex on 2026/10/28.
//

#import "TSAIBudsSystemAudioDriver+Private.h"
#import "TSAIPlaybackReferenceSource+Internal.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Playback-only source-node engine with a bounded render-reference handoff
 * @chinese 使用有界渲染参考交接的纯播放 SourceNode 引擎
 *
 * @discussion
 * [EN]: Never accesses an input node or changes AVAudioSession. PCM state and observer delivery
 * use a private serial queue; graph start/stop stay with the driver's audio executor.
 * The real-time callback only touches preallocated C storage.
 * [CN]: 不访问输入节点、不修改 AVAudioSession。PCM 状态与观察者回调使用私有串行队列，
 * 音频图启停留在驱动的音频执行器，实时回调仅操作预分配的 C 存储。
 */
@interface TSAIObservableVoicePlayer : NSObject <TSAIBudsStreamingPlayer>

/**
 * @brief Format accepted by appendInt16PCM
 * @chinese appendInt16PCM 接受的格式
 *
 * @discussion
 * [EN]: Always 16 kHz mono Int16LE.
 * [CN]: 始终为 16 kHz 单声道 Int16LE。
 *
 * @note
 * [EN]: Hardware conversion is performed by the output graph.
 * [CN]: 硬件格式转换由输出图完成。
 */
@property (nonatomic, strong, readonly) AVAudioFormat *audioFormat;
/**
 * @brief Terminal playback callback
 * @chinese 播放终态回调
 *
 * @discussion
 * [EN]: Called on the private non-real-time queue after the rendered final boundary
 * and output presentation latency, or immediately after cancellation/failure.
 * [CN]: 在最终渲染边界及输出呈现延迟之后，或取消/失败之后，在私有非实时队列回调。
 *
 * @note
 * [EN]: Exactly once per accepted voice; no waiting-buffer timeout is used.
 * [CN]: 每个已接受语音只回调一次，不使用等待缓冲超时。
 */
@property (nonatomic, copy, nullable) void (^onVoicePlaybackDidStop)(NSString *, AIBudsPlaybackStopReason,
                                                                  NSDate *, NSDate *, NSError * _Nullable);
/**
 * @brief Runtime engine failure callback
 * @chinese 引擎运行期失败回调
 *
 * @discussion
 * [EN]: Reports graph configuration loss and bounded queue overflow.
 * [CN]: 上报音频图配置失效及有界队列溢出。
 *
 * @note
 * [EN]: Runs outside the render thread; may be nil.
 * [CN]: 不在渲染线程回调，允许为空。
 */
@property (atomic, copy, nullable) void (^onPlaybackError)(NSError *error);
/**
 * @brief Whether the output graph is currently running
 * @chinese 输出图当前是否运行
 *
 * @discussion
 * [EN]: Snapshot updated after start, stop or graph failure.
 * [CN]: 启动、停止或图失效后更新的快照。
 *
 * @note
 * [EN]: YES does not certify acoustic echo-cancellation quality.
 * [CN]: YES 不代表声学回声消除质量已经验证。
 */
@property (atomic, assign, readonly) BOOL isRunning;
/**
 * @brief Cached system output-volume setting equals zero
 * @chinese 缓存的系统输出音量设置是否为零
 *
 * @discussion
 * [EN]: Updated outside the render callback; does not measure acoustic sound pressure.
 * [CN]: 在渲染回调外更新，不测量声学声压。
 *
 * @note
 * [EN]: Initialized at start and refreshed by the non-real-time delivery timer.
 * [CN]: 启动时初始化，由非实时交接定时器更新。
 */
@property (atomic, assign, readonly) BOOL playbackOutputMuted;

/**
 * @brief Create a renderer bound to one processing generation
 * @chinese 创建绑定单个处理代次的渲染器
 *
 * @param source
 * EN: Observer-facing source identity.
 * CN: 观察者看到的源身份。
 *
 * @param observer
 * EN: Weak reference observer.
 * CN: 弱引用参考观察者。
 *
 * @param generation
 * EN: Processing generation.
 * CN: 处理代次。
 *
 * @return
 * EN: A stopped playback engine.
 * CN: 尚未启动的播放引擎。
 */
- (instancetype)initWithReferenceSource:(id<TSAIPlaybackReferenceSource>)source
                               observer:(nullable id<TSAIPlaybackReferenceObserver>)observer
                             generation:(NSUInteger)generation NS_DESIGNATED_INITIALIZER;
/**
 * @brief Default initialization is unavailable
 * @chinese 不支持默认初始化
 *
 * @return
 * EN: Unavailable; use the designated reference-source initializer.
 * CN: 不可调用，请使用指定的播放参考源初始化方法。
 */
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
