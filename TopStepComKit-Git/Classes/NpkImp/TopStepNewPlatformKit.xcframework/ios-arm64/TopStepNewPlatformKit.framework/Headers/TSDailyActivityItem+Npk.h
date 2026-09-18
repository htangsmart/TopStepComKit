//
//  TSDailyActivityItem+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/8.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSMetaActivityDay;

@interface TSDailyActivityItem (Npk)

/**
 * @brief Convert TSMetaActivityDay array to dictionary array
 * @chinese 将TSMetaActivityDay数组转换为字典数组
 * 
 * @param activityDays 
 * EN: Array of TSMetaActivityDay objects to be converted
 * CN: 需要转换的TSMetaActivityDay对象数组
 * 
 * @return 
 * EN: Array of dictionaries with fields matching TSDailyExerciseTable structure
 * CN: 字典数组，字段与TSDailyExerciseTable结构保持一致
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromActivityDays:(NSArray<TSMetaActivityDay *> *)activityDays;


@end

NS_ASSUME_NONNULL_END
