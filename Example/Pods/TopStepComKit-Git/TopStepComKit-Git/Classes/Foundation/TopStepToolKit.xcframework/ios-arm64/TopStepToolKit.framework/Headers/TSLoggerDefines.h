//
//  TSLoggerDefines.h
//  TopStepToolKit
//
//  Created by TopStep on 2024/03/14.
//  Copyright © 2024年 TopStep. All rights reserved.
//
//  Description: 日志系统相关枚举定义
//  Author: TopStep
//  Version: 1.0.0
//

#import <Foundation/Foundation.h>



/** 日志级别枚举 */
typedef NS_ENUM(NSInteger, TopStepLogLevel) {
    TopStepLogLevelDebug,    // 调试信息
    TopStepLogLevelInfo,     // 一般信息
    TopStepLogLevelWarning,  // 警告信息
    TopStepLogLevelError     // 错误信息
};

/** 日志分类枚举 */
typedef NS_ENUM(NSInteger, TSLogCategory) {
    TSLogCategoryDefault,    // 默认分类
    TSLogCategoryNetwork,    // 网络相关
    TSLogCategoryUI,         // UI相关
    TSLogCategoryDatabase,   // 数据库相关
    TSLogCategoryBusiness    // 业务相关
};

// 存储类型枚举
typedef NS_OPTIONS(NSUInteger, TSLogStorageType) {
    TSLogStorageTypeConsole = 1 << 0,  // 控制台输出
    TSLogStorageTypeFile    = 1 << 1,  // 文件存储
    TSLogStorageTypeServer  = 1 << 2   // 服务器上报
};
