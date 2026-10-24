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
    if (d == 0)                               return TSLocalizedString(@"reminder.repeat_unselected");
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

// 编辑和提交都使用独立副本，保存失败时保留各模式草稿。
static TSRemindersModel *TSReminderCopy(TSRemindersModel *source) {
    TSRemindersModel *copy = [[TSRemindersModel alloc] init];
    copy.reminderId = source.reminderId;
    copy.reminderName = source.reminderName;
    copy.enabled = source.isEnabled;
    copy.reminderType = source.reminderType;
    copy.repeatDays = source.repeatDays;
    copy.timeType = source.timeType;
    copy.startTime = source.startTime;
    copy.endTime = source.endTime;
    copy.interval = source.interval;
    copy.timePoints = source.timePoints;
    copy.notes = source.notes;
    copy.isLunchBreakDNDEnabled = source.isLunchBreakDNDEnabled;
    copy.lunchBreakDNDStartTime = source.lunchBreakDNDStartTime;
    copy.lunchBreakDNDEndTime = source.lunchBreakDNDEndTime;
    return copy;
}

// 界面模式独立于 SDK 的时间类型。
typedef NS_ENUM(NSInteger, TSReminderEditorTimeMode) {
    TSReminderEditorTimeModeAllDay,
    TSReminderEditorTimeModePeriod,
    TSReminderEditorTimeModePoint
};

static BOOL TSReminderMinuteIsValid(NSInteger minutes) {
    return minutes >= 0 && minutes < 1440;
}

// 非整小时仍按分钟显示，避免 90 分钟显示成 1 小时。
static NSString *TSReminderIntervalText(NSInteger minutes) {
    if (minutes <= 0) return TSLocalizedString(@"general.not_set");
    NSString *format = minutes % 60 == 0 ? @"reminder.hours_format" : @"reminder.minutes_format";
    return [NSString stringWithFormat:TSLocalizedString(format), (long)(minutes % 60 == 0 ? minutes / 60 : minutes)];
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
    TSEditorRow_Summary,
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
        _picker.locale = [NSLocale localeWithLocaleIdentifier:@"en_GB"];
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
        _segment = [[UISegmentedControl alloc] initWithItems:@[
            TSLocalizedString(@"reminder.all_day"),
            TSLocalizedString(@"reminder.time_period"),
            TSLocalizedString(@"reminder.time_point")
        ]];
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

@interface TSReminderEditorVC () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) TSRemindersModel *reminder;
@property (nonatomic, assign) BOOL              isNew;
@property (nonatomic, copy)   void(^completion)(BOOL didSave);

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<NSArray<TSEditorRowItem *> *> *sections;

// 时间段和时间点保存在编辑副本中，全天单独保存间隔。
@property (nonatomic, assign) TSReminderEditorTimeMode timeMode;
@property (nonatomic, assign) NSInteger allDayInterval;

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
        // 编辑独立副本，取消或保存失败时不影响列表中的原模型。
        _reminder = TSReminderCopy(reminder);
        _timeMode = reminder.timeType == TSReminderTimeTypePoint
            ? TSReminderEditorTimeModePoint : TSReminderEditorTimeModePeriod;
        if (reminder.timeType == TSReminderTimeTypePeriod && reminder.startTime == 0 && reminder.endTime == 1440) {
            _timeMode = TSReminderEditorTimeModeAllDay;
        }
        _allDayInterval = _timeMode == TSReminderEditorTimeModeAllDay
            ? reminder.interval : (reminder.interval > 0 ? reminder.interval : 15);
        // 只为尚无配置的其他模式提供初始草稿，不修正当前模式的设备值。
        if (_timeMode != TSReminderEditorTimeModePoint && _reminder.timePoints.count == 0) {
            _reminder.timePoints = @[@480];
        }
        if (_timeMode == TSReminderEditorTimeModePoint && _reminder.startTime == 0 && _reminder.endTime == 0) {
            _reminder.startTime = 540;
            _reminder.endTime = 1080;
            _reminder.interval = 15;
        }

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

    if (self.timeMode == TSReminderEditorTimeModePoint) {
        NSArray *pts = self.reminder.timePoints ?: @[];
        for (NSInteger i = 0; i < (NSInteger)pts.count; i++) {
            [s1 addObject:[TSEditorRowItem row:TSEditorRow_TimePoint index:i]];
            if (self.activePickerType == TSEditorRow_TimePointPicker && self.activePickerIndex == i) {
                [s1 addObject:[TSEditorRowItem row:TSEditorRow_TimePointPicker index:i]];
            }
        }
        [s1 addObject:[TSEditorRowItem row:TSEditorRow_AddTimePoint]];
    } else if (self.timeMode == TSReminderEditorTimeModePeriod) {
        [s1 addObject:[TSEditorRowItem row:TSEditorRow_PeriodStart]];
        if (self.activePickerType == TSEditorRow_PeriodStartPicker) {
            [s1 addObject:[TSEditorRowItem row:TSEditorRow_PeriodStartPicker]];
        }
        [s1 addObject:[TSEditorRowItem row:TSEditorRow_PeriodEnd]];
        if (self.activePickerType == TSEditorRow_PeriodEndPicker) {
            [s1 addObject:[TSEditorRowItem row:TSEditorRow_PeriodEndPicker]];
        }
        [s1 addObject:[TSEditorRowItem row:TSEditorRow_Interval]];
    } else {
        [s1 addObject:[TSEditorRowItem row:TSEditorRow_Interval]];
    }
    [s1 addObject:[TSEditorRowItem row:TSEditorRow_Summary]];

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

