//
//  TSHsdParentalControlVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdParentalControlVC.h"
#import "TSHsdParentalControlItemVC.h"

@interface TSHsdParentalControlVC ()
/// 页面草稿（items 中只含手表返回 / 用户配置过的功能项）
@property (nonatomic, strong) TSHsdParentalControlModel *draft;
/// 读取状态：0 加载中 / 1 有数据 / 2 失败
@property (nonatomic, assign) NSInteger loadState;
@property (nonatomic, strong, nullable) NSError *loadError;
@end

@implementation TSHsdParentalControlVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"hsd.parental");
    self.hue = [TSHsdDisplay hueParental];
    self.usesDock = YES;
    self.chips = @[TSLocalizedString(@"hsd.pc.chip")];
    self.draft = [[TSHsdParentalControlModel alloc] init];
    self.draft.items = @[];
}

#pragma mark - 读取 / 保存

- (void)reload {
    self.loadState = 0;
    [self render];
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchParentalControl:" params:nil];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchParentalControl:^(TSHsdParentalControlModel *model, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            if (error || !model) {
                [self finishCall:entry success:NO error:error result:nil];
                self.loadState = 2;
                self.loadError = error;
            } else {
                [self finishCall:entry success:YES error:nil result:[self ts_summaryOf:model]];
                self.draft = [model copy];
                if (!self.draft.items) { self.draft.items = @[]; }
                self.dirty = NO;
                self.loadState = 1;
            }
            [self render];
        }];
    }];
}

/// 本地校验：function 不重复、每项时段数不超上限；返回问题文案，nil 表示通过
- (nullable NSString *)ts_validate {
    NSUInteger maxPeriods = [self ts_maxPeriodCount];
    NSMutableSet<NSNumber *> *seen = [NSMutableSet set];
    for (TSHsdParentalControlItemModel *item in self.draft.items) {
        NSString *name = [TSHsdDisplay parentalFunctionName:item.function];
        if ([seen containsObject:@(item.function)]) {
            return [NSString stringWithFormat:TSLocalizedString(@"hsd.pc.err_duplicate_format"), name];
        }
        [seen addObject:@(item.function)];
        if (item.periods.count > maxPeriods) {
            return [NSString stringWithFormat:TSLocalizedString(@"hsd.pc.err_period_count_format"), name, (long)item.periods.count, (long)maxPeriods];
        }
    }
    return nil;
}

- (void)save {
    if (!self.hsd) { [self toast:TSLocalizedString(@"hsd.error.not_support")]; return; }
    NSString *problem = [self ts_validate];
    if (problem) { [self toast:problem]; return; }
    TSHsdParentalControlModel *sent = [self.draft copy];
    self.saving = YES;
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setParentalControl:completion:" params:[self ts_summaryOf:sent]];
    __weak typeof(self) weakSelf = self;
    [self.hsd setParentalControl:sent completion:^(BOOL isSuccess, NSError *error) {
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

/// 保存成功后立即回读并逐项比对（§3.2）
- (void)ts_readbackAfterSave:(TSHsdParentalControlModel *)sent {
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchParentalControl:" params:TSLocalizedString(@"hsd.log.readback")];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchParentalControl:^(TSHsdParentalControlModel *model, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            self.saving = NO;
            if (error || !model) {
                [self finishCall:entry success:NO error:error result:nil];
                self.dirty = NO;
                [self render];
                [self toast:[NSString stringWithFormat:TSLocalizedString(@"hsd.save.readback_failed_format"), [TSHsdErrorText messageForError:error]]];
                return;
            }
            [self finishCall:entry success:YES error:nil result:[self ts_summaryOf:model]];
            NSArray<TSHsdDiffItem *> *diff = [TSHsdReadbackDiff diffParentalControl:sent read:model];
            self.draft = [model copy];
            if (!self.draft.items) { self.draft.items = @[]; }
            self.dirty = NO;
            [self render];
            if (diff.count == 0) {
                [self toast:TSLocalizedString(@"hsd.save.readback_match")];
            } else {
                [TSHsdReadbackDiff presentDiff:diff from:self];
            }
        }];
    }];
}

- (NSString *)ts_summaryOf:(TSHsdParentalControlModel *)model {
    return [NSString stringWithFormat:@"enabled=%@ · %lu items", model.isEnabled ? @"YES" : @"NO", (unsigned long)model.items.count];
}

- (void)ts_changed {
    self.dirty = YES;
    [self render];
}

#pragma mark - 功能项

/// 每项时段上限：SDK 返回 0（不支持）时退回常量，避免编辑页无法添加
- (NSUInteger)ts_maxPeriodCount {
    NSUInteger count = [self.hsd parentalControlMaxPeriodCount];
    return count > 0 ? count : TSHsdParentalControlPeriodMaxCount;
}

/// 草稿中某个动作对应的功能项；未配置返回 nil
- (nullable TSHsdParentalControlItemModel *)ts_itemForFunction:(TSHsdParentalControlFunction)function {
    for (TSHsdParentalControlItemModel *item in self.draft.items) {
        if (item.function == function) { return item; }
    }
    return nil;
}

