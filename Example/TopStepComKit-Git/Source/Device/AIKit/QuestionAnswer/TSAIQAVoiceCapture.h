//
//  TSAIQAVoiceCapture.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TopStepAIKit/TopStepAIKit.h>

#import "TSAIQATextRound.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief State of one App-side voice question capture
 * @chinese App 侧语音提问采集的状态
 */
typedef NS_ENUM(NSInteger, TSAIQAVoiceCaptureState) {
    /// 空闲
    TSAIQAVoiceCaptureStateIdle = 0,
    /// SDK 正在打开麦克风或正在录音（见 isWaitingForMicrophone）
    TSAIQAVoiceCaptureStateListening,
    /// 录音结束，SDK 正在识别
    TSAIQAVoiceCaptureStateRecognizing,
};

@class TSAIQAVoiceCapture;

/**
 * @brief Delegate of the App-side voice capture; all callbacks on the main thread
 * @chinese App 侧语音采集的代理；全部在主线程回调
 */
@protocol TSAIQAVoiceCaptureDelegate <NSObject>

/**
 * @brief State changed
 * @chinese 状态变化
 *
 * @param capture EN: The capture. CN: 采集对象。
 * @param state EN: New state. CN: 新状态。
 */
- (void)voiceCapture:(TSAIQAVoiceCapture *)capture didChangeState:(TSAIQAVoiceCaptureState)state;

/**
 * @brief Cumulative partial recognition text
 * @chinese 累计的中间识别文本
 *
 * @param capture EN: The capture. CN: 采集对象。
 * @param text EN: Cumulative text so far. CN: 到目前为止的累计文本。
 */
- (void)voiceCapture:(TSAIQAVoiceCapture *)capture didUpdatePartialText:(NSString *)text;

/**
 * @brief Recognition finished
 * @chinese 识别结束
 *
 * @param capture EN: The capture. CN: 采集对象。
 * @param text EN: Final question text; nil on failure. CN: 最终问题文本；失败时为 nil。
 * @param voiceDuration EN: Captured seconds. CN: 采集秒数。
 * @param error EN: Failure reason; nil on success. CN: 失败原因；成功时为 nil。
 */
- (void)voiceCapture:(TSAIQAVoiceCapture *)capture
   didFinishWithText:(nullable NSString *)text
       voiceDuration:(NSTimeInterval)voiceDuration
               error:(nullable NSError *)error;

/**
 * @brief A log line worth showing in the page log
 * @chinese 值得写入页面日志的一行
 *
 * @param capture EN: The capture. CN: 采集对象。
 * @param line EN: Log text. CN: 日志文本。
 */
- (void)voiceCapture:(TSAIQAVoiceCapture *)capture didAppendLog:(NSString *)line;

@end

/**
 * @brief Phone / earbuds microphone recognition through `recognizeSpeechWithMicrophoneConfig:`
 * @chinese 通过 `recognizeSpeechWithMicrophoneConfig:` 用手机麦或耳机麦识别
 *
 * @discussion
 * [EN]: No device coordination: the SDK opens the phone or earbuds microphone, records until
 *       `finish` (or its maximum duration) and recognizes the whole segment. The text is returned
 *       to the owner, who submits it to `askQuestion:`. No partial text in v1.
 * [CN]: 不涉及设备协同：SDK 打开手机麦或耳机麦录音，`finish`（或到达最长时长）后整段识别；
 *       识别文本交回持有者提交 `askQuestion:`。第一版没有中间结果。
 */
@interface TSAIQAVoiceCapture : NSObject

/**
 * @brief Delegate
 * @chinese 代理
 */
@property (nonatomic, weak, nullable) id<TSAIQAVoiceCaptureDelegate> delegate;

/**
 * @brief Current state
 * @chinese 当前状态
 */
@property (nonatomic, assign, readonly) TSAIQAVoiceCaptureState state;

/**
 * @brief Recognition language; defaults to Auto
 * @chinese 识别语言；默认 Auto
 */
@property (nonatomic, assign) TSAILanguage language;

/**
 * @brief Speech interface used for recognition and cancellation
 * @chinese 用于识别与取消的 Speech 接口
 */
@property (nonatomic, strong, nullable) id<TSAISpeechInterface> speech;

/**
 * @brief Seconds recorded so far, counted from Ready (live while listening)
 * @chinese 从 Ready 起已录的秒数（拾音中实时变化）
 */
@property (nonatomic, assign, readonly) NSTimeInterval capturedDuration;

/**
 * @brief Whether the SDK is still opening the microphone or waiting for the earbuds to return
 * @chinese SDK 是否仍在打开麦克风，或在等待耳机回来
 *
 * @discussion
 * [EN]: YES during Connecting / Recovering; speech is not recorded yet, so the UI asks the user to wait.
 * [CN]: Connecting / Recovering 期间为 YES；此时还不录音，界面提示稍等。
 */
@property (nonatomic, assign, readonly, getter=isWaitingForMicrophone) BOOL waitingForMicrophone;

/**
 * @brief Start recording from a microphone through the SDK
 * @chinese 通过 SDK 从指定麦克风开始录音
 *
 * @param source EN: PhoneMic or Headset. CN: 手机麦克风或蓝牙耳机。
 * @param error EN: Start failure. CN: 启动失败原因。
 *
 * @return
 * EN: YES when the SDK task was created (open failures arrive through the delegate)
 * CN: SDK 任务已创建时返回 YES（打开失败经代理回调）
 */
- (BOOL)startWithSource:(TSAIQARoundSource)source error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Stop recording; the SDK recognizes what was recorded
 * @chinese 停止录音，由 SDK 识别已录内容
 */
- (void)finish;

/**
 * @brief Cancel capture or recognition; the delegate receives a cancellation error
 * @chinese 取消采集或识别；代理收到取消错误
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
