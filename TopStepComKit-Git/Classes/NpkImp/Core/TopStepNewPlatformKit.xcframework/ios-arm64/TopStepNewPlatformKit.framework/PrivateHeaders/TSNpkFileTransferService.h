#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import "TSNpkPlatform.h"

NS_ASSUME_NONNULL_BEGIN

/** @brief Raw payload types supported by this service. @chinese 本服务支持的原始文件类型。 */
typedef NS_ENUM(uint8_t, TSNpkFileTransferType) {
    TSNpkFileTransferTypeEpo = 17,       // 星历
    TSNpkFileTransferTypeMusic = 23,     // 音乐
    TSNpkFileTransferTypeOfflineMap = 25 // 离线地图
};

/**
 * @brief Captures the transfer route and adapts a single NPK upload.
 * @chinese 捕获文件传输路由并适配一次 NPK 上传，仅供平台内部使用。
 */
@interface TSNpkFileTransferService : NSObject

/**
 * @brief Whether the captured route uses TP
 * @chinese 捕获的传输路由是否使用 TP
 *
 * @discussion
 * [EN]: Captured by serviceWithError: after matching authenticated device information
 *       to the current peripheral and connection generation. YES only for GUI579X;
 *       all other reported platform values retain PB compatibility. It does not
 *       imply that the uploader has started or that the device channel is available.
 * [CN]: serviceWithError: 将已认证设备信息与当前外设及连接代次核对后捕获。
 *       仅 GUI579X 为 YES，其余已上报平台值保持 PB 兼容；不表示上传已开始或通道已可用。
 */
@property (nonatomic, assign, readonly) BOOL usesNewTransfer;

/**
 * @brief Actual platform reported by the authenticated connection.
 * @chinese 当前已认证连接上报的实际平台。
 *
 * @discussion
 * [EN]: Captured by serviceWithError: after authenticated device information is matched
 *       to the current peripheral identifier and connection generation.
 * [CN]: serviceWithError: 将已认证设备信息与当前外设标识、连接代次核对后，
 *       捕获本次操作对应的实际平台值。
 *
 * @note
 * [EN]: Valid on a service successfully created with serviceWithError:. Each business
 *       must validate its supported platform range; this value alone does not imply support.
 * [CN]: 仅在 serviceWithError: 成功创建的服务对象中有效。
 *       业务应自行校验支持的平台范围，不能仅凭该值认定功能已支持。
 */
@property (nonatomic, assign, readonly) TSNpkPlatform platform;

/**
 * @brief Original peripheral identifier captured for this operation.
 * @chinese 本操作捕获的原始设备标识。
 *
 * @discussion
 * [EN]: Captured from the current uploader connection by serviceWithError: after
 *       matching authenticated device information. Used to verify ownership of
 *       business queries and transfer operations.
 * [CN]: serviceWithError: 核对已认证设备信息后，从当前上传器连接捕获设备标识，
 *       供业务查询和传输操作检查归属。
 *
 * @note
 * [EN]: Valid on a service successfully created with serviceWithError:. This is a copied
 *       operation snapshot; verify it together with connectionGeneration before use.
 * [CN]: 仅在 serviceWithError: 成功创建的服务对象中有效。该值是复制保存的操作快照，
 *       使用时应结合 connectionGeneration 核对归属。
 */
@property (nonatomic, copy, readonly) NSUUID *deviceIdentifier;

/**
 * @brief Original connection generation captured for this operation.
 * @chinese 本操作捕获的原始连接代次。
 *
 * @discussion
 * [EN]: Captured from the current uploader connection by serviceWithError: together
 *       with deviceIdentifier, identifying the authenticated connection for this operation.
 * [CN]: serviceWithError: 从当前上传器连接捕获，并与 deviceIdentifier 一起标识
 *       本次操作所属的已认证连接。
 *
 * @note
 * [EN]: Valid on a service successfully created with serviceWithError:. Reconnecting
 *       the same device invalidates the old generation; do not reuse it for a new connection.
 * [CN]: 仅在 serviceWithError: 成功创建的服务对象中有效。
 *       同一设备重连也会使旧代次失效，不得将其复用于新连接。
 */
@property (nonatomic, assign, readonly) NSUInteger connectionGeneration;

/**
 * @brief Whether this service operation has not reached its terminal state
 * @chinese 本服务操作是否尚未进入终态
 *
 * @discussion
 * [EN]: Initially YES, including asynchronous business preparation. Becomes NO when
 *       the service accepts its terminal result, before cleanup and result delivery.
 *       It may remain YES while cancellation is pending or rejected after END submission.
 *       This is not a global busy flag and does not track a PB transfer run outside this service.
 * [CN]: 初始为 YES，包含业务异步准备阶段；服务接收终态后、清理和结果回调前变为 NO。
 *       取消等待中或 END 提交后拒绝取消时仍可能为 YES。它不是全局忙标记，
 *       也不跟踪绕过本服务执行的 PB 传输。
 */
@property (nonatomic, assign, readonly, getter=isActive) BOOL active;

/**
 * @brief Cleanup block for resources owned by this preparation task
 * @chinese 本次准备任务所拥有资源的清理回调
 *
 * @discussion
 * [EN]: Optional copied block, initially nil. The stored block is cleared and invoked
 *       on the main thread before the terminal business callback. Once upload starts,
 *       cleanup waits for the uploader's actual terminal result; a rejected cancellation
 *       does not trigger it. Assigning a non-nil block after termination schedules that
 *       block on the main thread immediately. The block must clean only task-owned resources.
 * [CN]: 可选的复制回调，初始为 nil。进入终态时先清除保存值，再于主线程执行，
 *       然后交付业务终态。上传开始后须等待上传器真实终态；取消被拒绝不触发清理。
 *       若终态后才赋入非空回调，会立即交由主线程执行；回调只应清理本任务拥有的资源。
 */
