//
//  TSMyMapsVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSMyMapsVC.h"

#import <TopStepComKit/TopStepComKit.h>

#import "TSOfflineMapVC.h"
#import "TSOfflineMapCell.h"
#import "TSOfflineMapItem.h"
#import "TSOfflineMapStore.h"
#import "TSMapTransferOverlay.h"
#import "UIViewController+TSToast.h"

/// 推送所需最低电量
static const NSInteger kTSPushMinBattery = 30;

typedef NS_ENUM(NSUInteger, TSMyMapsTab) {
    TSMyMapsTabLocal = 0,   // 本地地图
    TSMyMapsTabDevice,      // 设备地图
};

@interface TSMyMapsVC () <UITableViewDataSource, UITableViewDelegate>

// 分段控件
@property (nonatomic, strong) UISegmentedControl *segment;
// 列表
@property (nonatomic, strong) UITableView *listTable;
// 空状态容器
@property (nonatomic, strong) UIView *emptyView;
// 底部按钮容器
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *primaryButton;   // 本地：推送到设备
@property (nonatomic, strong) UIButton *dangerButton;    // 本地：删除 / 设备：从设备删除

// 数据
@property (nonatomic, assign) TSMyMapsTab currentTab;
@property (nonatomic, strong) NSArray<TSOfflineMapItem *> *localMaps;
@property (nonatomic, strong) NSArray<NSString *> *deviceMaps;
// 选中：本地单选（名称），设备多选（名称集合）
@property (nonatomic, copy, nullable) NSString *selectedLocalName;
@property (nonatomic, strong) NSMutableSet<NSString *> *selectedDeviceNames;

// 推送态
@property (nonatomic, assign) BOOL isPushing;
@property (nonatomic, strong) TSMapTransferOverlay *transferOverlay;

@end

@implementation TSMyMapsVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"offline_map.my_maps.title");
    self.currentTab = TSMyMapsTabLocal;
    self.selectedDeviceNames = [NSMutableSet set];
    self.view.backgroundColor = TSColor_Background;
}

- (void)setupViews {
    [self.sourceTableview removeFromSuperview];
    [self ts_buildSegment];
    [self ts_buildList];
    [self ts_buildEmptyView];
    [self ts_buildBottomBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self ts_reloadCurrentTab];
}

- (void)layoutViews {
    CGFloat top = self.ts_navigationBarTotalHeight;
    if (top <= 0) top = self.view.safeAreaInsets.top;
    CGFloat width = self.view.bounds.size.width;
    CGFloat bottomSafe = self.view.safeAreaInsets.bottom;

    CGFloat segH = 44.f;
    self.segment.frame = CGRectMake(16.f, top + 8.f, width - 32.f, 30.f);

    CGFloat bottomBarH = 60.f + bottomSafe;
    self.bottomBar.frame = CGRectMake(0, self.view.bounds.size.height - bottomBarH, width, bottomBarH);

    CGFloat listTop = top + 8.f + segH;
    CGFloat listH = CGRectGetMinY(self.bottomBar.frame) - listTop;
    self.listTable.frame = CGRectMake(0, listTop, width, listH);
    self.emptyView.frame = self.listTable.frame;
}

#pragma mark - 构建 UI

/// 分段控件
- (void)ts_buildSegment {
    self.segment = [[UISegmentedControl alloc] initWithItems:@[@"", @""]];
    [self.segment addTarget:self action:@selector(ts_segmentChanged) forControlEvents:UIControlEventValueChanged];
    self.segment.selectedSegmentIndex = 0;
    [self.view addSubview:self.segment];
}

/// 列表
- (void)ts_buildList {
    self.listTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.listTable.dataSource = self;
    self.listTable.delegate = self;
    self.listTable.backgroundColor = TSColor_Background;
    self.listTable.separatorInset = UIEdgeInsetsMake(0, 72.f, 0, 0);
    self.listTable.rowHeight = 68.f;
    self.listTable.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.listTable];
}

