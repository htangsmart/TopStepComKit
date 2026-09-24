//
//  TSHsdCallLog.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 日志变化通知（主线程）
FOUNDATION_EXPORT NSNotificationName const TSHsdCallLogDidChangeNotification;

/**
 * @brief One SDK call record
 * @chinese 一次 SDK 调用记录：方法名、参数摘要、结果、耗时
 */
@interface TSHsdCallLogEntry : NSObject

@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *params;
@property (nonatomic, strong) NSDate *startedAt;
@property (nonatomic, strong, nullable) NSDate *finishedAt;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong, nullable) NSError *error;
/// 结果摘要（成功时由调用方填写，如 "4 tasks · coins 30"）
@property (nonatomic, copy, nullable) NSString *result;
/// 耗时（毫秒），未完成时为 0
@property (nonatomic, readonly) NSTimeInterval durationMs;

@end

/**
 * @brief In-memory SDK call log shared by all Huashengda pages
 * @chinese 华盛达页面共用的接口调用日志（产品方案 §3.7）：内存单例，最多保留 200 条
 */
@interface TSHsdCallLog : NSObject

+ (instancetype)shared;
/// 最新在前
@property (nonatomic, readonly) NSArray<TSHsdCallLogEntry *> *entries;
/// 最近一次完成的调用是否失败（右上角红点）
@property (nonatomic, readonly) BOOL lastCallFailed;

- (TSHsdCallLogEntry *)begin:(NSString *)method params:(nullable NSString *)params;
- (void)finish:(TSHsdCallLogEntry *)entry success:(BOOL)success error:(nullable NSError *)error result:(nullable NSString *)result;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
