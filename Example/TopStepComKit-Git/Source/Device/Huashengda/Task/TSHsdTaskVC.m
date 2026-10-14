//
//  TSHsdTaskVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdTaskVC.h"
#import "TSHsdTaskEditorVC.h"
#import "TSAlarmTypePickerVC.h"

#pragma mark - 金币卡（.coincard）

@interface TSHsdCoinCardView : UIView
@property (nonatomic, strong) UIImageView *coinView;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UIButton *adjustButton;
@property (nonatomic, strong) TSHsdCTAButton *exchangeButton;
@property (nonatomic, strong) UIView *statA;
@property (nonatomic, strong) UILabel *statAKey;
@property (nonatomic, strong) UILabel *statAValue;
@property (nonatomic, strong) TSHsdProgressBar *statAProgress;
@property (nonatomic, strong) UIView *statB;
@property (nonatomic, strong) UILabel *statBKey;
@property (nonatomic, strong) UILabel *statBValue;
@property (nonatomic, strong) UILabel *statBCap;
@property (nonatomic, copy, nullable) void (^onAdjust)(void);
@property (nonatomic, copy, nullable) void (^onExchange)(void);
@end

@implementation TSHsdCoinCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    UIColor *amber = [TSHsdDisplay hueTask];
    _coinView = [[UIImageView alloc] initWithImage:TSHsdSymbol(@"dollarsign.circle.fill", 48.f, UIImageSymbolWeightMedium)];
    _coinView.tintColor = amber;
    _coinView.contentMode = UIViewContentModeCenter;
    _coinView.layer.shadowColor = amber.CGColor; _coinView.layer.shadowOpacity = 0.45f; _coinView.layer.shadowRadius = 8.f; _coinView.layer.shadowOffset = CGSizeMake(0, 6.f);
    [self addSubview:_coinView];
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.font = [TSHsdDisplay roundedFontOfSize:40.f weight:UIFontWeightHeavy];
    _numberLabel.textColor = [TSHsdDisplay ink];
    [self addSubview:_numberLabel];
    _captionLabel = [[UILabel alloc] init];
    _captionLabel.font = [UIFont systemFontOfSize:12.5f];
    _captionLabel.textColor = [TSHsdDisplay textSecondary];
    _captionLabel.text = TSLocalizedString(@"hsd.task.total_coins");
    [self addSubview:_captionLabel];
    _adjustButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_adjustButton setTitle:TSLocalizedString(@"hsd.task.adjust") forState:UIControlStateNormal];
    [_adjustButton setTitleColor:amber forState:UIControlStateNormal];
    _adjustButton.titleLabel.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightSemibold];
    [_adjustButton addTarget:self action:@selector(ts_adjust) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_adjustButton];
    _exchangeButton = [[TSHsdCTAButton alloc] init];
    _exchangeButton.small = YES;
    [_exchangeButton setTitle:TSLocalizedString(@"hsd.task.exchange") symbol:@"gift.fill"];
    __weak typeof(self) weakSelf = self;
    _exchangeButton.onTap = ^{ if (weakSelf.onExchange) { weakSelf.onExchange(); } };
    [self addSubview:_exchangeButton];

    _statA = [self ts_statBox]; _statAKey = [self ts_statKey:_statA text:TSLocalizedString(@"hsd.task.today_done")]; _statAValue = [self ts_statValue:_statA];
    _statAProgress = [[TSHsdProgressBar alloc] init]; _statAProgress.hue = amber; [_statA addSubview:_statAProgress];
    _statB = [self ts_statBox]; _statBKey = [self ts_statKey:_statB text:TSLocalizedString(@"hsd.task.today_earn")]; _statBValue = [self ts_statValue:_statB];
    _statBCap = [[UILabel alloc] init]; _statBCap.font = [UIFont systemFontOfSize:11.f]; _statBCap.textColor = [TSHsdDisplay textTertiary]; [_statB addSubview:_statBCap];
    return self;
}

