#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// @brief Demo storage for raw device log files. @chinese Demo 设备日志原始文件存储。
@interface TSDeviceRealtimeLogStore : NSObject

/// @brief Get the shared store. @chinese 取得共享存储。
/// @return The store / 存储实例。
+ (instancetype)sharedStore;

/// @brief Append one complete packet. @chinese 追加一个完整数据包。
/// @param data Raw packet / 原始数据包。
/// @param deviceIdentifier Peripheral UUID / 外设 UUID。
/// @param recordingIdentifier Local writer owner / 本次写入的归属标识。
/// @param createdFile Whether this packet started a new file / 此包是否打开了新的有效文件。
/// @param error Storage error / 文件错误。
/// @return Whether the packet was accepted / 是否成功写入。
- (BOOL)appendData:(NSData *)data
  deviceIdentifier:(NSString *)deviceIdentifier
         recording:(NSUUID *)recordingIdentifier
       createdFile:(BOOL * _Nullable)createdFile
             error:(NSError * _Nullable * _Nullable)error;

/// @brief Close the matching writer. @chinese 关闭归属匹配的写入器。
/// @param recordingIdentifier Local writer owner / 本次写入的归属标识。
- (void)closeRecording:(NSUUID *)recordingIdentifier;

/// @brief List closed logs across device folders, newest first. @chinese 按新到旧列出各设备已关闭的日志。
/// @return Closed file URLs / 已关闭文件的 URL。
- (NSArray<NSURL *> *)closedFiles;

@end

NS_ASSUME_NONNULL_END
