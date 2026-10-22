//
//  TSGameSlotModel+Npk.h
//  TopStepNewPlatformKit
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSMetaSlotSpace;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Converts NPK game slots using an explicitly supplied target index.
 * @chinese 使用显式提供的目标索引转换 NPK 游戏槽位。
 */
@interface TSGameSlotModel (Npk)

/**
 * @brief Converts a slot without inferring its target index or occupancy.
 * @chinese 转换槽位，不推断目标索引或占用状态。
 *
 * @param meta
 * EN: Device slot message with a nonnegative capacity in bytes.
 * CN: 设备槽位消息，容量为非负字节数。
 *
 * @param slotIndex
 * EN: Caller-mapped nonnegative index, or NSNotFound when mapping is unavailable.
 * CN: 调用方映射的非负索引；映射尚未确定时传 NSNotFound。
 *
 * @return
 * EN: A new slot model, or nil for a missing message, negative capacity or negative index.
 * CN: 新槽位模型；消息缺失、容量为负或索引为负时返回 nil。
 *
 * @discussion
 * [EN]: Copies the full uint64 identifier, capacity and is_empty flag. The supplied
 *       index is retained unchanged; neither index base nor index mapping is inferred.
 * [CN]: 复制完整 uint64 内容标识、容量及 is_empty 标记；原样保留传入索引，
 *       不推断索引基数或映射规则。
 *
 * @note
 * [EN]: NSNotFound describes an unmapped query result, not a valid push target.
 *       Installation requests still apply their existing index validation.
 * [CN]: NSNotFound 表示尚未映射的查询结果，不是有效推送目标；
 *       安装请求仍执行既有索引校验。
 */
+ (nullable instancetype)modelFromMeta:(nullable TSMetaSlotSpace *)meta slotIndex:(NSInteger)slotIndex;

@end

NS_ASSUME_NONNULL_END
