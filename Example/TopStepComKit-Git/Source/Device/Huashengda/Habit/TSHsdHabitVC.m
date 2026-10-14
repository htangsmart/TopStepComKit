//
//  TSHsdHabitVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdHabitVC.h"
#import "TSHsdHabitEditorVC.h"

#pragma mark - 习惯卡内容（.habit）

@interface TSHsdHabitRowView : UIView
@property (nonatomic, strong) TSHsdRingView *ring;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) TSHsdStateLabel *stateLabel;
@property (nonatomic, strong) UILabel *planLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) TSHsdWeekDots *dots;
@property (nonatomic, strong) UILabel *weekLabel;
@property (nonatomic, strong) UIView *highlight;
@property (nonatomic, copy, nullable) void (^onTap)(void);
@end

@implementation TSHsdHabitRowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _highlight = [[UIView alloc] init]; _highlight.backgroundColor = [TSHsdDisplay fill]; _highlight.hidden = YES; [self addSubview:_highlight];
    _ring = [[TSHsdRingView alloc] init]; [self addSubview:_ring];
    _nameLabel = [[UILabel alloc] init]; _nameLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightBold]; _nameLabel.textColor = [TSHsdDisplay ink]; [self addSubview:_nameLabel];
    _stateLabel = [[TSHsdStateLabel alloc] init]; [self addSubview:_stateLabel];
    _planLabel = [[UILabel alloc] init]; _planLabel.font = [UIFont systemFontOfSize:12.5f]; _planLabel.textColor = [TSHsdDisplay textSecondary]; [self addSubview:_planLabel];
    _progressLabel = [[UILabel alloc] init]; _progressLabel.font = [UIFont systemFontOfSize:12.f]; _progressLabel.textColor = [TSHsdDisplay textSecondary]; [self addSubview:_progressLabel];
    _dots = [[TSHsdWeekDots alloc] init]; [self addSubview:_dots];
    _weekLabel = [[UILabel alloc] init]; _weekLabel.font = [UIFont systemFontOfSize:11.f]; _weekLabel.textColor = [TSHsdDisplay textTertiary]; _weekLabel.text = TSLocalizedString(@"hsd.habit.past_week"); [self addSubview:_weekLabel];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ts_tapped)]];
    return self;
}

- (void)configureWithHabit:(TSHsdHabitModel *)h hue:(UIColor *)hue {
    self.ring.hue = hue;
    self.ring.symbol = [TSHsdDisplay symbolForHabitType:h.type];
    self.ring.progress = h.taskDays ? (CGFloat)h.reachGoalDays / (CGFloat)h.taskDays : 0;
    self.nameLabel.text = h.type == TSHsdHabitTypeCustom ? (h.label.length ? h.label : TSLocalizedString(@"hsd.habit.custom_default")) : [TSHsdDisplay habitTypeName:h.type];
    [self.stateLabel setText:[TSHsdDisplay habitStateName:h.state] color:[TSHsdDisplay colorForHabitState:h.state]];
    self.planLabel.text = [NSString stringWithFormat:@"%@ · %@ · %@", [TSHsdDisplay timeStringForMinute:h.minuteOfDay],
                           [NSString stringWithFormat:TSLocalizedString(@"hsd.duration.m_format"), (long)h.duration], [TSHsdDisplay repeatString:h.repeatOptions]];
    NSString *progress = [NSString stringWithFormat:TSLocalizedString(@"hsd.habit.progress_format"), (long)h.reachGoalDays, (long)h.taskDays, (long)h.maxReachGoalDays];
    self.progressLabel.attributedText = TSHsdRich(progress, [UIFont systemFontOfSize:12.f], [TSHsdDisplay textSecondary], [TSHsdDisplay ink]);
    self.dots.hue = hue;
    self.dots.mask = h.achieveGoalRepeat;
    [self setNeedsLayout];
}

