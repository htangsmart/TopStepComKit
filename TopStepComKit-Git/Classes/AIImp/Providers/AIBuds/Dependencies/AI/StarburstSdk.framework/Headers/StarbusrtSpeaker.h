//
//  StarbusrtSpeaker.h
//  StarburstSdk
//
//  Created by liangshi on 2025/2/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StarbusrtSpeaker : NSObject
@property (nonatomic, strong) NSString *sid;/// 音色id
@property (nonatomic, strong) NSString *name;/// 名称
@property (nonatomic, strong) NSString *type;/// 类型
@property (nonatomic, strong) NSString *role;/// 角色
@end

NS_ASSUME_NONNULL_END
