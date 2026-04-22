//
//  TSReminderEditorVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSReminderEditorVC.h"
#import "TSReminderRepeatVC.h"
#import "TSBaseVC.h"
#import "TSRootVC.h"

// ─── 工具函数 ────────────────────────────────────────────────────────────────

static NSDate *TSMinutesToDate(NSInteger minutes) {
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.hour   = minutes / 60;
    comp.minute = minutes % 60;
    return [[NSCalendar currentCalendar] dateFromComponents:comp];
}

static NSInteger TSDateToMinutes(NSDate *date) {
    NSDateComponents *comp = [[NSCalendar currentCalendar]
        components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    return comp.hour * 60 + comp.minute;
}

static NSString *TSMinStr(NSInteger minutes) {
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(minutes / 60), (long)(minutes % 60)];
}

static NSString *TSReminderDaysStr(TSRemindersRepeat d) {
    if (d == 0)                               return TSLocalizedString(@"repeat.never");
    if (d == TSRemindersRepeatEveryday)        return TSLocalizedString(@"repeat.everyday");
    if (d == TSRemindersRepeatWorkday)         return TSLocalizedString(@"repeat.weekday");
    if (d == TSRemindersRepeatWeekend)         return TSLocalizedString(@"repeat.weekend");
    NSMutableArray *arr = [NSMutableArray array];
    if (d & TSRemindersRepeatMonday)    [arr addObject:TSLocalizedString(@"reminder.week_short.mon")];
    if (d & TSRemindersRepeatTuesday)   [arr addObject:TSLocalizedString(@"reminder.week_short.tue")];
    if (d & TSRemindersRepeatWednesday) [arr addObject:TSLocalizedString(@"reminder.week_short.wed")];
    if (d & TSRemindersRepeatThursday)  [arr addObject:TSLocalizedString(@"reminder.week_short.thu")];
    if (d & TSRemindersRepeatFriday)    [arr addObject:TSLocalizedString(@"reminder.week_short.fri")];
    if (d & TSRemindersRepeatSaturday)  [arr addObject:TSLocalizedString(@"reminder.week_short.sat")];
    if (d & TSRemindersRepeatSunday)    [arr addObject:TSLocalizedString(@"reminder.week_short.sun")];
    return [NSString stringWithFormat:TSLocalizedString(@"reminder.week_format"), [arr componentsJoinedByString:TSLocalizedString(@"reminder.day_separator")]];
}

// ─── 行描述符 ────────────────────────────────────────────────────────────────

typedef NS_ENUM(NSInteger, TSEditorRowType) {
    TSEditorRow_Name,
    TSEditorRow_Enable,
    TSEditorRow_TimeSegment,
    TSEditorRow_TimePoint,         // index = time point array index
    TSEditorRow_TimePointPicker,   // index = time point array index
    TSEditorRow_AddTimePoint,
    TSEditorRow_PeriodStart,
    TSEditorRow_PeriodStartPicker,
    TSEditorRow_PeriodEnd,
    TSEditorRow_PeriodEndPicker,
    TSEditorRow_Interval,
    TSEditorRow_Repeat,
    TSEditorRow_DNDEnable,
    TSEditorRow_DNDStart,
    TSEditorRow_DNDStartPicker,
    TSEditorRow_DNDEnd,
    TSEditorRow_DNDEndPicker,
    TSEditorRow_Notes,
};

@interface TSEditorRowItem : NSObject
@property (nonatomic, assign) TSEditorRowType type;
@property (nonatomic, assign) NSInteger index;
+ (instancetype)row:(TSEditorRowType)type;
+ (instancetype)row:(TSEditorRowType)type index:(NSInteger)idx;
@end

@implementation TSEditorRowItem
+ (instancetype)row:(TSEditorRowType)type { return [TSEditorRowItem row:type index:0]; }
+ (instancetype)row:(TSEditorRowType)type index:(NSInteger)idx {
    TSEditorRowItem *item = [[TSEditorRowItem alloc] init];
    item.type  = type;
    item.index = idx;
    return item;
}
@end

// ─── 内联 Cell ────────────────────────────────────────────────────────────────

// 名称 Cell：UITextField 内联
@interface TSEditorNameCell : UITableViewCell
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UITextField *textField;
@end
@implementation TSEditorNameCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = TSColor_Card;

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font      = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = TSColor_TextPrimary;
        _titleLabel.text      = TSLocalizedString(@"reminder.name");
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_titleLabel];

        _textField = [[UITextField alloc] init];
        _textField.font            = [UIFont systemFontOfSize:17];
        _textField.textColor       = TSColor_TextSecondary;
        _textField.textAlignment   = NSTextAlignmentRight;
        _textField.placeholder     = TSLocalizedString(@"reminder.name_placeholder");
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.returnKeyType   = UIReturnKeyDone;
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_textField];

        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [_titleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_titleLabel.widthAnchor constraintEqualToConstant:60],

            [_textField.leadingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor constant:8],
            [_textField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_textField.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_textField.heightAnchor constraintEqualToConstant:44],
        ]];
    }
    return self;
}
@end