- (UIView *)ts_statBox {
    UIView *box = [[UIView alloc] init];
    box.backgroundColor = [[TSHsdDisplay card] colorWithAlphaComponent:0.7f];
    box.layer.cornerRadius = 14.f;
    box.layer.borderWidth = 1.f;
    box.layer.borderColor = TSAdaptiveColor([[UIColor blackColor] colorWithAlphaComponent:0.06], [[UIColor whiteColor] colorWithAlphaComponent:0.08]).CGColor;
    [self addSubview:box];
    return box;
}

- (UILabel *)ts_statKey:(UIView *)box text:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:11.5f]; label.textColor = [TSHsdDisplay textSecondary]; label.text = text;
    [box addSubview:label];
    return label;
}

- (UILabel *)ts_statValue:(UIView *)box {
    UILabel *label = [[UILabel alloc] init];
    label.font = [TSHsdDisplay roundedFontOfSize:17.f weight:UIFontWeightBold]; label.textColor = [TSHsdDisplay ink];
    [box addSubview:label];
    return label;
}

- (void)ts_adjust { if (self.onAdjust) { self.onAdjust(); } }

- (void)configureCoins:(NSInteger)coins done:(NSInteger)done active:(NSInteger)active earn:(NSInteger)earn connected:(BOOL)connected {
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)coins];
    NSMutableAttributedString *a = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)done] attributes:@{NSFontAttributeName: self.statAValue.font, NSForegroundColorAttributeName: [TSHsdDisplay ink]}];
    [a appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" / %ld", (long)active] attributes:@{NSFontAttributeName: [TSHsdDisplay roundedFontOfSize:12.f weight:UIFontWeightSemibold], NSForegroundColorAttributeName: [TSHsdDisplay textTertiary]}]];
    self.statAValue.attributedText = a;
    self.statAProgress.progress = active ? (CGFloat)done / (CGFloat)active : 0;
    NSMutableAttributedString *b = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)earn] attributes:@{NSFontAttributeName: self.statBValue.font, NSForegroundColorAttributeName: [TSHsdDisplay ink]}];
    [b appendAttributedString:[[NSAttributedString alloc] initWithString:[@" " stringByAppendingString:TSLocalizedString(@"hsd.task.coins_unit")] attributes:@{NSFontAttributeName: [TSHsdDisplay roundedFontOfSize:12.f weight:UIFontWeightSemibold], NSForegroundColorAttributeName: [TSHsdDisplay textTertiary]}]];
    self.statBValue.attributedText = b;
    self.statBCap.text = [NSString stringWithFormat:TSLocalizedString(@"hsd.task.pending_format"), (long)(active - done)];
    self.exchangeButton.enabled = connected;
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 18.f + 54.f + 16.f + 78.f + 18.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    self.coinView.frame = CGRectMake(18.f, 18.f, 54.f, 54.f);
    CGSize es = [self.exchangeButton sizeThatFits:CGSizeZero];
    self.exchangeButton.frame = CGRectMake(w - 18.f - es.width, 18.f + (54.f - 36.f) / 2.f, es.width, 36.f);
    CGFloat textX = 18.f + 54.f + 14.f;
    self.numberLabel.frame = CGRectMake(textX, 18.f, CGRectGetMinX(self.exchangeButton.frame) - textX - 8.f, 40.f);
    [self.captionLabel sizeToFit];
    self.captionLabel.frame = CGRectMake(textX, 61.f, self.captionLabel.bounds.size.width, 14.f);
    [self.adjustButton sizeToFit];
    self.adjustButton.frame = CGRectMake(CGRectGetMaxX(self.captionLabel.frame) + 8.f, 57.f, self.adjustButton.bounds.size.width, 22.f);
    CGFloat statY = 18.f + 54.f + 16.f, statW = (w - 36.f - 10.f) / 2.f, statH = 78.f;
    self.statA.frame = CGRectMake(18.f, statY, statW, statH);
    self.statB.frame = CGRectMake(18.f + statW + 10.f, statY, statW, statH);
    for (UIView *box in @[self.statA, self.statB]) {
        UILabel *key = box == self.statA ? self.statAKey : self.statBKey;
        UILabel *value = box == self.statA ? self.statAValue : self.statBValue;
        key.frame = CGRectMake(12.f, 10.f, statW - 24.f, 14.f);
        value.frame = CGRectMake(12.f, 26.f, statW - 24.f, 22.f);
    }
    self.statAProgress.frame = CGRectMake(12.f, 56.f, statW - 24.f, 5.f);
    self.statBCap.frame = CGRectMake(12.f, 52.f, statW - 24.f, 14.f);
}

