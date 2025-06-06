//
//  TSDailyActivityValueModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSDailyActivityValueModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSDailyActivityValueModel (Fw)

/**
 * @brief Convert JSON message from Fw to TSDailyActivityValueModel
 * @chinese 将Fw返回的JSON消息转换为TSDailyActivityValueModel对象
 *
 * @param jsonMsg 
 * EN: JSON message dictionary from Fw containing daily exercise data
 * CN: 从Fw获取的包含每日运动数据的JSON消息字典
 *
 * @return 
 * EN: Converted TSDailyActivityValueModel object, nil if conversion fails
 * CN: 转换后的TSDailyActivityValueModel对象，转换失败时返回nil
 */
+ (nullable TSDailyActivityValueModel *)dailyExerciseModelWithFwJsonMsg:(nullable NSDictionary *)jsonMsg;



/**
 * @brief Convert a single dictionary to TSDailyActivityValueModel object
 * @chinese 将单个字典转换为TSDailyActivityValueModel对象
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
 * EN: Converted TSDailyActivityValueModel object, nil if conversion fails
 * CN: 转换后的TSDailyActivityValueModel对象，转换失败时返回nil
 */
+ (nullable TSDailyActivityValueModel *)dailyExerciseModelWithFwDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert array of dictionaries to array of TSDailyActivityValueModel objects
 * @chinese 将字典数组转换为TSDailyActivityValueModel对象数组
 *
 * @param dictArray
 * EN: Array of dictionaries containing daily exercise data
 * CN: 包含每日运动数据的字典数组
 *
 * @return
 * EN: Array of converted TSDailyActivityValueModel objects, nil if conversion fails
 * CN: 转换后的TSDailyActivityValueModel对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSDailyActivityValueModel *> *)dailyExerciseModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;
@end

NS_ASSUME_NONNULL_END
