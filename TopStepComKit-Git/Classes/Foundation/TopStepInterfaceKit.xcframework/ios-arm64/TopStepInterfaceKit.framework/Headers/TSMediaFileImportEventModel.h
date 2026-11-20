#import "TSKitBaseModel.h"
#import "TSMediaFileModel.h"
#import "TSMediaFileImportResultModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Media import session data
 * @chinese 媒体导入会话数据
 */
@interface TSMediaFileImportEventModel : TSKitBaseModel

/**
 * @brief Import session identifier
 * @chinese 导入会话标识
 *
 * @discussion
 * [EN]: Import session identifier
 * [CN]: 导入会话标识
 *
 * @note
 * [EN]: Populated before delivery on the main queue.
 * [CN]: 在主队列交付之前填写。
 */
@property (nonatomic, copy) NSString *sessionIdentifier;

/**
 * @brief Current import phase
 * @chinese 当前导入阶段
 *
 * @discussion
 * [EN]: Current import phase
 * [CN]: 当前导入阶段
 *
 * @note
 * [EN]: Populated before delivery on the main queue.
 * [CN]: 在主队列交付之前填写。
 */
@property (nonatomic, copy) NSString *phase;

/**
 * @brief Current file identifier
 * @chinese 当前文件标识
 *
 * @discussion
 * [EN]: Current file identifier
 * [CN]: 当前文件标识
 *
 * @note
 * [EN]: Nil means unavailable; do not infer success.
 * [CN]: 为空表示未知或不可用，不据此推断成功。
 */
@property (nonatomic, copy, nullable) NSString *fileIdentifier;

/**
 * @brief Transferred byte count
 * @chinese 已传输字节数
 *
 * @discussion
 * [EN]: Transferred byte count
 * [CN]: 已传输字节数
 *
 * @note
 * [EN]: Populated before delivery on the main queue.
 * [CN]: 在主队列交付之前填写。
 */
@property (nonatomic, assign) uint64_t transferredBytes;

/**
 * @brief Total bytes, nil when unknown
 * @chinese 总字节数，未知时为空
 *
 * @discussion
 * [EN]: Total bytes, nil when unknown
 * [CN]: 总字节数，未知时为空
 *
 * @note
 * [EN]: Nil means unavailable; do not infer success.
 * [CN]: 为空表示未知或不可用，不据此推断成功。
 */
@property (nonatomic, copy, nullable) NSNumber *totalBytes;

/**
 * @brief Transfer speed in bytes per second
 * @chinese 传输速度，单位字节每秒
 *
 * @discussion
 * [EN]: Transfer speed in bytes per second
 * [CN]: 传输速度，单位字节每秒
 *
 * @note
 * [EN]: Populated before delivery on the main queue.
 * [CN]: 在主队列交付之前填写。
 */
@property (nonatomic, assign) uint64_t speedBytesPerSecond;

/**
 * @brief Percentage from zero to one hundred
 * @chinese 零到一百的进度百分比
 *
 * @discussion
 * [EN]: Percentage from zero to one hundred
 * [CN]: 零到一百的进度百分比
 *
 * @note
 * [EN]: Nil means unavailable; do not infer success.
 * [CN]: 为空表示未知或不可用，不据此推断成功。
 */
@property (nonatomic, copy, nullable) NSNumber *progress;

/**
 * @brief Persisted per-file result when available
 * @chinese 可用时的已落盘单文件结果
 *
 * @discussion
 * [EN]: Persisted per-file result when available
 * [CN]: 可用时的已落盘单文件结果
 *
 * @note
 * [EN]: Nil means unavailable; do not infer success.
 * [CN]: 为空表示未知或不可用，不据此推断成功。
 */
@property (nonatomic, strong, nullable) TSMediaFileImportResultModel *result;

@end

NS_ASSUME_NONNULL_END
