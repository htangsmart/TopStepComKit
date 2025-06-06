//
//  TSCommonCmd.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/7.
//

#import <Foundation/Foundation.h>
#import "TSCommandConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface TSCommonCmd : NSObject

#pragma mark PwSystemStorage
+ (void)getSystemStorageWithKey:(NSString *_Nonnull)key completion:(void (^)(NSDictionary<NSString *, id> *_Nullable jsonMsg, NSError *_Nullable error))completion;

+ (void)getSystemStorageWithKeys:(NSArray *_Nonnull)keys completion:(void (^)(NSDictionary<NSString *, id> *_Nullable jsonMsg,  NSError *_Nullable error))completion;

+ (void)setSystemStorage:(NSDictionary *_Nonnull)dic completion:(void (^)(BOOL isSuccess, NSError *_Nullable error))completion ;


#pragma mark PwWearMessage
+ (void)sendMessageToLauncherWithCmd:(NSString *)cmd key:(NSString *)key completion:(void (^)(BOOL isSuccess, NSError *_Nullable error))completion ;

+ (void)sendMessageToLauncherWithValues:(NSDictionary *)value completion:(void (^)(BOOL isSuccess, NSError *_Nullable error))completion ;

+ (void)sendMessageToLauncherWithCmd:(NSString *)cmd key:(NSString *)key values:( NSDictionary * _Nullable)value completion:(void (^)(BOOL isSuccess, NSError *_Nullable error))completion ;

+ (void)sendMessageToAppWithID:(NSString *)appId values:(NSDictionary *)value completion:(void (^)(BOOL isSuccess, NSError *_Nullable error))completion ;


#pragma mark PwDcm
+ (void)setValuesToPwDCMWithValues:(NSDictionary *)values pool:(NSString *)poolName completion:(void (^)(BOOL isSuccess, NSError *_Nullable error))completion ;
+ (void)getValuesFromPwDCMWithKeys:(NSArray *)keys pool:(NSString *)poolName completion:(void (^)(NSDictionary<NSString *, id> *_Nullable jsonMsg,NSError *_Nullable error))completion ;


#pragma mark  时间同步
+ (void)syncTimeToSystemPwDCMWithTimestamp:(NSTimeInterval)timestamp completion:(void (^)(BOOL isSuccess,NSError *_Nullable error))completion;


#pragma mark  dail
// 删除云端表盘
+ (void)deleteCloudDialWithDialId:(NSString *)cloudDialId completion:(void (^)(BOOL isSuccess,NSError *_Nullable error))completion;
// 切换表盘
+ (void)switchToDialWithDialId:(NSString *)dialId completion:(void (^)(BOOL isSuccess,NSError *_Nullable error))completion;
// 获取所有表盘
+ (void)syncAllDialsCompletion:(void (^)(NSDictionary *jsonMsg ,NSError *_Nullable error))completion;
// 获取当前表盘
+ (void)syncCurrentDialsCompletion:(void (^)(NSDictionary *jsonMsg ,NSError *_Nullable error))completion;
// 云端表盘推送
+ (void)pushCloudDialWith:(NSString *)dialId localPath:(NSString *)localPath completion:(void (^)(NSString *event, NSDictionary<NSString *,id> * _Nonnull jsonMsg))completion;


#pragma mark  db
+ (void)queryValueFormDBWithPath:(NSString *)dbPath startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime completion:(void (^)(NSString * _Nullable event, NSDictionary<NSString *,id> * _Nullable jsonMsg,NSError *_Nullable  error))completion;


@end

NS_ASSUME_NONNULL_END
