#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 日志存储管理类
 * @chinese 日志存储管理类
 *
 * @discussion
 * [EN]: Responsible for log storage and management.
 * [CN]: 负责日志的存储和管理。
 */
@interface TSLogStorage : NSObject

/**
 * @brief Log storage directory
 * @chinese 日志存储路径
 */
@property (nonatomic, copy, readonly, nullable) NSString *logDirectory;


/**
 * @brief Get the shared instance of TSLogStorage
 * @chinese 获取 TSLogStorage 的单例实例
 *
 * @return TSLogStorage instance
 * @chinese 返回 TSLogStorage 实例
 */
+ (instancetype)sharedInstance;

/**
 * @brief Enable or disable log storage
 * @chinese 启用或禁用日志存储
 *
 * @param enable Whether to enable log storage
 * @chinese 是否启用日志存储
 */
- (void)setLogStorageEnable:(BOOL)enable;

/**
 * @brief Get all log file paths
 * @chinese 获取所有日志文件路径
 *
 * @return Array of log file paths
 * @chinese 日志文件路径数组
 */
- (NSArray<NSString *> *)logFilePaths;

/**
 * @brief Clear all logs
 * @chinese 清理所有日志
 */
- (void)clearAllLogs;


/**
 * @brief 检查并切换日志文件（如有必要），并返回当前日志文件路径
 * @chinese 检查并切换日志文件（如有必要），并返回当前日志文件路径
 *
 * @param appendLength
 * [EN]: The length of the log to be appended (in bytes)
 * [CN]: 即将追加的日志内容字节数
 */
- (void)checkAndRotateLogFileIfNeededWithAppendLength:(NSUInteger)appendLength;

@end

NS_ASSUME_NONNULL_END
