//
//  TSAIHostEchoCanceller+Internal.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/10/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal SpeexDSP MDF echo canceller with residual echo suppression.
 * @chinese 内部 SpeexDSP MDF 回声消除器，包含残余回声抑制。
 *
 * @discussion
 * [EN]: The caller serializes every method and supplies aligned 16 kHz mono Int16LE
 *       microphone/render frames. This class does not estimate transport delay or
 *       declare that a route is acoustically validated. The post-filter introduces
 *       one 160-sample frame of algorithmic delay.
 * [CN]: 调用方串行调用全部方法，提供已对齐的 16 kHz 单声道 Int16LE 拾音与播放参考帧。
 *       本类不估计传输延迟，不代表路由已通过声学验收。
 *       残余回声后滤波引入一帧（160 个采样点）的算法延迟。
 */
@interface TSAIHostEchoCanceller : NSObject

/**
 * @brief Whether the pinned MDF algorithm has reached its adapted state.
 * @chinese 固定版本 MDF 算法是否已进入内部自适应收敛状态。
 *
 * @discussion
 * [EN]: Reads SpeexDSP 1.2.1's actual `adapted` flag on the caller's serial
 *       processing queue. It is not a route quality or residual-echo guarantee.
 * [CN]: 在调用方串行处理队列读取 SpeexDSP 1.2.1 的真实 adapted 标志，
 *       不代表路由音质或残余回声已通过验收。
 */
@property (nonatomic, assign, readonly, getter=isConverged) BOOL converged;

/**
 * @brief Last-frame speech-presence probability from the residual echo post-filter.
 * @chinese 残余回声后滤波器输出的上一处理帧语音存在概率。
 *
 * @discussion
 * [EN]: Reads the pinned SpeexDSP probability as a value in 0 through 1 on the
 *       caller's serial processing queue. Returns 0 before processing, after
 *       reset, or when the state is unavailable. This is not a speaker identity,
 *       a speech event, or a second turn-segmentation VAD.
 * [CN]: 在调用方串行处理队列读取固定版本 SpeexDSP 的概率，范围为 0 至 1。
 *       处理前、重置后或状态不可用时返回 0；不代表说话人身份、语音事件或第二套分轮 VAD。
 */
@property (nonatomic, assign, readonly) double speechProbability;

/**
 * @brief Create an independent adaptive filter for one audio route lifecycle.
 * @chinese 为一次音频路由生命周期创建独立自适应滤波器。
 *
 * @param filterLengthMilliseconds
 * EN: Acoustic tail, 100 through 500 ms, rounded up to 10 ms; excludes BLE transport delay.
 * CN: 声学尾音长度，100 至 500 毫秒，向上取整至 10 毫秒；不包含 BLE 传输延迟。
 *
 * @param error
 * EN: Configuration or initialization error.
 * CN: 配置或初始化错误。
 *
 * @return
 * EN: A configured processor, or nil on failure.
 * CN: 已配置的处理器，失败为 nil。
 */
- (nullable instancetype)initWithFilterLengthMilliseconds:(NSUInteger)filterLengthMilliseconds
                                                   error:(NSError * _Nullable * _Nullable)error NS_DESIGNATED_INITIALIZER;

/**
 * @brief Process one continuous 10 ms microphone/render frame pair.
 * @chinese 处理一对连续的 10 毫秒拾音与播放参考帧。
 *
 * @param capturePCM
 * EN: Exactly 320 bytes of microphone PCM.
 * CN: 恰好 320 字节的拾音 PCM。
 *
 * @param referencePCM
 * EN: Exactly 320 bytes of aligned render PCM; provide continuous zero frames
 *     when no reference is playing.
 * CN: 恰好 320 字节且已对齐的播放参考 PCM；无播放参考时传连续零帧。
 *
 * @param error
 * EN: Invalid frame or unavailable state error.
 * CN: 帧格式或状态错误。
 *
 * @return
 * EN: Exactly 320 processed bytes, or nil on failure.
 * CN: 恰好 320 字节的处理结果，失败为 nil。
 */
- (nullable NSData *)processCapturePCM:(NSData *)capturePCM
                         referencePCM:(NSData *)referencePCM
                                error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Clear filter, overlap and residual suppression history.
 * @chinese 清除滤波、重叠窗与残余回声抑制历史。
 *
 * @discussion
 * [EN]: Call after discontinuity or reference timeline reset; the next process
 *       call reports an error if reset cannot restore its state.
 * [CN]: 音频中断或播放参考时间线重置后调用；若状态恢复失败，后续处理返回错误。
 */
- (void)reset;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
