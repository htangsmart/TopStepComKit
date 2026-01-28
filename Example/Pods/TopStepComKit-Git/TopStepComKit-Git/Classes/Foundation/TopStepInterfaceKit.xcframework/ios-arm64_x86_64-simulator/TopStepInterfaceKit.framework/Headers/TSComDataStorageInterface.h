//
//  TSComDataStorageInterface.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/3/3.
//
//  文件说明:
//  数据存储管理协议，定义了SDK配置信息、用户信息、设备信息等存储操作

#import "TSKitBaseInterface.h"
#import "TSDataSyncDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Data storage management protocol
 * @chinese 数据存储管理协议
 *
 * @discussion
 * EN: This protocol defines methods for managing persistent storage of SDK configurations,
 *     user information, device information, and connection parameters.
 * CN: 该协议定义了SDK配置、用户信息、设备信息和连接参数等持久化存储的管理方法。
 */
@protocol TSComDataStorageInterface <TSKitBaseInterface>

/**
 * @brief Get shared instance of data storage manager
 * @chinese 获取数据存储管理器的共享实例
 *
 * @return 
 * EN: Shared instance of data storage manager
 * CN: 数据存储管理器的共享实例
 *
 * @discussion
 * EN: This method returns a singleton instance for managing data storage operations.
 *     Use this instance to access all storage-related functionality.
 * CN: 此方法返回用于管理数据存储操作的单例实例。
 *     使用此实例访问所有存储相关的功能。
 */
+ (instancetype)sharedInstance;

/**
 * @brief Get current SDK configuration options
 * @chinese 获取当前SDK配置选项
 *
 * @return 
 * EN: Current SDK configuration options object
 * CN: 当前SDK配置选项对象
 *
 * @discussion
 * EN: Returns the stored SDK configuration options.
 *     These options control the behavior and features of the SDK.
 * CN: 返回已存储的SDK配置选项。
 *     这些选项控制SDK的行为和功能。
 */
-(TSKitConfigOptions *)kitConfigOption;

/**
 * @brief Store SDK configuration options
 * @chinese 存储SDK配置选项
 *
 * @param options 
 * EN: SDK configuration options to store, can be nil to clear settings
 * CN: 要存储的SDK配置选项，可以为nil以清除设置
 *
 * @discussion
 * EN: Persists the provided SDK configuration options.
 *     If nil is passed, existing configuration will be cleared.
 * CN: 持久化保存提供的SDK配置选项。
 *     如果传入nil，将清除现有配置。
 */
-(void)storageKitOption:(nullable TSKitConfigOptions *)options;

/**
 * @brief Get connected user information
 * @chinese 获取已连接用户信息
 *
 * @return 
 * EN: Current user information model
 * CN: 当前用户信息模型
 *
 * @discussion
 * EN: Returns the stored information of the currently connected user.
 *     Returns nil if no user is connected.
 * CN: 返回当前已连接用户的存储信息。
 *     如果没有用户连接，返回nil。
 */
-(TSUserInfoModel *)connectedUserInfo;

/**
 * @brief Store user information
 * @chinese 存储用户信息
 *
 * @param userInfo 
 * EN: User information to store, can be nil to clear user data
 * CN: 要存储的用户信息，可以为nil以清除用户数据
 *
 * @discussion
 * EN: Persists the provided user information.
 *     If nil is passed, existing user data will be cleared.
 * CN: 持久化保存提供的用户信息。
 *     如果传入nil，将清除现有用户数据。
 */
-(void)storageUserInfo:(nullable TSUserInfoModel *)userInfo;

/**
 * @brief Get connected peripheral device
 * @chinese 获取已连接的外设设备
 *
 * @return 
 * EN: Currently connected peripheral device object
 * CN: 当前连接的外设设备对象
 *
 * @discussion
 * EN: Returns the stored information of the currently connected peripheral device.
 *     Returns nil if no device is connected.
 * CN: 返回当前已连接外设设备的存储信息。
 *     如果没有设备连接，返回nil。
 */
-(TSPeripheral *)connectedPeripheral;

/**
 * @brief Store connected peripheral device information
 * @chinese 存储已连接的外设设备信息
 *
 * @param peripheral 
 * EN: Peripheral device to store, can be nil to clear device data
 * CN: 要存储的外设设备，可以为nil以清除设备数据
 *
 * @discussion
 * EN: Persists the provided peripheral device information.
 *     If nil is passed, existing device data will be cleared.
 * CN: 持久化保存提供的外设设备信息。
 *     如果传入nil，将清除现有设备数据。
 */
-(void)storageConnectedPeripheral:(nullable TSPeripheral *)peripheral;

/**
 * @brief Get connection parameters
 * @chinese 获取连接参数
 *
 * @return 
 * EN: Current connection parameters object
 * CN: 当前连接参数对象
 *
 * @discussion
 * EN: Returns the stored connection parameters used for device connection.
 *     These parameters are required for reconnecting to a device.
 * CN: 返回用于设备连接的存储参数。
 *     这些参数用于重新连接设备时使用。
 */
-(TSPeripheralConnectParam *)connectedParam;

/**
 * @brief Store connection parameters
 * @chinese 存储连接参数
 *
 * @param param 
 * EN: Connection parameters to store, can be nil to clear parameters
 * CN: 要存储的连接参数，可以为nil以清除参数
 *
 * @discussion
 * EN: Persists the provided connection parameters.
 *     If nil is passed, existing parameters will be cleared.
 * CN: 持久化保存提供的连接参数。
 *     如果传入nil，将清除现有参数。
 */
-(void)storageConnectParam:(nullable TSPeripheralConnectParam *)param;

