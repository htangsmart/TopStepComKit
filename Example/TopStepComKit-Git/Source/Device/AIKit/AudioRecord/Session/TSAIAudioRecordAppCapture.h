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
 * @brief Microphone used by App-side capture
 * @chinese App 侧采集使用的麦克风
 */
typedef NS_ENUM(NSInteger, TSAIAudioRecordAppCaptureInput) {
    /// @brief Phone built-in microphone @chinese 手机内置麦克风
    TSAIAudioRecordAppCaptureInputPhoneMicrophone = 0,
    /// @brief Bluetooth HFP headset microphone @chinese 蓝牙耳机（HFP）麦克风
    TSAIAudioRecordAppCaptureInputBluetoothHeadset,
};

/**
 * @brief Error codes for App-side AI recording capture
 * @chinese App 侧 AI 录音采集错误码
 */
typedef NS_ENUM(NSInteger, TSAIAudioRecordAppCaptureErrorCode) {
    /// @brief Microphone permission denied @chinese 麦克风权限被拒绝
    TSAIAudioRecordAppCaptureErrorCodePermissionDenied = 1,
    /// @brief Requested input is not available @chinese 请求的输入不可用
    TSAIAudioRecordAppCaptureErrorCodeInputUnavailable = 2,
    /// @brief Active route does not use the requested input @chinese 当前路由未使用请求的输入
    TSAIAudioRecordAppCaptureErrorCodeRouteMismatch = 3,
    /// @brief Audio engine or format failure @chinese 音频引擎或格式异常
    TSAIAudioRecordAppCaptureErrorCodeEngineFailed = 4,
    /// @brief Capture interrupted by the system or route loss @chinese 采集被系统打断或输入设备断开
    TSAIAudioRecordAppCaptureErrorCodeInterrupted = 5,
};

/**
 * @brief App-side microphone capture for AI recording
 * @chinese AI 录音的 App 侧麦克风采集
 *
 * @discussion
 * [EN]: Configures AVAudioSession for the requested microphone, captures with
 *       AVAudioEngine and converts every buffer to 16 kHz mono Int16LE PCM, the
 *       only format accepted by TopStepAIKit.
 * [CN]: 按所选麦克风配置 AVAudioSession，使用 AVAudioEngine 采集，并把每个缓冲
 *       转换为 TopStepAIKit 唯一接受的 16 kHz 单声道 Int16LE PCM。
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
 * @brief Whether microphone permission was explicitly denied
 * @chinese 麦克风权限是否已被明确拒绝
 *
 * @return
 * EN: YES when the user denied access; NO when granted or not asked yet
 * CN: 用户已拒绝时返回 YES；已授权或尚未询问时返回 NO
 */
+ (BOOL)isRecordPermissionDenied;

/**
 * @brief Request microphone permission
 * @chinese 请求麦克风权限
 *
 * @param completion
 * EN: Called on the main thread with the result
 * CN: 在主线程回调授权结果
 */
+ (void)requestRecordPermission:(void (^)(BOOL granted))completion;

/**
 * @brief Whether a Bluetooth HFP microphone is currently available
 * @chinese 当前是否有可用的蓝牙耳机（HFP）麦克风
 *
 * @return
 * EN: YES when AVAudioSession lists a Bluetooth HFP input
 * CN: AVAudioSession 可用输入中存在蓝牙 HFP 时返回 YES
 *
 * @discussion
 * [EN]: Call on the main thread while no capture is running. The audio session
 *       category is temporarily switched to list inputs and then restored.
 * [CN]: 需在主线程且未采集时调用。会临时切换音频会话类别以列出输入，随后恢复。
 */
+ (BOOL)isBluetoothHeadsetInputAvailable;

/**
 * @brief Start capture from one microphone
 * @chinese 从指定麦克风开始采集
 *
 * @param input
 * EN: Microphone to capture from
 * CN: 需要采集的麦克风
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
 * EN: YES after the engine is running on the requested input
 * CN: 引擎已在所选输入上运行时返回 YES
 */
- (BOOL)startWithInput:(TSAIAudioRecordAppCaptureInput)input
            pcmHandler:(void (^)(NSData *pcmData))pcmHandler
          errorHandler:(void (^)(NSError *error))errorHandler
                 error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Stop capture and release the audio session; safe to call repeatedly
 * @chinese 停止采集并释放音频会话，可重复调用
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
