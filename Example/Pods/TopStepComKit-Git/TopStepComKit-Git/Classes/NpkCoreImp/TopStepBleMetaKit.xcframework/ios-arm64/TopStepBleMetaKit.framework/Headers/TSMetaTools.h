//
//  TSMetaTools.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import <Foundation/Foundation.h>
#import "TSMetaHealthData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Meta tools for data synchronization
 * @chinese 数据同步工具类
 *
 * @discussion
 * [EN]: Provides utility methods for data synchronization time management.
 * [CN]: 提供数据同步时间管理的工具方法。
 */
@interface TSMetaTools : NSObject

#pragma mark - Data Sync Time Management

/**
 * @brief Get last sync time for a specific data type
 * @chinese 获取指定数据类型的最后同步时间
 *
 * @param dataOptions
 * [EN]: Data type to query (must be a single type, not a combination).
 * [CN]: 要查询的数据类型（必须是单个类型，不能是组合）。
 *
 * @param macAddress
 * [EN]: MAC address of the device (e.g., "00:11:22:33:44:55").
 * [CN]: 设备的MAC地址（例如："00:11:22:33:44:55"）。
 *
 * @return
 * [EN]: Last sync time in timestamp format (seconds since 2000).
 *       Returns 0 if no sync time is found for this data type and device.
 * [CN]: 最后同步时间，时间戳格式（以2000年开始的秒数）。
 *       如果未找到该数据类型和设备的同步时间，返回0。
 *
 * @discussion
 * [EN]: This method retrieves the last synchronization time for a specific data type
 *       of the device identified by MAC address. The time is stored in UserDefaults
 *       with a key format: "<MACAddress>_<TSMetaDataOpetions>". If no sync time is found, returns 0.
 *       
 *       Note: The dataOptions parameter should be a single type (e.g., TSMetaDataOpetionHeartRate),
 *       not a combination of multiple types.
 *       Using MAC address instead of UUID ensures that sync time persists even after device
 *       factory reset, as MAC address remains constant while UUID may change.
 * [CN]: 此方法获取指定MAC地址设备的数据类型的最后同步时间。
 *       时间存储在UserDefaults中，key格式为："<MACAddress>_<TSMetaDataOpetions>"。如果未找到同步时间，返回0。
 *       
 *       注意：dataOptions 参数应该是单个类型（如 TSMetaDataOpetionHeartRate），不能是多个类型的组合。
 *       使用MAC地址而不是UUID可以确保即使设备恢复出厂设置后，同步时间仍然保留，
 *       因为MAC地址保持不变，而UUID可能会变化。
 */
+ (NSTimeInterval)lastSyncTimeForDataOption:(TSMetaDataOpetions)dataOptions macAddress:(NSString *)macAddress;

/**
 * @brief Set last sync time for a specific data type
 * @chinese 设置指定数据类型的最后同步时间
 *
 * @param timestamp
 * [EN]: Sync time in timestamp format (seconds since 2000)
 * [CN]: 同步时间，时间戳格式（以2000年开始的秒数）
 *
 * @param dataOptions
 * [EN]: Data type to set (must be a single type, not a combination)
 * [CN]: 要设置的数据类型（必须是单个类型，不能是组合）
 *
 * @param macAddress
 * [EN]: MAC address of the device (e.g., "00:11:22:33:44:55").
 * [CN]: 设备的MAC地址（例如："00:11:22:33:44:55"）。
 *
 * @discussion
 * [EN]: This method stores the last synchronization time for a specific data type
 *       of the device identified by MAC address. The time is stored in UserDefaults
 *       with a key format: "<MACAddress>_<TSMetaDataOpetions>".
 *       
 *       Note: The dataOptions parameter should be a single type (e.g., TSMetaDataOpetionHeartRate),
 *       not a combination of multiple types.
 *       Using MAC address instead of UUID ensures that sync time persists even after device
 *       factory reset, as MAC address remains constant while UUID may change.
 * [CN]: 此方法存储指定MAC地址设备的数据类型的最后同步时间。
 *       时间存储在UserDefaults中，key格式为："<MACAddress>_<TSMetaDataOpetions>"。
 *       
 *       注意：dataOptions 参数应该是单个类型（如 TSMetaDataOpetionHeartRate），不能是多个类型的组合。
 *       使用MAC地址而不是UUID可以确保即使设备恢复出厂设置后，同步时间仍然保留，
 *       因为MAC地址保持不变，而UUID可能会变化。
 */
+ (void)setLastSyncTime:(NSTimeInterval)timestamp forDataType:(TSMetaDataOpetions)dataOptions macAddress:(NSString *)macAddress;

/**
 * @brief Clear last sync time for a specific data type
 * @chinese 清除指定数据类型的最后同步时间
 *
 * @param dataOptions
 * [EN]: Data type to clear (must be a single type, not a combination)
 * [CN]: 要清除的数据类型（必须是单个类型，不能是组合）
 *
 * @param macAddress
 * [EN]: MAC address of the device (e.g., "00:11:22:33:44:55").
 * [CN]: 设备的MAC地址（例如："00:11:22:33:44:55"）。
 *
 * @discussion
 * [EN]: This method removes the stored last synchronization time for a specific data type
 *       of the device identified by MAC address.
 *       
 *       Note: The dataOptions parameter should be a single type (e.g., TSMetaDataOpetionHeartRate),
 *       not a combination of multiple types.
 * [CN]: 此方法清除指定MAC地址设备的数据类型的最后同步时间。
 *       
 *       注意：dataOptions 参数应该是单个类型（如 TSMetaDataOpetionHeartRate），不能是多个类型的组合。
 */
+ (void)clearLastSyncTimeForDataType:(TSMetaDataOpetions)dataOptions macAddress:(NSString *)macAddress;

/**
 * @brief Clear all last sync times for a specific device
 * @chinese 清除指定设备的所有数据类型的最后同步时间
 *
 * @param macAddress
 * [EN]: MAC address of the device (e.g., "00:11:22:33:44:55").
 * [CN]: 设备的MAC地址（例如："00:11:22:33:44:55"）。
 *
 * @discussion
 * [EN]: This method removes all stored last synchronization times for all data types
 *       of the device identified by MAC address. This is typically called when unbinding a device
 *       or resetting sync history.
 * [CN]: 此方法清除指定MAC地址设备所有数据类型的最后同步时间。
 *       通常在解绑设备或重置同步历史时调用。
 */
+ (void)clearAllLastSyncTimesForMacAddress:(NSString *)macAddress;

@end

NS_ASSUME_NONNULL_END
