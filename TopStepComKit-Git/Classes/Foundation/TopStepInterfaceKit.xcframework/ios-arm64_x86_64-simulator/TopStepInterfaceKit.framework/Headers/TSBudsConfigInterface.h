//
//  TSBudsConfigInterface.h
//  TopStepInterfaceKit
//

#import "TSKitBaseInterface.h"
#import "TSBudsConfigDefines.h"
#import "TSBudsConfigCapabilities.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Physical operation mapping callback
 * @chinese 物理操作映射回调
 *
 * @param mapping
 * EN: Mapping from TSBudsPhysicalOperation keys to TSBudsPhysicalFunction values, nil if retrieval fails.
 * CN: 以 TSBudsPhysicalOperation 为键、TSBudsPhysicalFunction 为值的映射，获取失败时为 nil。
 *
 * @param error
 * EN: Error information, nil if successful.
 * CN: 错误信息，成功时为 nil。
 *
 * @discussion
 * EN: The callback is delivered on the main queue.
 * CN: 回调在主队列交付。
 */
typedef void (^TSBudsPhysicalOperationsResultBlock)(NSDictionary<NSNumber *, NSNumber *> * _Nullable mapping,
                                                    NSError * _Nullable error);

/**
 * @brief AI image resolution callback
 * @chinese AI 识图清晰度回调
 *
 * @param mode
 * EN: Observed AI image resolution mode, Unknown if unavailable.
 * CN: 设备观测的 AI 识图清晰度档位，不可用时为 Unknown。
 *
 * @param error
 * EN: Error information, nil if successful.
 * CN: 错误信息，成功时为 nil。
 *
 * @discussion
 * EN: The callback is delivered on the main queue.
 * CN: 回调在主队列交付。
 */
typedef void (^TSBudsImageResolutionResultBlock)(TSBudsImageResolutionMode mode, NSError * _Nullable error);

/**
 * @brief Video frame direction callback
 * @chinese 录像画幅方向回调
 *
 * @param direction
 * EN: Observed video frame direction, Unknown if unavailable.
 * CN: 设备观测的录像画幅方向，不可用时为 Unknown。
 *
 * @param error
 * EN: Error information, nil if successful.
 * CN: 错误信息，成功时为 nil。
 *
 * @discussion
 * EN: The callback is delivered on the main queue.
 * CN: 回调在主队列交付。
 */
typedef void (^TSBudsVideoDirectionResultBlock)(TSBudsVideoRecordDirection direction, NSError * _Nullable error);

/**
 * @brief Buds device configuration interface
 * @chinese Buds 设备配置接口
 *
 * @discussion
 * EN: This interface defines Buds configuration operations, including:
 *     1. Read, assign and observe physical operation mappings
 *     2. Read, set and observe AI image resolution
 *     3. Read, set and observe video frame direction
 * CN: 该接口定义 Buds 设备配置操作，包括：
 *     1. 读取、设置和监听物理操作映射
 *     2. 读取、设置和监听 AI 识图清晰度
 *     3. 读取、设置和监听录像画幅方向
 *
 * @note
 * EN: The inherited isSupport method indicates that at least one configuration group is available.
 *     Check capabilities separately for each group. These operations are independent of capture and AI sessions.
 *     Audio work mode is provided separately by TSWorkModeInterface.
 * CN: 继承的 isSupport 方法表示至少一组配置可用，具体配置须分别检查 capabilities。
 *     配置操作独立于拍摄和 AI 会话，音频工作模式由独立的 TSWorkModeInterface 提供。
 */
@protocol TSBudsConfigInterface <TSKitBaseInterface>

/**
 * @brief Current device configuration capabilities
 * @chinese 当前设备配置能力
 *
 * @discussion
 * EN: Snapshot of configuration availability based on the ready device, adapter and public SDK APIs.
 * CN: 根据当前就绪设备、适配器和公开 SDK API 生成的配置能力快照。
 *
 * @note
 * EN: Read on the main queue. An overall isSupport result of YES does not imply that every group is supported.
 * CN: 须在主队列读取。整体 isSupport 为 YES 不代表每组配置均受支持。
 */
@property (nonatomic, strong, readonly) TSBudsConfigCapabilities *capabilities;

