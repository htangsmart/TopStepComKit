//
//  TSHsdDefines.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/9/21.
//

#ifndef TSHsdDefines_h
#define TSHsdDefines_h

#import <Foundation/Foundation.h>
#import "TSAlarmClockModel.h"

#pragma mark - Limits 约束

/**
 * @brief Protocol limits of Huashengda customer-specific features
 * @chinese 华盛达定制能力的协议约束
 *
 * @discussion
 * [EN]: Values come from pb_b2b_hsd.options in "新平台指令协议". Exceeding them makes the
 *      SDK complete with a parameter error before anything is sent to the device.
 * [CN]: 取值来自《新平台指令协议》pb_b2b_hsd.options。超出约束时 SDK 在发送前直接回调参数错误。
 */

/// ICE 标签最大条数 （Maximum number of ICE labels）
static const NSUInteger TSHsdIceLabelMaxCount = 3;
/// ICE 单条标签 UTF-8 最大字节数 （Maximum UTF-8 bytes of one ICE label）
static const NSUInteger TSHsdIceLabelMaxBytes = 63;
/// 家长模式单个功能项的时段最大条数 （Maximum periods per parental-control item）
static const NSUInteger TSHsdParentalControlPeriodMaxCount = 10;
/// 任务最大条数，2026-09-21 固件确认以 5 为准 （Maximum number of tasks, confirmed as 5 on 2026-09-21）
static const NSUInteger TSHsdTaskMaxCount = 5;
/// 任务标签 UTF-8 最大字节数 （Maximum UTF-8 bytes of a task label）
static const NSUInteger TSHsdTaskLabelMaxBytes = 32;
/// 任务描述 UTF-8 最大字节数 （Maximum UTF-8 bytes of a task description）
static const NSUInteger TSHsdTaskDescriptionMaxBytes = 100;
/// 习惯最大条数 （Maximum number of habits）
static const NSUInteger TSHsdHabitMaxCount = 10;
/// 习惯标签 UTF-8 最大字节数 （Maximum UTF-8 bytes of a habit label）
static const NSUInteger TSHsdHabitLabelMaxBytes = 32;
/// 游戏排名趋势最大条数 （Maximum number of game ranking trends）
static const NSUInteger TSHsdGameRankingTrendMaxCount = 30;
/// 游戏排名最大值 （Maximum game ranking value）
static const NSUInteger TSHsdGameRankingMax = 255;
/// 一天的分钟数，分钟偏移取值范围为 [0, 1439] （Minutes per day; minute offsets are in [0, 1439]）
static const NSInteger TSHsdMinutesPerDay = 24 * 60;

#pragma mark - Parental Control 家长模式（进阶版）

/**
 * @brief Watch actions controlled by the advanced parental mode
 * @chinese 进阶版家长模式可控制的手表动作
 *
 * @discussion
 * [EN]: Maps to _HsdParentalControlItem.id (values aligned with Android WearKit HsdParentalControl.Id).
 * [CN]: 对应 _HsdParentalControlItem.id（取值与 Android WearKit HsdParentalControl.Id 一致）。
 */
typedef NS_ENUM(NSInteger, TSHsdParentalControlFunction) {
    /// 长按换表盘 （Long-press to change watch face）
    TSHsdParentalControlFunctionModifyDial = 1,
    /// 进入游戏 （Enter games）
    TSHsdParentalControlFunctionEnterGame = 2,
    /// 进入计算器 （Enter calculator）
    TSHsdParentalControlFunctionEnterCalculator = 3,
    /// 进入任务 （Enter tasks）
    TSHsdParentalControlFunctionEnterTask = 4,
    /// 进入时间日期 （Enter date & time）
    TSHsdParentalControlFunctionEnterDateTime = 5,
    /// 进入音乐控制 （Enter music control）
    TSHsdParentalControlFunctionEnterMusic = 6,
    /// 进入设置 （Enter settings）
    TSHsdParentalControlFunctionEnterSettings = 7,
    /// 修改闹钟 （Modify alarms）
    TSHsdParentalControlFunctionModifyAlarm = 8,
};

/**
 * @brief Behaviour of a parental-control item inside its periods
 * @chinese 家长模式功能项在时段内的行为
 *
 * @discussion
 * [EN]: Maps to _HsdParentalControlItem.mode.
 * [CN]: 对应 _HsdParentalControlItem.mode。
 */
typedef NS_ENUM(NSInteger, TSHsdParentalControlMode) {
    /// 时段内禁用 （Disabled inside the periods）
    TSHsdParentalControlModeDisableInPeriod = 0,
    /// 时段内允许 （Allowed inside the periods）
    TSHsdParentalControlModeAllowInPeriod = 1,
};

