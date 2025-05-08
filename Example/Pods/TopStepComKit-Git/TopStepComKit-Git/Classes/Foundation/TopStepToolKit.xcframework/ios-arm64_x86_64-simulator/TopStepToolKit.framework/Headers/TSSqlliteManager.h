//
//  TSSqlliteManager.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/24.
//

#import <Foundation/Foundation.h>


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

@end

NS_ASSUME_NONNULL_END
