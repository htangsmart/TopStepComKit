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

/**
 * @brief Acquire a neutral realtime transport lease
 * @chinese 取得中立的实时传输租约
 *
 * @param owner
 * EN: Unique logical operation owner; use a new value for every session.
 * CN: 逻辑操作的唯一所有者，每次会话必须使用新值。
 *
 * @param generation
 * EN: Current physical connection generation.
 * CN: 当前物理连接代次。
 *
 * @param error
 * EN: Receives a stale connection or admission error when acquisition fails.
 * CN: 获取失败时返回连接失效或准入错误。
 *
 * @return
 * EN: New lease identity, or nil if any file/realtime transaction or dirty state conflicts.
 * CN: 新租约标识；与文件、实时事务或未确认清场状态冲突时返回 nil。
 *
 * @discussion
 * [EN]: This guard never calls the request manager or waits on another queue.
 * [CN]: 此门闩不回调请求管理器，也不等待其他队列。
 */
- (nullable NSUUID *)beginRealtimeForOwner:(NSString *)owner
                              generation:(NSUInteger)generation
                                   error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Validate the exact realtime lease and physical generation
 * @chinese 核验原实时租约及其物理代次
 *
 * @param identifier
 * EN: Original lease identity.
 * CN: 原租约标识。
 *
 * @param owner
 * EN: Original logical owner.
 * CN: 原逻辑所有者。
 *
 * @param generation
 * EN: Original physical generation.
 * CN: 原物理连接代次。
 *
 * @return
 * EN: YES only while all three values match the active realtime lease.
 * CN: 三项均匹配当前实时租约时返回 YES。
 */
- (BOOL)isRealtimeOperationActive:(nullable NSUUID *)identifier
                           owner:(NSString *)owner
                      generation:(NSUInteger)generation;

/**
 * @brief Release only the captured realtime lease
 * @chinese 仅释放捕获的原实时租约
 *
 * @param identifier
 * EN: Original lease identity; a stale identity has no effect.
 * CN: 原租约标识；过期标识不产生副作用。
 *
 * @param clean
 * EN: Firmware barrier evidence; local write drain alone is insufficient.
 * CN: 固件清场屏障的证据；仅本地发送排空不足以证明清场。
 *
 * @discussion
 * [EN]: An unclean release blocks both file and realtime admission until a newer connection generation.
 * [CN]: 未确认清场的释放会阻止文件及实时准入，直至更新的物理连接代次。
 */
- (void)finishRealtimeOperation:(nullable NSUUID *)identifier deviceStateKnownClean:(BOOL)clean;

/**
 * @brief Atomically convert a realtime lease into an exclusive file registration
 * @chinese 将实时租约原子转换为独占的文件登记
 *
 * @param identifier
 * EN: Active realtime lease identity after its audio requests have drained.
 * CN: 音频请求已经排空后的有效实时租约标识。
 *
 * @param upload
 * EN: YES selects TP upload; NO selects PB.
 * CN: YES 选择 TP 上传，NO 选择 PB。
 *
 * @param error
 * EN: Receives the admission error for an inactive lease.
 * CN: 租约无效时返回准入错误。
 *
 * @return
 * EN: File identity to finish with finishOperation:deviceStateKnownClean:, or nil.
 * CN: 交由 finishOperation:deviceStateKnownClean: 释放的文件标识，失败为 nil。
 *
 * @discussion
 * [EN]: Reservation remains exclusive until the returned file registration finishes; no sender is started.
 * [CN]: 返回的文件登记结束前持续独占；本方法不启动文件发送器。
 */
- (nullable NSUUID *)convertRealtimeOperation:(NSUUID *)identifier
                                   toUpload:(BOOL)upload
                                      error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Reclaim a completed file reservation as a realtime lease
 * @chinese 将已完成的文件登记回收为实时租约
 * @param identifier EN: Reserved file operation. CN: 已登记的文件事务。
 * @param owner EN: Original realtime owner. CN: 原实时所有者。
 * @param generation EN: Original connection generation. CN: 原连接代次。
 * @param error EN: Reclaim error. CN: 回收错误。
 * @return New realtime lease or nil / 新实时租约或nil。
 */
- (nullable NSUUID *)reclaimFileOperationToRealtime:(NSUUID *)identifier
                                               owner:(NSString *)owner
                                         generation:(NSUInteger)generation
                                              error:(NSError * _Nullable * _Nullable)error;
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