@end

#pragma mark - 任务行右侧（金币药丸 + 开关）

@interface TSHsdTaskRightView : UIView
@property (nonatomic, strong) TSHsdPill *pill;
@property (nonatomic, strong) UISwitch *toggle;
@end

@implementation TSHsdTaskRightView
- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(MAX([self.pill sizeThatFits:size].width, 51.f), 22.f + 7.f + 31.f); }
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    CGSize ps = [self.pill sizeThatFits:CGSizeZero];
    self.pill.frame = CGRectMake(w - ps.width, 0, ps.width, 22.f);
    self.toggle.frame = CGRectMake(w - 51.f, 29.f, 51.f, 31.f);
}
@end

#pragma mark - TSHsdTaskVC

@interface TSHsdTaskVC ()
@property (nonatomic, strong) TSHsdTaskInfoModel *draft;
/// 最近一次从手表读到的快照（用于保存前比较）
@property (nonatomic, strong, nullable) TSHsdTaskInfoModel *base;
@property (nonatomic, assign) NSInteger loadState;
@property (nonatomic, strong, nullable) NSError *loadError;
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *supportedTypes;
@end

@implementation TSHsdTaskVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"hsd.task");
    self.hue = [TSHsdDisplay hueTask];
    self.usesDock = YES;
    self.chips = @[@"bit31", TSLocalizedString(@"hsd.task.chip")];
    self.draft = [[TSHsdTaskInfoModel alloc] init];
    self.draft.tasks = @[];
}

- (NSString *)dockButtonTitle {
    return [NSString stringWithFormat:TSLocalizedString(@"hsd.dock.save_all_format"), (long)self.draft.tasks.count];
}

#pragma mark - 读取

- (void)reload {
    self.loadState = 0;
    [self render];
    [self ts_loadSupportedTypes];
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchTaskInfo:" params:nil];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchTaskInfo:^(TSHsdTaskInfoModel *model, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            if (error || !model) {
                [self finishCall:entry success:NO error:error result:nil];
                self.loadState = 2;
                self.loadError = error;
            } else {
                [self finishCall:entry success:YES error:nil result:[self ts_summaryOf:model]];
                self.base = [model copy];
                self.draft = [model copy];
                self.dirty = NO;
                self.loadState = 1;
            }
            [self render];
        }];
    }];
}

- (void)ts_loadSupportedTypes {
    id<TSAlarmClockInterface> alarm = [TopStepComKit sharedInstance].alarmClock;
    if (![alarm isSupportAlarmType]) { return; }
    __weak typeof(self) weakSelf = self;
    [alarm fetchSupportedAlarmTypes:^(NSArray<NSNumber *> *types, NSError *error) {
        [weakSelf onMain:^{ if (!error) { weakSelf.supportedTypes = types; } }];
    }];
}

- (NSString *)ts_summaryOf:(TSHsdTaskInfoModel *)model {
    return [NSString stringWithFormat:@"%lu tasks · coins %ld", (unsigned long)model.tasks.count, (long)model.totalCoins];
}

#pragma mark - 校验

- (nullable NSString *)ts_validate {
    NSArray<TSHsdTaskModel *> *tasks = self.draft.tasks;
    if (tasks.count > TSHsdTaskMaxCount) {
        return [NSString stringWithFormat:TSLocalizedString(@"hsd.task.err_count_format"), (unsigned long)tasks.count, (unsigned long)TSHsdTaskMaxCount];
    }
    for (NSUInteger i = 0; i < tasks.count; i++) {
        if ([TSHsdDisplay utf8Length:tasks[i].label] > TSHsdTaskLabelMaxBytes) {
            return [NSString stringWithFormat:TSLocalizedString(@"hsd.task.err_label_format"), (unsigned long)(i + 1), (unsigned long)TSHsdTaskLabelMaxBytes];
        }
        if ([TSHsdDisplay utf8Length:tasks[i].taskDescription] > TSHsdTaskDescriptionMaxBytes) {
            return [NSString stringWithFormat:TSLocalizedString(@"hsd.task.err_desc_format"), (unsigned long)(i + 1), (unsigned long)TSHsdTaskDescriptionMaxBytes];
        }
    }
    return nil;
}