#pragma mark - Watch App 应用类型

/**
 * @brief Watch app identifiers for app-usage statistics
 * @chinese 应用使用统计中的手表应用类型
 *
 * @discussion
 * [EN]: Used as TSHsdUsageItem.type in the result of fetchAppUsage:.
 *      Values 0–32 match FitCloudKit HuashengdaWatchApp; 33–47 are extensions of the new platform protocol.
 * [CN]: 作为 fetchAppUsage: 返回结果中 TSHsdUsageItem.type 的取值。
 *      0–32 与 FitCloudKit HuashengdaWatchApp 一致；33–47 为新平台协议扩展。
 */
typedef NS_ENUM(NSInteger, TSHsdWatchApp) {
    /// 无 （None）
    TSHsdWatchAppNone = 0,
    /// 当天数据 （Daily data）
    TSHsdWatchAppDailyData = 1,
    /// 心率 （Heart rate）
    TSHsdWatchAppHeartRate = 2,
    /// 闹钟 （Alarm clock）
    TSHsdWatchAppAlarmClock = 3,
    /// 游戏 （Game）
    TSHsdWatchAppGame = 4,
    /// 睡眠 （Sleep）
    TSHsdWatchAppSleep = 5,
    /// 日期时间 （Date & time）
    TSHsdWatchAppDateTime = 6,
    /// ICE （ICE）
    TSHsdWatchAppICE = 7,
    /// 习惯 （Habit）
    TSHsdWatchAppHabit = 8,
    /// 运动记录 （Sport record）
    TSHsdWatchAppSportRecord = 9,
    /// 血压 （Blood pressure）
    TSHsdWatchAppBloodPressure = 10,
    /// 血氧 （Blood oxygen）
    TSHsdWatchAppBloodOxygen = 11,
    /// 计算器 （Calculator）
    TSHsdWatchAppCalculator = 12,
    /// 天气 （Weather）
    TSHsdWatchAppWeather = 13,
    /// 秒表 （Stopwatch）
    TSHsdWatchAppStopwatch = 14,
    /// 音乐 （Music）
    TSHsdWatchAppMusic = 15,
    /// 亮屏调节 （Brightness settings）
    TSHsdWatchAppBrightnessSettings = 16,
    /// 息屏时钟 （Screen-off clock）
    TSHsdWatchAppScreenOffClock = 17,
    /// 切换表盘 （Watch face toggle）
    TSHsdWatchAppWatchFaceToggle = 18,
    /// 亮屏时长 （Screen-on duration）
    TSHsdWatchAppScreenOnDuration = 19,
    /// 翻腕亮屏时长 （Wrist-raise screen-on duration）
    TSHsdWatchAppWristDuration = 20,
    /// 修改的语言 （Language settings）
    TSHsdWatchAppLanguageSettings = 21,
    /// 勿扰 （Do not disturb）
    TSHsdWatchAppDNDSettings = 22,
    /// 震动 （Vibration）
    TSHsdWatchAppVibrationSettings = 23,
    /// 健康检测 （Health check）
    TSHsdWatchAppHealthCheck = 24,
    /// 单位设置 （Unit settings）
    TSHsdWatchAppUnitSettings = 25,
    /// 日期设置 （Date settings）
    TSHsdWatchAppDateSettings = 26,
    /// 时间设置 （Time settings）
    TSHsdWatchAppTimeSettings = 27,
    /// 电池 （Battery）
    TSHsdWatchAppBattery = 28,
    /// 喝水 （Drink water）
    TSHsdWatchAppDrinkWater = 29,
    /// 久坐 （Sedentary）
    TSHsdWatchAppSedentary = 30,
    /// 左右手佩戴习惯 （Wearing habit）
    TSHsdWatchAppWearingHabitSettings = 31,
    /// 点击关机 （Power off）
    TSHsdWatchAppPowerOff = 32,
    /// 番茄闹钟 （Pomodoro）
    TSHsdWatchAppPomodoro = 33,
    /// 用户指南 （User guide）
    TSHsdWatchAppUserGuide = 34,
    /// 二维码 （QR code）
    TSHsdWatchAppQRCode = 35,
    /// 密码 （Password）
    TSHsdWatchAppPassword = 36,
    /// 拨号 （Dialer）
    TSHsdWatchAppDialer = 37,
    /// 常用联系人 （Frequent contacts）
    TSHsdWatchAppFrequentContacts = 38,
    /// 通话记录 （Call log）
    TSHsdWatchAppCallLog = 39,
    /// 语音助手 （Voice assistant）
    TSHsdWatchAppVoiceAssistant = 40,
    /// 运动 （Workout）
    TSHsdWatchAppWorkout = 41,
    /// 消息通知 （Notifications）
    TSHsdWatchAppNotifications = 42,
    /// 女性健康 （Female health）
    TSHsdWatchAppFemaleHealth = 43,
    /// 呼吸训练 （Breath training）
    TSHsdWatchAppBreathTraining = 44,
    /// 相机 （Camera）
    TSHsdWatchAppCamera = 45,
    /// 查找手机 （Find phone）
    TSHsdWatchAppFindPhone = 46,
    /// 下键设置 （Down-key settings）
    TSHsdWatchAppDownKeySettings = 47,
};