// Switch Cell
@interface TSEditorSwitchCell : UITableViewCell
@property (nonatomic, strong) UISwitch *toggle;
@property (nonatomic, copy) void(^onChanged)(BOOL isOn);
@end
@implementation TSEditorSwitchCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = TSColor_Card;
        self.textLabel.font      = [UIFont systemFontOfSize:17];
        self.textLabel.textColor = TSColor_TextPrimary;
        _toggle = [[UISwitch alloc] init];
        _toggle.onTintColor = TSColor_Primary;
        [_toggle addTarget:self action:@selector(onToggle:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = _toggle;
    }
    return self;
}
- (void)onToggle:(UISwitch *)sw {
    if (self.onChanged) self.onChanged(sw.isOn);
}
@end

// DatePicker Cell
@interface TSEditorPickerCell : UITableViewCell
@property (nonatomic, strong) UIDatePicker *picker;
@end
@implementation TSEditorPickerCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = TSColor_Card;
        _picker = [[UIDatePicker alloc] init];
        _picker.datePickerMode = UIDatePickerModeTime;
        if (@available(iOS 13.4, *)) {
            _picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        _picker.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_picker];
        [NSLayoutConstraint activateConstraints:@[
            [_picker.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [_picker.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
            [_picker.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [_picker.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        ]];
    }
    return self;
}
@end

// Segment Cell
@interface TSEditorSegmentCell : UITableViewCell
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, copy) void(^onChanged)(NSInteger index);
@end
@implementation TSEditorSegmentCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = TSColor_Card;
        _segment = [[UISegmentedControl alloc] initWithItems:@[TSLocalizedString(@"reminder.time_point"), TSLocalizedString(@"reminder.time_period")]];
        _segment.translatesAutoresizingMaskIntoConstraints = NO;
        [_segment addTarget:self action:@selector(onSegChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_segment];
        [NSLayoutConstraint activateConstraints:@[
            [_segment.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [_segment.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_segment.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        ]];
    }
    return self;
}
- (void)onSegChanged:(UISegmentedControl *)seg {
    if (self.onChanged) self.onChanged(seg.selectedSegmentIndex);
}
@end

// Notes Cell
@interface TSEditorNotesCell : UITableViewCell
@property (nonatomic, strong) UITextView *textView;
@end
@implementation TSEditorNotesCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = TSColor_Card;
        _textView = [[UITextView alloc] init];
        _textView.font        = [UIFont systemFontOfSize:15];
        _textView.textColor   = TSColor_TextPrimary;
        _textView.scrollEnabled = NO;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_textView];
        [NSLayoutConstraint activateConstraints:@[
            [_textView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
            [_textView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
            [_textView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12],
            [_textView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12],
            [_textView.heightAnchor constraintGreaterThanOrEqualToConstant:80],
        ]];
    }
    return self;
}
@end

// ─── TSReminderEditorVC ───────────────────────────────────────────────────────

static NSArray<NSNumber *> *kIntervalOptions;

@interface TSReminderEditorVC () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) TSRemindersModel *reminder;
@property (nonatomic, assign) BOOL              isNew;
@property (nonatomic, copy)   void(^completion)(BOOL didSave);

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<TSEditorRowItem *> *> *sections;

// 当前展开的 picker
@property (nonatomic, assign) TSEditorRowType activePickerType;  // -1 = none
@property (nonatomic, assign) NSInteger        activePickerIndex;

// 弱引用到当前激活的 DatePicker（用于获取值）
@property (nonatomic, weak) UIDatePicker *activeDatePicker;

@end

@implementation TSReminderEditorVC

- (instancetype)initWithReminder:(TSRemindersModel *)reminder
                           isNew:(BOOL)isNew
                      completion:(void(^)(BOOL))completion {
    self = [super init];
    if (self) {
        _reminder           = reminder;
        _isNew              = isNew;
        _completion         = completion;
        _activePickerType   = -1;
        _activePickerIndex  = 0;
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TSColor_Background;
    self.title = TSLocalizedString(@"reminder.edit_title");

    [self ts_setupNavBar];
    [self ts_setupTableView];
    [self ts_buildSections];
    [self.tableView reloadData];
}

#pragma mark - Setup

- (void)ts_setupNavBar {
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
        initWithTitle:TSLocalizedString(@"general.cancel")
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(ts_cancel)];

    UIBarButtonItem *save = [[UIBarButtonItem alloc]
        initWithTitle:TSLocalizedString(@"general.save")
                style:UIBarButtonItemStyleDone
               target:self
               action:@selector(ts_save)];

    self.navigationItem.leftBarButtonItem  = cancel;
    self.navigationItem.rightBarButtonItem = save;
}

