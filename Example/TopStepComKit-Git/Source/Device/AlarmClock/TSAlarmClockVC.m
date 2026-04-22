//
//  TSAlarmClockVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSAlarmClockVC.h"
#import "TSAlarmEditorVC.h"

// ─── 重复规则转文字 ────────────────────────────────────────────────────────
static NSString *TSRepeatString(TSAlarmRepeat repeat) {
    if (repeat == TSAlarmRepeatNone) return TSLocalizedString(@"repeat.once");
    if (repeat == TSAlarmRepeatEveryday) return TSLocalizedString(@"repeat.everyday");
    if (repeat == TSAlarmRepeatWorkday) return TSLocalizedString(@"repeat.weekday");
    if (repeat == TSAlarmRepeatWeekend) return TSLocalizedString(@"repeat.weekend");

    NSMutableArray *days = [NSMutableArray array];
    if (repeat & TSAlarmRepeatMonday)    [days addObject:TSLocalizedString(@"weekday.mon")];
    if (repeat & TSAlarmRepeatTuesday)   [days addObject:TSLocalizedString(@"weekday.tue")];
    if (repeat & TSAlarmRepeatWednesday) [days addObject:TSLocalizedString(@"weekday.wed")];
    if (repeat & TSAlarmRepeatThursday)  [days addObject:TSLocalizedString(@"weekday.thu")];
    if (repeat & TSAlarmRepeatFriday)    [days addObject:TSLocalizedString(@"weekday.fri")];
    if (repeat & TSAlarmRepeatSaturday)  [days addObject:TSLocalizedString(@"weekday.sat")];
    if (repeat & TSAlarmRepeatSunday)    [days addObject:TSLocalizedString(@"weekday.sun")];
    return [days componentsJoinedByString:@" "];
}

// ─── 闹钟卡片 Cell ─────────────────────────────────────────────────────────
@interface TSAlarmCell : UITableViewCell
@property (nonatomic, strong) UILabel  *timeLabel;
@property (nonatomic, strong) UILabel  *labelLabel;
@property (nonatomic, strong) UILabel  *repeatLabel;
@property (nonatomic, strong) UISwitch *enableSwitch;
@property (nonatomic, copy)   void(^onSwitchChanged)(BOOL isOn);
- (void)reloadWithAlarm:(TSAlarmClockModel *)alarm;
@end

@implementation TSAlarmCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.backgroundColor = TSColor_Card;
    self.selectionStyle  = UITableViewCellSelectionStyleNone;
    self.tintColor       = TSColor_Primary;  // 设置选中时的对勾颜色

    // 时间（大号）
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font      = [UIFont systemFontOfSize:42 weight:UIFontWeightLight];
    self.timeLabel.textColor = TSColor_TextPrimary;
    [self.contentView addSubview:self.timeLabel];

    // 标签
    self.labelLabel = [[UILabel alloc] init];
    self.labelLabel.font      = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.labelLabel.textColor = TSColor_TextPrimary;
    [self.contentView addSubview:self.labelLabel];

    // 重复规则
    self.repeatLabel = [[UILabel alloc] init];
    self.repeatLabel.font      = [UIFont systemFontOfSize:13];
    self.repeatLabel.textColor = TSColor_TextSecondary;
    [self.contentView addSubview:self.repeatLabel];

    // 开关
    self.enableSwitch = [[UISwitch alloc] init];
    self.enableSwitch.onTintColor = TSColor_Primary;
    [self.enableSwitch addTarget:self action:@selector(ts_switchChanged:)
                 forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.enableSwitch];

    return self;
}

