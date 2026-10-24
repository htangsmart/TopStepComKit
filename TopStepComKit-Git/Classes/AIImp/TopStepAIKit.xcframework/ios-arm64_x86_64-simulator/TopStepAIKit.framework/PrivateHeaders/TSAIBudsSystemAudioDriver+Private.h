//
//  TSAIBudsSystemAudioDriver+Private.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/17.
//

#import <AVFoundation/AVFoundation.h>
#import <AIBudsAudio/AIBudsAudio-Swift.h>

#import "TSAIBudsSystemAudioDriver+Internal.h"

@class TSAIBudsAudioLease;
@class TSAIBudsCaptureLevelStats;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 厂商音频对象（薄协议，便于单测注入假引擎）

/** 厂商双工引擎：同一 AVAudioEngine 内采音 + 播放（VPIO 以 SDK 播放为回声参考） */
@protocol TSAIBudsDuplexAudioEngine <NSObject>
@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, readonly) BOOL isVoiceProcessingEnabled;
@property (nonatomic, copy, nullable) void (^onAudioBuffer)(AVAudioPCMBuffer * _Nonnull);
@property (nonatomic, copy, nullable) void (^onAudioError)(NSError * _Nonnull);
@property (nonatomic, copy, nullable) void (^onVoicePlaybackDidStop)(NSString * _Nonnull, AIBudsPlaybackStopReason, NSDate * _Nonnull, NSDate * _Nonnull, NSError * _Nullable);
- (BOOL)startWithPreferSpeakerOutput:(BOOL)preferSpeakerOutput
               enableVoiceProcessing:(BOOL)enableVoiceProcessing
                               error:(NSError * _Nullable * _Nullable)error;
- (BOOL)stop;
- (void)appendInt16PCM:(NSData *)pcmData voiceId:(NSString *)voiceId isFinal:(BOOL)isFinal;
- (void)interruptCurrentVoicePlayback;
@end

/** 厂商仅采音引擎 */
@protocol TSAIBudsCaptureRecorder <NSObject>
@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, copy, nullable) void (^onAudioBuffer)(AVAudioPCMBuffer * _Nonnull);
@property (nonatomic, copy, nullable) void (^onRecordingError)(NSError * _Nonnull);
- (BOOL)startRecording:(BOOL)preferSpeakerOutput error:(NSError * _Nullable * _Nullable)error;
- (void)stopRecording;
@end

/** 厂商仅播放引擎 */
@protocol TSAIBudsStreamingPlayer <NSObject>
@property (nonatomic, readonly, strong, nullable) AVAudioFormat *audioFormat;
@property (nonatomic, copy, nullable) void (^onVoicePlaybackDidStop)(NSString * _Nonnull, AIBudsPlaybackStopReason, NSDate * _Nonnull, NSDate * _Nonnull, NSError * _Nullable);
- (BOOL)start;
- (BOOL)stop;
- (void)appendInt16PCM:(NSData *)pcmData voiceId:(NSString *)voiceId isFinal:(BOOL)isFinal;
- (void)interruptCurrentVoicePlayback;
@end

@interface AIBudsDuplexVoiceAudioEngine (TSAIBudsSystemAudioDriver) <TSAIBudsDuplexAudioEngine>
@end

@interface AIBudsAudioRecorder (TSAIBudsSystemAudioDriver) <TSAIBudsCaptureRecorder>
@end

@interface AIBudsStreamingVoicePlayer (TSAIBudsSystemAudioDriver) <TSAIBudsStreamingPlayer>
@end

/** 厂商音频对象的工厂 */
@protocol TSAIBudsAudioEngineFactory <NSObject>
- (id<TSAIBudsDuplexAudioEngine>)makeDuplexEngine;
- (id<TSAIBudsCaptureRecorder>)makeAudioRecorder;
- (id<TSAIBudsStreamingPlayer>)makeVoicePlayer;
@end

/** 默认工厂：创建 AIBudsAudio 的真实对象 */
@interface TSAIBudsVendorAudioEngineFactory : NSObject <TSAIBudsAudioEngineFactory>
@end