// 模式和免打扰共用展开状态，统一刷新两个分区以移除旧 picker。
- (void)ts_reloadTimeSections {
    [self ts_collapseActivePicker];
    [self ts_buildSections];
    NSMutableIndexSet *sections = [NSMutableIndexSet indexSetWithIndex:1];
    [sections addIndex:3];
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
}

// 切换只改变选中的模式，各模式草稿保持不变。
- (void)ts_selectTimeMode:(TSReminderEditorTimeMode)mode {
    if (mode < TSReminderEditorTimeModeAllDay || mode > TSReminderEditorTimeModePoint) return;
    self.timeMode = mode;
    [self ts_reloadTimeSections];
}

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
        if (![cell isKindOfClass:[TSEditorPickerCell class]]) return;
        TSEditorRowItem *item = [self ts_rowItemAt:path];
        if (!item || item.type != self.activePickerType || item.index != self.activePickerIndex) return;
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
        // UIDatePicker 用 00:00 展示午夜，模型保留当天结束边界 24:00。
        case TSEditorRow_PeriodEndPicker:    return self.reminder.endTime == 1440 ? 0 : self.reminder.endTime;
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
            // 仅时间段结束时间将午夜解释为当天结束，时间点及午休仍使用 0 分钟。
            self.reminder.endTime = minutes == 0 ? 1440 : minutes;
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
    [self ts_refreshScheduleFeedback];
}

#pragma mark - Interval Picker

// 全天和时间段各自保留间隔。
- (NSInteger)ts_selectedInterval {
    return self.timeMode == TSReminderEditorTimeModeAllDay ? self.allDayInterval : self.reminder.interval;
}

