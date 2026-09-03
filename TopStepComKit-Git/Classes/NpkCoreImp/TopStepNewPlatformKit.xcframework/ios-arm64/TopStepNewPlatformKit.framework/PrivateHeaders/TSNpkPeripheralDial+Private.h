//
//  TSNpkPeripheralDial+Private.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import "TSNpkPeripheralDial.h"

@class TSDownloader;
@class TSManagedDownloadedFile;
@class TSDialDraft;
@class TSNpkDialStyleCloudService;
@class TSNpkDialStyleConstraintMapper;

NS_ASSUME_NONNULL_BEGIN

@interface TSNpkPeripheralDial ()

@property (nonatomic, strong, nullable) TSNpkDialStyleCloudService *dialStyleCloudService;
@property (nonatomic, strong, nullable) TSNpkDialStyleConstraintMapper *dialStyleConstraintMapper;
@property (nonatomic, strong, nullable) TSDownloader *dialTemplateDownloader;
@property (nonatomic, strong, nullable) NSURL *dialStyleServiceURL;
@property (nonatomic, strong, nullable) NSURLSessionTask *dialMetadataTask;
@property (nonatomic, strong, nullable) NSURLSessionTask *dialTemplateDownloadTask;
@property (nonatomic, strong, nullable) TSManagedDownloadedFile *managedDialTemplateFile;
@property (nonatomic, strong, nullable) NSUUID *managedDialTemplateOwnerToken;
@property (nonatomic, strong, nullable) NSUUID *customDialBuildToken;
@property (nonatomic, assign) BOOL customDialInstalling;
@property (nonatomic, assign) BOOL customDialCreatorStarted;
@property (nonatomic, assign) BOOL customDialBuildCancelled;
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
 * @brief Prepare style and template dependencies
 * @chinese 准备样式与模板依赖
 */
- (void)tsnpk_prepareDialStyleDependencies;

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
