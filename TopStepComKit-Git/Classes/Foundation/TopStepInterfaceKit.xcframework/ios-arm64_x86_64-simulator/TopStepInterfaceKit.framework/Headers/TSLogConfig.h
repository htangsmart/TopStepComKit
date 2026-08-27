//
//  TSLogConfig.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/6/25.
//

#import <Foundation/Foundation.h>
#import <TopStepToolKit/TopStepToolKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief SDK logging configuration
 * @chinese SDK 日志配置
 *
 * @discussion
 * [EN]: Aggregates all logging-related options. `enabled` is the single master
 *       switch that controls console printing, file storage and crash capture
 *       together; `level` controls verbosity for both console and file.
 *       Prefer the presets (debugConfig / productionConfig) over tuning fields
 *       one by one.
 * [CN]: 聚合所有日志相关配置。`enabled` 是唯一总开关，统一控制控制台打印、
 *       文件存储与崩溃捕获；`level` 控制控制台与文件的日志详细程度。
 *       建议优先使用预设（debugConfig / productionConfig），而非逐项调参。
 */
@interface TSLogConfig : NSObject

/**
 * @brief Master logging switch
 * @chinese 日志总开关
 *
 * @discussion
 * [EN]: When NO, console printing, file storage and crash capture are all off,
 *       and `level` has no effect. When YES, all three are enabled and filtered
 *       by `level`.
 * [CN]: 为 NO 时，控制台打印、文件存储与崩溃捕获全部关闭，`level` 不生效；
 *       为 YES 时三者全部开启，并按 `level` 过滤。
 *
 * @note
 * [EN]: Default is NO.
 * [CN]: 默认值为 NO。
 */
@property (nonatomic, assign) BOOL enabled;

/**
 * @brief Minimum log level (verbosity)
 * @chinese 最低日志级别（详细程度）
 *
 * @discussion
 * [EN]: Only logs at or above this level are printed and stored. Levels from low
 *       to high: Debug < Info < Warning < Error. Only effective when enabled is YES.
 * [CN]: 只有级别等于或高于此值的日志才会打印和存储。级别从低到高：
 *       Debug < Info < Warning < Error。仅在 enabled 为 YES 时生效。
 *
 * @note
 * [EN]: Default is TopStepLogLevelDebug.
 * [CN]: 默认值为 TopStepLogLevelDebug。
 */
@property (nonatomic, assign) TopStepLogLevel level;

/**
 * @brief Custom log file directory
 * @chinese 自定义日志文件目录
 *
 * @discussion
 * [EN]: When set, log files are stored under this directory instead of the SDK
 *       default location. Pass nil to use the default directory.
 * [CN]: 设置后，日志文件存储到此目录而非 SDK 默认位置。传 nil 则使用默认目录。
 *
 * @note
 * [EN]: Default is nil (uses default log directory).
 * [CN]: 默认值为 nil（使用默认日志目录）。
 */
@property (nonatomic, copy, nullable) NSString *fileDirectory;

/**
 * @brief Default config: logging disabled
 * @chinese 默认配置：关闭日志
 *
 * @return
 * [EN]: enabled = NO, level = Debug. Keeps the SDK silent unless explicitly enabled.
 * [CN]: enabled = NO，level = Debug。除非显式开启，否则 SDK 静默。
 */
+ (instancetype)defaultConfig;

/**
 * @brief Debug config: verbose logging
 * @chinese 调试配置：详细日志
 *
 * @return
 * [EN]: enabled = YES, level = Debug. Console, file and crash capture all on.
 * [CN]: enabled = YES，level = Debug。控制台、文件与崩溃捕获全部开启。
 */
+ (instancetype)debugConfig;

/**
 * @brief Production config: warnings and errors only
 * @chinese 生产配置：仅警告与错误
 *
 * @return
 * [EN]: enabled = YES, level = Warning. Suitable for release builds.
 * [CN]: enabled = YES，level = Warning。适合发布版本。
 */
+ (instancetype)productionConfig;

@end

NS_ASSUME_NONNULL_END
