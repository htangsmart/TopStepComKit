//
//  JLUser.m
//  JieliJianKang
//
//  Created by Topstep on 2021/4/14.
//

#import "JLUser.h"
//#import "JL_RunSDK.h"

@implementation JLUser

- (id)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        _nickname           = [dic objectForKey:@"nickname"] ? dic[@"nickname"] : @"";
        _gender             = [dic objectForKey:@"gender"] ? [dic[@"gender"] intValue] : 2;
        _birthYear          = [dic objectForKey:@"birthYear"] ? [dic[@"birthYear"] intValue]: 0;
        _birthMonth         = [dic objectForKey:@"birthMonth"] ? [dic[@"birthMonth"] intValue]: 0;
        _birthDay           = [dic objectForKey:@"birthDay"] ? [dic[@"birthDay"] intValue]: 0;
        _height             = [dic objectForKey:@"height"] ? [dic[@"height"] intValue]: 0;
        _weight             = [dic objectForKey:@"weight"] ? [dic[@"weight"] floatValue] : 0;
        _step               = [dic objectForKey:@"step"] ? [dic[@"step"] intValue]: 0;
        _avatarUrl          = [dic objectForKey:@"avatarUrl"] ? dic[@"avatarUrl"] : @"";
        _weightStart        = [dic objectForKey:@"weightStart"] ? [dic[@"weightStart"] floatValue]: 0;
        _weightTarget       = [dic objectForKey:@"weightTarget"] ? [dic[@"weightTarget"] floatValue]: 0;
    }
    return self;
}

- (id)initWithWeightStartDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _weightStart = [dic objectForKey:@"weightStart"] ? [dic[@"weightStart"] floatValue]: 0;
    }
    return self;
}

- (NSString *)genderText {
    NSString *genderText = @"";
    if (_gender == 0) {
        genderText = kJL_TXT("男");
    } else if (_gender == 1) {
        genderText = kJL_TXT("女");
    }
    return genderText;
}

@end


@implementation UserProfile

NSString *const userProfile = @"userprofileDefault";
- (id)initWithDic:(NSDictionary *)dic{

    NSDictionary *dict = dic[@"data"];
    UserProfile *up =   [[UserProfile alloc] init];
    up.identify     =   [dict objectForKey:@"id"] ? dict[@"id"]:@"";
    up.uuid         =   [dict objectForKey:@"uuid"] ? dict[@"uuid"]:@"";
    up.mobile       =   [dict objectForKey:@"mobile"] ? dict[@"mobile"]:@"";
    up.password     =   [dict objectForKey:@"password"] ? dict[@"password"]:@"";
    up.configData   =   [dict objectForKey:@"configData"] ? dict[@"configData"]:@"";
    up.explain      =   [dict objectForKey:@"explain"] ? dict[@"explain"]:@"";
    up.status       =   [dict[@"status"] intValue];
    
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    fm.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *registerD = [dict objectForKey:@"registerTime"] ? dict[@"registerTime"]:@"";
    if (![registerD isEqualToString:@""]) {
        up.registerTime = [fm dateFromString:registerD];
    }
    NSString *loginD = [dict objectForKey:@"registerTime"] ? dict[@"registerTime"]:@"";
    if (![loginD isEqualToString:@""]) {
        up.lastLoginTime = [fm dateFromString:loginD];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    [[NSUserDefaults standardUserDefaults] setValue:jsonData forKey:userProfile];
    return up;
}

-(NSDictionary *)beDict{
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    fm.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDictionary *dict = @{@"id":self.identify,@"uuid":self.uuid,@"mobile":self.mobile,@"password":self.password,@"configData":self.configData,@"explain":self.explain,@"status":@(self.status),@"registerTime":[fm stringFromDate:self.registerTime],@"lastLoginTime":[fm stringFromDate:self.lastLoginTime]};
    return dict;
}

+(UserProfile * _Nullable )locateProfile{
   NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:userProfile];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (dict) {
            return [[UserProfile alloc] initWithDic:dict];
        }
    }
    return nil;
}



@end
