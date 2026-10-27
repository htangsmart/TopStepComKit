#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class TSDialGuiHeader, TSDialTime, TSNpkDialBuildContext, TSNpkDialDeviceProfile, TSNpkDialStyleResource;
NS_ASSUME_NONNULL_BEGIN
/**
 * @brief Validated GUI template snapshot shared by preview and package writing
 * @chinese 供预览与写包共用的已校验 GUI 模板快照
 */
@interface TSNpkDialGuiTemplateSnapshot : NSObject
/**
 * @brief Whether the template has a recognized writable time component
 * @chinese 模板是否具有已识别且可写的时间组件
 *
 * @discussion
 * [EN]: Derived from the template layout and Android GUIWriter component format.
 * [CN]: 根据模板布局与 Android GUIWriter 组件格式判定。
 *
 * @note
 * [EN]: Format compatibility does not replace device acceptance testing.
 * [CN]: 格式兼容性不能代替真机验收。
 */
@property (nonatomic, assign, readonly) BOOL supportsTimeCustomization;
/**
 * @brief Number of verified component styles
 * @chinese 已核验的组件样式数量
 *
 * @discussion
 * [EN]: Public identifiers 1...styleCount map to zero-based wire indices.
 * [CN]: 公开标识 1...styleCount 对应从零开始的协议索引。
 *
 * @note
 * [EN]: Zero for an unsupported component; recognized counts are 1...6.
 * [CN]: 不支持时为零，已识别格式允许 1...6 个样式。
 */
@property (nonatomic, assign, readonly) NSUInteger styleCount;
/**
 * @brief Supported positions and actual template frames
 * @chinese 支持的位置及真实模板区域
 *
 * @discussion
 * [EN]: Keys are TSDialTimePosition values; CGRect values use device pixels.
 * [CN]: 键为 TSDialTimePosition 数值，CGRect 值采用设备像素坐标。
 *
 * @note
 * [EN]: Empty for an unsupported component; absent positions are unavailable.
 * [CN]: 不支持组件时为空，缺失的位置不可选择。
 */
@property (nonatomic, copy, readonly) NSDictionary<NSNumber *, NSValue *> *positionFrames;
/**
 * @brief Effective preview time settings of a prepared task
 * @chinese 已准备任务的实际预览时间配置
 *
 * @discussion
 * [EN]: Uses the same resolved style, color and position as component writing.
 * [CN]: 与组件写入共用已解析的样式、颜色和位置。
 *
 * @note
 * [EN]: Nil for inspection-only snapshots or requests without a time preview.
 * [CN]: 仅检查的快照或无需时间预览的请求，此值为 nil。
 */
@property (nonatomic, copy, readonly, nullable) TSDialTime *previewTime;
/**
 * @brief Whether this task preserves template time settings after an unsupported edit
 * @chinese 本任务是否因时间编辑不可用而保留模板时间设置
 *
 * @discussion
 * [EN]: The writer clears all pending time changes together. Preview rendering ignores caller time artwork.
 * [CN]: 写包器同时清除待应用的时间改动，预览渲染不再使用调用方的新时间效果图。
 *
 * @note
 * [EN]: Defaults to NO; YES permits a background-only preview and does not advertise time customization.
 * [CN]: 默认 NO；为 YES 时允许仅提供背景预览，不代表模板支持时间定制。
 */
@property (nonatomic, assign, readonly) BOOL preservesTemplateTime;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

/**
 * @brief Validate dynamic GUI directories and rewrite recognized component fields
 * @chinese 校验动态 GUI 目录并改写已识别的组件字段
 */
@interface TSNpkDialGuiTemplateWriter : NSObject
/**
 * @brief Inspect an independent template copy against captured device facts
 * @chinese 对模板独立副本执行设备匹配与组件检查
 *
 * @param data
 * EN: Complete source bytes; an independent byte copy is retained.
 * CN: 完整源字节，内部持有独立字节副本。
 * @param profile
 * EN: Captured target device facts.
 * CN: 目标设备信息快照。
 * @param error
 * EN: Format or device mismatch error.
 * CN: 格式或设备不匹配错误。
 * @return
 * EN: Snapshot, or nil for invalid data. Unsupported components have empty capabilities.
 * CN: 快照，数据无效时为 nil；不支持的组件返回空能力。
 */
