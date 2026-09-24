//
//  TSHuashengdaInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import "TSKitBaseInterface.h"
#import "TSHsdDefines.h"
#import "TSHsdParentalModeModel.h"
#import "TSHsdParentalControlModel.h"
#import "TSHsdClassroomModeModel.h"
#import "TSHsdTaskModel.h"
#import "TSHsdHabitModel.h"
#import "TSHsdUsageModel.h"
#import "TSHsdGameModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Get parental mode callback
 * @chinese 获取家长模式回调
 *
 * @param model
 * EN: Parental mode model, nil if retrieval fails
 * CN: 家长模式模型，获取失败时为nil
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为nil
 */
typedef void (^TSHsdParentalModeResultBlock)(TSHsdParentalModeModel *_Nullable model, NSError *_Nullable error);

/**
 * @brief Get parental control callback
 * @chinese 获取进阶版家长模式回调
 *
 * @param model
 * EN: Parental control model, nil if retrieval fails
 * CN: 进阶版家长模式模型，获取失败时为nil
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 获取失败时的错误信息，成功时为nil
 */
typedef void (^TSHsdParentalControlResultBlock)(TSHsdParentalControlModel *_Nullable model, NSError *_Nullable error);

/**
 * @brief Get classroom mode callback
 * @chinese 获取课堂模式回调
 *
 * @param model
 * EN: Classroom mode model, nil if retrieval fails
 * CN: 课堂模式模型，获取失败时为nil
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为nil
 */
typedef void (^TSHsdClassroomModeResultBlock)(TSHsdClassroomModeModel *_Nullable model, NSError *_Nullable error);

/**
 * @brief Get task info callback
 * @chinese 获取任务信息回调
 *
 * @param model
 * EN: Task info model (total coins + task list), nil if retrieval fails
 * CN: 任务信息模型（总金币数 + 任务列表），获取失败时为nil
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为nil
 */
typedef void (^TSHsdTaskInfoResultBlock)(TSHsdTaskInfoModel *_Nullable model, NSError *_Nullable error);

/**
 * @brief Get habits callback
 * @chinese 获取习惯列表回调
 *
 * @param habits
 * EN: Array of habit models, nil if retrieval fails
 * CN: 习惯模型数组，获取失败时为nil
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为nil
 */
typedef void (^TSHsdHabitsResultBlock)(NSArray<TSHsdHabitModel *> *_Nullable habits, NSError *_Nullable error);

/**
 * @brief Get usage statistics callback
 * @chinese 获取使用统计回调
 *
 * @param days
 * EN: One model per day ordered by dayOffset ascending (index 0 = today); empty array if the device has no data; nil if retrieval fails
 * CN: 每天一个模型，按 dayOffset 升序（下标 0 为今天）；设备无数据时为空数组；获取失败时为nil
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为nil
 */
typedef void (^TSHsdDailyUsageResultBlock)(NSArray<TSHsdDailyUsageModel *> *_Nullable days, NSError *_Nullable error);

/**
 * @brief Get game records callback
 * @chinese 获取游戏记录回调
 *
 * @param records
 * EN: Array of game record models (at most 3), nil if retrieval fails
 * CN: 游戏记录模型数组（最多 3 条），获取失败时为nil
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为nil
 */
typedef void (^TSHsdGameRecordsResultBlock)(NSArray<TSHsdGameRecordModel *> *_Nullable records, NSError *_Nullable error);

/**
 * @brief Exchange task reward callback
 * @chinese 兑换任务奖励回调
 *
 * @param success
 * EN: Exchange result reported by the device; NO also when the request fails
 * CN: 设备返回的兑换结果；请求失败时同样为NO
 *
 * @param error
 * EN: Error information, nil if the request succeeded
 * CN: 错误信息，请求成功时为nil
 */
typedef void (^TSHsdExchangeResultBlock)(BOOL success, NSError *_Nullable error);


