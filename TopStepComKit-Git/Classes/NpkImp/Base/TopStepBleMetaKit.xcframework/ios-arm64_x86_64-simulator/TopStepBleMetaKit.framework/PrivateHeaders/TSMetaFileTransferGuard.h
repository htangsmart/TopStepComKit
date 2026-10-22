//
//  TSMetaFileTransferGuard.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>
#import "TSMetaFileSender.h"

NS_ASSUME_NONNULL_BEGIN

/** @brief Cross-protocol file admission guard. @chinese 新旧文件协议的原子准入保护。 */
@interface TSMetaFileTransferGuard : NSObject
/** @brief Shared guard. @chinese 获取唯一门闩。 @return Shared instance / 唯一实例。 */
+ (instancetype)sharedInstance;
/** @brief Register a legacy transaction. @chinese 登记旧协议事务，不改变旧协议之间的准入。
 * @param generation Current connection generation / 当前连接代次。
 * @param error Admission error / 准入错误。
 * @return Operation identifier or nil / 操作标识或nil。
 */
- (nullable NSUUID *)beginPBForGeneration:(NSUInteger)generation error:(NSError * _Nullable * _Nullable)error;
/** @brief Acquire upload exclusivity. @chinese 为新协议准备及发送取得独占。
 * @param generation Current connection generation / 当前连接代次。
 * @param error Admission error / 准入错误。
 * @return Operation identifier or nil / 操作标识或nil。
 */
- (nullable NSUUID *)beginUploadForGeneration:(NSUInteger)generation error:(NSError * _Nullable * _Nullable)error;
/** @brief Close exactly one registration. @chinese 仅关闭指定登记；未确认清场时保留对应协议的隔离标记。
 * @param identifier Registered operation / 已登记操作。
 * @param clean Whether device state is known clean / 是否确认设备事务已清场。
 */
- (void)finishOperation:(nullable NSUUID *)identifier deviceStateKnownClean:(BOOL)clean;
/** @brief Check registration validity. @chinese 检查登记是否仍属于当前连接。
 * @param identifier Registered operation / 已登记操作。
 * @return YES for a live registration / 登记仍有效返回YES。
 */
- (BOOL)isOperationActive:(nullable NSUUID *)identifier;
/** @brief Advance the connection boundary. @chinese 更新连接代次并使旧登记及隔离信息失效。
 * @param generation New connection generation / 新连接代次。
 */
- (void)invalidateForConnectionGeneration:(NSUInteger)generation;
@end

/** @brief Private cancellation observation. @chinese 旧发送器取消清场的内部观察入口。 */
@interface TSMetaFileSender (FileTransferGuard)
/**
 * @brief Current legacy sender registration identity
 * @chinese 旧发送器当前的文件准入登记标识
 *
 * @discussion
 * [EN]: Copied UUID assigned when PB admission succeeds; nil before registration
 *       or after that registration is released. Cancellation captures this value
 *       before its asynchronous device acknowledgement so a late result cannot
 *       release a later task's registration. It is not a file id or connection id.
 * [CN]: PB 准入成功时保存的 UUID；登记前或释放该登记后为 nil。取消门面须在等待
 *       设备异步应答前捕获此值，防止迟到结果释放后续任务的登记；它不是文件或连接编号。
 */
@property (nonatomic, copy, readonly, nullable) NSUUID *fileTransferOperationIdentifier;
/** @brief Complete captured cancellation registration. @chinese 关闭取消前捕获的登记，不影响后来任务。
 * @param identifier Captured identity / 取消前捕获的身份。
 * @param clean Parsed device acknowledgement / 已解析的设备清场结果。
 */
- (void)finishCancellationForOperation:(nullable NSUUID *)identifier deviceStateKnownClean:(BOOL)clean;
@end

NS_ASSUME_NONNULL_END
