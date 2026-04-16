//
//  TSSqlliteManager.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/24.
//

#import <Foundation/Foundation.h>

// 连接设备管理
#define TSPeripheralTable      @"TSPeripheralTable" // 当前连接设备表
#define TSConnectHistoryTable  @"TSConnectHistoryTable" // 设备连接历史记录表

// 健康数据
#define TSDailyExerciseTable   @"TSDailyExerciseTable"      // 每日活动数据
#define TSHeartRateTable       @"TSHeartRateTable"          // 心率
#define TSOxySaturationTable   @"TSOxySaturationTable"      // 血氧
#define TSBloodPressureTable   @"TSBloodPressureTable"      // 血压
#define TSHealthStressTable    @"TSHealthStressTable"       // 压力
#define TSSleepTable           @"TSSleepTable"              // 睡眠

// 运动记录
#define TSSportRecordTable     @"TSSportRecordTable"        // 运动记录
#define TSSportDetailItemTable @"TSSportDetailItemTable"    // 运动详情
#define TSSportHeartRateTable  @"TSSportHeartRateTable"     // 运动心率
#define TSSportGPSItemTable    @"TSSportGPSItemTable"       // 运动轨迹

#define TS_USER_ID [[[TSFitComDataStorage sharedInstance] connectedParam] userId]
#define TS_MAC_ADDRESS [[TSFitComDataStorage sharedInstance] macAddress]

#define TS_QUERY_DATA_SQL(TABLE_NAME, START_TIME, END_TIME) \
    [NSString stringWithFormat:@"SELECT * FROM %@ WHERE startTime BETWEEN %f AND %f AND userID = '%@' AND macAddress = '%@' ORDER BY startTime ASC", \
    TABLE_NAME, START_TIME, END_TIME, TS_USER_ID, TS_MAC_ADDRESS]

#define TS_QUERY_SLEEP_DATA_SQL(TABLE_NAME, START_TIME, END_TIME) \
    [NSString stringWithFormat:@"SELECT * FROM %@ WHERE dayStartTimestamp BETWEEN %f AND %f AND userID = '%@' AND macAddress = '%@' ORDER BY dayStartTimestamp ASC", \
    TABLE_NAME, START_TIME, END_TIME, TS_USER_ID, TS_MAC_ADDRESS]

#define TS_QUERY_SPORT_DATA_SQL(TABLE_NAME, START_TIME, END_TIME) \
    [NSString stringWithFormat:@"SELECT * FROM %@ WHERE sportID BETWEEN %f AND %f AND userID = '%@' AND macAddress = '%@' ORDER BY sportID ASC", \
    TABLE_NAME, START_TIME, END_TIME, TS_USER_ID, TS_MAC_ADDRESS]

#define TS_QUERY_SPORT_DETAIL_SQL(TABLE_NAME, SPORT_ID) \
    [NSString stringWithFormat:@"SELECT * FROM %@ WHERE sportID = %ld AND userID = '%@' AND macAddress = '%@' ORDER BY sportID ASC", \
    TABLE_NAME, SPORT_ID, TS_USER_ID, TS_MAC_ADDRESS]

#define TS_QUERY_CONNECTION_HISTORY_SQL(USER_ID, MAC, MAX_COUNT) \
    [NSString stringWithFormat:@"SELECT * FROM TSConnectHistoryTable WHERE userID = '%@' AND macAddress = '%@' ORDER BY operationTime ASC LIMIT %ld", \
    USER_ID, MAC, (long)MAX_COUNT]

#define TS_QUERY_CONNECTED_PERIPHERAL_SQL(USER_ID, MAC) \
    [NSString stringWithFormat:@"SELECT * FROM TSPeripheralTable WHERE userID = '%@' AND macAddress = '%@' ORDER BY connectTime ASC", \
    USER_ID, MAC]

#define TS_QUERY_ALL_CONNECTED_PERIPHERALS_SQL(USER_ID) \
    [NSString stringWithFormat:@"SELECT * FROM TSPeripheralTable WHERE userID = '%@' ORDER BY connectTime ASC", \
    USER_ID]

#define TS_QUERY_CONNECTION_HISTORY_BY_TYPE_SQL(USER_ID, MAC, OPERATION_TYPE, MAX_COUNT) \
    [NSString stringWithFormat:@"SELECT * FROM TSConnectHistoryTable WHERE userID = '%@' AND macAddress = '%@' AND operationType = %ld ORDER BY operationTime ASC LIMIT %ld", \
    USER_ID, MAC, (long)OPERATION_TYPE, (long)MAX_COUNT]


