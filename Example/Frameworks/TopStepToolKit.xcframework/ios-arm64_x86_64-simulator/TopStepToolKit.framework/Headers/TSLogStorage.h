#import <Foundation/Foundation.h>
#import "TSLogger.h"
#import "TSLoggerDefines.h"

NS_ASSUME_NONNULL_BEGIN  // 添加默认 nullability 上下文


@interface TSLogStorage : NSObject <TSLoggerDelegate>

@property (nonatomic, assign) TSLogStorageType storageType;  // 存储类型
@property (nonatomic, assign) BOOL enableEncryption;         // 是否加密
@property (nonatomic, assign) NSUInteger maxFileSize;        // 文件最大大小(MB)
@property (nonatomic, assign) NSUInteger retentionDays;      // 保留天数
@property (nonatomic, copy, readonly, nullable) NSString *logDirectory; // 日志存储路径

+ (instancetype)sharedInstance;

/**
 * 配置存储选项
 * @param type 存储类型（控制台/文件/服务器）
 * @param encryption 是否启用加密
 * @param maxSize 单个日志文件最大大小(MB)
 * @param days 日志保留天数
 * @param directory 自定义日志存储目录路径（可选，传nil则使用默认路径）
 * @return BOOL 配置是否成功
 */
- (BOOL)configureWithType:(TSLogStorageType)type
               encryption:(BOOL)encryption
                  maxSize:(NSUInteger)maxSize
            retentionDays:(NSUInteger)days
                directory:(nullable NSString *)directory;

/**
 * 获取日志文件路径列表
 * @return 日志文件路径数组
 */
- (NSArray<NSString *> *)logFilePaths;

/**
 * 清理所有日志
 */
- (void)clearAllLogs;

/**
 * 获取当前日志文件路径
 * @return 当前日志文件的完整路径
 */
- (nullable NSString *)currentLogFilePath;

/**
 * 读取并解密日志文件内容
 * @param filePath 日志文件路径
 * @return 解密后的日志内容，如果文件不存在或解密失败返回nil
 */
- (nullable NSString *)decryptLogFileAtPath:(NSString *)filePath;

/**
 * 导出日志文件
 * 将指定时间范围内的日志导出到系统"文件"应用
 * @param startDate 开始时间（可选，传nil则不限制开始时间）
 * @param endDate 结束时间（可选，传nil则使用当前时间）
 * @param completion 完成回调，返回导出文件的路径和可能的错误
 */
- (void)exportLogsFromDate:(nullable NSDate *)startDate
                    toDate:(nullable NSDate *)endDate
                completion:(void (^)(NSString *_Nullable filePath, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END  // 结束 nullability 上下文