#pragma mark - Game Type 游戏类型

/**
 * @brief Game type
 * @chinese 游戏类型
 *
 * @discussion
 * [EN]: Used by game-usage statistics (TSHsdUsageItem.type), game records and ranking trends.
 *      Values match the FitCloud protocol.
 * [CN]: 用于游戏使用统计（TSHsdUsageItem.type）、游戏记录与排名趋势，取值与 fitcloud 协议一致。
 */
typedef NS_ENUM(NSInteger, TSHsdGameType) {
    /// 宠物养成 （Pet raising）
    TSHsdGameTypePetRaising = 0,
    /// 2048 （2048）
    TSHsdGameType2048 = 1,
    /// 糖果消消乐 （Candy crush）
    TSHsdGameTypeCandyCrush = 2,
    /// 拼图 （Puzzle）
    TSHsdGameTypePuzzle = 3,
    /// 飞机 （Airplane）
    TSHsdGameTypeAirplane = 4,
    /// 赛车 （Racing）
    TSHsdGameTypeRacing = 5,
    /// 迷宫 （Maze）
    TSHsdGameTypeMaze = 6,
    /// 篮球 （Basketball）
    TSHsdGameTypeBasketball = 7,
    /// 算数题 （Arithmetic）
    TSHsdGameTypeArithmetic = 8,
    /// 俄罗斯方块 （Tetris）
    TSHsdGameTypeTetris = 9,
    /// 数独 （Sudoku）
    TSHsdGameTypeSudoku = 10,
    /// 答题 （Quiz）
    TSHsdGameTypeQuiz = 11,
    /// 跳一跳 （Jump）
    TSHsdGameTypeJump = 12,
    /// 堆堆乐 （Stacking）
    TSHsdGameTypeStacking = 13,
    /// 连一连 （Connect）
    TSHsdGameTypeConnect = 14,
    /// 贪吃蛇 （Snake）
    TSHsdGameTypeSnake = 15,
    /// 24 点 （24 points）
    TSHsdGameType24Points = 16,
    /// 糖果跳跳 （Candy jump）
    TSHsdGameTypeCandyJump = 17,
    /// 弹球突破 （Breakout）
    TSHsdGameTypeBreakout = 18,
    /// 3 分投篮 （Three-point shot）
    TSHsdGameTypeThreePointShot = 19,
    /// 足球靶子 （Soccer target）
    TSHsdGameTypeSoccerTarget = 20,
    /// 可爱方块 （Cute blocks）
    TSHsdGameTypeCuteBlocks = 21,
    /// 五子连珠 （Gomoku）
    TSHsdGameTypeGomoku = 22,
    /// 打小鸟 （Hit the bird）
    TSHsdGameTypeHitBird = 23,
    /// 五彩太空砖 （Space bricks）
    TSHsdGameTypeSpaceBricks = 24,
};

#pragma mark - Task 任务

/**
 * @brief Task type
 * @chinese 任务类型
 *
 * @discussion
 * [EN]: Alias of the public TSAlarmType table (TSAlarmClockModel.h), values 0–22; use the TSAlarmTypeXxx
 *      constants. Values are inferred from FitCloud FcTaskInfo and are pending firmware confirmation;
 *      the SDK passes the value through without whitelist validation.
 * [CN]: 公版闹钟类型表 TSAlarmType（TSAlarmClockModel.h）的别名，取值 0–22，请使用 TSAlarmTypeXxx 常量。
 *      取值由 FitCloud FcTaskInfo 推断、待固件确认；SDK 原值透传，不做白名单校验。
 */
typedef TSAlarmType TSHsdTaskType;

