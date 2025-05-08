//
//  TSLogger.h
//  TopStepToolKit
//
//  Created by TopStep on 2024/03/14.
//  Copyright © 2024年 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLogModel.h"
#import "TSLoggerDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TSLoggerDelegate <NSObject>

- (void)logger:(id)logger didCreateLog:(TSLogModel *)logModel;

@end

@interface TSLogger : NSObject

@property (nonatomic, weak) id<TSLoggerDelegate> delegate;
@property (nonatomic, assign) BOOL isEnabled;           // 是否启用日志
@property (nonatomic, assign) TSLogLevel minimumLevel;  // 最低日志级别



/**
 * 日志存储开关
 * YES: 保存所有日志
 * NO: 不保存日志
 * 默认值：NO
 */
@property (nonatomic, assign) BOOL saveLogsEnabled;

/**
 * 是否仅在调试模式下保存日志
 * YES: 仅在连接 Xcode 时保存日志
 * NO: 根据 saveLogsEnabled 的值决定是否保存
 * 默认值：YES
 */
@property (nonatomic, assign) BOOL saveLogsOnlyInDebug;

/**
 * 配置日志系统
 * @param enabled 是否启用日志
 * @param saveEnabled 是否保存日志
 * @param saveOnlyInDebug 是否仅在调试模式下保存
 * @param storageType 存储类型（控制台/文件/服务器）
 * @param encryption 是否启用加密
 * @param maxSize 单个日志文件最大大小(MB)
 * @param retentionDays 日志保留天数
 * @param directory 自定义日志存储目录路径（可选，传nil则使用默认路径）
 * @return BOOL 配置是否成功
 */
- (BOOL)configureWithEnabled:(BOOL)enabled
                saveEnabled:(BOOL)saveEnabled
             saveOnlyDebug:(BOOL)saveOnlyInDebug
              storageType:(TSLogStorageType)storageType
               encryption:(BOOL)encryption
                 maxSize:(NSUInteger)maxSize
           retentionDays:(NSUInteger)days
               directory:(nullable NSString *)directory;

/**
 * 快速配置（使用默认值）
 * @param saveEnabled 是否保存日志
 * @return BOOL 配置是否成功
 */
- (BOOL)quickConfigureWithSaveEnabled:(BOOL)saveEnabled;

- (void)setLogEnable:(BOOL)logEnable;


+ (instancetype)sharedInstance;

// 日志打印方法
+ (void)debug:(TSLogCategory)category message:(NSString *)format, ...;
+ (void)info:(TSLogCategory)category message:(NSString *)format, ...;
+ (void)warning:(TSLogCategory)category message:(NSString *)format, ...;
+ (void)error:(TSLogCategory)category message:(NSString *)format, ...;

// 新增不带 category 的日志打印方法
+ (void)debug:(NSString *)format, ...;
+ (void)info:(NSString *)format, ...;
+ (void)warning:(NSString *)format, ...;
+ (void)error:(NSString *)format, ...;



@end

NS_ASSUME_NONNULL_END

// 便捷宏定义
#define TSDebug(category, format, ...) [TSLogger debug:category message:format, ##__VA_ARGS__]
#define TSInfo(category, format, ...) [TSLogger info:category message:format, ##__VA_ARGS__]
#define TSWarning(category, format, ...) [TSLogger warning:category message:format, ##__VA_ARGS__]
#define TSError(category, format, ...) [TSLogger error:category message:format, ##__VA_ARGS__]

// 新增不带 category 的便捷宏定义
#define TSLog(format, ...) [TSLogger debug:format, ##__VA_ARGS__]
#define TSLogInfo(format, ...) [TSLogger info:format, ##__VA_ARGS__]
#define TSLogWarning(format, ...) [TSLogger warning:format, ##__VA_ARGS__]
#define TSLogError(format, ...) [TSLogger error:format, ##__VA_ARGS__] 
