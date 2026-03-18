//
//  TSSettingVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSSettingVC.h"
#import "TSPeripheralInfoVC.h"

// ─── Section / Row 枚举 ───────────────────────────────────────────────────────

typedef NS_ENUM(NSInteger, TSSettingSection) {
    TSSettingSectionWearing     = 0,  // 佩戴习惯
    TSSettingSectionNotify      = 1,  // 通知与提醒
    TSSettingSectionWristWake   = 2,  // 抬腕亮屏
    TSSettingSectionDND         = 3,  // 勿扰模式
    TSSettingSectionMonitor     = 4,  // 健康监测
    TSSettingSectionDeviceInfo  = 5,  // 设备信息
    TSSettingSectionCount       = 6,
};

typedef NS_ENUM(NSInteger, TSNotifyRow) {
    TSNotifyRowBluetooth  = 0,  // 蓝牙断连震动
    TSNotifyRowGoal       = 1,  // 运动目标提醒
    TSNotifyRowCallRing   = 2,  // 来电响铃
    TSNotifyRowCount      = 3,
};

// 抬腕亮屏 rows (动态)
// row 0 = 开关行
// row 1 = 开始时间 (仅开关开启时显示)
// row 2 = 结束时间 (仅开关开启时显示)

// 勿扰 rows (动态)
// row 0 = 开关行
// row 1 = 模式选择 (仅开关开启时)
// row 2 = 开始时间 (仅开关开启 + 时段模式)
// row 3 = 结束时间 (仅开关开启 + 时段模式)

// tags
static const NSInteger kTagWearingSeg  = 600;
static const NSInteger kTagNotifySwitch = 700; // +row

// ─── TSSettingVC ─────────────────────────────────────────────────────────────

@interface TSSettingVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView             *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, assign) BOOL                    dataLoaded;

// 佩戴习惯
@property (nonatomic, assign) TSWearingHabit wearingHabit;

// 通知开关
@property (nonatomic, assign) BOOL bluetoothVibration;
@property (nonatomic, assign) BOOL goalReminder;
@property (nonatomic, assign) BOOL callRing;

// 抬腕亮屏
@property (nonatomic, strong) TSWristWakeUpModel *wristWake;

// 勿扰模式
@property (nonatomic, strong) TSDoNotDisturbModel *dnd;

// 加强监测
@property (nonatomic, assign) BOOL enhancedMonitoring;

// 各功能支持状态（从 capability 预判断）
@property (nonatomic, assign) BOOL callRingSupported;
@property (nonatomic, assign) BOOL wristWakeSupported;
@property (nonatomic, assign) BOOL dndSupported;

@end

@implementation TSSettingVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"setting.title");
    self.view.backgroundColor = TSColor_Background;

    // 默认值（加载前）
    self.wristWake = [TSWristWakeUpModel new];
    self.wristWake.startTime = 480;   // 08:00
    self.wristWake.endTime   = 1320;  // 22:00

    self.dnd = [TSDoNotDisturbModel new];
    self.dnd.startTime = 1320;  // 22:00
    self.dnd.endTime   = 480;   // 08:00

    // 从 capability 预判断各功能支持状态
    TSFeatureAbility *fa = [TopStepComKit sharedInstance].connectedPeripheral.capability.featureAbility;
    self.callRingSupported  = fa ? fa.isSupportCallManagement : YES;
    self.wristWakeSupported = YES; // 暂无对应 capability flag
    self.dndSupported       = YES; // 暂无对应 capability flag

    [self ts_setupUI];
    [self ts_fetchAll];
}

#pragma mark - UI Setup

- (void)ts_setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStyleInsetGrouped];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = TSColor_Background;
    self.tableView.separatorColor  = TSColor_Separator;
    self.tableView.alpha           = 0;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];

    self.loadingIndicator = [[UIActivityIndicatorView alloc]
                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.color            = TSColor_Primary;
    self.loadingIndicator.hidesWhenStopped = YES;
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loadingIndicator];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor      constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],

        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];

    [self.loadingIndicator startAnimating];
}

#pragma mark - Fetch All

