//
//  TSAIAudioSessionDiagnostics+Internal.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Audio session diagnostics for the earbuds-microphone measurements (phase 0)
 * @chinese 音频会话诊断：记录会话配置与路由变化，并在关键调用点打标记（耳机拾音第 0 期测量用）
 *
 * @discussion
 * EN: Logging only; never changes the audio session. Every line starts with
 *     `[TSAIAudioDiag]` and carries a sequence number, the time since the first
 *     diagnostic event, the event name, an optional detail and a snapshot of
 *     category / mode / options / sample rate / IO buffer / channels / inputs /
 *     outputs / available inputs / preferred input. Besides explicit marks it
 *     logs route changes, interruptions, media-services loss / reset, secondary
 *     audio hints and configuration changes of every AVAudioEngine in the process.
 * CN: 只记录日志，不修改音频会话。每行以 `[TSAIAudioDiag]` 开头，带序号、距首个诊断事件的时间、
 *     事件名、可选附加信息，以及类别 / 模式 / 选项 / 采样率 / IO 缓冲 / 声道 / 输入 / 输出 /
 *     可用输入 / 首选输入的快照。除调用点标记外，还记录路由变化、系统打断、媒体服务丢失与重置、
 *     其他音频提示，以及进程内所有 AVAudioEngine 的配置变化。
 *     线程：调用方线程只同步记录序号、事件名与时间；会话快照只在音频会话执行器上采集——
 *     已在执行器上时内联，否则随后异步采集并注明采集时刻（同一 seq 的第二行），主线程不读会话。
 */
@interface TSAIAudioSessionDiagnostics : NSObject

/**
 * @brief Start observing audio session notifications (idempotent)
 * @chinese 开始监听音频会话通知（幂等）
 */
+ (void)startObserving;

/**
 * @brief Log a session snapshot at a call site
 * @chinese 在调用点记录一次会话快照
 *
 * @param event
 * EN: Short dotted event name, e.g. vendor.chat.start.begin
 * CN: 点分隔的事件名，如 vendor.chat.start.begin
 *
 * @param detail
 * EN: Optional free-form detail
 * CN: 可选的附加信息
 */
+ (void)markEvent:(NSString *)event detail:(nullable NSString *)detail;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
