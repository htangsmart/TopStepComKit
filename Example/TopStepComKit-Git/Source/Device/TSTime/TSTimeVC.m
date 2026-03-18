//
//  TSTimeVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSTimeVC.h"

typedef NS_ENUM(NSInteger, TSTimeSection) {
    TSTimeSectionFormat = 0,
    TSTimeSectionSync   = 1,
    TSTimeSectionCustom = 2,
    TSTimeSectionCount  = 3,
};

typedef NS_ENUM(NSInteger, TSTimeCustomRow) {
    TSTimeCustomRowPicker  = 0,  // 滚轮选择器
    TSTimeCustomRowDisplay = 1,  // 已选时间预览
    TSTimeCustomRowButton  = 2,  // 推送按钮
    TSTimeCustomRowCount   = 3,
};

// UIDatePickerStyleWheels 固定高度 216pt
static const CGFloat kPickerCellHeight  = 216.f;
static const CGFloat kDisplayCellHeight = 44.f;
static const CGFloat kButtonCellHeight  = 52.f;

static const NSInteger kSegTagTimeFormat = 500;

@interface TSTimeVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView             *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

/// 时间格式（12/24小时制）
@property (nonatomic, assign) TSTimeFormat timeFormat;
/// 时间格式是否已从设备加载
@property (nonatomic, assign) BOOL         formatLoaded;

/// 当前 DatePicker 选中的时间（默认为现在）
@property (nonatomic, strong) NSDate      *selectedDate;
/// 上次同步时间（成功后更新，用于副标题）
@property (nonatomic, strong, nullable) NSDate *lastSyncDate;
/// 同步按钮是否加载中
@property (nonatomic, assign) BOOL        syncing;
/// 自定义时间是否发送中
@property (nonatomic, assign) BOOL        sending;

@end

@implementation TSTimeVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"time.title");
    self.view.backgroundColor = TSColor_Background;
    self.selectedDate = [NSDate date];
    self.timeFormat   = TSTimeFormat12Hour;
    [self ts_setupUI];
    [self ts_fetchTimeFormat];
}

#pragma mark - UI Setup

- (void)ts_setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStyleInsetGrouped];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = TSColor_Background;
    self.tableView.separatorColor  = TSColor_Separator;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];

    self.loadingIndicator = [[UIActivityIndicatorView alloc]
                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.color            = TSColor_Primary;
    self.loadingIndicator.hidesWhenStopped = YES;
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loadingIndicator];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor      constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],

        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];
}

#pragma mark - Fetch

- (void)ts_fetchTimeFormat {
    [self.loadingIndicator startAnimating];
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] unit]
     getCurrentTimeFormat:^(TSTimeFormat format, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            if (!error) weakSelf.timeFormat = format;
            weakSelf.formatLoaded = YES;
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:TSTimeSectionFormat]
                              withRowAnimation:UITableViewRowAnimationNone];
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TSTimeSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TSTimeSectionFormat) return 1;
    if (section == TSTimeSectionSync)   return 1;
    if (section == TSTimeSectionCustom) return TSTimeCustomRowCount;
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == TSTimeSectionFormat) return TSLocalizedString(@"time.format");
    if (section == TSTimeSectionSync)   return TSLocalizedString(@"time.sync_section");
    if (section == TSTimeSectionCustom) return TSLocalizedString(@"time.custom_section");
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == TSTimeSectionFormat) {
        return [self ts_formatCellForTableView:tableView];
    }

    if (indexPath.section == TSTimeSectionSync) {
        return [self ts_syncCellForTableView:tableView];
    }

    if (indexPath.row == TSTimeCustomRowPicker) {
        return [self ts_pickerCellForTableView:tableView];
    }

    if (indexPath.row == TSTimeCustomRowDisplay) {
        return [self ts_displayCellForTableView:tableView];
    }

    return [self ts_buttonCellForTableView:tableView];
}

// ── 时间格式 cell ─────────────────────────────────────────────────────────────

