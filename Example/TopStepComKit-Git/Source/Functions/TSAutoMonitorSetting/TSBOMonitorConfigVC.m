//
//  TSBOMonitorConfigVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBOMonitorConfigVC.h"

// ─── 血氧预警 section 行定义 ──────────────────────────────────────────────
//   Row 0 → 启用预警 (switch)
//   Row 1 → 血氧过低 (lowerLimit, %)
//
// 注：血氧只关心下限（过低预警），不设上限预警。

typedef NS_ENUM(NSInteger, TSBOAlertRow) {
    TSBOAlertRowEnable = 0,
    TSBOAlertRowLower  = 1,
    TSBOAlertRowCount
};

@interface TSBOMonitorConfigVC ()
@property (nonatomic, strong) TSAutoMonitorConfigs *boConfig;
@end

@implementation TSBOMonitorConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"血氧检测配置";
}

#pragma mark - Fetch / Push

- (void)ts_fetchConfig {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] bloodOxygen]
        fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs *config, NSError *error) {
        if (error || !config) {
            TSLog(@"获取血氧配置失败: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf ts_stopLoading];
                [weakSelf ts_showAlertMsg:error.localizedDescription ?: @"获取血氧配置失败"];
            });
            return;
        }
        TSLog(@"获取血氧配置成功: %@", config.debugDescription);
        weakSelf.boConfig = config;
        weakSelf.schedule = config.schedule;
        [weakSelf ts_configDidLoad];
    }];
}

- (void)ts_pushConfig {
    if (!self.boConfig) { self.boConfig = [[TSAutoMonitorConfigs alloc] init]; }
    self.boConfig.schedule = self.schedule;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] bloodOxygen]
        pushAutoMonitorConfigs:self.boConfig
                    completion:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            TSLog(@"设置血氧配置成功");
            [weakSelf ts_configDidSave];
        } else {
            TSLog(@"设置血氧配置失败: %@", error);
            [weakSelf ts_configSaveFailed:error];
        }
    }];
}

#pragma mark - Extra Section (血氧预警)

- (NSInteger)ts_numberOfExtraSections        { return 1; }
- (NSString *)ts_titleForExtraSection:(NSInteger)s { return @"血氧预警"; }
- (NSInteger)ts_numberOfRowsInExtraSection:(NSInteger)s { return TSBOAlertRowCount; }

- (UITableViewCell *)ts_cellForExtraSection:(NSInteger)s
                                        row:(NSInteger)row
                                  tableView:(UITableView *)tableView {
    TSMonitorAlert *alert = self.boConfig.alert;

    if (row == TSBOAlertRowEnable) {
        static NSString *cellID = @"kTSBOAlertSwitchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:cellID];
            cell.backgroundColor = TSColor_Card;
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;
            cell.textLabel.text  = @"启用预警";
            cell.textLabel.font  = [UIFont systemFontOfSize:16.f];
            cell.textLabel.textColor = TSColor_TextPrimary;

            UISwitch *sw = [[UISwitch alloc] init];
            sw.onTintColor = TSColor_Primary;
            sw.tag         = 3000;
            [sw addTarget:self action:@selector(ts_alertSwitchChanged:)
         forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
        }
        UISwitch *sw = (UISwitch *)[cell viewWithTag:3000];
        [sw setOn:alert.isEnabled animated:NO];
        return cell;
    }

    // Row 1: 血氧过低
    static NSString *cellID = @"kTSBODetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellID];
        cell.backgroundColor      = TSColor_Card;
        cell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font       = [UIFont systemFontOfSize:16.f];
        cell.textLabel.textColor  = TSColor_TextPrimary;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.f];
        cell.detailTextLabel.textColor = TSColor_TextSecondary;
    }
    cell.textLabel.text       = @"血氧过低预警";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %%", alert.lowerLimit];
    return cell;
}

- (void)ts_didSelectExtraSection:(NSInteger)s row:(NSInteger)row {
    if (row == TSBOAlertRowEnable) return;

    __weak typeof(self) weakSelf = self;
    [self ts_showNumberInputWithTitle:@"血氧过低预警" unitLabel:@"%"
                         currentValue:self.boConfig.alert.lowerLimit
                                 minV:50 maxV:99
                           completion:^(NSInteger v) {
        weakSelf.boConfig.alert.lowerLimit = (UInt16)v;
        [weakSelf ts_markDirty];
        [weakSelf.tableView reloadData];
    }];
}

- (void)ts_alertSwitchChanged:(UISwitch *)sw {
    self.boConfig.alert.enabled = sw.isOn;
    [self ts_markDirty];
}

@end
