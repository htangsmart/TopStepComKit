//
//  TSSportItemModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSHealthValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sport activity detail item model
 * @chinese 运动活动详情项模型
 *
 * @discussion
 * [EN]: This model represents a detailed item of a sport activity, containing specific metrics
 * and measurements recorded during the activity. It includes basic information, distance metrics,
 * and specific data for different types of exercises like swimming, jump rope, elliptical, and rowing.
 *
 * [CN]: 此模型表示运动活动的详细项，包含活动期间记录的具体指标和测量值。
 * 包括基本信息、距离指标，以及游泳、跳绳、椭圆机和划船等不同类型运动的具体数据。
 */
@interface TSSportItemModel : TSHealthValueItem

#pragma mark - Basic Information
/**
 * @brief User identifier
 * @chinese 用户标识符
 *
 * @discussion
 * [EN]: Unique identifier for the user who performed the sport activity.
 * [CN]: 进行运动活动的用户的唯一标识符。
 */
@property (nonatomic, strong) NSString *userID;

/**
 * @brief Device MAC address
 * @chinese 设备MAC地址
 *
 * @discussion
 * [EN]: MAC address of the device that recorded the sport activity.
 * [CN]: 记录运动活动的设备的MAC地址。
 */
@property (nonatomic, strong) NSString *macAddress;

/**
 * @brief Sport activity identifier
 * @chinese 运动活动标识符
 *
 * @discussion
 * [EN]: Unique identifier for the sport activity session.
 * [CN]: 运动活动会话的唯一标识符。
 */
@property (nonatomic, assign) long sportID;

/**
 * @brief Type of sport activity
 * @chinese 运动活动类型
 *
 * @discussion
 * [EN]: The type of sport activity (e.g., running, cycling, swimming).
 * [CN]: 运动活动的类型（如跑步、骑行、游泳）。
 */
@property (nonatomic, assign) UInt16 type;


#pragma mark - Basic Metrics
/**
 * @brief Total distance covered during activity
 * @chinese 运动过程中的总距离
 *
 * @discussion
 * [EN]: The total distance covered during the sport activity, measured in meters.
 * [CN]: 运动过程中覆盖的总距离，以米为单位。
 */
@property (nonatomic, assign) NSInteger distance;

/**
 * @brief Total steps taken during activity
 * @chinese 运动过程中的总步数
 *
 * @discussion
 * [EN]: The total number of steps taken during the sport activity.
 * [CN]: 运动过程中的总步数统计。
 */
@property (nonatomic, assign) NSInteger steps;

/**
 * @brief Total calories burned during activity
 * @chinese 运动过程中消耗的卡路里
 *
 * @discussion
 * [EN]: The total calories burned during the sport activity, measured in calories.
 * [CN]: 运动过程中消耗的卡路里，以小卡为单位。
 */
@property (nonatomic, assign) NSInteger calories;

/**
 * @brief Current pace of the activity
 * @chinese 当前运动配速
 *
 * @discussion
 * [EN]: The current pace of the activity, measured in seconds per kilometer (s/km).
 * [CN]: 当前运动的配速，以每公里所需秒数表示（s/km）。
 */
@property (nonatomic, assign) NSInteger pace;

/**
 * @brief Step cadence during the activity
 * @chinese 运动过程中的步频
 *
 * @discussion
 * [EN]: The step cadence during the sport activity, measured in steps per minute (spm).
 * [CN]: 运动过程中的步频，以每分钟步数表示（步/分钟）。
 *
 * @note
 * [EN]: Applicable to walking, running, and similar activities.
 * [CN]: 适用于步行、跑步等类似运动。
 */
@property (nonatomic, assign) NSInteger cadence;

/**
 * @brief Speed during the activity
 * @chinese 运动过程中的速度
 *
 * @discussion
 * [EN]: The speed during the sport activity, measured in meters per hour (m/h).
 * [CN]: 运动过程中的速度，以米每小时表示（m/h）。
 *
 * @note
 * [EN]: Applicable to running, cycling, and similar activities.
 * [CN]: 适用于跑步、骑行等类似运动。
 */
@property (nonatomic, assign) double speed;

#pragma mark - Swimming Metrics
/**
 * @brief Swimming style
 * @chinese 游泳姿势
 *
 * @discussion
 * [EN]: The swimming style used:
 * 1: Freestyle
 * 2: Breaststroke
 * 3: Backstroke
 * 4: Butterfly
 *
 * [CN]: 游泳姿势类型：
 * 1: 自由泳
 * 2: 蛙泳
 * 3: 仰泳
 * 4: 蝶泳
 */
@property (nonatomic, assign) int swimStyle;

/**
 * @brief Number of swimming laps
 * @chinese 游泳趟数
 *
 * @discussion
 * [EN]: The total number of swimming laps completed during the activity.
 * [CN]: 游泳活动中完成的游泳趟数。
 */
@property (nonatomic, assign) int swimLaps;

/**
 * @brief Number of swimming strokes
 * @chinese 游泳划水次数
 *
 * @discussion
 * [EN]: The total number of swimming strokes made during the activity.
 * [CN]: 游泳活动中的总划水次数。
 */
@property (nonatomic, assign) int swimStrokes;

/**
 * @brief Swimming stroke frequency
 * @chinese 游泳划水频率
 *
 * @discussion
 * [EN]: The frequency of swimming strokes, measured in strokes per minute.
 * [CN]: 游泳划水的频率，以每分钟划水次数表示。
 */
