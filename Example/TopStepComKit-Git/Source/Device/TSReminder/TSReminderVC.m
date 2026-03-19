//
//  TSReminderVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSReminderVC.h"
#import "TSReminderEditorVC.h"
#import "TSBaseVC.h"

// ─── 工具函数 ────────────────────────────────────────────────────────────────

static NSString *TSReminderTimeSummary(TSRemindersModel *model) {
    if (!model.isEnabled) return TSLocalizedString(@"reminder.not_enabled");

    TSReminderDays d = model.repeatDays;
    NSString *repeatStr;
    if      (d == 0)                         repeatStr = TSLocalizedString(@"repeat.once");
    else if (d == eTSReminderRepeatEveryday)  repeatStr = TSLocalizedString(@"repeat.everyday");
    else if (d == eTSReminderRepeatWorkday)   repeatStr = TSLocalizedString(@"repeat.weekday");
    else if (d == eTSReminderRepeatWeekday)   repeatStr = TSLocalizedString(@"repeat.weekend");
    else {
        NSMutableArray *arr = [NSMutableArray array];
        if (d & eTSReminderDayMonday)    [arr addObject:TSLocalizedString(@"weekday.mon")];
        if (d & eTSReminderDayTuesday)   [arr addObject:TSLocalizedString(@"weekday.tue")];
        if (d & eTSReminderDayWednesday) [arr addObject:TSLocalizedString(@"weekday.wed")];
        if (d & eTSReminderDayThursday)  [arr addObject:TSLocalizedString(@"weekday.thu")];
        if (d & eTSReminderDayFriday)    [arr addObject:TSLocalizedString(@"weekday.fri")];
        if (d & eTSReminderDaySaturday)  [arr addObject:TSLocalizedString(@"weekday.sat")];
        if (d & eTSReminderDaySunday)    [arr addObject:TSLocalizedString(@"weekday.sun")];
        repeatStr = [arr componentsJoinedByString:TSLocalizedString(@"reminder.day_separator")];
    }

    NSString *timeStr;
    if (model.timeType == eTSReminderTimeTypePoint) {
        NSMutableArray *pts = [NSMutableArray array];
        for (NSNumber *n in model.timePoints) {
            NSInteger m = n.integerValue;
            [pts addObject:[NSString stringWithFormat:@"%02ld:%02ld", (long)(m/60), (long)(m%60)]];
        }
        timeStr = [pts componentsJoinedByString:TSLocalizedString(@"reminder.day_separator")];
    } else {
        NSInteger s = model.startTime, e = model.endTime;
        timeStr = [NSString stringWithFormat:TSLocalizedString(@"reminder.interval_format"),
                   (long)(s/60), (long)(s%60), (long)(e/60), (long)(e%60), (long)model.interval];
    }

    return [NSString stringWithFormat:@"%@ · %@", repeatStr, timeStr];
}

// ─── 列表 Cell ────────────────────────────────────────────────────────────────

@interface TSReminderListCell : UITableViewCell
@property (nonatomic, strong) UIView      *iconBg;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *subtitleLabel;
@property (nonatomic, strong) UISwitch    *toggle;
@property (nonatomic, copy)   void(^onSwitchChanged)(BOOL isOn);
@end