#pragma mark - 驱动状态

/** 手机麦驱动状态（异步路径只在执行器上变化） */
typedef NS_ENUM(NSInteger, TSAIBudsSystemAudioDriverState) {
    /// 空闲
    TSAIBudsSystemAudioDriverStateIdle = 0,
    /// 执行器正在启动（阻塞调用中）
    TSAIBudsSystemAudioDriverStateStarting = 1,
    /// 运行中
    TSAIBudsSystemAudioDriverStateRunning = 2,
    /// 采音会话被改写，等待重建
    TSAIBudsSystemAudioDriverStateRecovering = 3,
};

/** 1001 等待缓冲超时回调的处理结果 */
typedef NS_ENUM(NSInteger, TSAIBudsVoiceResumeResult) {
    /** 不涉及续播 */
    TSAIBudsVoiceResumeResultNone = 0,
    /** 已续播语音旧实例的迟到回调，忽略 */
    TSAIBudsVoiceResumeResultIgnored,
    /** 已安排静默期后续播 */
    TSAIBudsVoiceResumeResultScheduled,
    /** 已收到 final 且剩余可忽略，视为播完 */
    TSAIBudsVoiceResumeResultFinished,
    /** 续播次数超限，视为该语音播放失败 */
    TSAIBudsVoiceResumeResultExhausted,
};

/** 静默期内排队的一个输出分片 */
@interface TSAIBudsPendingPCMChunk : NSObject
/** PCM 数据（未做播放增益） */
@property (nonatomic, strong) NSData *pcmData;
/** 调用方原始语音标识 */
@property (nonatomic, copy) NSString *voiceId;
/** 是否为该语音的最终分片 */
@property (nonatomic, assign) BOOL isFinal;
@end

@interface TSAIBudsSystemAudioDriver ()

#pragma mark 模式

/** 回退开关：YES 时走旧的内联路径（调用方线程），不经执行器 */
@property (nonatomic, assign, readonly) BOOL usesSynchronousFallback;
/** 厂商音频对象工厂 */
@property (nonatomic, strong) id<TSAIBudsAudioEngineFactory> engineFactory;

#pragma mark 引擎（异步路径只在执行器上读写）

/** 系统双工引擎 */
@property (nonatomic, strong, nullable) id<TSAIBudsDuplexAudioEngine> duplexEngine;
/** 仅采音引擎 */
@property (nonatomic, strong, nullable) id<TSAIBudsCaptureRecorder> audioRecorder;
/** 仅播放引擎 */
@property (nonatomic, strong, nullable) id<TSAIBudsStreamingPlayer> voicePlayer;
/** 本次启动请求的输入通道 */
@property (nonatomic, assign) TSAIAudioInputChannel requestedInputChannel;
/** 本次启动请求的输出通道 */
@property (nonatomic, assign) TSAIAudioOutputChannel requestedOutputChannel;
/** 启动校验完成后才处理运行期路由变化 */
@property (nonatomic, assign) BOOL isRouteValidated;
/** 本次启动已发起的采音重建次数 */
@property (nonatomic, assign) NSUInteger captureRecoveryAttempts;
/** 是否已有待执行的采音重建 */
@property (nonatomic, assign) BOOL captureRecoveryScheduled;
/** 本次启动为降级播放 / 跟随系统把 PlayAndRecord 的输出改到了扬声器；停止时撤销 */
@property (nonatomic, assign) BOOL appliedSpeakerOverride;
/** 本次启动是否以 preferSpeakerOutput 启动（P3 10.1：启动前决策扬声器） */
@property (nonatomic, assign) BOOL startedWithPreferredSpeaker;

#pragma mark 旧路径（回退开关）的回调

/** PCM 回调 */
@property (nonatomic, copy, nullable) void (^pcmHandler)(NSData *pcmData);
/** 运行错误回调 */
@property (nonatomic, copy, nullable) void (^errorHandler)(NSError *error);

#pragma mark 异步路径

