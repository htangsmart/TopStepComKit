//
//  TSUserInfoModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSUserInfoModel (Fw)

+ (nullable NSDictionary *)fwUserInfoWithModel:(nullable TSUserInfoModel *)userInfoModel;

+ (nullable TSUserInfoModel *)userInfoModelWithFwDict:(nullable NSDictionary *)fwDict;

+ (NSArray *)userInfoKeys;


@end

NS_ASSUME_NONNULL_END