/**
 * @brief Huashengda customer-specific features interface
 * @chinese 华盛达客户定制能力接口
 *
 * @discussion
 * EN: This interface groups the whole Huashengda customization package, including:
 *     1. ICE labels
 *     2. Parental mode (basic, FitCloud) / parental control (advanced, NPK)
 *     3. Classroom mode
 *     4. Task & reward
 *     5. Habits
 *     6. App / game usage statistics
 *     7. Game records and ranking trends
 *     Each feature has its own isSupportXxx and shares no state with the others.
 *     isSupport is YES when any feature is supported. Alarm type is a public feature: see TSAlarmClockInterface.isSupportAlarmType.
 *     All completions run on the main thread exactly once. Unsupported features complete with
 *     TSERROR_NOTSUPPORT(kTSErrorDomainHuashengdaName) without sending anything to the device.
 * CN: 该接口承载整个华盛达定制包，包括：
 *     1. ICE 标签
 *     2. 家长模式（基础版，FitCloud）/ 进阶版家长模式（NPK）
 *     3. 课堂模式
 *     4. 任务&奖励
 *     5. 习惯
 *     6. 应用 / 游戏使用统计
 *     7. 游戏记录与排名趋势
 *     每个能力自带 isSupportXxx，能力之间不共享状态；任一能力支持时 isSupport 为YES。
 *     闹钟类型为公版能力，见 TSAlarmClockInterface.isSupportAlarmType。
 *     所有回调在主线程且恰好一次；不支持的能力直接回调 TSERROR_NOTSUPPORT(kTSErrorDomainHuashengdaName)，不发送蓝牙包。
 */
@protocol TSHuashengdaInterface <TSKitBaseInterface>

#pragma mark - Capabilities 能力

/**
 * @brief Whether ICE labels are supported
 * @chinese 是否支持 ICE 标签
 *
 * @return
 * EN: YES if the connected device supports ICE labels, otherwise NO.
 * CN: 当前设备支持 ICE 标签时返回YES，否则返回NO。
 */
- (BOOL)isSupportIce;

/**
 * @brief Whether the basic parental mode is supported
 * @chinese 是否支持基础版家长模式
 *
 * @return
 * EN: YES on FitCloud firmware with withParentalControl; NO on NPK, which uses the advanced parental control instead.
 * CN: FitCloud 固件 withParentalControl 时返回YES；NPK 返回NO（NPK 使用进阶版 parental control）。
 *
 * @discussion
 * EN: Gates fetchParentalMode: / setParentalMode:completion:. Aligned with Android WearKit HsdAbility.Compat.isSupportParentalMode.
 * CN: 决定 fetchParentalMode: / setParentalMode:completion: 是否可用。与 Android WearKit HsdAbility.Compat.isSupportParentalMode 一致。
 */
- (BOOL)isSupportParentalMode;

/**
 * @brief Whether the advanced parental control is supported
 * @chinese 是否支持进阶版家长模式
 *
 * @return
 * EN: YES if the device reports ability bit 29 (NPK), otherwise NO.
 * CN: 设备能力位 bit29 为真时返回YES（NPK），否则返回NO。
 *
 * @discussion
 * EN: Gates fetchParentalControl: / setParentalControl:completion:.
 * CN: 决定 fetchParentalControl: / setParentalControl:completion: 是否可用。
 */
- (BOOL)isSupportParentalControl;

/**
 * @brief Maximum number of periods per parental-control item
 * @chinese 每个家长模式功能项允许的最大时段数
 *
 * @return
 * EN: 10 on current NPK firmware; 0 when isSupportParentalControl is NO.
 * CN: 当前 NPK 固件为 10；isSupportParentalControl 为NO时返回 0。
 */
- (NSUInteger)parentalControlMaxPeriodCount;

/**
 * @brief Whether classroom mode is supported
 * @chinese 是否支持课堂模式
 *
 * @return
 * EN: YES if the connected device supports classroom mode, otherwise NO.
 * CN: 当前设备支持课堂模式时返回YES，否则返回NO。
 */
- (BOOL)isSupportClassroomMode;

/**
 * @brief Whether task & reward is supported
 * @chinese 是否支持任务&奖励
 *
 * @return
 * EN: YES if the connected device supports task & reward, otherwise NO.
 * CN: 当前设备支持任务&奖励时返回YES，否则返回NO。
 */
- (BOOL)isSupportTaskReward;

