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

typedef NS_ENUM(NSInteger, TSRepeatPreset) {
    TSRepeatPresetEveryday = 0,
    TSRepeatPresetWorkday,
    TSRepeatPresetWeekend,
    TSRepeatPresetCount
};

@interface TSReminderRepeatVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *optionTitles;
@property (nonatomic, strong) NSArray<NSString *> *presetTitles;
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

    self.presetTitles = @[TSLocalizedString(@"repeat.everyday"),
                          TSLocalizedString(@"repeat.weekday"),
                          TSLocalizedString(@"repeat.weekend")];

    [self ts_setupTableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
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

- (BOOL)isPresetSelected:(TSRepeatPreset)preset {
    switch (preset) {
        case TSRepeatPresetEveryday: return self.selectedDays == eTSReminderRepeatEveryday;
        case TSRepeatPresetWorkday:  return self.selectedDays == eTSReminderRepeatWorkday;
        case TSRepeatPresetWeekend:  return self.selectedDays == eTSReminderRepeatWeekday;
        default: return NO;
    }
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

- (void)selectPreset:(TSRepeatPreset)preset {
    switch (preset) {
        case TSRepeatPresetEveryday: self.selectedDays = eTSReminderRepeatEveryday; break;
        case TSRepeatPresetWorkday:  self.selectedDays = eTSReminderRepeatWorkday;  break;
        case TSRepeatPresetWeekend:  self.selectedDays = eTSReminderRepeatWeekday;  break;
        default: break;
    }
    [self.tableView reloadData];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? TSRepeatPresetCount : TSRepeatOptionCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return TSLocalizedString(@"reminder.repeat.preset");
    return TSLocalizedString(@"reminder.repeat.custom");
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

    BOOL selected = NO;
    if (indexPath.section == 0) {
        TSRepeatPreset preset = (TSRepeatPreset)indexPath.row;
        cell.textLabel.text = self.presetTitles[preset];
        selected = [self isPresetSelected:preset];
    } else {
        TSRepeatOption option = (TSRepeatOption)indexPath.row;
        cell.textLabel.text = self.optionTitles[option];
        selected = [self isOptionSelected:option];
    }

    if (selected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tintColor = TSColor_Primary;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self selectPreset:(TSRepeatPreset)indexPath.row];
    } else {
        [self toggleOption:(TSRepeatOption)indexPath.row];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section != 1) return nil;
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
