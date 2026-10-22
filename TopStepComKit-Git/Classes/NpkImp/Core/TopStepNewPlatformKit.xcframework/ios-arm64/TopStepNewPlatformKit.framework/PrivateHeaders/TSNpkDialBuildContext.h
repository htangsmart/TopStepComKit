#import <Foundation/Foundation.h>
@class TSDialDraft, TSNpkDialDeviceProfile;
NS_ASSUME_NONNULL_BEGIN

/** @brief Inputs and isolated paths for one build; public task state belongs to the entry.
 * @chinese 单次构建输入与隔离路径，公开任务状态仍由入口持有。
 */
@interface TSNpkDialBuildContext : NSObject
/**
 * @brief Normalized working draft
 * @chinese 归一后的草稿工作副本
 *
 * @discussion
 * [EN]: Validated and copied by the capability resolver for this task. Referenced source files are not copied here.
 * [CN]: 由能力解析器校验并复制，供本任务使用；此处不复制草稿引用的磁盘源文件。
 */
@property (nonatomic, strong, readonly) TSDialDraft *draft;
/**
 * @brief Captured device profile
 * @chinese 已捕获的设备信息快照
 *
 * @discussion
 * [EN]: Retains the supplied validated profile for all stages; later peripheral changes do not refresh it.
 * [CN]: 各阶段共用传入且已校验的快照；外围设备后续变化不会刷新此对象。
 */
@property (nonatomic, strong, readonly) TSNpkDialDeviceProfile *deviceProfile;
/**
 * @brief Build task identifier
 * @chinese 构建任务标识
 *
 * @discussion
 * [EN]: Required UUID supplied by the entry to isolate paths and reject stale callbacks; distinct from dialId.
 * [CN]: 入口提供的必填 UUID，用于路径隔离及排除过期回调；与 dialId 不同。
 */
@property (nonatomic, copy, readonly) NSUUID *taskToken;
/**
 * @brief Task working directory
 * @chinese 本任务工作目录
 *
 * @discussion
 * [EN]: Created under Working/taskToken during context creation. The task entry owns eventual cleanup.
 * [CN]: 创建上下文时生成 Working/taskToken 目录；任务入口负责最终清理。
 */
@property (nonatomic, copy, readonly) NSString *workingDirectory;
/**
 * @brief Planned artifact publication directory
 * @chinese 产物的预定发布目录
 *
 * @discussion
 * [EN]: Artifacts/taskToken path reserved for this task; context creation does not create this directory.
 * [CN]: 本任务使用的 Artifacts/taskToken 路径；创建上下文时不会创建该目录。
 */
@property (nonatomic, copy, readonly) NSString *publicationDirectory;
/**
 * @brief Cooperative cancellation check
 * @chinese 协作取消检查
 *
 * @discussion
 * [EN]: Optional entry-owned check, invoked by worker stages. YES requests cancellation; nil disables checking.
 * [CN]: 入口提供的可选检查，可能由后台阶段调用；YES 表示请求取消，nil 表示不检查，不代表立即完成清理。
 */
@property (nonatomic, copy, nullable) BOOL (^cancellationCheck)(void);

/** @brief Capture normalized inputs and create isolated directories.
 * @chinese 捕获归一输入并创建隔离目录。
 * @param draft EN: Source draft. CN: 原始草稿。
 * @param profile EN: Validated device facts. CN: 设备事实。
 * @param taskToken EN: Build identity. CN: 构建标识。
 * @param error EN: Validation or directory error. CN: 校验或目录错误。
 * @return EN: Context or nil. CN: 上下文或 nil。
 */
+ (nullable instancetype)contextWithDraft:(TSDialDraft *)draft profile:(TSNpkDialDeviceProfile *)profile
                               taskToken:(NSUUID *)taskToken error:(NSError *_Nullable *_Nullable)error;
@end
NS_ASSUME_NONNULL_END
