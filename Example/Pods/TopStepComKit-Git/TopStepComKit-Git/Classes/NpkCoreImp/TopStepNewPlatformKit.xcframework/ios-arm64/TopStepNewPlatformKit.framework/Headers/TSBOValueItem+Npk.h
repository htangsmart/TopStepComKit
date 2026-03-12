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
