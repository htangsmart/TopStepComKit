//
//  TSUnitVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSUnitVC.h"

typedef NS_ENUM(NSInteger, TSUnitRow) {
    TSUnitRowLength      = 0,
    TSUnitRowTemperature = 1,
    TSUnitRowWeight      = 2,
    TSUnitRowTime        = 3,
    TSUnitRowCount       = 4,
};

// tag = kSegTagBase + row，用于 action 回调中识别行号
static const NSInteger kSegTagBase = 100;

// contentView 内子视图 tag（固定，不含行信息）
static const NSInteger kTagIconBg    = 201;
static const NSInteger kTagIconView  = 202; // iconView 在 iconBg 内，viewWithTag 会递归搜到
static const NSInteger kTagTitle     = 203;

@interface TSUnitVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView             *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, assign) BOOL                    dataLoaded;

// 当前已生效的单位值
@property (nonatomic, assign) TSLengthUnit      lengthUnit;
@property (nonatomic, assign) TSTemperatureUnit temperatureUnit;
@property (nonatomic, assign) TSWeightUnit      weightUnit;
@property (nonatomic, assign) TSTimeFormat      timeFormat;

@end

@implementation TSUnitVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"单位设置";
    self.view.backgroundColor = TSColor_Background;
    [self ts_setupUI];
    [self ts_fetchAllUnits];
}

#pragma mark - UI Setup

- (void)ts_setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStyleInsetGrouped];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = TSColor_Background;
    self.tableView.separatorColor  = TSColor_Separator;
    self.tableView.scrollEnabled   = NO;
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

    [self.loadingIndicator startAnimating];
}

#pragma mark - Fetch

- (void)ts_fetchAllUnits {
    __weak typeof(self) weakSelf = self;
    dispatch_group_t group = dispatch_group_create();

    __block TSLengthUnit      fetchedLength = TSLengthUnitMetric;
    __block TSTemperatureUnit fetchedTemp   = TSTemperatureUnitCelsius;
    __block TSWeightUnit      fetchedWeight = TSWeightUnitKG;
    __block TSTimeFormat      fetchedTime   = TSTimeFormat12Hour;

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] unit]
     getCurrentLengthUnit:^(TSLengthUnit unit, NSError *error) {
        if (!error) fetchedLength = unit;
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] unit]
     getCurrentTemperatureUnit:^(TSTemperatureUnit unit, NSError *error) {
        if (!error) fetchedTemp = unit;
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] unit]
     getCurrentWeightUnit:^(TSWeightUnit unit, NSError *error) {
        if (!error) fetchedWeight = unit;
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] unit]
     getCurrentTimeFormat:^(TSTimeFormat format, NSError *error) {
        if (!error) fetchedTime = format;
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [weakSelf.loadingIndicator stopAnimating];
        weakSelf.lengthUnit      = fetchedLength;
        weakSelf.temperatureUnit = fetchedTemp;
        weakSelf.weightUnit      = fetchedWeight;
        weakSelf.timeFormat      = fetchedTime;
        weakSelf.dataLoaded      = YES;
        [weakSelf.tableView reloadData];
    });
}

#pragma mark - Row Metadata Helpers

- (NSString *)ts_iconNameForRow:(NSInteger)row {
    switch (row) {
        case TSUnitRowLength:      return @"ruler";
        case TSUnitRowTemperature: return @"thermometer";
        case TSUnitRowWeight:      return @"scalemass";
        case TSUnitRowTime:        return @"clock";
        default:                   return @"";
    }
}

- (UIColor *)ts_iconColorForRow:(NSInteger)row {
    switch (row) {
        case TSUnitRowLength:      return TSColor_Primary;
        case TSUnitRowTemperature: return TSColor_Danger;
        case TSUnitRowWeight:      return TSColor_Success;
        case TSUnitRowTime:        return TSColor_Warning;
        default:                   return TSColor_Gray;
    }
}

- (NSString *)ts_titleForRow:(NSInteger)row {
    switch (row) {
        case TSUnitRowLength:      return @"长度";
        case TSUnitRowTemperature: return @"温度";
        case TSUnitRowWeight:      return @"重量";
        case TSUnitRowTime:        return @"时间";
        default:                   return @"";
    }
}