- (void)ts_tapped {
    if (!self.onTap) { return; }
    self.highlight.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ self.highlight.hidden = YES; });
    self.onTap();
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 16.f + 20.f + 3.f + 18.f + 8.f + 16.f + 8.f + 14.f + 16.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    self.highlight.frame = self.bounds;
    self.ring.frame = CGRectMake(16.f, (self.bounds.size.height - 58.f) / 2.f, 58.f, 58.f);
    CGFloat x = 16.f + 58.f + 14.f, right = w - 16.f, textW = right - x;
    CGSize ss = [self.stateLabel sizeThatFits:CGSizeZero];
    self.stateLabel.frame = CGRectMake(right - ss.width, 18.f, ss.width, 16.f);
    self.nameLabel.frame = CGRectMake(x, 16.f, textW - ss.width - 8.f, 20.f);
    self.planLabel.frame = CGRectMake(x, 39.f, textW, 18.f);
    self.progressLabel.frame = CGRectMake(x, 65.f, textW, 16.f);
    CGSize ds = [self.dots sizeThatFits:CGSizeZero];
    self.dots.frame = CGRectMake(x, 89.f, ds.width, 14.f);
    self.weekLabel.frame = CGRectMake(x + ds.width + 8.f, 89.f, textW - ds.width - 8.f, 14.f);
}

@end

#pragma mark - TSHsdHabitVC

@interface TSHsdHabitVC ()
@property (nonatomic, copy) NSArray<TSHsdHabitModel *> *draft;
@property (nonatomic, assign) NSInteger loadState;
@property (nonatomic, strong, nullable) NSError *loadError;
@end

@implementation TSHsdHabitVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"hsd.habit");
    self.hue = [TSHsdDisplay hueHabit];
    self.usesDock = YES;
    self.chips = @[@"bit32", TSLocalizedString(@"hsd.habit.chip")];
    self.draft = @[];
}

- (NSString *)dockButtonTitle {
    return [NSString stringWithFormat:TSLocalizedString(@"hsd.dock.save_all_format"), (long)self.draft.count];
}

#pragma mark - 读取 / 保存

- (void)reload {
    self.loadState = 0;
    [self render];
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchHabits:" params:nil];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchHabits:^(NSArray<TSHsdHabitModel *> *habits, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            if (error || !habits) {
                [self finishCall:entry success:NO error:error result:nil];
                self.loadState = 2;
                self.loadError = error;
            } else {
                [self finishCall:entry success:YES error:nil result:[NSString stringWithFormat:@"%lu habits", (unsigned long)habits.count]];
                self.draft = [[NSArray alloc] initWithArray:habits copyItems:YES];
                self.dirty = NO;
                self.loadState = 1;
            }
            [self render];
        }];
    }];
}

- (nullable NSString *)ts_validate {
    if (self.draft.count > TSHsdHabitMaxCount) {
        return [NSString stringWithFormat:TSLocalizedString(@"hsd.habit.err_count_format"), (unsigned long)self.draft.count, (unsigned long)TSHsdHabitMaxCount];
    }
    for (NSUInteger i = 0; i < self.draft.count; i++) {
        if ([TSHsdDisplay utf8Length:self.draft[i].label] > TSHsdHabitLabelMaxBytes) {
            return [NSString stringWithFormat:TSLocalizedString(@"hsd.habit.err_label_format"), (unsigned long)(i + 1), (unsigned long)TSHsdHabitLabelMaxBytes];
        }
    }
    return nil;
}

- (void)save {
    if (!self.hsd) { [self toast:TSLocalizedString(@"hsd.error.not_support")]; return; }
    NSString *problem = [self ts_validate];
    if (problem) { [self toast:problem]; return; }
    __weak typeof(self) weakSelf = self;
    if (self.draft.count == 0) {
        // 0 条：清空手表上的全部习惯？（手表是否真的清空由固件决定，D-28）
        [self confirmTitle:TSLocalizedString(@"hsd.habit.confirm_clear") message:TSLocalizedString(@"hsd.habit.confirm_clear_msg")
              confirmTitle:TSLocalizedString(@"general.clear") destructive:YES handler:^{ [weakSelf ts_send]; }];
        return;
    }
    [self ts_send];
}

