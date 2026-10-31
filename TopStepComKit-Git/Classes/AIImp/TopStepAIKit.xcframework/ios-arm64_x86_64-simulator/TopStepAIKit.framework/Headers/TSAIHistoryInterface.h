#import <Foundation/Foundation.h>
#import "TSAIContractDefines.h"

NS_ASSUME_NONNULL_BEGIN
/**
 * @brief Requested history coverage
 * @chinese 请求的历史覆盖范围
 */
typedef NS_ENUM(NSInteger, TSAIHistoryScope) {
    TSAIHistoryScopeCurrentContext = 0,
    TSAIHistoryScopeAllLocalRecords = 1,
};
/**
 * @brief State reported by the external historical audio player
 * @chinese 外部历史音频播放器上报的状态
 */
typedef NS_ENUM(NSInteger, TSAIHistoryPlaybackState) {
    TSAIHistoryPlaybackStateStarted = 1,
    TSAIHistoryPlaybackStateFinished,
    TSAIHistoryPlaybackStateStopped,
    TSAIHistoryPlaybackStateFailed,
};
/**
 * @brief Vendor-neutral local history record
 * @chinese 厂商无关的本地历史记录
 */
@interface TSAIHistoryRecord : NSObject <NSCopying>
/**
 * @brief Source record identifier
 * @chinese 来源记录标识
 * @discussion
 * [EN]: Preserves source timestamp and role.
 * [CN]: 保留来源时间戳和角色。
 * @note
 * [EN]: Does not establish account isolation by itself.
 * [CN]: 此标识本身不代表具备账号隔离。
 */
@property (nonatomic, copy) NSString *recordIdentifier;
/**
 * @brief Context that supplied this record
 * @chinese 提供此记录的作用域
 * @discussion
 * [EN]: Prevents passing a record to another capability instance.
 * [CN]: 用于防止向其他能力实例传入该记录。
 * @note
 * [EN]: Not a vendor account identifier.
 * [CN]: 不是厂商账号标识。
 */
@property (nonatomic, copy) NSString *scopeIdentifier;
/**
 * @brief Display text
 * @chinese 显示文本
 * @discussion
 * [EN]: Latest text reported by the service.
 * [CN]: 服务上报的最新文本。
 * @note
 * [EN]: May be empty for media-only records.
 * [CN]: 纯媒体记录可能为空。
 */
@property (nonatomic, copy) NSString *text;
/**
 * @brief Original timestamp used by public deletion APIs
 * @chinese 公开删除接口使用的原始时间戳
 * @discussion
 * [EN]: Kept as a string without guessing time units.
 * [CN]: 保留字符串，不猜测时间单位。
 * @note
 * [EN]: Empty timestamps cannot be deleted individually.
 * [CN]: 时间戳为空时不能单条删除。
 */
@property (nonatomic, copy) NSString *sourceTimestamp;
/**
 * @brief Historical audio URL
 * @chinese 历史音频地址
 * @discussion
 * [EN]: Resolved only within the App Documents directory.
 * [CN]: 仅在 App Documents 目录内解析。
 * @note
 * [EN]: A URL or existing file does not prove the vendor finished writing it.
 * [CN]: 有地址或文件存在均不证明厂商已经写完。
 */
@property (nonatomic, copy, nullable) NSURL *audioFileURL;
/**
 * @brief Associated image URL
 * @chinese 关联图片地址
 * @discussion
 * [EN]: Use the actual file format rather than assuming its extension.
 * [CN]: 按实际文件读取，不假设扩展名。
 * @note
 * [EN]: Nil when no accessible reference was supplied.
 * [CN]: 未提供可访问引用时为 nil。
 */
@property (nonatomic, copy, nullable) NSURL *imageFileURL;
/**
 * @brief Resolve a vendor relative path inside an explicit Documents directory
 * @chinese 在指定 Documents 目录内解析厂商相对路径
 * @param relativePath
 * EN: Nonempty relative file path; absolute and escaping paths are rejected.
 * CN: 非空相对文件路径，拒绝绝对路径与越界路径。
 * @param documentsDirectory
 * EN: Local Documents directory URL, also used for symlink boundary checks.
 * CN: 本地 Documents 目录地址，同时用于符号链接边界校验。
 * @return
 * EN: Canonical local URL or nil; this does not prove file existence or completeness.
 * CN: 规范本地地址或 nil，不证明文件存在或已完整写入。
 */
+ (nullable NSURL *)fileURLForRelativePath:(nullable NSString *)relativePath
                       documentsDirectory:(NSURL *)documentsDirectory;
@end

/**
 * @brief Result of a history query
 * @chinese 历史查询结果
 * @param records EN: Available records. CN: 可用记录。
 * @param error EN: Query error. CN: 查询错误。
 */
typedef void (^TSAIHistoryQueryCompletion)(NSArray<TSAIHistoryRecord *> *_Nullable records, NSError *_Nullable error);
/**
 * @brief External player state observer
 * @chinese 外部播放器状态观察者
 * @param state EN: Actual player state. CN: 实际播放器状态。
 * @param error EN: Failure details. CN: 失败原因。
 */
typedef void (^TSAIHistoryPlaybackBlock)(TSAIHistoryPlaybackState state, NSError *_Nullable error);
/**
 * @brief Local history and external file playback
 * @chinese 本地历史与外部文件回放
 */
@protocol TSAIHistoryInterface <NSObject>
/**
 * @brief Query the explicitly selected coverage
 * @chinese 查询明确指定的范围
 * @param scope EN: Current Context or all local history. CN: 当前作用域或全部本地历史。
 * @param completion EN: Main-thread query result. CN: 主线程查询结果。
 */
- (void)fetchHistoryWithScope:(TSAIHistoryScope)scope completion:(TSAIHistoryQueryCompletion)completion;
/**
 * @brief Delete one selected source record and its attachments
 * @chinese 删除一条选中的来源记录及其附件
 * @param record EN: Selected record. CN: 选中的记录。
 * @param completion EN: Main-thread operation result. CN: 主线程操作结果。
 */
- (void)deleteHistoryRecord:(TSAIHistoryRecord *)record completion:(nullable TSAICompletionBlock)completion;
/**
 * @brief Delete all vendor chat history only after an explicit user action
 * @chinese 仅在用户显式操作后删除全部厂商聊天历史
 * @param completion EN: Main-thread operation result. CN: 主线程操作结果。
 */
- (void)deleteAllHistoryWithCompletion:(nullable TSAICompletionBlock)completion;
/**
 * @brief Play an existing historical file outside the live SDK player
 * @chinese 使用独立播放器回放已有历史文件
 * @param record EN: Selected record. CN: 选中的记录。
 * @param onPlayback EN: Actual playback states on the main thread. CN: 主线程实际播放状态。
 * @return EN: Client playback identifier. CN: 客户端回放标识。
 * @discussion
 * [EN]: Player completion does not prove the vendor finished writing the entire answer file.
 * [CN]: 播放器完成不证明厂商已完整写完整次回答文件。
 */
- (NSString *)playHistoryRecord:(TSAIHistoryRecord *)record onPlayback:(nullable TSAIHistoryPlaybackBlock)onPlayback;
/**
 * @brief Stop one matching playback
 * @chinese 停止匹配的回放
 * @param taskId EN: Playback identifier. CN: 回放标识。
 */
- (void)stopHistoryPlaybackWithTaskId:(NSString *)taskId;
@end
NS_ASSUME_NONNULL_END