/// 空状态
- (void)ts_buildEmptyView {
    self.emptyView = [[UIView alloc] init];
    self.emptyView.hidden = YES;
    [self.view addSubview:self.emptyView];
}

/// 底部按钮
- (void)ts_buildBottomBar {
    self.bottomBar = [[UIView alloc] init];
    self.bottomBar.backgroundColor = TSColor_Card;
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = TSColor_Separator;
    topLine.frame = CGRectMake(0, 0, self.view.bounds.size.width, 0.5f);
    topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.bottomBar addSubview:topLine];
    [self.view addSubview:self.bottomBar];

    self.primaryButton = [self ts_barButtonPrimary:YES];
    [self.primaryButton addTarget:self action:@selector(ts_pushTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.primaryButton];

    self.dangerButton = [self ts_barButtonPrimary:NO];
    [self.dangerButton addTarget:self action:@selector(ts_deleteTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.dangerButton];
}

- (UIButton *)ts_barButtonPrimary:(BOOL)primary {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
    button.layer.cornerRadius = 12.f;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = primary ? TSColor_Primary : TSColor_Danger;
    return button;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat pad = 16.f;
    CGFloat gap = 10.f;
    CGFloat h = 44.f;
    CGFloat totalW = self.bottomBar.bounds.size.width - pad * 2;
    if (self.currentTab == TSMyMapsTabLocal) {
        CGFloat w = (totalW - gap) / 2.f;
        self.primaryButton.frame = CGRectMake(pad, 8.f, w, h);
        self.dangerButton.frame = CGRectMake(pad + w + gap, 8.f, w, h);
    } else {
        self.dangerButton.frame = CGRectMake(pad, 8.f, totalW, h);
    }
}

#pragma mark - Tab 切换与刷新

- (void)ts_segmentChanged {
    if (self.isPushing) {
        self.segment.selectedSegmentIndex = self.currentTab;
        [self ts_showToast:TSLocalizedString(@"offline_map.push.busy")];
        return;
    }
    self.currentTab = (TSMyMapsTab)self.segment.selectedSegmentIndex;
    [self ts_reloadCurrentTab];
}

/// 刷新当前 Tab 数据
- (void)ts_reloadCurrentTab {
    self.localMaps = [[TSOfflineMapStore sharedStore] allLocalMaps];
    [self ts_updateSegmentTitles];

    if (self.currentTab == TSMyMapsTabLocal) {
        self.primaryButton.hidden = NO;
        [self ts_renderLocal];
    } else {
        self.primaryButton.hidden = YES;
        [self ts_fetchAndRenderDevice];
    }
    [self.view setNeedsLayout];
}

/// 更新分段标题（含数量）
- (void)ts_updateSegmentTitles {
    NSString *local = [NSString stringWithFormat:@"%@ (%ld)", TSLocalizedString(@"offline_map.tab.local"), (long)self.localMaps.count];
    NSString *device = [NSString stringWithFormat:@"%@ (%ld)", TSLocalizedString(@"offline_map.tab.device"), (long)self.deviceMaps.count];
    [self.segment setTitle:local forSegmentAtIndex:0];
    [self.segment setTitle:device forSegmentAtIndex:1];
}

/// 渲染本地列表
- (void)ts_renderLocal {
    BOOL empty = (self.localMaps.count == 0);
    self.listTable.hidden = empty;
    if (empty) {
        [self ts_showEmptyLocal];
    } else {
        self.emptyView.hidden = YES;
        [self.listTable reloadData];
    }
    [self ts_updateLocalActions];
}

/// 拉取并渲染设备列表
- (void)ts_fetchAndRenderDevice {
    id<TSOfflineMapsInterface> offlineMap = [[TopStepComKit sharedInstance] offlineMap];
    if (!offlineMap) {
        self.deviceMaps = @[];
        [self ts_renderDevice];
        return;
    }
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [offlineMap fetchDeviceOfflineMaps:^(NSArray<NSString *> *mapNames, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideLoading];
            weakSelf.deviceMaps = mapNames ?: @[];
            [weakSelf ts_updateSegmentTitles];
            [weakSelf ts_renderDevice];
        });
    }];
}

