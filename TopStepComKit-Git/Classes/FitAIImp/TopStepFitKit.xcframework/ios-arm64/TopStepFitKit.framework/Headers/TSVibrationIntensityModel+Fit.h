//
//  TSVibrationIntensityModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/7/21.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudVibrateSetting;

NS_ASSUME_NONNULL_BEGIN

@interface TSVibrationIntensityModel (Fit)

/**
 * @brief Convert FitCloudVibrateSetting to TSVibrationIntensityModel
 * @chinese 将 FitCloudVibrateSetting 转换为 TSVibrationIntensityModel
 *
 * @param vibrateSetting
 * EN: FitCloudVibrateSetting object to be converted.
 * CN: 需要转换的 FitCloudVibrateSetting 对象。
 *
 * @return
 * EN: Converted TSVibrationIntensityModel object, nil if unsupported or conversion fails.
 * CN: 转换后的 TSVibrationIntensityModel 对象，不支持或转换失败时返回 nil。
 */
+ (nullable TSVibrationIntensityModel *)modelWithFitCloudVibrateSetting:(nullable FitCloudVibrateSetting *)vibrateSetting;

/**
 * @brief Get supported vibration intensity level count
 * @chinese 获取支持的震动强度档位数量
 *
 * @param vibrateSetting
 * EN: FitCloudVibrateSetting object.
 * CN: FitCloudVibrateSetting 对象。
 *
 * @return
 * EN: Supported level count.
 * CN: 支持的档位数量。
 */
+ (NSInteger)vibrationLevelCountWithFitCloudVibrateSetting:(nullable FitCloudVibrateSetting *)vibrateSetting;

/**
 * @brief Get FitCloud vibration value for level
 * @chinese 获取指定档位对应的 FitCloud 震动值
 *
 * @param level
 * EN: Vibration intensity level index, starting from 0.
 * CN: 震动强度档位索引，从 0 开始。
 *
 * @param vibrateSetting
 * EN: FitCloudVibrateSetting object.
 * CN: FitCloudVibrateSetting 对象。
 *
 * @return
 * EN: FitCloud vibration value for the level.
 * CN: 档位对应的 FitCloud 震动值。
 */
+ (NSInteger)vibrationValueForLevel:(NSInteger)level
             fitCloudVibrateSetting:(FitCloudVibrateSetting *)vibrateSetting;

/**
 * @brief Check whether vibration intensity level is valid
 * @chinese 检查震动强度档位是否有效
 *
 * @param level
 * EN: Vibration intensity level index, starting from 0.
 * CN: 震动强度档位索引，从 0 开始。
 *
 * @param vibrateSetting
 * EN: FitCloudVibrateSetting object.
 * CN: FitCloudVibrateSetting 对象。
 *
 * @return
 * EN: YES if level is valid.
 * CN: 档位有效返回 YES。
 */
+ (BOOL)isValidVibrationLevel:(NSInteger)level
       fitCloudVibrateSetting:(nullable FitCloudVibrateSetting *)vibrateSetting;

/**
 * @brief Apply vibration intensity level to FitCloudVibrateSetting
 * @chinese 将震动强度档位应用到 FitCloudVibrateSetting
 *
 * @param level
 * EN: Vibration intensity level index, starting from 0.
 * CN: 震动强度档位索引，从 0 开始。
 *
 * @param vibrateSetting
 * EN: FitCloudVibrateSetting object to update.
 * CN: 需要更新的 FitCloudVibrateSetting 对象。
 *
 * @return
 * EN: YES if level is applied successfully.
 * CN: 档位应用成功返回 YES。
 */
+ (BOOL)applyVibrationLevel:(NSInteger)level
 toFitCloudVibrateSetting:(FitCloudVibrateSetting *)vibrateSetting;

@end

NS_ASSUME_NONNULL_END