- (void)reloadWithAlarm:(TSAlarmClockModel *)alarm {
    self.timeLabel.text   = [NSString stringWithFormat:@"%02ld:%02ld", (long)[alarm hour], (long)[alarm minute]];
    self.labelLabel.text  = alarm.label.length ? alarm.label : TSLocalizedString(@"alarm.default_label");
    self.repeatLabel.text = TSRepeatString(alarm.repeatOptions);
    [self.enableSwitch setOn:alarm.isEnabled animated:NO];

    // 禁用状态时文字变灰
    CGFloat alpha = alarm.isEnabled ? 1.0 : 0.4;
    self.timeLabel.alpha   = alpha;
    self.labelLabel.alpha  = alpha;
    self.repeatLabel.alpha = alpha;

    // 标签显示/隐藏
    self.labelLabel.hidden = (alarm.label.length == 0);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.contentView.bounds.size.width;
    CGFloat h = self.contentView.bounds.size.height;

    self.enableSwitch.frame = CGRectMake(w - 51 - 16, (h - 31) / 2.f, 51, 31);

    CGFloat textW = w - 16 - 8 - 51 - 16 - 16;

    if (self.labelLabel.hidden) {
        // 无标签：时间居中，重复规则在下方
        self.timeLabel.frame   = CGRectMake(16, (h - 48 - 18) / 2.f, textW, 48);
        self.repeatLabel.frame = CGRectMake(16, CGRectGetMaxY(self.timeLabel.frame) + 4, textW, 18);
    } else {
        // 有标签：时间在上，标签和重复规则在下
        self.timeLabel.frame   = CGRectMake(16, 16, textW, 48);
        self.labelLabel.frame  = CGRectMake(16, 68, textW, 20);
        self.repeatLabel.frame = CGRectMake(16, 92, textW, 18);
    }
}

- (void)ts_switchChanged:(UISwitch *)sw {
    if (self.onSwitchChanged) self.onSwitchChanged(sw.isOn);
}

@end

// ─── 空状态视图 ────────────────────────────────────────────────────────────
@interface TSEmptyAlarmView : UIView
@end

@implementation TSEmptyAlarmView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    UIImageView *icon = [[UIImageView alloc] init];
    icon.tintColor   = [TSColor_TextSecondary colorWithAlphaComponent:0.3];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration
            configurationWithPointSize:80 weight:UIImageSymbolWeightThin];
        icon.image = [UIImage systemImageNamed:@"alarm" withConfiguration:cfg];
    }
    [self addSubview:icon];

    UILabel *title = [[UILabel alloc] init];
    title.text          = TSLocalizedString(@"alarm.empty.title");
    title.font          = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    title.textColor     = TSColor_TextSecondary;
    title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:title];

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text          = TSLocalizedString(@"alarm.empty.subtitle");
    subtitle.font          = [UIFont systemFontOfSize:14];
    subtitle.textColor     = [TSColor_TextSecondary colorWithAlphaComponent:0.7];
    subtitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:subtitle];

    CGFloat centerY = frame.size.height / 2.f - 80;
    icon.frame     = CGRectMake((frame.size.width - 100) / 2.f, centerY, 100, 100);
    title.frame    = CGRectMake(0, centerY + 110, frame.size.width, 24);
    subtitle.frame = CGRectMake(0, centerY + 140, frame.size.width, 20);

    return self;
}

@end

// ─── TSAlarmClockVC ────────────────────────────────────────────────────────
@interface TSAlarmClockVC () <TSAlarmEditorDelegate>
@property (nonatomic, strong) NSMutableArray<TSAlarmClockModel *> *alarms;
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIToolbar       *bottomToolbar;
@property (nonatomic, strong) UIBarButtonItem *deleteButton;
@property (nonatomic, strong) TSEmptyAlarmView *emptyView;
@property (nonatomic, assign) BOOL isEditMode;
@end