- (void)ts_fetchAll {
    __weak typeof(self) weakSelf = self;
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] setting]
     getCurrentWearingHabit:^(TSWearingHabit habit, NSError *e) {
        if (!e) weakSelf.wearingHabit = habit;
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] setting]
     getBluetoothDisconnectionVibrationStatus:^(BOOL enabled, NSError *e) {
        if (!e) weakSelf.bluetoothVibration = enabled;
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] setting]
     getExerciseGoalReminderStatus:^(BOOL enabled, NSError *e) {
        if (!e) weakSelf.goalReminder = enabled;
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] setting]
     getCallRingStatus:^(BOOL enabled, NSError *e) {
        if (!e) {
            weakSelf.callRing = enabled;
        } else {
            weakSelf.callRingSupported = NO;
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] setting]
     getRaiseWristToWakeStatus:^(TSWristWakeUpModel *model, NSError *e) {
        if (!e && model) {
            weakSelf.wristWake = model;
        } else if (e) {
            weakSelf.wristWakeSupported = NO;
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] setting]
     getDoNotDisturbInfo:^(TSDoNotDisturbModel *model, NSError *e) {
        if (!e && model) {
            weakSelf.dnd = model;
        } else if (e) {
            weakSelf.dndSupported = NO;
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] setting]
     getEnhancedMonitoringStatus:^(BOOL enabled, NSError *e) {
        if (!e) weakSelf.enhancedMonitoring = enabled;
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [weakSelf.loadingIndicator stopAnimating];
        weakSelf.dataLoaded = YES;
        [weakSelf.tableView reloadData];
        [UIView animateWithDuration:0.25 animations:^{ weakSelf.tableView.alpha = 1; }];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TSSettingSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case TSSettingSectionWearing:   return 1;
        case TSSettingSectionNotify:    return TSNotifyRowCount;
        case TSSettingSectionWristWake: return (self.wristWakeSupported && self.wristWake.isEnable) ? 3 : 1;
        case TSSettingSectionDND: {
            if (!self.dndSupported || !self.dnd.isEnabled) return 1;
            return self.dnd.isTimePeriodMode ? 4 : 2;
        }
        case TSSettingSectionMonitor:   return 1;
        case TSSettingSectionDeviceInfo: return 1;
        default: return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TSSettingSectionWearing:   return TSLocalizedString(@"setting.section.wearing");
        case TSSettingSectionNotify:    return TSLocalizedString(@"setting.section.notify");
        case TSSettingSectionWristWake: return TSLocalizedString(@"setting.section.wrist_wake");
        case TSSettingSectionDND:       return TSLocalizedString(@"setting.section.dnd");
        case TSSettingSectionMonitor:   return TSLocalizedString(@"setting.section.monitor");
        case TSSettingSectionDeviceInfo: return TSLocalizedString(@"setting.section.system");
        default: return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case TSSettingSectionWearing:
            return [self ts_wearingCellForTableView:tableView];
        case TSSettingSectionNotify:
            return [self ts_notifyCellForTableView:tableView row:indexPath.row];
        case TSSettingSectionWristWake:
            return [self ts_wristWakeCellForTableView:tableView row:indexPath.row];
        case TSSettingSectionDND:
            return [self ts_dndCellForTableView:tableView row:indexPath.row];
        case TSSettingSectionMonitor:
            return [self ts_monitorCellForTableView:tableView];
        case TSSettingSectionDeviceInfo:
            return [self ts_deviceInfoCellForTableView:tableView];
        default:
            return [UITableViewCell new];
    }
}

// ── 佩戴习惯 ──────────────────────────────────────────────────────────────────

- (UITableViewCell *)ts_wearingCellForTableView:(UITableView *)tableView {
    static NSString *cellID = @"kTSWearingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;

        UIView *iconBg = [[UIView alloc] init];
        iconBg.backgroundColor    = TSColor_Primary;
        iconBg.layer.cornerRadius = TSRadius_SM;
        iconBg.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:iconBg];

        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.image       = [UIImage systemImageNamed:@"hand.raised.fill"];
        iconView.tintColor   = UIColor.whiteColor;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [iconBg addSubview:iconView];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text      = TSLocalizedString(@"setting.wearing_hand");
        titleLabel.font      = TSFont_Body;
        titleLabel.textColor = TSColor_TextPrimary;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:titleLabel];

        UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[TSLocalizedString(@"setting.left_hand"), TSLocalizedString(@"setting.right_hand")]];
        seg.tag     = kTagWearingSeg;
        seg.enabled = NO;
        [seg addTarget:self action:@selector(ts_wearingSegChanged:)
      forControlEvents:UIControlEventValueChanged];
        seg.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:seg];

        [NSLayoutConstraint activateConstraints:@[
            [iconBg.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor constant:TSSpacing_MD],
            [iconBg.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [iconBg.widthAnchor    constraintEqualToConstant:34.f],
            [iconBg.heightAnchor   constraintEqualToConstant:34.f],

            [iconView.centerXAnchor constraintEqualToAnchor:iconBg.centerXAnchor],
            [iconView.centerYAnchor constraintEqualToAnchor:iconBg.centerYAnchor],
            [iconView.widthAnchor   constraintEqualToConstant:20.f],
            [iconView.heightAnchor  constraintEqualToConstant:20.f],

            [titleLabel.leadingAnchor  constraintEqualToAnchor:iconBg.trailingAnchor constant:TSSpacing_SM + 4],
            [titleLabel.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:seg.leadingAnchor constant:-TSSpacing_SM],

            [seg.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-TSSpacing_MD],
            [seg.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [seg.widthAnchor    constraintEqualToConstant:190.f],
        ]];
    }

    UISegmentedControl *seg = (UISegmentedControl *)[cell.contentView viewWithTag:kTagWearingSeg];
    seg.enabled = self.dataLoaded;
    seg.selectedSegmentIndex = self.dataLoaded
        ? (self.wearingHabit == TSWearingHabitLeft ? 0 : 1)
        : UISegmentedControlNoSegment;
    return cell;
}

// ── 通知与提醒 ────────────────────────────────────────────────────────────────

