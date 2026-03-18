//
//  TSAlarmRepeatVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRootVC.h"
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSAlarmRepeatVC : TSRootVC

@property (nonatomic, assign) TSAlarmRepeat selectedRepeat;
@property (nonatomic, copy) void(^onRepeatChanged)(TSAlarmRepeat repeat);

@end

NS_ASSUME_NONNULL_END
