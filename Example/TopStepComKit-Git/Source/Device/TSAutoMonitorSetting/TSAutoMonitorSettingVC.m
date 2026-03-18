//
//  TSAutoMonitorSettingVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSAutoMonitorSettingVC.h"
#import "TSHRMonitorConfigVC.h"
#import "TSBOMonitorConfigVC.h"
#import "TSStressMonitorConfigVC.h"

// ─── 工具函数：把分钟数转 "HH:mm" ──────────────────────────────────────────

static NSString *TSFmtMinutes(NSInteger m) {
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(m / 60), (long)(m % 60)];
}

// ─── schedule → 副标题摘要 ─────────────────────────────────────────────────

static NSString *TSScheduleSummary(TSMonitorSchedule *schedule) {
    if (!schedule || !schedule.isEnabled) return TSLocalizedString(@"monitor.not_enabled");
    return [NSString stringWithFormat:TSLocalizedString(@"monitor.schedule_format"),
            TSFmtMinutes(schedule.startTime),
            TSFmtMinutes(schedule.endTime),
            schedule.interval];
}

// ─── TSAutoMonitorSettingVC ────────────────────────────────────────────────

@interface TSAutoMonitorSettingVC ()
@property (nonatomic, strong) NSMutableArray<TSValueModel *> *items;
@end

@implementation TSAutoMonitorSettingVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"monitor.title");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 每次页面出现（包括从配置页返回后）都重新拉取，保证数据最新
    [self ts_fetchAllConfigs];
}

#pragma mark - Data Source Override

- (NSArray *)sourceArray {
    return self.items;
}

- (NSMutableArray<TSValueModel *> *)items {
    if (!_items) {
        _items = [@[
            [TSValueModel valueWithName:TSLocalizedString(@"monitor.hr_config")
                                kitType:eTSKitHR
                                 vcName:nil
                               iconName:@"heart.fill"
                              iconColor:TSColor_Danger
                               subtitle:TSLocalizedString(@"general.loading")],

            [TSValueModel valueWithName:TSLocalizedString(@"monitor.bo_config")
                                kitType:eTSKitBO
                                 vcName:nil
                               iconName:@"drop.fill"
                              iconColor:TSColor_Primary
                               subtitle:TSLocalizedString(@"general.loading")],

            [TSValueModel valueWithName:TSLocalizedString(@"monitor.stress_config")
                                kitType:eTSKitStress
                                 vcName:nil
                               iconName:@"brain.head.profile"
                              iconColor:TSColor_Purple
                               subtitle:TSLocalizedString(@"general.loading")],
        ] mutableCopy];
    }
    return _items;
}

#pragma mark - Fetch

- (void)ts_fetchAllConfigs {
    // 先把 3 行都重置为"获取中…"
    for (TSValueModel *item in self.items) {
        item.subtitle = TSLocalizedString(@"general.loading");
    }
    [self.sourceTableview reloadData];

    [self ts_fetchHR];
    [self ts_fetchBO];
    [self ts_fetchStress];
}

- (void)ts_fetchHR {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] heartRate]
        fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorHRConfigs *config, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.items[0].subtitle = error
                ? TSLocalizedString(@"general.load_failed")
                : TSScheduleSummary(config.schedule);
            [weakSelf ts_reloadRow:0];
        });
    }];
}

- (void)ts_fetchBO {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] bloodOxygen]
        fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs *config, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.items[1].subtitle = error
                ? TSLocalizedString(@"general.load_failed")
                : TSScheduleSummary(config.schedule);
            [weakSelf ts_reloadRow:1];
        });
    }];
}

- (void)ts_fetchStress {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] stress]
        fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs *config, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.items[2].subtitle = error
                ? TSLocalizedString(@"general.load_failed")
                : TSScheduleSummary(config.schedule);
            [weakSelf ts_reloadRow:2];
        });
    }];
}

- (void)ts_reloadRow:(NSInteger)row {
    NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];
    if (row < (NSInteger)self.items.count) {
        [self.sourceTableview reloadRowsAtIndexPaths:@[ip]
                                    withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIViewController *configVC = nil;
    if (indexPath.row == 0) {
        configVC = [[TSHRMonitorConfigVC alloc] init];
    } else if (indexPath.row == 1) {
        configVC = [[TSBOMonitorConfigVC alloc] init];
    } else if (indexPath.row == 2) {
        configVC = [[TSStressMonitorConfigVC alloc] init];
    }
    if (!configVC) return;

    UINavigationController *nav = [[UINavigationController alloc]
        initWithRootViewController:configVC];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