- (UITableViewCell *)ts_formatCellForTableView:(UITableView *)tableView {
    static NSString *cellID = @"kTSFormatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;

        // 左侧图标
        UIView *iconBg = [[UIView alloc] init];
        iconBg.backgroundColor    = TSColor_Warning;
        iconBg.layer.cornerRadius = TSRadius_SM;
        iconBg.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:iconBg];

        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.image       = [UIImage systemImageNamed:@"clock"];
        iconView.tintColor   = UIColor.whiteColor;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [iconBg addSubview:iconView];

        // 标题
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text      = TSLocalizedString(@"time.time_label");
        titleLabel.font      = TSFont_Body;
        titleLabel.textColor = TSColor_TextPrimary;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:titleLabel];

        // 分段控件
        UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[TSLocalizedString(@"unit.12hour"), TSLocalizedString(@"unit.24hour")]];
        seg.tag = kSegTagTimeFormat;
        seg.enabled = NO;
        [seg addTarget:self action:@selector(ts_formatSegmentChanged:)
      forControlEvents:UIControlEventValueChanged];
        seg.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:seg];

        [NSLayoutConstraint activateConstraints:@[
            [iconBg.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor constant:TSSpacing_MD],
            [iconBg.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [iconBg.widthAnchor    constraintEqualToConstant:34.f],
            [iconBg.heightAnchor   constraintEqualToConstant:34.f],

            [iconView.centerXAnchor constraintEqualToAnchor:iconBg.centerXAnchor],
            [iconView.centerYAnchor constraintEqualToAnchor:iconBg.centerYAnchor],
            [iconView.widthAnchor   constraintEqualToConstant:20.f],
            [iconView.heightAnchor  constraintEqualToConstant:20.f],

            [titleLabel.leadingAnchor  constraintEqualToAnchor:iconBg.trailingAnchor constant:TSSpacing_SM + 4],
            [titleLabel.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:seg.leadingAnchor constant:-TSSpacing_SM],

            [seg.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-TSSpacing_MD],
            [seg.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [seg.widthAnchor    constraintEqualToConstant:190.f],
        ]];
    }

    UISegmentedControl *seg = (UISegmentedControl *)[cell.contentView viewWithTag:kSegTagTimeFormat];
    seg.enabled = self.formatLoaded;
    seg.selectedSegmentIndex = self.formatLoaded
        ? (self.timeFormat == TSTimeFormat12Hour ? 0 : 1)
        : UISegmentedControlNoSegment;
    return cell;
}

// ── 同步时间 cell ────────────────────────────────────────────────────────────

- (UITableViewCell *)ts_syncCellForTableView:(UITableView *)tableView {
    static NSString *cellID = @"kTSSyncCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellID];
        cell.backgroundColor           = TSColor_Card;
        cell.textLabel.font            = TSFont_Body;
        cell.textLabel.textColor       = TSColor_TextPrimary;
        cell.detailTextLabel.font      = TSFont_Caption;
        cell.detailTextLabel.textColor = TSColor_TextSecondary;

        // 左侧图标
        UIView *iconBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
        iconBg.backgroundColor    = TSColor_Primary;
        iconBg.layer.cornerRadius = TSRadius_SM;
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 20, 20)];
        iconView.image       = [UIImage systemImageNamed:@"clock.arrow.2.circlepath"];
        iconView.tintColor   = UIColor.whiteColor;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        [iconBg addSubview:iconView];
        cell.imageView.image = [self ts_imageFromView:iconBg size:CGSizeMake(34, 34)];
    }

    cell.textLabel.text = TSLocalizedString(@"time.sync_system");
    if (self.lastSyncDate) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"HH:mm:ss";
        cell.detailTextLabel.text = [NSString stringWithFormat:TSLocalizedString(@"time.last_sync_format"),
                                     [fmt stringFromDate:self.lastSyncDate]];
    } else {
        cell.detailTextLabel.text = TSLocalizedString(@"time.sync_hint");
    }

    if (self.syncing) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        [spinner startAnimating];
        cell.accessoryView = spinner;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.accessoryView  = nil;
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    return cell;
}

// ── DatePicker cell ──────────────────────────────────────────────────────────

