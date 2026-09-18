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

