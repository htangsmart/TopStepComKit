//
//  TSMetaHuashengda.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2026/9/21.
//

#import "TSBusinessBase.h"
#import "PbHsdParam.pbobjc.h"
#import "TSRequestOption.h"

NS_ASSUME_NONNULL_BEGIN

/// 列表分包 SET 失败时，error.userInfo 中记录失败包序号（NSNumber）的 key
FOUNDATION_EXPORT NSString *const kTSMetaHsdFailedFragmentIndexKey;

/**
 * @brief Huashengda (HSD) customer-specific commands
 * @chinese 华盛达客户定制指令
 *
 * @discussion
 * [EN]: Wraps Cmd 0x02 keys 0x59–0x67 defined in "新平台指令协议" → 客户定制 pb 文件 → 华盛达.
 *       All methods are blocking App requests; the device replies with the same cmd/key/sequenceId.
 *       List-fragmented commands are assembled here so callers always receive complete arrays.
 *       Capability gating (ability bits 27–34) is NOT done here; it belongs to the upper platform layer.
 * [CN]: 封装《新平台指令协议》中华盛达定制的 0x02-0x59～0x67 指令。
 *       全部为 App 阻塞指令，设备用相同 cmd/key/sequenceId 回复。
 *       列表分包在本类内收敛，调用方始终拿到完整数组。
 *       能力位（ability bit 27–34）判定不在本层，由上层平台适配（NPK）负责。
 *
 * @note
 * [EN]: Callbacks are delivered on the main thread exactly once (guaranteed by TSRequestManager).
 * [CN]: 回调由 TSRequestManager 保证在主线程且恰好一次。
 */
@interface TSMetaHuashengda : TSBusinessBase

#pragma mark - ICE (0x59)

/**
 * @brief Set ICE labels
 * @chinese 设置 ICE 标签（0x59，仅设置，无读取指令）
 *
 * @param ice
 * EN: Up to 3 labels, each ≤ 63 UTF-8 bytes. Validation is performed before sending.
 * CN: 最多 3 条，每条 UTF-8 ≤ 63 字节；发送前校验。
 */
+ (void)pushIceLabels:(TSMetaHsdIce *)ice completion:(nullable TSMetaCompletionBlock)completion;

#pragma mark - Parental Mode (0x5A / 0x5B，列表分包)

/**
 * @brief Fetch parental control (0x5A)
 * @chinese 获取家长模式（0x5A，列表分包）
 *
 * @param completion
 * EN: Completion callback
 *     - control: merged parental control (isEnabled from fragment 0, items of every fragment concatenated), nil on failure
 *     - error: error information, nil on success
 * CN: 完成回调
 *     - control: 合并后的家长模式（isEnabled 取第 0 包，items 为各包拼接），失败时为 nil
 *     - error: 错误信息，成功时为 nil
 *
 * @discussion
 * EN: Protocol v0.1.3 (pb_b2b_hsd.proto, 2026-09-24): every fragment is a complete _HsdParentalControl
 *     carrying isEnabled and at most kHsdParentalControlItemsPerFragment (7) items.
 * CN: 协议 v0.1.3（pb_b2b_hsd.proto，2026-09-24）：每包一个完整 _HsdParentalControl，携带 isEnabled 与最多
 *     kHsdParentalControlItemsPerFragment（7）条功能项。
 */
+ (void)fetchParentalControlWithCompletion:(void (^)(TSMetaHsdParentalControl *_Nullable control, NSError *_Nullable error))completion;

/**
 * @brief Set parental control (0x5B)
 * @chinese 设置家长模式（0x5B，列表分包）
 *
 * @param control
 * EN: Parental control to write; each item may carry at most kHsdParentalControlPeriodMaxCount (10) periods.
 * CN: 要写入的家长模式；每个功能项最多 kHsdParentalControlPeriodMaxCount（10）个时段。
 * @param completion
 * EN: Completion callback
 *     - isSuccess: YES when every fragment was acknowledged with result 0
 *     - error: error information; userInfo[kTSMetaHsdFailedFragmentIndexKey] holds the rejected fragment index
 * CN: 完成回调
 *     - isSuccess: 每个分包均被设备以 result 0 确认时为 YES
 *     - error: 错误信息；userInfo[kTSMetaHsdFailedFragmentIndexKey] 为被拒绝的分包序号
 *
 * @discussion
 * EN: Items are split into fragments of at most kHsdParentalControlItemsPerFragment (7); every fragment
 *     carries isEnabled. An empty item list is sent as one fragment holding only isEnabled.
 * CN: 功能项按每包最多 kHsdParentalControlItemsPerFragment（7）条切分，每一包都携带 isEnabled；
 *     无功能项时发送一包仅含 isEnabled。
 */
+ (void)pushParentalControl:(TSMetaHsdParentalControl *)control completion:(nullable TSMetaCompletionBlock)completion;

#pragma mark - Classroom Mode (0x5C / 0x5D)

+ (void)fetchClassroomModeWithCompletion:(void (^)(TSMetaHsdClassroomMode *_Nullable mode, NSError *_Nullable error))completion;

+ (void)pushClassroomMode:(TSMetaHsdClassroomMode *)mode completion:(nullable TSMetaCompletionBlock)completion;

#pragma mark - Task & Reward (0x5E / 0x5F / 0x60)

/**
 * @brief Fetch task info (list-fragmented)
 * @chinese 获取任务信息（0x5E，列表分包）
 *
 * @discussion
 * [EN]: Every fragment is a complete TSMetaHsdTaskInfo. Items are merged in fragment order;
 *       totalCoins is taken from fragment index 0 only.
 * [CN]: 每一包都是完整的 TSMetaHsdTaskInfo；items 按包序合并，totalCoins 只取第 0 包。
 */
