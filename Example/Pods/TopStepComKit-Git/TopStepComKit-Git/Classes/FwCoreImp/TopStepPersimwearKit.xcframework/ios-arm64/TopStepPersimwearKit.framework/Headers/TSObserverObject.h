//
//  TSObserverObject.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSObserverObject : NSObject

/**
 * @brief Observer object reference
 * @chinese 观察者对象引用
 *
 * @discussion
 * [EN]: Weak reference to avoid retain cycles
 * [CN]: 使用弱引用避免循环引用
 */
@property (nonatomic,weak) id  observer;

/**
 * @brief Selector to be called on observer
 * @chinese 在观察者上调用的选择器
 *
 * @discussion
 * [EN]: Method that will be called when notification is received
 * [CN]: 接收到通知时将被调用的方法
 */
@property (nonatomic,assign) SEL selector;

@end

NS_ASSUME_NONNULL_END
