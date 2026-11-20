#import "TSKitBaseModel.h"
#import "TSMediaFileModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Media import session data
 * @chinese 媒体导入会话数据
 */
@interface TSMediaFileImportSessionModel : TSKitBaseModel

/**
 * @brief Opaque import session identifier
 * @chinese 不透明导入会话标识
 *
 * @discussion
 * [EN]: Opaque import session identifier
 * [CN]: 不透明导入会话标识
 *
 * @note
 * [EN]: Populated before delivery on the main queue.
 * [CN]: 在主队列交付之前填写。
 */
@property (nonatomic, copy) NSString *identifier;

/**
 * @brief Device identity bound to this session
 * @chinese 会话绑定的设备标识
 *
 * @discussion
 * [EN]: Device identity bound to this session
 * [CN]: 会话绑定的设备标识
 *
 * @note
 * [EN]: Populated before delivery on the main queue.
 * [CN]: 在主队列交付之前填写。
 */
@property (nonatomic, copy) NSString *deviceIdentifier;

/**
 * @brief Device media list for this session
 * @chinese 本会话的设备媒体清单
 *
 * @discussion
 * [EN]: Device media list for this session
 * [CN]: 本会话的设备媒体清单
 *
 * @note
 * [EN]: Populated before delivery on the main queue.
 * [CN]: 在主队列交付之前填写。
 */
@property (nonatomic, copy) NSArray<TSMediaFileModel *> *mediaFiles;

@end

NS_ASSUME_NONNULL_END
