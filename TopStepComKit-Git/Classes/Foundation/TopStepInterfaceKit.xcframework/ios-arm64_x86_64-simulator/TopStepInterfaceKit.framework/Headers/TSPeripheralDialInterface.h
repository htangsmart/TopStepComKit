//
//  TSPeripheralDialInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/18.
//
//  文件说明:
//  外设表盘管理接口，提供表盘能力、查询、选择、构建、安装、卸载、
//  存储、预览与变化监听能力

/**
 * @brief Peripheral watch face management interface
 * @chinese 外设表盘管理接口
 *
 * @discussion
 * [EN]: Defines the public watch face lifecycle for peripheral devices: capability,
 *       query, selection, build, install, uninstall, storage, preview and change events.
 *
 * [CN]: 定义外设表盘生命周期公共能力，包括能力、查询、选择、构建、安装、卸载、
 *       存储、预览与变化事件。
 *
 * @note
 * [EN]: Model roles: TSDialModel describes device watch faces, TSDialDraft describes
 *       custom build inputs, and TSDialArtifact is the only install input.
 * [CN]: 模型职责：TSDialModel 表示设备表盘，TSDialDraft 表示自定义构建输入，
 *       TSDialArtifact 是安装唯一入参。
 */

#import "TSKitBaseInterface.h"
#import "TSDialModel.h"
#import "TSDialDefines.h"
#import "TSDialCapability.h"
#import "TSDialStorage.h"
#import "TSDialArtifact.h"
#import "TSComposePreviewInput.h"
#import "TSDialDraft.h"
#import "TSCustomDialStyleConstraint.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Watch face operation completion callback
 * @chinese 表盘操作完成回调
 *
 * @param result
 * EN: Operation result.
 * CN: 操作结果。
 *
 * @param error
 * EN: Error information if failed, nil if successful.
 * CN: 操作失败时的错误信息，成功时为 nil。
 */
typedef void (^TSDialInstallCompletionBlock)(TSDialInstallResult result, NSError *_Nullable error);

/**
 * @brief Watch face install progress callback
 * @chinese 表盘安装进度回调
 *
 * @param result
 * EN: Current install state.
 * CN: 当前安装状态。
 *
 * @param progress
 * EN: Current progress from 0 to 100.
 * CN: 当前进度，范围 0 到 100。
 */
typedef void (^TSDialInstallProgressBlock)(TSDialInstallResult result, NSInteger progress);

/**
 * @brief Watch face list callback
 * @chinese 表盘列表回调
 *
 * @param dials
 * EN: Watch face models, or nil if retrieval fails.
 * CN: 表盘模型列表；获取失败时为 nil。
 *
 * @param error
 * EN: Error information if failed, nil if successful.
 * CN: 获取失败时的错误信息，成功时为 nil。
 */
typedef void (^TSDialListBlock)(NSArray<TSDialModel *> *_Nullable dials, NSError *_Nullable error);

/**
 * @brief Widget list callback for Fw series devices
 * @chinese Fw 系列设备挂件列表回调
 *
 * @param widgets
 * EN: Widget information dictionary, or nil if unsupported or failed.
 * CN: 挂件信息字典；不支持或获取失败时为 nil。
 *
 * @param error
 * EN: Error information if failed, nil if successful.
 * CN: 获取失败时的错误信息，成功时为 nil。
 */
typedef void (^TSDialWidgetsBlock)(NSDictionary *_Nullable widgets, NSError *_Nullable error);

/**
 * @brief Custom watch face style constraint callback
 * @chinese 自定义表盘样式约束回调
 *
 * @param constraint
 * EN: Provider-neutral style constraint, or nil when retrieval fails.
 * CN: Provider 无关的样式约束；获取失败时为 nil。
 *
 * @param error
 * EN: Error information if retrieval fails, nil on success.
 * CN: 获取失败时的错误信息，成功时为 nil。
 */
typedef void (^TSCustomDialStyleConstraintBlock)(TSCustomDialStyleConstraint *_Nullable constraint,
                                                  NSError *_Nullable error);

