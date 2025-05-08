//
//  TSFitBaseDataSync.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/25.
//

#import <TopStepFitKit/TopStepFitKit.h>
#import <TopStepToolKit/TopStepToolKit.h>
#import "TSFitComDataStorage.h"
NS_ASSUME_NONNULL_BEGIN

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
    [NSString stringWithFormat:@"SELECT * FROM %@ WHERE sportID = %f AND userID = '%@' AND macAddress = '%@' ORDER BY sportID ASC", \
    TABLE_NAME, SPORT_ID, TS_USER_ID, TS_MAC_ADDRESS]



@interface TSFitBaseDataSync : TSFitKitBase

/**
 * @brief Query data from the database within a specified time range.
 * @chinese 在指定时间范围内从数据库查询数据。
 * 
 * @param startTime
 * EN: The start time for the query in seconds since 1970.
 * CN: 查询的开始时间，以1970年后的秒数表示。
 * 
 * @param endTime
 * EN: The end time for the query in seconds since 1970.
 * CN: 查询的结束时间，以1970年后的秒数表示。
 * 
 * @param completion
 * EN: The completion block that returns the success status, an array of data models, and an error if any.
 * CN: 完成块，返回成功状态、数据模型数组和可能的错误。
 */
+ (void)queryDataFromDBWithStartTime:(NSTimeInterval)startTime
                             endTime:(NSTimeInterval)endTime
                          completion:(void (^)(BOOL succeed, NSArray <TSHealthValueModel *> * _Nullable allDatas,  NSError *_Nullable error))completion;

/**
 * @brief Insert data into the database from a FitCloudManualSyncRecordObject.
 * @chinese 从FitCloudManualSyncRecordObject插入数据到数据库。
 * 
 * @param record
 * EN: The record object containing data to be inserted.
 * CN: 包含要插入数据的记录对象。
 * 
 * @param completion
 * EN: The completion block that returns the success status and an error if any.
 * CN: 完成块，返回成功状态和可能的错误。
 */
+ (void)insertDataIntoDBWithRecord:(FitCloudManualSyncRecordObject *)record 
                        completion:(void (^)(BOOL succeed, NSError *_Nullable error))completion;


+ (BOOL)isInvalidTime:(NSTimeInterval)start end:(NSTimeInterval)end;
@end

NS_ASSUME_NONNULL_END
