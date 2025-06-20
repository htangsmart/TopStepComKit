//
//  WMContactModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 联系人 （Contact person）
@interface WMContactModel : NSObject
/// 联系人名称 ，长度最大32（Contact name. The value contains a maximum of 32 characters）
@property (nonatomic, copy) NSString *name;
/// 电话号码 长度最大20（The phone number contains a maximum of 20 characters）
@property (nonatomic, copy) NSString *number;

@end

/// 紧急联系人 （Emergency contact）
@interface WMEmergencyContactModel : NSObject
/// 是否启用紧急联系人 （Whether to enable emergency contacts）
@property (nonatomic, assign) BOOL isEnable;
/// 联系人 （Contact person）
@property (nonatomic, strong) WMContactModel *model;

@end

NS_ASSUME_NONNULL_END
