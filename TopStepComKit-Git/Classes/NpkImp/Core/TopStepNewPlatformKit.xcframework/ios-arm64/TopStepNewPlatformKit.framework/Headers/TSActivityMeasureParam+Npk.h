//
//  TSActivityMeasureParam+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/3.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSMetaRealtimeModel;

@interface TSActivityMeasureParam (Npk)

/**
 * @brief Convert to meta realtime model
 * @chinese 转换为底层实时测量模型
 *
 * @param action
 * [EN]: Measure action. 1 = start, 0 = stop
 * [CN]: 测量动作。1 = 开始，0 = 停止
 *
 * @return
 * [EN]: Converted TSMetaRealtimeModel or nil if unsupported type
 * [CN]: 转换后的 TSMetaRealtimeModel；若类型不支持则返回 nil
 *
 * @discussion
 * [EN]: Maps TSActivityMeasureParam to protobuf realtime model used by BLE layer.
 *       Supported types: 1 HeartRate, 2 BloodOxygen, 3 BloodPressure, 4 Stress.
 * [CN]: 将 TSActivityMeasureParam 映射为 BLE 层使用的 protobuf 实时测量模型。
 *       支持的类型：1 心率、2 血氧、3 血压、4 压力。
 */
- (nullable TSMetaRealtimeModel *)toMetaRealtimeModelWithAction:(int32_t)action;

@end

NS_ASSUME_NONNULL_END
