//
//  TSAIKitRootCapability.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/20.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIKitRootCapability.h"

@implementation TSAIKitRootCapability

+ (instancetype)capabilityWithTitle:(NSString *)title
                           subtitle:(NSString *)subtitle
                          tintColor:(UIColor *)tintColor
                           iconType:(TSAIKitRootCapabilityIcon)iconType
                         widthStyle:(TSAIKitRootCapabilityWidth)widthStyle
                            vcClass:(Class)vcClass {
    TSAIKitRootCapability *item = [[self alloc] init];
    item.title = title;
    item.subtitle = subtitle;
    item.tintColor = tintColor;
    item.iconType = iconType;
    item.widthStyle = widthStyle;
    item.vcClass = vcClass;
    return item;
}

@end
