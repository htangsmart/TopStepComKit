//
//  TSHsdParentalControlItemVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdParentalControlItemVC.h"

/// 新增时段的默认开始 / 结束（18:00 – 20:00）
static const NSInteger kTSHsdParentalPeriodDefaultStart = 18 * 60;
static const NSInteger kTSHsdParentalPeriodDefaultEnd = 20 * 60;

@interface TSHsdParentalControlItemVC ()
/// 编辑草稿（onDone 交回其副本）
@property (nonatomic, strong) TSHsdParentalControlItemModel *draft;
/// 右上角「完成」
@property (nonatomic, strong) UIBarButtonItem *doneItem;
@end

@implementation TSHsdParentalControlItemVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.hue = [TSHsdDisplay hueParental];
    self.usesDock = NO;
    self.showsReloadButton = NO;
    self.maxPeriodCount = TSHsdParentalControlPeriodMaxCount;
}

- (void)viewDidLoad {
    if (self.item) {
        self.draft = [self.item copy];
    } else {
        TSHsdParentalControlItemModel *item = [[TSHsdParentalControlItemModel alloc] init];
        item.function = self.function;
        item.enabled = YES;
        item.mode = TSHsdParentalControlModeDisableInPeriod;
        item.periods = @[];
        self.draft = item;
    }
    self.draft.function = self.function;
    if (!self.draft.periods) { self.draft.periods = @[]; }
    self.title = [TSHsdDisplay parentalFunctionName:self.function];
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

- (void)reload {}

#pragma mark - 校验 / 完成

/// 时段数超过上限或分钟越界时不可完成
- (BOOL)ts_invalid {
    if (self.draft.periods.count > self.maxPeriodCount) { return YES; }
    for (TSHsdParentalControlPeriodModel *period in self.draft.periods) {
        if (period.startMinute < 0 || period.startMinute >= TSHsdMinutesPerDay ||
            period.endMinute < 0 || period.endMinute >= TSHsdMinutesPerDay) { return YES; }
    }
    return NO;
}

- (void)ts_refreshValidity { self.doneItem.enabled = ![self ts_invalid]; }

- (void)ts_done {
    if ([self ts_invalid]) { return; }
    TSHsdParentalControlItemModel *result = [self.draft copy];
    self.dirty = NO;
    if (self.onDone) { self.onDone(result); }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)ts_changed {
    self.dirty = YES;
    [self ts_refreshValidity];
    [self render];
}

#pragma mark - 时段增删改

/// 替换第 index 个时段（草稿数组不可变，整体替换）
- (void)ts_updatePeriodAt:(NSUInteger)index with:(void (^)(TSHsdParentalControlPeriodModel *period))mutate {
    if (index >= self.draft.periods.count) { return; }
    NSMutableArray<TSHsdParentalControlPeriodModel *> *list = [self.draft.periods mutableCopy];
    TSHsdParentalControlPeriodModel *period = [list[index] copy];
    mutate(period);
    list[index] = period;
    self.draft.periods = list;
    [self ts_changed];
}

- (void)ts_addPeriod {
    if (self.draft.periods.count >= self.maxPeriodCount) { return; }
    TSHsdParentalControlPeriodModel *period = [[TSHsdParentalControlPeriodModel alloc] init];
    period.startMinute = kTSHsdParentalPeriodDefaultStart;
    period.endMinute = kTSHsdParentalPeriodDefaultEnd;
    period.repeatOptions = TSAlarmRepeatEveryday;
    self.draft.periods = [self.draft.periods arrayByAddingObject:period];
    [self ts_changed];
}

- (void)ts_removePeriodAt:(NSUInteger)index {
    if (index >= self.draft.periods.count) { return; }
    NSMutableArray<TSHsdParentalControlPeriodModel *> *list = [self.draft.periods mutableCopy];
    [list removeObjectAtIndex:index];
    self.draft.periods = list;
    [self ts_changed];
}

- (void)ts_removeItem {
    __weak typeof(self) weakSelf = self;
    [self confirmTitle:TSLocalizedString(@"hsd.pc.edit.remove_item_confirm") message:TSLocalizedString(@"hsd.pc.edit.remove_item_msg")
          confirmTitle:TSLocalizedString(@"general.delete") destructive:YES handler:^{
        weakSelf.dirty = NO;
        if (weakSelf.onRemove) { weakSelf.onRemove(); }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - 积木

/// 一个时段卡：标题行（时段 N · 全天 / 跨天 + 删除）、时间轴、开始 / 结束、重复
- (TSHsdCardView *)ts_periodCardAt:(NSUInteger)index period:(TSHsdParentalControlPeriodModel *)period {
    __weak typeof(self) weakSelf = self;
    TSHsdRowView *head = [self row];
    head.title = [NSString stringWithFormat:TSLocalizedString(@"hsd.pc.edit.period_title_format"), (long)(index + 1)];
    if (period.startMinute == period.endMinute) {
        head.subtitle = TSLocalizedString(@"hsd.pc.all_day");
    } else if (period.startMinute > period.endMinute) {
        head.subtitle = TSLocalizedString(@"hsd.time.next_day");
    } else {
        head.subtitle = [TSHsdDisplay durationStringForMinutes:period.endMinute - period.startMinute];
    }
    TSHsdCTAButton *remove = [[TSHsdCTAButton alloc] init];
    remove.small = YES;
    remove.soft = YES;
    [remove setTitle:TSLocalizedString(@"hsd.pc.edit.remove_period") symbol:@"trash"];
    remove.onTap = ^{ [weakSelf ts_removePeriodAt:index]; };
    head.rightView = remove;

    NSMutableArray<UIView *> *rows = [NSMutableArray arrayWithObject:head];
    [rows addObject:[self timelineFrom:period.startMinute to:period.endMinute caption:TSLocalizedString(@"hsd.pc.edit.timeline_caption")]];
    [rows addObject:[self duoStart:period.startMinute end:period.endMinute
                           onStart:^(NSInteger minute) { [weakSelf ts_updatePeriodAt:index with:^(TSHsdParentalControlPeriodModel *p) { p.startMinute = minute; }]; }
                             onEnd:^(NSInteger minute) { [weakSelf ts_updatePeriodAt:index with:^(TSHsdParentalControlPeriodModel *p) { p.endMinute = minute; }]; }]];
    [rows addObject:[self weekdays:period.repeatOptions presets:[TSHsdWeekdayPreset classroomPresets]
                          onChange:^(TSAlarmRepeat repeat) { [weakSelf ts_updatePeriodAt:index with:^(TSHsdParentalControlPeriodModel *p) { p.repeatOptions = repeat; }]; }]];
    return [self card:rows];
}

- (NSArray<UIView *> *)buildBlocks {
    TSHsdParentalControlItemModel *d = self.draft;
    __weak typeof(self) weakSelf = self;
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];

    // 功能项开关
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.pc.edit.sec.item") right:nil]];
    [blocks addObject:[self card:@[
        [self switchRowWithSymbol:[TSHsdDisplay symbolForParentalFunction:self.function] color:nil
                            title:TSLocalizedString(@"hsd.pc.edit.enabled")
                         subtitle:d.isEnabled ? TSLocalizedString(@"hsd.pc.edit.enabled_on") : TSLocalizedString(@"hsd.pc.edit.enabled_off")
                               on:d.isEnabled onToggle:^(BOOL on) { weakSelf.draft.enabled = on; [weakSelf ts_changed]; }]
    ]]];

    // 时段内的行为
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.pc.edit.sec.mode") right:nil]];
    TSHsdSegView *modeSeg = [[TSHsdSegView alloc] init];
    modeSeg.insetInCard = YES;
    modeSeg.items = @[[TSHsdSegItem itemWithTitle:[TSHsdDisplay parentalControlModeName:TSHsdParentalControlModeDisableInPeriod] symbol:@"hand.raised.fill"],
                      [TSHsdSegItem itemWithTitle:[TSHsdDisplay parentalControlModeName:TSHsdParentalControlModeAllowInPeriod] symbol:@"checkmark.circle.fill"]];
    modeSeg.selectedIndex = d.mode == TSHsdParentalControlModeAllowInPeriod ? 1 : 0;
    modeSeg.onChange = ^(NSInteger index) {
        weakSelf.draft.mode = index == 1 ? TSHsdParentalControlModeAllowInPeriod : TSHsdParentalControlModeDisableInPeriod;
        [weakSelf ts_changed];
    };
    [blocks addObject:[self card:@[modeSeg]]];
    [blocks addObject:[self foot:d.mode == TSHsdParentalControlModeAllowInPeriod ? TSLocalizedString(@"hsd.pc.edit.foot_mode_allow") : TSLocalizedString(@"hsd.pc.edit.foot_mode_disable")]];

    // 生效时段
    NSUInteger n = d.periods.count;
    BOOL full = n >= self.maxPeriodCount;
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.pc.edit.sec.periods") right:[NSString stringWithFormat:@"%lu / %lu", (unsigned long)n, (unsigned long)self.maxPeriodCount]]];
    if (n) {
        [d.periods enumerateObjectsUsingBlock:^(TSHsdParentalControlPeriodModel *period, NSUInteger i, BOOL *stop) {
            [blocks addObject:[self ts_periodCardAt:i period:period]];
        }];
    } else {
        [blocks addObject:[self card:@[[self emptyWithSymbol:@"clock.badge.questionmark" title:TSLocalizedString(@"hsd.pc.edit.empty_title") text:TSLocalizedString(@"hsd.pc.edit.empty_text") code:nil]]]];
    }
    TSHsdGhostAddButton *add = [[TSHsdGhostAddButton alloc] init];
    add.enabled = !full;
    add.title = full ? TSLocalizedString(@"hsd.limit_reached") : TSLocalizedString(@"hsd.pc.edit.add_period");
    add.small = full ? [NSString stringWithFormat:@"parentalControlMaxPeriodCount = %lu", (unsigned long)self.maxPeriodCount]
                     : [NSString stringWithFormat:TSLocalizedString(@"hsd.remaining_format"), (unsigned long)(self.maxPeriodCount - n)];
    add.onTap = ^{ [weakSelf ts_addPeriod]; };
    [blocks addObject:add];
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.pc.edit.foot_periods")]];

    if (self.item && self.onRemove) {
        TSHsdDangerLink *remove = [[TSHsdDangerLink alloc] init];
        remove.title = TSLocalizedString(@"hsd.pc.edit.remove_item");
        remove.onTap = ^{ [weakSelf ts_removeItem]; };
        [blocks addObject:remove];
    }
    [self ts_refreshValidity];
    return blocks;
}

@end
