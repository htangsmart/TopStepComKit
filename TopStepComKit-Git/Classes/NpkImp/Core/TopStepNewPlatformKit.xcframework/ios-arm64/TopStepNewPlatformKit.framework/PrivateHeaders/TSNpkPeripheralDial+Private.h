//
//  TSNpkPeripheralDial+Private.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import "TSNpkPeripheralDial.h"
#import "TSNpkDialStyleCloudService.h"

@class TSDownloader;
@class TSManagedDownloadedFile;
@class TSDialArtifact;
@class TSDialDraft;
@class TSDialInstallOptions;
@class TSNpkDialBuildContext;
@class TSNpkDialStyleResource;
@class TSNpkDialStyleCloudService;
@class TSNpkDialStyleConstraintMapper;
@class TSNpkDialGuiInstaller;
@class TSNpkFileTransferService;

NS_ASSUME_NONNULL_BEGIN

@interface TSNpkPeripheralDial ()

/**
 * @brief Cancel the active dial build or installation
 * @chinese 取消当前表盘造包或安装任务
 * @param completion EN: Cancellation result. CN: 取消结果。
 */
- (void)cancelDialInstall:(TSCompletionBlock)completion;

/**
 * @brief Install a dial while consuming a pre-admitted file operation
 * @chinese 使用已预留文件事务执行表盘安装
 * @param artifact EN: Prepared dial artifact. CN: 已准备的表盘产物。
 * @param options EN: Installation options. CN: 安装选项。
 * @param fileOperation EN: Realtime-handoff file reservation. CN: 实时交接返回的文件事务。
 * @param progressBlock EN: Progress callback. CN: 进度回调。
 * @param completion EN: Installation result. CN: 安装结果。
 */
- (void)installDial:(TSDialArtifact *)artifact
            options:(nullable TSDialInstallOptions *)options
preacquiredFileOperation:(nullable NSUUID *)fileOperation
      progressBlock:(nullable TSDialInstallProgressBlock)progressBlock
          completion:(TSDialInstallCompletionBlock)completion;

/**
 * @brief Context of the active local build
 * @chinese 当前本地造包上下文
 *
 * @discussion
 * [EN]: Holds the captured draft, device facts and workspace during a build;
 *       nil when no local build owns this entry.
 * [CN]: 造包期间持有草稿、设备信息和工作区；没有本地造包任务占用入口时为 nil。
 */
@property (nonatomic, strong, nullable) TSNpkDialBuildContext *activeDialBuildContext;
/**
 * @brief Pending cancellation result callback
 * @chinese 等待交付的取消结果回调
 *
 * @discussion
 * [EN]: At most one cancellation waits for task exit. Successful cancellation is
 *       delivered after cleanup; rejected cancellation may complete while the upload continues.
 * [CN]: 同时最多一个取消请求等待任务退出；取消成功在清理后交付，
 *       取消被拒绝时可先交付拒绝结果，原上传继续执行。
 */
@property (nonatomic, copy, nullable) TSCompletionBlock dialCancellationCompletion;
/**
 * @brief Identity of the active installation
 * @chinese 当前安装任务身份
 *
 * @discussion
 * [EN]: A per-installation UUID used to reject stale callbacks, not a dial identifier.
 *       Cleared when that installation finishes.
 * [CN]: 每次安装独立生成的 UUID，用于拒绝过期回调，不是表盘编号；安装结束时清空。
 */
@property (nonatomic, copy, nullable) NSUUID *dialInstallToken;
/**
 * @brief Whether package inspection is still preparing the installation
 * @chinese 是否仍在执行安装包检查准备
 *
 * @discussion
 * [EN]: YES while the worker prepares the package snapshot. Cancellation records
 *       intent and waits for preparation to return before cleaning its directory.
 * [CN]: 工作队列准备包快照时为 YES；取消只记录意图，
 *       等准备返回后再清理其目录。
 */