/**
 * @brief Get device MAC address
 * @chinese 获取设备MAC地址
 *
 * @return 
 * EN: MAC address string of the connected device
 * CN: 已连接设备的MAC地址字符串
 *
 * @discussion
 * EN: Returns the MAC address of the currently connected device.
 *     Returns nil if no device is connected or MAC address is not available.
 * CN: 返回当前连接设备的MAC地址。
 *     如果没有设备连接或MAC地址不可用，返回nil。
 */
- (NSString *)macAddress;

/**
 * @brief Clear all connected data
 * @chinese 清理所有连接相关的数据
 *
 * @discussion
 * EN: Clears all stored connection-related data including connected peripheral,
 *     connection parameters, and user information. This method is typically called
 *     when unbinding a device to ensure complete cleanup.
 *     
 *     Note: SDK configuration options (kitConfigOption) are NOT cleared as they
 *     are independent of device connection state.
 * CN: 清除所有已存储的连接相关数据，包括已连接的外设、连接参数和用户信息。
 *     此方法通常在解绑设备时调用，以确保完全清理。
 *     
 *     注意：SDK配置选项（kitConfigOption）不会被清除，因为它们独立于设备连接状态。
 */
- (void)clearAllConnectedData;

#pragma mark - Data Sync Time Management

/**
 * @brief Get last sync time for a specific data type
 * @chinese 获取指定数据类型的最后同步时间
 *
 * @param dataOption
 * EN: Data type to query (must be a single type, not a combination)
 * CN: 要查询的数据类型（必须是单个类型，不能是组合）
 *
 * @return
 * EN: Last sync time in timestamp format (seconds since 1970).
 *     Returns 0 if no sync time is found for this data type and device.
 * CN: 最后同步时间，时间戳格式（1970年以来的秒数）。
 *     如果未找到该数据类型和设备的同步时间，返回0。
 *
 * @discussion
 * EN: This method retrieves the last synchronization time for a specific data type
 *     of the currently connected device. The MAC address is automatically obtained
 *     from the connected device. If no sync time is found, returns 0.
 *     
 *     Note: The dataOption parameter should be a single type (e.g., TSDataSyncOptionHeartRate),
 *     not a combination of multiple types.
 * CN: 此方法获取当前连接设备指定数据类型的最后同步时间。
 *     MAC地址会自动从已连接的设备获取。如果未找到同步时间，返回0。
 *     
 *     注意：dataOption 参数应该是单个类型（如 TSDataSyncOptionHeartRate），不能是多个类型的组合。
 */
- (NSTimeInterval)lastSyncTimeForDataOption:(TSDataSyncOption)dataOption;

/**
 * @brief Set last sync time for a specific data type
 * @chinese 设置指定数据类型的最后同步时间
 *
 * @param timestamp
 * EN: Sync time in timestamp format (seconds since 1970)
 * CN: 同步时间，时间戳格式（1970年以来的秒数）
 *
 * @param dataOption
 * EN: Data type to set (must be a single type, not a combination)
 * CN: 要设置的数据类型（必须是单个类型，不能是组合）
 *
 * @discussion
 * EN: This method stores the last synchronization time for a specific data type
 *     of the currently connected device. The MAC address is automatically obtained
 *     from the connected device. The time is stored in UserDefaults with a key
 *     format: "TSDataSyncLastTime_<DataType>_<MACAddress>".
 *     
 *     Note: The dataOption parameter should be a single type (e.g., TSDataSyncOptionHeartRate),
 *     not a combination of multiple types.
 * CN: 此方法存储当前连接设备指定数据类型的最后同步时间。
 *     MAC地址会自动从已连接的设备获取。时间存储在UserDefaults中，key格式为：
 *     "TSDataSyncLastTime_<DataType>_<MACAddress>"。
 *     
 *     注意：dataOption 参数应该是单个类型（如 TSDataSyncOptionHeartRate），不能是多个类型的组合。
 */
- (void)setLastSyncTime:(NSTimeInterval)timestamp forDataOption:(TSDataSyncOption)dataOption;

/**
 * @brief Clear last sync time for a specific data type
 * @chinese 清除指定数据类型的最后同步时间
 *
 * @param dataOption
 * EN: Data type to clear (must be a single type, not a combination)
 * CN: 要清除的数据类型（必须是单个类型，不能是组合）
 *
 * @discussion
 * EN: This method removes the stored last synchronization time for a specific data type
 *     of the currently connected device. The MAC address is automatically obtained
 *     from the connected device.
 *     
 *     Note: The dataOption parameter should be a single type (e.g., TSDataSyncOptionHeartRate),
 *     not a combination of multiple types.
 * CN: 此方法清除当前连接设备指定数据类型的最后同步时间。
 *     MAC地址会自动从已连接的设备获取。
 *     
 *     注意：dataOption 参数应该是单个类型（如 TSDataSyncOptionHeartRate），不能是多个类型的组合。
 */
- (void)clearLastSyncTimeForDataOption:(TSDataSyncOption)dataOption;

/**
 * @brief Clear all last sync times for the currently connected device
 * @chinese 清除当前连接设备的所有数据类型的最后同步时间
 *
 * @discussion
 * EN: This method removes all stored last synchronization times for all data types
 *     of the currently connected device. The MAC address is automatically obtained
 *     from the connected device. This is typically called when unbinding a device
 *     or resetting sync history.
 * CN: 此方法清除当前连接设备所有数据类型的最后同步时间。
 *     MAC地址会自动从已连接的设备获取。通常在解绑设备或重置同步历史时调用。
 */
- (void)clearAllLastSyncTimes;

@end

NS_ASSUME_NONNULL_END
