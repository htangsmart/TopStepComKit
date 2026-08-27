//
//  TSAIBudsSessionStore.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Context-owned AIBuds session store
 * @chinese Context 独立持有的 AIBuds 会话存储
 */
@interface TSAIBudsSessionStore : NSObject

/**
 * @brief Create an independent session store
 * @chinese 创建独立的会话存储
 *
 * @return
 * EN: A new session store
 * CN: 新的会话存储
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 * @brief Register a session object
 * @chinese 注册一个会话对象
 *
 * @param session
 * EN: Session object retained by the store
 * CN: 由会话存储持有的会话对象
 *
 * @param taskId
 * EN: Client-side task identifier
 * CN: 客户端任务标识
 *
 * @param type
 * EN: Session type, such as chat/asr/interpreter
 * CN: 会话类型，例如 chat/asr/interpreter
 */
- (void)registerSession:(id)session taskId:(NSString *)taskId type:(NSString *)type;

/**
 * @brief Fetch a registered session
 * @chinese 获取已注册会话
 *
 * @param taskId
 * EN: Client-side task identifier
 * CN: 客户端任务标识
 *
 * @return
 * EN: Registered session object, or nil
 * CN: 已注册会话对象，不存在时为 nil
 */
- (nullable id)sessionForTaskId:(NSString *)taskId;

/**
 * @brief Unregister a session
 * @chinese 注销一个会话
 *
 * @param taskId
 * EN: Client-side task identifier
 * CN: 客户端任务标识
 */
- (void)unregisterSessionForTaskId:(NSString *)taskId;

/**
 * @brief Remove all registered sessions
 * @chinese 移除全部已注册会话
 */
- (void)unregisterAllSessions;

/**
 * @brief Active task identifiers
 * @chinese 当前活跃任务标识列表
 *
 * @return
 * EN: Active task identifiers
 * CN: 当前活跃任务标识列表
 */
- (NSArray<NSString *> *)activeTaskIds;

@end

NS_ASSUME_NONNULL_END
