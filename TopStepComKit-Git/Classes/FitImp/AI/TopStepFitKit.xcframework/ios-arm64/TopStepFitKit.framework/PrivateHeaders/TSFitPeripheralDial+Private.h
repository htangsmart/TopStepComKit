//
//  TSFitPeripheralDial+Private.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSFitPeripheralDial.h"

@class TSFitCustomDialBuildOperation;
@class TSFitDialPreviewOptions;
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
 * @chinese 通过 Fit 内部实现构建自定义表盘产物，预览时间按固件组件能力决定
 * @param draft EN: Custom dial draft. CN: 自定义表盘草稿。
 * @param completion EN: Artifact callback. CN: 表盘产物回调。
 */
- (void)tsfit_buildDialWithDraft:(TSDialDraft *)draft
                      completion:(void (^)(TSDialArtifact *_Nullable artifact,
                                            NSError *_Nullable error))completion;

/**
 * @brief Build with explicit preview time rendering.
 * @chinese 构建时显式指定预览是否绘制时间；NO 时不解析时间图片。
 * @param draft EN: Dial draft. CN: 表盘草稿。
 * @param renderTime EN: Composite time in automatic previews. CN: 自动预览是否叠加时间。
 * @param completion EN: Result callback. CN: 结果回调。
 */
- (void)tsfit_buildDialWithDraft:(TSDialDraft *)draft
                      renderTime:(BOOL)renderTime
                      completion:(void (^)(TSDialArtifact *_Nullable artifact,
                                            NSError *_Nullable error))completion;

/** @brief Build with the existing template path. @chinese 使用既有模板路径构建，预览时间按固件组件能力决定。
 * @param draft EN: Template draft. CN: 模板草稿。
 * @param completion EN: Result callback. CN: 结果回调。
 */
- (void)tsfit_buildLegacyDialWithDraft:(TSDialDraft *)draft
                          completion:(void (^)(TSDialArtifact *_Nullable artifact, NSError *_Nullable error))completion;

/**
 * @brief Build with explicit preview time rendering.
 * @chinese 构建时显式指定预览是否绘制时间；NO 时不解析时间图片。
 * @param draft EN: Dial draft. CN: 表盘草稿。
 * @param renderTime EN: Composite time in automatic previews. CN: 自动预览是否叠加时间。
 * @param completion EN: Result callback. CN: 结果回调。
 */
- (void)tsfit_buildLegacyDialWithDraft:(TSDialDraft *)draft
                          renderTime:(BOOL)renderTime
                      completion:(void (^)(TSDialArtifact *_Nullable artifact, NSError *_Nullable error))completion;

/** @brief Check the captured device is still connected. @chinese 检查快照设备是否仍连接。
 * @param peripheral EN: Captured device. CN: 快照设备。
 * @return EN: Whether still current. CN: 是否仍为当前设备。
 */
- (BOOL)tsfit_isCurrentPeripheral:(TSPeripheral *)peripheral;

/** @brief Get the existing public preview-size contract. @chinese 获取现有公开预览尺寸契约。
 * @param peripheral EN: Device. CN: 设备。
 * @return EN: Public preview pixels. CN: 公开预览像素尺寸。
 */
- (CGSize)tsfit_effectivePreviewSizeForPeripheral:(TSPeripheral *)peripheral;

/** @brief Resolve semantic time placement. @chinese 解析语义时间位置。
 * @param backgroundSize EN: Screen pixels. CN: 屏幕像素尺寸。
 * @param timeImageSize EN: Style pixels. CN: 样式像素尺寸。
 * @param position EN: Semantic position. CN: 语义位置。
 * @return EN: Style rectangle. CN: 样式区域。
 */
- (CGRect)tsfit_timeRectForBackgroundSize:(CGSize)backgroundSize
                           timeImageSize:(CGSize)timeImageSize
                                position:(TSDialTimePosition)position;

/** @brief Deliver a build result on the main thread. @chinese 在主线程返回构建结果。
 * @param artifact EN: Optional artifact. CN: 可选产物。
 * @param error EN: Optional error. CN: 可选错误。
 * @param completion EN: Result callback. CN: 结果回调。
 */
- (void)tsfit_completeBuildWithArtifact:(nullable TSDialArtifact *)artifact
                                 error:(nullable NSError *)error
                            completion:(void (^)(TSDialArtifact *_Nullable artifact, NSError *_Nullable error))completion;

/** @brief Normalize build failures while retaining their cause. @chinese 归一构建错误并保留底层原因。
 * @param underlyingError EN: Optional underlying failure. CN: 可选底层错误。
 * @return EN: Public dial-domain error. CN: 公开表盘错误域错误。
 */
