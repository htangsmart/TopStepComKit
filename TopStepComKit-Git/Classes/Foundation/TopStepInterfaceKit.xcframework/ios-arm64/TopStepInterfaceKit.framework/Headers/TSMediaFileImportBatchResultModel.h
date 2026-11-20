#import "TSKitBaseModel.h"
#import "TSMediaFileModel.h"
#import "TSMediaFileImportResultModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Media import session data
 * @chinese 媒体导入会话数据
 */
@interface TSMediaFileImportBatchResultModel : TSKitBaseModel

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
 * @brief Per-file results including failures
 * @chinese 包含失败项的逐文件结果
 *
 * @discussion
 * [EN]: Per-file results including failures
 * [CN]: 包含失败项的逐文件结果
 *
 * @note
 * [EN]: Populated before delivery on the main queue.
 * [CN]: 在主队列交付之前填写。
 */
@property (nonatomic, copy) NSArray<TSMediaFileImportResultModel *> *results;

/**
 * @brief Identifiers of failed files
 * @chinese 失败文件标识集合
 *
 * @discussion
 * [EN]: Identifiers of failed files
 * [CN]: 失败文件标识集合
 *
 * @note
 * [EN]: Populated before delivery on the main queue.
 * [CN]: 在主队列交付之前填写。
 */
@property (nonatomic, copy) NSArray<NSString *> *failedIdentifiers;

@end

NS_ASSUME_NONNULL_END
