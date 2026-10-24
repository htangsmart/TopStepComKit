//
//  TSAIAudioRecordAppCapture.h
//  TopStepComKit-Git_Example
//
//  Created by Claude on 2026/9/21.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Error domain for App-side AI recording capture
 * @chinese App 侧 AI 录音采集错误域
 */
FOUNDATION_EXTERN NSErrorDomain const TSAIAudioRecordAppCaptureErrorDomain;

/**
 * @brief Error codes for App-side AI recording capture
 * @chinese App 侧 AI 录音采集错误码
 */
typedef NS_ENUM(NSInteger, TSAIAudioRecordAppCaptureErrorCode) {
    /// @brief Microphone permission denied @chinese 麦克风权限被拒绝
    TSAIAudioRecordAppCaptureErrorCodePermissionDenied = 1,
    /// @brief The phone microphone is not available, or was lost while capturing @chinese 手机麦克风不可用，或采集中丢失
    TSAIAudioRecordAppCaptureErrorCodeInputUnavailable = 2,
    /// @brief Active route does not use the requested input, or was switched away while capturing @chinese 当前路由未使用请求的输入，或采集中被切换
    TSAIAudioRecordAppCaptureErrorCodeRouteMismatch = 3,
    /// @brief Audio engine or format failure @chinese 音频引擎或格式异常
    TSAIAudioRecordAppCaptureErrorCodeEngineFailed = 4,
    /// @brief Capture interrupted by the system (call, media reset, engine config change) @chinese 采集被系统打断（来电、媒体服务重置、引擎配置变化）
    TSAIAudioRecordAppCaptureErrorCodeInterrupted = 5,
};

/**
 * @brief App-side phone microphone capture for AI recording (demo of App-supplied PCM)
 * @chinese AI 录音的 App 侧手机麦克风采集（演示「App 提供 PCM」接口）
 *
 * @discussion
 * [EN]: Configures AVAudioSession for the phone microphone, captures with AVAudioEngine and
 *       converts every buffer to 16 kHz mono Int16LE PCM, the only format accepted by
 *       TopStepAIKit. The earbuds microphone is captured by the SDK, not here.
 * [CN]: 为手机麦克风配置 AVAudioSession，使用 AVAudioEngine 采集，并把每个缓冲转换为
 *       TopStepAIKit 唯一接受的 16 kHz 单声道 Int16LE PCM。耳机麦克风由 SDK 采集，不在这里。
 */
@interface TSAIAudioRecordAppCapture : NSObject

/**
 * @brief Whether capture is running
 * @chinese 当前是否正在采集
 */
@property (nonatomic, assign, readonly) BOOL isRunning;

/**
 * @brief Whether captured buffers are currently dropped
 * @chinese 当前是否丢弃采集到的音频（暂停态）
 *
 * @discussion
 * [EN]: The engine keeps running so resume is instant; buffers are not delivered while paused.
 * [CN]: 引擎保持运行以便即时恢复；暂停期间不投递音频缓冲。
 */
@property (atomic, assign) BOOL isPaused;

/**
 * @brief Start capture from the phone microphone
 * @chinese 从手机麦克风开始采集
 *
 * @param pcmHandler
 * EN: Called on the audio capture thread with 16 kHz mono Int16LE PCM
 * CN: 在音频采集线程回调 16 kHz 单声道 Int16LE PCM
 *
 * @param errorHandler
 * EN: Called on the main thread once when capture stops unexpectedly
 * CN: 采集意外停止时在主线程回调一次
 *
 * @param error
 * EN: Start failure reason
 * CN: 启动失败原因
 *
 * @return
 * EN: YES after the engine is running on the phone microphone
 * CN: 引擎已在手机麦克风上运行时返回 YES
 */
- (BOOL)startWithPCMHandler:(void (^)(NSData *pcmData))pcmHandler
               errorHandler:(void (^)(NSError *error))errorHandler
                      error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Stop capture and release the audio session; safe to call repeatedly
 * @chinese 停止采集并释放音频会话，可重复调用
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