/**
 * @brief Whether habits are supported
 * @chinese 是否支持习惯
 *
 * @return
 * EN: YES if the connected device supports habits, otherwise NO.
 * CN: 当前设备支持习惯时返回YES，否则返回NO。
 */
- (BOOL)isSupportHabit;

/**
 * @brief Whether usage statistics are supported
 * @chinese 是否支持使用统计
 *
 * @return
 * EN: YES if the connected device supports usage statistics, otherwise NO.
 * CN: 当前设备支持使用统计时返回YES，否则返回NO。
 */
- (BOOL)isSupportUsageStatistics;

/**
 * @brief Whether game records and ranking trends are supported
 * @chinese 是否支持游戏记录与排名趋势
 *
 * @return
 * EN: YES if the connected device supports game records and ranking trends, otherwise NO.
 * CN: 当前设备支持游戏记录与排名趋势时返回YES，否则返回NO。
 */
- (BOOL)isSupportGame;

#pragma mark - ICE

/**
 * @brief Set ICE labels
 * @chinese 设置 ICE 标签
 *
 * @param labels
 * EN: Labels to set, at most TSHsdIceLabelMaxCount (3) items, each ≤ TSHsdIceLabelMaxBytes (63) UTF-8 bytes
 * CN: 要设置的标签，最多 TSHsdIceLabelMaxCount（3）条，每条 UTF-8 ≤ TSHsdIceLabelMaxBytes（63）字节
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: The protocol only defines a set command for ICE; there is no read command,
 *     so the App should cache the labels it has sent.
 *     Count or byte-length violations complete with a parameter error before sending.
 * CN: 协议仅定义了 ICE 的设置指令，没有读取指令，App 需自行缓存已下发的标签。
 *     条数或字节长度不满足约束时，在发送前回调参数错误。
 */
- (void)setIceLabels:(NSArray<NSString *> *)labels completion:(TSCompletionBlock)completion;

#pragma mark - Parental Mode 家长模式

/**
 * @brief Get parental mode
 * @chinese 获取家长模式
 *
 * @param completion
 * EN: Completion callback
 *     - model: Parental mode model, nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - model: 家长模式模型，获取失败时为nil
 *     - error: 获取失败时的错误信息，成功时为nil
 */
- (void)fetchParentalMode:(TSHsdParentalModeResultBlock)completion;

/**
 * @brief Set parental mode
 * @chinese 设置家长模式
 *
 * @param model
 * EN: Parental mode model to set; gameStartMinute / gameEndMinute must be in [0, 1439]
 * CN: 要设置的家长模式模型；gameStartMinute / gameEndMinute 取值范围 [0, 1439]
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Requires isSupportParentalMode (FitCloud). Model validation failures complete with a parameter error before sending.
 * CN: 需 isSupportParentalMode 为YES（FitCloud）。模型校验失败时，在发送前回调参数错误。
 */
- (void)setParentalMode:(TSHsdParentalModeModel *)model completion:(TSCompletionBlock)completion;

/**
 * @brief Get advanced parental control
 * @chinese 获取进阶版家长模式
 *
 * @param completion
 * EN: Completion callback
 *     - model: Parental control model (master switch + controlled action items), nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - model: 进阶版家长模式模型（总开关 + 受控动作列表），获取失败时为nil
 *     - error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Requires isSupportParentalControl. The device replies in list fragments of up to 7 items; the SDK merges them.
 * CN: 需 isSupportParentalControl 为YES。设备按每包最多 7 项分包回复，SDK 合并后回调。
 */
- (void)fetchParentalControl:(TSHsdParentalControlResultBlock)completion;

/**
 * @brief Set advanced parental control
 * @chinese 设置进阶版家长模式
 *
 * @param model
 * EN: Parental control model: master switch plus the complete item list. Item functions must be unique,
 *     each item at most parentalControlMaxPeriodCount periods, minutes in [0, 1439], mode 0 or 1.
 * CN: 进阶版家长模式模型：总开关 + 完整功能项列表。各项 function 不可重复，每项最多 parentalControlMaxPeriodCount 个时段，
 *     分钟取值 [0, 1439]，mode 为 0 或 1。
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Requires isSupportParentalControl. Validation failures complete with a parameter error before sending.
 *     The device replaces its whole configuration with the given list, so always send the complete list;
 *     the SDK splits it into fragments of 7 items.
 * CN: 需 isSupportParentalControl 为YES。校验失败时在发送前回调参数错误。
 *     设备以下发列表整体替换现有配置，请始终下发完整列表；SDK 按每包 7 条自动分包。
 */