+ (void)fetchTaskInfoWithCompletion:(void (^)(TSMetaHsdTaskInfo *_Nullable taskInfo, NSError *_Nullable error))completion;

/**
 * @brief Push task info (list-fragmented)
 * @chinese 设置任务信息（0x5F，列表分包）
 *
 * @discussion
 * [EN]: Items are split into fragments of at most kHsdTaskMaxCount tasks; every fragment carries totalCoins.
 * [CN]: 任务按每包最多 kHsdTaskMaxCount 条切分，每一包都携带 totalCoins。
 */
+ (void)pushTaskInfo:(TSMetaHsdTaskInfo *)taskInfo completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief Exchange task reward
 * @chinese 兑换任务奖励（0x60）
 *
 * @param completion
 * EN: Completion callback
 *     - success: _HsdTaskExchangeResult.success reported by the device
 *     - error: transport / parse error, nil on success
 * CN: 完成回调
 *     - success: 设备返回的 _HsdTaskExchangeResult.success
 *     - error: 传输 / 解析错误，成功时为 nil
 *
 * @discussion
 * EN: The device settles coins before replying, so this command waits 10 s for the response
 *     (see exchangeTaskRewardOption) instead of the 5 s fastQueryOption default; no request retry.
 * CN: 设备回复前需结算金币，本指令等待响应 10s（见 exchangeTaskRewardOption），而非 fastQueryOption 默认 5s；不做请求级重试。
 */
+ (void)exchangeTaskRewardWithCompletion:(void (^)(BOOL success, NSError *_Nullable error))completion;

/**
 * @brief Request option used by 0x60
 * @chinese 0x60 使用的请求策略
 *
 * @return
 * EN: fastQueryOption with responseTimeoutInterval = 10 s and requestTimeoutInterval = 15 s.
 * CN: 基于 fastQueryOption，responseTimeoutInterval = 10s，requestTimeoutInterval = 15s。
 */
+ (TSRequestOption *)exchangeTaskRewardOption;

#pragma mark - Habit (0x61 / 0x62)

/**
 * @brief Fetch habits (list-fragmented)
 * @chinese 获取习惯列表（0x61，列表分包；每包一个 TSMetaHsdHabitList，items 按包序合并）
 */
+ (void)fetchHabitListWithCompletion:(void (^)(NSArray<TSMetaHsdHabit *> *_Nullable habits, NSError *_Nullable error))completion;

/**
 * @brief Push habits (list-fragmented, one TSMetaHsdHabitList wrapping a single habit per fragment)
 * @chinese 设置习惯列表（0x62，列表分包，每包一个 TSMetaHsdHabitList（items 仅含一条习惯）；最多 kHsdHabitMaxCount 条）
 */
+ (void)pushHabitList:(NSArray<TSMetaHsdHabit *> *)habits completion:(nullable TSMetaCompletionBlock)completion;

#pragma mark - Usage Statistics (0x63 / 0x64 / 0x65)

/**
 * @brief Fetch app usage statistics (list-fragmented, one day per fragment)
 * @chinese 获取应用使用统计（0x63，列表分包，每包一天）
 *
 * @discussion
 * [EN]: Array index == fragment index == day offset from the watch's "today" (0 = today, 1 = yesterday, ...).
 *       An empty fragment yields an empty TSMetaHsdUsageInfoList at that index (position preserved).
 *       A single non-fragmented empty response is treated as "no data" and yields an empty array.
 * [CN]: 数组下标 == 分包序号 == 距手表"今天"的天数偏移（0 今天、1 昨天 …）。
 *       空包在对应下标产生空的 TSMetaHsdUsageInfoList（保留位置）。
 *       非分包的单个空响应视为"无数据"，返回空数组。
 */
+ (void)fetchAppUsageWithCompletion:(void (^)(NSArray<TSMetaHsdUsageInfoList *> *_Nullable days, NSError *_Nullable error))completion;

/**
 * @brief Fetch game usage statistics (list-fragmented, one day per fragment)
 * @chinese 获取游戏使用统计（0x64，语义同 0x63）
 */
+ (void)fetchGameUsageWithCompletion:(void (^)(NSArray<TSMetaHsdUsageInfoList *> *_Nullable days, NSError *_Nullable error))completion;

/**
 * @brief Reset usage statistics
 * @chinese 重置使用统计（0x65）
 */
+ (void)resetUsageInfoWithCompletion:(nullable TSMetaCompletionBlock)completion;

#pragma mark - Game (0x66 / 0x67)

/**
 * @brief Fetch top game records for a game type (at most 3, not fragmented)
 * @chinese 请求某游戏最高的三条记录（0x66，对象模式；payload 为 TSCommonIntRequest(value=gameType)）
 */
+ (void)fetchGameTopRecordsWithGameType:(int32_t)gameType
                             completion:(void (^)(TSMetaHsdGameRecordList *_Nullable records, NSError *_Nullable error))completion;

/**
 * @brief Push game ranking trends (list-fragmented, one TSMetaHsdGameRankingTrendList with a single item per fragment)
 * @chinese 设置游戏排名趋势（0x67，列表分包，每包一个仅含一条的 TSMetaHsdGameRankingTrendList；最多 kHsdGameRankingTrendMaxCount 条）
 */
+ (void)pushGameRankingTrends:(NSArray<TSMetaHsdGameRankingTrend *> *)trends completion:(nullable TSMetaCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