/**
 * @brief Task state of the current day
 * @chinese 当天任务状态
 *
 * @discussion
 * [EN]: Maintained by the device; the App normally leaves it as NotStarted when setting tasks.
 * [CN]: 由设备维护；App 下发任务时通常保持为未开始。
 */
typedef NS_ENUM(NSInteger, TSHsdTaskState) {
    /// 未开始 （Not started）
    TSHsdTaskStateNotStarted = 0,
    /// 进行中 （Ongoing）
    TSHsdTaskStateOngoing = 1,
    /// 已完成 （Completed）
    TSHsdTaskStateCompleted = 2,
};

#pragma mark - Habit 习惯

/**
 * @brief Habit type
 * @chinese 习惯类型
 *
 * @discussion
 * [EN]: Matches Android WearKit HsdHabit.kt / FitCloud FcHabit.kt.
 *      When the type is Custom, TSHsdHabitModel.label is meaningful.
 * [CN]: 与 Android WearKit HsdHabit.kt / FitCloud FcHabit.kt 一致。
 *      类型为自定义时 TSHsdHabitModel.label 有效。
 */
typedef NS_ENUM(NSInteger, TSHsdHabitType) {
    /// 自定义 （Custom）
    TSHsdHabitTypeCustom = 0,
    /// 运动 （Sport）
    TSHsdHabitTypeSport = 1,
    /// 学习 （Study）
    TSHsdHabitTypeStudy = 2,
    /// 睡眠 （Sleep）
    TSHsdHabitTypeSleep = 3,
};

/**
 * @brief Habit state
 * @chinese 习惯状态
 *
 * @discussion
 * [EN]: Matches Android WearKit HsdHabit.kt / FitCloud FcHabit.kt.
 * [CN]: 与 Android WearKit HsdHabit.kt / FitCloud FcHabit.kt 一致。
 */
typedef NS_ENUM(NSInteger, TSHsdHabitState) {
    /// 初始 （Init）
    TSHsdHabitStateInit = 0,
    /// 进行中 （Ongoing）
    TSHsdHabitStateOngoing = 1,
    /// 已完成 （Completed）
    TSHsdHabitStateCompleted = 2,
    /// 已过期 （Overdue）
    TSHsdHabitStateOverdue = 3,
    /// 已关闭 （Closed）
    TSHsdHabitStateClosed = 4,
    /// 已删除 （Deleted）
    TSHsdHabitStateDeleted = 5,
};

/**
 * @brief Function associated with a habit
 * @chinese 习惯关联的功能
 *
 * @discussion
 * [EN]: Matches Android WearKit HsdHabit.kt / FitCloud FcHabit.kt.
 * [CN]: 与 Android WearKit HsdHabit.kt / FitCloud FcHabit.kt 一致。
 */
typedef NS_ENUM(NSInteger, TSHsdHabitAssociatedFunction) {
    /// 无 （None）
    TSHsdHabitAssociatedFunctionNone = 0,
    /// 运动 （Sport）
    TSHsdHabitAssociatedFunctionSport = 1,
};

#pragma mark - Ranking Trend 排名趋势

/**
 * @brief Game ranking trend
 * @chinese 游戏排名趋势
 *
 * @discussion
 * [EN]: Direction of a game ranking compared with the previous period.
 * [CN]: 游戏排名相对上一周期的变化方向。
 */
typedef NS_ENUM(NSInteger, TSHsdRankingTrend) {
    /// 下降 （Down）
    TSHsdRankingTrendDown = 0,
    /// 不变 （Unchanged）
    TSHsdRankingTrendUnchanged = 1,
    /// 上升 （Up）
    TSHsdRankingTrendUp = 2,
};

#pragma mark - Usage Date Source 使用统计日期来源

/**
 * @brief Source of TSHsdDailyUsageModel.date
 * @chinese 使用统计"天"模型的日期来源
 *
 * @discussion
 * [EN]: The usage protocol carries no date in its payload; the day is implied by the packet index.
 *      Newer firmware may add a timestamp field, in which case the date comes from the device.
 * [CN]: 使用统计协议载荷中不含日期，日期由分包序号隐式表达；新固件可能补充 timestamp 字段，此时日期来自设备。
 */
typedef NS_ENUM(NSInteger, TSHsdUsageDateSource) {
    /// 由分包序号按手机当天日期推算，跨零点/时区变化/手表时间不准时可能差一天 （Inferred from the packet index using the phone's date; may be off by one day）
    TSHsdUsageDateSourceInferred = 0,
    /// 设备直接给出当天零点 （Provided by the device）
    TSHsdUsageDateSourceDevice = 1,
};

#endif /* TSHsdDefines_h */
