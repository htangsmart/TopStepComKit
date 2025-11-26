//
//  TSStressValueItem+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/8.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSMetaStressDay;

@interface TSStressValueItem (Npk)

/**
 * @brief Convert TSMetaStressDay array to dictionary array
 * @chinese 将TSMetaStressDay数组转换为字典数组
 *
 * @param stressDays
 * EN: Array of TSMetaStressDay objects to be converted
 * CN: 需要转换的TSMetaStressDay对象数组
 *
 * @return
 * EN: Array of dictionaries with fields matching TSHealthStressTable structure
 * CN: 字典数组，字段与TSHealthStressTable结构保持一致
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromStressDays:(NSArray<TSMetaStressDay *> *)stressDays;

/**
 * @brief Convert database dictionary array to TSStressValueItem array
 * @chinese 将数据库字典数组转换为TSStressValueItem数组
 *
 * @param dicts
 * EN: Array of database dictionary objects containing stress data
 * CN: 包含压力数据的数据库字典对象数组
 *
 * @return
 * EN: Array of TSStressValueItem objects converted from database dictionaries
 * CN: 从数据库字典转换而来的TSStressValueItem对象数组
 *
 * @discussion
 * EN: This method converts an array of database dictionary objects to TSStressValueItem objects.
 *     Each dictionary should contain fields that match the TSHealthStressTable structure.
 *     The method will safely handle nil values and create valid TSStressValueItem instances.
 * CN: 此方法将数据库字典对象数组转换为TSStressValueItem对象。
 *     每个字典应包含与TSHealthStressTable结构匹配的字段。
 *     该方法会安全处理nil值并创建有效的TSStressValueItem实例。
 *
 * @note
 * EN: If the input array is nil or empty, an empty array will be returned.
 *     Invalid dictionaries will be skipped during conversion.
 * CN: 如果输入数组为nil或空，将返回空数组。
 *     转换过程中会跳过无效的字典。
 */
+ (NSArray<TSStressValueItem *> *)valueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Convert database dictionary to TSStressValueItem
 * @chinese 将数据库字典转换为TSStressValueItem
 *
 * @param dict
 * EN: Database dictionary object containing stress data fields
 * CN: 包含压力数据字段的数据库字典对象
 *
 * @return
 * EN: TSStressValueItem object converted from database dictionary, nil if conversion fails
 * CN: 从数据库字典转换而来的TSStressValueItem对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts a single database dictionary to a TSStressValueItem object.
 *     The dictionary should contain fields such as 'value' (stress level),
 *     'isUserInitiated' (user-initiated flag), and time-related fields.
 *     The method uses KVC (Key-Value Coding) to safely set properties.
 * CN: 此方法将单个数据库字典转换为TSStressValueItem对象。
 *     字典应包含'value'（压力等级）、'isUserInitiated'（用户发起标志）和时间相关字段。
 *     该方法使用KVC（键值编码）安全设置属性。
 *
 * @note
 * EN: The method will return nil if the input dictionary is nil.
 *     Property setting uses @try-@catch blocks for safety.
 *     Stress values are clamped to valid range (0-100).
 * CN: 如果输入字典为nil，方法将返回nil。
 *     属性设置使用@try-@catch块确保安全。
 *     压力值会被限制在有效范围内（0-100）。
 */
+ (TSStressValueItem *)valueItemFromDBDict:(NSDictionary *)dict;

/**
 * @brief Convert TSMetaRealtimeData to TSStressValueItem
 * @chinese 将TSMetaRealtimeData转换为TSStressValueItem
 *
 * @param realtimeData
 * EN: Real-time measurement data from device
 * CN: 设备发送的实时测量数据
 *
 * @return
 * EN: TSStressValueItem object with converted stress data
 * CN: 转换后的压力数据对象
 *
 * @discussion
 * EN: This method converts real-time measurement data from device to TSStressValueItem.
 *     The timestamp will be set to current Unix timestamp (since 1970), and the stress value
 *     will be extracted from the realtimeData.value field. The isUserInitiated will
 *     be set to YES by default for real-time measurements.
 * CN: 此方法将设备的实时测量数据转换为TSStressValueItem。
 *     时间戳将设置为当前Unix时间戳（自1970年开始），压力值从realtimeData.value字段提取。
 *     实时测量的isUserInitiated默认为YES。
 *
 * @note
 * EN: The converted TSStressValueItem will have current Unix timestamp as startTime and endTime.
 *     Duration will be set to 0 for real-time measurements.
 *     isUserInitiated will always be set to YES for real-time measurements.
 * CN: 转换后的TSStressValueItem将使用当前Unix时间戳作为startTime和endTime。
 *     实时测量的持续时间设置为0。
 *     实时测量的isUserInitiated始终设置为YES。
 */
+ (TSStressValueItem *)valueItemFromRealtimeData:(TSMetaRealtimeData *)realtimeData;

@end

NS_ASSUME_NONNULL_END
