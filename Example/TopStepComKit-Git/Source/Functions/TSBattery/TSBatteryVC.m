//
//  TSBatteryVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBatteryVC.h"
#import <TopStepComKit/TopStepComKit.h>

@interface TSBatteryVC ()

/** 电池信息显示标签 */
@property (nonatomic, strong) UILabel *batteryInfoLabel;

@end

@implementation TSBatteryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"电池管理";
    
    // 初始化UI
    [self setupUI];
    // 注册电池状态变化监听
    [self registerCallBack];
}


/**
 * 初始化UI
 */
- (void)setupUI {
    // 创建电池信息显示标签
    self.batteryInfoLabel = [[UILabel alloc] init];
    self.batteryInfoLabel.numberOfLines = 0;
    self.batteryInfoLabel.textAlignment = NSTextAlignmentCenter;
    self.batteryInfoLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.batteryInfoLabel];
    
    // 设置标签位置（使用Frame布局）
    CGFloat labelWidth = 300;
    CGFloat labelHeight = 100;
    CGFloat labelX = (CGRectGetWidth(self.view.frame) - labelWidth) / 2;
    CGFloat labelY = CGRectGetMaxY(self.navigationController.navigationBar.frame) + 200;
    self.batteryInfoLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
}

/**
 * 注册电池状态变化监听
 */
- (void)registerCallBack {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] battery] registerBatteryDidChanged:^(TSBatteryModel * _Nullable batteryModel, NSError * _Nullable error) {
        if (error) {
            [TSToast showText:@"获取电池信息失败" onView:weakSelf.view dismissAfterDelay:1.0f];
            return;
        }
        // 更新电池信息显示
        [weakSelf updateBatteryInfo:batteryModel];
    }];
}

/**
 * 获取当前电池信息
 */
- (void)getBattery {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] battery] requestBatteryInformationCompletion:^(TSBatteryModel * _Nullable batteryModel, NSError * _Nullable error) {
        if (error) {
            [TSToast showText:@"获取电池信息失败" onView:weakSelf.view dismissAfterDelay:1.0f];
            return;
        }
        // 更新电池信息显示
        [weakSelf updateBatteryInfo:batteryModel];
    }];
}

/**
 * 更新电池信息显示
 */
- (void)updateBatteryInfo:(TSBatteryModel *)batteryModel {
    if (!batteryModel) {
        self.batteryInfoLabel.text = @"暂无电池信息";
        return;
    }
    
    // 格式化电池信息显示
    NSMutableString *info = [NSMutableString string];
    [info appendString:@"设备电池信息\n\n"];
    [info appendFormat:@"电量：%ld%%\n", (long)batteryModel.batteryPercentage];
    [info appendFormat:@"充电状态：%@", batteryModel.chargeState==TSBatteryStateCharging ? @"正在充电" : @"未充电"];
    
    self.batteryInfoLabel.text = info;
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"获取电量"],
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self getBattery];
    }
}

@end
