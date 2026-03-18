//
//  TSRootVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSRootVC.h"

@implementation TSRootVC

- (instancetype)init {
    self = [super init];
    if (self) {
        // 默认所有页面 push 时隐藏 TabBar
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

@end
