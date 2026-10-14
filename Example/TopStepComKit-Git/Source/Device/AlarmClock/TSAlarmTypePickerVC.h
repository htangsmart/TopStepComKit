//
//  TSAlarmTypePickerVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRootVC.h"
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Display helpers for TSAlarmType (name + SF Symbol)
 * @chinese 闹钟类型的展示辅助（本地化名称 + SF Symbol 图标）
 */
@interface TSAlarmTypeDisplay : NSObject

/// 本地化名称；超出 0–22 的取值返回「未知类型 (N)」
+ (NSString *)nameForType:(TSAlarmType)type;

/// 对应的 SF Symbol 图标名（iOS 13+），超出范围返回 "questionmark.circle"
+ (NSString *)symbolNameForType:(TSAlarmType)type;

/// 类型图标，iOS 13 以下返回 nil
+ (nullable UIImage *)iconForType:(TSAlarmType)type;

@end

/**
 * @brief Alarm type picker
 * @chinese 闹钟类型选择页（公版能力，仅 alarmClock.isSupportAlarmType 为 YES 时可进入）
 *
 * @discussion
 * [CN]: 列出 TSAlarmType 全表 0–22；不在 supportedTypes 内的类型置灰、不可选。
 *       与 TSAlarmRepeatVC 一样在返回时回调，不额外弹确认。
 */
@interface TSAlarmTypePickerVC : TSRootVC

/// 当前选中的类型
@property (nonatomic, assign) TSAlarmType selectedType;
/// 设备支持的类型集合（来自 fetchSupportedAlarmTypes:）；nil 表示未查询到，视为全部可选
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *supportedTypes;
/// 返回时回调
@property (nonatomic, copy, nullable) void (^onTypeChanged)(TSAlarmType type);

@end

NS_ASSUME_NONNULL_END
