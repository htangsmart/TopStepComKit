//
//  TSHRMonitorConfigVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSHRMonitorConfigVC.h"

// ─── Extra section 索引（相对于基类 offset=2）─────────────────────────────

typedef NS_ENUM(NSInteger, TSHRSection) {
    TSHRSectionRestAlert     = 0,   // 静息心率预警（section 2）
    TSHRSectionExerciseAlert = 1,   // 运动心率预警（section 3）
    TSHRSectionCount
};

// ─── 各 section 行定义 ────────────────────────────────────────────────────
//
// 静息心率预警 section:
//   Row 0 → 启用预警 (switch)
//   Row 1 → 心率过高 (upperLimit)
//   Row 2 → 心率过低 (lowerLimit)
//
// 运动心率预警 section:
//   Row 0 → 启用预警 (switch)
//   Row 1 → 心率过高 (upperLimit)
//   Row 2 → 心率过低 (lowerLimit)
//   Row 3 → 运动心率上限 (exerciseHRLimitMax，永远显示)

typedef NS_ENUM(NSInteger, TSHRAlertRow) {
    TSHRAlertRowEnable  = 0,
    TSHRAlertRowUpper   = 1,
    TSHRAlertRowLower   = 2,
    TSHRAlertRowCount   = 3
};

static const NSInteger TSHRExerciseRowMaxHR = TSHRAlertRowCount; // row 3

// ─── Interface ────────────────────────────────────────────────────────────

@interface TSHRMonitorConfigVC ()
@property (nonatomic, strong) TSAutoMonitorHRConfigs *hrConfig;
@end

// ─── Implementation ───────────────────────────────────────────────────────

@implementation TSHRMonitorConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"monitor.hr_config");
}

#pragma mark - Fetch / Push

- (void)ts_fetchConfig {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] heartRate]
        fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorHRConfigs *config, NSError *error) {
        if (error || !config) {
            TSLog(@"获取心率配置失败: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf ts_stopLoading];
                [weakSelf ts_showAlertMsg:error.localizedDescription ?: TSLocalizedString(@"monitor.hr.get_failed")];
            });
            return;
        }
        TSLog(@"获取心率配置成功: %@", config.debugDescription);
        weakSelf.hrConfig = config;
        weakSelf.schedule = config.schedule;
        [weakSelf ts_configDidLoad];
    }];
}

- (void)ts_pushConfig {
    if (!self.hrConfig) { self.hrConfig = [[TSAutoMonitorHRConfigs alloc] init]; }
    self.hrConfig.schedule = self.schedule;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] heartRate]
        pushAutoMonitorConfigs:self.hrConfig
                    completion:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            TSLog(@"设置心率配置成功");
            [weakSelf ts_configDidSave];
        } else {
            TSLog(@"设置心率配置失败: %@", error);
            [weakSelf ts_configSaveFailed:error];
        }
    }];
}

#pragma mark - Extra Sections

- (NSInteger)ts_numberOfExtraSections { return TSHRSectionCount; }

- (NSString *)ts_titleForExtraSection:(NSInteger)s {
    return (s == TSHRSectionRestAlert) ? TSLocalizedString(@"monitor.hr_rest_alert") : TSLocalizedString(@"monitor.hr_exercise_alert");
}

- (NSInteger)ts_numberOfRowsInExtraSection:(NSInteger)s {
    // 运动心率预警：永远多一行 exerciseHRLimitMax
    return (s == TSHRSectionExerciseAlert) ? (TSHRAlertRowCount + 1) : TSHRAlertRowCount;
}

- (UITableViewCell *)ts_cellForExtraSection:(NSInteger)s
                                        row:(NSInteger)row
                                  tableView:(UITableView *)tableView {
    TSMonitorAlert *alert = (s == TSHRSectionRestAlert)
        ? self.hrConfig.restHRAlert
        : self.hrConfig.exerciseHRAlert;

    // Row 0: 启用开关
    if (row == TSHRAlertRowEnable) {
        return [self ts_alertSwitchCellForSection:s alert:alert tableView:tableView];
    }

    // 运动心率 Row 3: 运动心率上限
    if (s == TSHRSectionExerciseAlert && row == TSHRExerciseRowMaxHR) {
        NSString *val = [NSString stringWithFormat:@"%d bpm",
                         self.hrConfig.exerciseHRLimitMax];
        return [self ts_detailCellWithTitle:TSLocalizedString(@"monitor.hr_exercise_max") value:val tableView:tableView];
    }

    // Row 1/2: 阈值
    if (row == TSHRAlertRowUpper) {
        NSString *val = [NSString stringWithFormat:@"%d bpm", alert.upperLimit];
        return [self ts_detailCellWithTitle:TSLocalizedString(@"monitor.hr_upper_alert") value:val tableView:tableView];
    }
    if (row == TSHRAlertRowLower) {
        NSString *val = [NSString stringWithFormat:@"%d bpm", alert.lowerLimit];
        return [self ts_detailCellWithTitle:TSLocalizedString(@"monitor.hr_lower_alert") value:val tableView:tableView];
    }
    return [[UITableViewCell alloc] init];
}