/**
 * @brief Get current physical operation mappings
 * @chinese 获取当前物理操作映射
 *
 * @param completion
 * EN: Completion callback, delivered once on the main queue.
 *     - mapping: Current operation mappings, nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调，在主队列交付一次。
 *     - mapping: 当前操作映射，获取失败时为 nil
 *     - error: 获取失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: Reads observations or the SDK cache for the current connection without sending a device query.
 *     A missing cache produces an error rather than an empty successful result.
 * CN: 读取当前连接的设备观测或 SDK 缓存，不发送设备查询命令。
 *     缓存尚未取得时返回错误，不生成空的成功结果。
 */
- (void)getPhysicalOperationsMapping:(nullable TSBudsPhysicalOperationsResultBlock)completion
    NS_SWIFT_NAME(getPhysicalOperationsMapping(completion:));

/**
 * @brief Assign a function to a physical operation
 * @chinese 为物理操作分配功能
 *
 * @param function
 * EN: Function to assign. TSBudsPhysicalFunctionNone is a valid value.
 * CN: 要分配的功能，TSBudsPhysicalFunctionNone 为合法值。
 *
 * @param operation
 * EN: Physical operation to configure. Unknown is invalid.
 * CN: 要配置的物理操作，Unknown 为非法值。
 *
 * @param completion
 * EN: Completion callback, delivered once on the main queue within ten seconds.
 *     - success: Whether the SDK command completed successfully
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调，十秒内在主队列交付一次。
 *     - success: SDK 命令是否成功完成
 *     - error: 设置失败时的错误信息，成功时为 nil
 *
 * @note
 * EN: The device may reject specific operation/function combinations. Command success does not create
 *     a device change event or update the observed mapping locally.
 * CN: 设备可能拒绝特定操作与功能组合。命令成功不会生成设备变化事件，也不会在本地修改观测映射。
 */
- (void)assignFunction:(TSBudsPhysicalFunction)function
    forPhysicalOperation:(TSBudsPhysicalOperation)operation
              completion:(nullable TSCompletionBlock)completion
    NS_SWIFT_NAME(assign(function:operation:completion:));

/**
 * @brief Register a physical operation mapping observer
 * @chinese 注册物理操作映射监听
 *
 * @param handler
 * EN: Observer callback, delivered on the main queue. Pass nil to remove the observer.
 *     - mapping: Device-reported mappings, nil if unavailable
 *     - error: Error information for invalid data or connection invalidation, nil if successful
 * CN: 在主队列交付的监听回调，传 nil 注销监听。
 *     - mapping: 设备上报的映射，不可用时为 nil
 *     - error: 数据异常或连接失效时的错误信息，成功时为 nil
 *
 * @note
 * EN: A new handler replaces the current observer for this configuration entry.
 * CN: 新注册的 handler 会替换本配置入口的当前监听者。
 */
- (void)registerPhysicalOperationsMappingDidChanged:(nullable TSBudsPhysicalOperationsResultBlock)handler;

/**
 * @brief Get AI image resolution mode
 * @chinese 获取 AI 识图清晰度档位
 *
 * @param completion
 * EN: Completion callback, delivered once on the main queue.
 *     - mode: Current resolution mode, Unknown if unavailable
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调，在主队列交付一次。
 *     - mode: 当前清晰度档位，不可用时为 Unknown
 *     - error: 获取失败时的错误信息，成功时为 nil
 *
 * @note
 * EN: For a ready connection, SDK versions without a public configuration API return Unknown
 *     and a NotSupport error with reason sdk_api_unavailable.
 * CN: 连接就绪但 SDK 缺少公开配置 API 时，返回 Unknown 和带 sdk_api_unavailable 原因的 NotSupport 错误。
 */
- (void)getAIImageResolutionMode:(nullable TSBudsImageResolutionResultBlock)completion
    NS_SWIFT_NAME(getAIImageResolutionMode(completion:));

/**
 * @brief Set AI image resolution mode
 * @chinese 设置 AI 识图清晰度档位
 *
 * @param mode
 * EN: Resolution mode to set, from UltraFast to UltraQuality. Unknown is invalid.
 * CN: 要设置的清晰度档位，有效范围为 UltraFast 至 UltraQuality，Unknown 为非法值。
 *
 * @param completion
 * EN: Completion callback, delivered once on the main queue.
 *     - success: Whether the setting succeeded
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调，在主队列交付一次。
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 *
 * @note
 * EN: This setting is independent of video recording. For a ready connection and valid mode,
 *     a missing public SDK API produces a NotSupport error with reason sdk_api_unavailable.
 * CN: 该配置独立于视频录制。连接就绪且参数合法时，SDK 缺少公开 API 会返回带
 *     sdk_api_unavailable 原因的 NotSupport 错误。
 */
