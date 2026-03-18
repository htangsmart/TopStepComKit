//
//  TSAlarmRepeatVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSAlarmRepeatVC.h"
#import "TSBaseVC.h"

// ─── 重复选项 Cell ─────────────────────────────────────────────────────────
@interface TSRepeatOptionCell : UITableViewCell
@end

@implementation TSRepeatOptionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.backgroundColor = TSColor_Card;
    self.textLabel.font = [UIFont systemFontOfSize:17];
    self.textLabel.textColor = TSColor_TextPrimary;

    return self;
}

@end

// ─── TSAlarmRepeatVC ───────────────────────────────────────────────────────
typedef NS_ENUM(NSInteger, TSRepeatOption) {
    TSRepeatOptionNever = 0,
    TSRepeatOptionMonday,
    TSRepeatOptionTuesday,
    TSRepeatOptionWednesday,
    TSRepeatOptionThursday,
    TSRepeatOptionFriday,
    TSRepeatOptionSaturday,
    TSRepeatOptionSunday,
    TSRepeatOptionCount
};

@interface TSAlarmRepeatVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *optionTitles;
@end

@implementation TSAlarmRepeatVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"reminder.repeat");
    self.view.backgroundColor = TSColor_Background;

    self.optionTitles = @[TSLocalizedString(@"repeat.never"),
                          TSLocalizedString(@"weekday.mon"), TSLocalizedString(@"weekday.tue"),
                          TSLocalizedString(@"weekday.wed"), TSLocalizedString(@"weekday.thu"),
                          TSLocalizedString(@"weekday.fri"), TSLocalizedString(@"weekday.sat"),
                          TSLocalizedString(@"weekday.sun")];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.done")
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(ts_done)];
    self.navigationItem.rightBarButtonItem = doneButton;

    [self ts_setupTableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat topOffset = 0;
    if (@available(iOS 11.0, *)) {
        topOffset = self.view.safeAreaInsets.top;
    }

    self.tableView.frame = CGRectMake(0, topOffset,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height - topOffset);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 返回时触发回调
    if (self.isMovingFromParentViewController && self.onRepeatChanged) {
        self.onRepeatChanged(self.selectedRepeat);
    }
}

#pragma mark - Actions

- (void)ts_done {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setup

- (void)ts_setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = TSColor_Background;
    self.tableView.separatorColor  = TSColor_Separator;

    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }

    [self.view addSubview:self.tableView];
}

#pragma mark - Helpers

- (BOOL)isOptionSelected:(TSRepeatOption)option {
    if (option == TSRepeatOptionNever) {
        return self.selectedRepeat == TSAlarmRepeatNone;
    }

    // 周一~周日对应 bit 0~6
    TSAlarmRepeat dayBit = (1 << (option - 1));
    return (self.selectedRepeat & dayBit) != 0;
}

- (void)toggleOption:(TSRepeatOption)option {
    if (option == TSRepeatOptionNever) {
        // 选择"永不"，清空所有重复
        self.selectedRepeat = TSAlarmRepeatNone;
    } else {
        // 切换某一天
        TSAlarmRepeat dayBit = (1 << (option - 1));

        if (self.selectedRepeat & dayBit) {
            // 取消选中
            self.selectedRepeat &= ~dayBit;
        } else {
            // 选中
            self.selectedRepeat |= dayBit;

            // 如果之前是"永不"，现在有选中的天，需要清除"永不"状态
            // （实际上 TSAlarmRepeatNone = 0，不需要特殊处理）
        }
    }

    [self.tableView reloadData];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TSRepeatOptionCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"kTSRepeatOptionCell";
    TSRepeatOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[TSRepeatOptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    TSRepeatOption option = (TSRepeatOption)indexPath.row;
    cell.textLabel.text = self.optionTitles[option];

    // 显示勾选状态
    if ([self isOptionSelected:option]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tintColor = TSColor_Primary;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    TSRepeatOption option = (TSRepeatOption)indexPath.row;
    [self toggleOption:option];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    // 显示当前选择的汇总
    if (self.selectedRepeat == TSAlarmRepeatNone) {
        return TSLocalizedString(@"alarm.repeat.desc.once");
    } else if (self.selectedRepeat == TSAlarmRepeatEveryday) {
        return TSLocalizedString(@"alarm.repeat.desc.everyday");
    } else if (self.selectedRepeat == TSAlarmRepeatWorkday) {
        return TSLocalizedString(@"alarm.repeat.desc.weekday");
    } else if (self.selectedRepeat == TSAlarmRepeatWeekend) {
        return TSLocalizedString(@"alarm.repeat.desc.weekend");
    } else {
        NSMutableArray *days = [NSMutableArray array];
        if (self.selectedRepeat & TSAlarmRepeatMonday)    [days addObject:TSLocalizedString(@"weekday.mon")];
        if (self.selectedRepeat & TSAlarmRepeatTuesday)   [days addObject:TSLocalizedString(@"weekday.tue")];
        if (self.selectedRepeat & TSAlarmRepeatWednesday) [days addObject:TSLocalizedString(@"weekday.wed")];
        if (self.selectedRepeat & TSAlarmRepeatThursday)  [days addObject:TSLocalizedString(@"weekday.thu")];
        if (self.selectedRepeat & TSAlarmRepeatFriday)    [days addObject:TSLocalizedString(@"weekday.fri")];
        if (self.selectedRepeat & TSAlarmRepeatSaturday)  [days addObject:TSLocalizedString(@"weekday.sat")];
        if (self.selectedRepeat & TSAlarmRepeatSunday)    [days addObject:TSLocalizedString(@"weekday.sun")];

        if (days.count > 0) {
            return [NSString stringWithFormat:TSLocalizedString(@"alarm.repeat.desc.custom"), [days componentsJoinedByString:TSLocalizedString(@"reminder.day_separator")]];
        }
    }

    return nil;
}

@end
