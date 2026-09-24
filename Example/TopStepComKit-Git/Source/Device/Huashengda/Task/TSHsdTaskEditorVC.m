//
//  TSHsdTaskEditorVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdTaskEditorVC.h"
#import "TSAlarmTypePickerVC.h"

@interface TSHsdTaskEditorVC ()
@property (nonatomic, strong) TSHsdTaskModel *draft;
@property (nonatomic, strong) UIBarButtonItem *doneItem;
/// 持有输入框，避免输入过程中整页重建
@property (nonatomic, strong) TSHsdWatchPreview *preview;
@end

@implementation TSHsdTaskEditorVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.hue = [TSHsdDisplay hueTask];
    self.usesDock = NO;
    self.showsReloadButton = NO;
}

- (void)viewDidLoad {
    // 先准备草稿，再让基类 render
    if (self.task) {
        self.draft = [self.task copy];
        self.title = TSLocalizedString(@"hsd.task.edit_title");
    } else {
        TSHsdTaskModel *task = [[TSHsdTaskModel alloc] init];
        task.taskId = self.nextTaskId;
        task.minuteOfDay = 8 * 60;
        task.label = @"";
        task.enabled = YES;
        task.repeatOptions = TSAlarmRepeatEveryday;
        task.type = TSAlarmTypeDrinkWater;
        task.state = TSHsdTaskStateNotStarted;
        task.coins = 5;
        task.taskDescription = @"";
        task.timeEnabled = YES;
        self.draft = task;
        self.title = TSLocalizedString(@"hsd.task.new_title");
    }
    [super viewDidLoad];
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

- (void)reload {
    // 编辑页不读取设备
}

#pragma mark - 校验 / 完成

- (BOOL)ts_invalid {
    return [TSHsdDisplay utf8Length:self.draft.label] > TSHsdTaskLabelMaxBytes
        || [TSHsdDisplay utf8Length:self.draft.taskDescription] > TSHsdTaskDescriptionMaxBytes;
}

- (void)ts_refreshValidity {
    self.doneItem.enabled = ![self ts_invalid];
}

- (void)ts_done {
    [self dismissKeyboard];
    if ([self ts_invalid]) { return; }
    TSHsdTaskModel *result = [self.draft copy];
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

/// 文本输入只刷新预览与校验，不重建页面
- (void)ts_textChanged {
    self.dirty = YES;
    [self ts_refreshValidity];
    [self ts_updatePreview];
}

- (void)ts_updatePreview {
    TSHsdTaskModel *d = self.draft;
    self.preview.topLeft = d.isTimeEnabled ? [TSHsdDisplay timeStringForMinute:d.minuteOfDay] : @"";
    self.preview.topRight = TSLocalizedString(@"hsd.task.watch_tag");
    self.preview.bigSymbol = [TSAlarmTypeDisplay symbolNameForType:d.type];
    self.preview.name = d.label.length ? d.label : [TSAlarmTypeDisplay nameForType:d.type];
    self.preview.meta = d.taskDescription.length ? d.taskDescription : [TSHsdDisplay repeatString:d.repeatOptions];
    self.preview.coinText = [NSString stringWithFormat:TSLocalizedString(@"hsd.task.watch_coins_format"), (long)d.coins];
}

#pragma mark - 积木

- (NSArray<UIView *> *)buildBlocks {
    TSHsdTaskModel *d = self.draft;
    __weak typeof(self) weakSelf = self;
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];

    // 手表示意 + 类型
    if (!self.preview) { self.preview = [[TSHsdWatchPreview alloc] init]; }
    self.preview.hue = self.hue;
    [self ts_updatePreview];
    TSHsdRowView *typeRow = [self row];
    typeRow.symbol = [TSAlarmTypeDisplay symbolNameForType:d.type];
    typeRow.emoStyle = YES;
    typeRow.title = TSLocalizedString(@"hsd.task.type");
    TSHsdValueLabel *typeValue = [[TSHsdValueLabel alloc] init];
    typeValue.text = [TSAlarmTypeDisplay nameForType:d.type];
    typeRow.rightView = typeValue;
    typeRow.showsChevron = YES;
    typeRow.onTap = ^{ [weakSelf ts_openTypePicker]; };
    [blocks addObject:[self card:@[self.preview, typeRow]]];
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.task.foot_type")]];

    // 显示内容
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.task.sec.content") right:nil]];
    TSHsdFieldView *labelField = [self fieldWithLabel:TSLocalizedString(@"hsd.task.label") text:d.label maxBytes:TSHsdTaskLabelMaxBytes
                                          placeholder:TSLocalizedString(@"hsd.task.label_ph") onChange:^(NSString *text) { weakSelf.draft.label = text; [weakSelf ts_textChanged]; }];
    TSHsdFieldView *descField = [self fieldWithLabel:TSLocalizedString(@"hsd.task.desc") text:d.taskDescription maxBytes:TSHsdTaskDescriptionMaxBytes
                                         placeholder:TSLocalizedString(@"hsd.task.desc_ph") onChange:^(NSString *text) { weakSelf.draft.taskDescription = text; [weakSelf ts_textChanged]; }];
    [blocks addObject:[self card:@[labelField, descField]]];
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.task.foot_bytes")]];

    // 时间
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.task.sec.time") right:nil]];
    NSMutableArray<UIView *> *timeRows = [NSMutableArray array];
    [timeRows addObject:[self switchRowWithSymbol:nil color:nil title:TSLocalizedString(@"hsd.task.show_time") subtitle:TSLocalizedString(@"hsd.task.show_time_sub")
                                               on:d.isTimeEnabled onToggle:^(BOOL on) { weakSelf.draft.timeEnabled = on; [weakSelf ts_changed]; }]];
    if (d.isTimeEnabled) {
        [timeRows addObject:[self timeRowWithTitle:TSLocalizedString(@"hsd.task.exec_time") minute:d.minuteOfDay onPick:^(NSInteger minute) { weakSelf.draft.minuteOfDay = minute; [weakSelf ts_changed]; }]];
    }
    [blocks addObject:[self card:timeRows]];

    // 重复
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.repeat") right:[TSHsdDisplay repeatString:d.repeatOptions]]];
    [blocks addObject:[self card:@[[self weekdays:d.repeatOptions presets:[TSHsdWeekdayPreset taskPresets] onChange:^(TSAlarmRepeat repeat) { weakSelf.draft.repeatOptions = repeat; [weakSelf ts_changed]; }]]]];

    // 奖励
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.task.sec.reward") right:nil]];
    TSHsdRowView *coinRow = [self row];
    coinRow.symbol = @"dollarsign.circle.fill";
    coinRow.iconColor = [TSHsdDisplay hueTask];
    coinRow.title = TSLocalizedString(@"hsd.task.reward_coins");
    TSHsdStepperView *stepper = [[TSHsdStepperView alloc] init];
    stepper.minValue = 0; stepper.maxValue = 999; stepper.step = 1;
    stepper.value = d.coins;
    stepper.onChange = ^(NSInteger value) { weakSelf.draft.coins = value; weakSelf.dirty = YES; [weakSelf ts_updatePreview]; };
    coinRow.rightView = stepper;
    [blocks addObject:[self card:@[
        coinRow,
        [self switchRowWithSymbol:nil color:nil title:TSLocalizedString(@"hsd.task.enable") subtitle:nil on:d.isEnabled onToggle:^(BOOL on) { weakSelf.draft.enabled = on; weakSelf.dirty = YES; }]
    ]]];

    // 手表维护 · 只读
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.sec.device_readonly") right:nil]];
    TSHsdRowView *idRow = [self row];
    idRow.title = TSLocalizedString(@"hsd.task.id");
    TSHsdValueLabel *idValue = [[TSHsdValueLabel alloc] init];
    idValue.mono = YES;
    idValue.text = [NSString stringWithFormat:@"%ld", (long)d.taskId];
    idRow.rightView = idValue;
    TSHsdRowView *stateRow = [self row];
    stateRow.title = TSLocalizedString(@"hsd.task.today_state");
    stateRow.rightView = [self stateLabel:[TSHsdDisplay taskStateName:d.state] color:[TSHsdDisplay colorForTaskState:d.state]];
    [blocks addObject:[self readOnlyGroup:@[idRow, stateRow]]];

    if (self.task) {
        TSHsdDangerLink *del = [[TSHsdDangerLink alloc] init];
        del.title = TSLocalizedString(@"hsd.task.delete");
        del.onTap = ^{ [weakSelf ts_delete]; };
        [blocks addObject:del];
    }
    [self ts_refreshValidity];
    return blocks;
}

#pragma mark - 动作

- (void)ts_openTypePicker {
    [self dismissKeyboard];
    TSAlarmTypePickerVC *picker = [[TSAlarmTypePickerVC alloc] init];
    picker.selectedType = self.draft.type;
    picker.supportedTypes = self.supportedTypes;
    __weak typeof(self) weakSelf = self;
    picker.onTypeChanged = ^(TSAlarmType type) {
        if (type == weakSelf.draft.type) { return; }
        weakSelf.draft.type = type;
        [weakSelf ts_changed];
    };
    [self.navigationController pushViewController:picker animated:YES];
}

- (void)ts_delete {
    __weak typeof(self) weakSelf = self;
    [self confirmTitle:TSLocalizedString(@"hsd.task.delete_confirm") message:TSLocalizedString(@"hsd.task.delete_confirm_msg")
          confirmTitle:TSLocalizedString(@"general.delete") destructive:YES handler:^{
        weakSelf.dirty = NO;
        if (weakSelf.onDelete) { weakSelf.onDelete(); }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

@end