- (NSArray<NSString *> *)ts_segmentTitlesForRow:(NSInteger)row {
    switch (row) {
        case TSUnitRowLength:      return @[@"公里 km", @"英里 mi"];
        case TSUnitRowTemperature: return @[@"摄氏 °C",  @"华氏 °F"];
        case TSUnitRowWeight:      return @[@"KG",       @"LB"];
        case TSUnitRowTime:        return @[@"12 小时",  @"24 小时"];
        default:                   return @[];
    }
}

- (NSInteger)ts_selectedIndexForRow:(NSInteger)row {
    switch (row) {
        case TSUnitRowLength:      return (self.lengthUnit      == TSLengthUnitMetric)        ? 0 : 1;
        case TSUnitRowTemperature: return (self.temperatureUnit == TSTemperatureUnitCelsius)  ? 0 : 1;
        case TSUnitRowWeight:      return (self.weightUnit      == TSWeightUnitKG)            ? 0 : 1;
        case TSUnitRowTime:        return (self.timeFormat      == TSTimeFormat12Hour)        ? 0 : 1;
        default:                   return 0;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TSUnitRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row    = indexPath.row;
    NSString *cellID = [NSString stringWithFormat:@"kTSUnitCell_%ld", (long)row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;

        // ── Icon container ──────────────────────────────────────────
        UIView *iconBg = [[UIView alloc] init];
        iconBg.layer.cornerRadius = TSRadius_SM;
        iconBg.tag = kTagIconBg;
        iconBg.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:iconBg];

        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.tintColor   = UIColor.whiteColor;
        iconView.tag = kTagIconView;
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [iconBg addSubview:iconView];

        // ── Title label ─────────────────────────────────────────────
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font      = TSFont_Body;
        titleLabel.textColor = TSColor_TextPrimary;
        titleLabel.tag = kTagTitle;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:titleLabel];

        // ── Segmented control ────────────────────────────────────────
        NSArray<NSString *> *titles = [self ts_segmentTitlesForRow:row];
        UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:titles];
        seg.tag = kSegTagBase + row;
        seg.enabled = NO;
        [seg addTarget:self action:@selector(ts_segmentChanged:)
      forControlEvents:UIControlEventValueChanged];
        seg.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:seg];

        // ── Layout ───────────────────────────────────────────────────
        [NSLayoutConstraint activateConstraints:@[
            // iconBg: 34×34, left-pinned, centered vertically
            [iconBg.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor constant:TSSpacing_MD],
            [iconBg.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [iconBg.widthAnchor    constraintEqualToConstant:34.f],
            [iconBg.heightAnchor   constraintEqualToConstant:34.f],

            // iconView: 20×20, centered in iconBg
            [iconView.centerXAnchor constraintEqualToAnchor:iconBg.centerXAnchor],
            [iconView.centerYAnchor constraintEqualToAnchor:iconBg.centerYAnchor],
            [iconView.widthAnchor   constraintEqualToConstant:20.f],
            [iconView.heightAnchor  constraintEqualToConstant:20.f],

            // titleLabel: follows iconBg, flexible width
            [titleLabel.leadingAnchor  constraintEqualToAnchor:iconBg.trailingAnchor constant:TSSpacing_SM + 4],
            [titleLabel.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:seg.leadingAnchor constant:-TSSpacing_SM],

            // seg: right-pinned, fixed 190pt width, centered vertically
            [seg.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-TSSpacing_MD],
            [seg.centerYAnchor  constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [seg.widthAnchor    constraintEqualToConstant:190.f],
        ]];
    }

    // ── Configure (called every reloadData) ──────────────────────────
    UIView          *iconBg    = [cell.contentView viewWithTag:kTagIconBg];
    UIImageView     *iconView  = (UIImageView *)[cell.contentView viewWithTag:kTagIconView];
    UILabel         *titleLbl  = (UILabel *)[cell.contentView viewWithTag:kTagTitle];
    UISegmentedControl *seg    = (UISegmentedControl *)[cell.contentView viewWithTag:kSegTagBase + row];

    iconBg.backgroundColor = [self ts_iconColorForRow:row];
    iconView.image = [UIImage systemImageNamed:[self ts_iconNameForRow:row]];
    titleLbl.text  = [self ts_titleForRow:row];
    seg.enabled    = self.dataLoaded;
    seg.selectedSegmentIndex = self.dataLoaded
        ? [self ts_selectedIndexForRow:row]
        : UISegmentedControlNoSegment;

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"单位设置";
}