/// 渲染设备列表
- (void)ts_renderDevice {
    // 清理不存在的选中项
    NSMutableSet *valid = [NSMutableSet setWithArray:self.deviceMaps];
    [self.selectedDeviceNames intersectSet:valid];

    BOOL empty = (self.deviceMaps.count == 0);
    self.listTable.hidden = empty;
    if (empty) {
        [self ts_showEmptyDevice];
    } else {
        self.emptyView.hidden = YES;
        [self.listTable reloadData];
    }
    [self ts_updateDeviceActions];
}

#pragma mark - 空状态

- (void)ts_showEmptyLocal {
    [self ts_configureEmptyWithText:TSLocalizedString(@"offline_map.empty.local")
                         showButton:YES];
}

- (void)ts_showEmptyDevice {
    [self ts_configureEmptyWithText:TSLocalizedString(@"offline_map.empty.device")
                         showButton:NO];
}

/// 配置空状态视图
- (void)ts_configureEmptyWithText:(NSString *)text showButton:(BOOL)showButton {
    self.emptyView.hidden = NO;
    for (UIView *sub in self.emptyView.subviews) [sub removeFromSuperview];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24.f, 120.f, self.emptyView.bounds.size.width - 48.f, 24.f)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.text = text;
    label.font = [UIFont systemFontOfSize:16.f];
    label.textColor = TSColor_TextSecondary;
    label.textAlignment = NSTextAlignmentCenter;
    [self.emptyView addSubview:label];

    if (showButton) {
        UIButton *newButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [newButton setTitle:TSLocalizedString(@"offline_map.empty.create") forState:UIControlStateNormal];
        [newButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        newButton.titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
        newButton.backgroundColor = TSColor_Primary;
        newButton.layer.cornerRadius = 12.f;
        newButton.frame = CGRectMake((self.emptyView.bounds.size.width - 160.f) / 2.f, 160.f, 160.f, 44.f);
        newButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [newButton addTarget:self action:@selector(ts_goCreate) forControlEvents:UIControlEventTouchUpInside];
        [self.emptyView addSubview:newButton];
    }
}