- (void)ts_setupTableView {
    UITableViewStyle editorTableStyle = UITableViewStyleGrouped;
    if (@available(iOS 13.0, *)) {
        editorTableStyle = UITableViewStyleInsetGrouped;
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:editorTableStyle];
    self.tableView.delegate            = self;
    self.tableView.dataSource          = self;
    self.tableView.backgroundColor     = TSColor_Background;
    self.tableView.separatorColor      = TSColor_Separator;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self.tableView registerClass:[TSEditorNameCell    class] forCellReuseIdentifier:@"NameCell"];
    [self.tableView registerClass:[TSEditorSwitchCell  class] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerClass:[TSEditorPickerCell  class] forCellReuseIdentifier:@"PickerCell"];
    [self.tableView registerClass:[TSEditorSegmentCell class] forCellReuseIdentifier:@"SegmentCell"];
    [self.tableView registerClass:[TSEditorNotesCell   class] forCellReuseIdentifier:@"NotesCell"];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

#pragma mark - Row Model

- (void)ts_buildSections {
    // Section 0: 基本信息
    NSArray *s0 = @[[TSEditorRowItem row:TSEditorRow_Name],
                    [TSEditorRowItem row:TSEditorRow_Enable]];

    // Section 1: 时间设置
    NSMutableArray *s1 = [NSMutableArray array];
    [s1 addObject:[TSEditorRowItem row:TSEditorRow_TimeSegment]];

    if (self.reminder.timeType == TSReminderTimeTypePoint) {
        NSArray *pts = self.reminder.timePoints ?: @[];
        for (NSInteger i = 0; i < (NSInteger)pts.count; i++) {
            [s1 addObject:[TSEditorRowItem row:TSEditorRow_TimePoint index:i]];
            if (self.activePickerType == TSEditorRow_TimePointPicker && self.activePickerIndex == i) {
                [s1 addObject:[TSEditorRowItem row:TSEditorRow_TimePointPicker index:i]];
            }
        }
        [s1 addObject:[TSEditorRowItem row:TSEditorRow_AddTimePoint]];
    } else {
        [s1 addObject:[TSEditorRowItem row:TSEditorRow_PeriodStart]];
        if (self.activePickerType == TSEditorRow_PeriodStartPicker) {
            [s1 addObject:[TSEditorRowItem row:TSEditorRow_PeriodStartPicker]];
        }
        [s1 addObject:[TSEditorRowItem row:TSEditorRow_PeriodEnd]];
        if (self.activePickerType == TSEditorRow_PeriodEndPicker) {
            [s1 addObject:[TSEditorRowItem row:TSEditorRow_PeriodEndPicker]];
        }
        [s1 addObject:[TSEditorRowItem row:TSEditorRow_Interval]];
    }

    // Section 2: 重复日期
    NSArray *s2 = @[[TSEditorRowItem row:TSEditorRow_Repeat]];

    // Section 3: 午休免打扰
    NSMutableArray *s3 = [NSMutableArray array];
    [s3 addObject:[TSEditorRowItem row:TSEditorRow_DNDEnable]];
    if (self.reminder.isLunchBreakDNDEnabled) {
        [s3 addObject:[TSEditorRowItem row:TSEditorRow_DNDStart]];
        if (self.activePickerType == TSEditorRow_DNDStartPicker) {
            [s3 addObject:[TSEditorRowItem row:TSEditorRow_DNDStartPicker]];
        }
        [s3 addObject:[TSEditorRowItem row:TSEditorRow_DNDEnd]];
        if (self.activePickerType == TSEditorRow_DNDEndPicker) {
            [s3 addObject:[TSEditorRowItem row:TSEditorRow_DNDEndPicker]];
        }
    }

    // Section 4: 备注
    NSArray *s4 = @[[TSEditorRowItem row:TSEditorRow_Notes]];

    self.sections = @[s0, s1, s2, s3, s4];
}

- (TSEditorRowItem *)ts_rowItemAt:(NSIndexPath *)indexPath {
    if (indexPath.section >= (NSInteger)self.sections.count) return nil;
    NSArray *rows = self.sections[indexPath.section];
    if (indexPath.row >= (NSInteger)rows.count) return nil;
    return rows[indexPath.row];
}