@property (nonatomic, assign) int swimStrokeFreq;

/**
 * @brief Swimming efficiency (SWOLF)
 * @chinese 游泳效率指数
 *
 * @discussion
 * [EN]: SWOLF score (Swimming + Golf), calculated as the sum of seconds and strokes per length.
 * Lower scores indicate better efficiency.
 *
 * [CN]: 游泳效率指数（时间 + 划水次数），计算方式为每个泳池长度所需秒数加上划水次数。
 * 分数越低表示效率越高。
 */
@property (nonatomic, assign) int swolf;

#pragma mark - Jump Rope Metrics
/**
 * @brief Jump rope count
 * @chinese 跳绳次数
 *
 * @discussion
 * [EN]: The total number of successful jumps during rope skipping activity.
 * [CN]: 跳绳运动中成功跳跃的总次数。
 */
@property (nonatomic, assign) int jumpCount;

/**
 * @brief Jump rope break count
 * @chinese 跳绳中断次数
 *
 * @discussion
 * [EN]: The number of times the rope skipping activity was interrupted.
 * [CN]: 跳绳运动中发生中断的次数。
 */
@property (nonatomic, assign) int jumpBkCount;

/**
 * @brief Consecutive jump rope count
 * @chinese 跳绳连续次数
 *
 * @discussion
 * [EN]: The highest number of consecutive successful jumps without interruption.
 * [CN]: 不间断连续跳绳的最高次数。
 */
@property (nonatomic, assign) int jumpConsCount;

#pragma mark - Elliptical Machine Metrics
/**
 * @brief Elliptical machine count
 * @chinese 椭圆机计数
 *
 * @discussion
 * [EN]: The total number of strides on the elliptical machine.
 * [CN]: 椭圆机运动中的总步数。
 */
@property (nonatomic, assign) int elCount;

/**
 * @brief Elliptical machine frequency
 * @chinese 椭圆机频率
 *
 * @discussion
 * [EN]: The current stride frequency on the elliptical machine, measured in strides per minute.
 * [CN]: 椭圆机当前的步频，以每分钟步数表示。
 */
@property (nonatomic, assign) int elFrequecy;

/**
 * @brief Maximum elliptical machine frequency
 * @chinese 椭圆机最大频率
 *
 * @discussion
 * [EN]: The highest stride frequency achieved on the elliptical machine, measured in strides per minute.
 * [CN]: 椭圆机运动中达到的最高步频，以每分钟步数表示。
 */
@property (nonatomic, assign) int elMaxFrequecy;

/**
 * @brief Minimum elliptical machine frequency
 * @chinese 椭圆机最小频率
 *
 * @discussion
 * [EN]: The lowest stride frequency recorded on the elliptical machine, measured in strides per minute.
 * [CN]: 椭圆机运动中记录的最低步频，以每分钟步数表示。
 */
@property (nonatomic, assign) int elMinFrequecy;

#pragma mark - Rowing Machine Metrics
/**
 * @brief Rowing machine count
 * @chinese 划船机计数
 *
 * @discussion
 * [EN]: The total number of rowing strokes completed.
 * [CN]: 划船运动完成的总划桨次数。
 */
@property (nonatomic, assign) int rowCount;

/**
 * @brief Rowing machine frequency
 * @chinese 划船机频率
 *
 * @discussion
 * [EN]: The current rowing frequency, measured in strokes per minute.
 * [CN]: 划船当前的频率，以每分钟划桨次数表示。
 */
@property (nonatomic, assign) int rowFrequecy;

/**
 * @brief Maximum rowing machine frequency
 * @chinese 划船机最大频率
 *
 * @discussion
 * [EN]: The highest rowing frequency achieved, measured in strokes per minute.
 * [CN]: 划船运动中达到的最高频率，以每分钟划桨次数表示。
 */
@property (nonatomic, assign) int rowMaxFrequecy;

/**
 * @brief Minimum rowing machine frequency
 * @chinese 划船机最小频率
 *
 * @discussion
 * [EN]: The lowest rowing frequency recorded, measured in strokes per minute.
 * [CN]: 划船运动中记录的最低频率，以每分钟划桨次数表示。
 */
@property (nonatomic, assign) int rowMinFrequecy;

/**
 * @brief Build detail item models from database detail rows
 * @chinese 由 `TSSportDetailItemTable`（或同字段）查询结果数组构造明细模型列表
 *
 * @param dictionaryArray
 * EN: Array of per-sample/per-segment dictionaries (`userID`, `macAddress`, `sportID`, `type`, time fields, pace as s/km, speed as m/h, swim/jump/elliptical/rowing fields, etc.).
 * CN: 每条为一段明细的字典数组（含用户、设备、运动 ID、类型、时间戳、`pace` 秒/公里、`speed` 米/小时及游泳/跳绳等扩展字段）。
 *
 * @return
 * EN: Array of `TSSportItemModel`; empty array if input is nil or empty. Invalid entries are skipped.
 * CN: `TSSportItemModel` 数组；入参为空时返回空数组，非法元素会被跳过。
 */
+ (NSArray<TSSportItemModel *> *)sportItemModelsFromDictionaries:(NSArray<NSDictionary *> *)dictionaryArray;

@end

NS_ASSUME_NONNULL_END
