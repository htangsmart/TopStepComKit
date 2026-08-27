//
//  TSAIAudioRecordSessionCoordinator.h
//  TopStepComKit-Git_Example
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRecordSessionState.h"

@class TSAIAudioRecordConfig;
@class TSAIAudioRecordDraft;
@class TSAIContext;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSNotificationName const TSAIAudioRecordSessionDidRequestPresentationNotification;
FOUNDATION_EXTERN NSNotificationName const TSAIAudioRecordSessionDidChangeNotification;
FOUNDATION_EXTERN NSNotificationName const TSAIAudioRecordSessionDidReceiveResultNotification;
FOUNDATION_EXTERN NSNotificationName const TSAIAudioRecordSessionDidCompleteNotification;

FOUNDATION_EXTERN NSString * const TSAIAudioRecordSessionStateUserInfoKey;
FOUNDATION_EXTERN NSString * const TSAIAudioRecordSessionDraftUserInfoKey;
FOUNDATION_EXTERN NSString * const TSAIAudioRecordSessionErrorUserInfoKey;
FOUNDATION_EXTERN NSString * const TSAIAudioRecordSessionAudioLevelUserInfoKey;

/// @brief Process-wide coordinator for App- and device-initiated AI audio recording.
/// @chinese App 与设备发起的 AI 录音进程级协调器。
@interface TSAIAudioRecordSessionCoordinator : NSObject <NSCopying, NSMutableCopying>

/// @brief Returns the shared recording coordinator.
/// @chinese 返回共享录音协调器。
+ (instancetype)sharedInstance;

/// @brief Snapshot of the current session state.
/// @chinese 当前会话状态快照。
@property (nonatomic, strong, readonly) TSAIAudioRecordSessionState *sessionState;

/// @brief Current in-memory recording draft.
/// @chinese 当前内存录音草稿。
@property (nonatomic, strong, nullable, readonly) TSAIAudioRecordDraft *currentDraft;

/// @brief Configuration used by the next device-initiated request.
/// @chinese 下一次设备发起请求使用的配置。
@property (nonatomic, strong, readonly) TSAIAudioRecordConfig *preferredConfig;

/// @brief Latest recording or persistence error.
/// @chinese 最近一次录音或持久化错误。
@property (nonatomic, strong, nullable, readonly) NSError *lastError;

/// @brief Binds an active AI context and registers device callbacks.
/// @chinese 绑定已激活 AI Context，并注册设备回调。
/// @param context Active context. / 已激活的 Context。
- (void)bindActiveContext:(TSAIContext *)context;

/// @brief Unbinds a context that is no longer usable.
/// @chinese 解绑已不可用的 Context。
/// @param context Context to unbind. / 要解绑的 Context。
- (void)unbindContext:(TSAIContext *)context;

/// @brief Updates the configuration used by the next device request.
/// @chinese 更新下一次设备请求使用的配置。
/// @param config Preferred recording configuration. / 首选录音配置。
- (void)updatePreferredConfig:(TSAIAudioRecordConfig *)config;

/// @brief Starts an App-initiated AI recording session.
/// @chinese 启动 App 发起的 AI 录音会话。
/// @param config Recording configuration. / 录音配置。
/// @param completion Start result callback. / 启动结果回调。
- (void)startRecordingWithConfig:(TSAIAudioRecordConfig *)config
                      completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

/// @brief Requests the current recording session to stop.
/// @chinese 请求停止当前录音会话。
- (void)stopRecording;

/// @brief Clears a terminal result and returns the Demo to its ready state.
/// @chinese 清除终态结果并让 Demo 返回准备状态。
- (void)prepareForNewSession;

/// @brief Returns whether the specified recording scene is currently available.
/// @chinese 返回当前是否支持指定录音场景。
/// @param scene Recording scene. / 录音场景。
/// @return YES when the context and scene capability are available. / Context 与场景能力可用时返回 YES。
- (BOOL)isRecordingAvailableForScene:(TSAIAudioRecordScene)scene;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