/// 用编辑结果替换同 function 的功能项；不存在则按 function 顺序插入
- (void)ts_replaceItem:(TSHsdParentalControlItemModel *)item {
    NSMutableArray<TSHsdParentalControlItemModel *> *list = [self.draft.items mutableCopy];
    NSUInteger existing = [list indexOfObjectPassingTest:^BOOL(TSHsdParentalControlItemModel *obj, NSUInteger idx, BOOL *stop) { return obj.function == item.function; }];
    if (existing != NSNotFound) {
        list[existing] = item;
    } else {
        NSUInteger insertAt = list.count;
        for (NSUInteger i = 0; i < list.count; i++) {
            if (list[i].function > item.function) { insertAt = i; break; }
        }
        [list insertObject:item atIndex:insertAt];
    }
    self.draft.items = list;
    [self ts_changed];
}

- (void)ts_removeItemForFunction:(TSHsdParentalControlFunction)function {
    NSMutableArray<TSHsdParentalControlItemModel *> *list = [self.draft.items mutableCopy];
    [list filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TSHsdParentalControlItemModel *obj, NSDictionary *bindings) { return obj.function != function; }]];
    self.draft.items = list;
    [self ts_changed];
}

- (void)ts_editFunction:(TSHsdParentalControlFunction)function {
    TSHsdParentalControlItemModel *item = [self ts_itemForFunction:function];
    TSHsdParentalControlItemVC *editor = [[TSHsdParentalControlItemVC alloc] init];
    editor.function = function;
    editor.item = item;
    editor.maxPeriodCount = [self ts_maxPeriodCount];
    __weak typeof(self) weakSelf = self;
    editor.onDone = ^(TSHsdParentalControlItemModel *edited) { [weakSelf ts_replaceItem:edited]; };
    if (item) {
        editor.onRemove = ^{ [weakSelf ts_removeItemForFunction:function]; };
    }
    [self.navigationController pushViewController:editor animated:YES];
}

/// 功能项行右侧的状态文案：未设置 / 已关闭 / 时段内禁用 · 2 个时段 / 时段内允许 · 全天
- (NSString *)ts_stateTextForItem:(nullable TSHsdParentalControlItemModel *)item {
    if (!item) { return TSLocalizedString(@"hsd.pc.item.unset"); }
    if (!item.isEnabled) { return TSLocalizedString(@"hsd.pc.item.off"); }
    NSString *mode = [TSHsdDisplay parentalControlModeName:item.mode];
    NSUInteger n = item.periods.count;
    if (n == 0) { return [NSString stringWithFormat:@"%@ · %@", mode, TSLocalizedString(@"hsd.pc.no_period")]; }
    if (n == 1) {
        TSHsdParentalControlPeriodModel *period = item.periods.firstObject;
        NSString *time = period.startMinute == period.endMinute ? TSLocalizedString(@"hsd.pc.all_day")
            : [NSString stringWithFormat:@"%@–%@", [TSHsdDisplay timeStringForMinute:period.startMinute], [TSHsdDisplay timeStringForMinute:period.endMinute]];
        return [NSString stringWithFormat:@"%@ · %@", mode, time];
    }
    return [NSString stringWithFormat:@"%@ · %@", mode, [NSString stringWithFormat:TSLocalizedString(@"hsd.pc.period_count_format"), (long)n]];
}

#pragma mark - 积木

- (NSArray<UIView *> *)buildBlocks {
    if (self.loadState == 0) { return @[[self loadingBlock:nil]]; }
    __weak typeof(self) weakSelf = self;
    if (self.loadState == 2) { return @[[self errorBlock:self.loadError retry:^{ [weakSelf reload]; }]]; }

    self.invalid = ([self ts_validate] != nil);
    TSHsdParentalControlModel *d = self.draft;
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];

    // 总开关卡
    [blocks addObject:[self card:@[
        [self switchRowWithSymbol:@"shield.fill" color:nil title:TSLocalizedString(@"hsd.parental.master")
                         subtitle:d.isEnabled ? TSLocalizedString(@"hsd.pc.master_on") : TSLocalizedString(@"hsd.pc.master_off")
                               on:d.isEnabled onToggle:^(BOOL on) { weakSelf.draft.enabled = on; [weakSelf ts_changed]; }]
    ]]];
    if (!d.isEnabled) {
        [blocks addObject:[self foot:TSLocalizedString(@"hsd.pc.foot_off")]];
    }

    // 受控功能：固定 8 个动作，未配置的显示为「未设置」
    NSUInteger configured = 0;
    NSMutableArray<UIView *> *rows = [NSMutableArray array];
    for (NSInteger function = TSHsdParentalControlFunctionModifyDial; function <= TSHsdParentalControlFunctionModifyAlarm; function++) {
        TSHsdParentalControlItemModel *item = [self ts_itemForFunction:function];
        if (item) { configured++; }
        TSHsdRowView *row = [self valueRowWithSymbol:[TSHsdDisplay symbolForParentalFunction:function]
                                               color:(item && item.isEnabled) ? self.hue : [TSHsdDisplay hueTools]
                                               title:[TSHsdDisplay parentalFunctionName:function]
                                               value:[self ts_stateTextForItem:item]
                                               onTap:^{ [weakSelf ts_editFunction:function]; }];
        row.dim = (item == nil) || !item.isEnabled;
        [rows addObject:row];
    }
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.pc.sec.items")
                          right:[NSString stringWithFormat:TSLocalizedString(@"hsd.pc.configured_format"), (long)configured, (long)(TSHsdParentalControlFunctionModifyAlarm - TSHsdParentalControlFunctionModifyDial + 1)]]];
    [blocks addObject:[self card:rows]];
    [blocks addObject:[self foot:[NSString stringWithFormat:TSLocalizedString(@"hsd.pc.foot_items"), (long)[self ts_maxPeriodCount]]]];
    return blocks;
}

@end
