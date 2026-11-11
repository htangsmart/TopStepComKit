#import "TSKitBaseModel.h"
#import "TSMediaFileModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Media import session data
 * @chinese 媒体导入会话数据
 */
@interface TSMediaFileImportResultModel : TSKitBaseModel

/**
 * @brief Source media metadata
 * @chinese 来源媒体元数据
 *
 * @discussion
 * [EN]: Source media metadata
 * [CN]: 来源媒体元数据
 *
 * @note
 * [EN]: Populated before delivery on the main queue.
 * [CN]: 在主队列交付之前填写。
 */
@property (nonatomic, strong) TSMediaFileModel *mediaFile;

/**
 * @brief Persistent original path when retained
 * @chinese 保留原件时的持久路径
 *
 * @discussion
 * [EN]: Persistent original path when retained
 * [CN]: 保留原件时的持久路径
 *
 * @note
 * [EN]: Nil means unavailable; do not infer success.
 * [CN]: 为空表示未知或不可用，不据此推断成功。
 */
@property (nonatomic, copy, nullable) NSString *originalLocalPath;

/**
 * @brief Persistent usable file path
 * @chinese 持久可用文件路径
 *
 * @discussion
 * [EN]: Persistent usable file path
 * [CN]: 持久可用文件路径
 *
 * @note
 * [EN]: Nil means unavailable; do not infer success.
 * [CN]: 为空表示未知或不可用，不据此推断成功。
 */
@property (nonatomic, copy, nullable) NSString *localPath;

/**
 * @brief Post-processing outcome
 * @chinese 后处理结果
 *
 * @discussion
 * [EN]: Post-processing outcome
 * [CN]: 后处理结果
 *
 * @note
 * [EN]: Populated before delivery on the main queue.
 * [CN]: 在主队列交付之前填写。
 */
@property (nonatomic, copy) NSString *postProcessStatus;

/**
 * @brief File import or persistence error
 * @chinese 文件导入或落盘错误
 *
 * @discussion
 * [EN]: File import or persistence error
 * [CN]: 文件导入或落盘错误
 *
 * @note
 * [EN]: Nil means unavailable; do not infer success.
 * [CN]: 为空表示未知或不可用，不据此推断成功。
 */
@property (nonatomic, strong, nullable) NSError *error;

@end

NS_ASSUME_NONNULL_END
