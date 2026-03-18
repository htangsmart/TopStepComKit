//
//  TSBaseMonitorConfigVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseMonitorConfigVC.h"

// ─── 常量 ──────────────────────────────────────────────────────────────────

static const NSInteger kSectionEnable      = 0;
static const NSInteger kSectionSchedule    = 1;
static const NSInteger kExtraSectionOffset = 2;

typedef NS_ENUM(NSInteger, TSScheduleRow) {
    TSScheduleRowStartTime = 0,
    TSScheduleRowEndTime,
    TSScheduleRowInterval,
    TSScheduleRowCount
};

static NSString *TSMinutesToString(NSInteger m) {
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(m / 60), (long)(m % 60)];
}

// ─── Interface ─────────────────────────────────────────────────────────────

@interface TSBaseMonitorConfigVC ()

@property (nonatomic, assign, getter=isDirty)   BOOL dirty;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *saveIndicator;

// 时间选择器 bottom sheet 状态
@property (nonatomic, copy)   void (^timePickerCompletion)(NSInteger);
@property (nonatomic, strong) UIView       *pickerOverlay;
@property (nonatomic, strong) UIDatePicker *activeDatePicker;

@end

// ─── Implementation ────────────────────────────────────────────────────────

@implementation TSBaseMonitorConfigVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TSColor_Background;
    self.schedule = [[TSMonitorSchedule alloc] init];

    [self ts_setupNavBar];
    [self ts_setupTableView];
    [self ts_setupLoadingIndicator];

    [self ts_startLoading];
    [self ts_fetchConfig];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat top = 0;
    if (@available(iOS 11.0, *)) { top = self.view.safeAreaInsets.top; }

    self.tableView.frame = CGRectMake(0, top,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height - top);

    self.loadingIndicator.center = CGPointMake(self.view.bounds.size.width  / 2.f,
                                               self.view.bounds.size.height / 2.f);
}

#pragma mark - Setup

- (void)ts_setupNavBar {
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
        initWithTitle:TSLocalizedString(@"general.cancel") style:UIBarButtonItemStylePlain
               target:self action:@selector(ts_cancel)];

    self.saveButton = [[UIBarButtonItem alloc]
        initWithTitle:TSLocalizedString(@"general.save") style:UIBarButtonItemStyleDone
               target:self action:@selector(ts_save)];
    self.saveButton.enabled   = NO;
    self.saveButton.tintColor = TSColor_TextSecondary;

    self.navigationItem.leftBarButtonItem  = cancel;
    self.navigationItem.rightBarButtonItem = self.saveButton;
}

- (void)ts_setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStyleInsetGrouped];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = TSColor_Background;
    self.tableView.separatorColor  = TSColor_Separator;
    if (@available(iOS 15.0, *)) { self.tableView.sectionHeaderTopPadding = 8.f; }
    [self.view addSubview:self.tableView];
}

- (void)ts_setupLoadingIndicator {
    self.loadingIndicator = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];
}

#pragma mark - Loading

- (void)ts_startLoading {
    self.loading           = YES;
    self.tableView.hidden  = YES;
    self.saveButton.enabled = NO;
    [self.loadingIndicator startAnimating];
}

- (void)ts_stopLoading {
    self.loading          = NO;
    self.tableView.hidden = NO;
    [self.loadingIndicator stopAnimating];
}

#pragma mark - Dirty / Save Button

- (void)ts_markDirty {
    if (!self.dirty) {
        self.dirty = YES;
        self.saveButton.enabled   = YES;
        self.saveButton.tintColor = TSColor_Primary;
    }
}

#pragma mark - Subclass Hooks (abstract)

- (void)ts_fetchConfig {
    NSAssert(NO, @"%@ must override ts_fetchConfig", NSStringFromClass(self.class));
}

- (void)ts_pushConfig {
    NSAssert(NO, @"%@ must override ts_pushConfig", NSStringFromClass(self.class));
}

