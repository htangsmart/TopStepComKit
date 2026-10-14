//
//  TSHsdParentalModeVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdParentalModeVC.h"

@interface TSHsdParentalModeVC ()
/// 页面草稿
@property (nonatomic, strong) TSHsdParentalModeModel *draft;
/// 读取状态：0 加载中 / 1 有数据 / 2 失败
@property (nonatomic, assign) NSInteger loadState;
@property (nonatomic, strong, nullable) NSError *loadError;
@end

@implementation TSHsdParentalModeVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"hsd.parental");
    self.hue = [TSHsdDisplay hueParental];
    self.usesDock = YES;
    self.chips = @[TSLocalizedString(@"hsd.parental.basic_chip")];
    self.draft = [[TSHsdParentalModeModel alloc] init];
    self.draft.gameStartMinute = 18 * 60;
    self.draft.gameEndMinute = 20 * 60;
}

#pragma mark - 读取 / 保存

- (void)reload {
    self.loadState = 0;
    [self render];
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchParentalMode:" params:nil];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchParentalMode:^(TSHsdParentalModeModel *model, NSError *error) {
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
                self.dirty = NO;
                self.loadState = 1;
            }
            [self render];
        }];
    }];
}

- (void)save {
    if (!self.hsd) { [self toast:TSLocalizedString(@"hsd.error.not_support")]; return; }
    NSInteger start = self.draft.gameStartMinute, end = self.draft.gameEndMinute;
    if (start < 0 || start >= TSHsdMinutesPerDay || end < 0 || end >= TSHsdMinutesPerDay) {
        [self toast:TSLocalizedString(@"hsd.error.minute_range")];
        return;
    }
    TSHsdParentalModeModel *sent = [self.draft copy];
    self.saving = YES;
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setParentalMode:completion:" params:[self ts_summaryOf:sent]];
    __weak typeof(self) weakSelf = self;
    [self.hsd setParentalMode:sent completion:^(BOOL isSuccess, NSError *error) {
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

/// 保存成功后立即回读并逐字段比对（§3.2，对应 D-12）
- (void)ts_readbackAfterSave:(TSHsdParentalModeModel *)sent {
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchParentalMode:" params:TSLocalizedString(@"hsd.log.readback")];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchParentalMode:^(TSHsdParentalModeModel *model, NSError *error) {
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
            NSArray<TSHsdDiffItem *> *diff = [TSHsdReadbackDiff diffParental:sent read:model];
            self.draft = [model copy];
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

- (NSString *)ts_summaryOf:(TSHsdParentalModeModel *)model {
    return [NSString stringWithFormat:@"enabled=%@ game=%@–%@", model.isEnabled ? @"YES" : @"NO",
            [TSHsdDisplay timeStringForMinute:model.gameStartMinute], [TSHsdDisplay timeStringForMinute:model.gameEndMinute]];
}

- (void)ts_changed {
    self.dirty = YES;
    [self render];
}

#pragma mark - 积木

- (NSArray<UIView *> *)buildBlocks {
    if (self.loadState == 0) { return @[[self loadingBlock:nil]]; }
    __weak typeof(self) weakSelf = self;
    if (self.loadState == 2) { return @[[self errorBlock:self.loadError retry:^{ [weakSelf reload]; }]]; }

    TSHsdParentalModeModel *d = self.draft;
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];

    // 主开关卡
    [blocks addObject:[self card:@[
        [self switchRowWithSymbol:@"shield.fill" color:nil title:TSLocalizedString(@"hsd.parental.master")
                         subtitle:d.isEnabled ? TSLocalizedString(@"hsd.parental.master_on") : TSLocalizedString(@"hsd.parental.master_off")
                               on:d.isEnabled onToggle:^(BOOL on) { weakSelf.draft.enabled = on; [weakSelf ts_changed]; }]
    ]]];
    if (!d.isEnabled) {
        [blocks addObject:[self foot:TSLocalizedString(@"hsd.parental.foot_off")]];
        return blocks;
    }

    // 手表上允许的操作
    UIColor *slate = [TSHsdDisplay hueTools];
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.parental.sec.permissions") right:nil]];
    [blocks addObject:[self card:@[
        [self switchRowWithSymbol:@"clock" color:slate title:TSLocalizedString(@"hsd.parental.time_setting") subtitle:TSLocalizedString(@"hsd.parental.time_setting_sub")
                               on:d.isTimeSettingEnabled onToggle:^(BOOL on) { weakSelf.draft.timeSettingEnabled = on; [weakSelf ts_changed]; }],
        [self switchRowWithSymbol:@"slider.horizontal.3" color:slate title:TSLocalizedString(@"hsd.parental.enter_setting") subtitle:TSLocalizedString(@"hsd.parental.enter_setting_sub")
                               on:d.isEnterSettingEnabled onToggle:^(BOOL on) { weakSelf.draft.enterSettingEnabled = on; [weakSelf ts_changed]; }],
        [self switchRowWithSymbol:@"alarm" color:slate title:TSLocalizedString(@"hsd.parental.alarm_setting") subtitle:TSLocalizedString(@"hsd.parental.alarm_setting_sub")
                               on:d.isAlarmSettingEnabled onToggle:^(BOOL on) { weakSelf.draft.alarmSettingEnabled = on; [weakSelf ts_changed]; }],
    ]]];
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.parental.foot_polarity")]];

    // 游戏
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.parental.sec.game") right:nil]];
    NSMutableArray<UIView *> *gameRows = [NSMutableArray array];
    [gameRows addObject:[self switchRowWithSymbol:@"gamecontroller.fill" color:[TSHsdDisplay hueGame] title:TSLocalizedString(@"hsd.parental.game_limit")
                                         subtitle:d.isGameDurationEnabled ? TSLocalizedString(@"hsd.parental.game_limit_on") : TSLocalizedString(@"hsd.parental.game_limit_off")
                                               on:d.isGameDurationEnabled onToggle:^(BOOL on) { weakSelf.draft.gameDurationEnabled = on; [weakSelf ts_changed]; }]];
    if (d.isGameDurationEnabled) {
        [gameRows addObject:[self timelineFrom:d.gameStartMinute to:d.gameEndMinute caption:TSLocalizedString(@"hsd.parental.timeline_caption")]];
        [gameRows addObject:[self duoStart:d.gameStartMinute end:d.gameEndMinute
                                   onStart:^(NSInteger minute) { weakSelf.draft.gameStartMinute = minute; [weakSelf ts_changed]; }
                                     onEnd:^(NSInteger minute) { weakSelf.draft.gameEndMinute = minute; [weakSelf ts_changed]; }]];
    }
    [blocks addObject:[self card:gameRows]];
    if (d.isGameDurationEnabled) {
        [blocks addObject:[self foot:TSLocalizedString(@"hsd.parental.foot_next_day")]];
    }
    return blocks;
}

@end
