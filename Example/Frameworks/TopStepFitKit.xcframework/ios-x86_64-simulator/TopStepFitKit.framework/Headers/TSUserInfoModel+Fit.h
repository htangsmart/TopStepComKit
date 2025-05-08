//
//  TSUserInfoModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/13.
//

#import <TopStepInterfaceKit/TSUserInfoModel.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSUserInfoModel (Fit)

/**
 * @brief 将TSUserInfoModel转换为FitCloudUserProfileObject
 *
 * @param model 用户信息模型
 * @return FitCloudUserProfileObject对象
 *
 * @discussion 该方法会将TSUserInfoModel的属性映射到FitCloudUserProfileObject中：
 *            - 性别：TSUserGender -> FITCLOUDGENDER
 *            - 年龄：限制在0~127范围内
 *            - 身高：单位cm，限制在0.0~256cm范围内
 *            - 体重：单位kg，限制在0.0~512kg范围内
 */
+ (nullable FitCloudUserProfileObject *)fitCloudUserInfoWithModel:(nullable TSUserInfoModel *)model;

@end

NS_ASSUME_NONNULL_END
