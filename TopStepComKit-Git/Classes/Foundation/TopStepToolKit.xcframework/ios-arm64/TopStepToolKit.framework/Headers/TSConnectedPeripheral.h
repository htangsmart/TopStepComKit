//
//  TSConnectedPeripheral.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/1/15.
//

#import <Foundation/Foundation.h>

#import "TSError.h"
#import "TSLogPrinter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 当前连接外设管理类
 * @chinese 用于管理当前连接的外设状态信息
 *
 * @discussion
 * [EN]: This class manages the current connected peripheral status information.
 *       It corresponds to TSPeripheralTable in the database, storing
 *       real-time peripheral connection state and basic peripheral information.
 * [CN]: 此类用于管理当前连接的外设状态信息。
 *       对应数据库中的TSPeripheralTable表，存储实时的外设连接状态和基本外设信息。
 */
@interface TSConnectedPeripheral : NSObject

#pragma mark - 用户信息 (User Information)

/**
 * @brief User ID
 * @chinese 用户ID
 *
 * @discussion
 * [EN]: Unique identifier for the user
 * [CN]: 用户的唯一标识符
 */
@property (nonatomic, copy) NSString *userID;

#pragma mark - 外设信息 (Device Information)

/**
 * @brief Device Bluetooth name
 * @chinese 外设蓝牙名称
 *
 * @discussion
 * [EN]: Bluetooth broadcast name of the peripheral
 * [CN]: 外设的蓝牙广播名称
 */
@property (nonatomic, copy) NSString *bleName;

/**
 * @brief Device MAC address
 * @chinese 外设MAC地址
 *
 * @discussion
 * [EN]: Unique hardware identifier of the peripheral
 * [CN]: 外设的唯一硬件标识符
 */
@property (nonatomic, copy) NSString *macAddress;

/**
 * @brief Device UUID string
 * @chinese 外设UUID字符串
 *
 * @discussion
 * [EN]: UUID identifier of the peripheral
 * [CN]: 外设的UUID标识符
 */
@property (nonatomic, copy) NSString *uuidString;

#pragma mark - 项目信息 (Project Information)

/**
 * @brief Project ID
 * @chinese 项目ID
 *
 * @discussion
 * [EN]: Identifier of the project the peripheral belongs to
 * [CN]: 外设所属项目的标识符
 */
@property (nonatomic, copy) NSString *projectId;

/**
 * @brief Firmware version
 * @chinese 固件版本
 *
 * @discussion
 * [EN]: Current firmware version running on the peripheral
 * [CN]: 外设当前运行的固件版本
 */
@property (nonatomic, copy) NSString *firmVersion;

#pragma mark - 连接状态信息 (Connection Status)

/**
 * @brief Connection status
 * @chinese 连接状态
 *
 * @discussion
 * [EN]: Current connection status of the peripheral
 * [CN]: 外设当前的连接状态
 */
@property (nonatomic, assign) BOOL isConnected;

/**
 * @brief Connection timestamp
 * @chinese 连接时间戳
 *
 * @discussion
 * [EN]: Unix timestamp when the peripheral was connected
 * [CN]: 外设连接时的Unix时间戳
 */
@property (nonatomic, assign) NSTimeInterval connectTime;

/**
 * @brief Formatted connection time
 * @chinese 格式化连接时间
 *
 * @discussion
 * [EN]: Human-readable formatted time string for connectTime
 * [CN]: connectTime对应的人类可读格式化时间字符串
 */
@property (nonatomic, copy) NSString *formatConnectTime;

#pragma mark - 数据库操作方法 (Database Operations)

/**
 * @brief Save connected peripheral to database
 * @chinese 保存连接的外设到数据库
 *
 * @param peripheral
 * [EN]: Connected peripheral to be saved
 * [CN]: 要保存的连接外设
 *
 * @param completion
 * [EN]: Callback block that returns save result
 * [CN]: 返回保存结果的回调块
 *
 * @discussion
 * [EN]: - Saves the connected peripheral to local database
 *       - Validates peripheral data before saving
 *       - Returns success/failure status and error information
 *       - Executes asynchronously to avoid blocking main thread
 * [CN]: - 将连接的外设保存到本地数据库
 *       - 保存前验证外设数据
 *       - 返回成功/失败状态和错误信息
 *       - 异步执行以避免阻塞主线程
 */
+ (void)saveConnectedPeripheral:(TSConnectedPeripheral *)peripheral
                 completion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Query connected peripherals by user ID
 * @chinese 根据用户ID查询连接的外设
 *
 * @param userId
 * [EN]: User ID to filter peripherals
 * [CN]: 用于过滤外设的用户ID
 *
 * @param completion
 * [EN]: Callback block that returns query results
 * [CN]: 返回查询结果的回调块
 *
 * @discussion
 * [EN]: - Queries connected peripherals from local database
 *       - Filters by user ID
 *       - Returns array of connected peripherals or empty array if none found
 *       - Executes asynchronously to avoid blocking main thread
 * [CN]: - 从本地数据库查询连接的外设
 *       - 根据用户ID进行过滤
 *       - 返回连接的外设数组，如果没有找到则返回空数组
 *       - 异步执行以避免阻塞主线程
 */
