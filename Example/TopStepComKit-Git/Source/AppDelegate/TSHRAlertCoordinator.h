//
//  TSHRAlertCoordinator.h
//  TopStepComKit_Example
//

#import <Foundation/Foundation.h>

@class TSHRAlertModel;

NS_ASSUME_NONNULL_BEGIN

/** @brief Listener or latest alert changed on the main thread. @chinese 监听状态或最近告警更新，主线程发送。 */
FOUNDATION_EXTERN NSNotificationName const TSHRAlertCoordinatorDidUpdateNotification;

/** @brief App-owned heart rate listener state. @chinese App 管理的心率告警监听状态。 */
typedef NS_ENUM(NSInteger, TSHRAlertListenerStatus) {
    TSHRAlertListenerStatusWaitingForDevice = 0, ///< Waiting for a ready device / 等待设备就绪
    TSHRAlertListenerStatusNotSupported,         ///< Alert delivery unavailable / 暂不支持告警回调
    TSHRAlertListenerStatusListening,            ///< Listener registered / 已注册监听
    TSHRAlertListenerStatusFailed               ///< Listener reported an error / 监听发生错误
};

/**
 * @brief Owns the Demo alert listener, foreground dialogs and local notifications.
 * @chinese 管理 Demo 全局告警监听、前台弹窗与本地通知，独立于页面生命周期。
 * @discussion Read state on the main thread. / 在主线程读取状态。
 */
@interface TSHRAlertCoordinator : NSObject

/**
 * @brief Return the shared App coordinator.
 * @chinese 返回 App 共享协调器。
 * @return Shared coordinator / 共享协调器。
 */
+ (instancetype)sharedInstance;

/** @brief Current listener status. @chinese 当前监听状态。 */
@property (nonatomic, assign, readonly) TSHRAlertListenerStatus listenerStatus;

/** @brief Latest alert in the current device session. @chinese 当前设备会话最近收到的告警。 */
@property (nonatomic, strong, readonly, nullable) TSHRAlertModel *latestAlert;

/** @brief Latest listener error, if any. @chinese 最近一次监听错误，无错误时为 nil。 */
@property (nonatomic, strong, readonly, nullable) NSError *listenerError;

/**
 * @brief Start observing device readiness once; automatically register for each ready session.
 * @chinese 启动设备就绪观察，每次设备会话就绪后自动注册；重复调用不会重复观察。
 */
- (void)start;

/**
 * @brief Localized title shared by alerts and notifications.
 * @chinese 弹窗和通知共用的本地化标题。
 * @param alert Device alert / 设备告警。
 * @return Localized title / 本地化标题。
 */
+ (NSString *)titleForAlert:(TSHRAlertModel *)alert;

/**
 * @brief Format the device event without inferring a missing mode, direction or threshold.
 * @chinese 根据设备事件组织提示，不推断缺失的模式、方向或阈值。
 * @param alert Device alert / 设备告警。
 * @return Localized message / 本地化正文。
 */
+ (NSString *)messageForAlert:(TSHRAlertModel *)alert;

@end

NS_ASSUME_NONNULL_END
