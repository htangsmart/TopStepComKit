//
//  TSUnitVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSUnitVC.h"

@interface TSUnitVC ()

@end

@implementation TSUnitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"单位设置";
    [self registerCallBack];
}

- (void)registerCallBack {
    // 可以在这里添加其他回调注册
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"设置长度单位-公里"],
        [TSValueModel valueWithName:@"设置长度单位-英里"],
        [TSValueModel valueWithName:@"获取长度单位"],
        
        [TSValueModel valueWithName:@"设置温度单位-摄氏度"],
        [TSValueModel valueWithName:@"设置温度单位-华氏度"],
        [TSValueModel valueWithName:@"获取温度单位"],
        
        [TSValueModel valueWithName:@"设置重量单位-KG"],
        [TSValueModel valueWithName:@"设置重量单位-LB"],
        [TSValueModel valueWithName:@"获取重量单位"],
        
        [TSValueModel valueWithName:@"设置时间制度-12小时"],
        [TSValueModel valueWithName:@"设置时间制度-24小时"],
        [TSValueModel valueWithName:@"获取时间单位"],
        
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self setLenthKM];
    } else if (indexPath.row == 1) {
        [self setLenthMile];
    } else if (indexPath.row == 2) {
        [self getLenth];
    } else if (indexPath.row == 3) {
        [self setTempC];
    } else if (indexPath.row == 4) {
        [self setTempH];
    } else if (indexPath.row == 5) {
        [self getTemp];
    } else if (indexPath.row == 6) {
        [self setWeithKG];
    } else if (indexPath.row == 7) {
        [self setWeightLB];
    } else if (indexPath.row == 8) {
        [self getWeight];
    } else if (indexPath.row == 9) {
        [self setTime12];
    } else if (indexPath.row == 10) {
        [self setTime24];
    } else if (indexPath.row == 11) {
        [self getTime];
    }
}

- (void)setLenthKM {
    [TSToast showLoadingOnView:self.view];
    [[[TopStepComKit sharedInstance] unit] setLengthUnit:TSLengthUnitMetric
                                              completion:^(BOOL success, NSError *_Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        [TSToast     showText:success ? @"设置成功" : @"设置失败"
                       onView:self.view
            dismissAfterDelay:1.0f];
    }];
}

- (void)setLenthMile {
    [TSToast showLoadingOnView:self.view];
    
    [[[TopStepComKit sharedInstance] unit] setLengthUnit:TSLengthUnitImperial
                                              completion:^(BOOL success, NSError *_Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        
        [TSToast     showText:success ? @"设置成功" : @"设置失败"
                       onView:self.view
            dismissAfterDelay:1.0f];
    }];
}

- (void)getLenth {
    [TSToast showLoadingOnView:self.view];
    
    [[[TopStepComKit sharedInstance] unit] getCurrentLengthUnit:^(TSLengthUnit unit, NSError *_Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        
        if (error) {
            [TSToast     showText:[NSString stringWithFormat:@"获取长度失败: %@", error.localizedDescription]
                           onView:self.view
                dismissAfterDelay:1.0f];
        } else {
            [TSToast     showText:[NSString stringWithFormat:@"获取长度成功: %ld", (long)unit]
                           onView:self.view
                dismissAfterDelay:1.0f];
        }
    }];
}

- (void)setTempC {
    [TSToast showLoadingOnView:self.view];
    
    [[[TopStepComKit sharedInstance] unit] setTemperatureUnit:TSTemperatureUnitCelsius
                                                   completion:^(BOOL success, NSError *_Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        
        [TSToast     showText:success ? @"设置成功" : @"设置失败"
                       onView:self.view
            dismissAfterDelay:1.0f];
    }];
}

- (void)setTempH {
    [TSToast showLoadingOnView:self.view];
    
    [[[TopStepComKit sharedInstance] unit] setTemperatureUnit:TSTemperatureUnitFahrenheit
                                                   completion:^(BOOL success, NSError *_Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        
        [TSToast     showText:success ? @"设置成功" : @"设置失败"
                       onView:self.view
            dismissAfterDelay:1.0f];
    }];
}

- (void)getTemp {
    [TSToast showLoadingOnView:self.view];
    
    [[[TopStepComKit sharedInstance] unit] getCurrentTemperatureUnit:^(TSTemperatureUnit unit, NSError *_Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        
        if (error) {
            [TSToast     showText:[NSString stringWithFormat:@"获取温度失败: %@", error.localizedDescription]
                           onView:self.view
                dismissAfterDelay:1.0f];
        } else {
            [TSToast     showText:[NSString stringWithFormat:@"获取温度成功: %ld", (long)unit]
                           onView:self.view
                dismissAfterDelay:1.0f];
        }
    }];
}

- (void)setWeithKG {
    [TSToast showLoadingOnView:self.view];
    
    [[[TopStepComKit sharedInstance] unit] setWeightUnit:TSWeightUnitKG
                                              completion:^(BOOL success, NSError *_Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        
        [TSToast     showText:success ? @"设置成功" : @"设置失败"
                       onView:self.view
            dismissAfterDelay:1.0f];
    }];
}

- (void)setWeightLB {
    [TSToast showLoadingOnView:self.view];
    
    [[[TopStepComKit sharedInstance] unit] setWeightUnit:TSWeightUnitLB
                                              completion:^(BOOL success, NSError *_Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        
        [TSToast     showText:success ? @"设置成功" : @"设置失败"
                       onView:self.view
            dismissAfterDelay:1.0f];
    }];
}

- (void)getWeight {
    [TSToast showLoadingOnView:self.view];
    
    [[[TopStepComKit sharedInstance] unit] getCurrentWeightUnit:^(TSWeightUnit unit, NSError *_Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        
        if (error) {
            [TSToast     showText:[NSString stringWithFormat:@"获取重量失败: %@", error.localizedDescription]
                           onView:self.view
                dismissAfterDelay:1.0f];
        } else {
            [TSToast     showText:[NSString stringWithFormat:@"获取重量成功: %ld", (long)unit]
                           onView:self.view
                dismissAfterDelay:1.0f];
        }
    }];
}

- (void)setTime12 {
    [TSToast showLoadingOnView:self.view];
    
    [[[TopStepComKit sharedInstance] unit] setTimeFormat:TSTimeFormat12Hour
                                              completion:^(BOOL success, NSError *_Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        
        [TSToast     showText:success ? @"设置成功" : @"设置失败"
                       onView:self.view
            dismissAfterDelay:1.0f];
    }];
}

- (void)setTime24 {
    [TSToast showLoadingOnView:self.view];
    
    [[[TopStepComKit sharedInstance] unit] setTimeFormat:TSTimeFormat24Hour
                                              completion:^(BOOL success, NSError *_Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        
        [TSToast     showText:success ? @"设置成功" : @"设置失败"
                       onView:self.view
            dismissAfterDelay:1.0f];
    }];
}

- (void)getTime {
    [TSToast showLoadingOnView:self.view];
    
    [[[TopStepComKit sharedInstance] unit] getCurrentTimeFormat:^(TSTimeFormat format, NSError *_Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        
        if (error) {
            [TSToast     showText:[NSString stringWithFormat:@"获取时间失败: %@", error.localizedDescription]
                           onView:self.view
                dismissAfterDelay:1.0f];
        } else {
            [TSToast     showText:[NSString stringWithFormat:@"获取时间成功: %ld", (long)format]
                           onView:self.view
                dismissAfterDelay:1.0f];
        }
    }];
}

@end