+ (void)queryConnectedPeripheralsWithUserId:(NSString *)userId
                             completion:(void (^)(NSArray<TSConnectedPeripheral *> *peripherals, NSError * _Nullable error))completion;

/**
 * @brief Query connected peripheral by user ID and MAC address
 * @chinese 根据用户ID和MAC地址查询连接的外设
 *
 * @param userId
 * [EN]: User ID to filter peripheral
 * [CN]: 用于过滤外设的用户ID
 *
 * @param macAddress
 * [EN]: MAC address to filter peripheral
 * [CN]: 用于过滤外设的MAC地址
 *
 * @param completion
 * [EN]: Callback block that returns query result
 * [CN]: 返回查询结果的回调块
 *
 * @discussion
 * [EN]: - Queries specific connected peripheral from local database
 *       - Filters by user ID and MAC address combination
 *       - Returns the peripheral or nil if not found
 *       - Executes asynchronously to avoid blocking main thread
 * [CN]: - 从本地数据库查询特定的连接外设
 *       - 根据用户ID和MAC地址组合进行过滤
 *       - 返回外设或nil（如果未找到）
 *       - 异步执行以避免阻塞主线程
 */
+ (void)queryConnectedPeripheralWithUserId:(NSString *)userId
                            macAddress:(NSString *)macAddress
                            completion:(void (^)(TSConnectedPeripheral * _Nullable peripheral, NSError * _Nullable error))completion;

/**
 * @brief Update or create peripheral connection status (Upsert operation)
 * @chinese 更新或创建外设连接状态（Upsert操作）
 *
 * @param userId
 * [EN]: User ID of the peripheral
 * [CN]: 外设的用户ID
 *
 * @param macAddress
 * [EN]: MAC address of the peripheral
 * [CN]: 外设的MAC地址
 *
 * @param isConnected
 * [EN]: New connection status
 * [CN]: 新的连接状态
 *
 * @param completion
 * [EN]: Callback block that returns update result
 * [CN]: 返回更新结果的回调块
 *
 * @discussion
 * [EN]: - Performs upsert operation on peripheral connection status
 *       - If peripheral exists: updates the connection status and time
 *       - If peripheral doesn't exist: creates a new peripheral record
 *       - Supports both new device connections and existing device status updates
 *       - Updates connectTime and formatConnectTime when connecting
 *       - Returns success/failure status and error information
 *       - Executes asynchronously to avoid blocking main thread
 * [CN]: - 对外设连接状态执行upsert操作
 *       - 如果外设存在：更新连接状态和时间
 *       - 如果外设不存在：创建新的外设记录
 *       - 支持新设备连接和现有设备状态更新
 *       - 连接时更新connectTime和formatConnectTime
 *       - 返回成功/失败状态和错误信息
 *       - 异步执行以避免阻塞主线程
 */
+ (void)updateDeviceConnectionStatusWithUserId:(NSString *)userId
                                    macAddress:(NSString *)macAddress
                                   isConnected:(BOOL)isConnected
                                    completion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;

#pragma mark - 数据转换方法 (Data Conversion)

/**
 * @brief Convert array of dictionaries to TSConnectedPeripheral objects
 * @chinese 将字典数组转换为TSConnectedPeripheral对象数组
 *
 * @param allDeviceInfos
 * [EN]: Array of dictionary objects containing peripheral information
 * [CN]: 包含外设信息的字典对象数组
 *
 * @return
 * [EN]: Array of TSConnectedPeripheral objects
 * [CN]: TSConnectedPeripheral对象数组
 *
 * @discussion
 * [EN]: - Converts raw dictionary data from database to TSConnectedPeripheral objects
 *       - Filters out invalid peripherals during conversion
 *       - Returns empty array if input is nil or empty
 *       - Used internally for database query results processing
 * [CN]: - 将数据库中的原始字典数据转换为TSConnectedPeripheral对象
 *       - 转换过程中过滤掉无效外设
 *       - 如果输入为nil或空则返回空数组
 *       - 内部用于数据库查询结果处理
 */
+ (NSArray<TSConnectedPeripheral *> *)allDevicesFromDictionarys:(NSArray<NSDictionary *> *)allDeviceInfos;

/**
 * @brief Create TSConnectedPeripheral instance from dictionary
 * @chinese 从字典创建TSConnectedPeripheral实例
 *
 * @param dictionary
 * [EN]: Dictionary containing peripheral data
 * [CN]: 包含外设数据的字典
 *
 * @return
 * [EN]: New TSConnectedPeripheral instance
 * [CN]: 新的TSConnectedPeripheral实例
 *
 * @discussion
 * [EN]: - Creates a TSConnectedPeripheral object from dictionary data
 *       - Maps dictionary keys to object properties
 *       - Handles data type conversion (string to number, etc.)
 *       - Used for deserializing data from database or network
 * [CN]: - 从字典数据创建TSConnectedPeripheral对象
 *       - 将字典键映射到对象属性
 *       - 处理数据类型转换（字符串转数字等）
 *       - 用于从数据库或网络反序列化数据
 */
