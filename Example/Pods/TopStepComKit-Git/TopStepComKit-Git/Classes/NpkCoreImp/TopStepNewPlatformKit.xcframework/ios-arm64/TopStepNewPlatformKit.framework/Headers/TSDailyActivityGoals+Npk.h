//
//  TSDailyActivityGoals+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/4.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/PbConfigParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSDailyActivityGoals (Npk)

/**
 * @brief Create goals model from meta goals config
 * @chinese 自底层 TSMetaDailyConfig 生成 TSDailyActivityGoals
 */
+ (TSDailyActivityGoals *_Nullable)goalsFromMetaGoals:(TSMetaDailyConfig *_Nullable)meta;

/**
 * @brief Copy target fields from one meta config to another (no unit conversion)
 * @chinese 将源 meta 的目标字段拷贝到目标 meta（无单位转换）
 */
+ (void)applyMetaTargetsFrom:(TSMetaDailyConfig *)source toMeta:(TSMetaDailyConfig *)dest;

/**
 * @brief Apply goals model to meta config (with unit conversion)
 * @chinese 将 Goals 模型写入 meta（含单位转换：分钟→秒）
 */
+ (void)applyMetaTargetsFromGoals:(TSDailyActivityGoals *)goals toMeta:(TSMetaDailyConfig *)dest;

@end

NS_ASSUME_NONNULL_END