- (UITableViewCell *)ts_pickerCellForTableView:(UITableView *)tableView {
    static NSString *cellID = @"kTSPickerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;

        UIDatePicker *picker = [[UIDatePicker alloc] init];
        picker.datePickerMode = UIDatePickerModeDateAndTime;
        if (@available(iOS 14.0, *)) {
            picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        picker.tintColor = TSColor_Primary;
        picker.tag = 999;
        picker.translatesAutoresizingMaskIntoConstraints = NO;
        [picker addTarget:self action:@selector(ts_datePickerChanged:)
         forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:picker];

        [NSLayoutConstraint activateConstraints:@[
            [picker.topAnchor      constraintEqualToAnchor:cell.contentView.topAnchor    constant:TSSpacing_SM],
            [picker.bottomAnchor   constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-TSSpacing_SM],
            [picker.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor constant:TSSpacing_SM],
            [picker.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-TSSpacing_SM],
        ]];
    }

    UIDatePicker *picker = (UIDatePicker *)[cell.contentView viewWithTag:999];
    [picker setDate:self.selectedDate animated:NO];
    return cell;
}

// ── 已选时间预览 cell ──────────────────────────────────────────────────────────

- (UITableViewCell *)ts_displayCellForTableView:(UITableView *)tableView {
    static NSString *cellID = @"kTSDisplayCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellID];
        cell.backgroundColor           = TSColor_Card;
        cell.selectionStyle            = UITableViewCellSelectionStyleNone;
        cell.textLabel.font            = TSFont_Caption;
        cell.textLabel.textColor       = TSColor_TextSecondary;
        cell.detailTextLabel.font      = TSFont_Body;
        cell.detailTextLabel.textColor = TSColor_TextPrimary;
    }

    cell.textLabel.text = TSLocalizedString(@"time.selected_time");
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd  HH:mm";
    cell.detailTextLabel.text = [fmt stringFromDate:self.selectedDate];
    return cell;
}

// ── 推送按钮 cell ─────────────────────────────────────────────────────────────

- (UITableViewCell *)ts_buttonCellForTableView:(UITableView *)tableView {
    static NSString *cellID = @"kTSSendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = 888;
        btn.backgroundColor    = TSColor_Primary;
        btn.layer.cornerRadius = TSRadius_MD;
        btn.layer.masksToBounds = YES;
        btn.tintColor          = UIColor.whiteColor;
        [btn setTitle:TSLocalizedString(@"time.push_to_watch") forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
        [btn addTarget:self action:@selector(ts_sendCustomTime) forControlEvents:UIControlEventTouchUpInside];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:btn];

        [NSLayoutConstraint activateConstraints:@[
            [btn.topAnchor      constraintEqualToAnchor:cell.contentView.topAnchor    constant:TSSpacing_SM],
            [btn.bottomAnchor   constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-TSSpacing_SM],
            [btn.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor constant:TSSpacing_MD],
            [btn.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-TSSpacing_MD],
        ]];
    }

    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:888];
    btn.enabled = !self.sending;
    btn.alpha   = self.sending ? 0.5f : 1.f;

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TSTimeSectionFormat)  return 62.f;
    if (indexPath.section == TSTimeSectionSync)    return 60.f;
    if (indexPath.row == TSTimeCustomRowPicker)    return kPickerCellHeight;
    if (indexPath.row == TSTimeCustomRowDisplay)   return kDisplayCellHeight;
    if (indexPath.row == TSTimeCustomRowButton)    return kButtonCellHeight;
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == TSTimeSectionSync && !self.syncing) {
        [self ts_syncSystemTime];
    }
}

#pragma mark - DatePicker Action

