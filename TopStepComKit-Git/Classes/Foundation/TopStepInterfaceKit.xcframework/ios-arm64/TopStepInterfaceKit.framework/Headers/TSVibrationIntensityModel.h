//
//  TSVibrationIntensityModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/21.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Vibration intensity model
 * @chinese 震动强度模型
 */
@interface TSVibrationIntensityModel : TSKitBaseModel

/**
 * @brief Current vibration intensity level
 * @chinese 当前震动强度档位
 */
@property (nonatomic, assign) NSInteger currentLevel;

/**
 * @brief Supported vibration intensity level count
 * @chinese 支持的震动强度档位数量
 */
@property (nonatomic, assign) NSInteger levelCount;

@end

NS_ASSUME_NONNULL_END