/** 执行器上正在使用引擎的租约（执行器内） */
@property (nonatomic, strong, nullable) TSAIBudsAudioLease *q_currentLease;
/** 驱动状态（执行器内写；通知线程读原子快照） */
@property (atomic, assign) TSAIBudsSystemAudioDriverState driverState;
/** 最近一次 begin 的租约：不带作用域的旧方法作用于它 */
@property (atomic, strong, nullable) TSAIBudsAudioLease *latestLease;
/** 正在使用引擎的租约快照（任意线程读：输出记账、运行期错误） */
@property (atomic, strong, nullable) TSAIBudsAudioLease *engineLease;
/** 启动期间收到的打断 / 媒体服务重置（通知线程写，启动块结束后消费） */
@property (atomic, strong, nullable) NSError *pendingStartInterruption;
/** 语音处理是否生效（原子快照） */
@property (atomic, assign) BOOL voiceProcessingSnapshot;

#pragma mark 共用

/** 引擎代次：每次启动 / 停止递增，作废尚未执行的采音重建与排队投递（原子读） */
@property (atomic, assign) NSUInteger engineGeneration;

#pragma mark 输出调度（outputCompletions 锁内）

/** 按语音标识保存播放终态回调 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *outputCompletions;
/** 每段语音累计字节数，用于按音频长度设置终态等待上限 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *outputByteCounts;
/** 当前活动语音（调用方原始语音标识） */
@property (nonatomic, copy, nullable) NSString *activeVoiceId;
/** 当前活动语音在播放器中的标识（续播时为带 #n 后缀的别名） */
@property (nonatomic, copy, nullable) NSString *activePlayerVoiceId;
/** 当前活动语音是否已收到 final */
@property (nonatomic, assign) BOOL activeVoiceSealed;
/** 当前活动语音是否已有数据交给播放器（被误杀待续播时为 NO） */
@property (nonatomic, assign) BOOL activeVoiceOnPlayer;
/** 每段语音已分配的播放器别名序号：单调递增，别名不复用 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *voiceAliasSequences;
/** 每段语音被误杀（播放器里仍有未播数据却报 1001）的累计次数，用于续播上限；正常播完后清零 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *voiceKillCounts;
/** 已退场的语音（被新语音取代 / 续播超限 / 被打断）→ 其迟到最终分片的终态错误；迟到分片直接丢弃 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSError *> *retiredVoiceErrors;
/** 输出代次：每次打断 / 停止递增，正在投递的排队分片据此中止 */
@property (nonatomic, assign) NSUInteger outputEpoch;
/** 当前播放器实例已接收的原始 PCM，被误杀后按播放进度续播 */
@property (nonatomic, strong) NSMutableData *activeVoicePCM;
/** 续播别名 → 调用方原始语音标识 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *playerVoiceAliases;
/** 静默期截止时刻（systemUptime），之前到达的分片先排队 */
@property (nonatomic, assign) NSTimeInterval quietDeadline;
/** 静默期内排队的分片 */
@property (nonatomic, strong) NSMutableArray<TSAIBudsPendingPCMChunk *> *pendingChunks;
/** 是否已安排排队分片的投递 */
@property (nonatomic, assign) BOOL pendingFlushScheduled;
/** 是否正在投递排队分片：期间其他线程到达的分片继续排队，保证先后顺序 */
@property (nonatomic, assign) BOOL isFlushingPendingChunks;
/** 静默期时长（秒），默认 kTSAIBudsPlaybackQuietInterval */
@property (nonatomic, assign) NSTimeInterval playbackQuietInterval;

#pragma mark 诊断

/** 诊断：本次启动的采音电平统计（采音线程累计，日志用） */
@property (atomic, strong, nullable) TSAIBudsCaptureLevelStats *captureLevelStats;

#pragma mark 共用方法（核心文件）