- (void)setAIImageResolutionMode:(TSBudsImageResolutionMode)mode completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Register an AI image resolution observer
 * @chinese 注册 AI 识图清晰度监听
 *
 * @param handler
 * EN: Observer callback, delivered on the main queue. Pass nil to unregister.
 *     - mode: Observed resolution mode, Unknown if unavailable
 *     - error: Error information if failed, nil if successful
 * CN: 在主队列交付的监听回调，传 nil 注销。
 *     - mode: 设备观测的清晰度档位，不可用时为 Unknown
 *     - error: 失败时的错误信息，成功时为 nil
 *
 * @note
 * EN: For a ready connection, SDK versions without a public configuration API report Unknown
 *     and NotSupport once when registering a nonnil handler.
 * CN: 连接就绪但 SDK 缺少公开配置 API 时，注册非 nil 的 handler 会回调一次 Unknown 与 NotSupport。
 */
- (void)registerAIImageResolutionModeDidChanged:(nullable TSBudsImageResolutionResultBlock)handler;

/**
 * @brief Get video frame direction
 * @chinese 获取录像画幅方向
 *
 * @param completion
 * EN: Completion callback, delivered once on the main queue.
 *     - direction: Current video frame direction, Unknown if unavailable
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调，在主队列交付一次。
 *     - direction: 当前录像画幅方向，不可用时为 Unknown
 *     - error: 获取失败时的错误信息，成功时为 nil
 *
 * @note
 * EN: For a ready connection, SDK versions without a public configuration API return Unknown
 *     and a NotSupport error with reason sdk_api_unavailable.
 * CN: 连接就绪但 SDK 缺少公开配置 API 时，返回 Unknown 和带 sdk_api_unavailable 原因的 NotSupport 错误。
 */
- (void)getVideoRecordDirection:(nullable TSBudsVideoDirectionResultBlock)completion
    NS_SWIFT_NAME(getVideoRecordDirection(completion:));

/**
 * @brief Set video frame direction
 * @chinese 设置录像画幅方向
 *
 * @param direction
 * EN: Video frame direction to set, Landscape or Portrait. Unknown is invalid.
 * CN: 要设置的录像画幅方向，可选 Landscape 或 Portrait，Unknown 为非法值。
 *
 * @param completion
 * EN: Completion callback, delivered once on the main queue.
 *     - success: Whether the setting succeeded
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调，在主队列交付一次。
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 *
 * @note
 * EN: Configures the video frame direction before capture, without implying rotation of photos or phone screens.
 *     For a ready connection and valid direction, a missing public SDK API produces NotSupport
 *     with reason sdk_api_unavailable.
 * CN: 用于拍摄前配置录像画幅方向，不表示旋转普通照片或手机屏幕。连接就绪且参数合法时，
 *     SDK 缺少公开 API 会返回带 sdk_api_unavailable 原因的 NotSupport 错误。
 */
- (void)setVideoRecordDirection:(TSBudsVideoRecordDirection)direction completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Register a video frame direction observer
 * @chinese 注册录像画幅方向监听
 *
 * @param handler
 * EN: Observer callback, delivered on the main queue. Pass nil to unregister.
 *     - direction: Observed video frame direction, Unknown if unavailable
 *     - error: Error information if failed, nil if successful
 * CN: 在主队列交付的监听回调，传 nil 注销。
 *     - direction: 设备观测的录像画幅方向，不可用时为 Unknown
 *     - error: 失败时的错误信息，成功时为 nil
 *
 * @note
 * EN: For a ready connection, SDK versions without a public configuration API report Unknown
 *     and NotSupport once when registering a nonnil handler.
 * CN: 连接就绪但 SDK 缺少公开配置 API 时，注册非 nil 的 handler 会回调一次 Unknown 与 NotSupport。
 */
- (void)registerVideoRecordDirectionDidChanged:(nullable TSBudsVideoDirectionResultBlock)handler;

@end

NS_ASSUME_NONNULL_END