@property (nonatomic, assign) BOOL dialInstallPreparing;
/**
 * @brief Cancellation intent for the active installation
 * @chinese 当前安装的取消意图
 *
 * @discussion
 * [EN]: Set during preparation or when forwarding cancellation to transport.
 *       Cleared at completion or when cancellation is rejected; it is not a terminal result.
 * [CN]: 准备期间或向传输层转发取消时设置；结束或取消被拒绝时清除，
 *       该标记本身不是终态结果。
 */
@property (nonatomic, assign) BOOL dialInstallCancellationRequested;
/**
 * @brief GUI installer retained for the active upload
 * @chinese 当前 GUI 上传持有的安装器
 *
 * @discussion
 * [EN]: Owns the inspected package and captured transfer service for GUI installation.
 *       Nil on the PB path and cleared at installation completion.
 * [CN]: GUI 安装时持有已检查的包和捕获的传输服务；PB 路径为 nil，安装结束时清空。
 */
@property (nonatomic, strong, nullable) TSNpkDialGuiInstaller *dialGuiInstaller;
/**
 * @brief PB preparation token for scoped cancellation
 * @chinese 限定 PB 取消范围的准备令牌
 *
 * @discussion
 * [EN]: Returned by PB preparation and passed back when cancelling this operation.
 *       Nil before acquisition and after installation cleanup.
 * [CN]: 由 PB 准备流程返回，取消本次操作时原样传回；取得前和安装清理后为 nil。
 */
@property (nonatomic, copy, nullable) NSNumber *dialPBPrepareToken;
/**
 * @brief Temporary directory owned by the installation
 * @chinese 安装任务持有的临时目录
 *
 * @discussion
 * [EN]: Stores the input snapshot and any repacked upload. Removed at terminal cleanup;
 *       the caller's original package is outside this ownership.
 * [CN]: 保存输入快照及可能重打包的上传文件，终态清理时删除；
 *       调用方原始包不属于该目录的清理范围。
 */
@property (nonatomic, copy, nullable) NSString *dialInstallDirectory;
/**
 * @brief Public result callback of the active installation
 * @chinese 当前安装的公开结果回调
 *
 * @discussion
 * [EN]: Retained by the entry for final result delivery and cleared once the task
 *       finishes. Cancellation results use dialCancellationCompletion separately.
 * [CN]: 由入口持有并交付最终安装结果，任务结束时清空；
 *       取消结果另外通过 dialCancellationCompletion 交付。
 */
@property (nonatomic, copy, nullable) TSDialInstallCompletionBlock dialInstallCompletion;

/**
 * @brief Metadata service for the selected endpoint
 * @chinese 当前服务地址对应的元数据服务
 *
 * @discussion
 * [EN]: Created when style dependencies are prepared and replaced when the endpoint changes.
 * [CN]: 准备样式依赖时创建，服务地址变化时重新创建。
 */
@property (nonatomic, strong, nullable) TSNpkDialStyleCloudService *dialStyleCloudService;
/**
 * @brief Mapper from cloud style resources to public constraints
 * @chinese 云端样式资源到公开约束的映射器
 *
 * @discussion
 * [EN]: Lazily created with the style dependencies and reused for constraint queries.
 * [CN]: 准备样式依赖时按需创建，并复用于约束查询。
 */
@property (nonatomic, strong, nullable) TSNpkDialStyleConstraintMapper *dialStyleConstraintMapper;
/**
 * @brief Downloader for task-managed template and style files
 * @chinese 任务托管模板和样式文件的下载器
 *
 * @discussion
 * [EN]: Prepared on demand. Downloaded temporary files are cleaned or copied into
 *       the task workspace according to the owning build.
 * [CN]: 按需准备；下载临时文件按所属造包任务清理，或复制到该任务工作区。
 */
@property (nonatomic, strong, nullable) TSDownloader *dialTemplateDownloader;
/**
 * @brief Endpoint associated with the cached metadata service
 * @chinese 当前缓存元数据服务对应的接口地址
 *
 * @discussion
 * [EN]: Compared with the requested endpoint to decide whether the service must be recreated.
 * [CN]: 与请求地址比较，用于判断是否需要重新创建元数据服务。
 */
