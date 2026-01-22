//
//  TSLogPrinter.h
//  TopStepToolKit
//
//  Created by TopStep on 2024/03/14.
//  Copyright © 2024年 TopStep. All rights reserved.
//
//  Description: 日志打印管理类，负责日志的格式化打印
//  Author: TopStep
//  Version: 1.0.0
//

#import <Foundation/Foundation.h>
#import "TSLogModel.h"
#import "TSLoggerDefines.h"


// 不带 category 的便捷宏定义
#define TSLog(format, ...) [TSLogPrinter debug:format, ##__VA_ARGS__]
#define TSLogInfo(format, ...) [TSLogPrinter info:format, ##__VA_ARGS__]
#define TSLogWarning(format, ...) [TSLogPrinter warning:format, ##__VA_ARGS__]
#define TSLogError(format, ...) [TSLogPrinter error:format, ##__VA_ARGS__]


// 便捷宏定义
#define TSDebug(category, format, ...) [TSLogPrinter debug:category message:format, ##__VA_ARGS__]
#define TSInfo(category, format, ...) [TSLogPrinter info:category message:format, ##__VA_ARGS__]
#define TSWarning(category, format, ...) [TSLogPrinter warning:category message:format, ##__VA_ARGS__]
#define TSError(category, format, ...) [TSLogPrinter error:category message:format, ##__VA_ARGS__]



NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 日志打印管理类
 * @chinese 日志打印管理类
 *
 * @discussion
 * [EN]: Responsible for formatting and printing logs with different levels.
 * [CN]: 负责格式化打印不同级别的日志。
 */
@interface TSLogPrinter : NSObject

/**
 * @brief Whether logging is enabled
 * @chinese 是否启用日志打印
 */
@property (nonatomic, assign) BOOL isPrinterEnabled;

/**
 * @brief Minimum log level to print
 * @chinese 最低日志打印级别
 */
@property (nonatomic, assign) TopStepLogLevel minimumLevel;

/**
 * @brief Get the shared instance of TSLogPrinter
 * @chinese 获取 TSLogPrinter 的单例实例
 *
 * @return TSLogPrinter instance
 * @chinese 返回 TSLogPrinter 实例
 */
+ (instancetype)sharedInstance;

// 日志打印方法
+ (void)debug:(TSLogCategory)category message:(NSString *)format, ...;
+ (void)info:(TSLogCategory)category message:(NSString *)format, ...;
+ (void)warning:(TSLogCategory)category message:(NSString *)format, ...;
+ (void)error:(TSLogCategory)category message:(NSString *)format, ...;

// 不带 category 的日志打印方法
+ (void)debug:(NSString *)format, ...;
+ (void)info:(NSString *)format, ...;
+ (void)warning:(NSString *)format, ...;
+ (void)error:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END

