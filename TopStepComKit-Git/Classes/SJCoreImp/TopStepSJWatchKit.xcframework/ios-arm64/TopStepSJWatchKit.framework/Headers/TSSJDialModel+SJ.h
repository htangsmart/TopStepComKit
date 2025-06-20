//
//  TSSJDialModel+SJ.h
//  BitByteData
//
//  Created by 磐石 on 2025/3/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMDialModel;
@class WMCustomDialModel;
NS_ASSUME_NONNULL_BEGIN

@interface TSSJDialModel (SJ)

/**
 * @brief Convert TSSJDialModel to WMDialModel
 * @chinese 将TSSJDialModel转换为WMDialModel
 *
 * @param tsModel 
 * EN: TSSJDialModel object to be converted
 * CN: 需要转换的TSSJDialModel对象
 *
 * @return 
 * EN: Converted WMDialModel object, nil if conversion fails
 * CN: 转换后的WMDialModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts TSSJDialModel to WMDialModel:
 *     - Maps dial ID
 *     - Sets built-in status
 *     - Sets current status
 * CN: 该方法将TSSJDialModel转换为WMDialModel：
 *     - 映射表盘ID
 *     - 设置内置状态
 *     - 设置当前状态
 */
+ (nullable WMDialModel *)wmModelWithTSSJDialModel:(nullable TSSJDialModel *)tsModel;

/**
 * @brief Convert TSSJDialModel array to WMDialModel array
 * @chinese 将TSSJDialModel数组转换为WMDialModel数组
 *
 * @param tsModels 
 * EN: Array of TSSJDialModel objects to be converted
 * CN: 需要转换的TSSJDialModel对象数组
 *
 * @return 
 * EN: Array of WMDialModel objects, empty array if conversion fails
 * CN: 转换后的WMDialModel对象数组，如果转换失败则返回空数组
 */
+ (NSArray<WMDialModel *> *)wmModelsWithTSSJDialModels:(NSArray<TSSJDialModel *> *)tsModels;

/**
 * @brief Convert WMDialModel to TSSJDialModel
 * @chinese 将WMDialModel转换为TSSJDialModel
 *
 * @param wmModel 
 * EN: WMDialModel object to be converted
 * CN: 需要转换的WMDialModel对象
 *
 * @return 
 * EN: Converted TSSJDialModel object, nil if conversion fails
 * CN: 转换后的TSSJDialModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts WMDialModel to TSSJDialModel:
 *     - Maps dial ID
 *     - Sets built-in status
 *     - Sets current status
 * CN: 该方法将WMDialModel转换为TSSJDialModel：
 *     - 映射表盘ID
 *     - 设置内置状态
 *     - 设置当前状态
 */
+ (nullable TSSJDialModel *)modelWithWMDialModel:(nullable WMDialModel *)wmModel;

/**
 * @brief Convert WMDialModel array to TSSJDialModel array
 * @chinese 将WMDialModel数组转换为TSSJDialModel数组
 *
 * @param wmModels 
 * EN: Array of WMDialModel objects to be converted
 * CN: 需要转换的WMDialModel对象数组
 *
 * @return 
 * EN: Array of TSSJDialModel objects, empty array if conversion fails
 * CN: 转换后的TSSJDialModel对象数组，如果转换失败则返回空数组
 */
+ (NSArray<TSSJDialModel *> *)modelsWithWMDialModels:(NSArray<WMDialModel *> *)wmModels;


+ (nullable WMCustomDialModel *)wmCustomerModelWithTSSJDialModel:(nullable TSSJDialModel *)dialModel ;

@end

NS_ASSUME_NONNULL_END
