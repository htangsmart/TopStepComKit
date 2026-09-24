//
//  TSHsdHabitEditorVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdHabitEditorVC.h"

@interface TSHsdHabitEditorVC ()
@property (nonatomic, strong) TSHsdHabitModel *draft;
@property (nonatomic, strong) UIBarButtonItem *doneItem;
@end

/// 提醒默认值（新建习惯、以及固件下发 0 时的兜底）
static const NSInteger kTSHsdHabitDefaultRemindAdvance  = 5;    // 提前提醒，单位：分钟
static const NSInteger kTSHsdHabitDefaultRemindDuration = 30;   // 提醒时长，单位：秒

@implementation TSHsdHabitEditorVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.hue = [TSHsdDisplay hueHabit];
    self.usesDock = NO;
    self.showsReloadButton = NO;
}

- (void)viewDidLoad {
    if (self.habit) {
        self.draft = [self.habit copy];
        [self ts_fillRemindDefaultsIfNeeded];
        self.title = TSLocalizedString(@"hsd.habit.edit_title");
    } else {
        TSHsdHabitModel *h = [[TSHsdHabitModel alloc] init];
        h.habitId = self.nextHabitId;
        h.type = TSHsdHabitTypeSport;
        h.label = @"";
        h.minuteOfDay = 18 * 60;
        h.duration = 30;
        h.repeatOptions = TSAlarmRepeatEveryday;
        h.state = TSHsdHabitStateInit;
        h.taskDays = 21;
        h.associatedFunction = TSHsdHabitAssociatedFunctionNone;
        h.remindDuration = kTSHsdHabitDefaultRemindDuration;
        h.remindAdvance = kTSHsdHabitDefaultRemindAdvance;
        self.draft = h;
        self.title = TSLocalizedString(@"hsd.habit.new_title");
    }
    [super viewDidLoad];
}

/// 固件下发的习惯（如手表自带的「运动」）提醒字段为 0 时，填入 Demo 默认值；只改编辑草稿，点「完成」并保存后才会写回手表
- (void)ts_fillRemindDefaultsIfNeeded {
    if (self.draft.remindAdvance <= 0) { self.draft.remindAdvance = kTSHsdHabitDefaultRemindAdvance; }
    if (self.draft.remindDuration <= 0) { self.draft.remindDuration = kTSHsdHabitDefaultRemindDuration; }
}

