//
//  TSRequestNotifyManager.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/24.
//

#import "TSCommandBase.h"
#import "TSCommandRequest.h"
#import "TSPackageHandleInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSRequestNotifyManager : TSCommandBase <TSPackageHandleInterface>

//获取单例实例
+ (instancetype _Nonnull )sharedManager;

/**
 * 添加通知监听器（参照 KVO 设计，addObserver 风格）
 * 
 * @param notifier 监听对象，通过其类名作为唯一标识符
 * @param request 请求对象
 * 
 * @discussion
 * EN: Adds a notification listener for the specified request.
 *     The notifier's class name is used as the unique identifier.
 *     If the same notifier registers again, the previous registration will be replaced.
 * CN: 为指定的请求添加通知监听器。
 *     notifier 的类名用作唯一标识符。
 *     如果同一个 notifier 再次注册，将替换之前的注册。
 * 
 * @note
 * EN: Since request is created internally in TSCommand.addRequestNotify,
 *     Manager must use strong reference to keep it alive.
 *     Must call removeNotifyForNotifier:command:key: when done to avoid memory leaks.
 * CN: 由于 request 在 TSCommand.addRequestNotify 内部创建，
 *     Manager 必须使用强引用保活。
 *     使用后必须调用 removeNotifyForNotifier:command:key: 清理，避免内存泄漏。
 */
- (void)addNotifier:(id)notifier request:(TSCommandRequest *)request;

/**
 * 移除指定 cmd+key 的所有监听者
 * 
 * 释放 request 及其持有的 block，避免内存泄漏。
 * 必须在不再需要监听时调用（通常在 dealloc 中）。
 */
- (void)removeNotifyRequestWithCommand:(TSRequestCommand)command key:(UInt8)key;

/**
 * 移除指定 notifier 的监听（通过类名标识）
 * 
 * @param notifier 监听对象
 * @param command 命令类型
 * @param key 子命令键
 */
- (void)removeNotifyForNotifier:(id)notifier command:(TSRequestCommand)command key:(UInt8)key;


@end

NS_ASSUME_NONNULL_END
