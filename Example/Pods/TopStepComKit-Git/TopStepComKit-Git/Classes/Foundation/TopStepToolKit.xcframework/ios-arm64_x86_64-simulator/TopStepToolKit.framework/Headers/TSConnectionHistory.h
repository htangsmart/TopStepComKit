//
//  TSConnectionHistory.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/1/15.
//

#import <Foundation/Foundation.h>
#import "TSError.h"
#import "TSLogPrinter.h"
#import "NSDate+Tool.h"
NS_ASSUME_NONNULL_BEGIN

#pragma mark - 枚举定义 (Enums)

/**
 * @brief Operation type
 * @chinese 操作类型
 *
 * @discussion
 * [EN]: Enumerates operation types for device operation history records.
 * [CN]: 枚举设备操作历史记录中的操作类型。
 */
typedef NS_ENUM(NSInteger, TSOperationType) {
    eTSOperationUnbind    = 0,  // 解绑
    eTSOperationBind      = 1,  // 绑定
    eTSOperationConnect   = 2,  // 连接
    eTSOperationDisconnect = 3, // 断开连接
};

/**
 * @brief Operation result type
 * @chinese 操作结果类型
 *
 * @discussion
 * [EN]: Enumerates operation result types.
 * [CN]: 枚举操作结果类型。
 */
typedef NS_ENUM(NSInteger, TSOperationResult) {
    eTSOperationResultFailed  = 0,  // 失败
    eTSOperationResultSuccess = 1,  // 成功
};

/**
 * @brief 设备连接历史记录管理类
 * @chinese 用于管理设备连接历史记录
 *
 * @discussion
 * [EN]: This class manages the device connection history records.
 *       It corresponds to TSConnectHistoryTable in the database, storing
 *       all connection operations including bind, unbind, connect, and disconnect.
 * [CN]: 此类用于管理设备连接历史记录。
 *       对应数据库中的TSConnectHistoryTable表，存储所有连接操作包括绑定、解绑、连接和断开连接。
 */
@interface TSConnectionHistory : NSObject

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

/**
 * @brief Device MAC address
 * @chinese 设备MAC地址
 *
 * @discussion
 * [EN]: Unique hardware identifier of the device
 * [CN]: 设备的唯一硬件标识符
 */
@property (nonatomic, copy) NSString *macAddress;

#pragma mark - 设备信息 (Device Information)

/**
 * @brief Device Bluetooth name
 * @chinese 设备蓝牙名称
 *
 * @discussion
 * [EN]: Bluetooth broadcast name of the device (only recorded during bind operation)
 * [CN]: 设备的蓝牙广播名称（仅在绑定操作时记录）
 */
@property (nonatomic, copy, nullable) NSString *bleName;

/**
 * @brief Device UUID string
 * @chinese 设备UUID字符串
 *
 * @discussion
 * [EN]: UUID identifier of the device (only recorded during bind operation)
 * [CN]: 设备的UUID标识符（仅在绑定操作时记录）
 */
@property (nonatomic, copy, nullable) NSString *uuidString;

/**
 * @brief Project ID
 * @chinese 项目ID
 *
 * @discussion
 * [EN]: Identifier of the project the device belongs to (only recorded during bind operation)
 * [CN]: 设备所属项目的标识符（仅在绑定操作时记录）
 */
@property (nonatomic, copy, nullable) NSString *projectId;

/**
 * @brief Firmware version
 * @chinese 固件版本
 *
 * @discussion
 * [EN]: Current firmware version running on the device (only recorded during bind operation)
 * [CN]: 设备当前运行的固件版本（仅在绑定操作时记录）
 */
@property (nonatomic, copy, nullable) NSString *firmVersion;

#pragma mark - 操作信息 (Operation Information)

/**
 * @brief Operation type
 * @chinese 操作类型
 *
 * @discussion
 * [EN]: Type of operation performed on the device
 * [CN]: 对设备执行的操作类型
 */
@property (nonatomic, assign) TSOperationType operationType;

/**
 * @brief Operation result
 * @chinese 操作结果
 *
 * @discussion
 * [EN]: Result of the operation (success or failure)
 * [CN]: 操作的结果（成功或失败）
 */
@property (nonatomic, assign) TSOperationResult operationResult;

/**
 * @brief Error message
 * @chinese 错误信息
 *
 * @discussion
 * [EN]: Error message if operation failed, nil if successful
 * [CN]: 操作失败时的错误信息，成功时为nil
 */
