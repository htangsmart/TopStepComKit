//
//  TSUserInfoModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSUserInfoModel (Fw)

/**
 * @brief Convert user information to a device storage dictionary
 * @chinese 将用户信息转换为设备存储字典
 *
 * @param userInfoModel
 * EN: User information model to convert
 * CN: 待转换的用户信息模型
 *
 * @return
 * EN: Storage dictionary, or nil for a nil model or unsupported gender
 * CN: 设备存储字典；模型为空或性别不受支持时返回 nil
 *
 * @discussion
 * [EN]: Only Female and Male are supported; Unknown is never sent to the device.
 * [CN]: 仅支持女性和男性，不向设备发送未知性别值。
 */
+ (nullable NSDictionary *)fwUserInfoWithModel:(nullable TSUserInfoModel *)userInfoModel;

+ (nullable TSUserInfoModel *)userInfoModelWithFwDict:(nullable NSDictionary *)fwDict;

+ (NSArray *)userInfoKeys;


@end

NS_ASSUME_NONNULL_END
