//
//  TSDialArtifact.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/19.
//
//  文件说明:
//  表盘可安装产物。由自定义造包或云端下载生成，是"产出"与"安装"之间
//  的传递物，包含表盘类型、表盘 id 和表盘包路径。

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Installable watch face artifact
 * @chinese 表盘可安装产物
 *
 * @discussion
 * [EN]: Output of custom build or cloud download. It carries the watch face type,
 *       generated watch face id and package path. The underlying container format is
 *       not exposed; filePath is an opaque local handle.
 * [CN]: 自定义造包或云端下载的输出。承载表盘类型、生成后的表盘 id 和表盘包路径。
 *       底层容器格式不外泄，filePath 仅为不透明的本地句柄。
 */
@interface TSDialArtifact : TSKitBaseModel

/**
 * @brief Watch face id (opaque)
 * @chinese 表盘 id（不透明）
 *
 * @discussion
 * [EN]: Copied from the initializer and required to be nonempty during model validation.
 *       It identifies the package, not an installation slot or build task.
 *       Provider-specific package/id consistency is checked by the installation path.
 * [CN]: 从初始化参数复制，模型校验时必须非空。表示包编号，不是安装槽位或构建任务身份；
 *       包内容与编号是否一致由对应 Provider 的安装路径进一步检查。
 */
@property (nonatomic, copy, readonly) NSString *dialId;

/**
 * @brief Dial type
 * @chinese 表盘类型
 *
 * @discussion
 * [EN]: The installable artifact source type. It must be custom or cloud.
 * [CN]: 当前可安装产物的来源表盘类型，必须是自定义或云端。
 */
@property (nonatomic, assign, readonly) TSDialType dialType;

/**
 * @brief Built package local file path (opaque handle for install)
 * @chinese 已造包的本地文件路径（安装用不透明句柄）
 *
 * @discussion
 * [EN]: Copied from the initializer. Model validation requires a nonempty path to an
 *       existing file; format and device compatibility are checked during installation.
 *       Creating this model does not copy or delete the file. Keep the package available
 *       while a build or installation uses it, and do not infer its format from its suffix.
 * [CN]: 从初始化参数复制。模型校验要求路径非空且文件存在；格式及设备兼容性由安装流程检查。
 *       创建模型不会复制或删除文件；构建或安装使用期间应保持包可用，不通过后缀推断包格式。
 */
@property (nonatomic, copy, readonly) NSString *filePath;

/**
 * @brief Optional app preview file associated with the package
 * @chinese 与包关联的可选手机预览文件
 *
 * @discussion
 * [EN]: Copied from the initializer; constructors without a preview argument set nil.
 *       This is a separate app preview, not the package's embedded thumbnail or its
 *       installation path. SDK-published outputs are retained across later builds
 *       and cancellation. Callers may copy them to app-owned storage or remove them
 *       when no build or installation uses them; path copying does not duplicate files.
 * [CN]: 从初始化参数复制；不带预览参数的旧构造方法设为 nil。这是独立的手机预览，
 *       不是包内缩略图或安装路径。SDK 已发布产物不由后续构建或取消删除；
 *       调用方可复制至自管目录，或在没有构建、安装使用时删除；复制路径不会复制文件。
 */
@property (nonatomic, copy, nullable, readonly) NSString *previewFilePath;

/** @brief Initialize an artifact and its optional app preview.
 * @chinese 初始化产物及其可选手机预览。
 * @param dialType EN: Custom or cloud. CN: 自定义或云端类型。
 * @param dialId EN: Actual package id. CN: 包内实际编号。
 * @param filePath EN: Package path. CN: 包文件路径。
 * @param previewFilePath EN: Optional preview path. CN: 可选预览路径。
 * @return EN: Artifact. CN: 产物。
 */
- (instancetype)initWithDialType:(TSDialType)dialType
                         dialId:(NSString *)dialId
                       filePath:(NSString *)filePath
                previewFilePath:(nullable NSString *)previewFilePath NS_DESIGNATED_INITIALIZER;

/**
 * @brief Designated initializer
 * @chinese 指定初始化方法
 *
 * @param dialType
 * EN: Artifact dial type, custom or cloud.
 * CN: 产物表盘类型，自定义或云端。
 *
 * @param dialId
 * EN: Watch face id.
 * CN: 表盘 id。
 *
 * @param filePath
 * EN: Built package local file path.
 * CN: 已造包的本地文件路径。
 *
 * @return
 * EN: Initialized artifact.
 * CN: 初始化完成的产物。
 */
- (instancetype)initWithDialType:(TSDialType)dialType
                          dialId:(NSString *)dialId
                         filePath:(NSString *)filePath;

/**
 * @brief Disable default init method
 * @chinese 禁用默认初始化方法
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Disable new method
 * @chinese 禁用 new 方法
 */
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Create a custom watch face artifact
 * @chinese 创建自定义表盘产物
 *
 * @param dialId
 * EN: Watch face id.
 * CN: 表盘 id。
 *
 * @param filePath
 * EN: Built package local file path.
 * CN: 已造包的本地文件路径。
 *
 * @return
 * EN: Initialized custom artifact.
 * CN: 初始化完成的自定义表盘产物。
 */
- (instancetype)initWithDialId:(NSString *)dialId
                      filePath:(NSString *)filePath;

/**
 * @brief Convenience constructor with dial type
 * @chinese 带表盘类型的便利构造方法
 *
 * @param dialType
 * EN: Artifact dial type, custom or cloud.
 * CN: 产物表盘类型，自定义或云端。
 *
 * @param dialId
 * EN: Watch face id.
 * CN: 表盘 id。
 *
 * @param filePath
 * EN: Built package local file path.
 * CN: 已造包的本地文件路径。
 *
 * @return
 * EN: Initialized artifact.
 * CN: 初始化完成的产物。
 */
+ (instancetype)artifactWithDialType:(TSDialType)dialType
                              dialId:(NSString *)dialId
                            filePath:(NSString *)filePath;

/**
 * @brief Convenience constructor for custom watch face artifact
 * @chinese 自定义表盘产物便利构造方法
 *
 * @param dialId
 * EN: Watch face id.
 * CN: 表盘 id。
 *
 * @param filePath
 * EN: Built package local file path.
 * CN: 已造包的本地文件路径。
 *
 * @return
 * EN: Initialized custom artifact.
 * CN: 初始化完成的自定义表盘产物。
 */
+ (instancetype)artifactWithDialId:(NSString *)dialId
                          filePath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
