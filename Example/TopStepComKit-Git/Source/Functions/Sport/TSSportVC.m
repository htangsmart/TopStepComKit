//
//  TSSportVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSSportVC.h"
#import "TSSportCell.h"
#import "TSSportDetailVC.h"
#import <TopStepComKit/TopStepComKit.h>

static const CGFloat kDateBarHeight = 50.f;
static const CGFloat kCellHeight = 124.f;  // 增加高度以容纳所有内容
static NSString * const kSportCellID = @"TSSportCell";

@interface TSSportVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *dateBar;
@property (nonatomic, strong) UIButton *dateButton;
@property (nonatomic, strong) UIButton *syncButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) NSMutableArray<TSSportModel *> *sportList;
@property (nonatomic, strong) NSDate *selectedDate;

@end

@implementation TSSportVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self syncTodaySportData];
}

#pragma mark - Override Base Setup

- (void)initData {
    [super initData];
    self.title = @"运动数据";
    _sportList = [NSMutableArray array];
    _selectedDate = [NSDate date]; // 默认今天
}

- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;

    // 日期选择栏
    [self.view addSubview:self.dateBar];
    [self.dateBar addSubview:self.dateButton];
    [self.dateBar addSubview:self.syncButton];

    // 列表
    [self.view addSubview:self.tableView];

    // 空状态
    [self.view addSubview:self.emptyView];

    // Loading
    [self.view addSubview:self.loadingIndicator];
}

- (void)layoutViews {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    CGFloat top = self.ts_navigationBarTotalHeight;
    if (top <= 0) top = self.view.safeAreaInsets.top;

    // 日期栏
    _dateBar.frame = CGRectMake(0, top, w, kDateBarHeight);
    _dateButton.frame = CGRectMake(TSSpacing_MD, 10, 120, 30);
    _syncButton.frame = CGRectMake(w - 50 - TSSpacing_MD, 10, 50, 30);

    // 列表
    CGFloat tableTop = top + kDateBarHeight;
    _tableView.frame = CGRectMake(0, tableTop, w, h - tableTop);

    // 空状态
    _emptyView.frame = _tableView.frame;

    // Loading
    _loadingIndicator.center = CGPointMake(w / 2.f, (h + tableTop) / 2.f);
}

#pragma mark - Data Loading

- (void)syncTodaySportData {
    [self.loadingIndicator startAnimating];
    _emptyView.hidden = YES;

    // 获取当日0点时间戳
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:_selectedDate];
    NSDate *startOfDay = [calendar dateFromComponents:components];
    NSTimeInterval startTime = [startOfDay timeIntervalSince1970];
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];

    // 配置数据同步
    TSDataSyncConfig *config = [[TSDataSyncConfig alloc] init];
    config.options = TSDataSyncOptionSport;  // 只同步运动数据
    config.granularity = TSDataGranularityDay;  // 按天聚合
    config.startTime = startTime;  // 当日0点
    config.endTime = endTime;  // 当前时间

    __weak typeof(self) wself = self;
    [[[TopStepComKit sharedInstance] dataSync] syncDataWithConfig:config
                                                       completion:^(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.loadingIndicator stopAnimating];

            if (error) {
                [wself showAlertWithMsg:error.localizedDescription ?: @"同步失败"];
                return;
            }

            // 从结果中提取运动数据
            TSHealthData *sportData = [TSHealthData findHealthDataWithOption:TSDataSyncOptionSport fromArray:results];

            [wself.sportList removeAllObjects];

            if (sportData && !sportData.fetchError && sportData.healthValues.count > 0) {
                // healthValues 中的对象是 TSSportModel 类型
                for (TSHealthValueModel *value in sportData.healthValues) {
                    if ([value isKindOfClass:[TSSportModel class]]) {
                        [wself.sportList addObject:(TSSportModel *)value];
                    }
                }

                // 按开始时间倒序排列（最新的在前）
                [wself.sportList sortUsingComparator:^NSComparisonResult(TSSportModel *obj1, TSSportModel *obj2) {
                    if (obj2.summary.startTime > obj1.summary.startTime) {
                        return NSOrderedAscending;
                    } else if (obj2.summary.startTime < obj1.summary.startTime) {
                        return NSOrderedDescending;
                    }
                    return NSOrderedSame;
                }];
            } else if (sportData && sportData.fetchError) {
                [wself showAlertWithMsg:sportData.fetchError.localizedDescription ?: @"获取运动数据失败"];
            }

            [wself.tableView reloadData];
            wself.emptyView.hidden = (wself.sportList.count > 0);
        });
    }];
}

