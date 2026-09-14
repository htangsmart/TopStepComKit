//
//  TSAlarmClockModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/11.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

typedef NS_ENUM(NSUInteger, FWAlarmEditType) {
    eFWAlarmEditTypeAdd = 0,
    eFWAlarmEditTypeModify,
    eFWAlarmEditTypeDelete,
};
NS_ASSUME_NONNULL_BEGIN

@interface TSAlarmClockModel (Fw)

/**
 * @brief Convert launcher/DCM alarm payload to models
 * @chinese 将固件闹钟字典数组转为 TSAlarmClockModel 数组
 *
 * @discussion
 * [EN]: identifier <- alarmItem.id (device-side unique id);
 * alarmId <- index in returned array (UI reference only).
 * [CN]: identifier 取自 alarmItem.id（设备端唯一 ID）；
 * alarmId 按返回数组顺序填 index（仅供 UI 引用）。
 */
+ (NSArray<TSAlarmClockModel *> *)alarmModelsFromFwAlarmDicts:(NSArray<NSDictionary *> *)fwAlarmDicts;

/**
 * @brief Compare two models on Fw-relevant business fields (excluding alarmId)
 * @chinese 比较两个模型在固件相关业务字段上是否一致（不含 alarmId）
 */
- (BOOL)isEqualToModel:(nullable TSAlarmClockModel *)alarmModel;

/**
 * @brief Build JSON dict for add/modify/delete with explicit clockId
 * @chinese 按 clockId 构造 add/modify/delete 三种 JSON
 *
 * @param modifyType
 * EN: 0 add / 1 modify / 2 delete
 * CN: 0 新增 / 1 修改 / 2 删除
 *
 * @param clockId
 * EN: Required device-side identifier; caller must provide a non-empty value.
 * CN: 设备端 ID，调用方必须传入非空值。
 */
- (NSDictionary *)toAlarmJsonWithType:(FWAlarmEditType)modifyType clockId:(NSString *)clockId;

@end

NS_ASSUME_NONNULL_END
