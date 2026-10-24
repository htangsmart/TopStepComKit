//
//  TSGameSlotModel.h
//  TopStepInterfaceKit
//

#import "TSKitBaseModel.h"
#import "TSGamePushDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief A fixed game slot reported by the device.
 * @chinese 设备返回的固定游戏槽位。
 */
@interface TSGameSlotModel : TSKitBaseModel

/**
 * @brief Provider-defined upload target index.
 * @chinese Provider 定义的上传目标索引。
 *
 * @discussion
 * [EN]: The provider maps the device's slot ordering and index convention to
 *       the upload target. This index is separate from the slot's content identifier.
 * [CN]: Provider 根据设备槽位顺序与索引规则映射上传目标，索引与槽位中的内容标识相互独立。
 *
 * @note
 * [EN]: Defaults to NSNotFound until a valid mapping is available. Neither the
 *       index base nor the mapping may be inferred from rawIdentifier.
 * [CN]: 有效映射完成前默认值为 NSNotFound；不能从 rawIdentifier 推断索引基数或映射规则。
 */
@property (nonatomic, assign) NSInteger slotIndex;

/**
 * @brief Complete original 64-bit content identifier.
 * @chinese 完整的原始 64 位内容标识。
 *
 * @discussion
 * [EN]: Preserves the uint64 id field of _SlotSpace. Game type uses bits 0–7,
 *       and the skin number uses bits 8–31; the complete original value is retained.
 * [CN]: 保存 _SlotSpace 的 uint64 id 字段；低 8 位表示游戏类型，第 8–31 位表示皮肤编号，
 *       同时保留完整原始数值。
 *
 * @note
 * [EN]: Defaults to 0. This is not a slot index, and a zero identifier does not
 *       mean the slot is empty; use empty to determine occupancy.
 * [CN]: 默认值为 0；该值不是槽位索引，也不能以值为 0 判断空槽，槽位占用状态应读取 empty。
 */
@property (nonatomic, assign) uint64_t rawIdentifier;

/**
 * @brief Total capacity of this slot in bytes.
 * @chinese 当前槽位的总容量。
 *
 * @discussion
 * [EN]: Maps the nonnegative space_size field of _SlotSpace to a byte count.
 *       It represents the total capacity of one slot, not its remaining free space.
 * [CN]: 将 _SlotSpace 中非负的 space_size 字段转换为字节数，表示单个槽位的总容量，
 *       不是该槽位的剩余可用空间。
 *
 * @note
 * [EN]: Defaults to 0, which is not unlimited capacity. Negative protocol values
 *       must be rejected before conversion to this unsigned property.
 * [CN]: 默认值为 0，不代表无限容量；协议负数必须在转换为此无符号属性前拒绝。
 */
@property (nonatomic, assign) uint64_t capacityBytes;

/**
 * @brief Whether the device reports this slot as empty.
 * @chinese 设备报告的槽位是否为空。
 *
 * @discussion
 * [EN]: Maps the is_empty field of _SlotSpace and is the source of truth for
 *       occupancy. An empty slot can still contain stale identifier bits.
 * [CN]: 对应 _SlotSpace 的 is_empty 字段，是判断占用状态的依据；空槽仍可能保留旧内容标识。
 *
 * @note
 * [EN]: Defaults to NO until filled from the device response. Do not infer
 *       emptiness from rawIdentifier, gameType or skinNumber.
 * [CN]: 从设备响应填充前默认值为 NO；不能从 rawIdentifier、gameType 或 skinNumber 推断空槽。
 */
@property (nonatomic, assign, getter=isEmpty) BOOL empty;

/**
 * @brief Game type derived from the content identifier.
 * @chinese 从内容标识派生的游戏类型。
 *
 * @discussion
 * [EN]: Calculated on every read as rawIdentifier & 0xFF. No independent
 *       writable value is stored, so it always matches the original identifier.
 * [CN]: 每次读取时按 rawIdentifier & 0xFF 计算，不保存独立可写值，始终与原始标识一致。
 *
 * @note
 * [EN]: The decoded range is 0–255 and the initial result is 0. Only a nonempty
 *       slot gives this field current-content meaning; empty-slot values are diagnostic.
 * [CN]: 拆解范围为 0–255，初始计算结果为 0；仅非空槽具有当前内容语义，空槽值仅供诊断。
 */
@property (nonatomic, assign, readonly) TSGameType gameType;

/**
 * @brief Skin number derived from the content identifier.
 * @chinese 从内容标识派生的皮肤编号。
 *
 * @discussion
 * [EN]: Calculated on every read as (rawIdentifier >> 8) & 0xFFFFFF. Bits 32–63
 *       are retained in rawIdentifier but do not contribute to this skin number.
 * [CN]: 每次读取时按 (rawIdentifier >> 8) & 0xFFFFFF 计算；高 32 位保留在 rawIdentifier 中，
 *       不参与皮肤编号。
 *
 * @note
 * [EN]: The decoded range is 0–16777215 and the initial result is 0. The value
 *       is diagnostic only when empty is YES and does not prove a game is installed.
 * [CN]: 拆解范围为 0–16777215，初始计算结果为 0；empty 为 YES 时仅供诊断，不能证明游戏已安装。
 */
@property (nonatomic, assign, readonly) int32_t skinNumber;

@end

NS_ASSUME_NONNULL_END