- (UITableViewCell *)ts_notifyCellForTableView:(UITableView *)tableView row:(NSInteger)row {
    NSString *cellID = [NSString stringWithFormat:@"kTSNotifyCell_%ld", (long)row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;

        UIView *iconBg = [[UIView alloc] init];
        iconBg.layer.cornerRadius = TSRadius_SM;
        iconBg.translatesAutoresizingMaskIntoConstraints = NO;
        iconBg.tag = 801;
        [cell.contentView addSubview:iconBg];

        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.tintColor   = UIColor.whiteColor;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.tag         = 802;
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [iconBg addSubview:iconView];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font      = TSFont_Body;
        titleLabel.textColor = TSColor_TextPrimary;
        titleLabel.tag       = 850;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:titleLabel];

        UILabel *subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.font      = TSFont_Caption;
        subtitleLabel.textColor = TSColor_TextSecondary;
        subtitleLabel.tag       = 851;
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:subtitleLabel];

        UISwitch *sw = [[UISwitch alloc] init];
        sw.tag = kTagNotifySwitch + row;
        sw.onTintColor = TSColor_Primary;
        [sw addTarget:self action:@selector(ts_notifySwitchChanged:)
     forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;

        [NSLayoutConstraint activateConstraints:@[
            [iconBg.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor constant:TSSpacing_MD],
            [iconBg.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [iconBg.widthAnchor    constraintEqualToConstant:34.f],
            [iconBg.heightAnchor   constraintEqualToConstant:34.f],

            [iconView.centerXAnchor constraintEqualToAnchor:iconBg.centerXAnchor],
            [iconView.centerYAnchor constraintEqualToAnchor:iconBg.centerYAnchor],
            [iconView.widthAnchor   constraintEqualToConstant:20.f],
            [iconView.heightAnchor  constraintEqualToConstant:20.f],

            [titleLabel.leadingAnchor  constraintEqualToAnchor:iconBg.trailingAnchor constant:TSSpacing_SM + 4],
            [titleLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-(60 + TSSpacing_MD)],
            [titleLabel.topAnchor      constraintEqualToAnchor:cell.contentView.topAnchor constant:11.f],

            [subtitleLabel.leadingAnchor  constraintEqualToAnchor:titleLabel.leadingAnchor],
            [subtitleLabel.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],
            [subtitleLabel.topAnchor      constraintEqualToAnchor:titleLabel.bottomAnchor constant:2.f],
        ]];
    }

    UIView      *iconBg      = [cell.contentView viewWithTag:801];
    UIImageView *iconView    = (UIImageView *)[cell.contentView viewWithTag:802];
    UILabel     *titleLbl    = (UILabel *)[cell.contentView viewWithTag:850];
    UILabel     *subtitleLbl = (UILabel *)[cell.contentView viewWithTag:851];
    UISwitch    *sw          = (UISwitch *)cell.accessoryView;

    switch (row) {
        case TSNotifyRowBluetooth:
            iconBg.backgroundColor = TSColor_Warning;
            iconView.image         = [UIImage systemImageNamed:@"antenna.radiowaves.left.and.right"];
            titleLbl.text          = TSLocalizedString(@"setting.ble_disconnect_vibrate");
            subtitleLbl.text       = TSLocalizedString(@"setting.ble_disconnect_vibrate.sub");
            sw.on = self.bluetoothVibration;
            break;
        case TSNotifyRowGoal:
            iconBg.backgroundColor = TSColor_Success;
            iconView.image         = [UIImage systemImageNamed:@"trophy.fill"];
            titleLbl.text          = TSLocalizedString(@"setting.goal_reminder");
            subtitleLbl.text       = TSLocalizedString(@"setting.goal_reminder.sub");
            sw.on = self.goalReminder;
            break;
        case TSNotifyRowCallRing:
            iconBg.backgroundColor = [UIColor systemPurpleColor];
            iconView.image         = [UIImage systemImageNamed:@"phone.fill"];
            titleLbl.text          = TSLocalizedString(@"setting.call_ring");
            subtitleLbl.text       = self.callRingSupported ? TSLocalizedString(@"setting.call_ring.sub") : TSLocalizedString(@"setting.not_supported");
            sw.on = self.callRing;
            break;
    }

    BOOL supported = (row == TSNotifyRowCallRing) ? self.callRingSupported : YES;
    sw.enabled          = supported && self.dataLoaded;
    titleLbl.textColor  = supported ? TSColor_TextPrimary   : TSColor_TextSecondary;
    iconBg.alpha        = supported ? 1.0f : 0.4f;
    return cell;
}

// ── 抬腕亮屏 ──────────────────────────────────────────────────────────────────

