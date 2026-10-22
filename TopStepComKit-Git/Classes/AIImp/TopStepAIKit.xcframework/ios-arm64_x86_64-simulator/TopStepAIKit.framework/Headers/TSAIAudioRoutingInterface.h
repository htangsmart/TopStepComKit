//
//  TSAIAudioRoutingInterface.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIFeatureDefines.h"

@class TSAIAudioRouteCapability;
@class TSAIAudioRouteSnapshot;
@class TSAIEarbudsMicrophoneStatus;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Main-thread callback for audio-route capability changes
 * @chinese 音频路由能力变化的主线程回调
 * @param features EN: Features whose capabilities may have changed. CN: 能力可能发生变化的功能集合。
 */
typedef void(^TSAIAudioRouteCapabilitiesDidChangeBlock)(TSAIFeatureOptions features);

/**
 * @brief Main-thread callback for an active route change
 * @chinese 活动路由变化的主线程回调
 * @param snapshot EN: Latest route snapshot. CN: 最新路由快照。
 */
typedef void(^TSAIAudioRouteDidChangeBlock)(TSAIAudioRouteSnapshot *snapshot);

/**
 * @brief Read-only audio-route discovery and observation interface
 * @chinese 只读音频路由发现与观察接口
 */
@protocol TSAIAudioRoutingInterface <NSObject>

/**
 * @brief Return complete routes supported for one AI feature
 * @chinese 返回某个 AI 功能支持的完整路由对
 * @param feature EN: Exactly one AI feature. CN: 单个 AI 功能。
 * @return EN: Stable ordered route capabilities. CN: 顺序稳定的路由能力数组。
 */
- (NSArray<TSAIAudioRouteCapability *> *)audioRouteCapabilitiesForFeature:
    (TSAIFeatureOptions)feature NS_SWIFT_NAME(audioRouteCapabilities(forFeature:));

/**
 * @brief Return the active route snapshot for one feature
 * @chinese 返回某个功能的活动路由快照
 * @param feature EN: Exactly one AI feature. CN: 单个 AI 功能。
 * @return EN: Active snapshot, or nil when idle. CN: 活动快照；空闲时为 nil。
 */
- (nullable TSAIAudioRouteSnapshot *)activeAudioRouteForFeature:
    (TSAIFeatureOptions)feature;

/**
 * @brief Register capability-change observation
 * @chinese 注册路由能力变化监听
 * @param block EN: Main-thread callback; nil unregisters it. CN: 主线程回调；传 nil 注销。
 */
- (void)registerAudioRouteCapabilitiesDidChange:
    (nullable TSAIAudioRouteCapabilitiesDidChangeBlock)block;

/**
 * @brief Register active-route observation
 * @chinese 注册活动路由变化监听
 * @param block EN: Main-thread callback; nil unregisters it. CN: 主线程回调；传 nil 注销。
 */
- (void)registerActiveAudioRouteDidChange:
    (nullable TSAIAudioRouteDidChangeBlock)block;

/**
 * @brief Return whether the earbuds microphone can currently be selected for one feature
 * @chinese 返回某功能当前能否选择耳机收音
 *
 * @param feature
 * EN: Exactly one feature: AIChat, Interpretation, DeviceVoiceTranslation, AIAudioRecording or
 *     PCMRecognition (microphone speech recognition)
 * CN: 单个功能：AIChat、Interpretation、DeviceVoiceTranslation、AIAudioRecording 或
 *     PCMRecognition（麦克风语音识别）
 *
 * @return
 * EN: Status computed without side effects; changes are posted with
 *     TSAIEarbudsMicrophoneStatusDidChangeNotification
 * CN: 零副作用计算的状态；变化通过 TSAIEarbudsMicrophoneStatusDidChangeNotification 通知
 */
- (TSAIEarbudsMicrophoneStatus *)earbudsMicrophoneStatusForFeature:(TSAIFeatureOptions)feature
    NS_SWIFT_NAME(earbudsMicrophoneStatus(forFeature:));

@optional

/**
 * @brief Whether AIKit uses no phone-microphone audio path and every teardown has finished
 * @chinese AIKit 当前是否没有在用手机麦系统音频链路，且拆除都已完成
 *
 * @discussion
 * EN: When NO, a host that configures AVAudioSession itself should wait for
 *     TSAIAudioSessionDidBecomeIdleNotification first (session completions do not wait for the teardown).
 *     The teardowns include the phone microphone and the earbuds microphone.
 * CN: 为 NO 时，宿主自行配置 AVAudioSession 前应先等待 TSAIAudioSessionDidBecomeIdleNotification
 *     （会话 completion 不等待拆除）。拆除包括手机麦与耳机麦。
 */
@property (nonatomic, assign, readonly, getter=isAudioSessionIdle) BOOL audioSessionIdle;

@end

NS_ASSUME_NONNULL_END