#pragma mark - Actions

- (void)onDateButtonTapped {
    // TODO: 可以实现日期选择器
    [self showAlertWithMsg:@"日期选择功能待实现"];
}

- (void)onSyncButtonTapped {
    [self syncTodaySportData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sportList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSSportCell *cell = [tableView dequeueReusableCellWithIdentifier:kSportCellID forIndexPath:indexPath];
    if (indexPath.row < _sportList.count) {
        TSSportModel *sport = _sportList[indexPath.row];
        [cell configureWithSport:sport];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _sportList.count) return;

    TSSportModel *sport = _sportList[indexPath.row];
    TSSportDetailVC *detailVC = [[TSSportDetailVC alloc] initWithSport:sport];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - Lazy Loading

- (UIView *)dateBar {
    if (!_dateBar) {
        _dateBar = [[UIView alloc] init];
        _dateBar.backgroundColor = TSColor_Card;

        // 底部分割线
        UIView *separator = [[UIView alloc] init];
        separator.backgroundColor = TSColor_Separator;
        separator.frame = CGRectMake(0, kDateBarHeight - 0.5f, [UIScreen mainScreen].bounds.size.width, 0.5f);
        [_dateBar addSubview:separator];
    }
    return _dateBar;
}

- (UIButton *)dateButton {
    if (!_dateButton) {
        _dateButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_dateButton setTitle:@"今天" forState:UIControlStateNormal];
        [_dateButton setTitleColor:TSColor_TextPrimary forState:UIControlStateNormal];
        _dateButton.titleLabel.font = TSFont_H2;
        [_dateButton addTarget:self action:@selector(onDateButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dateButton;
}

- (UIButton *)syncButton {
    if (!_syncButton) {
        _syncButton = [UIButton buttonWithType:UIButtonTypeSystem];

        UIImage *refreshImg = nil;
        if (@available(iOS 13.0, *)) {
            refreshImg = [UIImage systemImageNamed:@"arrow.clockwise"];
        }
        [_syncButton setImage:refreshImg forState:UIControlStateNormal];
        [_syncButton addTarget:self action:@selector(onSyncButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _syncButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = TSColor_Background;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TSSportCell class] forCellReuseIdentifier:kSportCellID];
    }
    return _tableView;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] init];
        _emptyView.backgroundColor = TSColor_Background;
        _emptyView.hidden = YES;

        UILabel *iconLabel = [[UILabel alloc] init];
        iconLabel.text = @"🏃";
        iconLabel.font = [UIFont systemFontOfSize:60];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        [_emptyView addSubview:iconLabel];

        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.text = @"暂无运动数据";
        textLabel.font = TSFont_Body;
        textLabel.textColor = TSColor_TextSecondary;
        textLabel.textAlignment = NSTextAlignmentCenter;
        [_emptyView addSubview:textLabel];

        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        CGFloat centerY = [UIScreen mainScreen].bounds.size.height / 2.f;
        iconLabel.frame = CGRectMake(0, centerY - 80, w, 70);
        textLabel.frame = CGRectMake(0, centerY - 10, w, 20);
    }
    return _emptyView;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        if (@available(iOS 13.0, *)) {
            _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _loadingIndicator.hidesWhenStopped = YES;
    }
    return _loadingIndicator;
}

@end
