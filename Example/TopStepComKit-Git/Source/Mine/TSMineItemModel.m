//
//  TSMineItemModel.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/17.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSMineItemModel.h"

@implementation TSMineItemModel

/**
 * 创建项目模型
 */
+ (instancetype)itemWithIcon:(NSString *)iconName
                       title:(NSString *)title
                      detail:(nullable NSString *)detail
                      action:(NSString *)action {
    TSMineItemModel *model = [[TSMineItemModel alloc] init];
    model.iconName = iconName;
    model.title = title;
    model.detail = detail;
    model.action = action;
    return model;
}

@end
