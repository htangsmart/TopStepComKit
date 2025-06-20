//
//  TSTimeVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSTimeVC.h"
#import <TopStepComKit/TopStepComKit.h>
#import <TopStepToolKit/TopStepToolKit.h>

@interface TSTimeVC ()

@end

@implementation TSTimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"时间设置";
}

/**
 * 返回功能列表数组
 */
- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"设置当前时间"],
        [TSValueModel valueWithName:@"设置指定时间"],
        [TSValueModel valueWithName:@"设置世界时间"],
    ];
}

/**
 * 表格点击事件处理
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self setCurrentTime];
    }else if(indexPath.row == 1){
        [self setSpeficTime];
    }else{
        [self setWorldClocks];
    }
}

/**
 * 设置当前系统时间到设备
 */
- (void)setCurrentTime {
    [TSToast showText:@"正在同步系统时间..." onView:self.view dismissAfterDelay:1.0f];
    
    [[[TopStepComKit sharedInstance] time] setSystemTimeWithCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [TSToast showText:@"系统时间同步成功" onView:self.view dismissAfterDelay:1.0f];
        } else {
            [TSToast showText:@"系统时间同步失败" onView:self.view dismissAfterDelay:1.0f];
        }
    }];
}

/**
 * 生成随机时间
 * @return 随机生成的时间，在当前时间前后24小时范围内
 */
- (NSDate *)randomTime {
    // 获取当前时间
    NSDate *now = [NSDate date];
    
    // 生成-24到+24小时的随机偏移量（以秒为单位）
    NSInteger randomOffset = arc4random_uniform(24 * 60 * 60 * 2) - (24 * 60 * 60);
    
    // 返回偏移后的时间
    return [now dateByAddingTimeInterval:randomOffset];
}

/**
 * 设置指定时间到设备
 */
- (void)setSpeficTime {
    NSDate *randomTime = [self randomTime];
    
    // 创建日期格式化器
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *timeString = [formatter stringFromDate:randomTime];
    
    TSLog(@"time is %@",timeString);
    [TSToast showText:[NSString stringWithFormat:@"正在设置时间: %@", timeString]
              onView:self.view 
    dismissAfterDelay:1.0f complete:^{
        [[[TopStepComKit sharedInstance] time] setSpecificTime:randomTime completion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [TSToast showText:@"时间设置成功" onView:self.view dismissAfterDelay:1.0f];
            } else {
                [TSToast showText:@"时间设置失败" onView:self.view dismissAfterDelay:1.0f];
            }
        }];
    }];
    
}

/**
 * 生成随机世界时间数组
 * @return 包含3个世界时间的数组
 */
- (NSArray *)randomWorldTime {
    // 预定义一些常用城市的时区信息
    NSArray *cities = @[
        @{@"id":@(1), @"name": @"北京", @"zone": @"Asia/Shanghai", @"utc": @8.0},
        @{@"id":@(2),@"name": @"东京", @"zone": @"Asia/Tokyo", @"utc": @9.0},
        @{@"id":@(3),@"name": @"伦敦", @"zone": @"Europe/London", @"utc": @0.0},
        @{@"id":@(4),@"name": @"纽约", @"zone": @"America/New_York", @"utc": @-5.0},
        @{@"id":@(5),@"name": @"巴黎", @"zone": @"Europe/Paris", @"utc": @1.0}
    ];
    
    // 随机选择3个不重复的城市
    NSMutableArray *selectedCities = [NSMutableArray array];
    NSMutableArray *tempCities = [cities mutableCopy];
    
    for (int i = 0; i < 3 && tempCities.count > 0; i++) {
        NSInteger randomIndex = arc4random_uniform((uint32_t)tempCities.count);
        NSDictionary *cityInfo = tempCities[randomIndex];
        
        NSInteger cityId = [cityInfo[@"id"] integerValue];
        NSString *cityName = cityInfo[@"name"];
        NSString *cityZone = cityInfo[@"zone"];
        NSInteger utOffset = [cityInfo[@"utc"] integerValue]*3600;

        TSWorldClockModel *worldTime = [TSWorldClockModel modelWithClockId:cityId cityName:cityName timeZoneIdentifier:cityZone utcOffsetInSeconds:utOffset];
        [selectedCities addObject:worldTime];
        [tempCities removeObjectAtIndex:randomIndex];
    }
    
    return selectedCities;
}

/**
 * 设置世界时间到设备
 */
- (void)setWorldClocks {
    NSArray *worldTimes = [self randomWorldTime];
    
    [TSToast showLoadingOnView:self.view];
    [[[TopStepComKit sharedInstance] worldClock] setWorldClocks:worldTimes completion:^(BOOL isSuccess, NSError * _Nullable error) {
        [TSToast dismissLoadingOnView:self.view];
        [TSToast showText:(isSuccess?@"世界时间设置成功":(error.localizedDescription ?: @"世界时间设置失败")) onView:self.view dismissAfterDelay:1.0f];
    }];
}

@end
