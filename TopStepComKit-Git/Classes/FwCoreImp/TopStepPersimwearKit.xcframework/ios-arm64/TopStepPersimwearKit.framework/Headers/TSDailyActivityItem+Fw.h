//
//  TSDailyActivityItem+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSDailyActivityItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSDailyActivityItem (Fw)

/**
 * @brief Convert JSON message from Fw to TSDailyActivityItem
 * @chinese 将Fw返回的JSON消息转换为TSDailyActivityItem对象
 *
 * @param jsonMsg 
 * EN: JSON message dictionary from Fw containing daily exercise data
 * CN: 从Fw获取的包含每日运动数据的JSON消息字典
 *
 * @return 
 * EN: Converted TSDailyActivityItem object, nil if conversion fails
 * CN: 转换后的TSDailyActivityItem对象，转换失败时返回nil
 */
+ (nullable TSDailyActivityItem *)dailyExerciseModelWithFwJsonMsg:(nullable NSDictionary *)jsonMsg;



/**
 * @brief Convert a single dictionary to TSDailyActivityItem object
 * @chinese 将单个字典转换为TSDailyActivityItem对象
 *
 * @param dict
 * EN: Dictionary containing daily exercise data with:
 * - ts: Timestamp in seconds
 * - d: Dictionary containing exercise details:
 *   - calorie: Calories burned
 *   - distance: Distance covered
 *   - number: Exercise count
 *   - sit: Sitting time
 *   - sport: Sport time
 *   - stand: Standing time
 *   - steps: Step count
 * CN: 包含每日运动数据的字典，包含：
 * - ts: 时间戳（秒）
 * - d: 包含运动详情的字典：
 *   - calorie: 消耗的卡路里
 *   - distance: 运动距离
 *   - number: 运动次数
 *   - sit: 久坐时间
 *   - sport: 运动时间
 *   - stand: 站立时间
 *   - steps: 步数
 *
 * @return
 * EN: Converted TSDailyActivityItem object, nil if conversion fails
 * CN: 转换后的TSDailyActivityItem对象，转换失败时返回nil
 */
+ (nullable TSDailyActivityItem *)dailyExerciseModelWithFwDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert array of dictionaries to array of TSDailyActivityItem objects
 * @chinese 将字典数组转换为TSDailyActivityItem对象数组
 *
 * @param dictArray
 * EN: Array of dictionaries containing daily exercise data
 * CN: 包含每日运动数据的字典数组
 *
 * @return
 * EN: Array of converted TSDailyActivityItem objects, nil if conversion fails
 * CN: 转换后的TSDailyActivityItem对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSDailyActivityItem *> *)dailyExerciseModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;

/**
 * @brief Convert TSDailyActivityItem array to dictionary array for database insertion
 * @chinese 将TSDailyActivityItem数组转换为数据库插入用的字典数组
 *
 * @param activityItems
 * EN: Array of TSDailyActivityItem objects to be converted
 * CN: 需要转换的TSDailyActivityItem对象数组
 *
 * @return
 * EN: Array of dictionaries with fields matching TSDailyExerciseTable structure
 * CN: 字典数组，字段与TSDailyExerciseTable结构保持一致
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromActivityItems:(NSArray<TSDailyActivityItem *> *)activityItems;

@end

NS_ASSUME_NONNULL_END