- (NSInteger)ts_numberOfExtraSections                                 { return 0; }
- (NSString *)ts_titleForExtraSection:(NSInteger)s                    { return @""; }
- (NSInteger)ts_numberOfRowsInExtraSection:(NSInteger)s               { return 0; }
- (UITableViewCell *)ts_cellForExtraSection:(NSInteger)s row:(NSInteger)r tableView:(UITableView *)tv {
    return [[UITableViewCell alloc] init];
}
- (void)ts_didSelectExtraSection:(NSInteger)s row:(NSInteger)r        {}

#pragma mark - Callbacks

- (void)ts_configDidLoad {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self ts_stopLoading];
        self.dirty            = NO;
        self.saveButton.enabled   = NO;
        self.saveButton.tintColor = TSColor_TextSecondary;
        [self.tableView reloadData];
    });
}

- (void)ts_configDidSave {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self ts_hideSavingIndicator];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)ts_configSaveFailed:(nullable NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self ts_hideSavingIndicator];
        self.saveButton.enabled   = YES;
        self.saveButton.tintColor = TSColor_Primary;
        NSString *msg = error.localizedDescription ?: TSLocalizedString(@"monitor.save_failed_retry");
        [self ts_showAlertMsg:msg];
    });
}

#pragma mark - Nav Actions

- (void)ts_cancel {
    if (!self.dirty) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:TSLocalizedString(@"general.discard_changes")
                         message:TSLocalizedString(@"monitor.unsaved_changes")
                  preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.discard")
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction *a) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.continue_editing")
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)ts_save {
    self.saveButton.enabled = NO;
    [self ts_showSavingIndicator];
    [self ts_pushConfig];
}

- (void)ts_showSavingIndicator {
    if (!self.saveIndicator) {
        self.saveIndicator = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    }
    [self.saveIndicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithCustomView:self.saveIndicator];
}

- (void)ts_hideSavingIndicator {
    [self.saveIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem = self.saveButton;
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kExtraSectionOffset + [self ts_numberOfExtraSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kSectionEnable)   return 1;
    if (section == kSectionSchedule) return TSScheduleRowCount;
    return [self ts_numberOfRowsInExtraSection:section - kExtraSectionOffset];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == kSectionEnable)   return TSLocalizedString(@"monitor.section_auto");
    if (section == kSectionSchedule) return TSLocalizedString(@"monitor.section_schedule");
    return [self ts_titleForExtraSection:section - kExtraSectionOffset];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionEnable) {
        return [self ts_enableCellForTableView:tableView];
    }
    if (indexPath.section == kSectionSchedule) {
        return [self ts_scheduleCellForRow:indexPath.row tableView:tableView];
    }
    return [self ts_cellForExtraSection:indexPath.section - kExtraSectionOffset
                                    row:indexPath.row
                              tableView:tableView];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kSectionEnable)   return;
    if (indexPath.section == kSectionSchedule) {
        [self ts_handleScheduleRowTap:indexPath.row];
        return;
    }
    [self ts_didSelectExtraSection:indexPath.section - kExtraSectionOffset
                               row:indexPath.row];
}

#pragma mark - Enable Cell

- (UITableViewCell *)ts_enableCellForTableView:(UITableView *)tableView {
    static NSString *cellID = @"kTSMonitorEnableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        cell.textLabel.text  = TSLocalizedString(@"monitor.enable");
        cell.textLabel.font  = [UIFont systemFontOfSize:16.f];
        cell.textLabel.textColor = TSColor_TextPrimary;

        UISwitch *sw = [[UISwitch alloc] init];
        sw.onTintColor = TSColor_Primary;
        sw.tag         = 1001;
        [sw addTarget:self action:@selector(ts_enableSwitchChanged:)
     forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;
    }
    UISwitch *sw = (UISwitch *)[cell viewWithTag:1001];
    [sw setOn:self.schedule.isEnabled animated:NO];
    return cell;
}