/** 判断输入是否由系统音频链路负责 */
- (BOOL)isSystemInputChannel:(TSAIAudioInputChannel)channel;
/** 判断输出是否由系统音频链路负责 */
- (BOOL)isSystemOutputChannel:(TSAIAudioOutputChannel)channel;
/** 校验当前真实系统端口 */
- (BOOL)currentRouteMatchesInput:(TSAIAudioInputChannel)input output:(TSAIAudioOutputChannel)output;
/** 路由不匹配错误（带真实端口与会话配置） */
- (NSError *)routeMismatchErrorWithDescription:(NSString *)description;
/** 启动失败的错误：补上 audioFailurePhase = start 与 audioFailureScope */
- (NSError *)startErrorFromError:(nullable NSError *)error lease:(TSAIBudsAudioLease *)lease;
/** 系统输出不可用 */
- (NSError *)outputUnavailableError;
/** 启动看门狗时长 */
- (NSTimeInterval)startWatchdogTimeout;
/** 实际音频会话（单测替换） */
- (AVAudioSession *)audioSession;

@end

#pragma mark - 分类

/** 生命周期：启动 / 拆除 / 通知 / 采音重建（两种路径） */
@interface TSAIBudsSystemAudioDriver (Lifecycle)

/** 执行器：启动租约（§6.3 q_start） */
- (void)q_startLease:(TSAIBudsAudioLease *)lease;
/** 执行器：拆除租约（不是当前使用引擎的租约时无操作） */
- (void)q_teardownLease:(TSAIBudsAudioLease *)lease;
/** 旧路径：同步启动（回退开关打开时） */
- (BOOL)legacyStartWithInputChannel:(TSAIAudioInputChannel)inputChannel
                      outputChannel:(TSAIAudioOutputChannel)outputChannel
                    pcmDataReceived:(nullable void (^)(NSData *pcmData))pcmHandler
                      errorOccurred:(nullable void (^)(NSError *error))errorHandler
                              error:(NSError * _Nullable * _Nullable)error;
/** 旧路径：同步停止 */
- (void)legacyStop;
/** 注册会话通知（异步路径额外监听打断与媒体服务重置） */
- (void)registerSessionNotifications;
/** 启动同时采音和播放的双工引擎（会话写操作；异步路径在执行器上） */
- (BOOL)startDuplexForInput:(TSAIAudioInputChannel)input
                      output:(TSAIAudioOutputChannel)output
               bufferHandler:(void (^)(AVAudioPCMBuffer *buffer))bufferHandler
                errorHandler:(void (^)(NSError *error))errorHandler
                       error:(NSError * _Nullable * _Nullable)error;
/** 启动仅播放的流式播放器 */
- (BOOL)startPlayback;
/** 跟随系统且只有听筒时改到扬声器（启动后的覆盖；停止时撤销） */
- (void)routeSystemDefaultOutputToSpeakerIfNeededForInput:(TSAIAudioInputChannel)input
                                                   output:(TSAIAudioOutputChannel)output
                                                   reason:(NSString *)reason;
/** 撤销扬声器覆盖 */
- (void)restoreSpeakerOverrideIfNeeded;

@end

/** 输出：语音别名、静默期、1001 续播（两种路径共用记账，分发方式按路径） */
@interface TSAIBudsSystemAudioDriver (Output)

/** 记账 + 投递一个分片（旧路径在调用方线程，异步路径在执行器上） */
- (void)enqueueOutputPCMData:(NSData *)pcmData
                     voiceId:(NSString *)voiceId
                     isFinal:(BOOL)isFinal
                  completion:(nullable void (^)(BOOL success, NSError * _Nullable error))completion;
/**
 * 打断的记账部分（任意线程，锁内）：voiceId 不是活动语音时返回 NO（无操作）；
 * sealPlayerVoiceId 返回需要封口的播放器语音；被放弃的终态回调放入 abandoned；
 * retireActive 为 YES 时把当前语音标为退场（之后到达的分片直接丢弃）
 */
- (BOOL)interruptOutputAccountingForVoiceId:(nullable NSString *)voiceId
                               retireActive:(BOOL)retireActive
                          sealPlayerVoiceId:(NSString * _Nullable * _Nullable)sealPlayerVoiceId
                                  abandoned:(NSMutableArray *)abandoned;