@implementation TSReminderListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    self.backgroundColor = TSColor_Card;
    self.accessoryType   = UITableViewCellAccessoryDisclosureIndicator;

    _iconBg = [[UIView alloc] init];
    _iconBg.layer.cornerRadius = 8;
    _iconBg.clipsToBounds = YES;
    _iconBg.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_iconBg];

    _iconView = [[UIImageView alloc] init];
    _iconView.tintColor = UIColor.whiteColor;
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    _iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [_iconBg addSubview:_iconView];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font      = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    _nameLabel.textColor = TSColor_TextPrimary;
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_nameLabel];

    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.font          = TSFont_Caption;
    _subtitleLabel.textColor     = TSColor_TextSecondary;
    _subtitleLabel.numberOfLines = 0;
    _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_subtitleLabel];

    _toggle = [[UISwitch alloc] init];
    _toggle.onTintColor = TSColor_Primary;
    _toggle.translatesAutoresizingMaskIntoConstraints = NO;
    [_toggle addTarget:self action:@selector(onToggleChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_toggle];

    CGFloat iconSize = 36;
    [NSLayoutConstraint activateConstraints:@[
        [_iconBg.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:TSSpacing_MD],
        [_iconBg.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_iconBg.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.topAnchor constant:10],
        [_iconBg.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.bottomAnchor constant:-10],
        [_iconBg.widthAnchor constraintEqualToConstant:iconSize],
        [_iconBg.heightAnchor constraintEqualToConstant:iconSize],

        [_iconView.leadingAnchor constraintEqualToAnchor:_iconBg.leadingAnchor constant:6],
        [_iconView.trailingAnchor constraintEqualToAnchor:_iconBg.trailingAnchor constant:-6],
        [_iconView.topAnchor constraintEqualToAnchor:_iconBg.topAnchor constant:6],
        [_iconView.bottomAnchor constraintEqualToAnchor:_iconBg.bottomAnchor constant:-6],

        [_toggle.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-44],
        [_toggle.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],

        [_nameLabel.leadingAnchor constraintEqualToAnchor:_iconBg.trailingAnchor constant:12],
        [_nameLabel.trailingAnchor constraintEqualToAnchor:_toggle.leadingAnchor constant:-8],
        [_nameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],

        [_subtitleLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_subtitleLabel.trailingAnchor constraintEqualToAnchor:_toggle.leadingAnchor constant:-8],
        [_subtitleLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:3],
        [_subtitleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10],
    ]];
    return self;
}

- (void)configureWithModel:(TSRemindersModel *)model iconName:(NSString *)iconName iconColor:(UIColor *)color {
    _iconBg.backgroundColor = color;
    _iconView.image = [UIImage systemImageNamed:iconName];
    _nameLabel.text    = model.reminderName ?: TSLocalizedString(@"reminder.default_name");
    _subtitleLabel.text = TSReminderTimeSummary(model);
    [UIView setAnimationsEnabled:NO];
    _toggle.on = model.isEnabled;
    [UIView setAnimationsEnabled:YES];
}

- (void)onToggleChanged:(UISwitch *)sw {
    if (self.onSwitchChanged) self.onSwitchChanged(sw.isOn);
}

@end

// ─── TSReminderVC ─────────────────────────────────────────────────────────────

@interface TSReminderVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView               *tableView;
@property (nonatomic, strong) UIActivityIndicatorView   *loadingView;
@property (nonatomic, strong) NSMutableArray<TSRemindersModel *> *builtinReminders;
@property (nonatomic, strong) NSMutableArray<TSRemindersModel *> *customReminders;

@end

@implementation TSReminderVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"reminder.title");
    self.view.backgroundColor = TSColor_Background;

    [self ts_setupViews];
    [self ts_fetch];
}

// 阻止 TSBaseVC 的 sourceTableview 干扰
- (void)setupViews  {}
- (void)layoutViews {}

#pragma mark - Setup

- (void)ts_setupViews {
    // 右上角添加按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                             target:self
                             action:@selector(ts_addReminder)];

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    _tableView.delegate       = self;
    _tableView.dataSource     = self;
    _tableView.backgroundColor = TSColor_Background;
    _tableView.separatorColor  = TSColor_Separator;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 64;
    [_tableView registerClass:[TSReminderListCell class] forCellReuseIdentifier:@"TSReminderListCell"];
    if (@available(iOS 15.0, *)) {
        _tableView.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:_tableView];

    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _loadingView.color = TSColor_Primary;
    _loadingView.hidesWhenStopped = YES;
    [self.view addSubview:_loadingView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
    _loadingView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
}

#pragma mark - Fetch

- (void)ts_fetch {
    _loadingView.alpha = 1;
    [_loadingView startAnimating];
    _tableView.alpha = 0.4;
    _tableView.userInteractionEnabled = NO;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] reminder] getAllRemindersWithCompletion:^(NSArray<TSRemindersModel *> *reminders, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingView stopAnimating];
            weakSelf.tableView.alpha = 1;
            weakSelf.tableView.userInteractionEnabled = YES;
            if (error) {
                [weakSelf ts_showToast:TSLocalizedString(@"reminder.fetch_failed") success:NO];
                return;
            }
            [weakSelf ts_applyReminders:reminders];
        });
    }];
}

