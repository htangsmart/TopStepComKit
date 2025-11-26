//
//  TSHRValueItem+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/8.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>
NS_ASSUME_NONNULL_BEGIN

@class TSMetaHeartRateDay;
@class TSMetaSportDetailData;

@interface TSHRValueItem (Npk)

/**
 * @brief Convert TSMetaHeartRateDay array to dictionary array
 * @chinese 将TSMetaHeartRateDay数组转换为字典数组
 *
 * @param heartRateDays
 * EN: Array of TSMetaHeartRateDay objects to be converted
 * CN: 需要转换的TSMetaHeartRateDay对象数组
 *
 * @return
 * EN: Array of dictionaries with fields matching TSHeartRateTable structure
 * CN: 字典数组，字段与TSHeartRateTable结构保持一致
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromHeartRateDays:(NSArray<TSMetaHeartRateDay *> *)heartRateDays;

/**
 * @brief Convert database dictionary array to TSHRValueItem array
 * @chinese 将数据库字典数组转换为TSHRValueItem数组
 *
 * @param dicts
 * EN: Array of database dictionary objects containing heart rate data
 * CN: 包含心率数据的数据库字典对象数组
 *
 * @return
 * EN: Array of TSHRValueItem objects converted from database dictionaries
 * CN: 从数据库字典转换而来的TSHRValueItem对象数组
 *
 * @discussion
 * EN: This method converts an array of database dictionary objects to TSHRValueItem objects.
 *     Each dictionary should contain fields that match the TSHeartRateTable structure.
 *     The method will safely handle nil values and create valid TSHRValueItem instances.
 * CN: 此方法将数据库字典对象数组转换为TSHRValueItem对象。
 *     每个字典应包含与TSHeartRateTable结构匹配的字段。
 *     该方法会安全处理nil值并创建有效的TSHRValueItem实例。
 *
 * @note
 * EN: If the input array is nil or empty, an empty array will be returned.
 *     Invalid dictionaries will be skipped during conversion.
 * CN: 如果输入数组为nil或空，将返回空数组。
 *     转换过程中会跳过无效的字典。
 */
+ (NSArray<TSHRValueItem *> *)valueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Convert sport heart-rate DB dict array to TSHRValueItem array
 * @chinese 将 TSSportHeartRateTable 查询结果字典数组转换为 TSHRValueItem 数组
 */
+ (NSArray<TSHRValueItem *> *)sportValueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Convert sport detail data to heart rate dictionary array
 * @chinese 将运动详情数据转换为心率字典数组
 *
 * @param detailData
 * EN: Parsed sport detail data (TSMetaSportDetailData)
 * CN: 解析后的运动详情数据
 *
 * @return
 * EN: Array of dictionaries for TSSportHeartRateTable insertion
 * CN: 可直接插入 TSSportHeartRateTable 的字典数组
 *
 * @discussion
 * [EN]: This method generates sport heart rate dictionaries.
 *       sportID, userID, macAddress are resolved internally.
 * [CN]: 本方法负责生成运动心率入库字典。
 *       sportID、userID、macAddress 内部自动获取。
 */
+ (NSArray<NSDictionary *> *)sportHeartRateDictionariesFromDetailData:(TSMetaSportDetailData *)detailData;

/**
 * @brief Convert database dictionary to TSHRValueItem
 * @chinese 将数据库字典转换为TSHRValueItem
 *
 * @param dict
 * EN: Database dictionary object containing heart rate data fields
 * CN: 包含心率数据字段的数据库字典对象
 *
 * @return
 * EN: TSHRValueItem object converted from database dictionary, nil if conversion fails
 * CN: 从数据库字典转换而来的TSHRValueItem对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts a single database dictionary to a TSHRValueItem object.
 *     The dictionary should contain fields such as 'value' (heart rate value),
 *     'isUserInitiated' (user-initiated flag), and time-related fields.
 *     The method uses KVC (Key-Value Coding) to safely set properties.
 * CN: 此方法将单个数据库字典转换为TSHRValueItem对象。
 *     字典应包含'value'（心率值）、'isUserInitiated'（用户发起标志）和时间相关字段。
 *     该方法使用KVC（键值编码）安全设置属性。
 *
 * @note
 * EN: The method will return nil if the input dictionary is nil.
 *     Property setting uses @try-@catch blocks for safety.
 *     Heart rate values are clamped to valid range (30-220 BPM).
 * CN: 如果输入字典为nil，方法将返回nil。
 *     属性设置使用@try-@catch块确保安全。
 *     心率值会被限制在有效范围内（30-220 BPM）。
 */
+ (TSHRValueItem *)valueItemFromDBDict:(NSDictionary *)dict;

/**
 * @brief Convert TSMetaRealtimeData to TSHRValueItem
 * @chinese 将TSMetaRealtimeData转换为TSHRValueItem
 *
 * @param realtimeData
 * EN: Real-time measurement data from device
 * CN: 设备发送的实时测量数据
 *
 * @return
 * EN: TSHRValueItem object with converted heart rate data
 * CN: 转换后的心率数据对象
 *
 * @discussion
 * EN: This method converts real-time measurement data from device to TSHRValueItem.
 *     The timestamp will be set to current Unix timestamp (since 1970), and the heart rate value
 *     will be extracted from the realtimeData.value field. The isUserInitiated will
 *     be set to YES by default for real-time measurements.
 * CN: 此方法将设备的实时测量数据转换为TSHRValueItem。
 *     时间戳将设置为当前Unix时间戳（自1970年开始），心率值从realtimeData.value字段提取。
 *     实时测量的isUserInitiated默认为YES。
 *
 * @note
 * EN: The converted TSHRValueItem will have current Unix timestamp as startTime and endTime.
 *     Duration will be set to 0 for real-time measurements.
 *     isUserInitiated will always be set to YES for real-time measurements.
 * CN: 转换后的TSHRValueItem将使用当前Unix时间戳作为startTime和endTime。
 *     实时测量的持续时间设置为0。
 *     实时测量的isUserInitiated始终设置为YES。
 */
+ (TSHRValueItem *)valueItemFromRealtimeData:(TSMetaRealtimeData *)realtimeData;

@end

NS_ASSUME_NONNULL_END

