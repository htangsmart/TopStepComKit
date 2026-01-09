//
//  TSDialModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudWatchfaceSlot;
@class FitCloudWatchfaceUIInfo;
NS_ASSUME_NONNULL_BEGIN

@interface TSDialModel (Fit)

/**
 * @brief Convert FitCloudWatchfaceSlot to TSDialModel
 * @chinese 将FitCloudWatchfaceSlot转换为TSDialModel
 * 
 * @param slot 
 * EN: FitCloudWatchfaceSlot object to be converted
 * CN: 需要转换的FitCloudWatchfaceSlot对象
 * 
 * @return 
 * EN: A new TSDialModel instance with properties set from the slot
 * CN: 根据slot信息设置属性的新TSDialModel实例
 * 
 * @discussion 
 * EN: This method converts a FitCloudWatchfaceSlot object to TSDialModel:
 *     - Sets dialId from watchfaceNo
 *     - Sets dialName from name property
 *     - Sets dialType based on isBuiltin and isCustom flags
 *     - Sets dialSize from width and height
 *     - Sets dialPreviewSize from previewWidth and previewHeight
 *     - Sets version and hidden properties
 * CN: 此方法将FitCloudWatchfaceSlot对象转换为TSDialModel：
 *     - 从watchfaceNo设置dialId
 *     - 从name属性设置dialName
 *     - 根据isBuiltin和isCustom标志设置dialType
 *     - 从width和height设置dialSize
 *     - 从previewWidth和previewHeight设置dialPreviewSize
 *     - 设置version和hidden属性
 */
+ (instancetype)modelWithFitCloudWatchfaceSlot:(FitCloudWatchfaceSlot *)slot;

/**
 * @brief Convert FitCloudWatchfaceSlot to TSDialModel with UI info
 * @chinese 使用UI信息将FitCloudWatchfaceSlot转换为TSDialModel
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
 * EN: A new TSDialModel instance with properties set from both slot and UI info
 * CN: 根据slot和UI信息设置属性的新TSDialModel实例
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



+ (BOOL)isProject_9804;

+ (void)getEnablePushDial:(TSDialModel *)dial completeion:(void(^)(BOOL result,NSInteger switchDialIndex, NSInteger enablePushDialIndex))completion;

@end

NS_ASSUME_NONNULL_END