@implementation TSAlarmClockVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"alarm.page_title");
    self.view.backgroundColor = TSColor_Background;

    [self ts_setupNavBar];
    [self ts_setupTableView];
    [self ts_setupBottomToolbar];
    [self ts_setupEmptyView];
    [self ts_registerCallback];
    [self ts_loadAlarms];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;

    CGFloat bottomH = self.isEditMode ? 44 : 0;
    self.sourceTableview.frame = CGRectMake(0, topOffset,
                                            self.view.frame.size.width,
                                            self.view.frame.size.height - topOffset - bottomH);

    if (self.isEditMode) {
        self.bottomToolbar.frame = CGRectMake(0,
                                              self.view.frame.size.height - 44 - self.view.safeAreaInsets.bottom,
                                              self.view.frame.size.width, 44);
    }

    if (self.emptyView && !self.emptyView.hidden) {
        self.emptyView.frame = self.sourceTableview.frame;
    }
}

#pragma mark - Setup

- (void)ts_setupNavBar {
    // + 按钮
    UIImage *addIcon = nil;
    if (@available(iOS 13.0, *)) {
        addIcon = [UIImage systemImageNamed:@"plus"];
    }
    self.addButton = [[UIBarButtonItem alloc] initWithImage:addIcon
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(ts_addAlarm)];

    // 编辑按钮
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"alarm.edit_btn")
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(ts_toggleEditMode)];

    // 完成按钮
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.done")
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(ts_toggleEditMode)];

    self.navigationItem.rightBarButtonItems = @[self.addButton, self.editButton];
}

- (void)ts_setupTableView {
    [self.sourceTableview removeFromSuperview];

    UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.delegate        = self;
    table.dataSource      = self;
    table.backgroundColor = TSColor_Background;
    table.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
    table.separatorColor  = TSColor_Separator;
    table.separatorInset  = UIEdgeInsetsMake(0, 16, 0, 0);
    table.allowsMultipleSelectionDuringEditing = YES;
    if (@available(iOS 15.0, *)) {
        table.sectionHeaderTopPadding = 0;
    }
    self.sourceTableview = table;
    [self.view addSubview:self.sourceTableview];
}

- (void)ts_setupBottomToolbar {
    self.bottomToolbar = [[UIToolbar alloc] init];
    self.bottomToolbar.hidden = YES;

    UIBarButtonItem *flex = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    self.deleteButton = [[UIBarButtonItem alloc]
        initWithTitle:TSLocalizedString(@"general.delete") style:UIBarButtonItemStylePlain target:self action:@selector(ts_batchDelete)];
    self.deleteButton.tintColor = TSColor_Danger;
    self.deleteButton.enabled   = NO;

    self.bottomToolbar.items = @[flex, self.deleteButton, flex];
    [self.view addSubview:self.bottomToolbar];
}

- (void)ts_setupEmptyView {
    self.emptyView = [[TSEmptyAlarmView alloc] initWithFrame:self.view.bounds];
    self.emptyView.hidden = YES;
    [self.view addSubview:self.emptyView];
}

- (void)ts_registerCallback {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] alarmClock] registerAlarmClocksDidChangedBlock:^(NSArray<TSAlarmClockModel *> *alarms, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                TSLog(@"闹钟变化回调错误: %@", error);
                return;
            }
            weakSelf.alarms = [alarms mutableCopy];
            [weakSelf ts_refreshUI];
        });
    }];
}

#pragma mark - Data

- (void)ts_loadAlarms {
    self.maxCount = [[[TopStepComKit sharedInstance] alarmClock] supportMaxAlarmCount];
    if (self.maxCount <= 0) self.maxCount = 8;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] alarmClock] getAllAlarmClocksCompletion:^(NSArray<TSAlarmClockModel *> *alarms, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [weakSelf showAlertWithMsg:[NSString stringWithFormat:TSLocalizedString(@"alarm.load_failed_format"), error.localizedDescription]];
                return;
            }
            weakSelf.alarms = [alarms mutableCopy];
            [weakSelf ts_refreshUI];
        });
    }];
}

- (void)ts_refreshUI {
    [self.sourceTableview reloadData];

    BOOL isEmpty = (self.alarms.count == 0);
    self.emptyView.hidden = !isEmpty;
    self.editButton.enabled = !isEmpty;

    if (isEmpty && self.isEditMode) {
        [self ts_toggleEditMode];
    }
}

