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
 * @brief Convert user information to a FitCloud profile
 * @chinese 将用户信息转换为 FitCloud 资料
 *
 * @param model
 * EN: User information model to convert
 * CN: 待转换的用户信息模型
 *
 * @return
 * EN: Converted profile, or nil if the model is nil or gender is unsupported
 * CN: 转换后的资料；模型为空或性别不受支持时返回 nil
 *
 * @discussion
 * [EN]: Only Female and Male are supported. Age, height and weight are passed
 *       through after the provider validates their ranges.
 * [CN]: 仅支持女性和男性；年龄、身高、体重由 Provider 校验范围后透传。
 */
+ (nullable FitCloudUserProfileObject *)fitCloudUserInfoWithModel:(nullable TSUserInfoModel *)model;

@end

NS_ASSUME_NONNULL_END