- (void)ts_goCreate {
    // 返回圈选页（若栈中已有则 pop，否则 push 新的）
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[TSOfflineMapVC class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    [self.navigationController pushViewController:[[TSOfflineMapVC alloc] init] animated:YES];
}

#pragma mark - 底部按钮状态

- (void)ts_updateLocalActions {
    BOOL hasSelection = (self.selectedLocalName != nil);
    self.primaryButton.enabled = hasSelection;
    self.primaryButton.alpha = hasSelection ? 1.f : 0.5f;
    [self.primaryButton setTitle:TSLocalizedString(@"offline_map.push") forState:UIControlStateNormal];

    self.dangerButton.enabled = hasSelection;
    self.dangerButton.alpha = hasSelection ? 1.f : 0.5f;
    [self.dangerButton setTitle:TSLocalizedString(@"general.delete") forState:UIControlStateNormal];
}

- (void)ts_updateDeviceActions {
    BOOL hasSelection = (self.selectedDeviceNames.count > 0);
    self.dangerButton.enabled = hasSelection;
    self.dangerButton.alpha = hasSelection ? 1.f : 0.5f;
    NSString *title = self.selectedDeviceNames.count > 1
        ? [NSString stringWithFormat:@"%@ (%ld)", TSLocalizedString(@"offline_map.delete_device"), (long)self.selectedDeviceNames.count]
        : TSLocalizedString(@"offline_map.delete_device");
    [self.dangerButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.currentTab == TSMyMapsTabLocal) ? self.localMaps.count : self.deviceMaps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"kTSOfflineMapCell";
    TSOfflineMapCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[TSOfflineMapCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if (self.currentTab == TSMyMapsTabLocal) {
        TSOfflineMapItem *item = self.localMaps[indexPath.row];
        BOOL checked = [item.name isEqualToString:self.selectedLocalName];
        [cell configureWithName:item.name sizeText:[item readableSize] checked:checked];
    } else {
        NSString *name = self.deviceMaps[indexPath.row];
        BOOL checked = [self.selectedDeviceNames containsObject:name];
        [cell configureWithName:name sizeText:@"—" checked:checked];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.currentTab == TSMyMapsTabLocal) {
        // 单选：再次点选中项则取消
        TSOfflineMapItem *item = self.localMaps[indexPath.row];
        self.selectedLocalName = [item.name isEqualToString:self.selectedLocalName] ? nil : item.name;
        [self.listTable reloadData];
        [self ts_updateLocalActions];
    } else {
        NSString *name = self.deviceMaps[indexPath.row];
        if ([self.selectedDeviceNames containsObject:name]) {
            [self.selectedDeviceNames removeObject:name];
        } else {
            [self.selectedDeviceNames addObject:name];
        }
        [self.listTable reloadData];
        [self ts_updateDeviceActions];
    }
}

#pragma mark - 推送

- (void)ts_pushTapped {
    if (!self.selectedLocalName) return;
    TSOfflineMapItem *item = [self ts_selectedLocalItem];
    if (!item) return;

    id<TSOfflineMapsInterface> offlineMap = [[TopStepComKit sharedInstance] offlineMap];
    if (!offlineMap || ![[[TopStepComKit sharedInstance] bleConnector] isConnected]) {
        [self ts_showToast:TSLocalizedString(@"offline_map.device_disconnected")];
        return;
    }

    // 电量前置检查
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] battery] getBatteryInfoCompletion:^(TSBatteryModel *batteryModel, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (batteryModel && batteryModel.percentage < kTSPushMinBattery) {
                [weakSelf ts_showToast:TSLocalizedString(@"offline_map.push.low_battery")];
                return;
            }
            [weakSelf ts_continuePushForItem:item];
        });
    }];
}

/// 电量检查通过后，判断是否需要覆盖确认
- (void)ts_continuePushForItem:(TSOfflineMapItem *)item {
    if (self.deviceMaps.count > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"offline_map.overwrite.title")
                                                                      message:nil
                                                               preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
        __weak typeof(self) weakSelf = self;
        [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
            [weakSelf ts_startPushForItem:item];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self ts_startPushForItem:item];
    }
}

/// 开始推送
- (void)ts_startPushForItem:(TSOfflineMapItem *)item {
    id<TSOfflineMapsInterface> offlineMap = [[TopStepComKit sharedInstance] offlineMap];
    if (!offlineMap) {
        [self ts_showToast:TSLocalizedString(@"offline_map.device_disconnected")];
        return;
    }

    self.isPushing = YES;
    [self ts_setNavigationBlocked:YES];
    self.transferOverlay = [[TSMapTransferOverlay alloc] init];
    [self.transferOverlay showInView:self.navigationController.view
                               title:TSLocalizedString(@"offline_map.pushing.title")
                                hint:TSLocalizedString(@"offline_map.pushing.hint")];

    __weak typeof(self) weakSelf = self;
    [offlineMap pushOfflineMap:item.packagePath
                       mapName:item.name
                      progress:^(TSFileTransferStatus state, NSInteger progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.transferOverlay updateProgress:progress];
        });
    } success:^(TSFileTransferStatus state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf ts_handlePushSuccessForItem:item];
        });
    } failure:^(TSFileTransferStatus state, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf ts_handlePushFailure];
        });
    }];
}