#pragma mark - Actions

- (void)ts_addAlarm {
    if (self.alarms.count >= self.maxCount) {
        [self showAlertWithMsg:[NSString stringWithFormat:TSLocalizedString(@"alarm.max_count_format"), (long)self.maxCount]];
        return;
    }

    [self ts_showAlarmEditor:nil];
}

- (void)ts_toggleEditMode {
    self.isEditMode = !self.isEditMode;
    [self.sourceTableview setEditing:self.isEditMode animated:YES];

    self.navigationItem.rightBarButtonItems = self.isEditMode
        ? @[self.doneButton]
        : @[self.addButton, self.editButton];

    self.bottomToolbar.hidden = !self.isEditMode;
    self.deleteButton.enabled = NO;

    // 刷新所有 cell 以更新 selectionStyle
    [self.sourceTableview reloadData];

    [UIView animateWithDuration:0.25 animations:^{
        [self viewDidLayoutSubviews];
    }];
}

- (void)ts_batchDelete {
    NSArray<NSIndexPath *> *selected = [self.sourceTableview indexPathsForSelectedRows];
    if (selected.count == 0) return;

    NSString *msg = [NSString stringWithFormat:TSLocalizedString(@"alarm.batch_delete_confirm_format"), (unsigned long)selected.count];
    UIAlertController *confirm = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"alarm.batch_delete")
                                                                     message:msg
                                                              preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [confirm addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        NSMutableArray<TSAlarmClockModel *> *alarmsToDelete = [NSMutableArray array];
        for (NSIndexPath *ip in selected) {
            if (ip.row < (NSInteger)weakSelf.alarms.count) {
                [alarmsToDelete addObject:weakSelf.alarms[ip.row]];
            }
        }

        // 全选：deleteAll 更高效
        if (alarmsToDelete.count == weakSelf.alarms.count) {
            [weakSelf ts_deleteAllAlarms];
        } else {
            [weakSelf ts_deleteAlarmsOneByOne:alarmsToDelete];
        }
    }]];
    [confirm addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:confirm animated:YES completion:nil];
}

- (void)ts_deleteAllAlarms {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] alarmClock] deleteAllAlarmClocksWithCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success || error) {
                [weakSelf showAlertWithMsg:[NSString stringWithFormat:TSLocalizedString(@"alarm.delete_failed_format"), error.localizedDescription ?: @""]];
            }
            [weakSelf ts_toggleEditMode];
            [weakSelf ts_loadAlarms];
        });
    }];
}

- (void)ts_deleteAlarmsOneByOne:(NSArray<TSAlarmClockModel *> *)alarmsToDelete {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger index = 0;
    __block NSError *firstError = nil;
    id<TSAlarmClockInterface> alarmClock = [[TopStepComKit sharedInstance] alarmClock];

    __block void (^deleteNext)(void);
    void (^finish)(void) = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (firstError) {
                [weakSelf showAlertWithMsg:[NSString stringWithFormat:TSLocalizedString(@"alarm.delete_failed_format"), firstError.localizedDescription]];
            }
            [weakSelf ts_toggleEditMode];
            [weakSelf ts_loadAlarms];
        });
    };
    deleteNext = ^{
        if (index >= alarmsToDelete.count) {
            finish();
            return;
        }
        TSAlarmClockModel *alarm = alarmsToDelete[index++];
        [alarmClock deleteAlarmClockWithId:alarm.alarmId completion:^(BOOL success, NSError *error) {
            if ((!success || error) && !firstError) {
                firstError = error ?: [NSError errorWithDomain:@"TSAlarmClockVC" code:-1 userInfo:nil];
            }
            deleteNext();
        }];
    };
    deleteNext();
}

#pragma mark - Alarm Editor

- (void)ts_showAlarmEditor:(TSAlarmClockModel *)alarm {
    TSAlarmEditorVC *editor = [[TSAlarmEditorVC alloc] init];
    editor.alarm    = alarm;
    editor.delegate = self;

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editor];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;

    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - TSAlarmEditorDelegate

