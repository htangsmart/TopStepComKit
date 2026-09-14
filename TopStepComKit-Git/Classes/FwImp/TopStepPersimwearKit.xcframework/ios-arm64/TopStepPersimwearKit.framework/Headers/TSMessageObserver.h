//
//  TSMessageObserver.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/10.
//

#import <Foundation/Foundation.h>

#if __has_feature(nullability)
#pragma clang assume_nonnull begin
#endif


/**
 * @brief Common message handling class for observer pattern implementation
 * @chinese 通用消息处理类，实现观察者模式
 *
 * @discussion
 * [EN]: This class implements a custom observer pattern for handling messages with key-command pairs.
 * It supports adding/removing observers and broadcasting messages to registered observers.
 *
 * [CN]: 该类实现了一个自定义的观察者模式，用于处理基于key-command对的消息。
 * 支持添加/移除观察者，以及向注册的观察者广播消息。
 */
@interface TSMessageObserver : NSObject

/**
 * @brief Get the shared instance of TSMessageObserver
 * @chinese 获取TSMessageObserver的共享实例
 *
 * @return
 * EN: The shared instance of TSMessageObserver
 * CN: TSMessageObserver的共享实例
 */
+ (instancetype)sharedObserver;

/**
 * @brief Add an observer for a specific key and command
 * @chinese 为特定的key和命令添加观察者
 *
 * @param observe
 * EN: The observer object to be added
 * CN: 要添加的观察者对象
 *
 * @param key
 * EN: The key to observe
 * CN: 要观察的key
 *
 * @param cmd
 * EN: The command to observe
 * CN: 要观察的命令
 *
 * @param selector
 * EN: The selector to be called when the message is received
 * CN: 接收到消息时要调用的方法
 *
 * @return
 * EN: YES if the observer was added successfully, NO otherwise
 * CN: 如果观察者添加成功返回YES，否则返回NO
 */
- (BOOL)addObserver:(id)observe
                cmd:(NSString *)cmd
                key:(NSString *)key
           selector:(SEL)selector;

/**
 * @brief Remove an observer for a specific key and command
 * @chinese 移除特定key和命令的观察者
 *
 * @param observer
 * EN: The observer to be removed
 * CN: 要移除的观察者
 *
 * @param key
 * EN: The key associated with the observer
 * CN: 与观察者关联的key
 *
 * @param cmd
 * EN: The command associated with the observer
 * CN: 与观察者关联的命令
 */
- (void)removeObserver:(id)observer forCmd:(NSString *)cmd key:(NSString *)key ;

/**
 * @brief Remove all observers for a specific key and command
 * @chinese 移除特定key和命令的所有观察者
 *
 * @param key
 * EN: The key to remove observers from
 * CN: 要移除观察者的key
 *
 * @param cmd
 * EN: The command to remove observers from
 * CN: 要移除观察者的命令
 */
- (void)removeObserverForCmd:(NSString *)cmd key:(NSString *)key;

/**
 * @brief Remove all observers
 * @chinese 移除所有观察者
 */
- (void)removeAllObservers;

/**
 * @brief Remove all observations for a specific observer
 * @chinese 移除指定观察者的所有观察
 *
 * @param observer
 * EN: The observer whose all observations will be removed
 * CN: 要移除所有观察的观察者对象
 */
- (void)removeObservers:(id)observer;

/**
 * @brief Send a message with a specific key and command
 * @chinese 发送带有特定key和命令的消息
 *
 * @param key
 * EN: The key for the message
 * CN: 消息的key
 *
 * @param cmd
 * EN: The command for the message
 * CN: 消息的命令
 */
- (void)sendMessageWithCmd:(nullable NSString *)cmd key:(nullable NSString *)key param:(NSDictionary *)param;

@end

#if __has_feature(nullability)
#pragma clang assume_nonnull end
#endif
