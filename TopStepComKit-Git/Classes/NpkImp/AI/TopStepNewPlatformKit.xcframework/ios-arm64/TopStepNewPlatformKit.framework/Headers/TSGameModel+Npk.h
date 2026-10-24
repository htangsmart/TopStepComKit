//
//  TSGameModel+Npk.h
//  TopStepNewPlatformKit
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSMetaGameItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Converts NPK installed-game messages to unified game models.
 * @chinese 将 NPK 已有游戏消息转换为统一游戏模型。
 */
@interface TSGameModel (Npk)

/**
 * @brief Converts one installed-game message without narrowing its values.
 * @chinese 转换单个已有游戏消息并完整保留原始数值。
 *
 * @param meta
 * EN: Device message, or nil when no message is available.
 * CN: 设备消息；没有消息时可传 nil。
 *
 * @return
 * EN: A new game model, or nil when the message is nil.
 * CN: 新游戏模型；消息为 nil 时返回 nil。
 *
 * @discussion
 * [EN]: Preserves signed int32 type and skin values, including unnamed types
 *       and type 0. Copies the built-in flag without inferring overwrite permission.
 * [CN]: 保留有符号 int32 类型与皮肤值，包括未命名类型和类型 0；
 *       复制内置标记，不据此推断覆盖权限。
 */
+ (nullable instancetype)modelFromMeta:(nullable TSMetaGameItem *)meta;

@end

NS_ASSUME_NONNULL_END