- (UITableViewCell *)ts_wristWakeCellForTableView:(UITableView *)tableView row:(NSInteger)row {
    if (row == 0) {
        // 开关行
        static NSString *cellID = @"kTSWristToggleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:cellID];
            cell.backgroundColor = TSColor_Card;
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;

            UIView *iconBg = [[UIView alloc] init];
            iconBg.backgroundColor    = TSColor_Primary;
            iconBg.layer.cornerRadius = TSRadius_SM;
            iconBg.translatesAutoresizingMaskIntoConstraints = NO;
            iconBg.tag = 811;
            [cell.contentView addSubview:iconBg];

            UIImageView *iconView = [[UIImageView alloc] init];
            iconView.image       = [UIImage systemImageNamed:@"hand.raised.fill"];
            iconView.tintColor   = UIColor.whiteColor;
            iconView.contentMode = UIViewContentModeScaleAspectFit;
            iconView.translatesAutoresizingMaskIntoConstraints = NO;
            [iconBg addSubview:iconView];

            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.font      = TSFont_Body;
            titleLabel.textColor = TSColor_TextPrimary;
            titleLabel.tag       = 850;
            titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:titleLabel];

            UILabel *subtitleLabel = [[UILabel alloc] init];
            subtitleLabel.font      = TSFont_Caption;
            subtitleLabel.textColor = TSColor_TextSecondary;
            subtitleLabel.tag       = 851;
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:subtitleLabel];

            UISwitch *sw = [[UISwitch alloc] init];
            sw.tag = 812;
            sw.onTintColor = TSColor_Primary;
            [sw addTarget:self action:@selector(ts_wristWakeSwitchChanged:)
         forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;

            [NSLayoutConstraint activateConstraints:@[
                [iconBg.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor constant:TSSpacing_MD],
                [iconBg.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
                [iconBg.widthAnchor    constraintEqualToConstant:34.f],
                [iconBg.heightAnchor   constraintEqualToConstant:34.f],

                [iconView.centerXAnchor constraintEqualToAnchor:iconBg.centerXAnchor],
                [iconView.centerYAnchor constraintEqualToAnchor:iconBg.centerYAnchor],
                [iconView.widthAnchor   constraintEqualToConstant:20.f],
                [iconView.heightAnchor  constraintEqualToConstant:20.f],

                [titleLabel.leadingAnchor  constraintEqualToAnchor:iconBg.trailingAnchor constant:TSSpacing_SM + 4],
                [titleLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-(60 + TSSpacing_MD)],
                [titleLabel.topAnchor      constraintEqualToAnchor:cell.contentView.topAnchor constant:11.f],

                [subtitleLabel.leadingAnchor  constraintEqualToAnchor:titleLabel.leadingAnchor],
                [subtitleLabel.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],
                [subtitleLabel.topAnchor      constraintEqualToAnchor:titleLabel.bottomAnchor constant:2.f],
            ]];
        }

        UILabel  *titleLbl    = (UILabel *)[cell.contentView viewWithTag:850];
        UILabel  *subtitleLbl = (UILabel *)[cell.contentView viewWithTag:851];
        UISwitch *sw          = (UISwitch *)cell.accessoryView;
        sw.on      = self.wristWake.isEnable;
        sw.enabled = self.wristWakeSupported && self.dataLoaded;
        titleLbl.textColor = self.wristWakeSupported ? TSColor_TextPrimary : TSColor_TextSecondary;
        titleLbl.text = TSLocalizedString(@"setting.section.wrist_wake");
        if (!self.wristWakeSupported) {
            subtitleLbl.text = TSLocalizedString(@"setting.not_supported");
        } else if (self.wristWake.isEnable) {
            subtitleLbl.text = [NSString stringWithFormat:@"%@ – %@",
                                [self ts_minutesToString:self.wristWake.startTime],
                                [self ts_minutesToString:self.wristWake.endTime]];
        } else {
            subtitleLbl.text = TSLocalizedString(@"setting.off");
        }
        return cell;
    }

    // 时间行 (row 1 = 开始, row 2 = 结束)
    BOOL isStart   = (row == 1);
    NSString *cellID = isStart ? @"kTSWristStartCell" : @"kTSWristEndCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellID];
        cell.backgroundColor           = TSColor_Card;
        cell.textLabel.font            = TSFont_Body;
        cell.textLabel.textColor       = TSColor_TextPrimary;
        cell.detailTextLabel.font      = TSFont_Body;
        cell.detailTextLabel.textColor = TSColor_TextSecondary;
        cell.accessoryType             = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text       = isStart ? TSLocalizedString(@"general.start_time") : TSLocalizedString(@"general.end_time");
    cell.detailTextLabel.text = isStart
        ? [self ts_minutesToString:self.wristWake.startTime]
        : [self ts_minutesToString:self.wristWake.endTime];
    return cell;
}

// ── 勿扰模式 ──────────────────────────────────────────────────────────────────

