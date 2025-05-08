//
//  TSFitDialModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudWatchfaceSlot;
@class FitCloudWatchfaceUIInfo;
NS_ASSUME_NONNULL_BEGIN

@interface TSFitDialModel (Fit)

/**
 * @brief Convert FitCloudWatchfaceSlot to TSFitDialModel
 * @chinese 将FitCloudWatchfaceSlot转换为TSFitDialModel
 * 
 * @param slot 
 * EN: FitCloudWatchfaceSlot object to be converted
 * CN: 需要转换的FitCloudWatchfaceSlot对象
 * 
 * @return 
 * EN: A new TSFitDialModel instance with properties set from the slot
 * CN: 根据slot信息设置属性的新TSFitDialModel实例
 * 
 * @discussion 
 * EN: This method converts a FitCloudWatchfaceSlot object to TSFitDialModel:
 *     - Sets dialId from watchfaceNo
 *     - Sets dialName from name property
 *     - Sets dialType based on isBuiltin and isCustom flags
 *     - Sets dialSize from width and height
 *     - Sets dialPreviewSize from previewWidth and previewHeight
 *     - Sets version and hidden properties
 * CN: 此方法将FitCloudWatchfaceSlot对象转换为TSFitDialModel：
 *     - 从watchfaceNo设置dialId
 *     - 从name属性设置dialName
 *     - 根据isBuiltin和isCustom标志设置dialType
 *     - 从width和height设置dialSize
 *     - 从previewWidth和previewHeight设置dialPreviewSize
 *     - 设置version和hidden属性
 */
+ (instancetype)modelWithFitCloudWatchfaceSlot:(FitCloudWatchfaceSlot *)slot;

/**
 * @brief Convert FitCloudWatchfaceSlot to TSFitDialModel with UI info
 * @chinese 使用UI信息将FitCloudWatchfaceSlot转换为TSFitDialModel
 * 
 * @param slot 
 * EN: FitCloudWatchfaceSlot object to be converted
 * CN: 需要转换的FitCloudWatchfaceSlot对象
 * 
 * @param uiInfo 
 * EN: FitCloudWatchfaceUIInfo object containing additional UI information
 * CN: 包含额外UI信息的FitCloudWatchfaceUIInfo对象
 * 
 * @return 
 * EN: A new TSFitDialModel instance with properties set from both slot and UI info
 * CN: 根据slot和UI信息设置属性的新TSFitDialModel实例
 * 
 * @discussion 
 * EN: This method extends the basic conversion by adding UI information:
 *     - All basic properties from modelWithFitCloudWatchfaceSlot:
 *     - Additional UI properties from FitCloudWatchfaceUIInfo
 *     - Sets isCurrentDial flag based on watchfaceNo comparison
 * CN: 此方法通过添加UI信息扩展了基本转换：
 *     - 包含modelWithFitCloudWatchfaceSlot:的所有基本属性
 *     - 从FitCloudWatchfaceUIInfo添加额外的UI属性
 *     - 根据watchfaceNo比较设置isCurrentDial标志
 */
+ (instancetype)modelWithFitCloudWatchfaceSlot:(FitCloudWatchfaceSlot *)slot
                                       uiInfo:(FitCloudWatchfaceUIInfo *)uiInfo;

/**
 * @brief Get the FitCloud watch face time position
 * @chinese 获取FitCloud表盘时间位置
 * 
 * @return 
 * EN: FitCloud watch face time position value:
 *     - FITCLOUDWATCHFACEDTPOSITION_TOP (0): Time displayed at the top
 *     - FITCLOUDWATCHFACEDTPOSITION_BOTTOM (1): Time displayed at the bottom
 *     - FITCLOUDWATCHFACEDTPOSITION_LEFT (2): Time displayed on the left
 *     - FITCLOUDWATCHFACEDTPOSITION_RIGHT (3): Time displayed on the right
 * CN: FitCloud表盘时间位置值：
 *     - FITCLOUDWATCHFACEDTPOSITION_TOP (0): 时间显示在顶部
 *     - FITCLOUDWATCHFACEDTPOSITION_BOTTOM (1): 时间显示在底部
 *     - FITCLOUDWATCHFACEDTPOSITION_LEFT (2): 时间显示在左侧
 *     - FITCLOUDWATCHFACEDTPOSITION_RIGHT (3): 时间显示在右侧
 * 
 * @discussion 
 * EN: This method converts TSDialTimePosition to FitCloud's position value.
 *     Used when creating or updating custom watch faces.
 *     Default position is TOP if the current position is invalid.
 * CN: 此方法将TSDialTimePosition转换为FitCloud的位置值。
 *     在创建或更新自定义表盘时使用。
 *     如果当前位置无效，默认位置为顶部。
 */
- (NSInteger)fitPosition;


+ (BOOL)isProject_9804;

+ (void)getEnablePushDial:(TSFitDialModel *)dial completeion:(void(^)(BOOL result,NSInteger switchDialIndex, NSInteger enablePushDialIndex))completion;

@end

NS_ASSUME_NONNULL_END