@property (nonatomic, copy, nullable) NSString *errorMessage;

/**
 * @brief Operation timestamp
 * @chinese 操作时间戳
 *
 * @discussion
 * [EN]: Unix timestamp when the operation was performed
 * [CN]: 执行操作时的Unix时间戳
 */
@property (nonatomic, assign) NSTimeInterval operationTime;

/**
 * @brief Formatted operation time
 * @chinese 格式化操作时间
 *
 * @discussion
 * [EN]: Human-readable formatted time string for operationTime
 * [CN]: operationTime对应的人类可读格式化时间字符串
 */
@property (nonatomic, copy) NSString *formatOperationTime;

#pragma mark - 创建方法 (Creation Methods)

/**
 * @brief Create connection history with basic information
 * @chinese 使用基本信息创建连接历史记录
 */
+ (instancetype)connectionHistoryWithUserID:(NSString *)userID
                                macAddress:(NSString *)macAddress
                             operationType:(TSOperationType)operationType;

/**
 * @brief Create connection history with device information
 * @chinese 使用设备信息创建连接历史记录
 */
+ (instancetype)connectionHistoryWithUserID:(NSString *)userID
                                macAddress:(NSString *)macAddress
                             operationType:(TSOperationType)operationType
                                   bleName:(nullable NSString *)bleName
                                uuidString:(nullable NSString *)uuidString
                                  projectId:(nullable NSString *)projectId
                                firmVersion:(nullable NSString *)firmVersion;

/**
 * @brief Create connection history with operation result
 * @chinese 使用操作结果创建连接历史记录
 */
+ (instancetype)connectionHistoryWithUserID:(NSString *)userID
                                macAddress:(NSString *)macAddress
                             operationType:(TSOperationType)operationType
                            operationResult:(TSOperationResult)operationResult
                               errorMessage:(nullable NSString *)errorMessage;

/**
 * @brief Create connection history with all information
 * @chinese 使用完整信息创建连接历史记录
 */
+ (instancetype)connectionHistoryWithUserID:(NSString *)userID
                                macAddress:(NSString *)macAddress
                             operationType:(TSOperationType)operationType
                            operationResult:(TSOperationResult)operationResult
                               errorMessage:(nullable NSString *)errorMessage
                                    bleName:(nullable NSString *)bleName
                                 uuidString:(nullable NSString *)uuidString
                                   projectId:(nullable NSString *)projectId
                                 firmVersion:(nullable NSString *)firmVersion;

#pragma mark - 数据库操作方法 (Database Operations)

/**
 * @brief Save device operation history to database
 * @chinese 保存设备操作历史到数据库
 *
 * @param connectionHistory
 * [EN]: Device operation history to be saved
 * [CN]: 要保存的设备操作历史
 *
 * @param completion
 * [EN]: Callback block that returns save result
 * [CN]: 返回保存结果的回调块
 *
 * @discussion
 * [EN]: - Saves the device operation history to local database
 *       - Validates operation history data before saving
 *       - Returns success/failure status and error information
 *       - Executes asynchronously to avoid blocking main thread
 * [CN]: - 将设备操作历史保存到本地数据库
 *       - 保存前验证操作历史数据
 *       - 返回成功/失败状态和错误信息
 *       - 异步执行以避免阻塞主线程
 */
+ (void)saveConnectionHistory:(TSConnectionHistory *)connectionHistory
                   completion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Query device operation history by user ID and MAC address
 * @chinese 根据用户ID和MAC地址查询设备操作历史
 *
 * @param userId
 * [EN]: User ID to filter operations
 * [CN]: 用于过滤操作的用户ID
 *
 * @param macAddress
 * [EN]: MAC address to filter operations
 * [CN]: 用于过滤操作的MAC地址
 *
 * @param maxCount
 * [EN]: Maximum number of records to return (0 for no limit)
 * [CN]: 返回的最大记录数（0表示无限制）
 *
 * @param completion
 * [EN]: Callback block that returns query results
 * [CN]: 返回查询结果的回调块
 *
 * @discussion
 * [EN]: - Queries device operation history from local database
 *       - Filters by user ID and MAC address combination
 *       - Returns array of operation history records or empty array if none found
 *       - Supports limiting the number of returned records
 *       - Executes asynchronously to avoid blocking main thread
 * [CN]: - 从本地数据库查询设备操作历史
 *       - 根据用户ID和MAC地址组合进行过滤
 *       - 返回操作历史记录数组，如果没有找到则返回空数组
 *       - 支持限制返回的记录数量
 *       - 异步执行以避免阻塞主线程
 */
