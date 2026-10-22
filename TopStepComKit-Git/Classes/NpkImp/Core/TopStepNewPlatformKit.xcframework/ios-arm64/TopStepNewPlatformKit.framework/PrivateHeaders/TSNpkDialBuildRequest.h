//
//  TSNpkDialBuildRequest.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSNpkDialDeviceProfile;
@class TSNpkDialBuildContext;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable input of one dial package build
 * @chinese 一次造包的不可变输入
 */
@interface TSNpkDialBuildRequest : NSObject

/**
 * @brief Shared build context
 * @chinese 共享构建上下文
 *
 * @discussion
 * [EN]: Retained by the context initializer for input identity and cancellation; nil only for the legacy designated initializer.
 * [CN]: 上下文初始化入口保留此对象以共享任务身份与取消检查；旧指定初始化入口下为 nil。
 */
@property (nonatomic, strong, nullable, readonly) TSNpkDialBuildContext *context;
/** @brief Create format-specific paths from captured inputs. @chinese 从捕获输入创建格式专属路径。
 * @param context EN: Captured inputs. CN: 捕获输入。
 * @param templatePath EN: Resolved archive. CN: 已解析模板归档。
 * @return EN: LVGL request. CN: LVGL 请求。
 */
- (instancetype)initWithContext:(TSNpkDialBuildContext *)context templatePath:(NSString *)templatePath;

/**
 * @brief Draft used by LVGL stages
 * @chinese LVGL 阶段使用的草稿
 *
 * @discussion
 * [EN]: The context initializer shares its normalized working draft; the legacy initializer retains its supplied draft.
 * [CN]: 上下文入口共享归一后的工作草稿；旧初始化入口保留调用方传入的草稿，不在此处再次复制。
 */
@property (nonatomic, strong, readonly) TSDialDraft *draft;
/**
 * @brief Identifier written into the package
 * @chinese 写入表盘包的标识
 *
 * @discussion
 * [EN]: Uses the working draft identifier or generates one for its mode; context initialization also assigns it to draft.
 * [CN]: 使用工作草稿已有标识，缺失时按模式生成；上下文初始化时还会回填到工作草稿。
 */
@property (nonatomic, copy, readonly) NSString *dialId;
/**
 * @brief Device facts shared by the LVGL stages
 * @chinese LVGL 各阶段共享的设备事实
 *
 * @discussion
 * [EN]: Retains the supplied snapshot rather than querying the connected peripheral during the build.
 * [CN]: 保留传入的设备快照，构建过程中不重新查询当前连接设备。
 */
@property (nonatomic, strong, readonly) TSNpkDialDeviceProfile *deviceProfile;
/**
 * @brief Local template archive path
 * @chinese 本地模板归档路径
 *
 * @discussion
 * [EN]: Context initialization uses the resolved template path; the legacy initializer copies draft.templateFilePath or an empty string.
 * [CN]: 上下文入口使用已解析的模板路径；旧入口复制 draft.templateFilePath，为 nil 时保存空字符串。
 */
@property (nonatomic, copy, readonly) NSString *templateArchivePath;
/**
 * @brief Template extraction directory
 * @chinese 模板解压目录
 *
 * @discussion
 * [EN]: Context initialization selects Working/taskToken/Templates; the template stage populates it.
 * [CN]: 上下文入口选用 Working/taskToken/Templates，由模板阶段填充解压内容。
 */
@property (nonatomic, copy, readonly) NSString *templateDirectory;
/**
 * @brief Mutable LVGL package content directory
 * @chinese 可修改的 LVGL 包内容目录
 *
 * @discussion
 * [EN]: Context initialization selects Working/taskToken/Content; stages edit res.bin, screen.json, config.json and media here.
 * [CN]: 上下文入口选用 Working/taskToken/Content；各阶段在此修改资源、配置、屏幕 JSON 与媒体。
 */
@property (nonatomic, copy, readonly) NSString *contentDirectory;
/**
 * @brief Unpublished TAR output path
 * @chinese 尚未发布的 TAR 输出路径
 *
 * @discussion
 * [EN]: Context initialization selects Working/taskToken/dial.tar. The archive stage writes it before atomic publication.
 * [CN]: 上下文入口选用 Working/taskToken/dial.tar，由归档阶段写入，再交给发布流程。
 */
@property (nonatomic, copy, readonly) NSString *packageFilePath;

/**
 * @brief Resource binary path
 * @chinese 资源二进制文件路径
 *
 * @discussion
 * [EN]: Computed as contentDirectory/res.bin; accessing this property does not create the file.
 * [CN]: 计算结果为 contentDirectory/res.bin；读取属性不会创建文件。
 */
@property (nonatomic, copy, readonly) NSString *binFilePath;
/**
 * @brief Screen JSON path
 * @chinese 屏幕 JSON 文件路径
 *
 * @discussion
 * [EN]: Computed as contentDirectory/screen.json for template reading and screen-stage output.
 * [CN]: 计算结果为 contentDirectory/screen.json，供模板读取和屏幕阶段写回。
 */
@property (nonatomic, copy, readonly) NSString *screenFilePath;
/**
 * @brief Configuration JSON path
 * @chinese 配置 JSON 文件路径
 *
 * @discussion
 * [EN]: Computed as contentDirectory/config.json for package identifier and resource configuration updates.
 * [CN]: 计算结果为 contentDirectory/config.json，供更新包标识及资源配置。
 */
@property (nonatomic, copy, readonly) NSString *configFilePath;

/**
 * @brief Presence of an explicit time tint
 * @chinese 是否存在显式时间着色
 *
 * @discussion
 * [EN]: Recomputed from draft.items on access; YES if any item's time.timeColor is non-nil.
 * [CN]: 每次读取遍历 draft.items；任一项 time.timeColor 非空即为 YES，不表示模板一定支持染色。
 */
@property (nonatomic, assign, readonly) BOOL hasColorTint;

- (instancetype)initWithDraft:(TSDialDraft *)draft
                       dialId:(NSString *)dialId
                deviceProfile:(TSNpkDialDeviceProfile *)deviceProfile
            templateDirectory:(NSString *)templateDirectory
             contentDirectory:(NSString *)contentDirectory
              packageFilePath:(NSString *)packageFilePath NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
