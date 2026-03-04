//
//  TSStressMonitorConfigVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSStressMonitorConfigVC.h"

// ─── 压力预警 section 行定义 ──────────────────────────────────────────────
//   Row 0 → 启用预警 (switch)
//   Row 1 → 压力过高 (upperLimit，压力值通常 0-100)
//
// 注：压力只关心上限（过高预警）。

typedef NS_ENUM(NSInteger, TSStressAlertRow) {
    TSStressAlertRowEnable = 0,
    TSStressAlertRowUpper  = 1,
    TSStressAlertRowCount
};

@interface TSStressMonitorConfigVC ()
@property (nonatomic, strong) TSAutoMonitorConfigs *stressConfig;
@end

@implementation TSStressMonitorConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"压力检测配置";
}

#pragma mark - Fetch / Push

- (void)ts_fetchConfig {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] stress]
        fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs *config, NSError *error) {
        if (error || !config) {
            TSLog(@"获取压力配置失败: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf ts_stopLoading];
                [weakSelf ts_showAlertMsg:error.localizedDescription ?: @"获取压力配置失败"];
            });
            return;
        }
        TSLog(@"获取压力配置成功: %@", config.debugDescription);
        weakSelf.stressConfig = config;
        weakSelf.schedule     = config.schedule;
        [weakSelf ts_configDidLoad];
    }];
}

- (void)ts_pushConfig {
    if (!self.stressConfig) { self.stressConfig = [[TSAutoMonitorConfigs alloc] init]; }
    self.stressConfig.schedule = self.schedule;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] stress]
        pushAutoMonitorConfigs:self.stressConfig
                    completion:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            TSLog(@"设置压力配置成功");
            [weakSelf ts_configDidSave];
        } else {
            TSLog(@"设置压力配置失败: %@", error);
            [weakSelf ts_configSaveFailed:error];
        }
    }];
}

#pragma mark - Extra Section (压力预警)

- (NSInteger)ts_numberOfExtraSections        { return 1; }
- (NSString *)ts_titleForExtraSection:(NSInteger)s { return @"压力预警"; }
- (NSInteger)ts_numberOfRowsInExtraSection:(NSInteger)s { return TSStressAlertRowCount; }

- (UITableViewCell *)ts_cellForExtraSection:(NSInteger)s
                                        row:(NSInteger)row
                                  tableView:(UITableView *)tableView {
    TSMonitorAlert *alert = self.stressConfig.alert;

    if (row == TSStressAlertRowEnable) {
        static NSString *cellID = @"kTSStressAlertSwitchCell";
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
            sw.tag         = 4000;
            [sw addTarget:self action:@selector(ts_alertSwitchChanged:)
         forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
        }
        UISwitch *sw = (UISwitch *)[cell viewWithTag:4000];
        [sw setOn:alert.isEnabled animated:NO];
        return cell;
    }

    // Row 1: 压力过高
    static NSString *cellID = @"kTSStressDetailCell";
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
    cell.textLabel.text       = @"压力过高预警";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", alert.upperLimit];
    return cell;
}

- (void)ts_didSelectExtraSection:(NSInteger)s row:(NSInteger)row {
    if (row == TSStressAlertRowEnable) return;

    __weak typeof(self) weakSelf = self;
    [self ts_showNumberInputWithTitle:@"压力过高预警" unitLabel:@""
                         currentValue:self.stressConfig.alert.upperLimit
                                 minV:0 maxV:99
                           completion:^(NSInteger v) {
        weakSelf.stressConfig.alert.upperLimit = (UInt16)v;
        [weakSelf ts_markDirty];
        [weakSelf.tableView reloadData];
    }];
}

- (void)ts_alertSwitchChanged:(UISwitch *)sw {
    self.stressConfig.alert.enabled = sw.isOn;
    [self ts_markDirty];
}

@end
