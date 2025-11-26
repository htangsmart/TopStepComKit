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
 * 注册通知监听（Manager 强引用 request）
 * 
 * 注意：由于 request 在 TSCommand.registerNotifyCommand 内部创建，
 * 没有外部持有者，Manager 必须强引用保活。
 * 
 * 使用后必须调用 removeObserverWithCommand:key: 清理，避免内存泄漏。
 */
- (void)registerNotifyRequest:(TSCommandRequest *)request;

/**
 * 移除指定 cmd+key 的所有监听者
 * 
 * 释放 request 及其持有的 block，避免内存泄漏。
 * 必须在不再需要监听时调用（通常在 dealloc 中）。
 */
- (void)removeNotifyRequestWithCommand:(TSRequestCommand)command key:(UInt8)key;

/**
 * 移除单个 request 监听者
 * 
 * 一般不需要使用，推荐使用 removeNotifyRequestWithCommand:key:
 */
- (void)removeNotifyRequest:(TSCommandRequest *)request;


@end

NS_ASSUME_NONNULL_END
