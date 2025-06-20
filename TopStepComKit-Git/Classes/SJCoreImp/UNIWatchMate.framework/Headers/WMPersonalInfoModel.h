//
//  WMPersonalInfoModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 性别 （sex）
typedef NS_ENUM(NSInteger, Gender) {
    /// 男性 （male）
    GenderMale,
    /// 女性 （The female sex）
    GenderFemale,
    /// 其他 （other）
    GenderOther
};

@interface WMPersonalInfoModel : NSObject

/// 身高（0，表示不设置） （Height (0, indicates no setting)）
@property (nonatomic, assign) NSInteger height;
/// 体重（0，表示不设置） （Weight (0, indicates no setting)）
@property (nonatomic, assign) NSInteger weight;
/// 性别（none，表示不设置） （Gender (none: not set)）
@property (nonatomic, assign) Gender gender;
/// 生日（nil，表示不设置）（Birthday (nil, meaning not set)）
@property (nonatomic, strong) NSDate * birthDate;

@end

NS_ASSUME_NONNULL_END