- (UITableViewCell *)ts_dndCellForTableView:(UITableView *)tableView row:(NSInteger)row {
    if (row == 0) {
        // 开关行
        static NSString *cellID = @"kTSDNDToggleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:cellID];
            cell.backgroundColor = TSColor_Card;
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;

            UIView *iconBg = [[UIView alloc] init];
            iconBg.backgroundColor    = [UIColor systemIndigoColor];
            iconBg.layer.cornerRadius = TSRadius_SM;
            iconBg.translatesAutoresizingMaskIntoConstraints = NO;
            iconBg.tag = 821;
            [cell.contentView addSubview:iconBg];

            UIImageView *iconView = [[UIImageView alloc] init];
            iconView.image       = [UIImage systemImageNamed:@"bell.slash.fill"];
            iconView.tintColor   = UIColor.whiteColor;
            iconView.contentMode = UIViewContentModeScaleAspectFit;
            iconView.translatesAutoresizingMaskIntoConstraints = NO;
            [iconBg addSubview:iconView];

            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.font      = TSFont_Body;
            titleLabel.textColor = TSColor_TextPrimary;
            titleLabel.tag       = 850;
            titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:titleLabel];

            UILabel *subtitleLabel = [[UILabel alloc] init];
            subtitleLabel.font      = TSFont_Caption;
            subtitleLabel.textColor = TSColor_TextSecondary;
            subtitleLabel.tag       = 851;
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:subtitleLabel];

            UISwitch *sw = [[UISwitch alloc] init];
            sw.tag = 822;
            sw.onTintColor = TSColor_Primary;
            [sw addTarget:self action:@selector(ts_dndSwitchChanged:)
         forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;

            [NSLayoutConstraint activateConstraints:@[
                [iconBg.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor constant:TSSpacing_MD],
                [iconBg.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
                [iconBg.widthAnchor    constraintEqualToConstant:34.f],
                [iconBg.heightAnchor   constraintEqualToConstant:34.f],

                [iconView.centerXAnchor constraintEqualToAnchor:iconBg.centerXAnchor],
                [iconView.centerYAnchor constraintEqualToAnchor:iconBg.centerYAnchor],
                [iconView.widthAnchor   constraintEqualToConstant:20.f],
                [iconView.heightAnchor  constraintEqualToConstant:20.f],

                [titleLabel.leadingAnchor  constraintEqualToAnchor:iconBg.trailingAnchor constant:TSSpacing_SM + 4],
                [titleLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-(60 + TSSpacing_MD)],
                [titleLabel.topAnchor      constraintEqualToAnchor:cell.contentView.topAnchor constant:11.f],

                [subtitleLabel.leadingAnchor  constraintEqualToAnchor:titleLabel.leadingAnchor],
                [subtitleLabel.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],
                [subtitleLabel.topAnchor      constraintEqualToAnchor:titleLabel.bottomAnchor constant:2.f],
            ]];
        }

        UILabel  *titleLbl    = (UILabel *)[cell.contentView viewWithTag:850];
        UILabel  *subtitleLbl = (UILabel *)[cell.contentView viewWithTag:851];
        UISwitch *sw          = (UISwitch *)cell.accessoryView;
        sw.on      = self.dnd.isEnabled;
        sw.enabled = self.dndSupported && self.dataLoaded;
        titleLbl.textColor = self.dndSupported ? TSColor_TextPrimary : TSColor_TextSecondary;
        titleLbl.text = TSLocalizedString(@"setting.section.dnd");
        if (!self.dndSupported) {
            subtitleLbl.text = TSLocalizedString(@"setting.not_supported");
        } else if (self.dnd.isEnabled) {
            subtitleLbl.text = self.dnd.isTimePeriodMode
                ? [NSString stringWithFormat:@"%@ – %@",
                   [self ts_minutesToString:self.dnd.startTime],
                   [self ts_minutesToString:self.dnd.endTime]]
                : TSLocalizedString(@"setting.all_day");
        } else {
            subtitleLbl.text = TSLocalizedString(@"setting.off");
        }
        return cell;
    }

    if (row == 1) {
        // 模式选择行
        static NSString *cellID = @"kTSDNDModeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:cellID];
            cell.backgroundColor = TSColor_Card;
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;

            UILabel *label = [[UILabel alloc] init];
            label.text      = TSLocalizedString(@"setting.mode");
            label.font      = TSFont_Body;
            label.textColor = TSColor_TextPrimary;
            label.tag = 831;
            label.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:label];

            UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[TSLocalizedString(@"setting.all_day"), TSLocalizedString(@"setting.time_period")]];
            seg.tag = 832;
            seg.tintColor = TSColor_Primary;
            [seg addTarget:self action:@selector(ts_dndModeSegChanged:)
          forControlEvents:UIControlEventValueChanged];
            seg.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:seg];

            [NSLayoutConstraint activateConstraints:@[
                [label.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor constant:TSSpacing_MD + 34 + TSSpacing_SM + 4],
                [label.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
                [label.trailingAnchor constraintLessThanOrEqualToAnchor:seg.leadingAnchor constant:-TSSpacing_SM],

                [seg.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-TSSpacing_MD],
                [seg.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
                [seg.widthAnchor    constraintEqualToConstant:190.f],
            ]];
        }
        UISegmentedControl *seg = (UISegmentedControl *)[cell.contentView viewWithTag:832];
        seg.selectedSegmentIndex = self.dnd.isTimePeriodMode ? 1 : 0;
        return cell;
    }

    // row 2/3 = 开始/结束时间（时段模式）
    BOOL isStart   = (row == 2);
    NSString *cellID = isStart ? @"kTSDNDStartCell" : @"kTSDNDEndCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellID];
        cell.backgroundColor           = TSColor_Card;
        cell.textLabel.font            = TSFont_Body;
        cell.textLabel.textColor       = TSColor_TextPrimary;
        cell.detailTextLabel.font      = TSFont_Body;
        cell.detailTextLabel.textColor = TSColor_TextSecondary;
        cell.accessoryType             = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text       = isStart ? TSLocalizedString(@"general.start_time") : TSLocalizedString(@"general.end_time");
    cell.detailTextLabel.text = isStart
        ? [self ts_minutesToString:self.dnd.startTime]
        : [self ts_minutesToString:self.dnd.endTime];
    return cell;
}

// ── 加强监测 ──────────────────────────────────────────────────────────────────