#pragma mark - 保存（静默回读 → 确认 → 下发 → 回读比对）

- (void)save {
    if (!self.hsd) { [self toast:TSLocalizedString(@"hsd.error.not_support")]; return; }
    NSString *problem = [self ts_validate];
    if (problem) { [self toast:problem]; return; }
    self.saving = YES;
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchTaskInfo:" params:TSLocalizedString(@"hsd.log.pre_read")];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchTaskInfo:^(TSHsdTaskInfoModel *now, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            if (error || !now) {
                self.saving = NO;
                [self finishCall:entry success:NO error:error result:nil];
                [self alertError:error title:TSLocalizedString(@"hsd.save.failed")];
                return;
            }
            [self finishCall:entry success:YES error:nil result:[NSString stringWithFormat:@"coins %ld", (long)now.totalCoins]];
            [self ts_checkWatchChanges:now];
        }];
    }];
}

/// 讨论点 A：手表侧金币 / 状态与进入页面时的快照不同则提示
- (void)ts_checkWatchChanges:(TSHsdTaskInfoModel *)now {
    NSMutableArray<NSString *> *changes = [NSMutableArray array];
    if (now.totalCoins != self.base.totalCoins) {
        [changes addObject:[NSString stringWithFormat:TSLocalizedString(@"hsd.task.change_coins_format"), (long)self.base.totalCoins, (long)now.totalCoins]];
    }
    for (TSHsdTaskModel *t in now.tasks) {
        for (TSHsdTaskModel *o in self.base.tasks) {
            if (o.taskId == t.taskId && o.state != t.state) {
                NSString *name = t.label.length ? t.label : [TSAlarmTypeDisplay nameForType:t.type];
                [changes addObject:[NSString stringWithFormat:@"「%@」%@", name, [TSHsdDisplay taskStateName:t.state]]];
            }
        }
    }
    __weak typeof(self) weakSelf = self;
    if (changes.count == 0) {
        [self ts_confirmAndSend];
        return;
    }
    BOOL coinsEdited = self.draft.totalCoins != self.base.totalCoins;
    NSString *message = [changes componentsJoinedByString:@"\n"];
    NSArray<NSString *> *buttons = nil;
    if (coinsEdited) {
        message = [message stringByAppendingFormat:@"\n\n%@", TSLocalizedString(@"hsd.task.change_coins_choice")];
        buttons = @[TSLocalizedString(@"general.cancel"),
                    [NSString stringWithFormat:TSLocalizedString(@"hsd.task.use_mine_format"), (long)self.draft.totalCoins],
                    [NSString stringWithFormat:TSLocalizedString(@"hsd.task.use_watch_format"), (long)now.totalCoins]];
    } else {
        message = [message stringByAppendingFormat:@"\n\n%@", TSLocalizedString(@"hsd.task.change_overwrite_hint")];
        buttons = @[TSLocalizedString(@"general.cancel"), TSLocalizedString(@"hsd.task.adopt_watch_and_save")];
    }
    [self askTitle:TSLocalizedString(@"hsd.task.watch_changed") message:message buttons:buttons destructiveIndex:-1 handler:^(NSInteger index) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        if (index == 0) { self.saving = NO; return; }
        if (!(coinsEdited && index == 1)) { self.draft.totalCoins = now.totalCoins; }
        for (TSHsdTaskModel *t in self.draft.tasks) {
            for (TSHsdTaskModel *o in now.tasks) { if (o.taskId == t.taskId) { t.state = o.state; } }
        }
        [self ts_confirmAndSend];
    }];
}

