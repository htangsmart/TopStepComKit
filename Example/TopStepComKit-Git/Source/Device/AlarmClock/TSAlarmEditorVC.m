//
//  TSAlarmEditorVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSAlarmEditorVC.h"
#import "TSAlarmRepeatVC.h"
#import "TSBaseVC.h"

// ─── 重复规则转文字 ────────────────────────────────────────────────────────
static NSString *TSRepeatDisplayString(TSAlarmRepeat repeat) {
    if (repeat == TSAlarmRepeatNone) return TSLocalizedString(@"repeat.never");
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

// ─── 设置项 Cell ───────────────────────────────────────────────────────────
@interface TSAlarmSettingCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation TSAlarmSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.backgroundColor = TSColor_Card;
    self.selectionStyle  = UITableViewCellSelectionStyleDefault;
    self.accessoryType   = UITableViewCellAccessoryDisclosureIndicator;

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font      = [UIFont systemFontOfSize:17];
    self.titleLabel.textColor = TSColor_TextPrimary;
    [self.contentView addSubview:self.titleLabel];

    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font          = [UIFont systemFontOfSize:17];
    self.detailLabel.textColor     = TSColor_TextSecondary;
    self.detailLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.detailLabel];

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.contentView.bounds.size.width;
    CGFloat h = self.contentView.bounds.size.height;

    self.titleLabel.frame  = CGRectMake(16, 0, 100, h);
    self.detailLabel.frame = CGRectMake(120, 0, w - 120 - 40, h);
}

@end

// ─── TSAlarmEditorVC ───────────────────────────────────────────────────────
typedef NS_ENUM(NSInteger, TSAlarmEditorRow) {
    TSAlarmEditorRowRepeat = 0,
    TSAlarmEditorRowLabel,
    TSAlarmEditorRowCount
};

@interface TSAlarmEditorVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) UIDatePicker *timePicker;
@property (nonatomic, strong) UITableView  *tableView;
@property (nonatomic, strong) TSAlarmClockModel *editingAlarm;
@end

@implementation TSAlarmEditorVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TSColor_Background;

    // 如果是新建，创建默认闹钟
    if (!self.alarm) {
        self.editingAlarm = [[TSAlarmClockModel alloc] init];
        [self.editingAlarm setHour:8 minute:0];
        self.editingAlarm.isOn = YES;
        self.editingAlarm.repeatOptions = TSAlarmRepeatNone;
    } else {
        // 编辑模式，复制一份避免直接修改原对象
        self.editingAlarm = [[TSAlarmClockModel alloc] init];
        self.editingAlarm.alarmId = self.alarm.alarmId;
        [self.editingAlarm setHour:[self.alarm hour] minute:[self.alarm minute]];
        self.editingAlarm.label = self.alarm.label;
        self.editingAlarm.isOn = self.alarm.isOn;
        self.editingAlarm.repeatOptions = self.alarm.repeatOptions;
        self.editingAlarm.snoozeEnable = self.alarm.snoozeEnable;
    }

    [self ts_setupNavBar];
    [self ts_setupTimePicker];
    [self ts_setupTableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat topOffset = 0;
    if (@available(iOS 11.0, *)) {
        topOffset = self.view.safeAreaInsets.top;
    }

    CGFloat pickerH = 216.f;
    self.timePicker.frame = CGRectMake(0, topOffset, self.view.bounds.size.width, pickerH);
    self.tableView.frame  = CGRectMake(0, topOffset + pickerH,
                                       self.view.bounds.size.width,
                                       self.view.bounds.size.height - topOffset - pickerH);
}

#pragma mark - Setup

- (void)ts_setupNavBar {
    self.title = self.alarm ? TSLocalizedString(@"alarm.edit") : TSLocalizedString(@"alarm.add");

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.cancel")
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(ts_cancel)];

    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"alarm.save_btn")
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(ts_save)];

    self.navigationItem.leftBarButtonItem  = cancel;
    self.navigationItem.rightBarButtonItem = save;
}

