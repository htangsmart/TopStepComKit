//
//  TSAIAppLifecycle+Internal.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// App 回到前台（变为活跃）时发出的内部通知（主线程）
FOUNDATION_EXPORT NSNotificationName const TSAIAppLifecycleDidBecomeActiveNotification;

/**
 * @brief Foreground / background tracking without linking UIKit
 * @chinese 不依赖 UIKit 的前后台跟踪
 *
 * @discussion
 * EN: Observes UIApplication notifications by name. Assumes foreground until the first
 *     background notification (the SDK is started from UI).
 * CN: 按名称监听 UIApplication 通知；收到第一次进入后台通知之前按前台处理（SDK 由界面启动）。
 */
@interface TSAIAppLifecycle : NSObject

/** @brief Whether the App is in the background @chinese App 是否在后台 */
@property (atomic, assign, readonly, getter=isInBackground) BOOL inBackground;

/** @brief Shared tracker; starts observing on first use @chinese 共享实例，首次使用时开始监听 */
+ (instancetype)sharedLifecycle;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