+ (instancetype)peripheralFromDictionary:(NSDictionary *)dictionary;

/**
 * @brief Convert TSConnectedPeripheral to dictionary
 * @chinese 将TSConnectedPeripheral转换为字典
 *
 * @return
 * [EN]: Dictionary representation of the peripheral
 * [CN]: 外设的字典表示
 *
 * @discussion
 * [EN]: - Converts TSConnectedPeripheral object to dictionary format
 *       - Maps all properties to dictionary keys
 *       - Handles nil values by converting to empty strings
 *       - Used for serializing data for database storage or network transmission
 * [CN]: - 将TSConnectedPeripheral对象转换为字典格式
 *       - 将所有属性映射到字典键
 *       - 通过转换为空字符串处理nil值
 *       - 用于序列化数据以便数据库存储或网络传输
 */
- (NSDictionary *)toDictionary;

/**
 * @brief Validate peripheral data integrity
 * @chinese 验证外设数据完整性
 *
 * @return YES if peripheral is valid, NO otherwise
 * @chinese 外设有效返回YES，否则返回NO
 *
 * @discussion
 * [EN]: - Validates essential fields are not empty or nil
 *       - Checks userID, macAddress, and uuidString are present
 *       - Logs validation failures for debugging
 *       - Returns NO if any required field is missing
 * [CN]: - 验证必要字段不为空或nil
 *       - 检查userID、macAddress和uuidString是否存在
 *       - 记录验证失败信息用于调试
 *       - 如果任何必需字段缺失则返回NO
 */
- (BOOL)isValid;

/**
 * @brief Update or insert connected peripheral record
 * @chinese 更新或插入已连接外设记录
 *
 * @param connectedPeripheral
 * EN: TSConnectedPeripheral object to update or insert
 * CN: 要更新或插入的TSConnectedPeripheral对象
 *
 * @param completion
 * EN: Completion callback with success status or error
 * CN: 完成回调，包含成功状态或错误信息
 *
 * @discussion
 * [EN]: This method performs an upsert operation based on the connectedPeripheral object.
 *       It will look up existing records and update if found, or insert if not found.
 *       This provides a more flexible and object-oriented approach to managing device records.
 * [CN]: 此方法基于connectedPeripheral对象执行upsert操作。
 *       将查找现有记录并在找到时更新，或在未找到时插入。
 *       这为管理设备记录提供了更灵活和面向对象的方法。
 */
+ (void)updateConnectedPeripheral:(TSConnectedPeripheral *)connectedPeripheral
                       completion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Delete connected peripheral record
 * @chinese 删除已连接外设记录
 *
 * @param connectedPeripheral
 * EN: TSConnectedPeripheral object to delete
 * CN: 要删除的TSConnectedPeripheral对象
 *
 * @param completion
 * EN: Completion callback with success status or error
 * CN: 完成回调，包含成功状态或错误信息
 *
 * @discussion
 * [EN]: This method deletes the specified connected peripheral record from the database.
 *       The record will be permanently removed based on userID and macAddress.
 * [CN]: 此方法从数据库中删除指定的已连接外设记录。
 *       记录将根据userID和macAddress被永久删除。
 */
+ (void)deleteConnectedPeripheral:(TSConnectedPeripheral *)connectedPeripheral
                       completion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Query connected peripheral record synchronously
 * @chinese 同步查询已连接外设记录
 *
 * @param userId
 * EN: User ID to query for
 * CN: 要查询的用户ID
 *
 * @param macAddress
 * EN: MAC address to query for
 * CN: 要查询的MAC地址
 *
 * @return
 * EN: TSConnectedPeripheral object if found, nil if not found
 * CN: 如果找到则返回TSConnectedPeripheral对象，否则返回nil
 *
 * @discussion
 * [EN]: This method synchronously queries for a connected peripheral record.
 *       It returns the first matching record based on userID and macAddress.
 *       This method should be used when immediate result is needed.
 * CN: 此方法同步查询已连接外设记录。
 *     根据userID和macAddress返回第一个匹配的记录。
 *     当需要立即获得结果时使用此方法。
 */
+ (TSConnectedPeripheral * _Nullable)queryConnectedPeripheralWithUserId:(NSString *)userId
                                                             macAddress:(NSString *)macAddress;

/**
 * @brief Get formatted description of the peripheral
 * @chinese 获取外设的格式化描述
 *
 * @return Formatted string representation of the peripheral
 * @chinese 外设的格式化字符串表示
 *
 * @discussion
 * [EN]: - Returns a human-readable string representation of the peripheral
 *       - Includes all key properties with Chinese labels
 *       - Useful for debugging and logging purposes
 *       - Format: TSConnectedPeripheral with user ID, peripheral info, and connection status
 * [CN]: - 返回外设的人类可读字符串表示
 *       - 包含所有关键属性，带有中文标签
 *       - 适用于调试和日志记录
 *       - 格式：TSConnectedPeripheral，包含用户ID、外设信息和连接状态
 */
- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