+ (void)queryConnectionHistoryWithUserId:(NSString *)userId
                             macAddress:(NSString *)macAddress
                               maxCount:(NSInteger)maxCount
                             completion:(void (^)(NSArray<TSConnectionHistory *> *operations, NSError * _Nullable error))completion;

/**
 * @brief Query device operation history by user ID
 * @chinese 根据用户ID查询设备操作历史
 *
 * @param userId
 * [EN]: User ID to filter operations
 * [CN]: 用于过滤操作的用户ID
 *
 * @param maxCount
 * [EN]: Maximum number of records to return (0 for no limit)
 * [CN]: 返回的最大记录数（0表示无限制）
 *
 * @param completion
 * [EN]: Callback block that returns query results
 * [CN]: 返回查询结果的回调块
 *
 * @discussion
 * [EN]: - Queries all device operation history for a user from local database
 *       - Filters by user ID
 *       - Returns array of operation history records or empty array if none found
 *       - Supports limiting the number of returned records
 *       - Executes asynchronously to avoid blocking main thread
 * [CN]: - 从本地数据库查询用户的所有设备操作历史
 *       - 根据用户ID进行过滤
 *       - 返回操作历史记录数组，如果没有找到则返回空数组
 *       - 支持限制返回的记录数量
 *       - 异步执行以避免阻塞主线程
 */
+ (void)queryConnectionHistoryWithUserId:(NSString *)userId
                               maxCount:(NSInteger)maxCount
                             completion:(void (^)(NSArray<TSConnectionHistory *> *operations, NSError * _Nullable error))completion;

/**
 * @brief Query operation history by operation type
 * @chinese 根据操作类型查询操作历史
 *
 * @param userId
 * [EN]: User ID to filter operations
 * [CN]: 用于过滤操作的用户ID
 *
 * @param macAddress
 * [EN]: MAC address to filter operations
 * [CN]: 用于过滤操作的MAC地址
 *
 * @param operationType
 * [EN]: Operation type to filter
 * [CN]: 要过滤的操作类型
 *
 * @param maxCount
 * [EN]: Maximum number of records to return (0 for no limit)
 * [CN]: 返回的最大记录数（0表示无限制）
 *
 * @param completion
 * [EN]: Callback block that returns query results
 * [CN]: 返回查询结果的回调块
 *
 * @discussion
 * [EN]: - Queries device operation history filtered by operation type
 *       - Filters by user ID, MAC address, and operation type
 *       - Returns array of matching operation history records
 *       - Supports limiting the number of returned records
 *       - Executes asynchronously to avoid blocking main thread
 * [CN]: - 根据操作类型查询设备操作历史
 *       - 根据用户ID、MAC地址和操作类型进行过滤
 *       - 返回匹配的操作历史记录数组
 *       - 支持限制返回的记录数量
 *       - 异步执行以避免阻塞主线程
 */
+ (void)queryConnectionHistoryWithUserId:(NSString *)userId
                             macAddress:(NSString *)macAddress
                         operationType:(TSOperationType)operationType
                               maxCount:(NSInteger)maxCount
                             completion:(void (^)(NSArray<TSConnectionHistory *> *operations, NSError * _Nullable error))completion;

#pragma mark - 数据转换方法 (Data Conversion)

/**
 * @brief Convert array of dictionaries to TSConnectionHistory objects
 * @chinese 将字典数组转换为TSConnectionHistory对象数组
 *
 * @param allConnectionInfos
 * [EN]: Array of dictionary objects containing operation information
 * [CN]: 包含操作信息的字典对象数组
 *
 * @return
 * [EN]: Array of TSConnectionHistory objects
 * [CN]: TSConnectionHistory对象数组
 *
 * @discussion
 * [EN]: - Converts raw dictionary data from database to TSConnectionHistory objects
 *       - Filters out invalid operations during conversion
 *       - Returns empty array if input is nil or empty
 *       - Used internally for database query results processing
 * [CN]: - 将数据库中的原始字典数据转换为TSConnectionHistory对象
 *       - 转换过程中过滤掉无效操作
 *       - 如果输入为nil或空则返回空数组
 *       - 内部用于数据库查询结果处理
 */
