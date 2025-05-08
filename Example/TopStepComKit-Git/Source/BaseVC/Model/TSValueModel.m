//
//  TSValueModel.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/1/3.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSValueModel.h"

@implementation TSValueModel

+ (instancetype)valueWithName:(NSString *)valueName {
    return [[TSValueModel alloc]initWithName:valueName kitType:eTSKitDefault];
}

+ (instancetype)valueWithName:(NSString *)valueName kitType:(TSKitType)kitType{
    return [[TSValueModel alloc]initWithName:valueName kitType:kitType];
}

- (instancetype)initWithName:(NSString *)valueName kitType:(TSKitType)kitType{
    self = [super init];
    if (self) {
        _valueName = valueName;
        _kitType = kitType;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)valueName kitType:(TSKitType)kitType vcName:(nonnull NSString *)vcName{
    self = [super init];
    if (self) {
        _valueName = valueName;
        _kitType = kitType;
        _vcName = vcName;
    }
    return self;
}

+ (nonnull instancetype)valueWithName:(nonnull NSString *)valueName kitType:(TSKitType)kitType vcName:(nonnull NSString *)vcName {
    
    return [[TSValueModel alloc]initWithName:valueName kitType:kitType vcName:vcName];
}

@end
