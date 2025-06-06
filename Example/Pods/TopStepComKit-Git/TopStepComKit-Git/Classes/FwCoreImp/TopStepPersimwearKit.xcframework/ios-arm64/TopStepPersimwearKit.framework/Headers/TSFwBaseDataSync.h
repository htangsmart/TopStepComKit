//
//  TSFwBaseDataSync.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSFwKitBase.h"
#import "TSHealthValueModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFwBaseDataSync : TSFwKitBase

// 查询历史自动测量数据
+ (void)queryDataWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime completion:(void (^)(BOOL succeed, NSArray<TSHealthValueModel *> *_Nullable, NSError *_Nullable))completion;



/**
 * @brief Validate heart rate response data from server
 * @chinese 验证服务器返回的心率数据
 *
 * @param jsonMsg
 * EN: JSON response message to validate
 * CN: 需要验证的JSON响应消息
 *
 * @param error
 * EN: Error pointer to store validation error if any
 * CN: 用于存储验证错误的错误指针
 *
 * @param records
 * EN: Pointer to store validated records array
 * CN: 用于存储验证后记录数组的指针
 *
 * @return
 * EN: YES if validation succeeds, NO if fails
 * CN: 验证成功返回YES，失败返回NO
 */
+ (BOOL)validateHRResponse:(nonnull NSDictionary *)jsonMsg
                    error:(NSError * _Nullable * _Nullable)error
                  records:(NSArray * _Nullable * _Nullable)records;


+ (BOOL)isInvalidTime:(NSTimeInterval)start end:(NSTimeInterval)end;

@end

NS_ASSUME_NONNULL_END