/**
 * @brief Peripheral watch face management interface
 * @chinese 外设表盘管理接口
 *
 * @discussion
 * EN: Exposes watch face capability, query, selection, build, install, uninstall,
 *     storage, preview, widget and event APIs.
 * CN: 提供表盘能力、查询、选择、构建、安装、卸载、存储、预览、挂件与事件接口。
 */
@protocol TSPeripheralDialInterface <TSKitBaseInterface>

#pragma mark - Capability

/**
 * @brief Fetch static watch face capability snapshot
 * @chinese 获取表盘静态能力快照
 *
 * @return
 * EN: Capability flags and numeric limits from cached device info, or nil when unavailable.
 * CN: 基于本地缓存设备信息生成的能力与限制；不可用时返回 nil。
 */
- (nullable TSDialCapability *)dialCapability;

#pragma mark - Custom Dial Style

/**
 * @brief Check whether custom watch face style constraints are supported
 * @chinese 检查是否支持自定义表盘样式约束
 *
 * @return
 * EN: YES when the current device and Provider support custom watch face style constraints.
 * CN: 当前设备和 Provider 支持自定义表盘样式约束时返回 YES。
 */
- (BOOL)isSupportCustomDialStyleConstraint;

/**
 * @brief Fetch custom watch face style constraints
 * @chinese 获取自定义表盘样式约束
 *
 * @param completion
 * EN: Called exactly once on the main thread with the constraint or error.
 * CN: 在主线程恰好回调一次，返回样式约束或错误信息。
 */
- (void)fetchCustomDialStyleConstraint:(TSCustomDialStyleConstraintBlock)completion;

#pragma mark - Query

/**
 * @brief Fetch all watch faces on device
 * @chinese 获取设备上的全部表盘
 *
 * @param completion
 * EN: Returns built-in, custom and cloud watch faces, or error.
 * CN: 返回内置、自定义、云端表盘列表或错误信息。
 */
- (void)fetchAllDials:(TSDialListBlock)completion;

/**
 * @brief Fetch current watch face
 * @chinese 获取当前表盘
 *
 * @param completion
 * EN: Returns the selected watch face, or error.
 * CN: 返回当前选中的表盘或错误信息。
 */
- (void)fetchCurrentDial:(void (^)(TSDialModel *_Nullable dial,
                                   NSError *_Nullable error))completion;

/**
 * @brief Fetch watch face storage snapshot
 * @chinese 获取表盘存储空间快照
 *
 * @param completion
 * EN: Returns free and total bytes for watch face storage, or error.
 * CN: 返回表盘存储剩余空间与总空间（字节）或错误信息。
 */
- (void)fetchDialStorage:(void (^)(TSDialStorage *_Nullable storage,
                                    NSError *_Nullable error))completion;

#pragma mark - Selection

/**
 * @brief Select current watch face
 * @chinese 选择当前表盘
 *
 * @param dialId
 * EN: Watch face identifier already installed on the device.
 * CN: 设备上已安装的表盘标识符。
 *
 * @param completion
 * EN: Required callback reporting whether the select command succeeds.
 * CN: 必传回调，返回选择指令是否成功。
 */
- (void)selectDial:(NSString *)dialId completion:(TSCompletionBlock)completion;

#pragma mark - Build

/**
 * @brief Build a custom watch face package from a draft
 * @chinese 根据草稿构建自定义表盘包
 *
 * @param draft
 * EN: Ready-made custom watch face materials. The app prepares crop, trim and screen size.
 * CN: 自定义表盘成品素材；App 负责裁剪、截取与屏幕尺寸适配。
 *
 * @param completion
 * EN: Returns an installable artifact, or error.
 * CN: 返回可安装产物或错误信息。
 *
 * @discussion
 * EN: The returned TSDialArtifact is passed to installDial:progressBlock:completion:.
 *     When draft.templateFilePath is nil, the Provider resolves a compatible template.
 *     The SDK validates image, preview and video dimensions against the connected
 *     device screen during build.
 * CN: 返回的 TSDialArtifact 用于 installDial:progressBlock:completion:。
 *     draft.templateFilePath 为空时，由 Provider 解析兼容模板。
 *     SDK 会在造包阶段结合当前连接设备屏幕校验图片、预览图与视频尺寸。
 */