- (void)ts_applyReminders:(NSArray<TSRemindersModel *> *)reminders {
    _builtinReminders = [NSMutableArray array];
    _customReminders  = [NSMutableArray array];

    for (TSRemindersModel *r in reminders) {
        if (r.reminderType == eTSReminderTypeCustom) {
            [_customReminders addObject:r];
        } else {
            // 内置提醒始终使用本地化名称，覆盖设备返回的固定中文名
            switch (r.reminderType) {
                case eTSReminderTypeSedentary:    r.reminderName = TSLocalizedString(@"reminder.sedentary"); break;
                case eTSReminderTypeDrinking:     r.reminderName = TSLocalizedString(@"reminder.drinking"); break;
                case eTSReminderTypeTakeMedicine: r.reminderName = TSLocalizedString(@"reminder.take_medicine"); break;
                default: break;
            }
            [_builtinReminders addObject:r];
        }
    }
    [_tableView reloadData];
}

#pragma mark - Add

- (void)ts_addReminder {
    // 检查数量上限
    NSInteger maxCount = [[[TopStepComKit sharedInstance] reminder] supportMaxCustomeReminders];
    if (maxCount > 0 && (NSInteger)_customReminders.count >= maxCount) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"reminder.max_reached")
                                                                       message:[NSString stringWithFormat:TSLocalizedString(@"reminder.max_count_format"), (long)maxCount]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] reminder] createCustomReminderTemplateWithCompletion:^(TSRemindersModel *reminder, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !reminder) {
                [weakSelf ts_showToast:TSLocalizedString(@"reminder.create_failed") success:NO];
                return;
            }
            [weakSelf ts_openEditor:reminder isNew:YES];
        });
    }];
}

#pragma mark - Editor

- (void)ts_openEditor:(TSRemindersModel *)reminder isNew:(BOOL)isNew {
    // 内置提醒始终使用本地化名称，覆盖设备返回的固定中文名
    switch (reminder.reminderType) {
        case eTSReminderTypeSedentary:    reminder.reminderName = TSLocalizedString(@"reminder.sedentary"); break;
        case eTSReminderTypeDrinking:     reminder.reminderName = TSLocalizedString(@"reminder.drinking"); break;
        case eTSReminderTypeTakeMedicine: reminder.reminderName = TSLocalizedString(@"reminder.take_medicine"); break;
        default: break;
    }
    __weak typeof(self) weakSelf = self;
    TSReminderEditorVC *editor = [[TSReminderEditorVC alloc] initWithReminder:reminder
                                                                        isNew:isNew
                                                                   completion:^(BOOL didSave) {
        [weakSelf ts_fetch]; // 刷新列表
    }];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editor];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Toast

- (void)ts_showToast:(NSString *)message success:(BOOL)success {
    UIView *toast = [[UIView alloc] init];
    toast.backgroundColor    = success ? TSColor_Success : TSColor_Danger;
    toast.layer.cornerRadius = 20;
    toast.alpha              = 0;
    toast.clipsToBounds      = YES;

    UIImageView *icon = [[UIImageView alloc] init];
    icon.image = [UIImage systemImageNamed:success ? @"checkmark.circle.fill" : @"xmark.circle.fill"];
    icon.tintColor    = UIColor.whiteColor;
    icon.contentMode  = UIViewContentModeScaleAspectFit;

    UILabel *label = [[UILabel alloc] init];
    label.text      = message;
    label.font      = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    label.textColor = UIColor.whiteColor;

    [toast addSubview:icon];
    [toast addSubview:label];
    [self.view addSubview:toast];

    CGFloat iconSize = 20;
    CGSize textSize  = [label sizeThatFits:CGSizeMake(300, 40)];
    CGFloat toastW   = iconSize + 8 + textSize.width + 32;
    CGFloat toastH   = 40;
    CGFloat safeBottom = self.view.safeAreaInsets.bottom;
    toast.frame = CGRectMake((self.view.bounds.size.width - toastW) / 2,
                             self.view.bounds.size.height - safeBottom - toastH - 16,
                             toastW, toastH);
    icon.frame  = CGRectMake(12, 10, iconSize, iconSize);
    label.frame = CGRectMake(CGRectGetMaxX(icon.frame) + 8, 0, textSize.width, toastH);

    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1; } completion:^(BOOL f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 0; } completion:^(BOOL d) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - Helper