- (void)ts_datePickerChanged:(UIDatePicker *)picker {
    self.selectedDate = picker.date;
    [self.tableView reloadRowsAtIndexPaths:
     @[[NSIndexPath indexPathForRow:TSTimeCustomRowDisplay inSection:TSTimeSectionCustom]]
                          withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Format Segment Action

- (void)ts_formatSegmentChanged:(UISegmentedControl *)sender {
    TSTimeFormat prev = self.timeFormat;
    TSTimeFormat next = (sender.selectedSegmentIndex == 0) ? TSTimeFormat12Hour : TSTimeFormat24Hour;

    sender.enabled = NO;
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] unit]
     setTimeFormat:next completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (success) {
                weakSelf.timeFormat = next;
                [weakSelf ts_showToast:(next == TSTimeFormat12Hour) ? TSLocalizedString(@"unit.set_12hour") : TSLocalizedString(@"unit.set_24hour")];
            } else {
                sender.selectedSegmentIndex = (prev == TSTimeFormat12Hour) ? 0 : 1;
                NSString *msg = error.localizedDescription ?: TSLocalizedString(@"general.set_failed_retry");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"general.set_failed")
                                                                               message:msg
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm") style:UIAlertActionStyleDefault handler:nil]];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

#pragma mark - Sync System Time

- (void)ts_syncSystemTime {
    self.syncing = YES;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:TSTimeSectionSync]]
                          withRowAnimation:UITableViewRowAnimationNone];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] time]
     setSystemTimeWithCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.syncing = NO;
            if (success) {
                weakSelf.lastSyncDate = [NSDate date];
                TSLog(@"系统时间同步成功");
                [weakSelf ts_showToast:TSLocalizedString(@"time.sync_success")];
            } else {
                TSLog(@"系统时间同步失败: %@", error.localizedDescription);
                [weakSelf ts_showToast:TSLocalizedString(@"time.sync_failed_retry")];
            }
            [weakSelf.tableView reloadRowsAtIndexPaths:
             @[[NSIndexPath indexPathForRow:0 inSection:TSTimeSectionSync]]
                                      withRowAnimation:UITableViewRowAnimationNone];
        });
    }];
}

#pragma mark - Send Custom Time

- (void)ts_sendCustomTime {
    if (self.sending) return;
    self.sending = YES;
    [self.tableView reloadRowsAtIndexPaths:
     @[[NSIndexPath indexPathForRow:TSTimeCustomRowButton inSection:TSTimeSectionCustom]]
                          withRowAnimation:UITableViewRowAnimationNone];

    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    TSLog(@"设置自定义时间: %@", [fmt stringFromDate:self.selectedDate]);

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] time]
     setSpecificTime:self.selectedDate
          completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.sending = NO;
            if (success) {
                TSLog(@"自定义时间设置成功");
                [weakSelf ts_showToast:TSLocalizedString(@"time.push_success")];
            } else {
                TSLog(@"自定义时间设置失败: %@", error.localizedDescription);
                [weakSelf ts_showToast:TSLocalizedString(@"time.push_failed_retry")];
            }
            [weakSelf.tableView reloadRowsAtIndexPaths:
             @[[NSIndexPath indexPathForRow:TSTimeCustomRowButton inSection:TSTimeSectionCustom]]
                                      withRowAnimation:UITableViewRowAnimationNone];
        });
    }];
}

#pragma mark - Toast

- (void)ts_showToast:(NSString *)message {
    UILabel *toast = [[UILabel alloc] init];
    toast.text             = message;
    toast.font             = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    toast.textColor        = UIColor.whiteColor;
    toast.textAlignment    = NSTextAlignmentCenter;
    toast.backgroundColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    toast.layer.cornerRadius  = 18.f;
    toast.layer.masksToBounds = YES;
    toast.alpha            = 0;

    CGFloat hPad  = TSSpacing_LG, vPad = TSSpacing_SM;
    CGFloat maxW  = self.view.bounds.size.width - TSSpacing_XL * 2;
    CGSize textSz = [message boundingRectWithSize:CGSizeMake(maxW - hPad * 2, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: toast.font}
                                          context:nil].size;
    CGFloat w = textSz.width  + hPad * 2;
    CGFloat h = textSz.height + vPad * 2;
    CGFloat x = (self.view.bounds.size.width - w) / 2.f;
    CGFloat y = self.view.bounds.size.height - h - TSSpacing_XL - self.view.safeAreaInsets.bottom;
    toast.frame = CGRectMake(x, y, w, h);

    [self.view addSubview:toast];
    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1; } completion:^(BOOL _) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{ toast.alpha = 0; }
                             completion:^(BOOL __) { [toast removeFromSuperview]; }];
        });
    }];
}

#pragma mark - Helpers

/// 将 UIView 渲染成 UIImage（用于 cell.imageView）
- (UIImage *)ts_imageFromView:(UIView *)view size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