@property (nonatomic, strong, nullable) NSURL *dialStyleServiceURL;
/**
 * @brief Cancellable metadata request of the current build
 * @chinese 当前造包的可取消元数据请求
 *
 * @discussion
 * [EN]: Holds the new-endpoint request or its legacy fallback behind one handle;
 *       nil after completion or when no asynchronous request is needed.
 * [CN]: 用同一取消句柄持有新接口请求及其旧接口回退；
 *       请求完成或无需异步请求时为 nil。
 */
@property (nonatomic, strong, nullable) id<TSNpkDialStyleCancellable> dialMetadataTask;
/**
 * @brief Active template or style file download
 * @chinese 正在进行的模板或样式文件下载
 *
 * @discussion
 * [EN]: Captured only for the owning build token so cancellation does not affect another task.
 * [CN]: 仅由所属造包令牌捕获，避免取消操作影响其他任务。
 */
@property (nonatomic, strong, nullable) NSURLSessionTask *dialTemplateDownloadTask;
/**
 * @brief Managed download retained by the legacy template path
 * @chinese 旧模板解析路径持有的托管下载文件
 *
 * @discussion
 * [EN]: Cleanup is allowed only when managedDialTemplateOwnerToken matches the finishing build.
 * [CN]: 仅在 managedDialTemplateOwnerToken 与结束任务匹配时允许清理。
 */
@property (nonatomic, strong, nullable) TSManagedDownloadedFile *managedDialTemplateFile;
/**
 * @brief Owner token of the retained managed template
 * @chinese 所持托管模板的所有者令牌
 *
 * @discussion
 * [EN]: Paired with managedDialTemplateFile; prevents late cleanup from deleting a newer task's file.
 * [CN]: 与 managedDialTemplateFile 配对，防止晚到的清理删除新任务的文件。
 */
@property (nonatomic, strong, nullable) NSUUID *managedDialTemplateOwnerToken;
/**
 * @brief Identity of the active local build
 * @chinese 当前本地造包任务身份
 *
 * @discussion
 * [EN]: A per-build UUID used by asynchronous callbacks and cleanup; nil when no build is active.
 * [CN]: 每次造包独立的 UUID，供异步回调和清理核对；没有活动造包时为 nil。
 */
@property (nonatomic, strong, nullable) NSUUID *customDialBuildToken;
/**
 * @brief Whether the dial entry is occupied by a build or installation
 * @chinese 表盘入口是否被造包或安装占用
 *
 * @discussion
 * [EN]: Shared busy flag for both operations. Set at task admission and reset on terminal cleanup.
 * [CN]: 两类操作共用的忙标记，接纳任务时设置，终态清理时复位。
 */
@property (nonatomic, assign) BOOL customDialInstalling;
/**
 * @brief Whether the local build engine has started
 * @chinese 本地造包引擎是否已开始执行
 *
 * @discussion
 * [EN]: Set after the worker accepts the matching build token; reset when the build finishes.
 * [CN]: 工作队列确认造包令牌匹配后设置，造包结束时复位。
 */
@property (nonatomic, assign) BOOL customDialCreatorStarted;
/**
 * @brief Whether a completion path has claimed build finalization
 * @chinese 是否已有完成路径取得造包收尾权
 *
 * @discussion
 * [EN]: Prevents repeated callbacks from publishing the same task more than once.
 *       Set before publication and reset at final cleanup.
 * [CN]: 防止重复回调多次发布同一任务，发布前设置，最终清理时复位。
 */
@property (nonatomic, assign) BOOL customDialBuildFinishing;
/**
 * @brief Cancellation intent for the local build
 * @chinese 本地造包的取消意图
 *
 * @discussion
 * [EN]: Observed by cooperative stage checks and final publication. Setting it
 *       does not immediately release a workspace still in use.
 * [CN]: 由各阶段协作检查及最终发布流程读取；设置后不会立即释放仍在使用的工作区。
 */