- (void)ts_confirmAndSend {
    NSUInteger n = self.draft.tasks.count;
    __weak typeof(self) weakSelf = self;
    NSString *title = n ? [NSString stringWithFormat:TSLocalizedString(@"hsd.task.confirm_save_format"), (unsigned long)n] : TSLocalizedString(@"hsd.task.confirm_clear");
    NSString *message = n ? [NSString stringWithFormat:TSLocalizedString(@"hsd.task.confirm_save_msg_format"), (long)self.draft.totalCoins]
                          : [NSString stringWithFormat:TSLocalizedString(@"hsd.task.confirm_clear_msg_format"), (long)self.draft.totalCoins];
    [self askTitle:title message:message buttons:@[TSLocalizedString(@"general.cancel"), n ? TSLocalizedString(@"general.save") : TSLocalizedString(@"general.clear")] destructiveIndex:n ? -1 : 1 handler:^(NSInteger index) {
        if (index == 0) { weakSelf.saving = NO; return; }
        [weakSelf ts_send];
    }];
}

- (void)ts_send {
    TSHsdTaskInfoModel *sent = [self.draft copy];
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setTaskInfo:completion:" params:[NSString stringWithFormat:@"tasks=%lu totalCoins=%ld", (unsigned long)sent.tasks.count, (long)sent.totalCoins]];
    __weak typeof(self) weakSelf = self;
    [self.hsd setTaskInfo:sent completion:^(BOOL isSuccess, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            if (!isSuccess) {
                self.saving = NO;
                [self finishCall:entry success:NO error:error result:nil];
                [self alertError:error title:TSLocalizedString(@"hsd.save.failed")];
                return;
            }
            [self finishCall:entry success:YES error:nil result:nil];
            [self ts_readbackAfterSave:sent];
        }];
    }];
}

- (void)ts_readbackAfterSave:(TSHsdTaskInfoModel *)sent {
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchTaskInfo:" params:TSLocalizedString(@"hsd.log.readback")];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchTaskInfo:^(TSHsdTaskInfoModel *model, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            self.saving = NO;
            if (error || !model) {
                [self finishCall:entry success:NO error:error result:nil];
                self.dirty = NO;
                self.base = [sent copy];
                [self render];
                [self toast:[NSString stringWithFormat:TSLocalizedString(@"hsd.save.readback_failed_format"), [TSHsdErrorText messageForError:error]]];
                return;
            }
            [self finishCall:entry success:YES error:nil result:[self ts_summaryOf:model]];
            NSArray<TSHsdDiffItem *> *diff = [TSHsdReadbackDiff diffTaskInfo:sent read:model];
            self.base = [model copy];
            self.draft = [model copy];
            self.dirty = NO;
            [self render];
            if (diff.count == 0) { [self toast:TSLocalizedString(@"hsd.save.readback_match")]; }
            else { [TSHsdReadbackDiff presentDiff:diff from:self]; }
        }];
    }];
}

#pragma mark - 兑换

- (void)ts_exchange {
    __weak typeof(self) weakSelf = self;
    [self confirmTitle:TSLocalizedString(@"hsd.task.exchange_confirm") message:[NSString stringWithFormat:TSLocalizedString(@"hsd.task.exchange_confirm_msg_format"), (long)self.draft.totalCoins]
          confirmTitle:TSLocalizedString(@"hsd.task.exchange") destructive:NO handler:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        [self showLoading];
        TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.exchangeTaskReward:" params:nil];
        [self.hsd exchangeTaskReward:^(BOOL success, NSError *error) {
            [weakSelf onMain:^{
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) { return; }
                [self hideLoading];
                if (error) {
                    [self finishCall:entry success:NO error:error result:nil];
                    [self alertError:error title:TSLocalizedString(@"hsd.task.exchange_failed")];
                    [self ts_refetchAfterExchange:NO];
                    return;
                }
                [self finishCall:entry success:YES error:nil result:success ? @"success=YES" : @"success=NO"];
                if (!success) { [self toast:TSLocalizedString(@"hsd.task.exchange_watch_rejected")]; }
                [self ts_refetchAfterExchange:success];
            }];
        }];
    }];
}