// 禁止点击行（交互完全由 UISegmentedControl 处理）
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Segment Action

- (void)ts_segmentChanged:(UISegmentedControl *)sender {
    NSInteger row           = sender.tag - kSegTagBase;
    NSInteger selectedIndex = sender.selectedSegmentIndex;

    sender.enabled = NO; // 禁用，等待回调
    __weak typeof(self) weakSelf = self;

    switch (row) {

        case TSUnitRowLength: {
            TSLengthUnit prev = self.lengthUnit;
            TSLengthUnit next = (selectedIndex == 0) ? TSLengthUnitMetric : TSLengthUnitImperial;
            [[[TopStepComKit sharedInstance] unit]
             setLengthUnit:next completion:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sender.enabled = YES;
                    if (success) {
                        weakSelf.lengthUnit = next;
                        [weakSelf ts_showToast:(selectedIndex == 0) ? @"已设置为公里 km" : @"已设置为英里 mi"];
                    } else {
                        sender.selectedSegmentIndex = (prev == TSLengthUnitMetric) ? 0 : 1;
                        [weakSelf ts_showError:error];
                    }
                });
            }];
            break;
        }

        case TSUnitRowTemperature: {
            TSTemperatureUnit prev = self.temperatureUnit;
            TSTemperatureUnit next = (selectedIndex == 0) ? TSTemperatureUnitCelsius : TSTemperatureUnitFahrenheit;
            [[[TopStepComKit sharedInstance] unit]
             setTemperatureUnit:next completion:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sender.enabled = YES;
                    if (success) {
                        weakSelf.temperatureUnit = next;
                        [weakSelf ts_showToast:(selectedIndex == 0) ? @"已设置为摄氏 °C" : @"已设置为华氏 °F"];
                    } else {
                        sender.selectedSegmentIndex = (prev == TSTemperatureUnitCelsius) ? 0 : 1;
                        [weakSelf ts_showError:error];
                    }
                });
            }];
            break;
        }

        case TSUnitRowWeight: {
            TSWeightUnit prev = self.weightUnit;
            TSWeightUnit next = (selectedIndex == 0) ? TSWeightUnitKG : TSWeightUnitLB;
            [[[TopStepComKit sharedInstance] unit]
             setWeightUnit:next completion:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sender.enabled = YES;
                    if (success) {
                        weakSelf.weightUnit = next;
                        [weakSelf ts_showToast:(selectedIndex == 0) ? @"已设置为 KG" : @"已设置为 LB"];
                    } else {
                        sender.selectedSegmentIndex = (prev == TSWeightUnitKG) ? 0 : 1;
                        [weakSelf ts_showError:error];
                    }
                });
            }];
            break;
        }

        case TSUnitRowTime: {
            TSTimeFormat prev = self.timeFormat;
            TSTimeFormat next = (selectedIndex == 0) ? TSTimeFormat12Hour : TSTimeFormat24Hour;
            [[[TopStepComKit sharedInstance] unit]
             setTimeFormat:next completion:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sender.enabled = YES;
                    if (success) {
                        weakSelf.timeFormat = next;
                        [weakSelf ts_showToast:(selectedIndex == 0) ? @"已设置为 12 小时制" : @"已设置为 24 小时制"];
                    } else {
                        sender.selectedSegmentIndex = (prev == TSTimeFormat12Hour) ? 0 : 1;
                        [weakSelf ts_showError:error];
                    }
                });
            }];
            break;
        }
    }
}

#pragma mark - Toast / Error

- (void)ts_showToast:(NSString *)message {
    UILabel *toast = [[UILabel alloc] init];
    toast.text             = message;
    toast.font             = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    toast.textColor        = UIColor.whiteColor;
    toast.textAlignment    = NSTextAlignmentCenter;
    toast.backgroundColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    toast.layer.cornerRadius  = 18.f;
    toast.layer.masksToBounds = YES;
    toast.numberOfLines    = 0;
    toast.alpha            = 0;

    CGFloat hPad   = TSSpacing_LG, vPad = TSSpacing_SM;
    CGFloat maxW   = self.view.bounds.size.width - TSSpacing_XL * 2;
    CGSize  textSz = [message boundingRectWithSize:CGSizeMake(maxW - hPad * 2, CGFLOAT_MAX)
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

- (void)ts_showError:(NSError *)error {
    NSString *msg = error.localizedDescription ?: @"设置失败，请重试";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置失败"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