/** 打断输出（旧路径整段；异步路径在执行器上用于终态超时） */
- (void)interruptOutputForVoiceId:(nullable NSString *)voiceId;
/** 给未 final 的语音补空 final 后打断厂商播放器（厂商调用） */
- (void)sealAndInterruptPlayerVoiceId:(nullable NSString *)playerVoiceId;
/** 停止 / 拆除时清空输出记账，返回仍待回调的终态 */
- (NSArray *)resetOutputAccounting;
/** 厂商播放终态（单测入口：归属当前使用引擎的租约） */
- (void)handlePlaybackStopForPlayerVoiceId:(NSString *)playerVoiceId
                                    reason:(AIBudsPlaybackStopReason)reason
                                 startTime:(NSDate *)startTime
                                  stopTime:(NSDate *)stopTime
                                     error:(nullable NSError *)playbackError;
/** 厂商播放终态（厂商回调线程：只记账，后续调用切回执行器）；lease 为产生该回调的引擎所属租约（旧路径为 nil） */
- (void)handlePlaybackStopForPlayerVoiceId:(NSString *)playerVoiceId
                                    reason:(AIBudsPlaybackStopReason)reason
                                 startTime:(NSDate *)startTime
                                  stopTime:(NSDate *)stopTime
                                     error:(nullable NSError *)playbackError
                                     lease:(nullable TSAIBudsAudioLease *)lease;
/** 以取消终态结束一批回调（异步路径在主线程投递） */
- (void)cancelOutputCompletions:(NSArray *)completions;
/** 以指定终态错误结束一批回调（异步路径在主线程投递） */
- (void)finishOutputCompletions:(NSArray *)completions error:(NSError *)error;
/** 停止时未播完的语音的取消错误 */
- (NSError *)stoppedOutputError;
/** 投递一个播放终态：旧路径在当前线程直接回调，异步路径切到主线程（R6） */
- (void)deliverOutputCompletion:(nullable void (^)(BOOL success, NSError * _Nullable error))completion
                        success:(BOOL)success
                          error:(nullable NSError *)error;
/** 已不会再播放的语音的取消错误 */
- (NSError *)cancelledOutputError;
/** 是否已有可用的输出引擎 */
- (BOOL)hasOutputEngine;
/** 向当前输出引擎追加 PCM；仅播放链路先做增益（厂商调用） */
- (void)playerAppendPCMData:(NSData *)pcmData voiceId:(NSString *)voiceId isFinal:(BOOL)isFinal;
/** 打断输出引擎上的当前语音（厂商调用） */
- (void)playerInterrupt;

@end

/** 诊断：采音电平、分段打点、P0 验证开关 */
@interface TSAIBudsSystemAudioDriver (Diagnostics)

/** 开始一次启动的采音电平统计 */
- (void)beginCaptureLevelStats;
/** 累计采音电平；首个缓冲打印格式 */
- (void)recordCaptureLevelsForBuffer:(AVAudioPCMBuffer *)buffer convertedPCM:(nullable NSData *)pcmData;
/** 停止时打印最后一个窗口并结束统计 */
- (void)flushCaptureLevelsOnStop;
/** 记录采音输入设置 */
- (void)logCaptureInputSettings;
/** 将任意输入缓冲转换为 16 kHz 单声道 Int16LE */
- (nullable NSData *)int16PCMDataFromBuffer:(AVAudioPCMBuffer *)buffer;
/** P0-V6：采音回调进入 / 离开（记录正在执行的回调） */
- (void)noteTapEntered;
- (void)noteTapExited;
/** P0-V6：停止厂商引擎前记录是否有正在执行的采音回调 */
- (void)logTapStateBeforeEngineStopWithLabel:(NSString *)label;
/** P0-V6：采音回调里人为阻塞的毫秒数（NSUserDefaults，0 关闭） */
- (NSUInteger)diagnosticTapStallMilliseconds;
/** P0-V2 / P3 10.1：启动前决策扬声器的开关（NSUserDefaults，进程内读一次） */
+ (BOOL)prefersSpeakerAtStart;
/** 分段打点 */
- (void)markStage:(NSString *)stage lease:(nullable TSAIBudsAudioLease *)lease detail:(nullable NSString *)detail;

@end

NS_ASSUME_NONNULL_END
