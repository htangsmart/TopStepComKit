#import <Foundation/Foundation.h>

/** @brief Cloud transcription recovery policy @chinese 云端转写恢复策略 */
typedef NS_ENUM(NSUInteger, TSAIAudioRecordTranscriptionRecoveryPolicy) {
    TSAIAudioRecordTranscriptionRecoveryPolicyDisabled = 0, ///< Disabled / 不自动重建
    TSAIAudioRecordTranscriptionRecoveryPolicyRestartOnRecoverableFailure, ///< Restart / 可恢复故障后重建
};

/** @brief Transcription lifecycle, independent of capture @chinese 独立于本地录音的转写生命周期 */
typedef NS_ENUM(NSUInteger, TSAIAudioRecordTranscriptionState) {
    TSAIAudioRecordTranscriptionStateUnknown = 0, ///< Not supplied / 未提供
    TSAIAudioRecordTranscriptionStateWaitingPrerequisites, ///< Waiting / 等待前置条件
    TSAIAudioRecordTranscriptionStateStarting, ///< Starting / 启动中
    TSAIAudioRecordTranscriptionStateAwaitingResults, ///< Awaiting evidence / 等待识别结果
    TSAIAudioRecordTranscriptionStateRecognizing, ///< Recognizing / 识别中
    TSAIAudioRecordTranscriptionStateStoppingSegment, ///< Retiring / 结束旧识别段
    TSAIAudioRecordTranscriptionStateBackoff, ///< Retry delay / 等待有限重试
    TSAIAudioRecordTranscriptionStateBlocked, ///< Blocked / 识别暂不可用
    TSAIAudioRecordTranscriptionStateClosed, ///< Capture ended / 录音恢复调度已关闭
};

/** @brief Transcription state reason @chinese 转写状态原因 */
typedef NS_ENUM(NSUInteger, TSAIAudioRecordTranscriptionReason) {
    TSAIAudioRecordTranscriptionReasonNone = 0, ///< No failure / 无故障
    TSAIAudioRecordTranscriptionReasonOffline, ///< Offline / 网络离线
    TSAIAudioRecordTranscriptionReasonAuthorizationPending, ///< Authorization / 等待鉴权
    TSAIAudioRecordTranscriptionReasonResourceBusy, ///< Resource busy / 等待识别资源
    TSAIAudioRecordTranscriptionReasonTransientFailure, ///< Transient failure / 可恢复故障
    TSAIAudioRecordTranscriptionReasonReleaseUnconfirmed, ///< Release unconfirmed / 旧资源释放未确认
    TSAIAudioRecordTranscriptionReasonRetryExhausted, ///< Retry exhausted / 重试预算耗尽
    TSAIAudioRecordTranscriptionReasonFatalFailure, ///< Non-retryable / 不可自动重试
};
