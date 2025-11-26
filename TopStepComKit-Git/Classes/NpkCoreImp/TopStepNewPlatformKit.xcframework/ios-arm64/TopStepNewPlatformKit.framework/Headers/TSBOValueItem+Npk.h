//
//  TSBOValueItem+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/8.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSMetaBloodOxygenDay;

@interface TSBOValueItem (Npk)

/**
 * @brief Convert TSMetaBloodOxygenDay array to dictionary array
 * @chinese 将TSMetaBloodOxygenDay数组转换为字典数组
 * 
 * @param bloodOxygenDays 
 * EN: Array of TSMetaBloodOxygenDay objects to be converted
 * CN: 需要转换的TSMetaBloodOxygenDay对象数组
 *
 * @return 
 * EN: Array of dictionaries with fields matching TSOxySaturationTable structure
 * CN: 字典数组，字段与TSOxySaturationTable结构保持一致
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromBloodOxygenDays:(NSArray<TSMetaBloodOxygenDay *> *)bloodOxygenDays;

/**
 * @brief Convert database dictionary array to TSBOValueItem array
 * @chinese 将数据库字典数组转换为TSBOValueItem数组
 *
 * @param dicts
 * EN: Array of database dictionary objects containing blood oxygen data
 * CN: 包含血氧数据的数据库字典对象数组
 *
 * @return
 * EN: Array of TSBOValueItem objects converted from database dictionaries
 * CN: 从数据库字典转换而来的TSBOValueItem对象数组
 *
 * @discussion
 * EN: This method converts an array of database dictionary objects to TSBOValueItem objects.
 *     Each dictionary should contain fields that match the TSOxySaturationTable structure.
 *     The method will safely handle nil values and create valid TSBOValueItem instances.
 * CN: 此方法将数据库字典对象数组转换为TSBOValueItem对象。
 *     每个字典应包含与TSOxySaturationTable结构匹配的字段。
 *     该方法会安全处理nil值并创建有效的TSBOValueItem实例。
 *
 * @note
 * EN: If the input array is nil or empty, an empty array will be returned.
 *     Invalid dictionaries will be skipped during conversion.
 * CN: 如果输入数组为nil或空，将返回空数组。
 *     转换过程中会跳过无效的字典。
 */
+ (NSArray<TSBOValueItem *> *)valueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Convert database dictionary to TSBOValueItem
 * @chinese 将数据库字典转换为TSBOValueItem
 *
 * @param dict
 * EN: Database dictionary object containing blood oxygen data fields
 * CN: 包含血氧数据字段的数据库字典对象
 *
 * @return
 * EN: TSBOValueItem object converted from database dictionary, nil if conversion fails
 * CN: 从数据库字典转换而来的TSBOValueItem对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts a single database dictionary to a TSBOValueItem object.
 *     The dictionary should contain fields such as 'value' (blood oxygen percentage),
 *     'isUserInitiated' (user-initiated flag), and time-related fields.
 *     The method uses KVC (Key-Value Coding) to safely set properties.
 * CN: 此方法将单个数据库字典转换为TSBOValueItem对象。
 *     字典应包含'value'（血氧百分比）、'isUserInitiated'（用户发起标志）和时间相关字段。
 *     该方法使用KVC（键值编码）安全设置属性。
 *
 * @note
 * EN: The method will return nil if the input dictionary is nil.
 *     Property setting uses @try-@catch blocks for safety.
 *     Blood oxygen values are clamped to valid range (0-100%).
 * CN: 如果输入字典为nil，方法将返回nil。
 *     属性设置使用@try-@catch块确保安全。
 *     血氧值会被限制在有效范围内（0-100%）。
 */
+ (TSBOValueItem *)valueItemFromDBDict:(NSDictionary *)dict;

/**
 * @brief Convert TSMetaRealtimeData to TSBOValueItem
 * @chinese 将TSMetaRealtimeData转换为TSBOValueItem
 *
 * @param realtimeData
 * EN: Real-time measurement data from device
 * CN: 设备发送的实时测量数据
 *
 * @return
 * EN: TSBOValueItem object with converted blood oxygen data
 * CN: 转换后的血氧数据对象
 *
 * @discussion
 * EN: This method converts real-time measurement data from device to TSBOValueItem.
 *     The timestamp will be set to current Unix timestamp (since 1970), and the blood oxygen value
 *     will be extracted from the realtimeData.value field. The isUserInitiated will
 *     be set to YES by default for real-time measurements.
 * CN: 此方法将设备的实时测量数据转换为TSBOValueItem。
 *     时间戳将设置为当前Unix时间戳（自1970年开始），血氧值从realtimeData.value字段提取。
 *     实时测量的isUserInitiated默认为YES。
 *
 * @note
 * EN: The converted TSBOValueItem will have current timestamp as startTime and endTime.
 *     Duration will be set to 0 for real-time measurements.
 *     isUserInitiated will always be set to YES for real-time measurements.
 * CN: 转换后的TSBOValueItem将使用当前时间作为startTime和endTime。
 *     实时测量的持续时间设置为0。
 *     实时测量的isUserInitiated始终设置为YES。
 */
+ (TSBOValueItem *)valueItemFromRealtimeData:(TSMetaRealtimeData *)realtimeData;

@end

NS_ASSUME_NONNULL_END
