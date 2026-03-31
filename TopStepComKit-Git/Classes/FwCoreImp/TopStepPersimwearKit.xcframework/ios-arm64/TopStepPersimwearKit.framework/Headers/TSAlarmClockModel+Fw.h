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
 * @param fwAlarmDicts
 * EN: Each element is a dictionary with keys such as:
 * `alarmItem` (id, label, remark — each maps to the same-named model field), `itemlbltime` (HH:mm or HH:mm:ss), optional `itemTimePeriod` (AM/PM),
 * `itemlblday` (weekday indices 0–6), `itemckbx` (value, remindlater, etc.); top-level `label` / `remark` fill only when nested did not provide that field.
 * Non-dictionary elements are skipped.
 * CN: 每项为字典，典型键：`alarmItem`（id、label、remark 各对应模型同名字段）、`itemlbltime`、`itemTimePeriod`（可选）、
 * `itemlblday`、`itemckbx`；顶层 `label`/`remark` 仅在嵌套未写入对应字段时补全。非字典元素会跳过。
 *
 * @return
 * EN: Parsed models; empty array if input invalid.
 * CN: 解析结果；入参非法时返回空数组。
 */
+ (NSArray<TSAlarmClockModel *> *)alarmModelsFromFwAlarmDicts:(NSArray<NSDictionary *> *)fwAlarmDicts;

/**
 * @brief Compare this model with another for equality (Fw alarm fields)
 * @chinese 比较当前闹钟与另一模型在固件相关字段上是否相等
 *
 * @param alarmModel
 * EN: Another TSAlarmClockModel; pass nil returns NO
 * CN: 另一个 TSAlarmClockModel；传入 nil 时返回 NO
 *
 * @return
 * EN: YES if identifier, label, remark, hour, minute, isOn, repeatOptions all match. Nil pairs compare equal per-field.
 * CN: 当 identifier、label、remark、hour、minute、开关与重复规则均一致时返回 YES；各字符串字段双方均为 nil 时视为相等。
 */
- (BOOL)isEqualToModel:(nullable TSAlarmClockModel *)alarmModel;

-(NSDictionary*)toAddedJson;

-(NSDictionary*)toModifyJson;

-(NSDictionary*)toDeletedJson;

-(NSDictionary*)toAlarmJsonWithType:(FWAlarmEditType)modifyType;

@end

NS_ASSUME_NONNULL_END
