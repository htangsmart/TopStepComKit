//
//  TSHealthValueModel.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Health value type for records
 * @chinese 数值类型枚举
 *
 * @discussion
 * [EN]: Distinguishes normal/max/min/resting records stored in health tables.
 *       Resting applies to heart rate only; others should not use it.
 * [CN]: 区分健康数据表中存储的普通/最大/最小/静息记录。
 *       静息仅适用于心率，其他类型不应使用。
 */
typedef NS_ENUM(NSInteger, TSHealthValueType) {
    /// 普通数据 (Normal)
    TSHealthValueTypeNormal  = 0,
    /// 最大值 (Max)
    TSHealthValueTypeMax     = 1,
    /// 最小值 (Min)
    TSHealthValueTypeMin     = 2,
    /// 静息（仅心率使用）(Resting - HR only)
    TSHealthValueTypeResting = 3
};

@interface TSHealthValueModel : TSKitBaseModel


@end

NS_ASSUME_NONNULL_END