- (UITableViewCell *)ts_monitorCellForTableView:(UITableView *)tableView {
    static NSString *cellID = @"kTSMonitorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;

        UIView *iconBg = [[UIView alloc] init];
        iconBg.backgroundColor    = TSColor_Danger;
        iconBg.layer.cornerRadius = TSRadius_SM;
        iconBg.translatesAutoresizingMaskIntoConstraints = NO;
        iconBg.tag = 841;
        [cell.contentView addSubview:iconBg];

        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.image       = [UIImage systemImageNamed:@"heart.fill"];
        iconView.tintColor   = UIColor.whiteColor;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [iconBg addSubview:iconView];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font      = TSFont_Body;
        titleLabel.textColor = TSColor_TextPrimary;
        titleLabel.tag       = 850;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:titleLabel];

        UILabel *subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.font      = TSFont_Caption;
        subtitleLabel.textColor = TSColor_TextSecondary;
        subtitleLabel.tag       = 851;
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:subtitleLabel];

        UISwitch *sw = [[UISwitch alloc] init];
        sw.tag = 842;
        sw.onTintColor = TSColor_Primary;
        [sw addTarget:self action:@selector(ts_monitorSwitchChanged:)
     forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;

        [NSLayoutConstraint activateConstraints:@[
            [iconBg.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor constant:TSSpacing_MD],
            [iconBg.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [iconBg.widthAnchor    constraintEqualToConstant:34.f],
            [iconBg.heightAnchor   constraintEqualToConstant:34.f],

            [iconView.centerXAnchor constraintEqualToAnchor:iconBg.centerXAnchor],
            [iconView.centerYAnchor constraintEqualToAnchor:iconBg.centerYAnchor],
            [iconView.widthAnchor   constraintEqualToConstant:20.f],
            [iconView.heightAnchor  constraintEqualToConstant:20.f],

            [titleLabel.leadingAnchor  constraintEqualToAnchor:iconBg.trailingAnchor constant:TSSpacing_SM + 4],
            [titleLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-(60 + TSSpacing_MD)],
            [titleLabel.topAnchor      constraintEqualToAnchor:cell.contentView.topAnchor constant:11.f],

            [subtitleLabel.leadingAnchor  constraintEqualToAnchor:titleLabel.leadingAnchor],
            [subtitleLabel.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],
            [subtitleLabel.topAnchor      constraintEqualToAnchor:titleLabel.bottomAnchor constant:2.f],
        ]];
    }

    UILabel  *titleLbl    = (UILabel *)[cell.contentView viewWithTag:850];
    UILabel  *subtitleLbl = (UILabel *)[cell.contentView viewWithTag:851];
    UISwitch *sw          = (UISwitch *)cell.accessoryView;
    sw.on      = self.enhancedMonitoring;
    sw.enabled = self.dataLoaded;
    titleLbl.text    = TSLocalizedString(@"setting.enhanced_monitor");
    subtitleLbl.text = TSLocalizedString(@"setting.enhanced_monitor.sub");
    return cell;
}

/**
 * 设备信息 cell
 */
- (UITableViewCell *)ts_deviceInfoCellForTableView:(UITableView *)tableView {
    static NSString *cellID = @"kTSDeviceInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.selectionStyle  = UITableViewCellSelectionStyleDefault;
        cell.accessoryType   = UITableViewCellAccessoryDisclosureIndicator;

        UIView *iconBg = [[UIView alloc] init];
        iconBg.backgroundColor    = TSColor_Gray;
        iconBg.layer.cornerRadius = TSRadius_SM;
        iconBg.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:iconBg];

        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.image       = [UIImage systemImageNamed:@"info.circle.fill"];
        iconView.tintColor   = UIColor.whiteColor;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [iconBg addSubview:iconView];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text      = TSLocalizedString(@"device.menu.device_info");
        titleLabel.font      = TSFont_Body;
        titleLabel.textColor = TSColor_TextPrimary;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:titleLabel];

        [NSLayoutConstraint activateConstraints:@[
            [iconBg.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor constant:TSSpacing_MD],
            [iconBg.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [iconBg.widthAnchor    constraintEqualToConstant:34.f],
            [iconBg.heightAnchor   constraintEqualToConstant:34.f],

            [iconView.centerXAnchor constraintEqualToAnchor:iconBg.centerXAnchor],
            [iconView.centerYAnchor constraintEqualToAnchor:iconBg.centerYAnchor],
            [iconView.widthAnchor   constraintEqualToConstant:20.f],
            [iconView.heightAnchor  constraintEqualToConstant:20.f],

            [titleLabel.leadingAnchor  constraintEqualToAnchor:iconBg.trailingAnchor constant:TSSpacing_SM],
            [titleLabel.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
        ]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TSSettingSectionWearing) return 62.f;
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // 设备信息
    if (indexPath.section == TSSettingSectionDeviceInfo) {
        TSPeripheralInfoVC *infoVC = [[TSPeripheralInfoVC alloc] init];
        [self.navigationController pushViewController:infoVC animated:YES];
        return;
    }

    // 抬腕亮屏时间行
    if (indexPath.section == TSSettingSectionWristWake && indexPath.row > 0) {
        BOOL isStart = (indexPath.row == 1);
        NSInteger current = isStart ? self.wristWake.startTime : self.wristWake.endTime;
        [self ts_showTimePickerWithCurrentMinutes:current
                                           title:isStart ? TSLocalizedString(@"general.start_time") : TSLocalizedString(@"general.end_time")
                                      completion:^(NSInteger minutes) {
            if (isStart) self.wristWake.startTime = minutes;
            else         self.wristWake.endTime   = minutes;
            [self ts_saveWristWake];
        }];
        return;
    }

    // 勿扰时间行
    if (indexPath.section == TSSettingSectionDND && indexPath.row >= 2) {
        BOOL isStart = (indexPath.row == 2);
        NSInteger current = isStart ? self.dnd.startTime : self.dnd.endTime;
        [self ts_showTimePickerWithCurrentMinutes:current
                                           title:isStart ? TSLocalizedString(@"general.start_time") : TSLocalizedString(@"general.end_time")
                                      completion:^(NSInteger minutes) {
            if (isStart) self.dnd.startTime = minutes;
            else         self.dnd.endTime   = minutes;
            [self ts_saveDND];
        }];
    }
}

#pragma mark - Switch / Segment Actions

- (void)ts_wearingSegChanged:(UISegmentedControl *)sender {
    TSWearingHabit prev = self.wearingHabit;
    TSWearingHabit next = (sender.selectedSegmentIndex == 0) ? TSWearingHabitLeft : TSWearingHabitRight;
    sender.enabled = NO;
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] setting]
     setWearingHabit:next completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (success) {
                weakSelf.wearingHabit = next;
                [weakSelf ts_showToast:(next == TSWearingHabitLeft) ? TSLocalizedString(@"setting.set_left") : TSLocalizedString(@"setting.set_right")];
            } else {
                sender.selectedSegmentIndex = (prev == TSWearingHabitLeft) ? 0 : 1;
                [weakSelf ts_showError:error title:TSLocalizedString(@"setting.failed")];
            }
        });
    }];
}