// 查找某 rowType+index 的 IndexPath（返回 nil 如果不存在）
- (nullable NSIndexPath *)ts_indexPathForType:(TSEditorRowType)type index:(NSInteger)index {
    for (NSInteger s = 0; s < (NSInteger)self.sections.count; s++) {
        NSArray *rows = self.sections[s];
        for (NSInteger r = 0; r < (NSInteger)rows.count; r++) {
            TSEditorRowItem *item = rows[r];
            if (item.type == type && item.index == index) {
                return [NSIndexPath indexPathForRow:r inSection:s];
            }
        }
    }
    return nil;
}

#pragma mark - Picker Toggle

// 展开/收起 picker，带动画
- (void)ts_togglePickerForTimeRow:(TSEditorRowItem *)tappedItem {
    // 确定目标 picker 类型
    TSEditorRowType targetPickerType  = -1;
    NSInteger       targetPickerIndex = tappedItem.index;

    switch (tappedItem.type) {
        case TSEditorRow_TimePoint:   targetPickerType = TSEditorRow_TimePointPicker;   break;
        case TSEditorRow_PeriodStart: targetPickerType = TSEditorRow_PeriodStartPicker; break;
        case TSEditorRow_PeriodEnd:   targetPickerType = TSEditorRow_PeriodEndPicker;   break;
        case TSEditorRow_DNDStart:    targetPickerType = TSEditorRow_DNDStartPicker;    break;
        case TSEditorRow_DNDEnd:      targetPickerType = TSEditorRow_DNDEndPicker;      break;
        default: return;
    }

    BOOL same = (self.activePickerType == targetPickerType && self.activePickerIndex == targetPickerIndex);

    // 保存当前 picker 的路径（删除用）
    NSIndexPath *oldPickerPath = nil;
    if (self.activePickerType != (TSEditorRowType)-1) {
        oldPickerPath = [self ts_indexPathForType:self.activePickerType index:self.activePickerIndex];
    }

    if (same) {
        // 收起
        self.activePickerType  = -1;
        self.activePickerIndex = 0;
        [self ts_buildSections];
        if (oldPickerPath) {
            [self.tableView deleteRowsAtIndexPaths:@[oldPickerPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        NSIndexPath *newPickerPath = nil;

        [self.tableView beginUpdates];

        // 先移除旧 picker（在 sections 变化前获取路径）
        if (oldPickerPath) {
            self.activePickerType = -1;
            [self ts_buildSections];
            [self.tableView deleteRowsAtIndexPaths:@[oldPickerPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
        }

        // 再插入新 picker
        self.activePickerType  = targetPickerType;
        self.activePickerIndex = targetPickerIndex;
        [self ts_buildSections];
        newPickerPath = [self ts_indexPathForType:targetPickerType index:targetPickerIndex];
        if (newPickerPath) {
            [self.tableView insertRowsAtIndexPaths:@[newPickerPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
        }

        [self.tableView endUpdates];

        // 配置新 picker 的初始时间
        [self ts_configureDatePickerAtPath:newPickerPath];
        return;
    }
}

- (void)ts_configureDatePickerAtPath:(NSIndexPath *)path {
    if (!path) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        TSEditorPickerCell *cell = [self.tableView cellForRowAtIndexPath:path];
        if (!cell) return;
        TSEditorRowItem *item = [self ts_rowItemAt:path];
        if (!item) return;
        NSInteger minutes = [self ts_minutesForPickerType:item.type index:item.index];
        cell.picker.date = TSMinutesToDate(minutes);
    });
}

- (NSInteger)ts_minutesForPickerType:(TSEditorRowType)type index:(NSInteger)index {
    switch (type) {
        case TSEditorRow_TimePointPicker: {
            NSArray *pts = self.reminder.timePoints ?: @[];
            if (index < (NSInteger)pts.count) return [pts[index] integerValue];
            return 480;
        }
        case TSEditorRow_PeriodStartPicker:  return self.reminder.startTime;
        case TSEditorRow_PeriodEndPicker:    return self.reminder.endTime;
        case TSEditorRow_DNDStartPicker:     return self.reminder.lunchBreakDNDStartTime;
        case TSEditorRow_DNDEndPicker:       return self.reminder.lunchBreakDNDEndTime;
        default: return 480;
    }
}

#pragma mark - DatePicker Value Changed

- (void)ts_pickerValueChanged:(UIDatePicker *)picker {
    NSInteger minutes = TSDateToMinutes(picker.date);

    switch (self.activePickerType) {
        case TSEditorRow_TimePointPicker: {
            NSMutableArray *pts = [self.reminder.timePoints mutableCopy] ?: [NSMutableArray array];
            if (self.activePickerIndex < (NSInteger)pts.count) {
                pts[self.activePickerIndex] = @(minutes);
            }
            self.reminder.timePoints = [pts copy];
            // 刷新对应时间点行的标签
            NSIndexPath *ptPath = [self ts_indexPathForType:TSEditorRow_TimePoint index:self.activePickerIndex];
            if (ptPath) {
                [self.tableView reloadRowsAtIndexPaths:@[ptPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
        case TSEditorRow_PeriodStartPicker: {
            self.reminder.startTime = minutes;
            NSIndexPath *p = [self ts_indexPathForType:TSEditorRow_PeriodStart index:0];
            if (p) [self.tableView reloadRowsAtIndexPaths:@[p] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case TSEditorRow_PeriodEndPicker: {
            self.reminder.endTime = minutes;
            NSIndexPath *p = [self ts_indexPathForType:TSEditorRow_PeriodEnd index:0];
            if (p) [self.tableView reloadRowsAtIndexPaths:@[p] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case TSEditorRow_DNDStartPicker: {
            self.reminder.lunchBreakDNDStartTime = minutes;
            NSIndexPath *p = [self ts_indexPathForType:TSEditorRow_DNDStart index:0];
            if (p) [self.tableView reloadRowsAtIndexPaths:@[p] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case TSEditorRow_DNDEndPicker: {
            self.reminder.lunchBreakDNDEndTime = minutes;
            NSIndexPath *p = [self ts_indexPathForType:TSEditorRow_DNDEnd index:0];
            if (p) [self.tableView reloadRowsAtIndexPaths:@[p] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        default: break;
    }
}

#pragma mark - Interval Picker

- (void)ts_showIntervalPicker {
    NSArray<NSNumber *> *options = @[@5, @10, @15, @20, @30, @45, @60, @90, @120];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"reminder.interval")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSNumber *min in options) {
        NSString *title = min.integerValue < 60
            ? [NSString stringWithFormat:TSLocalizedString(@"reminder.minutes_format"), (long)min.integerValue]
            : [NSString stringWithFormat:TSLocalizedString(@"reminder.hours_format"), (long)(min.integerValue / 60)];
        __weak typeof(self) weakSelf = self;
        [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            weakSelf.reminder.interval = min.integerValue;
            NSIndexPath *p = [weakSelf ts_indexPathForType:TSEditorRow_Interval index:0];
            if (p) [weakSelf.tableView reloadRowsAtIndexPaths:@[p] withRowAnimation:UITableViewRowAnimationNone];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Actions

- (void)ts_cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)ts_save {
    // 基本校验
    if (self.reminder.reminderName.length == 0) {
        [self ts_showError:TSLocalizedString(@"reminder.error.name_required")];
        return;
    }
    if (self.reminder.timeType == TSReminderTimeTypePoint) {
        if (self.reminder.timePoints.count == 0) {
            [self ts_showError:TSLocalizedString(@"reminder.error.add_one_time")];
            return;
        }
    } else {
        if (self.reminder.startTime >= self.reminder.endTime) {
            [self ts_showError:TSLocalizedString(@"reminder.error.end_after_start")];
            return;
        }
        if (self.reminder.interval <= 0) {
            [self ts_showError:TSLocalizedString(@"reminder.error.interval_required")];
            return;
        }
        // 间隔不能超过时间段长度
        NSInteger duration = self.reminder.endTime - self.reminder.startTime;
        if (self.reminder.interval > duration) {
            [self ts_showError:TSLocalizedString(@"reminder.error.interval_exceeds_period")];
            return;
        }
    }
    // 午休免打扰时间校验
    if (self.reminder.isLunchBreakDNDEnabled) {
        if (self.reminder.lunchBreakDNDStartTime >= self.reminder.lunchBreakDNDEndTime) {
            [self ts_showError:TSLocalizedString(@"reminder.error.dnd_end_after_start")];
            return;
        }
    }

    // 显示菊花，禁用交互
    UIActivityIndicatorViewStyle spinnerStyle;
    if (@available(iOS 13.0, *)) {
        spinnerStyle = UIActivityIndicatorViewStyleMedium;
    } else {
        spinnerStyle = UIActivityIndicatorViewStyleGray;
    }
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:spinnerStyle];
    [spinner startAnimating];
    UIBarButtonItem *loadingItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    UIBarButtonItem *savedSaveItem = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = loadingItem;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.tableView.userInteractionEnabled = NO;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] reminder] setReminder:self.reminder
                                                completion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.navigationItem.rightBarButtonItem = savedSaveItem;
            weakSelf.navigationItem.leftBarButtonItem.enabled = YES;
            weakSelf.tableView.userInteractionEnabled = YES;
            if (isSuccess) {
                if (weakSelf.completion) weakSelf.completion(YES);
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            } else {
                [weakSelf ts_showError:error.localizedDescription ?: TSLocalizedString(@"reminder.save_failed")];
            }
        });
    }];
}

- (void)ts_deleteReminder {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"reminder.delete_title")
                                                                   message:TSLocalizedString(@"reminder.delete")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [[[TopStepComKit sharedInstance] reminder] deleteReminderWithId:weakSelf.reminder.reminderId
                                                             completion:^(BOOL isSuccess, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isSuccess) {
                    if (weakSelf.completion) weakSelf.completion(NO);
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [weakSelf ts_showError:error.localizedDescription ?: TSLocalizedString(@"reminder.delete_failed")];
                }
            });
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)ts_showError:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"general.hint")
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *headers = @[
        TSLocalizedString(@"reminder.section.basic"),
        TSLocalizedString(@"reminder.section.time"),
        TSLocalizedString(@"reminder.section.repeat"),
        TSLocalizedString(@"reminder.section.dnd"),
        TSLocalizedString(@"reminder.section.notes"),
    ];
    if (section < (NSInteger)headers.count) return headers[section];
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSEditorRowItem *item = [self ts_rowItemAt:indexPath];
    if (!item) return 44;
    switch (item.type) {
        case TSEditorRow_TimePointPicker:
        case TSEditorRow_PeriodStartPicker:
        case TSEditorRow_PeriodEndPicker:
        case TSEditorRow_DNDStartPicker:
        case TSEditorRow_DNDEndPicker:
            return 216;
        case TSEditorRow_Notes:
            return UITableViewAutomaticDimension;
        default:
            return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSEditorRowItem *item = [self ts_rowItemAt:indexPath];
    if (!item) return [[UITableViewCell alloc] init];

    switch (item.type) {
        case TSEditorRow_Name: {
            TSEditorNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NameCell" forIndexPath:indexPath];
            cell.textField.text = self.reminder.reminderName;
            cell.textField.delegate = self;
            return cell;
        }
        case TSEditorRow_Enable: {
            TSEditorSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
            cell.textLabel.text = TSLocalizedString(@"general.enable");
            cell.toggle.on = self.reminder.isEnabled;
            __weak typeof(self) weakSelf = self;
            cell.onChanged = ^(BOOL isOn) { weakSelf.reminder.enabled = isOn; };
            return cell;
        }
        case TSEditorRow_TimeSegment: {
            TSEditorSegmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentCell" forIndexPath:indexPath];
            cell.segment.selectedSegmentIndex = (self.reminder.timeType == TSReminderTimeTypePoint) ? 0 : 1;
            __weak typeof(self) weakSelf = self;
            cell.onChanged = ^(NSInteger idx) {
                [weakSelf ts_collapseActivePicker];
                weakSelf.reminder.timeType = (idx == 0) ? TSReminderTimeTypePoint : TSReminderTimeTypePeriod;
                [weakSelf ts_buildSections];
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            };
            return cell;
        }
        case TSEditorRow_TimePoint: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimePointCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TimePointCell"];
                cell.backgroundColor = TSColor_Card;
                cell.textLabel.font  = [UIFont systemFontOfSize:17];
                cell.textLabel.textColor = TSColor_TextPrimary;
            }
            cell.textLabel.text = [NSString stringWithFormat:TSLocalizedString(@"reminder.time_point_format"), (long)(item.index + 1)];
            NSArray *pts = self.reminder.timePoints ?: @[];
            if (item.index < (NSInteger)pts.count) {
                cell.detailTextLabel.text = TSMinStr([pts[item.index] integerValue]);
            }
            BOOL isExpanded = (self.activePickerType == TSEditorRow_TimePointPicker && self.activePickerIndex == item.index);
            cell.detailTextLabel.textColor = isExpanded ? TSColor_Primary : TSColor_TextSecondary;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
        case TSEditorRow_TimePointPicker:
        case TSEditorRow_PeriodStartPicker:
        case TSEditorRow_PeriodEndPicker:
        case TSEditorRow_DNDStartPicker:
        case TSEditorRow_DNDEndPicker: {
            TSEditorPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PickerCell" forIndexPath:indexPath];
            NSInteger minutes = [self ts_minutesForPickerType:item.type index:item.index];
            cell.picker.date = TSMinutesToDate(minutes);
            [cell.picker removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
            [cell.picker addTarget:self action:@selector(ts_pickerValueChanged:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
        case TSEditorRow_AddTimePoint: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddTimeCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddTimeCell"];
                cell.backgroundColor = TSColor_Card;
            }
            cell.textLabel.text      = TSLocalizedString(@"reminder.add_time");
            cell.textLabel.textColor = TSColor_Primary;
            cell.textLabel.font      = [UIFont systemFontOfSize:17];
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
        case TSEditorRow_PeriodStart: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PeriodStartCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PeriodStartCell"];
                cell.backgroundColor = TSColor_Card;
                cell.textLabel.font  = [UIFont systemFontOfSize:17];
                cell.textLabel.textColor = TSColor_TextPrimary;
            }
            cell.textLabel.text = TSLocalizedString(@"general.start_time");
            cell.detailTextLabel.text = TSMinStr(self.reminder.startTime);
            BOOL isExpanded = (self.activePickerType == TSEditorRow_PeriodStartPicker);
            cell.detailTextLabel.textColor = isExpanded ? TSColor_Primary : TSColor_TextSecondary;
            return cell;
        }
        case TSEditorRow_PeriodEnd: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PeriodEndCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PeriodEndCell"];
                cell.backgroundColor = TSColor_Card;
                cell.textLabel.font  = [UIFont systemFontOfSize:17];
                cell.textLabel.textColor = TSColor_TextPrimary;
            }
            cell.textLabel.text = TSLocalizedString(@"general.end_time");
            cell.detailTextLabel.text = TSMinStr(self.reminder.endTime);
            BOOL isExpanded = (self.activePickerType == TSEditorRow_PeriodEndPicker);
            cell.detailTextLabel.textColor = isExpanded ? TSColor_Primary : TSColor_TextSecondary;
            return cell;
        }
        case TSEditorRow_Interval: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IntervalCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"IntervalCell"];
                cell.backgroundColor = TSColor_Card;
                cell.textLabel.font  = [UIFont systemFontOfSize:17];
                cell.textLabel.textColor = TSColor_TextPrimary;
                cell.accessoryType   = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.textLabel.text = TSLocalizedString(@"general.interval");
            NSInteger interval = self.reminder.interval;
            if (interval <= 0) {
                cell.detailTextLabel.text = TSLocalizedString(@"general.not_set");
            } else if (interval < 60) {
                cell.detailTextLabel.text = [NSString stringWithFormat:TSLocalizedString(@"reminder.minutes_format"), (long)interval];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:TSLocalizedString(@"reminder.hours_format"), (long)(interval / 60)];
            }
            cell.detailTextLabel.textColor = TSColor_TextSecondary;
            return cell;
        }
        case TSEditorRow_Repeat: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepeatCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"RepeatCell"];
                cell.backgroundColor = TSColor_Card;
                cell.textLabel.font  = [UIFont systemFontOfSize:17];
                cell.textLabel.textColor = TSColor_TextPrimary;
                cell.accessoryType   = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.textLabel.text = TSLocalizedString(@"reminder.repeat");
            cell.detailTextLabel.text  = TSReminderDaysStr(self.reminder.repeatDays);
            cell.detailTextLabel.textColor = TSColor_TextSecondary;
            return cell;
        }
        case TSEditorRow_DNDEnable: {
            TSEditorSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
            cell.textLabel.text = TSLocalizedString(@"general.enable");
            cell.toggle.on = self.reminder.isLunchBreakDNDEnabled;
            __weak typeof(self) weakSelf = self;
            cell.onChanged = ^(BOOL isOn) {
                [weakSelf ts_collapseActivePicker];
                weakSelf.reminder.isLunchBreakDNDEnabled = isOn;
                [weakSelf ts_buildSections];
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:3]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            };
            return cell;
        }
        case TSEditorRow_DNDStart: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DNDStartCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DNDStartCell"];
                cell.backgroundColor = TSColor_Card;
                cell.textLabel.font  = [UIFont systemFontOfSize:17];
                cell.textLabel.textColor = TSColor_TextPrimary;
            }
            cell.textLabel.text = TSLocalizedString(@"general.start_time");
            cell.detailTextLabel.text = TSMinStr(self.reminder.lunchBreakDNDStartTime);
            BOOL isExpanded = (self.activePickerType == TSEditorRow_DNDStartPicker);
            cell.detailTextLabel.textColor = isExpanded ? TSColor_Primary : TSColor_TextSecondary;
            return cell;
        }
        case TSEditorRow_DNDEnd: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DNDEndCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DNDEndCell"];
                cell.backgroundColor = TSColor_Card;
                cell.textLabel.font  = [UIFont systemFontOfSize:17];
                cell.textLabel.textColor = TSColor_TextPrimary;
            }
            cell.textLabel.text = TSLocalizedString(@"general.end_time");
            cell.detailTextLabel.text = TSMinStr(self.reminder.lunchBreakDNDEndTime);
            BOOL isExpanded = (self.activePickerType == TSEditorRow_DNDEndPicker);
            cell.detailTextLabel.textColor = isExpanded ? TSColor_Primary : TSColor_TextSecondary;
            return cell;
        }
        case TSEditorRow_Notes: {
            TSEditorNotesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotesCell" forIndexPath:indexPath];
            cell.textView.text = self.reminder.notes;
            cell.textView.delegate = self;
            return cell;
        }
        default:
            return [[UITableViewCell alloc] init];
    }
}

