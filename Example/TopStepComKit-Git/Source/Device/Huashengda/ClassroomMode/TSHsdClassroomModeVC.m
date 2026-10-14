//
//  TSHsdClassroomModeVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdClassroomModeVC.h"

@interface TSHsdClassroomModeVC ()
@property (nonatomic, strong) TSHsdClassroomModeModel *draft;
@property (nonatomic, assign) NSInteger loadState;
@property (nonatomic, strong, nullable) NSError *loadError;
@end

@implementation TSHsdClassroomModeVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"hsd.classroom");
    self.hue = [TSHsdDisplay hueClassroom];
    self.usesDock = YES;
    self.chips = @[@"bit30", TSLocalizedString(@"hsd.classroom.chip")];
    self.draft = [[TSHsdClassroomModeModel alloc] init];
    self.draft.startMinute = 8 * 60;
    self.draft.endMinute = 16 * 60 + 30;
    self.draft.repeatOptions = TSAlarmRepeatWorkday;
}

#pragma mark - 读取 / 保存

- (void)reload {
    self.loadState = 0;
    [self render];
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchClassroomMode:" params:nil];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchClassroomMode:^(TSHsdClassroomModeModel *model, NSError *error) {
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
    NSInteger start = self.draft.startMinute, end = self.draft.endMinute;
    if (start < 0 || start >= TSHsdMinutesPerDay || end < 0 || end >= TSHsdMinutesPerDay) {
        [self toast:TSLocalizedString(@"hsd.error.minute_range")];
        return;
    }
    TSHsdClassroomModeModel *sent = [self.draft copy];
    self.saving = YES;
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setClassroomMode:completion:" params:[self ts_summaryOf:sent]];
    __weak typeof(self) weakSelf = self;
    [self.hsd setClassroomMode:sent completion:^(BOOL isSuccess, NSError *error) {
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

- (void)ts_readbackAfterSave:(TSHsdClassroomModeModel *)sent {
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchClassroomMode:" params:TSLocalizedString(@"hsd.log.readback")];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchClassroomMode:^(TSHsdClassroomModeModel *model, NSError *error) {
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
            NSArray<TSHsdDiffItem *> *diff = [TSHsdReadbackDiff diffClassroom:sent read:model];
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

- (NSString *)ts_summaryOf:(TSHsdClassroomModeModel *)model {
    return [NSString stringWithFormat:@"enabled=%@ %@–%@ repeat=0x%02X", model.isEnabled ? @"YES" : @"NO",
            [TSHsdDisplay timeStringForMinute:model.startMinute], [TSHsdDisplay timeStringForMinute:model.endMinute], (unsigned)model.repeatOptions];
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

    TSHsdClassroomModeModel *d = self.draft;
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];
    [blocks addObject:[self card:@[
        [self switchRowWithSymbol:@"graduationcap.fill" color:nil title:TSLocalizedString(@"hsd.classroom.master")
                         subtitle:d.isEnabled ? TSLocalizedString(@"hsd.classroom.master_on") : TSLocalizedString(@"hsd.classroom.master_off")
                               on:d.isEnabled onToggle:^(BOOL on) { weakSelf.draft.enabled = on; [weakSelf ts_changed]; }]
    ]]];
    if (!d.isEnabled) { return blocks; }

    [blocks addObject:[self sec:TSLocalizedString(@"hsd.classroom.sec.period") right:nil]];
    [blocks addObject:[self card:@[
        [self timelineFrom:d.startMinute to:d.endMinute caption:TSLocalizedString(@"hsd.classroom.timeline_caption")],
        [self duoStart:d.startMinute end:d.endMinute
               onStart:^(NSInteger minute) { weakSelf.draft.startMinute = minute; [weakSelf ts_changed]; }
                 onEnd:^(NSInteger minute) { weakSelf.draft.endMinute = minute; [weakSelf ts_changed]; }]
    ]]];

    [blocks addObject:[self sec:TSLocalizedString(@"hsd.repeat") right:[TSHsdDisplay repeatString:d.repeatOptions]]];
    [blocks addObject:[self card:@[
        [self weekdays:d.repeatOptions presets:[TSHsdWeekdayPreset classroomPresets] onChange:^(TSAlarmRepeat repeat) { weakSelf.draft.repeatOptions = repeat; [weakSelf ts_changed]; }]
    ]]];
    if (d.repeatOptions == TSAlarmRepeatNone) {
        [blocks addObject:[self banner:TSLocalizedString(@"hsd.classroom.banner_no_repeat") warn:YES]];
    }
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.classroom.foot")]];
    return blocks;
}

@end