/// 推送成功
- (void)ts_handlePushSuccessForItem:(TSOfflineMapItem *)item {
    [self ts_finishPushing];
    // 成功 = 本地移除 + 设备新增（覆盖模式设备端已替换）
    [[TSOfflineMapStore sharedStore] removeLocalMapWithName:item.name];
    self.selectedLocalName = nil;
    [self ts_reloadCurrentTab];
    [self ts_showPushResultTitle:TSLocalizedString(@"offline_map.push.success")];
}

/// 推送失败
- (void)ts_handlePushFailure {
    [self ts_finishPushing];
    // 失败：本地保留，可重试
    [self ts_showPushResultTitle:TSLocalizedString(@"offline_map.push.failed")];
}

/// 结束推送态
- (void)ts_finishPushing {
    self.isPushing = NO;
    [self ts_setNavigationBlocked:NO];
    [self.transferOverlay dismiss];
    self.transferOverlay = nil;
}

/// 推送结果弹窗（单按钮「知道了」）
- (void)ts_showPushResultTitle:(NSString *)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.got_it") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 推送中拦截导航返回
- (void)ts_setNavigationBlocked:(BOOL)blocked {
    self.navigationItem.hidesBackButton = blocked;
    self.navigationController.interactivePopGestureRecognizer.enabled = !blocked;
}

#pragma mark - 删除

- (void)ts_deleteTapped {
    if (self.currentTab == TSMyMapsTabLocal) {
        [self ts_deleteLocal];
    } else {
        [self ts_deleteDevice];
    }
}

/// 删除本地地图
- (void)ts_deleteLocal {
    if (!self.selectedLocalName) return;
    NSString *name = self.selectedLocalName;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"offline_map.delete_local.title")
                                                                  message:TSLocalizedString(@"offline_map.delete_local.message")
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.delete")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action) {
        [[TSOfflineMapStore sharedStore] removeLocalMapWithName:name];
        weakSelf.selectedLocalName = nil;
        [weakSelf ts_reloadCurrentTab];
        [weakSelf ts_showToast:TSLocalizedString(@"offline_map.deleted")];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 从设备删除地图
- (void)ts_deleteDevice {
    if (self.selectedDeviceNames.count == 0) return;
    NSArray<NSString *> *names = [self.selectedDeviceNames allObjects];
    NSString *title = names.count > 1
        ? [NSString stringWithFormat:TSLocalizedString(@"offline_map.delete_device.title_multi"), (long)names.count]
        : TSLocalizedString(@"offline_map.delete_device.title");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                  message:TSLocalizedString(@"offline_map.delete_device.message")
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.delete")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action) {
        [weakSelf ts_performDeviceDelete:names];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 逐个下发设备删除指令
- (void)ts_performDeviceDelete:(NSArray<NSString *> *)names {
    id<TSOfflineMapsInterface> offlineMap = [[TopStepComKit sharedInstance] offlineMap];
    if (!offlineMap) {
        [self ts_showToast:TSLocalizedString(@"offline_map.device_disconnected")];
        return;
    }
    [self showLoading];
    dispatch_group_t group = dispatch_group_create();
    for (NSString *name in names) {
        dispatch_group_enter(group);
        [offlineMap deleteOfflineMap:name completion:^(BOOL isSuccess, NSError *error) {
            dispatch_group_leave(group);
        }];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [weakSelf hideLoading];
        [weakSelf.selectedDeviceNames removeAllObjects];
        [weakSelf ts_showToast:TSLocalizedString(@"offline_map.deleted")];
        [weakSelf ts_fetchAndRenderDevice];
    });
}

#pragma mark - 私有方法

/// 当前选中的本地地图
- (TSOfflineMapItem *)ts_selectedLocalItem {
    for (TSOfflineMapItem *item in self.localMaps) {
        if ([item.name isEqualToString:self.selectedLocalName]) return item;
    }
    return nil;
}

@end