// 底部删除按钮（仅已存在的自定义提醒）
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section != self.sections.count - 1) return nil;
    if (self.reminder.reminderType != TSReminderTypeCustom) return nil;
    if (self.isNew) return nil;

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 80)];
    footer.backgroundColor = [UIColor clearColor];

    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    deleteBtn.backgroundColor  = TSColor_Card;
    deleteBtn.layer.cornerRadius = TSRadius_MD;
    [deleteBtn setTitle:TSLocalizedString(@"reminder.delete") forState:UIControlStateNormal];
    [deleteBtn setTitleColor:TSColor_Danger forState:UIControlStateNormal];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    [deleteBtn addTarget:self action:@selector(ts_deleteReminder) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [footer addSubview:deleteBtn];

    [NSLayoutConstraint activateConstraints:@[
        [deleteBtn.leadingAnchor  constraintEqualToAnchor:footer.leadingAnchor  constant:20],
        [deleteBtn.trailingAnchor constraintEqualToAnchor:footer.trailingAnchor constant:-20],
        [deleteBtn.topAnchor      constraintEqualToAnchor:footer.topAnchor      constant:16],
        [deleteBtn.heightAnchor   constraintEqualToConstant:48],
    ]];

    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section != (NSInteger)(self.sections.count - 1)) return 0;
    if (self.reminder.reminderType != TSReminderTypeCustom) return 0;
    return self.isNew ? 0 : 80;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TSEditorRowItem *item = [self ts_rowItemAt:indexPath];
    if (!item) return;

    switch (item.type) {
        case TSEditorRow_TimePoint:
        case TSEditorRow_PeriodStart:
        case TSEditorRow_PeriodEnd:
        case TSEditorRow_DNDStart:
        case TSEditorRow_DNDEnd:
            [self ts_togglePickerForTimeRow:item];
            break;

        case TSEditorRow_AddTimePoint:
            [self ts_addTimePoint];
            break;

        case TSEditorRow_Interval:
            [self ts_showIntervalPicker];
            break;

        case TSEditorRow_Repeat:
            [self ts_showRepeatVC];
            break;

        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    TSEditorRowItem *item = [self ts_rowItemAt:indexPath];
    return item.type == TSEditorRow_TimePoint;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    TSEditorRowItem *item = [self ts_rowItemAt:indexPath];
    if (item.type != TSEditorRow_TimePoint) return;

    NSMutableArray *pts = [self.reminder.timePoints mutableCopy] ?: [NSMutableArray array];
    if (pts.count <= 1) {
        // 至少保留一个时间点，恢复 UI 状态
        [self ts_showError:TSLocalizedString(@"reminder.error.keep_one_time")];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    [self ts_collapseActivePicker];
    if (item.index < (NSInteger)pts.count) {
        [pts removeObjectAtIndex:item.index];
    }
    self.reminder.timePoints = [pts copy];
    [self ts_buildSections];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Time Point Management

- (void)ts_addTimePoint {
    NSMutableArray *pts = [self.reminder.timePoints mutableCopy] ?: [NSMutableArray array];
    [pts addObject:@(480)]; // 默认 08:00
    self.reminder.timePoints = [pts copy];

    [self ts_collapseActivePicker];
    [self ts_buildSections];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)ts_collapseActivePicker {
    self.activePickerType  = -1;
    self.activePickerIndex = 0;
}

#pragma mark - Repeat VC

- (void)ts_showRepeatVC {
    TSReminderRepeatVC *vc = [[TSReminderRepeatVC alloc] init];
    vc.selectedDays = self.reminder.repeatDays;
    __weak typeof(self) weakSelf = self;
    vc.onDaysChanged = ^(TSRemindersRepeat days) {
        weakSelf.reminder.repeatDays = days;
        NSIndexPath *p = [weakSelf ts_indexPathForType:TSEditorRow_Repeat index:0];
        if (p) {
            [weakSelf.tableView reloadRowsAtIndexPaths:@[p] withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.reminder.reminderName = textField.text;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.reminder.notes = textView.text;
    // 动态更新 cell 高度
    [UIView performWithoutAnimation:^{
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}

@end
