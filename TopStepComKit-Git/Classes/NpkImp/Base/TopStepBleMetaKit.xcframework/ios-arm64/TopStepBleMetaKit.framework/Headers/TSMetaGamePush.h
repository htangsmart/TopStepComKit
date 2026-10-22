//
//  TSMetaGamePush.h
//  TopStepBleMetaKit
//

#import "TSBusinessBase.h"
#import "PbSettingParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Validate the caller's authenticated connection identity.
 * @chinese 校验调用方捕获的已认证连接身份。
 *
 * @discussion
 * [EN]: Must be thread safe. Called before enqueue, before sending,
 *       and before main-thread delivery. Return nil while the identity remains valid.
 * [CN]: 必须线程安全；入队前、发送前及主线程交付前调用，身份有效时返回 nil。
 *
 * @return
 * EN: An error that invalidates this query, or nil.
 * CN: 使本次查询失效的错误；有效时返回 nil。
 */
typedef NSError * _Nullable (^TSMetaGamePushQueryGuard)(void);

/**
 * @brief Public-platform game metadata queries.
 * @chinese 公版游戏元数据查询。
 *
 * @discussion
 * [EN]: The caller owns capability, platform, authenticated-session checks and the
 *       end-to-end deadline, including queue waiting. Completion is delivered at
 *       most once, asynchronously on the main queue.
 * [CN]: 调用方负责能力、平台、认证会话检查及包含排队等待的业务截止时间；
 *       完成回调统一异步主线程且最多一次。
 */
@interface TSMetaGamePush : TSBusinessBase

/**
 * @brief Query game slots using 0x02-0x74.
 * @chinese 通过 0x02-0x74 查询游戏槽位。
 *
 * @param guard
 * EN: Connection identity validator.
 * CN: 连接身份校验闭包。
 *
 * @param completion
 * EN: Slots in device order, or an error. Slot IDs are not indices.
 * CN: 设备顺序的槽位列表或错误；槽位 ID 不是目标索引。
 *
 * @discussion
 * [EN]: This query applies only to GUI_579X; the caller checks the platform.
 * [CN]: 此查询仅适用于 GUI_579X，由调用方检查平台。
 */
+ (void)fetchGameSlotsWithGuard:(TSMetaGamePushQueryGuard)guard
                   completion:(void (^)(NSArray<TSMetaSlotSpace *> * _Nullable slots,
                                        NSError * _Nullable error))completion;

/**
 * @brief Query supported game types using 0x02-0x75.
 * @chinese 通过 0x02-0x75 查询支持的游戏类型。
 *
 * @param guard
 * EN: Connection identity validator.
 * CN: 连接身份校验闭包。
 *
 * @param completion
 * EN: Raw int32 values in device order, or an error.
 * CN: 设备顺序的原始 int32 类型列表或错误。
 *
 * @discussion
 * [EN]: Type 0 and unknown original values are preserved.
 * [CN]: 保留类型 0 和未知类型的原始数值。
 */
+ (void)fetchSupportedGameTypesWithGuard:(TSMetaGamePushQueryGuard)guard
                            completion:(void (^)(NSArray<NSNumber *> * _Nullable types,
                                                 NSError * _Nullable error))completion;

/**
 * @brief Query installed games using 0x02-0x76.
 * @chinese 通过 0x02-0x76 查询已有游戏。
 *
 * @param guard
 * EN: Connection identity validator.
 * CN: 连接身份校验闭包。
 *
 * @param completion
 * EN: Games in device order, or an error. A valid zero-length response is an empty list.
 * CN: 设备顺序的游戏列表或错误；合法零长度响应表示空列表。
 *
 * @discussion
 * [EN]: Preserves skin numbers and built-in flags reported for each game.
 * [CN]: 保留设备上报的每个游戏的皮肤编号和内置标记。
 */
+ (void)fetchInstalledGamesWithGuard:(TSMetaGamePushQueryGuard)guard
                        completion:(void (^)(NSArray<TSMetaGameItem *> * _Nullable games,
                                             NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