- (void)ts_enableSwitchChanged:(UISwitch *)sw {
    self.schedule.enabled = sw.isOn;
    [self ts_markDirty];
}

#pragma mark - Schedule Cells

- (UITableViewCell *)ts_scheduleCellForRow:(NSInteger)row tableView:(UITableView *)tableView {
    static NSString *cellID = @"kTSScheduleCell";
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
    switch (row) {
        case TSScheduleRowStartTime:
            cell.textLabel.text       = TSLocalizedString(@"general.start_time");
            cell.detailTextLabel.text = TSMinutesToString(self.schedule.startTime);
            break;
        case TSScheduleRowEndTime:
            cell.textLabel.text       = TSLocalizedString(@"general.end_time");
            cell.detailTextLabel.text = TSMinutesToString(self.schedule.endTime);
            break;
        case TSScheduleRowInterval:
            cell.textLabel.text       = TSLocalizedString(@"monitor.detect_interval");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d 分钟",
                                         self.schedule.interval];
            break;
    }
    return cell;
}

- (void)ts_handleScheduleRowTap:(NSInteger)row {
    __weak typeof(self) weakSelf = self;
    if (row == TSScheduleRowStartTime) {
        [self ts_showTimePickerWithMinutes:self.schedule.startTime completion:^(NSInteger m) {
            weakSelf.schedule.startTime = (UInt16)m;
            [weakSelf ts_markDirty];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSectionSchedule]
                              withRowAnimation:UITableViewRowAnimationNone];
        }];
    } else if (row == TSScheduleRowEndTime) {
        [self ts_showTimePickerWithMinutes:self.schedule.endTime completion:^(NSInteger m) {
            weakSelf.schedule.endTime = (UInt16)m;
            [weakSelf ts_markDirty];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSectionSchedule]
                              withRowAnimation:UITableViewRowAnimationNone];
        }];
    } else if (row == TSScheduleRowInterval) {
        [self ts_showIntervalPickerWithCurrent:self.schedule.interval completion:^(NSInteger v) {
            weakSelf.schedule.interval = (UInt16)v;
            [weakSelf ts_markDirty];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSectionSchedule]
                              withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
}

#pragma mark - Time Picker (bottom sheet)

- (void)ts_showTimePickerWithMinutes:(NSInteger)currentMinutes
                          completion:(void (^)(NSInteger))completion {
    self.timePickerCompletion = completion;

    UIWindow *window   = self.view.window;
    CGFloat screenW    = window.bounds.size.width;
    CGFloat screenH    = window.bounds.size.height;
    CGFloat safeBottom = 0;
    if (@available(iOS 11.0, *)) { safeBottom = window.safeAreaInsets.bottom; }
    CGFloat containerH = 44.f + 216.f + safeBottom;

    // 半透明遮罩
    UIView *overlay = [[UIView alloc] initWithFrame:window.bounds];
    overlay.backgroundColor = [UIColor clearColor];
    overlay.tag = 9988;
    [window addSubview:overlay];
    self.pickerOverlay = overlay;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self action:@selector(ts_cancelTimePicker)];
    [overlay addGestureRecognizer:tap];

    // 白色容器（顶部圆角）
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, screenH, screenW, containerH)];
    container.backgroundColor       = TSColor_Card;
    container.layer.cornerRadius    = TSRadius_LG;
    container.layer.maskedCorners   = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    container.tag = 9989;
    [overlay addSubview:container];

    // 工具栏
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, 44.f)];
    UIView *sep     = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5f, screenW, 0.5f)];
    sep.backgroundColor = TSColor_Separator;
    [toolbar addSubview:sep];

    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(16.f, 0, 60.f, 44.f);
    [cancelBtn setTitle:TSLocalizedString(@"general.cancel") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:TSColor_TextSecondary forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(ts_cancelTimePicker)
        forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:cancelBtn];

    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    doneBtn.frame = CGRectMake(screenW - 76.f, 0, 60.f, 44.f);
    [doneBtn setTitle:TSLocalizedString(@"general.done") forState:UIControlStateNormal];
    [doneBtn setTitleColor:TSColor_Primary forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(ts_confirmTimePicker)
      forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:doneBtn];

    [container addSubview:toolbar];

    // UIDatePicker
    UIDatePicker *picker = [[UIDatePicker alloc] init];
    picker.datePickerMode  = UIDatePickerModeTime;
    picker.backgroundColor = TSColor_Card;
    if (@available(iOS 13.4, *)) {
        picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    picker.frame = CGRectMake(0, 44.f, screenW, 216.f);

    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.hour   = currentMinutes / 60;
    comp.minute = currentMinutes % 60;
    picker.date = [[NSCalendar currentCalendar] dateFromComponents:comp];
    [container addSubview:picker];
    self.activeDatePicker = picker;

    // 动画滑入
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
        container.frame = CGRectMake(0, screenH - containerH, screenW, containerH);
    } completion:nil];
}