- (void)setParentalControl:(TSHsdParentalControlModel *)model completion:(TSCompletionBlock)completion;

#pragma mark - Classroom Mode 课堂模式

/**
 * @brief Get classroom mode
 * @chinese 获取课堂模式
 *
 * @param completion
 * EN: Completion callback
 *     - model: Classroom mode model, nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - model: 课堂模式模型，获取失败时为nil
 *     - error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: The device does not push change notifications for classroom mode; call this again
 *     to observe changes made on the watch.
 * CN: 设备不会主动上报课堂模式变化，手表侧修改后需再次调用本方法获取最新值。
 */
- (void)fetchClassroomMode:(TSHsdClassroomModeResultBlock)completion;

/**
 * @brief Set classroom mode
 * @chinese 设置课堂模式
 *
 * @param model
 * EN: Classroom mode model to set; startMinute / endMinute must be in [0, 1439]
 * CN: 要设置的课堂模式模型；startMinute / endMinute 取值范围 [0, 1439]
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Model validation failures complete with a parameter error before sending.
 * CN: 模型校验失败时，在发送前回调参数错误。
 */
- (void)setClassroomMode:(TSHsdClassroomModeModel *)model completion:(TSCompletionBlock)completion;

#pragma mark - Task & Reward 任务&奖励

/**
 * @brief Get task info
 * @chinese 获取任务信息
 *
 * @param completion
 * EN: Completion callback
 *     - model: Task info model (total coins + task list), nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - model: 任务信息模型（总金币数 + 任务列表），获取失败时为nil
 *     - error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Task states and total coins are maintained by the device; fetch again after the
 *     user completes tasks on the watch to observe the latest values.
 * CN: 任务状态与总金币数由设备维护，用户在手表上完成任务后需再次获取以得到最新值。
 */
- (void)fetchTaskInfo:(TSHsdTaskInfoResultBlock)completion;

/**
 * @brief Set task info
 * @chinese 设置任务信息
 *
 * @param model
 * EN: Task info model to set; at most TSHsdTaskMaxCount (5) tasks, label ≤ 32 and description ≤ 100 UTF-8 bytes
 * CN: 要设置的任务信息模型；最多 TSHsdTaskMaxCount（5）条任务，label ≤ 32 字节、description ≤ 100 字节（UTF-8）
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Replaces the whole task list on the device. Model validation failures complete with
 *     a parameter error before sending.
 * CN: 整表覆盖设备上的任务列表。模型校验失败时，在发送前回调参数错误。
 */
- (void)setTaskInfo:(TSHsdTaskInfoModel *)model completion:(TSCompletionBlock)completion;

/**
 * @brief Exchange task reward
 * @chinese 兑换任务奖励
 *
 * @param completion
 * EN: Completion callback
 *     - success: Exchange result reported by the device
 *     - error: Error information if the request failed, nil if successful
 * CN: 兑换完成的回调
 *     - success: 设备返回的兑换结果
 *     - error: 请求失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Asks the device to exchange the accumulated coins. How coins are consumed is decided by the firmware;
 *     fetch task info again to read the updated total.
 * CN: 请求设备兑换累计的金币，金币如何扣减由固件决定；兑换后可再次获取任务信息读取最新总金币数。
 */
- (void)exchangeTaskReward:(TSHsdExchangeResultBlock)completion;

#pragma mark - Habit 习惯

/**
 * @brief Get habits
 * @chinese 获取习惯列表
 *
 * @param completion
 * EN: Completion callback
 *     - habits: Array of habit models, nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - habits: 习惯模型数组，获取失败时为nil
 *     - error: 获取失败时的错误信息，成功时为nil
 */
- (void)fetchHabits:(TSHsdHabitsResultBlock)completion;