- (void)ts_notifySwitchChanged:(UISwitch *)sender {
    NSInteger row = sender.tag - kTagNotifySwitch;
    sender.enabled = NO;
    __weak typeof(self) weakSelf = self;

    void (^handle)(BOOL success, NSError *error, BOOL prevVal, void(^setter)(BOOL)) =
    ^(BOOL success, NSError *error, BOOL prevVal, void(^setter)(BOOL)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (success) {
                setter(sender.isOn);
                [weakSelf ts_showToast:sender.isOn ? TSLocalizedString(@"setting.enabled") : TSLocalizedString(@"setting.off")];
            } else {
                sender.on = prevVal;
                [weakSelf ts_showError:error title:TSLocalizedString(@"setting.failed")];
            }
        });
    };

    if (row == TSNotifyRowBluetooth) {
        BOOL prev = self.bluetoothVibration;
        [[[TopStepComKit sharedInstance] setting]
         setBluetoothDisconnectionVibration:sender.isOn
                                 completion:^(BOOL s, NSError *e) {
            handle(s, e, prev, ^(BOOL v){ weakSelf.bluetoothVibration = v; });
        }];
    } else if (row == TSNotifyRowGoal) {
        BOOL prev = self.goalReminder;
        [[[TopStepComKit sharedInstance] setting]
         setExerciseGoalReminder:sender.isOn
                      completion:^(BOOL s, NSError *e) {
            handle(s, e, prev, ^(BOOL v){ weakSelf.goalReminder = v; });
        }];
    } else if (row == TSNotifyRowCallRing) {
        BOOL prev = self.callRing;
        [[[TopStepComKit sharedInstance] setting]
         setCallRing:sender.isOn
          completion:^(BOOL s, NSError *e) {
            handle(s, e, prev, ^(BOOL v){ weakSelf.callRing = v; });
        }];
    }
}

- (void)ts_wristWakeSwitchChanged:(UISwitch *)sender {
    BOOL prev = self.wristWake.isEnable;
    self.wristWake.isEnable = sender.isOn;
    sender.enabled = NO;

    NSIndexSet *section = [NSIndexSet indexSetWithIndex:TSSettingSectionWristWake];
    [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] setting]
     setRaiseWristToWake:self.wristWake completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (success) {
                [weakSelf ts_showToast:sender.isOn ? TSLocalizedString(@"setting.wrist_wake_on") : TSLocalizedString(@"setting.wrist_wake_off")];
            } else {
                weakSelf.wristWake.isEnable = prev;
                [weakSelf.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakSelf ts_showError:error title:TSLocalizedString(@"setting.failed")];
            }
        });
    }];
}

- (void)ts_dndSwitchChanged:(UISwitch *)sender {
    BOOL prev = self.dnd.isEnabled;
    self.dnd.isEnabled = sender.isOn;
    sender.enabled = NO;

    NSIndexSet *section = [NSIndexSet indexSetWithIndex:TSSettingSectionDND];
    [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] setting]
     setDoNotDisturb:self.dnd completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (success) {
                [weakSelf ts_showToast:sender.isOn ? TSLocalizedString(@"setting.dnd_on") : TSLocalizedString(@"setting.dnd_off")];
            } else {
                weakSelf.dnd.isEnabled = prev;
                [weakSelf.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakSelf ts_showError:error title:TSLocalizedString(@"setting.failed")];
            }
        });
    }];
}

