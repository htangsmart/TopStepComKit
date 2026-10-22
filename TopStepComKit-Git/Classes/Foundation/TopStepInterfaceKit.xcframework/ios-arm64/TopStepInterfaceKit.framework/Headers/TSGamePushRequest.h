//
//  TSGamePushRequest.h
//  TopStepInterfaceKit
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief A request to install one local game package.
 * @chinese 安装一个本地游戏包的请求。
 *
 * @discussion
 * [EN]: Device support, package contents and slot capacity are checked by the
 *       provider. The provider snapshots the request and file before uploading.
 * [CN]: 设备支持、包内容和槽位容量由 Provider 校验；上传前固定请求和文件内容。
 */
@interface TSGamePushRequest : TSKitBaseModel

/**
 * @brief Local game package path.
 * @chinese 本地游戏包路径。
 *
 * @discussion
 * [EN]: Identifies the local package supplied by the caller. The provider checks
 *       file readability and validates package contents using its private snapshot.
 * [CN]: 指向调用方提供的本地游戏包；Provider 在准备私有快照时校验文件可读性和包内容。
 *
 * @note
 * [EN]: Defaults to an empty string. A nonempty local file path is required;
 *       remote URLs are not accepted and this request does not download files.
 * [CN]: 默认值为空字符串；调用时必须提供非空本地文件路径，不接受远程 URL，也不执行文件下载。
 */
@property (nonatomic, copy) NSString *localFilePath;

/**
 * @brief Optional target slot index.
 * @chinese 可选的目标槽位索引。
 *
 * @discussion
 * [EN]: Nil selects the first empty slot large enough for the package and fails
 *       if none is available. An explicit occupied slot requires confirmation
 *       that its existing game is not built in. The provider checks live capacity.
 * [CN]: nil 自动选择首个容量足够的空槽，无可用空槽则失败。显式选择已占用位置时，
 *       必须确认原游戏非内置；Provider 使用实时容量校验目标。
 *
 * @note
 * [EN]: Defaults to nil, which differs from @0 and does not authorize overwriting.
 *       A supplied value must be a finite, nonnegative integer representable as
 *       NSInteger and must not equal NSNotFound; device-specific limits still apply.
 * [CN]: 默认值为 nil，与 @0 区分，也不授权覆盖。非 nil 值必须是有限、非负、可表示为 NSInteger
 *       且不等于 NSNotFound 的整数，仍需遵守设备特定限制。
 */
@property (nonatomic, copy, nullable) NSNumber *targetSlotIndex;

/**
 * @brief Validate static request fields without accessing files or devices.
 * @chinese 只校验请求字段，不访问文件或设备。
 *
 * @return
 * EN: A game-domain parameter error, or nil if static validation succeeds.
 * CN: 游戏错误域的参数错误；静态校验通过时返回 nil。
 */
- (nullable NSError *)doesModelHasError;

@end

NS_ASSUME_NONNULL_END
