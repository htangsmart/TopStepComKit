//
//  TSEpoSource.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/9.
//

#import "TSKitBaseModel.h"
#import "TSEpoDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief EPO update source
 * @chinese EPO 更新星历来源
 *
 * @discussion
 * [EN]: Describes where the EPO ephemeris data comes from for a single update. The four sources are
 *       mutually exclusive: a TSEpoSource can only be created by a dedicated factory method, so an
 *       illegal combination(e.g. both a server and a bin file) can never be expressed.
 *
 *       - builtinServer / customServer: the App needs to know nothing about the EPO protocol; the SDK
 *         fetches, downloads, merges and pushes internally.
 *       - fileURLs / binFile: the App takes over part of the pipeline and MUST follow the device EPO
 *         format(constellation set, type order, merge layout). Only use them if you have a full
 *         ephemeris management of your own.
 *
 * [CN]: 描述单次更新的 EPO 星历数据来源。四种来源互斥：TSEpoSource 只能由专用工厂方法创建，
 *       因此不可能表达出非法组合(例如同时指定服务器和 bin 文件)。
 *
 *       - builtinServer / customServer：App 无需了解任何 EPO 协议细节，SDK 内部完成拉取、下载、合并、推送。
 *       - fileURLs / binFile：App 接管了部分流程，必须遵循设备 EPO 格式(星座组成、类型顺序、合并布局)。
 *         仅在你拥有自己完整的星历管理体系时使用。
 */
@interface TSEpoSource : TSKitBaseModel

/**
 * @brief The source type
 * @chinese 来源类型
 */
@property (nonatomic, assign, readonly) TSEpoSourceType type;

/**
 * @brief Custom server base URL (only for eTSEpoSourceCustomServer)
 * @chinese 自定义服务器地址（仅 eTSEpoSourceCustomServer 有效）
 */
@property (nonatomic, copy, readonly, nullable) NSString *serverBaseURL;

/**
 * @brief Custom EPO file URLs (only for eTSEpoSourceFileURLs)
 * @chinese 自备星历文件地址（仅 eTSEpoSourceFileURLs 有效）
 */
@property (nonatomic, copy, readonly, nullable) NSArray<NSURL *> *fileURLs;

/**
 * @brief Constellation types matching fileURLs (only for eTSEpoSourceFileURLs)
 * @chinese 与 fileURLs 一一对应的星座类型（仅 eTSEpoSourceFileURLs 有效）
 */
@property (nonatomic, copy, readonly, nullable) NSArray<NSNumber *> *fileTypes;

/**
 * @brief Merged EPO bin file path (only for eTSEpoSourceBinFile)
 * @chinese 已合并的最终 bin 文件路径（仅 eTSEpoSourceBinFile 有效）
 */
@property (nonatomic, copy, readonly, nullable) NSString *binFilePath;

/**
 * @brief Use the SDK built-in EPO server
 * @chinese 使用 SDK 内置 EPO 服务器
 *
 * @discussion
 * [EN]: The default, most worry-free source. The App needs to know nothing about EPO.
 * [CN]: 默认、最省心的来源。App 无需了解 EPO 任何细节。
 */
+ (instancetype)builtinServer;

/**
 * @brief Use a custom EPO server
 * @chinese 使用自定义 EPO 服务器
 *
 * @param baseURL
 * EN: Your EPO server base URL. It MUST return the same response format as the built-in server;
 *     downloading and merging are still done by the SDK.
 * CN: 你的 EPO 服务器地址。必须返回与内置服务器一致的响应格式；下载与合并仍由 SDK 完成。
 */
+ (instancetype)customServerWithBaseURL:(NSString *)baseURL;

/**
 * @brief Use App-provided per-constellation EPO files
 * @chinese 使用 App 自备的各星座星历文件
 *
 * @param fileURLs
 * EN: Per-constellation ephemeris files(local or remote URLs). The SDK merges then pushes them.
 * CN: 各星座星历文件(本地或远程 URL)。SDK 负责合并后推送。
 *
 * @param types
 * EN: Constellation types one-to-one matching fileURLs. Count MUST equal fileURLs.count.
 * CN: 与 fileURLs 一一对应的星座类型。数量必须与 fileURLs.count 相同。
 *
 * @note
 * EN: The files must be raw ephemeris in the device-recognized format. This leaks EPO protocol
 *     details to the App; prefer builtinServer/customServer unless you must.
 * CN: 文件必须是设备可识别的原始星历格式。此来源会将 EPO 协议细节暴露给 App；
 *     非必要请优先使用 builtinServer/customServer。
 */
+ (instancetype)fileURLs:(NSArray<NSURL *> *)fileURLs
                   types:(NSArray<NSNumber *> *)types;

/**
 * @brief Use an App-merged final EPO bin file
 * @chinese 使用 App 已合并好的最终 EPO bin 文件
 *
 * @param binFilePath
 * EN: The final bin file already merged by the App per the device format. The SDK only pushes it.
 * CN: App 已按设备格式合并好的最终 bin 文件。SDK 仅负责推送。
 *
 * @note
 * EN: The App must produce the exact device merge layout(header type/offset/size table + CRC32).
 *     This is the heaviest protocol dependency.
 * CN: App 必须产出与设备完全一致的合并布局(头部 type/offset/size 表 + CRC32)。这是最重的协议依赖。
 */
+ (instancetype)binFile:(NSString *)binFilePath;

@end

NS_ASSUME_NONNULL_END