- (void)ts_didSelectExtraSection:(NSInteger)s row:(NSInteger)row {
    if (row == TSHRAlertRowEnable) return; // 由 switch 处理

    TSMonitorAlert *alert = (s == TSHRSectionRestAlert)
        ? self.hrConfig.restHRAlert
        : self.hrConfig.exerciseHRAlert;

    __weak typeof(self) weakSelf = self;

    // 运动心率上限
    if (s == TSHRSectionExerciseAlert && row == TSHRExerciseRowMaxHR) {
        [self ts_showNumberInputWithTitle:TSLocalizedString(@"monitor.hr_exercise_max") unitLabel:@"bpm"
                             currentValue:self.hrConfig.exerciseHRLimitMax
                                     minV:100 maxV:220
                               completion:^(NSInteger v) {
            weakSelf.hrConfig.exerciseHRLimitMax = (UInt8)v;
            [weakSelf ts_markDirty];
            [weakSelf.tableView reloadData];
        }];
        return;
    }

    if (row == TSHRAlertRowUpper) {
        [self ts_showNumberInputWithTitle:TSLocalizedString(@"monitor.hr_upper_alert") unitLabel:@"bpm"
                             currentValue:alert.upperLimit minV:60 maxV:220
                               completion:^(NSInteger v) {
            alert.upperLimit = (UInt16)v;
            [weakSelf ts_markDirty];
            [weakSelf.tableView reloadData];
        }];
    } else if (row == TSHRAlertRowLower) {
        [self ts_showNumberInputWithTitle:TSLocalizedString(@"monitor.hr_lower_alert") unitLabel:@"bpm"
                             currentValue:alert.lowerLimit minV:30 maxV:120
                               completion:^(NSInteger v) {
            alert.lowerLimit = (UInt16)v;
            [weakSelf ts_markDirty];
            [weakSelf.tableView reloadData];
        }];
    }
}

#pragma mark - Cell Helpers

- (UITableViewCell *)ts_alertSwitchCellForSection:(NSInteger)s
                                            alert:(TSMonitorAlert *)alert
                                        tableView:(UITableView *)tableView {
    NSString *cellID = [NSString stringWithFormat:@"kTSHRAlertSwitch_%ld", (long)s];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        cell.textLabel.text  = TSLocalizedString(@"monitor.alert_enable");
        cell.textLabel.font  = [UIFont systemFontOfSize:16.f];
        cell.textLabel.textColor = TSColor_TextPrimary;

        UISwitch *sw = [[UISwitch alloc] init];
        sw.onTintColor = TSColor_Primary;
        sw.tag         = 2000 + s;
        [sw addTarget:self action:@selector(ts_alertSwitchChanged:)
     forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;
    }
    UISwitch *sw = (UISwitch *)[cell viewWithTag:2000 + s];
    [sw setOn:alert.isEnabled animated:NO];
    return cell;
}

- (UITableViewCell *)ts_detailCellWithTitle:(NSString *)title
                                      value:(NSString *)value
                                  tableView:(UITableView *)tableView {
    static NSString *cellID = @"kTSHRDetailCell";
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
    cell.textLabel.text       = title;
    cell.detailTextLabel.text = value;
    return cell;
}

- (void)ts_alertSwitchChanged:(UISwitch *)sw {
    NSInteger s = sw.tag - 2000;
    TSMonitorAlert *alert = (s == TSHRSectionRestAlert)
        ? self.hrConfig.restHRAlert
        : self.hrConfig.exerciseHRAlert;
    alert.enabled = sw.isOn;
    [self ts_markDirty];
}

@end
