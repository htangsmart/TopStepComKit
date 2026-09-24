//
//  TSNpkHsdAbility.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2026/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 华盛达定制能力位（_DeviceInfo.ability，0-based）
typedef NS_ENUM(NSInteger, TSNpkHsdAbilityBit) {
    TSNpkHsdAbilityBitAlarmType = 27,       ///< 闹钟类型（公版能力，由 TSNpkAlarmClock.isSupportAlarmType 读取）
    TSNpkHsdAbilityBitIce = 28,             ///< ICE
    TSNpkHsdAbilityBitParentalMode = 29,    ///< 家长模式
    TSNpkHsdAbilityBitClassroomMode = 30,   ///< 课堂模式
    TSNpkHsdAbilityBitTaskReward = 31,      ///< 任务 & 奖励
    TSNpkHsdAbilityBitHabit = 32,           ///< 习惯
    TSNpkHsdAbilityBitUsageStatistics = 33, ///< 使用统计
    TSNpkHsdAbilityBitGame = 34,            ///< 游戏
};

/**
 * @brief Raw-ability-bit reader for Huashengda features
 * @chinese 华盛达定制能力位读取器
 *
 * @discussion
 * [EN]: TSPeripheralSupportAbility has no spare bits for these features, so they are read from
 *       TSFeatureAbility.originAbility via isCapabilitySupportedAtBitIndex: on the connected peripheral.
 * [CN]: TSPeripheralSupportAbility 无空余位，故直接从已连接设备的 TSFeatureAbility.originAbility 读取原始位。
 */
@interface TSNpkHsdAbility : NSObject

/// 当前已连接设备是否支持指定能力位；无连接 / 无能力数据时返回 NO
+ (BOOL)isSupportedBit:(TSNpkHsdAbilityBit)bit;

@end

NS_ASSUME_NONNULL_END
