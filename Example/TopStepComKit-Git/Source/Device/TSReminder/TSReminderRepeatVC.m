//
//  TSReminderRepeatVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSReminderRepeatVC.h"
#import "TSBaseVC.h"

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

@interface TSReminderRepeatVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *optionTitles;
@end

@implementation TSReminderRepeatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"reminder.repeat");
    self.view.backgroundColor = TSColor_Background;

    self.optionTitles = @[TSLocalizedString(@"repeat.never"),
                          TSLocalizedString(@"weekday.mon"), TSLocalizedString(@"weekday.tue"),
                          TSLocalizedString(@"weekday.wed"), TSLocalizedString(@"weekday.thu"),
                          TSLocalizedString(@"weekday.fri"), TSLocalizedString(@"weekday.sat"),
                          TSLocalizedString(@"weekday.sun")];

    [self ts_setupTableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topOffset = 0;
    if (@available(iOS 11.0, *)) {
        topOffset = self.view.safeAreaInsets.top;
    }
    self.tableView.frame = CGRectMake(0, topOffset, self.view.bounds.size.width, self.view.bounds.size.height - topOffset);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController && self.onDaysChanged) {
        self.onDaysChanged(self.selectedDays);
    }
}

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

- (BOOL)isOptionSelected:(TSRepeatOption)option {
    if (option == TSRepeatOptionNever) {
        return self.selectedDays == 0;
    }
    TSReminderDays dayBit = (1 << (option - 1));
    return (self.selectedDays & dayBit) != 0;
}

- (void)toggleOption:(TSRepeatOption)option {
    if (option == TSRepeatOptionNever) {
        self.selectedDays = 0;
    } else {
        TSReminderDays dayBit = (1 << (option - 1));
        if (self.selectedDays & dayBit) {
            self.selectedDays &= ~dayBit;
        } else {
            self.selectedDays |= dayBit;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - UITableView

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.textColor = TSColor_TextPrimary;
    }

    TSRepeatOption option = (TSRepeatOption)indexPath.row;
    cell.textLabel.text = self.optionTitles[option];

    if ([self isOptionSelected:option]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tintColor = TSColor_Primary;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TSRepeatOption option = (TSRepeatOption)indexPath.row;
    [self toggleOption:option];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (self.selectedDays == 0) {
        return TSLocalizedString(@"reminder.repeat.once_hint");
    } else if (self.selectedDays == eTSReminderRepeatEveryday) {
        return TSLocalizedString(@"reminder.repeat.everyday_hint");
    } else if (self.selectedDays == eTSReminderRepeatWorkday) {
        return TSLocalizedString(@"reminder.repeat.workday_hint");
    } else if (self.selectedDays == eTSReminderRepeatWeekday) {
        return TSLocalizedString(@"reminder.repeat.weekend_hint");
    } else {
        NSMutableArray *days = [NSMutableArray array];
        if (self.selectedDays & eTSReminderDayMonday)    [days addObject:TSLocalizedString(@"weekday.mon")];
        if (self.selectedDays & eTSReminderDayTuesday)   [days addObject:TSLocalizedString(@"weekday.tue")];
        if (self.selectedDays & eTSReminderDayWednesday) [days addObject:TSLocalizedString(@"weekday.wed")];
        if (self.selectedDays & eTSReminderDayThursday)  [days addObject:TSLocalizedString(@"weekday.thu")];
        if (self.selectedDays & eTSReminderDayFriday)    [days addObject:TSLocalizedString(@"weekday.fri")];
        if (self.selectedDays & eTSReminderDaySaturday)  [days addObject:TSLocalizedString(@"weekday.sat")];
        if (self.selectedDays & eTSReminderDaySunday)    [days addObject:TSLocalizedString(@"weekday.sun")];
        if (days.count > 0) {
            return [NSString stringWithFormat:TSLocalizedString(@"reminder.repeat.custom_format"), [days componentsJoinedByString:TSLocalizedString(@"reminder.day_separator")]];
        }
    }
    return nil;
}

@end