/// 兑换后无论成败都重新读取；兑换成功但回读失败时明确提示
- (void)ts_refetchAfterExchange:(BOOL)exchanged {
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchTaskInfo:" params:TSLocalizedString(@"hsd.log.after_exchange")];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchTaskInfo:^(TSHsdTaskInfoModel *model, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            if (error || !model) {
                [self finishCall:entry success:NO error:error result:nil];
                if (exchanged) { [self toast:TSLocalizedString(@"hsd.task.exchange_ok_readback_failed")]; }
                return;
            }
            [self finishCall:entry success:YES error:nil result:[self ts_summaryOf:model]];
            NSInteger before = self.base.totalCoins;
            self.base = [model copy];
            if (!self.isDirty) { self.draft = [model copy]; } else { self.draft.totalCoins = model.totalCoins; }
            [self render];
            if (exchanged) {
                [self toast:[NSString stringWithFormat:TSLocalizedString(@"hsd.task.exchange_ok_format"), (long)before, (long)model.totalCoins]];
            }
        }];
    }];
}

#pragma mark - 编辑

- (void)ts_editTaskAt:(NSInteger)index {
    TSHsdTaskEditorVC *editor = [[TSHsdTaskEditorVC alloc] init];
    editor.supportedTypes = self.supportedTypes;
    NSInteger maxId = 0;
    for (TSHsdTaskModel *t in self.draft.tasks) { maxId = MAX(maxId, t.taskId); }
    editor.nextTaskId = maxId + 1;
    editor.task = index >= 0 ? self.draft.tasks[index] : nil;
    __weak typeof(self) weakSelf = self;
    editor.onDone = ^(TSHsdTaskModel *task) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        NSMutableArray<TSHsdTaskModel *> *tasks = [self.draft.tasks mutableCopy];
        if (index >= 0 && index < (NSInteger)tasks.count) { tasks[index] = task; } else { [tasks addObject:task]; }
        self.draft.tasks = tasks;
        self.dirty = YES;
        [self render];
    };
    editor.onDelete = ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || index < 0) { return; }
        NSMutableArray<TSHsdTaskModel *> *tasks = [self.draft.tasks mutableCopy];
        [tasks removeObjectAtIndex:index];
        self.draft.tasks = tasks;
        self.dirty = YES;
        [self render];
    };
    [self.navigationController pushViewController:editor animated:YES];
}

- (void)ts_openCoins {
    __weak typeof(self) weakSelf = self;
    [TSHsdSheet presentCoinsFrom:self value:self.draft.totalCoins hue:self.hue onDone:^(NSInteger value) {
        if (value == weakSelf.draft.totalCoins) { return; }
        weakSelf.draft.totalCoins = value;
        weakSelf.dirty = YES;
        [weakSelf render];
    }];
}

#pragma mark - 积木