/**
 * @brief Set habits
 * @chinese 设置习惯列表
 *
 * @param habits
 * EN: Habit models to set, at most TSHsdHabitMaxCount (10) items, label ≤ 32 UTF-8 bytes
 * CN: 要设置的习惯模型数组，最多 TSHsdHabitMaxCount（10）条，label ≤ 32 字节（UTF-8）
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Replaces the whole habit list on the device. Model validation failures complete with
 *     a parameter error before sending.
 * CN: 整表覆盖设备上的习惯列表。模型校验失败时，在发送前回调参数错误。
 */
- (void)setHabits:(NSArray<TSHsdHabitModel *> *)habits completion:(TSCompletionBlock)completion;

#pragma mark - Usage Statistics 使用统计

/**
 * @brief Get app usage statistics
 * @chinese 获取应用使用统计
 *
 * @param completion
 * EN: Completion callback
 *     - days: One model per day, days[i].dayOffset == i (0 = the watch's today); empty array if the device has no data
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - days: 每天一个模型，days[i].dayOffset == i（0 为手表的今天）；设备无数据时为空数组
 *     - error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: TSHsdUsageItem.type is a TSHsdWatchApp. The device returns every day it retains; there is no
 *     time-range parameter. Counts are cumulative per day, so persist by (date, type) with overwrite.
 *     Use resetUsageStatistics: to clear the device-side data.
 * CN: TSHsdUsageItem.type 按 TSHsdWatchApp 解释。设备返回它保留的全部天数，无起止时间参数。
 *     count 为当天累计值，落库请按（日期，类型）覆盖。可通过 resetUsageStatistics: 清空设备侧数据。
 */
- (void)fetchAppUsage:(TSHsdDailyUsageResultBlock)completion;

/**
 * @brief Get game usage statistics
 * @chinese 获取游戏使用统计
 *
 * @param completion
 * EN: Completion callback
 *     - days: One model per day, days[i].dayOffset == i (0 = the watch's today); empty array if the device has no data
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - days: 每天一个模型，days[i].dayOffset == i（0 为手表的今天）；设备无数据时为空数组
 *     - error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Same semantics as fetchAppUsage:, except that TSHsdUsageItem.type is a TSHsdGameType.
 * CN: 语义与 fetchAppUsage: 相同，区别是 TSHsdUsageItem.type 按 TSHsdGameType 解释。
 */
- (void)fetchGameUsage:(TSHsdDailyUsageResultBlock)completion;

/**
 * @brief Reset usage statistics
 * @chinese 重置使用统计
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 重置完成的回调
 *     - success: 是否重置成功
 *     - error: 重置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Clears the usage statistics stored on the device. Whether app and game statistics are
 *     cleared together is decided by the firmware.
 * CN: 清空设备侧保存的使用统计。应用与游戏两类统计是否同时清空由固件决定。
 */
- (void)resetUsageStatistics:(TSCompletionBlock)completion;

#pragma mark - Game 游戏

/**
 * @brief Get top game records of a game type
 * @chinese 获取某游戏的最高记录
 *
 * @param gameType
 * EN: Game type to query, see TSHsdGameType
 * CN: 要查询的游戏类型，见 TSHsdGameType
 *
 * @param completion
 * EN: Completion callback
 *     - records: Array of game record models (at most 3), empty array if the game has no record, nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - records: 游戏记录模型数组（最多 3 条），该游戏无记录时为空数组，获取失败时为nil
 *     - error: 获取失败时的错误信息，成功时为nil
 */
- (void)fetchGameTopRecordsWithType:(TSHsdGameType)gameType completion:(TSHsdGameRecordsResultBlock)completion;

/**
 * @brief Set game ranking trends
 * @chinese 设置游戏排名趋势
 *
 * @param trends
 * EN: Ranking trend models to set, 1 to TSHsdGameRankingTrendMaxCount (30) items, ranking in [0, 255]
 * CN: 要设置的排名趋势模型数组，1 到 TSHsdGameRankingTrendMaxCount（30）条，ranking 取值范围 [0, 255]
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Model validation failures complete with a parameter error before sending.
 * CN: 模型校验失败时，在发送前回调参数错误。
 */
- (void)setGameRankingTrends:(NSArray<TSHsdGameRankingTrendModel *> *)trends completion:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