- (void)buildDialWithDraft:(TSDialDraft *)draft
                completion:(void (^)(TSDialArtifact *_Nullable artifact, NSError *_Nullable error))completion;

/**
 * @brief Compose watch face preview image
 * @chinese 合成表盘预览图
 *
 * @param input
 * EN: Preview composition input, including background, time image, layout and size limit.
 * CN: 预览合成入参，包含背景、时间图、布局与大小限制。
 *
 * @param completion
 * EN: Returns preview image, or error.
 * CN: 返回预览图或错误信息。
 */
- (void)composeDialPreview:(TSComposePreviewInput *)input
                completion:(void (^)(UIImage *_Nullable previewImage,
                                      NSError *_Nullable error))completion;

#pragma mark - Install

/**
 * @brief Install a watch face artifact
 * @chinese 安装表盘产物
 *
 * @param artifact
 * EN: Installable custom or cloud artifact.
 * CN: 自定义或云端可安装产物。
 *
 * @param progressBlock
 * EN: Optional install progress, result plus 0-100 progress.
 * CN: 可选安装进度，包含 result 与 0-100 进度。
 *
 * @param completion
 * EN: Required callback reporting final install result and error.
 * CN: 必传回调，返回最终安装结果与错误信息。
 *
 * @discussion
 * EN: The artifact keeps the custom draft type used during build.
 * CN: artifact 会保留造包时使用的自定义草稿类型。
 */
- (void)installDial:(TSDialArtifact *)artifact
      progressBlock:(nullable TSDialInstallProgressBlock)progressBlock
         completion:(TSDialInstallCompletionBlock)completion;

/**
 * @brief Cancel current watch face install task
 * @chinese 取消当前表盘安装任务
 *
 * @param completion
 * EN: Reports whether the cancel command succeeds.
 * CN: 返回取消指令是否成功。
 */
- (void)cancelDialInstall:(TSCompletionBlock)completion;

/**
 * @brief Uninstall watch face
 * @chinese 卸载表盘
 *
 * @param dialId
 * EN: Watch face identifier to uninstall.
 * CN: 要卸载的表盘标识符。
 *
 * @param completion
 * EN: Required callback reporting whether the uninstall command succeeds.
 * CN: 必传回调，返回卸载指令是否成功。
 *
 * @discussion
 * EN: Built-in watch faces cannot be uninstalled.
 * CN: 内置表盘不能卸载。
 */
- (void)uninstallDial:(NSString *)dialId completion:(TSCompletionBlock)completion;

#pragma mark - Event

/**
 * @brief Register watch face list change handler
 * @chinese 注册表盘列表变化回调
 *
 * @param handler
 * EN: Handler called after the watch face list changes. Returns all current watch faces, or error.
 * CN: 表盘列表变化后的回调，返回当前全部表盘或错误信息。
 *
 * @discussion
 * EN: Only one handler is retained; a later registration replaces the previous one.
 *     The device does not report whether the change was caused by install, uninstall or select.
 * CN: 仅保留一个回调；后注册的回调会覆盖之前的回调。
 *     设备不会上报该变化由安装、卸载或选择触发。
 */
- (void)registerDialListDidChangeHandler:(void (^)(NSArray<TSDialModel *> *_Nullable allDials,
                                                   NSError *_Nullable error))handler;

#pragma mark - Widget

/**
 * @brief Fetch supported watch face widgets
 * @chinese 获取支持的表盘挂件
 *
 * @param completion
 * EN: Returns widget information for supported devices, or error.
 * CN: 返回支持设备的挂件信息或错误信息。
 *
 * @discussion
 * EN: Mainly used by Fw series devices; unsupported devices may return nil with an error.
 * CN: 主要用于 Fw 系列设备；不支持的设备可返回 nil 与错误信息。
 */
- (void)fetchSupportedDialWidgets:(TSDialWidgetsBlock)completion;

@end

NS_ASSUME_NONNULL_END
