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
    return [[TSValueModel alloc] initWithName:valueName kitType:eTSKitDefault vcName:nil iconName:nil iconColor:nil subtitle:nil];
}

+ (instancetype)valueWithName:(NSString *)valueName kitType:(TSKitType)kitType {
    return [[TSValueModel alloc] initWithName:valueName kitType:kitType vcName:nil iconName:nil iconColor:nil subtitle:nil];
}

+ (instancetype)valueWithName:(NSString *)valueName kitType:(TSKitType)kitType vcName:(NSString *)vcName {
    return [[TSValueModel alloc] initWithName:valueName kitType:kitType vcName:vcName iconName:nil iconColor:nil subtitle:nil];
}

+ (instancetype)valueWithName:(NSString *)valueName
                      kitType:(TSKitType)kitType
                       vcName:(NSString *)vcName
                     iconName:(nullable NSString *)iconName
                    iconColor:(nullable UIColor *)iconColor
                     subtitle:(nullable NSString *)subtitle {
    return [[TSValueModel alloc] initWithName:valueName kitType:kitType vcName:vcName iconName:iconName iconColor:iconColor subtitle:subtitle];
}

- (instancetype)initWithName:(NSString *)valueName
                     kitType:(TSKitType)kitType
                      vcName:(nullable NSString *)vcName
                    iconName:(nullable NSString *)iconName
                   iconColor:(nullable UIColor *)iconColor
                    subtitle:(nullable NSString *)subtitle {
    self = [super init];
    if (self) {
        _valueName = valueName;
        _kitType   = kitType;
        _vcName    = vcName;
        _iconName  = iconName;
        _iconColor = iconColor;
        _subtitle  = subtitle;
    }
    return self;
}

@end