@property (nonatomic, assign) BOOL customDialBuildCancelled;
/**
 * @brief Serial worker queue for local dial preparation
 * @chinese 本地表盘准备的串行工作队列
 *
 * @discussion
 * [EN]: Lazily created for build stages, package inspection and publication.
 *       Public result delivery is dispatched separately to the main thread.
 * [CN]: 懒创建，用于造包阶段、包检查和发布；公开结果交付另外切换到主线程。
 */
@property (nonatomic, strong) dispatch_queue_t customDialWorkerQueue;

@end

@interface TSNpkPeripheralDial (StyleConstraint)

/**
 * @brief Check the internal style-constraint capability
 * @chinese 检查内部样式约束能力
 * @return EN: Whether the capability is available. CN: 当前能力是否可用。
 */
- (BOOL)tsnpk_isSupportCustomDialStyleConstraint;

/**
 * @brief Fetch style constraints through the internal provider implementation
 * @chinese 通过 Provider 内部实现获取样式约束
 * @param completion EN: Constraint result callback. CN: 样式约束结果回调。
 */
- (void)tsnpk_fetchCustomDialStyleConstraint:(TSCustomDialStyleConstraintBlock)completion;

/**
 * @brief Fetch style constraints with an optional custom URL
 * @chinese 使用可选自定义 URL 获取样式约束
 * @param urlString
 * EN: Custom HTTPS endpoint, or nil for the default endpoint.
 * CN: 自定义 HTTPS 服务地址，nil 表示使用默认地址。
 * @param completion EN: Constraint result callback. CN: 样式约束结果回调。
 */
- (void)tsnpk_fetchCustomDialStyleConstraintWithURLString:(nullable NSString *)urlString
                                                completion:(TSCustomDialStyleConstraintBlock)completion;

/**
 * @brief Prepare style and template dependencies
 * @chinese 准备样式与模板依赖
 */
- (void)tsnpk_prepareDialStyleDependenciesWithEndpointURL:(NSURL *)endpointURL;

/** @brief Resolve templates using immutable build facts. @chinese 使用不可变造包事实解析模板。
 * @param context EN: Build snapshot. CN: 造包快照。
 * @param completion EN: Exactly one result, including cancellation. CN: 包括取消在内的单次结果。
 */
- (void)tsnpk_resolveTemplateForBuildContext:(TSNpkDialBuildContext *)context
    completion:(void (^)(TSNpkDialStyleResource *_Nullable resource, NSError *_Nullable error))completion;

/**
 * @brief Resolve a provider-compatible template into an isolated working draft
 * @chinese 解析 Provider 兼容模板并返回隔离的工作草稿
 * @param draft EN: Caller-owned source draft. CN: 调用方持有的源草稿。
 * @param buildToken EN: Owner token of this build. CN: 当前造包任务的所有权令牌。
 * @param completion EN: Resolved working draft or error. CN: 返回已解析的工作草稿或错误。
 */
- (void)tsnpk_resolveTemplateForDialDraft:(TSDialDraft *)draft
                                buildToken:(NSUUID *)buildToken
                               completion:(void (^)(TSDialDraft *_Nullable resolvedDraft,
                                                    NSError *_Nullable error))completion;

/**
 * @brief Check whether a build token still owns the active pre-cancel task
 * @chinese 检查造包令牌是否仍持有当前未取消任务
 * @param buildToken EN: Build owner token. CN: 造包任务所有权令牌。
 * @return EN: Whether the token is active. CN: 令牌是否仍处于活动状态。
 */
- (BOOL)tsnpk_isActiveCustomDialBuildToken:(NSUUID *)buildToken;

/**
 * @brief Clean the SDK-managed template owned by a build token
 * @chinese 清理由指定造包令牌持有的 SDK 模板下载文件
 * @param buildToken EN: Build owner token. CN: 造包任务所有权令牌。
 */
- (void)tsnpk_cleanupManagedDialTemplateForBuildToken:(NSUUID *)buildToken;

@end

NS_ASSUME_NONNULL_END