- (NSError *)tsfit_publicBuildError:(nullable NSError *)underlyingError;

/**
 * @brief Compose a custom dial preview through the Fit implementation
 * @chinese 通过 Fit 内部实现合成自定义表盘预览图，时间绘制按固件组件能力决定
 * @param input EN: Preview composition input. CN: 预览图合成输入。
 * @param completion EN: Preview callback. CN: 预览图回调。
 */
- (void)tsfit_composeDialPreview:(TSComposePreviewInput *)input
                      completion:(void (^)(UIImage *_Nullable previewImage,
                                            NSError *_Nullable error))completion;

/** @brief Compose with explicit time rendering. @chinese 显式控制预览时间绘制。
 * @param input EN: Preview input. CN: 预览输入。
 * @param renderTime EN: Resolve and render time. CN: 是否解析和绘制时间。
 * @param completion EN: Main-thread result. CN: 主线程结果回调。
 */
- (void)tsfit_composeDialPreview:(TSComposePreviewInput *)input
                      renderTime:(BOOL)renderTime
                      completion:(void (^)(UIImage *_Nullable previewImage,
                                            NSError *_Nullable error))completion;

/** @brief Resolve preview corner radius. @chinese 解析预览圆角。 */
- (CGFloat)tsfit_previewCornerRadiusForPeripheral:(TSPeripheral *)peripheral targetSize:(CGSize)targetSize;
/** @brief Resolve preview transparency. @chinese 解析预览透明背景要求。 */
- (BOOL)tsfit_previewRequiresTransparencyForPeripheral:(TSPeripheral *)peripheral;
/** @brief Resolve normalized time image, tint and placement. @chinese 统一解析时间图片方向、着色及位置。
 * @param time EN: Time settings. CN: 时间配置。
 * @param image EN: Resolved time image. CN: 已解析的时间图片。
 * @param backgroundSize EN: Background pixels. CN: 背景像素尺寸。
 * @param error EN: Layout failure. CN: 布局错误。
 * @return EN: Shared overlay parameters. CN: 共用叠加参数。
 */
- (nullable TSFitDialPreviewOptions *)tsfit_previewOptionsForTime:(TSDialTime *)time
                                                         image:(UIImage *)image
                                                backgroundSize:(CGSize)backgroundSize
                                                         error:(NSError *_Nullable *_Nullable)error;

@end

@interface TSFitPeripheralDial (GeneratedDial)

/** @brief Select a route from draft semantics and device eligibility. @chinese 根据草稿语义与设备资格选择路由。
 * @param draft EN: Validated draft. CN: 已校验草稿。
 * @param eligible EN: Captured platform and component eligibility. CN: 平台及组件资格。
 * @return EN: Whether generated routing is required. CN: 是否需要全代码生成路由。
 */
- (BOOL)tsfit_usesGeneratedRouteForDraft:(TSDialDraft *)draft eligible:(BOOL)eligible;

/** @brief Validate enhancement flags and video-backend availability. @chinese 校验增强能力及视频后端可用性。
 * @param draft EN: Validated draft. CN: 已校验草稿。
 * @param features EN: Effective enhancement bits. CN: 有效增强能力位。
 * @param videoAvailable EN: Whether video conversion is available. CN: 视频转码是否可用。
 * @return EN: Explicit support failure, or nil. CN: 明确的不支持原因，通过时为 nil。
 */
- (nullable NSError *)tsfit_generatedModeErrorForDraft:(TSDialDraft *)draft
                                             features:(uint8_t)features
                                       videoAvailable:(BOOL)videoAvailable;

/** @brief Build a generated Fit dial while preserving template compatibility. @chinese 构建全代码 Fit 表盘并保留模板兼容性，预览时间按固件组件能力决定。
 * @param draft EN: Validated draft. CN: 已校验草稿。
 * @param completion EN: Main-thread result, delivered once. CN: 主线程单次结果回调。
 */
- (void)tsfit_buildGeneratedDialWithDraft:(TSDialDraft *)draft
                             completion:(void (^)(TSDialArtifact *_Nullable artifact, NSError *_Nullable error))completion;

/**
 * @brief Build with explicit preview time rendering.
 * @chinese 构建时显式指定预览是否绘制时间；NO 时不解析时间图片。
 * @param draft EN: Dial draft. CN: 表盘草稿。
 * @param renderTime EN: Composite time in automatic previews. CN: 自动预览是否叠加时间。
 * @param completion EN: Result callback. CN: 结果回调。
 */
- (void)tsfit_buildGeneratedDialWithDraft:(TSDialDraft *)draft
                             renderTime:(BOOL)renderTime
                      completion:(void (^)(TSDialArtifact *_Nullable artifact, NSError *_Nullable error))completion;

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