+ (nullable TSNpkDialGuiTemplateSnapshot *)inspectTemplateData:(NSData *)data
    profile:(TSNpkDialDeviceProfile *)profile error:(NSError **)error;
/**
 * @brief Freeze source bytes and resolve time before rendering
 * @chinese 渲染前冻结源字节并解析时间配置
 *
 * @param path
 * EN: Caller-owned source template.
 * CN: 调用方持有的源模板。
 * @param context
 * EN: Frozen build task and input.
 * CN: 冻结的构建任务及输入。
 * @param error
 * EN: Read or structural validation error; unsupported time edits preserve the template and log a warning.
 * CN: 读取或结构校验错误；不支持的时间编辑保留模板原值并记录警告。
 * @return
 * EN: Prepared snapshot, or nil on failure.
 * CN: 已准备快照，失败返回 nil。
 */
+ (nullable TSNpkDialGuiTemplateSnapshot *)prepareTemplateAtPath:(NSString *)path
    context:(TSNpkDialBuildContext *)context error:(NSError **)error;
/**
 * @brief Prepare the template with downloaded style preview assets
 * @chinese 结合已下载样式预览素材准备模板
 *
 * @param path
 * EN: Source template path.
 * CN: 源模板路径。
 * @param context
 * EN: Frozen build task.
 * CN: 冻结构建任务。
 * @param resource
 * EN: Optional downloaded metadata and preview paths.
 * CN: 可选的已下载元数据与预览路径。
 * @param error
 * EN: Read or structural validation error; unusable time edits or assets preserve template time settings.
 * CN: 读取或结构校验错误；无法应用的时间编辑或素材使本任务保留模板时间设置。
 * @return
 * EN: Prepared snapshot using the resolved style's asset.
 * CN: 使用实际选中样式素材的已准备快照。
 */
+ (nullable TSNpkDialGuiTemplateSnapshot *)prepareTemplateAtPath:(NSString *)path
    context:(TSNpkDialBuildContext *)context resource:(nullable TSNpkDialStyleResource *)resource error:(NSError **)error;
/**
 * @brief Rewrite a prepared snapshot without reading the source again
 * @chinese 使用已准备快照写包，不再次读取源文件
 *
 * @param snapshot
 * EN: Snapshot prepared for this exact task.
 * CN: 为当前任务准备的快照。
 * @param context
 * EN: The same task used during preparation.
 * CN: 准备阶段使用的同一任务。
 * @param preview
 * EN: Composed or caller-supplied preview.
 * CN: 已合成或调用方提供的成品预览。
 * @param error
 * EN: Validation, capacity or encoding error.
 * CN: 校验、容量或编码错误。
 * @return
 * EN: New package bytes; the source template is untouched.
 * CN: 新包字节，不修改源模板。
 */
+ (nullable NSData *)packageFromPreparedTemplate:(TSNpkDialGuiTemplateSnapshot *)snapshot
    context:(TSNpkDialBuildContext *)context preview:(UIImage *)preview error:(NSError **)error;
/**
 * @brief Validate the complete TOPSTEP and TBUI structure
 * @chinese 校验完整 TOPSTEP 与 TBUI 结构
 *
 * @param data
 * EN: Complete package bytes.
 * CN: 完整包字节。
 * @param error
 * EN: Validation error.
 * CN: 校验错误。
 * @return
 * EN: Validated header, or nil on failure.
 * CN: 已校验包头，失败返回 nil。
 */
+ (nullable TSDialGuiHeader *)validatedHeaderInPackageData:(NSData *)data error:(NSError **)error;
/**
 * @brief Prepare and rewrite a template for existing internal callers
 * @chinese 为既有内部调用方完成模板准备与改写
 *
 * @param path
 * EN: Read-only source template path.
 * CN: 只读源模板路径。
 * @param context
 * EN: Frozen build input and target.
 * CN: 冻结构建输入与目标。
 * @param preview
 * EN: Composed preview.
 * CN: 已合成预览。
 * @param error
 * EN: Preparation, capacity or encoding error.
 * CN: 准备、容量或编码错误。
 * @return
 * EN: New complete bytes without changing the source.
 * CN: 新完整字节，不修改源文件。
 */
+ (nullable NSData *)packageFromTemplatePath:(NSString *)path context:(TSNpkDialBuildContext *)context
    preview:(UIImage *)preview error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
