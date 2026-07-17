//
//  TSMethodInvoker.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/4/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief 方法调用工具类
 * @chinese 方法调用工具类
 *
 * @discussion
 * [EN]: A utility class for method invocation with multiple strategies:
 * 1. Standard: Safe invocation using NSInvocation, with type checking and error handling
 * 2. Runtime: Direct invocation using method IMP, with basic error handling
 * 3. Fast: High-performance invocation using objc_msgSend, with minimal safety checks
 *
 * [CN]: 方法调用工具类，提供多种调用策略：
 * 1. 标准：使用NSInvocation的安全调用，具有类型检查和错误处理
 * 2. Runtime：使用方法IMP的直接调用，具有基本错误处理
 * 3. 快速：使用objc_msgSend的高性能调用，仅有最低限度的安全检查
 */
@interface TSMethodInvoker : NSObject

/**
 * @brief 执行实例方法
 * @discussion 该方法负责安全地执行实例方法，包括：
 * 1. 检查方法是否存在
 * 2. 使用runtime执行方法并传递参数
 * 3. 记录执行日志
 */
+ (void)invokeMethodDirectly:(id)instance
                  methodName:(NSString *)methodName
                      params:(id)params
                   className:(NSString *)className ;



+ (void)invokeMethod:(id)instance
          methodName:(NSString *)methodName
              params:(id)params
           className:(NSString *)className;

/**
 * @brief 执行实例方法 - 使用Runtime直接调用
 * @discussion 该方法负责安全地执行实例方法，包括：
 * 1. 检查方法是否存在
 * 2. 使用objc_msgSend直接调用方法
 * 3. 记录执行日志
 */
+ (void)invokeMethodWithRuntime:(id)instance
                     methodName:(NSString *)methodName
                         params:(id)params
                      className:(NSString *)className;



/**
 * @brief 执行实例方法 - 直接使用objc_msgSend
 * @discussion 这是最高效但也最危险的方法调用方式：
 * 1. 直接使用objc_msgSend
 * 2. 不进行类型检查，需要调用者确保类型安全
 * 3. 不处理异常
 */
+ (void)invokeMethodFast:(id)instance
              methodName:(NSString *)methodName
                  params:(id)params
               className:(NSString *)className;



@end

NS_ASSUME_NONNULL_END
