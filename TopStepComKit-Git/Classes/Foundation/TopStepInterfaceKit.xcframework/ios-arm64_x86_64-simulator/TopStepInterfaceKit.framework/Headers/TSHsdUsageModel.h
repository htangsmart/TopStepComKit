//
//  TSHsdUsageModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/9/21.
//

#import "TSKitBaseModel.h"
#import "TSHsdDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One usage counter
 * @chinese 一条使用计数
 *
 * @discussion
 * [EN]: A (type, count) pair within a day of usage statistics.
 * [CN]: 一天使用统计中的一个（类型，次数）对。
 */
@interface TSHsdUsageItem : NSObject <NSCopying>

/**
 * @brief Usage type
 * @chinese 使用类型
 *
 * @discussion
 * [EN]: For app usage (fetchAppUsage:) interpret as TSHsdWatchApp; for game usage (fetchGameUsage:) as TSHsdGameType.
 * [CN]: 应用使用统计（fetchAppUsage:）中按 TSHsdWatchApp 解释；游戏使用统计（fetchGameUsage:）中按 TSHsdGameType 解释。
 */
@property (nonatomic, assign) NSInteger type;

/**
 * @brief Usage count of the day
 * @chinese 当天使用次数
 *
 * @discussion
 * [EN]: Cumulative value for that day. Repeated fetches return the same days again,
 *      so persist by (date, type) with overwrite semantics, never by accumulation.
 * [CN]: 当天累计值。重复拉取会再次返回同样的天数，落库请按（日期，类型）覆盖，不能累加。
 */
@property (nonatomic, assign) NSInteger count;

@end

/**
 * @brief Usage statistics of one day
 * @chinese 一天的使用统计
 *
 * @discussion
 * [EN]: Huashengda customer-specific feature.
 *      Returned by TSHuashengdaInterface.fetchAppUsage: / fetchGameUsage:, one instance per day.
 * [CN]: 华盛达定制能力。
 *      由 TSHuashengdaInterface.fetchAppUsage: / fetchGameUsage: 返回，每天一个实例。
 */
@interface TSHsdDailyUsageModel : NSObject <NSCopying>

/**
 * @brief Start of the day (00:00) the statistics belong to
 * @chinese 统计所属日期的零点
 *
 * @discussion
 * [EN]: When dateSource is TSHsdUsageDateSourceDevice the value comes from the device;
 *      when it is TSHsdUsageDateSourceInferred it is derived from the phone's current date minus dayOffset
 *      and may be off by one day across midnight, time-zone changes or an inaccurate watch clock.
 * [CN]: dateSource 为 TSHsdUsageDateSourceDevice 时来自设备；
 *      为 TSHsdUsageDateSourceInferred 时由手机当天日期减 dayOffset 推算，跨零点、时区变化或手表时间不准时可能差一天。
 *
 * @note
 * [EN]: Use this as the persistence key together with TSHsdUsageItem.type.
 * [CN]: 与 TSHsdUsageItem.type 一起作为落库主键。
 */
@property (nonatomic, strong) NSDate *date;

/**
 * @brief Day offset from the watch's "today"
 * @chinese 距手表"今天"的天数偏移
 *
 * @discussion
 * [EN]: 0 = today, 1 = yesterday, and so on. Equals the protocol packet index and is always authoritative.
 * [CN]: 0 表示今天，1 表示昨天，依次类推。等于协议分包序号，始终为权威值。
 */
@property (nonatomic, assign) NSInteger dayOffset;

/**
 * @brief Where date came from
 * @chinese date 的来源
 *
 * @discussion
 * [EN]: See TSHsdUsageDateSource.
 * [CN]: 见 TSHsdUsageDateSource。
 */
@property (nonatomic, assign) TSHsdUsageDateSource dateSource;

/**
 * @brief Usage counters of the day
 * @chinese 当天各类型的使用计数
 *
 * @discussion
 * [EN]: Empty when the device reported no usage for that day.
 * [CN]: 设备当天无使用记录时为空数组。
 */
@property (nonatomic, copy) NSArray<TSHsdUsageItem *> *items;

@end

NS_ASSUME_NONNULL_END