- (void)setupViews {
    [super setupViews];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.cancel") style:UIBarButtonItemStylePlain target:self action:@selector(handleBack)];
    self.doneItem = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.done") style:UIBarButtonItemStyleDone target:self action:@selector(ts_done)];
    self.navigationItem.rightBarButtonItems = @[self.doneItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
}

- (void)reload {}

#pragma mark - 校验 / 完成

- (BOOL)ts_invalid {
    return self.draft.type == TSHsdHabitTypeCustom && [TSHsdDisplay utf8Length:self.draft.label] > TSHsdHabitLabelMaxBytes;
}

- (void)ts_refreshValidity { self.doneItem.enabled = ![self ts_invalid]; }

- (void)ts_done {
    [self dismissKeyboard];
    if ([self ts_invalid]) { return; }
    TSHsdHabitModel *result = [self.draft copy];
    self.dirty = NO;
    if (self.onDone) { self.onDone(result); }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)ts_changed {
    [self dismissKeyboard];
    self.dirty = YES;
    [self ts_refreshValidity];
    [self render];
}

- (void)ts_textChanged {
    self.dirty = YES;
    [self ts_refreshValidity];
}

#pragma mark - 数值滚轮配置（范围为 Demo 约定，§4.4）

/// 分钟数文字：45 分钟 / 1 小时 / 1 小时 30 分
+ (NSString *)ts_minutesText:(NSInteger)minutes {
    if (minutes >= 60 && minutes % 60 == 0) { return [NSString stringWithFormat:TSLocalizedString(@"hsd.duration.h_format"), (long)(minutes / 60)]; }
    if (minutes >= 60) { return [NSString stringWithFormat:TSLocalizedString(@"hsd.duration.hm_format"), (long)(minutes / 60), (long)(minutes % 60)]; }
    return [NSString stringWithFormat:TSLocalizedString(@"hsd.duration.m_format"), (long)minutes];
}

/// 秒数文字：30 秒 / 1 分钟 / 1 分 30 秒
+ (NSString *)ts_secondsText:(NSInteger)seconds {
    if (seconds >= 60 && seconds % 60 == 0) { return [NSString stringWithFormat:TSLocalizedString(@"hsd.duration.m_format"), (long)(seconds / 60)]; }
    if (seconds >= 60) { return [NSString stringWithFormat:TSLocalizedString(@"hsd.duration.ms_format"), (long)(seconds / 60), (long)(seconds % 60)]; }
    return [NSString stringWithFormat:TSLocalizedString(@"hsd.duration.s_format"), (long)seconds];
}

/// 快捷值文字
+ (NSArray<NSString *> *)ts_titlesForValues:(NSArray<NSNumber *> *)values text:(NSString * (^)(NSInteger value))text {
    NSMutableArray<NSString *> *titles = [NSMutableArray arrayWithCapacity:values.count];
    for (NSNumber *value in values) { [titles addObject:text(value.integerValue)]; }
    return titles;
}

/// 每次时长：时 + 分双列，1 分钟 – 10 小时
- (TSHsdValuePickConfig *)ts_durationConfig {
    TSHsdValuePickConfig *config = [[TSHsdValuePickConfig alloc] init];
    config.title = TSLocalizedString(@"hsd.habit.duration");
    config.hourMinute = YES;
    config.minValue = 1;
    config.maxValue = 600;
    config.quickValues = @[@15, @30, @45, @60, @90, @120];
    config.quickTitles = [TSHsdHabitEditorVC ts_titlesForValues:config.quickValues text:^NSString *(NSInteger v) { return [TSHsdHabitEditorVC ts_minutesText:v]; }];
    config.hintBlock = ^NSString *(NSInteger v) { return TSLocalizedString(@"hsd.habit.duration_hint"); };
    return config;
}

/// 任务天数：1 – 365 天
- (TSHsdValuePickConfig *)ts_taskDaysConfig {
    TSHsdValuePickConfig *config = [[TSHsdValuePickConfig alloc] init];
    config.title = TSLocalizedString(@"hsd.habit.task_days");
    config.minValue = 1;
    config.maxValue = 365;
    config.unit = TSLocalizedString(@"hsd.unit.days");
    config.quickValues = @[@7, @14, @21, @30, @66, @100];
    config.quickTitles = [TSHsdHabitEditorVC ts_titlesForValues:config.quickValues text:^NSString *(NSInteger v) { return [NSString stringWithFormat:TSLocalizedString(@"hsd.days_format"), (long)v]; }];
    config.hintBlock = ^NSString *(NSInteger v) {
        NSString *sub = TSLocalizedString(@"hsd.habit.task_days_sub");
        if (v < 7) { return sub; }
        NSString *weeks = v % 7 == 0 ? [NSString stringWithFormat:@"%ld", (long)(v / 7)] : [NSString stringWithFormat:@"%.1f", v / 7.0];
        return [NSString stringWithFormat:@"%@ · %@", [NSString stringWithFormat:TSLocalizedString(@"hsd.habit.weeks_format"), weeks], sub];
    };
    return config;
}

/// 提前提醒：0 – 120 分钟，0 显示「准时」
- (TSHsdValuePickConfig *)ts_remindAdvanceConfig {
    TSHsdValuePickConfig *config = [[TSHsdValuePickConfig alloc] init];
    config.title = TSLocalizedString(@"hsd.habit.remind_advance");
    config.minValue = 0;
    config.maxValue = 120;
    config.unit = TSLocalizedString(@"hsd.unit.minutes");
    config.zeroText = TSLocalizedString(@"hsd.habit.remind_on_time");
    config.quickValues = @[@0, @5, @10, @15, @30, @60];
    config.quickTitles = [TSHsdHabitEditorVC ts_titlesForValues:config.quickValues text:^NSString *(NSInteger v) {
        return v == 0 ? TSLocalizedString(@"hsd.habit.remind_on_time") : [TSHsdHabitEditorVC ts_minutesText:v];
    }];
    config.hintBlock = ^NSString *(NSInteger v) {
        return v == 0 ? TSLocalizedString(@"hsd.habit.remind_advance_hint_zero") : [NSString stringWithFormat:TSLocalizedString(@"hsd.habit.remind_advance_hint_format"), (long)v];
    };
    return config;
}

/// 提醒时长：0 – 300 秒
- (TSHsdValuePickConfig *)ts_remindDurationConfig {
    TSHsdValuePickConfig *config = [[TSHsdValuePickConfig alloc] init];
    config.title = TSLocalizedString(@"hsd.habit.remind_duration");
    config.minValue = 0;
    config.maxValue = 300;
    config.unit = TSLocalizedString(@"hsd.unit.seconds");
    config.quickValues = @[@10, @15, @30, @60, @120];
    config.quickTitles = [TSHsdHabitEditorVC ts_titlesForValues:config.quickValues text:^NSString *(NSInteger v) { return [TSHsdHabitEditorVC ts_secondsText:v]; }];
    config.hintBlock = ^NSString *(NSInteger v) {
        return [NSString stringWithFormat:TSLocalizedString(@"hsd.habit.remind_duration_hint_format"), [TSHsdHabitEditorVC ts_secondsText:v]];
    };
    return config;
}

#pragma mark - 积木

- (NSArray<UIView *> *)buildBlocks {
    TSHsdHabitModel *d = self.draft;
    __weak typeof(self) weakSelf = self;
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];

    // 类型
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.habit.sec.type") right:nil]];
    TSHsdSegView *typeSeg = [[TSHsdSegView alloc] init];
    typeSeg.insetInCard = YES;
    NSMutableArray<TSHsdSegItem *> *typeItems = [NSMutableArray array];
    for (NSInteger t = TSHsdHabitTypeCustom; t <= TSHsdHabitTypeSleep; t++) {
        [typeItems addObject:[TSHsdSegItem itemWithTitle:[TSHsdDisplay habitTypeName:t] symbol:[TSHsdDisplay symbolForHabitType:t]]];
    }
    typeSeg.items = typeItems;
    typeSeg.selectedIndex = MAX(0, MIN(3, d.type));
    typeSeg.onChange = ^(NSInteger index) {
        weakSelf.draft.type = index;
        if (index != TSHsdHabitTypeCustom) { weakSelf.draft.label = @""; }   // 预置类型：清空标签，避免隐藏标签参与校验与下发
        [weakSelf ts_changed];
    };
    NSMutableArray<UIView *> *typeRows = [NSMutableArray arrayWithObject:typeSeg];
    if (d.type == TSHsdHabitTypeCustom) {
        [typeRows addObject:[self fieldWithLabel:TSLocalizedString(@"hsd.habit.name") text:d.label maxBytes:TSHsdHabitLabelMaxBytes placeholder:TSLocalizedString(@"hsd.habit.name_ph")
                                        onChange:^(NSString *text) { weakSelf.draft.label = text; [weakSelf ts_textChanged]; }]];
    }
    [blocks addObject:[self card:typeRows]];
    [blocks addObject:[self foot:d.type == TSHsdHabitTypeCustom ? TSLocalizedString(@"hsd.habit.foot_custom") : TSLocalizedString(@"hsd.habit.foot_preset")]];

    // 计划
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.habit.sec.plan") right:nil]];
    [blocks addObject:[self card:@[
        [self timeRowWithTitle:TSLocalizedString(@"hsd.habit.exec_time") minute:d.minuteOfDay onPick:^(NSInteger minute) { weakSelf.draft.minuteOfDay = minute; [weakSelf ts_changed]; }],
        [self pickRowWithTitle:TSLocalizedString(@"hsd.habit.duration") subtitle:nil config:[self ts_durationConfig] value:d.duration onPick:^(NSInteger value) { weakSelf.draft.duration = value; [weakSelf ts_changed]; }],
        [self pickRowWithTitle:TSLocalizedString(@"hsd.habit.task_days") subtitle:TSLocalizedString(@"hsd.habit.task_days_sub") config:[self ts_taskDaysConfig] value:d.taskDays onPick:^(NSInteger value) { weakSelf.draft.taskDays = value; [weakSelf ts_changed]; }],
    ]]];
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.habit.foot_range")]];

    // 重复
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.repeat") right:[TSHsdDisplay repeatString:d.repeatOptions]]];
    [blocks addObject:[self card:@[[self weekdays:d.repeatOptions presets:[TSHsdWeekdayPreset taskPresets] onChange:^(TSAlarmRepeat repeat) { weakSelf.draft.repeatOptions = repeat; [weakSelf ts_changed]; }]]]];

    // 提醒
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.habit.sec.remind") right:nil]];
    [blocks addObject:[self card:@[
        [self pickRowWithTitle:TSLocalizedString(@"hsd.habit.remind_advance") subtitle:nil config:[self ts_remindAdvanceConfig] value:d.remindAdvance onPick:^(NSInteger value) { weakSelf.draft.remindAdvance = value; [weakSelf ts_changed]; }],
        [self pickRowWithTitle:TSLocalizedString(@"hsd.habit.remind_duration") subtitle:nil config:[self ts_remindDurationConfig] value:d.remindDuration onPick:^(NSInteger value) { weakSelf.draft.remindDuration = value; [weakSelf ts_changed]; }],
    ]]];

    // 关联功能
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.habit.sec.assoc") right:nil]];
    TSHsdSegView *assocSeg = [[TSHsdSegView alloc] init];
    assocSeg.insetInCard = YES;
    assocSeg.items = @[[TSHsdSegItem itemWithTitle:[TSHsdDisplay associatedFunctionName:TSHsdHabitAssociatedFunctionNone] symbol:nil],
                       [TSHsdSegItem itemWithTitle:[TSHsdDisplay associatedFunctionName:TSHsdHabitAssociatedFunctionSport] symbol:@"figure.run"]];
    assocSeg.selectedIndex = d.associatedFunction == TSHsdHabitAssociatedFunctionSport ? 1 : 0;
    assocSeg.onChange = ^(NSInteger index) { weakSelf.draft.associatedFunction = index; [weakSelf ts_changed]; };
    [blocks addObject:[self card:@[assocSeg]]];
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.habit.foot_assoc")]];

    // 手表维护 · 只读
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.sec.device_readonly") right:nil]];
    TSHsdRowView *stateRow = [self row];
    stateRow.title = TSLocalizedString(@"hsd.habit.state");
    stateRow.rightView = [self stateLabel:[TSHsdDisplay habitStateName:d.state] color:[TSHsdDisplay colorForHabitState:d.state]];
    TSHsdRowView *daysRow = [self row];
    daysRow.title = TSLocalizedString(@"hsd.habit.reach_max");
    TSHsdValueLabel *daysValue = [[TSHsdValueLabel alloc] init];
    daysValue.rounded = YES;
    daysValue.text = [NSString stringWithFormat:TSLocalizedString(@"hsd.habit.reach_max_format"), (long)d.reachGoalDays, (long)d.maxReachGoalDays];
    daysRow.rightView = daysValue;
    TSHsdRowView *latestRow = [self row];
    latestRow.title = TSLocalizedString(@"hsd.habit.latest");
    TSHsdValueLabel *latestValue = [[TSHsdValueLabel alloc] init];
    latestValue.text = d.latestAchieveGoalMonth ? [NSString stringWithFormat:TSLocalizedString(@"hsd.habit.latest_format"), (long)d.latestAchieveGoalMonth, (long)d.latestAchieveGoalDay] : TSLocalizedString(@"hsd.none");
    latestRow.rightView = latestValue;
    TSHsdRowView *weekRow = [self row];
    weekRow.title = TSLocalizedString(@"hsd.habit.past_week");
    TSHsdWeekDots *dots = [[TSHsdWeekDots alloc] init];
    dots.hue = self.hue;
    dots.mask = d.achieveGoalRepeat;
    weekRow.rightView = dots;
    TSHsdRowView *idRow = [self row];
    idRow.title = TSLocalizedString(@"hsd.habit.id");
    TSHsdValueLabel *idValue = [[TSHsdValueLabel alloc] init];
    idValue.mono = YES;
    idValue.text = [NSString stringWithFormat:@"%ld", (long)d.habitId];
    idRow.rightView = idValue;
    [blocks addObject:[self readOnlyGroup:@[stateRow, daysRow, latestRow, weekRow, idRow]]];

    if (self.habit) {
        TSHsdDangerLink *del = [[TSHsdDangerLink alloc] init];
        del.title = TSLocalizedString(@"hsd.habit.delete");
        del.onTap = ^{ [weakSelf ts_delete]; };
        [blocks addObject:del];
    }
    [self ts_refreshValidity];
    return blocks;
}

- (void)ts_delete {
    __weak typeof(self) weakSelf = self;
    [self confirmTitle:TSLocalizedString(@"hsd.habit.delete_confirm") message:TSLocalizedString(@"hsd.habit.delete_confirm_msg")
          confirmTitle:TSLocalizedString(@"general.delete") destructive:YES handler:^{
        weakSelf.dirty = NO;
        if (weakSelf.onDelete) { weakSelf.onDelete(); }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

@end
