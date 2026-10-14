//
//  PbHsdParamDefines.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2026/9/21.
//
//  华盛达（HSD）定制协议的长度/数量约束（来源 pb_b2b_hsd.options）

#ifndef PbHsdParamDefines_h
#define PbHsdParamDefines_h

// MARK: - ICE
/** ICE 标签最大条数 */
#define kHsdIceLabelMaxCount 3
/** ICE 单条标签 UTF-8 最大字节数 */
#define kHsdIceLabelMaxLength 63

// MARK: - 家长模式
/** 家长模式功能项每包最大条数（_HsdParentalControl.items 每包 max_count:7，列表分包） */
#define kHsdParentalControlItemsPerFragment 7
/** 单个功能项的时段最大条数（_HsdParentalControlItem.periods max_count:10） */
#define kHsdParentalControlPeriodMaxCount 10

// MARK: - 任务 & 奖励
/** 任务标签 UTF-8 最大字节数 */
#define kHsdTaskLabelMaxLength 32
/** 任务描述 UTF-8 最大字节数 */
#define kHsdTaskDescriptionMaxLength 100
/** 任务最大条数（_HsdTaskInfo.items max_count:5，2026-09-21 确认以 5 为准） */
#define kHsdTaskMaxCount 5

// MARK: - 习惯
/** 习惯标签 UTF-8 最大字节数 */
#define kHsdHabitLabelMaxLength 32
/** 习惯最大条数 */
#define kHsdHabitMaxCount 10

// MARK: - 使用统计
/** 单日使用信息最大条数 */
#define kHsdUsageInfoMaxCount 100

// MARK: - 游戏
/** 游戏记录列表最大条数（0x66 实际最多返回 3 条） */
#define kHsdGameRecordMaxCount 10
/** 游戏排名趋势最大条数 */
#define kHsdGameRankingTrendMaxCount 30
/** 游戏排名最大值 */
#define kHsdGameRankingMax 255

#endif /* PbHsdParamDefines_h */
