//
//  TSBPValueItem+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/8.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSMetaBloodPressureDay;

@interface TSBPValueItem (Npk)

/**
 * @brief Convert TSMetaBloodPressureDay array to dictionary array
 * @chinese 将TSMetaBloodPressureDay数组转换为字典数组
 * 
 * @param bloodPressureDays 
 * EN: Array of TSMetaBloodPressureDay objects to be converted
 * CN: 需要转换的TSMetaBloodPressureDay对象数组
 * 
 * @return 
 * EN: Array of dictionaries with fields matching TSBloodPressureTable structure
 * CN: 字典数组，字段与TSBloodPressureTable结构保持一致
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromBloodPressureDays:(NSArray<TSMetaBloodPressureDay *> *)bloodPressureDays;

/**
 * @brief Convert database dictionary array to TSBPValueItem array
 * @chinese 将数据库字典数组转换为TSBPValueItem数组
 *
 * @param dicts
 * EN: Array of database dictionary objects containing blood pressure data
 * CN: 包含血压数据的数据库字典对象数组
 *
 * @return
 * EN: Array of TSBPValueItem objects converted from database dictionaries
 * CN: 从数据库字典转换而来的TSBPValueItem对象数组
 *
 * @discussion
 * EN: This method converts an array of database dictionary objects to TSBPValueItem objects.
 *     Each dictionary should contain fields that match the TSBloodPressureTable structure,
 *     including 'sbp' (systolic blood pressure) and 'dbp' (diastolic blood pressure).
 *     The method will safely handle nil values and create valid TSBPValueItem instances.
 * CN: 此方法将数据库字典对象数组转换为TSBPValueItem对象。
 *     每个字典应包含与TSBloodPressureTable结构匹配的字段，
 *     包括'sbp'（收缩压）和'dbp'（舒张压）。
 *     该方法会安全处理nil值并创建有效的TSBPValueItem实例。
 *
 * @note
 * EN: If the input array is nil or empty, an empty array will be returned.
 *     Invalid dictionaries will be skipped during conversion.
 * CN: 如果输入数组为nil或空，将返回空数组。
 *     转换过程中会跳过无效的字典。
 */
+ (NSArray<TSBPValueItem *> *)valueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Convert database dictionary to TSBPValueItem
 * @chinese 将数据库字典转换为TSBPValueItem
 *
 * @param dict
 * EN: Database dictionary object containing blood pressure data fields
 * CN: 包含血压数据字段的数据库字典对象
 *
 * @return
 * EN: TSBPValueItem object converted from database dictionary, nil if conversion fails
 * CN: 从数据库字典转换而来的TSBPValueItem对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts a single database dictionary to a TSBPValueItem object.
 *     The dictionary should contain fields such as 'sbp' (systolic pressure),
 *     'dbp' (diastolic pressure), 'isUserInitiated' (user-initiated flag),
 *     and time-related fields. The method uses KVC (Key-Value Coding) to safely set properties.
 * CN: 此方法将单个数据库字典转换为TSBPValueItem对象。
 *     字典应包含'sbp'（收缩压）、'dbp'（舒张压）、'isUserInitiated'（用户发起标志）
 *     和时间相关字段。该方法使用KVC（键值编码）安全设置属性。
 *
 * @note
 * EN: The method will return nil if the input dictionary is nil.
 *     Property setting uses @try-@catch blocks for safety.
 *     Blood pressure values are clamped to valid range (0-300 mmHg).
 * CN: 如果输入字典为nil，方法将返回nil。
 *     属性设置使用@try-@catch块确保安全。
 *     血压值会被限制在有效范围内（0-300 mmHg）。
 */
+ (TSBPValueItem *)valueItemFromDBDict:(NSDictionary *)dict;

/**
 * @brief Convert TSMetaRealtimeData to TSBPValueItem
 * @chinese 将TSMetaRealtimeData转换为TSBPValueItem
 *
 * @param realtimeData
 * EN: Real-time measurement data from device
 * CN: 设备发送的实时测量数据
 *
 * @return
 * EN: TSBPValueItem object with converted blood pressure data
 * CN: 转换后的血压数据对象
 *
 * @discussion
 * EN: This method converts real-time measurement data from device to TSBPValueItem.
 *     For blood pressure data, the realtimeData.value represents systolic pressure (SBP),
 *     and realtimeData.value2 represents diastolic pressure (DBP).
 *     The timestamp will be set to current Unix timestamp (since 1970).
 *     The isUserInitiated will be set to YES by default for real-time measurements.
 * CN: 此方法将设备的实时测量数据转换为TSBPValueItem。
 *     对于血压数据，realtimeData.value表示收缩压（SBP），
 *     realtimeData.value2表示舒张压（DBP）。
 *     时间戳将设置为当前Unix时间戳（自1970年开始）。
 *     实时测量的isUserInitiated默认为YES。
 *
 * @note
 * EN: The converted TSBPValueItem will have current Unix timestamp as startTime and endTime.
 *     Duration will be set to 0 for real-time measurements.
 *     isUserInitiated will always be set to YES for real-time measurements.
 *     Blood pressure values are clamped to valid range (0-300 mmHg).
 * CN: 转换后的TSBPValueItem将使用当前Unix时间戳作为startTime和endTime。
 *     实时测量的持续时间设置为0。
 *     实时测量的isUserInitiated始终设置为YES。
 *     血压值会被限制在有效范围内（0-300 mmHg）。
 */
+ (TSBPValueItem *)valueItemFromRealtimeData:(TSMetaRealtimeData *)realtimeData;

@end

NS_ASSUME_NONNULL_END
