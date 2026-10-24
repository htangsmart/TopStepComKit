//
//  TSAISpeechDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIASRDeviceMicResult.h"
#import "TSAIASRPartialResult.h"
#import "TSAIASRResult.h"
#import "TSAITTSResult.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSAITTSCompletionBlock)(TSAITTSResult * _Nullable result,
                                      NSError * _Nullable error);
typedef void(^TSAIASRPartialBlock)(TSAIASRPartialResult *partial);
typedef void(^TSAIASRCompletionBlock)(TSAIASRResult * _Nullable result,
                                      NSError * _Nullable error);
typedef void(^TSAIASRDeviceMicCompletionBlock)(TSAIASRDeviceMicResult * _Nullable result,
                                               NSError * _Nullable error);

typedef NS_ENUM(NSInteger, TSAIDeviceMicRecognitionState) {
    TSAIDeviceMicRecognitionStateDeviceStopped = 0,
    TSAIDeviceMicRecognitionStateStarted = 1,
    TSAIDeviceMicRecognitionStateEnded = 2,
    TSAIDeviceMicRecognitionStateFailure = 255,
};

typedef NS_ENUM(NSInteger, TSAISpeechRecognitionMode) {
    TSAISpeechRecognitionModeOff = 0,
    TSAISpeechRecognitionModeOn = 1,
};

typedef void(^TSAIDeviceMicRecognitionStateBlock)(TSAIDeviceMicRecognitionState state);

/**
 * @brief State of a microphone speech recognition task
 * @chinese 麦克风语音识别任务的状态
 */
typedef NS_ENUM(NSInteger, TSAIASRMicrophoneState) {
    /// Opening the microphone (the earbuds take 0.5–2 s) / 正在打开麦克风（耳机需要 0.5～2 秒）
    TSAIASRMicrophoneStateConnecting = 0,
    /// Recording; the user can speak now / 正在录音，可以开始说话
    TSAIASRMicrophoneStateReady = 1,
    /// The earbuds left; waiting for them to come back / 耳机离开，等待恢复
    TSAIASRMicrophoneStateRecovering = 2,
    /// Recording stopped; recognizing the recorded speech / 录音已停止，正在识别
    TSAIASRMicrophoneStateRecognizing = 3,
};

/**
 * @brief Main-thread state callback of microphone speech recognition
 * @chinese 麦克风语音识别的状态回调（主线程）
 */
typedef void(^TSAIASRMicrophoneStateBlock)(NSString *taskId, TSAIASRMicrophoneState state);
typedef void(^TSAISpeechBoolResultBlock)(BOOL success, BOOL result, NSError * _Nullable error);

NS_ASSUME_NONNULL_END