@property (nonatomic, copy, nullable) dispatch_block_t preparationCleanup;

/**
 * @brief Records device information from the same authenticated connection.
 * @chinese 记录同一次已认证连接返回的设备信息。
 * @param platform EN: Device platform: 0=LVGLW30, 1=LVGL579X, 2=GUI579X.
 *                 CN: 设备平台：0=LVGLW30、1=LVGL579X、2=GUI579X；仅 GUI579X 选择 TP，其余值保持 PB。
 * @param peripheral EN: Original peripheral. CN: 原始外设。
 * @param generation EN: Generation captured before requesting information. CN: 请求信息前捕获的连接代次。
 */
+ (void)recordPlatform:(TSNpkPlatform)platform peripheral:(CBPeripheral *)peripheral generation:(NSUInteger)generation;
/** @brief Invalidates the cached transfer route. @chinese 使缓存的传输路由失效。 */
+ (void)invalidateDeviceInformation;
/**
 * @brief Captures the current route before any asynchronous preparation.
 * @chinese 在异步准备前捕获当前连接及路由。
 * @param error EN: Connection or information error. CN: 连接或设备信息错误。
 * @return EN: An operation, or nil when not ready. CN: 操作对象；未就绪返回 nil。
 */
+ (nullable instancetype)serviceWithError:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Reserve a realtime-handoff file operation for the next upload
 * @chinese 为下一次上传绑定实时通道交接返回的文件事务
 * @param operationIdentifier
 * EN: File operation returned by the realtime handoff. CN: 实时交接返回的文件事务。
 */
- (void)setPreacquiredOperationIdentifier:(nullable NSUUID *)operationIdentifier;

/**
 * @brief Sets callbacks for this new-protocol operation.
 * @chinese 设置本次新协议操作的回调。
 * @param progress EN: Upload progress. CN: 上传进度。
 * @param success EN: Upload success. CN: 上传成功。
 * @param failure EN: Failure or cancellation. CN: 失败或取消。
 */
- (void)prepareWithProgress:(nullable TSFileTransferProgressBlock)progress
                   success:(nullable TSFileTransferSuccessBlock)success
                   failure:(nullable TSFileTransferFailureBlock)failure;
/**
 * @brief Verifies that preparation still belongs to the captured connection.
 * @chinese 校验准备任务仍属于捕获的原连接；失效时结束操作。
 * @return EN: YES if preparation may continue. CN: 可以继续准备时返回 YES。
 */
- (BOOL)continuePreparation;
/**
 * @brief Uploads raw bytes using a virtual container.
 * @chinese 使用虚拟容器上传原始文件。
 * @param path EN: Local file path. CN: 本地文件路径。
 * @param fileType EN: Protocol file type. CN: 协议文件类型。
 * @param fileName EN: Device-side name. CN: 设备端文件名。
 */
- (void)uploadRawFileAtPath:(NSString *)path fileType:(TSNpkFileTransferType)fileType fileName:(NSString *)fileName;
/**
 * @brief Uploads an existing container without changing its metadata.
 * @chinese 上传已有容器，不覆盖其元数据。
 * @param path EN: Container path. CN: 容器路径。
 */
- (void)uploadContainerAtPath:(NSString *)path;
/** @brief Upload a WATCHFACE container with an in-memory target slot.
 * @chinese 上传 WATCHFACE 容器，仅在内存中指定目标槽位。
 * @param path EN: Complete container. CN: 完整容器。
 * @param index EN: Optional slot index, nil preserves the header. CN: 可选槽位索引，nil 保持原头。
 */
- (void)uploadContainerAtPath:(NSString *)path itemIndexOverride:(nullable NSNumber *)index;
/**
 * @brief Upload a single TOPSTEP-packed game container
 * @chinese 上传单条目 TOPSTEP 打包游戏容器
 *
 * @param path
 * EN: Complete container; the source verifies one item of file type 7, 8 or 12 and pack type 2.
 * CN: 完整容器；数据源要求恰含一个文件类型为 7、8 或 12、打包类型为 2 的条目。
 *
 * @param index
 * EN: Optional integer in 0...255; nil preserves the header index. A supplied index requires
 *     storage_addr == 0 and changes only the in-memory index.
 * CN: 可选的 0...255 整数；nil 保留原头索引。指定索引时要求 storage_addr 为 0，
 *     只修改内存中的索引字节。
 *
 * @discussion
 * [EN]: Uses this service's captured connection and existing TP completion and cancellation rules.
 *       A valid successful END_ACK completes the transfer. Slot selection and replacement
 *       policy belong to the game adapter; game-list refresh is independent of success.
 * [CN]: 使用本服务捕获的连接及既有 TP 完成、取消规则。
 *       有效成功 END_ACK 表示推送完成。选槽和替换策略由游戏适配层负责；列表刷新独立于推送终态。
 */
- (void)uploadGameContainerAtPath:(NSString *)path targetSlotIndex:(nullable NSNumber *)index;
/**
 * @brief Ends failed preparation once.
 * @chinese 将准备失败收口为一次终态。
 * @param error EN: Preparation error. CN: 准备错误。
 */
- (void)failPreparationWithError:(NSError *)error;
/**
 * @brief Cancels preparation or delegates cancellation to the captured uploader.
 * @chinese 取消准备或转交给捕获的上传器；END 提交后保留原终态。
 * @param completion EN: Cancellation result. CN: 取消结果。
 */
- (void)cancelWithCompletion:(nullable TSCompletionBlock)completion;
@end
NS_ASSUME_NONNULL_END