- (void)ts_setupTimePicker {
    self.timePicker = [[UIDatePicker alloc] init];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    self.timePicker.backgroundColor = TSColor_Card;

    if (@available(iOS 13.4, *)) {
        self.timePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }

    // 设置初始时间
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.hour   = [self.editingAlarm hour];
    comp.minute = [self.editingAlarm minute];
    self.timePicker.date = [[NSCalendar currentCalendar] dateFromComponents:comp];

    [self.timePicker addTarget:self action:@selector(ts_timeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.timePicker];
}

- (void)ts_setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = TSColor_Background;
    self.tableView.separatorColor  = TSColor_Separator;

    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }

    [self.view addSubview:self.tableView];
}

#pragma mark - Actions

- (void)ts_timeChanged:(UIDatePicker *)picker {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute)
                                                             fromDate:picker.date];
    [self.editingAlarm setHour:comp.hour minute:comp.minute];
}

- (void)ts_cancel {
    if ([self.delegate respondsToSelector:@selector(alarmEditorDidCancel:)]) {
        [self.delegate alarmEditorDidCancel:self];
    }
}

- (void)ts_save {
    // 如果是新建，需要设置 alarmId
    if (!self.alarm) {
        // alarmId 由外部设置
    }

    if ([self.delegate respondsToSelector:@selector(alarmEditor:didSaveAlarm:)]) {
        [self.delegate alarmEditor:self didSaveAlarm:self.editingAlarm];
    }
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TSAlarmEditorRowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == TSAlarmEditorRowRepeat) {
        static NSString *cellID = @"kTSAlarmSettingCell";
        TSAlarmSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[TSAlarmSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.titleLabel.text  = TSLocalizedString(@"alarm.repeat");
        cell.detailLabel.text = TSRepeatDisplayString(self.editingAlarm.repeatOptions);
        return cell;

    } else if (indexPath.row == TSAlarmEditorRowLabel) {
        static NSString *cellID = @"kTSAlarmLabelCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.backgroundColor = TSColor_Card;
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;

            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 80, 44)];
            titleLabel.font      = [UIFont systemFontOfSize:17];
            titleLabel.textColor = TSColor_TextPrimary;
            titleLabel.text      = TSLocalizedString(@"alarm.label");
            titleLabel.tag       = 100;
            [cell.contentView addSubview:titleLabel];

            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 0, 44)];
            textField.font                 = [UIFont systemFontOfSize:17];
            textField.textColor            = TSColor_TextPrimary;
            textField.placeholder          = TSLocalizedString(@"alarm.default_name");
            textField.clearButtonMode      = UITextFieldViewModeWhileEditing;
            textField.returnKeyType        = UIReturnKeyDone;
            textField.delegate             = self;
            textField.tag                  = 101;
            [cell.contentView addSubview:textField];
        }

        UITextField *textField = [cell.contentView viewWithTag:101];
        textField.text = self.editingAlarm.label;

        // 动态计算 textField 宽度
        CGFloat w = tableView.bounds.size.width;
        if (@available(iOS 11.0, *)) {
            w -= tableView.safeAreaInsets.left + tableView.safeAreaInsets.right;
        }
        textField.frame = CGRectMake(100, 0, w - 100 - 32, 44);

        return cell;
    }

    return [[UITableViewCell alloc] init];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == TSAlarmEditorRowRepeat) {
        [self ts_showRepeatPicker];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.editingAlarm.label = textField.text;
}

#pragma mark - Repeat Picker

- (void)ts_showRepeatPicker {
    TSAlarmRepeatVC *repeatVC = [[TSAlarmRepeatVC alloc] init];
    repeatVC.selectedRepeat = self.editingAlarm.repeatOptions;

    __weak typeof(self) weakSelf = self;
    repeatVC.onRepeatChanged = ^(TSAlarmRepeat repeat) {
        weakSelf.editingAlarm.repeatOptions = repeat;
        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:TSAlarmEditorRowRepeat inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationNone];
    };

    [self.navigationController pushViewController:repeatVC animated:YES];
}

@end
