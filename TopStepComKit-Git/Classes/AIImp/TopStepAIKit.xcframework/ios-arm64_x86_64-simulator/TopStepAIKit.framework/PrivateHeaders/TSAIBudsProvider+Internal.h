//
//  TSAIBudsProvider+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import "TSAIBudsProvider.h"

@class AIBudsAIDeviceInfoModel;
@class TSAIBudsManager;
@class TSAIBudsSessionStore;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal Context-owned dependencies of the AIBuds root Provider
 * @chinese AIBuds 根 Provider 的 Context 级内部依赖
 */
@interface TSAIBudsProvider (Internal)

/**
 * @brief Manager owned by this root Provider
 * @chinese 当前根 Provider 独立持有的管理器
 */
@property (nonatomic, strong, readonly) TSAIBudsManager *manager;

/**
 * @brief Session store owned by this root Provider
 * @chinese 当前根 Provider 独立持有的会话存储
 */
@property (nonatomic, strong, readonly) TSAIBudsSessionStore *sessionStore;

/**
 * @brief Device bridge owned by this root Provider during its lifecycle
 * @chinese 当前根 Provider 生命周期内持有的设备桥接器
 */
@property (nonatomic, strong, readonly, nullable) id<TSAIDeviceBridge> deviceBridge;

/**
 * @brief Create a root Provider with isolated dependencies
 * @chinese 使用隔离依赖创建根 Provider
 *
 * @param manager EN: Context-owned AIBuds manager. CN: Context 独立持有的 AIBuds 管理器。
 * @param sessionStore EN: Context-owned session store. CN: Context 独立持有的会话存储。
 *
 * @return EN: A new root Provider. CN: 新的根 Provider。
 */
- (instancetype)initWithManager:(TSAIBudsManager *)manager
                   sessionStore:(TSAIBudsSessionStore *)sessionStore;

/**
 * @brief Authenticate the AIBuds AI service for the current Context
 * @chinese 为当前 Context 鉴权 AIBuds AI 服务
 *
 * @param deviceInfo
 * EN: AIBuds AI device information
 * CN: AIBuds AI 设备信息
 *
 * @param completion
 * EN: Completion called after the authentication check finishes
 * CN: 鉴权检查完成后的回调
 */
- (void)authenticateWithDeviceInfo:(AIBudsAIDeviceInfoModel *)deviceInfo
                        completion:(nullable TSAICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