- (NSArray<UIView *> *)buildBlocks {
    if (self.loadState == 0) { return @[[self loadingBlock:nil]]; }
    __weak typeof(self) weakSelf = self;
    if (self.loadState == 2) { return @[[self errorBlock:self.loadError retry:^{ [weakSelf reload]; }]]; }

    TSHsdTaskInfoModel *d = self.draft;
    self.invalid = ([self ts_validate] != nil);
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];

    // 今日统计：启用且重复日包含今天（或仅一次）
    NSInteger weekday = [[NSCalendar currentCalendar] component:NSCalendarUnitWeekday fromDate:[NSDate date]];   // 1 = 周日
    TSAlarmRepeat todayBit = (TSAlarmRepeat)(1 << ((weekday + 5) % 7));                                             // bit0 = 周一
    NSInteger active = 0, done = 0, earn = 0;
    for (TSHsdTaskModel *t in d.tasks) {
        if (!t.isEnabled) { continue; }
        if (t.repeatOptions != TSAlarmRepeatNone && !(t.repeatOptions & todayBit)) { continue; }
        active++;
        if (t.state == TSHsdTaskStateCompleted) { done++; } else { earn += t.coins; }
    }

    // 金币卡
    TSHsdCoinCardView *coin = [[TSHsdCoinCardView alloc] init];
    [coin configureCoins:d.totalCoins done:done active:active earn:earn connected:self.connected];
    coin.onAdjust = ^{ [weakSelf ts_openCoins]; };
    coin.onExchange = ^{ [weakSelf ts_exchange]; };
    TSHsdCardView *coinCard = [self card:@[coin]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)[[TSHsdDisplay hueTask] colorWithAlphaComponent:0.2f].CGColor, (id)[UIColor clearColor].CGColor];
    gradient.locations = @[@0, @0.62];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 1);
    coinCard.gradient = gradient;
    [blocks addObject:coinCard];

    // 任务列表
    NSUInteger n = d.tasks.count;
    BOOL full = n >= TSHsdTaskMaxCount;
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.task.sec.tasks") right:[NSString stringWithFormat:@"%lu / %lu", (unsigned long)n, (unsigned long)TSHsdTaskMaxCount]]];
    if (n) {
        NSMutableArray<UIView *> *rows = [NSMutableArray array];
        [d.tasks enumerateObjectsUsingBlock:^(TSHsdTaskModel *t, NSUInteger i, BOOL *stop) {
            TSHsdRowView *row = [self row];
            row.symbol = [TSAlarmTypeDisplay symbolNameForType:t.type];
            row.emoStyle = YES;
            row.topAligned = YES;
            row.title = t.label.length ? t.label : [TSAlarmTypeDisplay nameForType:t.type];
            row.subtitle = [NSString stringWithFormat:@"%@ · %@", t.isTimeEnabled ? [TSHsdDisplay timeStringForMinute:t.minuteOfDay] : TSLocalizedString(@"hsd.task.no_time"), [TSHsdDisplay repeatString:t.repeatOptions]];
            row.extraView = [self stateLabel:[TSHsdDisplay taskStateName:t.state] color:[TSHsdDisplay colorForTaskState:t.state]];
            TSHsdTaskRightView *right = [[TSHsdTaskRightView alloc] init];
            right.pill = [[TSHsdPill alloc] init];
            right.pill.style = TSHsdPillStyleCoin;
            right.pill.symbol = @"dollarsign.circle.fill";
            right.pill.text = [NSString stringWithFormat:@"+%ld", (long)t.coins];
            [right addSubview:right.pill];
            right.toggle = [[UISwitch alloc] init];
            right.toggle.on = t.isEnabled;
            right.toggle.onTintColor = self.hue;
            right.toggle.tag = i;
            [right.toggle addTarget:self action:@selector(ts_taskToggled:) forControlEvents:UIControlEventValueChanged];
            [right addSubview:right.toggle];
            row.rightView = right;
            row.dim = !t.isEnabled;
            row.onTap = ^{ [weakSelf ts_editTaskAt:i]; };
            [rows addObject:row];
        }];
        [blocks addObject:[self card:rows]];
    } else {
        [blocks addObject:[self card:@[[self emptyWithSymbol:@"checklist" title:TSLocalizedString(@"hsd.task.empty_title") text:TSLocalizedString(@"hsd.task.empty_text") code:nil]]]];
    }
    TSHsdGhostAddButton *add = [[TSHsdGhostAddButton alloc] init];
    add.enabled = !full;
    add.title = full ? TSLocalizedString(@"hsd.limit_reached") : TSLocalizedString(@"hsd.task.add");
    add.small = full ? @"TSHsdTaskMaxCount = 5" : [NSString stringWithFormat:TSLocalizedString(@"hsd.remaining_format"), (unsigned long)(TSHsdTaskMaxCount - n)];
    add.onTap = ^{ [weakSelf ts_editTaskAt:-1]; };
    [blocks addObject:add];
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.task.foot")]];
    return blocks;
}

- (void)ts_taskToggled:(UISwitch *)sender {
    NSInteger i = sender.tag;
    if (i < 0 || i >= (NSInteger)self.draft.tasks.count) { return; }
    self.draft.tasks[i].enabled = sender.isOn;
    self.dirty = YES;
    [self render];
}

@end
