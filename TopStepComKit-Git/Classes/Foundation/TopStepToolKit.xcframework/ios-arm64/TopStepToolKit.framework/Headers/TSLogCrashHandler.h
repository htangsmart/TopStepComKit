//
//  TSLogCrashHandler.h
//  TopStepToolKit
//
//  Created by TopStep on 2026/06/12.
//  Copyright © 2026年 TopStep. All rights reserved.
//
//  Description: 崩溃捕获与异常退出检测
//  Author: TopStep
//  Version: 1.0.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Crash capture and abnormal exit detection for the log module
 * @chinese 日志模块的崩溃捕获与异常退出检测
 *
 * @discussion
 * [EN]: Two independent capabilities:
 *       1. Crash capture (default OFF): registers NSUncaughtExceptionHandler and
 *          signal handlers (SIGABRT/SIGSEGV/SIGBUS/SIGILL/SIGFPE/SIGTRAP) to write
 *          crash stack into the log file. Previous handlers are saved and chained,
 *          so host-app crash reporters (Bugly/Firebase etc.) keep working.
 *       2. Abnormal exit detection (default ON): a foreground-session marker file
 *          is used to detect, on next launch, that the previous session ended
 *          abnormally (crash / OOM / watchdog kill) while in foreground.
 *       Both start working when log storage is enabled.
 * [CN]: 两个相互独立的能力：
 *       1. 崩溃捕获（默认关闭）：注册 NSUncaughtExceptionHandler 和信号处理器
 *          （SIGABRT/SIGSEGV/SIGBUS/SIGILL/SIGFPE/SIGTRAP），把崩溃堆栈写入日志文件。
 *          注册前保存旧 handler 并在处理后链式调用，不影响宿主 App 的崩溃上报（Bugly/Firebase 等）。
 *       2. 异常退出检测（默认开启）：通过前台会话标记文件，在下次启动时倒推出
 *          上次会话在前台异常结束（崩溃 / OOM / 看门狗强杀）。
 *       两者均在日志存储启用后开始工作。
 */
@interface TSLogCrashHandler : NSObject

/**
 * @brief Whether crash capture is enabled (default NO)
 * @chinese 是否启用崩溃捕获（默认 NO）
 *
 * @discussion
 * [EN]: Registering global crash handlers is intrusive to the host app,
 *       so it is OFF by default and must be enabled explicitly.
 * [CN]: 注册全局崩溃 handler 对宿主 App 有侵入性，默认关闭，需接入方显式开启。
 */
@property (nonatomic, assign, getter=isCrashCaptureEnabled) BOOL crashCaptureEnable;

/**
 * @brief Whether abnormal exit detection is enabled (default YES)
 * @chinese 是否启用异常退出检测（默认 YES）
 *
 * @discussion
 * [EN]: Zero-intrusion. Only detects abnormal exits that happened in foreground;
 *       being killed by the system in background is normal on iOS and is ignored.
 * [CN]: 零侵入。只检测前台发生的异常退出；iOS 后台被系统回收属正常行为，不计入。
 */
@property (nonatomic, assign, getter=isAbnormalExitDetectEnabled) BOOL abnormalExitDetectEnable;

/**
 * @brief Get the shared instance of TSLogCrashHandler
 * @chinese 获取 TSLogCrashHandler 的单例实例
 *
 * @return TSLogCrashHandler instance
 * @chinese 返回 TSLogCrashHandler 实例
 */
+ (instancetype)sharedInstance;

/**
 * @brief Begin session monitoring (called by TSLogStorage when storage is enabled)
 * @chinese 开始会话监测（由 TSLogStorage 在启用日志存储时调用）
 *
 * @discussion
 * [EN]: Merges pending signal-crash records from last session into the log and
 *       archives them under the Crash/ subdirectory (keeps the latest 20),
 *       reports abnormal exit of last session, then creates the session marker.
 * [CN]: 将上次会话遗留的信号崩溃记录合并进日志并归档到 Crash/ 子目录（保留最近 20 个），
 *       报告上次会话的异常退出，然后创建本次会话标记。
 */
- (void)beginSessionMonitoring;

/**
 * @brief End session monitoring (called by TSLogStorage when storage is disabled)
 * @chinese 结束会话监测（由 TSLogStorage 在禁用日志存储时调用）
 */
- (void)endSessionMonitoring;

@end

NS_ASSUME_NONNULL_END
