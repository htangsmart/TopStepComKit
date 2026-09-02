//
//  TSFitPeripheralDial+Private.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSFitPeripheralDial.h"

@class TSFitCustomDialBuildOperation;
@class TSFitCustomDialTemplateResolver;
@class TSFitCustomDialTimeImageResolver;
@class TSFitDialInstallSession;
@class TSFitDialStyleConstraintMapper;
@class TSFitDialTemplateDownloader;
@class TSFitDialTemplateRepository;
@class TSFitDialTemplateRequestContextLoader;

NS_ASSUME_NONNULL_BEGIN

@interface TSFitPeripheralDial ()

/** @brief Current custom-dial build operation @chinese 当前自定义表盘构建操作 */
@property (nonatomic, strong, nullable) TSFitCustomDialBuildOperation *customDialBuildOperation;
/** @brief Whether custom-dial build dependencies are being prepared @chinese 是否正在准备自定义表盘构建依赖 */
@property (nonatomic, assign) BOOL isPreparingCustomDial;
/** @brief Current dial install session @chinese 当前表盘安装会话 */
@property (nonatomic, strong, nullable) TSFitDialInstallSession *dialInstallSession;
/** @brief Shared custom-dial template resolver @chinese 共享自定义表盘模板解析器 */
@property (nonatomic, strong, nullable) TSFitCustomDialTemplateResolver *customDialTemplateResolver;
/** @brief Shared custom-dial time-image resolver @chinese 共享自定义表盘时间图片解析器 */
@property (nonatomic, strong, nullable) TSFitCustomDialTimeImageResolver *customDialTimeImageResolver;
/** @brief Shared custom-dial resource downloader @chinese 共享自定义表盘资源下载器 */
@property (nonatomic, strong, nullable) TSFitDialTemplateDownloader *customDialResourceDownloader;
/** @brief Shared template request context loader @chinese 共享模板请求上下文加载器 */
@property (nonatomic, strong, nullable) TSFitDialTemplateRequestContextLoader *customDialTemplateContextLoader;
/** @brief Shared template catalog repository @chinese 共享模板目录仓库 */
@property (nonatomic, strong, nullable) TSFitDialTemplateRepository *customDialTemplateRepository;
/** @brief Shared custom-dial style mapper @chinese 共享自定义表盘样式转换器 */
@property (nonatomic, strong, nullable) TSFitDialStyleConstraintMapper *customDialStyleConstraintMapper;
/** @brief Registered dial-list change handler @chinese 已注册的表盘列表变化回调 */
@property (nonatomic, copy, nullable) void (^dialListDidChangeHandler)(
    NSArray<TSDialModel *> *_Nullable allDials,
    NSError *_Nullable error);

@end

@interface TSFitPeripheralDial (StyleConstraint)

/**
 * @brief Prepare shared template dependencies for constraint queries and custom-dial builds
 * @chinese 为约束查询和自定义表盘构建准备共享模板依赖
 */
- (void)tsfit_prepareCustomDialTemplateDependencies;

/**
 * @brief Check custom dial style-constraint support in the Fit implementation
 * @chinese 检查 Fit 内部实现是否支持自定义表盘样式约束
 * @return EN: Whether style constraints are supported. CN: 是否支持样式约束。
 */
- (BOOL)tsfit_isSupportCustomDialStyleConstraint;

/**
 * @brief Fetch custom dial style constraints from the Fit implementation
 * @chinese 从 Fit 内部实现获取自定义表盘样式约束
 * @param completion EN: Constraint callback. CN: 样式约束回调。
 */
- (void)tsfit_fetchCustomDialStyleConstraint:(TSCustomDialStyleConstraintBlock)completion;

@end

@interface TSFitPeripheralDial (CustomDial)

/**
 * @brief Build a custom dial artifact through the Fit implementation
 * @chinese 通过 Fit 内部实现构建自定义表盘产物
 * @param draft EN: Custom dial draft. CN: 自定义表盘草稿。
 * @param completion EN: Artifact callback. CN: 表盘产物回调。
 */
- (void)tsfit_buildDialWithDraft:(TSDialDraft *)draft
                      completion:(void (^)(TSDialArtifact *_Nullable artifact,
                                            NSError *_Nullable error))completion;

/**
 * @brief Compose a custom dial preview through the Fit implementation
 * @chinese 通过 Fit 内部实现合成自定义表盘预览图
 * @param input EN: Preview composition input. CN: 预览图合成输入。
 * @param completion EN: Preview callback. CN: 预览图回调。
 */
- (void)tsfit_composeDialPreview:(TSComposePreviewInput *)input
                      completion:(void (^)(UIImage *_Nullable previewImage,
                                            NSError *_Nullable error))completion;

@end

@interface TSFitPeripheralDial (Install)

/**
 * @brief Install a dial artifact through the Fit implementation
 * @chinese 通过 Fit 内部实现安装表盘产物
 * @param artifact EN: Dial artifact. CN: 表盘产物。
 * @param progressBlock EN: Optional progress callback. CN: 可选进度回调。
 * @param completion EN: Final result callback. CN: 最终结果回调。
 */
- (void)tsfit_installDial:(TSDialArtifact *)artifact
            progressBlock:(nullable TSDialInstallProgressBlock)progressBlock
               completion:(TSDialInstallCompletionBlock)completion;

/**
 * @brief Cancel the active Fit dial installation
 * @chinese 取消当前 Fit 表盘安装任务
 * @param completion EN: Cancellation result callback. CN: 取消结果回调。
 */
- (void)tsfit_cancelDialInstall:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