- (void)alarmEditor:(TSAlarmEditorVC *)editor didSaveAlarm:(TSAlarmClockModel *)alarm {
    BOOL isNew = ![self.alarms containsObject:editor.alarm];
    __weak typeof(self) weakSelf = self;
    TSCompletionBlock completion = ^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success || error) {
                NSString *fmt = isNew ? TSLocalizedString(@"alarm.add_failed_format") : TSLocalizedString(@"alarm.update_failed_format");
                [weakSelf showAlertWithMsg:[NSString stringWithFormat:fmt, error.localizedDescription ?: @""]];
            }
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            [weakSelf ts_loadAlarms];
        });
    };

    id<TSAlarmClockInterface> alarmClock = [[TopStepComKit sharedInstance] alarmClock];
    if (isNew) {
        [alarmClock addAlarmClock:alarm completion:completion];
    } else {
        alarm.alarmId = editor.alarm.alarmId;
        [alarmClock updateAlarmClock:alarm completion:completion];
    }
}

- (void)alarmEditorDidCancel:(TSAlarmEditorVC *)editor {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:TSLocalizedString(@"alarm.added_count_format"),
            (unsigned long)self.alarms.count, (long)self.maxCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.alarms.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"kTSAlarmCell";
    TSAlarmCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[TSAlarmCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    TSAlarmClockModel *alarm = self.alarms[indexPath.row];
    [cell reloadWithAlarm:alarm];

    // 编辑模式下允许选中样式，非编辑模式下禁用
    cell.selectionStyle = self.isEditMode ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;

    __weak typeof(self) weakSelf = self;
    cell.onSwitchChanged = ^(BOOL isOn) {
        alarm.enable = isOn;
        [[[TopStepComKit sharedInstance] alarmClock] updateAlarmClock:alarm completion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!success || error) {
                    // 失败回滚
                    alarm.enable = !isOn;
                    [weakSelf showAlertWithMsg:[NSString stringWithFormat:TSLocalizedString(@"alarm.update_failed_format"), error.localizedDescription ?: @""]];
                    [weakSelf ts_refreshUI];
                }
            });
        }];
    };

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditMode) {
        self.deleteButton.enabled = ([tableView indexPathsForSelectedRows].count > 0);
        return;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self ts_showAlarmEditor:self.alarms[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditMode) {
        self.deleteButton.enabled = ([tableView indexPathsForSelectedRows].count > 0);
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    if (self.isEditMode) return nil;

    __weak typeof(self) weakSelf = self;
    UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                         title:TSLocalizedString(@"general.delete")
                                                                       handler:^(UIContextualAction *action, UIView *sourceView, void (^completion)(BOOL)) {
        if (indexPath.row >= (NSInteger)weakSelf.alarms.count) {
            completion(NO);
            return;
        }
        TSAlarmClockModel *alarm = weakSelf.alarms[indexPath.row];
        [[[TopStepComKit sharedInstance] alarmClock] deleteAlarmClockWithId:alarm.alarmId completion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!success || error) {
                    [weakSelf showAlertWithMsg:[NSString stringWithFormat:TSLocalizedString(@"alarm.delete_failed_format"), error.localizedDescription ?: @""]];
                    completion(NO);
                } else {
                    completion(YES);
                }
                [weakSelf ts_loadAlarms];
            });
        }];
    }];
    delete.backgroundColor = TSColor_Danger;

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[delete]];
    config.performsFirstActionWithFullSwipe = YES;
    return config;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 编辑模式下返回 None，配合 allowsMultipleSelectionDuringEditing 显示多选圆圈
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    // 编辑模式下不缩进，让多选圆圈正常显示
    return NO;
}

#pragma mark - Lazy

- (NSMutableArray<TSAlarmClockModel *> *)alarms {
    if (!_alarms) {
        _alarms = [NSMutableArray array];
    }
    return _alarms;
}

@end
