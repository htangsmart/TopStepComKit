//
//  TSSportModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/3/2.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSportModel (Fit)

+ (void)sportDictWithFitCloudManualSyncRecord:(FitCloudManualSyncRecordObject *)record
                                   completion:(void (^)(NSDictionary *sportDict, NSArray<NSDictionary *> *sportItemArray, NSArray <NSDictionary *> *sportHrItemArray))completion;

/**
 * @brief Convert database dictionary to TSSportModel array
 * @chinese 将数据库字典转换为TSSportModel数组
 *
 * @param dbDict
 * EN: Dictionary containing sport record data from database
 * CN: 从数据库中查询的运动记录数据字典
 *
 * @return
 * EN: Array of TSSportModel objects, nil if conversion fails
 * CN: TSSportModel对象数组，转换失败时返回nil
 */
+ (TSSportModel *)sportModelWithDBDict:(NSDictionary *)dbDict;

/**
 * @brief Create a test FitCloudSportsRecordObject
 * @chinese 创建一个测试用的FitCloudSportsRecordObject对象
 *
 * @return 
 * EN: A FitCloudSportsRecordObject instance with test data
 * CN: 包含测试数据的FitCloudSportsRecordObject实例
 */
+ (FitCloudSportsRecordObject *)tempTestModel;

@end

NS_ASSUME_NONNULL_END