- (TSRemindersModel *)ts_modelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row < (NSInteger)_builtinReminders.count) return _builtinReminders[indexPath.row];
    } else {
        if (indexPath.row < (NSInteger)_customReminders.count) return _customReminders[indexPath.row];
    }
    return nil;
}

- (nullable NSIndexPath *)ts_indexPathForModel:(TSRemindersModel *)model {
    for (NSInteger i = 0; i < (NSInteger)_builtinReminders.count; i++) {
        if (_builtinReminders[i] == model) return [NSIndexPath indexPathForRow:i inSection:0];
    }
    for (NSInteger i = 0; i < (NSInteger)_customReminders.count; i++) {
        if (_customReminders[i] == model) return [NSIndexPath indexPathForRow:i inSection:1];
    }
    return nil;
}

- (NSString *)ts_iconNameForModel:(TSRemindersModel *)model {
    switch (model.reminderType) {
        case eTSReminderTypeSedentary:    return @"figure.walk";
        case eTSReminderTypeDrinking:     return @"drop.fill";
        case eTSReminderTypeTakeMedicine: return @"pills.fill";
        default:                          return @"bell.fill";
    }
}

- (UIColor *)ts_iconColorForModel:(TSRemindersModel *)model {
    switch (model.reminderType) {
        case eTSReminderTypeSedentary:    return TSColor_Warning;
        case eTSReminderTypeDrinking:     return TSColor_Primary;
        case eTSReminderTypeTakeMedicine: return TSColor_Danger;
        default:                          return TSColor_Purple;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? _builtinReminders.count : _customReminders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSReminderListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TSReminderListCell" forIndexPath:indexPath];
    TSRemindersModel *model  = [self ts_modelAtIndexPath:indexPath];
    if (!model) return cell;

    [cell configureWithModel:model
                    iconName:[self ts_iconNameForModel:model]
                   iconColor:[self ts_iconColorForModel:model]];

    __weak typeof(self) weakSelf = self;
    __weak TSRemindersModel *weakModel = model;
    cell.onSwitchChanged = ^(BOOL isOn) {
        weakModel.isEnabled = isOn;
        [[[TopStepComKit sharedInstance] reminder] updateReminder:weakModel
                                                      completion:^(BOOL isSuccess, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *msg = isSuccess ? TSLocalizedString(@"general.synced") : TSLocalizedString(@"reminder.sync_failed");
                [weakSelf ts_showToast:msg success:isSuccess];
                if (!isSuccess) {
                    // 回滚开关状态，重新查找当前 indexPath 避免失效
                    weakModel.isEnabled = !isOn;
                    NSIndexPath *currentPath = [weakSelf ts_indexPathForModel:weakModel];
                    if (currentPath) {
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[currentPath]
                                                 withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
            });
        }];
    };
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return _builtinReminders.count > 0 ? TSLocalizedString(@"reminder.builtin") : nil;
    return _customReminders.count > 0 ? [NSString stringWithFormat:TSLocalizedString(@"reminder.custom_format"),
        (long)_customReminders.count,
        (long)[[[TopStepComKit sharedInstance] reminder] supportMaxCustomeReminders]] : nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1; // 仅自定义可删除
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    TSRemindersModel *model = [self ts_modelAtIndexPath:indexPath];
    if (!model) return;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] reminder] deleteReminderWithId:model.reminderId
                                                        completion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                [weakSelf.customReminders removeObject:model];
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                [weakSelf ts_showToast:TSLocalizedString(@"reminder.delete_failed") success:NO];
            }
        });
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TSRemindersModel *model = [self ts_modelAtIndexPath:indexPath];
    if (model) [self ts_openEditor:model isNew:NO];
}

@end
