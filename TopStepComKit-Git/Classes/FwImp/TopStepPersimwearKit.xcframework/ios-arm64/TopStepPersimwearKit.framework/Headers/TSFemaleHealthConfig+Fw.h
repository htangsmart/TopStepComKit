//
//  TSFemaleHealthConfig+Fw.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/12/29.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSFemaleHealthConfig (Fw)

/**
 * @brief Convert TSFemaleHealthConfig to dictionary
 * @chinese 将TSFemaleHealthConfig转换为字典
 * 
 * @return 
 * EN: Dictionary containing female health configuration, nil if conversion fails
 * CN: 包含女性健康配置的字典，转换失败时返回nil
 */
- (NSDictionary *)toFemaleHealthDict;

/**
 * @brief Create TSFemaleHealthConfig from dictionary
 * @chinese 从字典创建TSFemaleHealthConfig
 * 
 * @param fwDict 
 * EN: Dictionary containing female health configuration data
 * CN: 包含女性健康配置数据的字典
 * 
 * @return 
 * EN: TSFemaleHealthConfig object, nil if conversion fails
 * CN: TSFemaleHealthConfig对象，转换失败时返回nil
 */
+ (nullable TSFemaleHealthConfig *)femaleHealthConfigWithFwDict:(nullable NSDictionary *)fwDict;

@end

NS_ASSUME_NONNULL_END
