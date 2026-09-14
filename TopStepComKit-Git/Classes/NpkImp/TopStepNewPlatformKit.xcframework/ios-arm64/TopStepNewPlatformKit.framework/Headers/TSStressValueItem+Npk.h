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
