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
 * @brief Set custom log directory path
 * @chinese 设置自定义日志目录路径
 *
 * @param logDirectory 
 * [EN]: Custom log directory path. Must not be nil or empty.
 *       If nil or empty string is passed, will clear custom path and use default path.
 *       The directory will be created automatically if it doesn't exist.
 * [CN]: 自定义日志目录路径。不能为nil或空字符串。
 *       如果传入nil或空字符串，将清除自定义路径并使用默认路径。
 *       如果目录不存在，将自动创建。
 */
- (void)setCustomLogDirectory:(nullable NSString *)logDirectory;

/**
 * @brief Enable or disable log storage
 * @chinese 启用或禁用日志存储
 *
 * @param enable Whether to enable log storage
 * @chinese 是否启用日志存储
 */
- (void)setLogStorageEnable:(BOOL)enable;

/**
 * @brief Check if log storage is enabled
 * @chinese 检查日志存储是否启用
 *
 * @return YES if enabled, NO otherwise
 * @chinese 如果启用返回YES，否则返回NO
 */
- (BOOL)isLogStorageEnabled;

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

/**
 * @brief Write log content directly to file (only for SDK logs)
 * @chinese 直接将日志内容写入文件（仅用于SDK日志）
 *
 * @param logContent
 * [EN]: The formatted log content to write
 * [CN]: 要写入的格式化日志内容
 *
 * @discussion
 * [EN]: This method writes log content directly to the log file without redirecting stdout/stderr.
 *       Only logs from TSLogPrinter will be stored, not App logs or other third-party logs.
 * [CN]: 此方法直接将日志内容写入日志文件，不重定向stdout/stderr。
 *       只有来自TSLogPrinter的日志会被存储，不会存储App日志或其他第三方库的日志。
 */
- (void)writeLogContent:(NSString *)logContent;

@end

NS_ASSUME_NONNULL_END