- (void)ts_send {
    NSArray<TSHsdHabitModel *> *sent = [[NSArray alloc] initWithArray:self.draft copyItems:YES];
    self.saving = YES;
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setHabits:completion:" params:[NSString stringWithFormat:TSLocalizedString(@"hsd.habit.log_send_format"), (unsigned long)sent.count]];
    __weak typeof(self) weakSelf = self;
    [self.hsd setHabits:sent completion:^(BOOL isSuccess, NSError *error) {
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

- (void)ts_readbackAfterSave:(NSArray<TSHsdHabitModel *> *)sent {
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchHabits:" params:TSLocalizedString(@"hsd.log.readback")];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchHabits:^(NSArray<TSHsdHabitModel *> *habits, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            self.saving = NO;
            if (error || !habits) {
                [self finishCall:entry success:NO error:error result:nil];
                self.dirty = NO;
                [self render];
                [self toast:[NSString stringWithFormat:TSLocalizedString(@"hsd.save.readback_failed_format"), [TSHsdErrorText messageForError:error]]];
                return;
            }
            [self finishCall:entry success:YES error:nil result:[NSString stringWithFormat:@"%lu habits", (unsigned long)habits.count]];
            NSArray<TSHsdDiffItem *> *diff = [TSHsdReadbackDiff diffHabits:sent read:habits];
            self.draft = [[NSArray alloc] initWithArray:habits copyItems:YES];
            self.dirty = NO;
            [self render];
            if (diff.count == 0) { [self toast:TSLocalizedString(@"hsd.save.readback_match")]; }
            else { [TSHsdReadbackDiff presentDiff:diff from:self]; }
        }];
    }];
}

#pragma mark - 编辑

- (void)ts_editHabitAt:(NSInteger)index {
    TSHsdHabitEditorVC *editor = [[TSHsdHabitEditorVC alloc] init];
    NSInteger maxId = 0;
    for (TSHsdHabitModel *h in self.draft) { maxId = MAX(maxId, h.habitId); }
    editor.nextHabitId = maxId + 1;
    editor.habit = index >= 0 ? self.draft[index] : nil;
    __weak typeof(self) weakSelf = self;
    editor.onDone = ^(TSHsdHabitModel *habit) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        NSMutableArray<TSHsdHabitModel *> *list = [self.draft mutableCopy];
        if (index >= 0 && index < (NSInteger)list.count) { list[index] = habit; } else { [list addObject:habit]; }
        self.draft = list;
        self.dirty = YES;
        [self render];
    };
    editor.onDelete = ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || index < 0) { return; }
        NSMutableArray<TSHsdHabitModel *> *list = [self.draft mutableCopy];
        [list removeObjectAtIndex:index];
        self.draft = list;
        self.dirty = YES;
        [self render];
    };
    [self.navigationController pushViewController:editor animated:YES];
}

#pragma mark - 积木

- (NSArray<UIView *> *)buildBlocks {
    if (self.loadState == 0) { return @[[self loadingBlock:nil]]; }
    __weak typeof(self) weakSelf = self;
    if (self.loadState == 2) { return @[[self errorBlock:self.loadError retry:^{ [weakSelf reload]; }]]; }

    self.invalid = ([self ts_validate] != nil);
    NSUInteger n = self.draft.count;
    BOOL full = n >= TSHsdHabitMaxCount;
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.habit.sec.all") right:[NSString stringWithFormat:@"%lu / %lu", (unsigned long)n, (unsigned long)TSHsdHabitMaxCount]]];
    if (n) {
        [self.draft enumerateObjectsUsingBlock:^(TSHsdHabitModel *h, NSUInteger i, BOOL *stop) {
            TSHsdHabitRowView *row = [[TSHsdHabitRowView alloc] init];
            [row configureWithHabit:h hue:self.hue];
            row.onTap = ^{ [weakSelf ts_editHabitAt:i]; };
            [blocks addObject:[self card:@[row]]];
        }];
    } else {
        [blocks addObject:[self card:@[[self emptyWithSymbol:@"leaf.fill" title:TSLocalizedString(@"hsd.habit.empty_title") text:TSLocalizedString(@"hsd.habit.empty_text") code:nil]]]];
    }
    TSHsdGhostAddButton *add = [[TSHsdGhostAddButton alloc] init];
    add.enabled = !full;
    add.title = full ? TSLocalizedString(@"hsd.limit_reached") : TSLocalizedString(@"hsd.habit.add");
    add.small = full ? @"TSHsdHabitMaxCount = 10" : [NSString stringWithFormat:TSLocalizedString(@"hsd.remaining_format"), (unsigned long)(TSHsdHabitMaxCount - n)];
    add.onTap = ^{ [weakSelf ts_editHabitAt:-1]; };
    [blocks addObject:add];
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.habit.foot")]];
    return blocks;
}

@end
