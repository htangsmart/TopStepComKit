//
//  TSAIEarbudsMicrophoneUI.h
//  TopStepComKit-Git_Example
//
//  Created by Claude on 2026/10/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TopStepAIKit/TopStepAIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Grace period of the SDK earbuds engine, in seconds (display only)
 * @chinese SDK 耳机引擎的断开宽限期（秒），仅用于提示文案
 *
 * @discussion
 * [EN]: While the earbuds are away the SDK keeps the session in Recovering and sends silence;
 *       if they are not back in time the session ends with 1023 (AudioInputLost).
 * [CN]: 耳机离开期间 SDK 处于 Recovering 并上送静音；超时未回来则以 1023（AudioInputLost）结束。
 */
FOUNDATION_EXTERN const NSTimeInterval TSAIEarbudsReconnectGracePeriod;

/**
 * @brief Demo display helper over the SDK earbuds microphone APIs
 * @chinese 基于 SDK 耳机麦克风接口的 Demo 展示辅助
 *
 * @discussion
 * [EN]: Every decision comes from TopStepAIKit (`earbudsMicrophoneStatusForFeature:`, the two
 *       earbuds notifications and `TSAIKit` permission APIs). The Demo no longer probes
 *       AVAudioSession or captures the earbuds itself.
 * [CN]: 所有判断都来自 TopStepAIKit（`earbudsMicrophoneStatusForFeature:`、两个耳机通知与
 *       `TSAIKit` 权限接口）。Demo 不再自行探测 AVAudioSession，也不再自行采集耳机。
 */
@interface TSAIEarbudsMicrophoneUI : NSObject

/**
 * @brief Earbuds microphone status of one feature from the active Context
 * @chinese 从当前 Context 读取某功能的耳机麦克风状态
 *
 * @param feature EN: One SDK feature. CN: 单个 SDK 功能。
 * @return EN: nil when no Context is active. CN: 没有活动 Context 时为 nil。
 */
+ (nullable TSAIEarbudsMicrophoneStatus *)statusForFeature:(TSAIFeatureOptions)feature;

/**
 * @brief Whether the earbuds option can be tapped
 * @chinese 耳机选项是否可点击
 *
 * @return
 * EN: YES for Likely / Verified and for the permission states (tapping guides the user)
 * CN: Likely / Verified 以及权限相关状态（点击后引导授权）返回 YES
 */
+ (BOOL)isSelectableStatus:(nullable TSAIEarbudsMicrophoneStatus *)status;

/**
 * @brief User-facing reason when the earbuds cannot be used
 * @chinese 耳机不可用时给用户的原因
 *
 * @return EN: nil when usable or permission not determined yet. CN: 可用或尚未询问权限时为 nil。
 */
+ (nullable NSString *)unavailableReasonForStatus:(nullable TSAIEarbudsMicrophoneStatus *)status;

/**
 * @brief Short suffix for an option title, e.g. the headset name or "not connected"
 * @chinese 选项标题后缀，例如耳机名称或「未连接」
 */
+ (nullable NSString *)titleSuffixForStatus:(nullable TSAIEarbudsMicrophoneStatus *)status;

/**
 * @brief Observe status changes of one feature
 * @chinese 监听某功能的耳机麦克风状态变化
 *
 * @discussion
 * [EN]: Fires on TSAIEarbudsMicrophoneStatusDidChangeNotification, and also when the Demo's device
 *       connection snapshot changes or the App becomes active (the Context may have been replaced,
 *       in which case the SDK posts nothing).
 * [CN]: 收到 TSAIEarbudsMicrophoneStatusDidChangeNotification 时回调；Demo 的设备连接快照变化、
 *       App 回到前台时也回调（Context 可能已被替换，此时 SDK 不会发通知）。
 *
 * @param handler EN: Called on the main thread with the current status (nil without a Context). CN: 在主线程回调当前状态（没有 Context 时为 nil）。
 * @return EN: Token for removeObserver:. CN: 用于 removeObserver: 的令牌。
 */
+ (id<NSObject>)addStatusObserverForFeature:(TSAIFeatureOptions)feature
                                    handler:(void (^)(TSAIEarbudsMicrophoneStatus * _Nullable status))handler;

/**
 * @brief Observe the runtime input state of one feature (TSAIEarbudsMicrophoneInputDidChangeNotification)
 * @chinese 监听某功能运行中的耳机输入状态
 *
 * @param handler
 * EN: Called on the main thread with the state, task id and error (Lost only)
 * CN: 在主线程回调状态、任务标识与错误（仅 Lost 时有）
 * @return EN: Token for removeObserver:. CN: 用于 removeObserver: 的令牌。
 */
+ (id<NSObject>)addInputObserverForFeature:(TSAIFeatureOptions)feature
                                   handler:(void (^)(TSAIEarbudsMicrophoneInputState state,
                                                     NSString * _Nullable taskId,
                                                     NSError * _Nullable error))handler;

/**
 * @brief Stop an observer
 * @chinese 停止监听
 *
 * @param observer EN: Token; nil is ignored. CN: 令牌，nil 时忽略。
 */
+ (void)removeObserver:(nullable id<NSObject>)observer;

/**
 * @brief Whether an error comes from the SDK earbuds microphone (1021 / 1022 / 1023)
 * @chinese 错误是否来自 SDK 耳机麦克风（1021 / 1022 / 1023）
 */
+ (BOOL)isEarbudsMicrophoneError:(nullable NSError *)error;

/**
 * @brief User-facing description of an earbuds microphone error
 * @chinese 耳机麦克风错误的用户提示
 */
+ (NSString *)descriptionForEarbudsMicrophoneError:(nullable NSError *)error;

/**
 * @brief Whether the microphone permission was denied (TSAIKit)
 * @chinese 麦克风权限是否已被拒绝（TSAIKit）
 */
+ (BOOL)isMicrophonePermissionDenied;

/**
 * @brief Request the microphone permission through TSAIKit
 * @chinese 通过 TSAIKit 请求麦克风权限
 *
 * @param completion EN: Called on the main thread. CN: 在主线程回调。
 */
+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completion;

/**
 * @brief Open this App's page in the system Settings
 * @chinese 打开系统设置中的本 App 页面
 */
+ (void)openAppSettings;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
