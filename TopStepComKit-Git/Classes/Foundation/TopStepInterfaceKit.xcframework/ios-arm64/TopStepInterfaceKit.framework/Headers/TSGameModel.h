//
//  TSGameModel.h
//  TopStepInterfaceKit
//

#import "TSKitBaseModel.h"
#import "TSGamePushDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief A game reported by the device's installed game list.
 * @chinese 设备已安装游戏列表中的游戏信息。
 */
@interface TSGameModel : TSKitBaseModel

/**
 * @brief Original game type.
 * @chinese 原始游戏类型。
 *
 * @discussion
 * [EN]: Maps the type field of the device's _GameItem message. Unnamed
 *       identifiers are preserved without substituting another enum value.
 * [CN]: 对应设备 _GameItem 消息的 type 字段，未命名类型保持原始数值，
 *       不替换成其他枚举值。
 *
 * @note
 * [EN]: Defaults to 0, which identifies the valid pet-raising game; 0 is not
 *       an unknown-value marker. The named enum values are not an exhaustive list.
 * [CN]: 默认值为 0，表示合法的宠物养成游戏，不是未知值标记；具名枚举不是完整类型列表。
 */
@property (nonatomic, assign) TSGameType gameType;

/**
 * @brief Original skin number.
 * @chinese 原始皮肤编号。
 *
 * @discussion
 * [EN]: Maps the skin_num field of _GameItem and preserves the complete signed
 *       32-bit protocol value independently of the game type.
 * [CN]: 对应 _GameItem 的 skin_num 字段，独立于游戏类型保存完整的有符号 32 位协议值。
 *
 * @note
 * [EN]: Defaults to 0. Query results are not truncated to the 24-bit skin
 *       encoding used by slot identifiers.
 * [CN]: 默认值为 0；查询结果不按槽位标识中的 24 位皮肤编码截断。
 */
@property (nonatomic, assign) int32_t skinNumber;

/**
 * @brief Whether the game is built in.
 * @chinese 游戏是否内置。
 *
 * @discussion
 * [EN]: Maps the is_builtin field of _GameItem and reflects the device's
 *       built-in game classification.
 * [CN]: 对应 _GameItem 的 is_builtin 字段，反映设备对内置游戏的分类结果。
 *
 * @note
 * [EN]: Defaults to NO. This flag alone does not grant permission to overwrite
 *       the game; installation rules are defined separately by the device.
 * [CN]: 默认值为 NO；不能仅凭此标记判断是否允许覆盖，安装规则由设备另行约定。
 */
@property (nonatomic, assign, getter=isBuiltIn) BOOL builtIn;

@end

NS_ASSUME_NONNULL_END