- (void)ts_showIntervalPicker {
    NSArray<NSNumber *> *options = @[@5, @10, @15, @20, @30, @45, @60, @90, @120];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"reminder.interval")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSNumber *minutes in options) {
        NSString *title = TSReminderIntervalText(minutes.integerValue);
        __weak typeof(self) weakSelf = self;
        [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (weakSelf.timeMode == TSReminderEditorTimeModeAllDay) {
                weakSelf.allDayInterval = minutes.integerValue;
            } else {
                weakSelf.reminder.interval = minutes.integerValue;
            }
            NSIndexPath *intervalPath = [weakSelf ts_indexPathForType:TSEditorRow_Interval index:0];
            if (intervalPath) [weakSelf.tableView reloadRowsAtIndexPaths:@[intervalPath] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf ts_refreshScheduleFeedback];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    NSIndexPath *intervalPath = [self ts_indexPathForType:TSEditorRow_Interval index:0];
    alert.popoverPresentationController.sourceView = self.tableView;
    alert.popoverPresentationController.sourceRect = intervalPath
        ? [self.tableView rectForRowAtIndexPath:intervalPath] : self.tableView.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

// 只提示与午休时段的重叠，不删除用户选择的时间点。
- (BOOL)ts_timePointOverlapsDND:(NSInteger)minutes {
    return self.reminder.isLunchBreakDNDEnabled &&
        self.reminder.lunchBreakDNDStartTime < self.reminder.lunchBreakDNDEndTime &&
        minutes >= self.reminder.lunchBreakDNDStartTime &&
        minutes < self.reminder.lunchBreakDNDEndTime;
}

// 摘要反映当前模式及共用设置，不读取其他模式草稿。
- (NSString *)ts_scheduleSummary {
    NSMutableArray<NSString *> *lines = [NSMutableArray array];
    if (!self.reminder.isEnabled) [lines addObject:TSLocalizedString(@"reminder.summary_disabled")];
    if (self.timeMode == TSReminderEditorTimeModePoint) {
        NSMutableArray<NSString *> *times = [NSMutableArray array];
        NSMutableArray<NSString *> *overlappingTimes = [NSMutableArray array];
        for (NSNumber *minutes in self.reminder.timePoints) {
            [times addObject:TSMinStr(minutes.integerValue)];
            if ([self ts_timePointOverlapsDND:minutes.integerValue]) {
                [overlappingTimes addObject:TSMinStr(minutes.integerValue)];
            }
        }
        [lines addObject:times.count > 0
            ? [NSString stringWithFormat:TSLocalizedString(@"reminder.summary_points"), [times componentsJoinedByString:TSLocalizedString(@"reminder.day_separator")]]
            : TSLocalizedString(@"reminder.error.add_one_time")];
        if (overlappingTimes.count > 0) {
            NSString *warningKey = overlappingTimes.count == times.count
                ? @"reminder.dnd_all_points_warning" : @"reminder.dnd_points_warning";
            [lines addObject:[NSString stringWithFormat:@"%@ · %@", [overlappingTimes componentsJoinedByString:TSLocalizedString(@"reminder.day_separator")], TSLocalizedString(warningKey)]];
        }
    } else if (self.timeMode == TSReminderEditorTimeModeAllDay) {
        [lines addObject:[NSString stringWithFormat:TSLocalizedString(@"reminder.summary_all_day"),
            TSReminderIntervalText(self.allDayInterval)]];
    } else {
        [lines addObject:[NSString stringWithFormat:TSLocalizedString(@"reminder.summary_period"),
            TSMinStr(self.reminder.startTime), TSMinStr(self.reminder.endTime),
            TSReminderIntervalText(self.reminder.interval)]];
    }
    [lines addObject:TSReminderDaysStr(self.reminder.repeatDays)];
    if (self.reminder.isLunchBreakDNDEnabled) {
        [lines addObject:[NSString stringWithFormat:TSLocalizedString(@"reminder.summary_dnd"),
            TSMinStr(self.reminder.lunchBreakDNDStartTime), TSMinStr(self.reminder.lunchBreakDNDEndTime)]];
    }
    return [lines componentsJoinedByString:@"\n"];
}

// 更新摘要及时间点提示，避免刷新正在滚动的时间选择器。
- (void)ts_refreshScheduleFeedback {
    NSMutableArray<NSIndexPath *> *paths = [NSMutableArray array];
    NSIndexPath *summaryPath = [self ts_indexPathForType:TSEditorRow_Summary index:0];
    if (summaryPath) [paths addObject:summaryPath];
    if (self.timeMode == TSReminderEditorTimeModePoint) {
        for (NSInteger i = 0; i < (NSInteger)self.reminder.timePoints.count; i++) {
            NSIndexPath *pointPath = [self ts_indexPathForType:TSEditorRow_TimePoint index:i];
            if (pointPath) [paths addObject:pointPath];
        }
    }
    if (paths.count > 0) {
        [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Actions

- (void)ts_cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)ts_save {
    [self.view endEditing:YES];
    NSString *validationMessage = nil;
    TSRemindersModel *submission = [self ts_reminderForSavingWithError:&validationMessage];
    if (!submission) {
        [self ts_showError:validationMessage];
        return;
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
    [[[TopStepComKit sharedInstance] reminder] setReminder:submission
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

// 仅校验当前模式及共用字段，隐藏模式的未完成草稿不阻塞保存。
- (nullable NSString *)ts_validationMessage {
    if ([self.reminder.reminderName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return TSLocalizedString(@"reminder.error.name_required");
    }
    if (self.timeMode == TSReminderEditorTimeModePoint) {
        if (self.reminder.timePoints.count == 0) {
            return TSLocalizedString(@"reminder.error.add_one_time");
        }
        if (self.reminder.timePoints.count > [self ts_maxTimePointCount]) {
            return [NSString stringWithFormat:TSLocalizedString(@"reminder.error.time_limit"), (long)[self ts_maxTimePointCount]];
        }
        NSMutableSet<NSNumber *> *seenMinutes = [NSMutableSet set];
        for (NSNumber *timePoint in self.reminder.timePoints) {
            if (![timePoint isKindOfClass:[NSNumber class]] || !TSReminderMinuteIsValid(timePoint.integerValue) ||
                timePoint.doubleValue != timePoint.integerValue) {
                return TSLocalizedString(@"reminder.error.invalid_time");
            }
            NSNumber *minutes = @(timePoint.integerValue);
            if ([seenMinutes containsObject:minutes]) {
                return TSLocalizedString(@"reminder.error.duplicate_time");
            }
            [seenMinutes addObject:minutes];
        }
    } else if (self.timeMode == TSReminderEditorTimeModePeriod) {
        if (!TSReminderMinuteIsValid(self.reminder.startTime) || self.reminder.endTime < 0 || self.reminder.endTime > 1440) {
            return TSLocalizedString(@"reminder.error.invalid_period_time");
        }
        if (self.reminder.startTime >= self.reminder.endTime) {
            return TSLocalizedString(@"reminder.error.end_after_start");
        }
        if (self.reminder.interval <= 0) {
            return TSLocalizedString(@"reminder.error.interval_required");
        }
        if (self.reminder.interval > self.reminder.endTime - self.reminder.startTime) {
            return TSLocalizedString(@"reminder.error.interval_exceeds_period");
        }
    } else if (self.allDayInterval <= 0) {
        return TSLocalizedString(@"reminder.error.interval_required");
    } else if (self.allDayInterval > 1440) {
        return TSLocalizedString(@"reminder.error.interval_exceeds_period");
    }
    if (self.reminder.isLunchBreakDNDEnabled) {
        if (!TSReminderMinuteIsValid(self.reminder.lunchBreakDNDStartTime) ||
            !TSReminderMinuteIsValid(self.reminder.lunchBreakDNDEndTime)) {
            return TSLocalizedString(@"reminder.error.invalid_time");
        }
        if (self.reminder.lunchBreakDNDStartTime >= self.reminder.lunchBreakDNDEndTime) {
            return TSLocalizedString(@"reminder.error.dnd_end_after_start");
        }
    }
    return nil;
}

// 生成提交快照，不排序或清空编辑草稿，失败后仍可切换模式继续编辑。
- (nullable TSRemindersModel *)ts_reminderForSavingWithError:(NSString * _Nullable * _Nullable)message {
    NSString *validationMessage = [self ts_validationMessage];
    if (message) *message = validationMessage;
    if (validationMessage) return nil;
    TSRemindersModel *submission = TSReminderCopy(self.reminder);
    if (self.timeMode == TSReminderEditorTimeModePoint) {
        submission.timeType = TSReminderTimeTypePoint;
        submission.timePoints = [self.reminder.timePoints sortedArrayUsingSelector:@selector(compare:)];
        submission.startTime = 0;
        submission.endTime = 0;
        submission.interval = 0;
    } else {
        submission.timeType = TSReminderTimeTypePeriod;
        submission.timePoints = @[];
        if (self.timeMode == TSReminderEditorTimeModeAllDay) {
            // 全天复用时间段协议，固定覆盖 00:00–24:00，并使用独立的全天间隔。
            submission.startTime = 0;
            submission.endTime = 1440;
            submission.interval = self.allDayInterval;
        }
    }
    return submission;
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
        case TSEditorRow_Summary:
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
            cell.onChanged = ^(BOOL isOn) {
                weakSelf.reminder.enabled = isOn;
                [weakSelf ts_refreshScheduleFeedback];
            };
            return cell;
        }
        case TSEditorRow_TimeSegment: {
            TSEditorSegmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentCell" forIndexPath:indexPath];
            cell.segment.selectedSegmentIndex = self.timeMode;
            __weak typeof(self) weakSelf = self;
            cell.onChanged = ^(NSInteger index) {
                [weakSelf ts_selectTimeMode:(TSReminderEditorTimeMode)index];
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
            BOOL overlapsDND = item.index < (NSInteger)pts.count && [self ts_timePointOverlapsDND:[pts[item.index] integerValue]];
            cell.detailTextLabel.textColor = overlapsDND ? TSColor_Warning : (isExpanded ? TSColor_Primary : TSColor_TextSecondary);
            cell.accessibilityValue = overlapsDND
                ? [NSString stringWithFormat:@"%@, %@", cell.detailTextLabel.text, TSLocalizedString(@"reminder.time_in_dnd")]
                : cell.detailTextLabel.text;
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
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AddTimeCell"];
                cell.backgroundColor = TSColor_Card;
            }
            cell.textLabel.text      = TSLocalizedString(@"reminder.add_time");
            BOOL canAdd = self.reminder.timePoints.count < [self ts_maxTimePointCount];
            cell.textLabel.textColor = canAdd ? TSColor_Primary : TSColor_TextSecondary;
            cell.textLabel.font      = [UIFont systemFontOfSize:17];
            NSUInteger limit = [self ts_maxTimePointCount];
            cell.detailTextLabel.text = limit < 1440
                ? [NSString stringWithFormat:@"%lu / %lu", (unsigned long)self.reminder.timePoints.count, (unsigned long)limit]
                : [NSString stringWithFormat:@"%lu", (unsigned long)self.reminder.timePoints.count];
            cell.detailTextLabel.textColor = TSColor_TextSecondary;
            cell.selectionStyle = canAdd ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = canAdd;
            cell.accessibilityTraits = canAdd ? UIAccessibilityTraitButton : (UIAccessibilityTraitButton | UIAccessibilityTraitNotEnabled);
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
            cell.detailTextLabel.text = TSReminderIntervalText([self ts_selectedInterval]);
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
                weakSelf.reminder.isLunchBreakDNDEnabled = isOn;
                [weakSelf ts_reloadTimeSections];
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
        case TSEditorRow_Summary: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SummaryCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SummaryCell"];
                cell.backgroundColor = TSColor_Card;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
                cell.textLabel.textColor = TSColor_TextSecondary;
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
                cell.detailTextLabel.textColor = TSColor_TextSecondary;
                cell.detailTextLabel.numberOfLines = 0;
            }
            cell.textLabel.text = TSLocalizedString(@"reminder.summary_title");
            cell.detailTextLabel.text = [self ts_scheduleSummary];
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
    return item && item.type == TSEditorRow_TimePoint && self.reminder.timePoints.count > 1;
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
    if (item.index < (NSInteger)pts.count) {
        [pts removeObjectAtIndex:item.index];
    }
    self.reminder.timePoints = [pts copy];
    [self ts_reloadTimeSections];
}

#pragma mark - Time Point Management

// NPK 协议明确限制 10 个；其他平台仅以一天可用的分钟数限制本地草稿。
- (NSUInteger)ts_maxTimePointCount {
    return [TopStepComKit sharedInstance].kitOption.sdkType == eTSSDKTypeTPB ? 10 : 1440;
}

- (void)ts_addTimePoint {
    NSMutableArray<NSNumber *> *points = [self.reminder.timePoints mutableCopy] ?: [NSMutableArray array];
    NSUInteger limit = [self ts_maxTimePointCount];
    if (points.count >= limit) {
        [self ts_showError:[NSString stringWithFormat:TSLocalizedString(@"reminder.error.time_limit"), (long)limit]];
        return;
    }
    NSSet<NSNumber *> *occupiedMinutes = [NSSet setWithArray:points];
    NSInteger lastMinute = points.lastObject.integerValue;
    NSInteger suggestedMinute = points.count > 0 && TSReminderMinuteIsValid(lastMinute) ? (lastMinute + 60) % 1440 : 480;
    for (NSInteger i = 0; i < 1440; i++) {
        NSNumber *candidate = @((suggestedMinute + i) % 1440);
        if ([occupiedMinutes containsObject:candidate]) continue;
        [points addObject:candidate];
        self.reminder.timePoints = points;
        [self ts_reloadTimeSections];
        return;
    }
    [self ts_showError:TSLocalizedString(@"reminder.error.no_free_time")];
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
        [weakSelf ts_refreshScheduleFeedback];
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