- (void)ts_cancelTimePicker  { [self ts_dismissTimePickerSave:NO];  }
- (void)ts_confirmTimePicker { [self ts_dismissTimePickerSave:YES]; }

- (void)ts_dismissTimePickerSave:(BOOL)save {
    UIView  *overlay    = self.pickerOverlay;
    UIView  *container  = [overlay viewWithTag:9989];
    CGFloat  screenH    = overlay.bounds.size.height;
    CGFloat  containerH = container.bounds.size.height;

    NSInteger newMinutes = 0;
    if (save && self.activeDatePicker) {
        NSCalendarUnit units = NSCalendarUnitHour | NSCalendarUnitMinute;
        NSDateComponents *comp = [[NSCalendar currentCalendar]
            components:units fromDate:self.activeDatePicker.date];
        newMinutes = comp.hour * 60 + comp.minute;
    }
    void (^completion)(NSInteger) = self.timePickerCompletion;

    [UIView animateWithDuration:0.25f animations:^{
        overlay.backgroundColor = [UIColor clearColor];
        container.frame = CGRectMake(0, screenH, container.bounds.size.width, containerH);
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
        self.pickerOverlay        = nil;
        self.activeDatePicker     = nil;
        self.timePickerCompletion = nil;
        if (save && completion) completion(newMinutes);
    }];
}

#pragma mark - Interval Picker (action sheet)

- (void)ts_showIntervalPickerWithCurrent:(NSInteger)current
                              completion:(void (^)(NSInteger))completion {
    NSArray<NSNumber *> *options = @[@5, @10, @15, @20, @30];
    UIAlertController *sheet = [UIAlertController
        alertControllerWithTitle:TSLocalizedString(@"monitor.detect_interval") message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];

    for (NSNumber *opt in options) {
        NSInteger v     = opt.integerValue;
        NSString *title = (v == current)
            ? [NSString stringWithFormat:@"%ld 分钟  ✓", (long)v]
            : [NSString stringWithFormat:@"%ld 分钟", (long)v];
        [sheet addAction:[UIAlertAction actionWithTitle:title
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *a) {
            if (completion) completion(v);
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark - Number Input

- (void)ts_showNumberInputWithTitle:(NSString *)title
                          unitLabel:(NSString *)unit
                       currentValue:(NSInteger)value
                               minV:(NSInteger)minV
                               maxV:(NSInteger)maxV
                         completion:(void (^)(NSInteger))completion {
    NSString *msg = [NSString stringWithFormat:@"范围：%ld – %ld %@",
                     (long)minV, (long)maxV, unit];
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:title message:msg
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.text         = [NSString stringWithFormat:@"%ld", (long)value];
        tf.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *a) {
        NSInteger v = [alert.textFields.firstObject.text integerValue];
        v = MAX(minV, MIN(maxV, v));
        if (completion) completion(v);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Alert Helper

- (void)ts_showAlertMsg:(NSString *)msg {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:TSLocalizedString(@"general.hint") message:msg
                  preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