- (void)ts_dndModeSegChanged:(UISegmentedControl *)sender {
    BOOL prev = self.dnd.isTimePeriodMode;
    self.dnd.isTimePeriodMode = (sender.selectedSegmentIndex == 1);

    NSIndexSet *section = [NSIndexSet indexSetWithIndex:TSSettingSectionDND];
    [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] setting]
     setDoNotDisturb:self.dnd completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [weakSelf ts_showToast:weakSelf.dnd.isTimePeriodMode ? TSLocalizedString(@"setting.switched_period") : TSLocalizedString(@"setting.switched_allday")];
            } else {
                weakSelf.dnd.isTimePeriodMode = prev;
                [weakSelf.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakSelf ts_showError:error title:TSLocalizedString(@"setting.failed")];
            }
        });
    }];
}

- (void)ts_monitorSwitchChanged:(UISwitch *)sender {
    BOOL prev = self.enhancedMonitoring;
    sender.enabled = NO;
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] setting]
     setEnhancedMonitoring:sender.isOn completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (success) {
                weakSelf.enhancedMonitoring = sender.isOn;
                [weakSelf ts_showToast:sender.isOn ? TSLocalizedString(@"setting.enhanced_on") : TSLocalizedString(@"setting.enhanced_off")];
            } else {
                sender.on = prev;
                [weakSelf ts_showError:error title:TSLocalizedString(@"setting.failed")];
            }
        });
    }];
}

#pragma mark - Save Helpers

- (void)ts_saveWristWake {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] setting]
     setRaiseWristToWake:self.wristWake completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                NSIndexSet *sec = [NSIndexSet indexSetWithIndex:TSSettingSectionWristWake];
                [weakSelf.tableView reloadSections:sec withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf ts_showToast:TSLocalizedString(@"setting.time_updated")];
            } else {
                [weakSelf ts_showError:error title:TSLocalizedString(@"setting.failed")];
            }
        });
    }];
}

- (void)ts_saveDND {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] setting]
     setDoNotDisturb:self.dnd completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                NSIndexSet *sec = [NSIndexSet indexSetWithIndex:TSSettingSectionDND];
                [weakSelf.tableView reloadSections:sec withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf ts_showToast:TSLocalizedString(@"setting.time_updated")];
            } else {
                [weakSelf ts_showError:error title:TSLocalizedString(@"setting.failed")];
            }
        });
    }];
}

#pragma mark - Time Picker

- (void)ts_showTimePickerWithCurrentMinutes:(NSInteger)minutes
                                      title:(NSString *)title
                                 completion:(void(^)(NSInteger minutes))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:@"\n\n\n\n\n\n\n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIDatePicker *picker = [[UIDatePicker alloc] init];
    picker.datePickerMode = UIDatePickerModeTime;
    if (@available(iOS 14.0, *)) {
        picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    picker.frame = CGRectMake(0, 44, 270, 180);

    // 将分钟数转换为 Date
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
                                     fromDate:[NSDate date]];
    comps.hour   = minutes / 60;
    comps.minute = minutes % 60;
    picker.date  = [cal dateFromComponents:comps];

    [alert.view addSubview:picker];

    __weak UIDatePicker *weakPicker = picker;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        NSDateComponents *c = [[NSCalendar currentCalendar]
                               components:(NSCalendarUnitHour|NSCalendarUnitMinute)
                               fromDate:weakPicker.date];
        completion(c.hour * 60 + c.minute);
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Helpers

- (NSString *)ts_minutesToString:(NSInteger)minutes {
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(minutes / 60), (long)(minutes % 60)];
}

#pragma mark - Toast / Error

- (void)ts_showToast:(NSString *)message {
    UILabel *toast = [[UILabel alloc] init];
    toast.text             = message;
    toast.font             = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    toast.textColor        = UIColor.whiteColor;
    toast.textAlignment    = NSTextAlignmentCenter;
    toast.backgroundColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    toast.layer.cornerRadius  = 18.f;
    toast.layer.masksToBounds = YES;
    toast.alpha = 0;

    CGFloat hPad  = TSSpacing_LG, vPad = TSSpacing_SM;
    CGFloat maxW  = self.view.bounds.size.width - TSSpacing_XL * 2;
    CGSize textSz = [message boundingRectWithSize:CGSizeMake(maxW - hPad * 2, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: toast.font}
                                          context:nil].size;
    CGFloat w = textSz.width  + hPad * 2;
    CGFloat h = textSz.height + vPad * 2;
    CGFloat x = (self.view.bounds.size.width - w) / 2.f;
    CGFloat y = self.view.bounds.size.height - h - TSSpacing_XL - self.view.safeAreaInsets.bottom;
    toast.frame = CGRectMake(x, y, w, h);

    [self.view addSubview:toast];
    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1; } completion:^(BOOL _) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{ toast.alpha = 0; }
                             completion:^(BOOL __) { [toast removeFromSuperview]; }];
        });
    }];
}

- (void)ts_showError:(NSError *)error title:(NSString *)title {
    NSString *msg = error.localizedDescription ?: TSLocalizedString(@"setting.operation_failed");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