NS_ASSUME_NONNULL_BEGIN

@interface TSSqlliteManager : NSObject

/**
 * @brief Get singleton instance
 * @chinese 获取单例实例
 *
 * @return TSFitSqlliteManager instance
 * @chinese 返回TSFitSqlliteManager实例
 */
+ (instancetype)sharedInstance;

/**
 * @brief Initialize the database
 * @chinese 初始化数据库
 */
- (void)initDatabase;

/**
 * @brief Query data with SQL statement
 * @chinese 使用SQL语句查询数据
 *
 * @param sql
 * EN: The SQL query string
 * CN: SQL查询字符串
 *
 * @param isAsync
 * EN: Whether the query is asynchronous
 * CN: 查询是否为异步
 *
 * @param completion
 * EN: The completion block with results or error
 * CN: 完成块，包含结果或错误
 */
- (void)queryDataWithSql:(NSString *)sql
                   async:(BOOL)isAsync
              completion:(nonnull void (^)(NSArray<NSDictionary *> *_Nonnull values, NSError *_Nonnull error))completion;

/**
 * @brief Query data with SQL statement synchronously
 * @chinese 使用SQL语句同步查询数据
 *
 * @param sql
 * EN: The SQL query string
 * CN: SQL查询字符串
 *
 * @return
 * EN: Array of query results, nil if error occurs
 * CN: 查询结果数组，发生错误时返回nil
 *
 * @discussion
 * [EN]: This method performs a synchronous database query and returns the results immediately.
 *       It blocks the current thread until the query completes.
 *       Use this method when you need immediate results without callbacks.
 * [CN]: 此方法执行同步数据库查询并立即返回结果。
 *       它会阻塞当前线程直到查询完成。
 *       当需要立即获得结果而不使用回调时使用此方法。
 */
- (NSArray<NSDictionary *> * _Nullable)queryDataWithSqlSync:(NSString *)sql;

/**
 * @brief Insert data into the specified table
 * @chinese 向指定表中插入数据
 *
 * @param tableName
 * EN: The name of the table to insert data into
 * CN: 要插入数据的表名
 *
 * @param parameters
 * EN: The data to insert, as an array of dictionaries
 * CN: 要插入的数据，作为字典数组
 *
 * @param isAsync
 * EN: Whether the insertion is asynchronous
 * CN: 插入是否为异步
 *
 * @param completion
 * EN: The completion block with success status or error
 * CN: 完成块，包含成功状态或错误
 */
- (void)insertDataWithTableName:(NSString *)tableName
                     parameters:(NSArray<NSDictionary *> *)parameters
                          async:(BOOL)isAsync
                     completion:(void (^)(BOOL, NSError *_Nonnull))completion;

/**
 * @brief Upsert data into the specified table (Insert or Update)
 * @chinese 向指定表中upsert数据（插入或更新）
 *
 * @param tableName
 * EN: The name of the table to upsert data into
 * CN: 要upsert数据的表名
 *
 * @param parameters
 * EN: The data to upsert, as an array of dictionaries
 * CN: 要upsert的数据，作为字典数组
 *
 * @param isAsync
 * EN: Whether the upsert operation is asynchronous
 * CN: upsert操作是否为异步
 *
 * @param completion
 * EN: The completion block with success status or error
 * CN: 完成块，包含成功状态或错误
 *
 * @discussion
 * [EN]: This method performs an upsert operation (INSERT OR REPLACE) on the specified table.
 *       If a record with the same primary key or unique constraint exists, it will be updated.
 *       If no matching record exists, a new record will be inserted.
 *       
 *       This method uses SQLite's INSERT OR REPLACE statement internally.
 *       
 * [CN]: 此方法在指定表上执行upsert操作（INSERT OR REPLACE）。
 *       如果存在相同主键或唯一约束的记录，将被更新。
 *       如果没有匹配的记录，将插入新记录。
 *       
 *       此方法内部使用SQLite的INSERT OR REPLACE语句。
 */
- (void)upsertDataWithTableName:(NSString *)tableName
                     parameters:(NSArray<NSDictionary *> *)parameters
                          async:(BOOL)isAsync
                     completion:(void (^)(BOOL, NSError *_Nonnull))completion;

@end

NS_ASSUME_NONNULL_END
