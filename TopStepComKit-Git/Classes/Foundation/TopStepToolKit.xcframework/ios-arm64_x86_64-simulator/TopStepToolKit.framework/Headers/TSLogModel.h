//
//  TSLogModel.h
//  TopStepToolKit
//
//  Created by TopStep on 2024/03/14.
//  Copyright © 2024年 TopStep. All rights reserved.
//
//  Description: 日志数据模型类
//  Author: TopStep
//  Version: 1.0.0
//

#import <Foundation/Foundation.h>
#import "TSLoggerDefines.h" // 新增的枚举定义文件

NS_ASSUME_NONNULL_BEGIN

/**
 * 日志数据模型类
 * 用于封装单条日志的所有相关信息
 */
@interface TSLogModel : NSObject <NSCopying>

/** 日志内容 */
@property (nonatomic, copy) NSString *message;

/** 日志级别 */
@property (nonatomic, assign) TSLogLevel level;

/** 日志分类 */
@property (nonatomic, assign) TSLogCategory category;

/** 源文件名 */
@property (nonatomic, copy) NSString *fileName;

/** 行号 */
@property (nonatomic, assign) NSInteger lineNumber;

/** 函数名 */
@property (nonatomic, copy) NSString *function;

/** 时间戳 */
@property (nonatomic, strong) NSDate *timestamp;

/**
 * 打印格式化日志消息
 * 将日志信息格式化为标准格式，包含时间戳、日志级别、分类、文件信息等
 */
- (void)logFormattedMessage ;

@end

NS_ASSUME_NONNULL_END
