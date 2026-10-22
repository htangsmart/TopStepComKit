//
//  TSBleManager+FileUpload.h
//  TopStepBleMetaKit
//

#import "TSBleManager.h"
@class TSMetaFileUploadChannel;

NS_ASSUME_NONNULL_BEGIN

/** @brief Private connection bridge for the upload channel. @chinese 新上传通道的内部连接桥接。 */
@interface TSBleManager (FileUpload)
/** @brief Current connection generation. @chinese 当前连接代次，断连及换设备后变化。 */
@property (nonatomic, assign, readonly) NSUInteger fileUploadConnectionGeneration;
/** @brief Current connection upload channel. @chinese 当前连接唯一上传通道；未连接时返回nil。
 * @return Connection-owned channel / 由连接持有的通道。
 */
- (nullable TSMetaFileUploadChannel *)fileUploadChannel;
/** @brief Execute in the existing serial write context. @chinese 在原串行写上下文执行，已在队列时直接调用。
 * @param block Work to execute / 待执行工作。
 */
- (void)performFileUploadWriteBlock:(dispatch_block_t)block;
/** @brief Always enqueue a new write turn. @chinese 始终异步排入原写队列，用于有界让出。
 * @param block Work to enqueue / 待排入工作。
 */
- (void)enqueueFileUploadWriteBlock:(dispatch_block_t)block;
@end

NS_ASSUME_NONNULL_END
