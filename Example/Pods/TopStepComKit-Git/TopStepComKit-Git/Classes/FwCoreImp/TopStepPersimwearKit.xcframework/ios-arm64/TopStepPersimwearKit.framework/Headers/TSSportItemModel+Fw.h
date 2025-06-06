//
//  TSSportItemModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSportItemModel (Fw)

/**
 * @brief Convert a single dictionary to TSSportItemModel object
 * @chinese 将单个字典转换为TSSportItemModel对象
 *
 * @param dict 
 * EN: Dictionary containing sport item data with:
 * - ts: Timestamp in seconds
 * - d: Dictionary containing detailed metrics:
 *   - cal: Calories burned
 *   - dis: Distance covered
 *   - ds: Start timestamp
 *   - dur: Duration
 *   - hr: Heart rate
 *   - id: Sport ID
 *   - step: Step count
 *   - time: Elapsed time
 * CN: 包含运动项目数据的字典，包含：
 * - ts: 时间戳（秒）
 * - d: 包含详细指标的字典：
 *   - cal: 消耗的卡路里
 *   - dis: 运动距离
 *   - ds: 开始时间戳
 *   - dur: 持续时间
 *   - hr: 心率
 *   - id: 运动ID
 *   - step: 步数
 *   - time: 运动时间
 *
 * @return 
 * EN: Converted TSSportItemModel object, nil if conversion fails
 * CN: 转换后的TSSportItemModel对象，转换失败时返回nil
 */
+ (nullable TSSportItemModel *)sportItemModelWithFwDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert array of dictionaries to array of TSSportItemModel objects
 * @chinese 将字典数组转换为TSSportItemModel对象数组
 *
 * @param dictArray 
 * EN: Array of dictionaries containing sport item data
 * CN: 包含运动项目数据的字典数组
 *
 * @return 
 * EN: Array of converted TSSportItemModel objects, nil if conversion fails
 * CN: 转换后的TSSportItemModel对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSSportItemModel *> *)sportItemModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;

@end

NS_ASSUME_NONNULL_END