+ (NSArray<TSConnectionHistory *> *)allConnectionsFromDictionarys:(NSArray<NSDictionary *> *)allConnectionInfos;

/**
 * @brief Create TSConnectionHistory instance from dictionary
 * @chinese 从字典创建TSConnectionHistory实例
 *
 * @param dictionary
 * [EN]: Dictionary containing operation data
 * [CN]: 包含操作数据的字典
 *
 * @return
 * [EN]: New TSConnectionHistory instance
 * [CN]: 新的TSConnectionHistory实例
 *
 * @discussion
 * [EN]: - Creates a TSConnectionHistory object from dictionary data
 *       - Maps dictionary keys to object properties
 *       - Handles data type conversion (string to number, etc.)
 *       - Used for deserializing data from database or network
 * [CN]: - 从字典数据创建TSConnectionHistory对象
 *       - 将字典键映射到对象属性
 *       - 处理数据类型转换（字符串转数字等）
 *       - 用于从数据库或网络反序列化数据
 */
+ (instancetype)connectionFromDictionary:(NSDictionary *)dictionary;

/**
 * @brief Convert TSConnectionHistory to dictionary
 * @chinese 将TSConnectionHistory转换为字典
 *
 * @return
 * [EN]: Dictionary representation of the operation
 * [CN]: 操作的字典表示
 *
 * @discussion
 * [EN]: - Converts TSConnectionHistory object to dictionary format
 *       - Maps all properties to dictionary keys
 *       - Handles nil values by converting to empty strings
 *       - Used for serializing data for database storage or network transmission
 * [CN]: - 将TSConnectionHistory对象转换为字典格式
 *       - 将所有属性映射到字典键
 *       - 通过转换为空字符串处理nil值
 *       - 用于序列化数据以便数据库存储或网络传输
 */
- (NSDictionary *)toDictionary;

/**
 * @brief Validate operation history data integrity
 * @chinese 验证操作历史数据完整性
 *
 * @return YES if operation history is valid, NO otherwise
 * @chinese 操作历史有效返回YES，否则返回NO
 *
 * @discussion
 * [EN]: - Validates essential fields are not empty or nil
 *       - Checks userID, macAddress, and operationType are present
 *       - Logs validation failures for debugging
 *       - Returns NO if any required field is missing
 * [CN]: - 验证必要字段不为空或nil
 *       - 检查userID、macAddress和operationType是否存在
 *       - 记录验证失败信息用于调试
 *       - 如果任何必需字段缺失则返回NO
 */
- (BOOL)isValid;

/**
 * @brief Get formatted description of the operation history
 * @chinese 获取操作历史的格式化描述
 *
 * @return Formatted string representation of the operation history
 * @chinese 操作历史的格式化字符串表示
 *
 * @discussion
 * [EN]: - Returns a human-readable string representation of the operation history
 *       - Includes all key properties with Chinese labels
 *       - Useful for debugging and logging purposes
 *       - Format: TSConnectionHistory with user ID, device info, operation details, and result
 * [CN]: - 返回操作历史的人类可读字符串表示
 *       - 包含所有关键属性，带有中文标签
 *       - 适用于调试和日志记录
 *       - 格式：TSConnectionHistory，包含用户ID、设备信息、操作详情和结果
 */
- (NSString *)description;

/**
 * @brief Get operation type description
 * @chinese 获取操作类型描述
 *
 * @return Human-readable operation type string
 * @chinese 人类可读的操作类型字符串
 *
 * @discussion
 * [EN]: - Returns a human-readable string for the operation type
 *       - Used for logging and debugging purposes
 *       - Maps enum values to descriptive strings
 * [CN]: - 返回操作类型的人类可读字符串
 *       - 用于日志记录和调试
 *       - 将枚举值映射为描述性字符串
 */
- (NSString *)operationTypeDescription;

/**
 * @brief Get operation result description
 * @chinese 获取操作结果描述
 *
 * @return Human-readable operation result string
 * @chinese 人类可读的操作结果字符串
 *
 * @discussion
 * [EN]: - Returns a human-readable string for the operation result
 *       - Used for logging and debugging purposes
 *       - Maps enum values to descriptive strings
 * [CN]: - 返回操作结果的人类可读字符串
 *       - 用于日志记录和调试
 *       - 将枚举值映射为描述性字符串
 */
- (NSString *)connectionResultDescription;

@end

NS_ASSUME_NONNULL_END
