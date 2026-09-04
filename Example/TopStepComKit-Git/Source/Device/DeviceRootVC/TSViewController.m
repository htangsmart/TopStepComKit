//
//  TSViewController.m
//  TopStepComKit
//
//  Created by rd@hetangsmart.com on 12/23/2024.
//  Copyright (c) 2024 rd@hetangsmart.com. All rights reserved.
//

#import "TSViewController.h"

#import <TopStepAIKit/TopStepAIKit.h>

#import "TSDeviceScanVC.h"
#import "TSDeviceCoordinator.h"
#import "TSDeviceMenuBuilder.h"
#import "TSTakePhotoVC.h"
#import "TSPeripheralInfoVC.h"
#import "TSAIChatVC.h"
#import "TSAIChatDeviceSessionCoordinator.h"
#import "TSDeviceStatusCardView.h"

// ─── Section 枚举 ───────────────────────────────────────────────────────────
typedef NS_ENUM(NSUInteger, TSHomeSection) {
    TSHomeSectionDevice = 0,       // 设备功能
    TSHomeSectionSettings,         // 系统设置
    TSHomeSectionDanger,           // 危险操作
    TSHomeSectionCount
};

// ─── TSViewController ────────────────────────────────────────────────────────
@interface TSViewController () <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager       *centralManager;
@property (nonatomic, strong) TSDeviceStatusCardView *statusCard;
// 缓存 sectionData，避免每次 tableView 回调都重建
@property (nonatomic, strong) NSArray<NSArray *>     *cachedSectionData;
@property (nonatomic, assign) BOOL                   deviceCallbacksRegistered;

@end

@implementation TSViewController

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        // 一级页面，显示 TabBar
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ts_initData];
    [self ts_initViews];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ts_handleDeviceSnapshotChanged:)
                                                 name:TSDeviceConnectionSnapshotDidChangeNotification
                                               object:[TSDeviceCoordinator sharedInstance]];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(ts_handleAIChatPresentationRequest:)
               name:TSAIChatDeviceSessionDidRequestPresentationNotification
             object:[TSAIChatDeviceSessionCoordinator sharedInstance]];
    [self ts_applyDeviceSnapshot:[TSDeviceCoordinator sharedInstance].snapshot];
}

/** 接收统一连接快照 */
- (void)ts_handleDeviceSnapshotChanged:(NSNotification *)notification {
    TSDeviceConnectionSnapshot *snapshot = notification.userInfo[TSDeviceConnectionSnapshotUserInfoKey];
    [self ts_applyDeviceSnapshot:snapshot];
}

/** 根据连接快照更新页面级监听与 UI */
- (void)ts_applyDeviceSnapshot:(TSDeviceConnectionSnapshot *)snapshot {
    if (snapshot.isReady) {
        [self ts_ensureDeviceCallbacksRegistered];
    } else {
        [self ts_resetDeviceCallbacksRegistration];
    }
    [self ts_refreshStatusCard];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self ts_refreshStatusCard];
}

#pragma mark - Setup

- (void)ts_initData {
    [self ts_applyNavTitle];
    self.view.backgroundColor = TSColor_Background;

    // CBCentralManager 仅用于检查蓝牙权限
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:nil
                                                             options:@{CBCentralManagerOptionShowPowerAlertKey: @YES}];
}

/**
 * 连接成功后注册设备回调：相机事件 + 电量变化
 */
- (void)ts_registerDeviceCallbacks {
    __weak typeof(self) weakSelf = self;

    // 相机事件：设备主动进入相机时跳转拍照页
    [[[TopStepComKit sharedInstance] camera] registerAppCameraControlledByDevice:^(TSCameraAction action) {
        if (action != TSCameraActionEnterCamera) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            UIViewController *top = strongSelf.navigationController.topViewController;
            if ([top isKindOfClass:[TSTakePhotoVC class]]) return;
            TSTakePhotoVC *vc = [[TSTakePhotoVC alloc] init];
            vc.isTriggeredByDevice = YES;
            [strongSelf.navigationController pushViewController:vc animated:YES];
        });
    }];

    // 电量变化：实时更新状态卡片（多电池设备每个部件变化时各回调一次，调用 applyBatteryUpdate: 增量更新）
    [[[TopStepComKit sharedInstance] battery] registerBatteryDidChanged:^(TSBatteryModel *batteryModel, NSError *error) {
        if (!batteryModel) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf.statusCard applyBatteryUpdate:batteryModel];
        });
    }];
}

- (void)ts_ensureDeviceCallbacksRegistered {
    if (self.deviceCallbacksRegistered) return;
    if (![TSDeviceCoordinator sharedInstance].snapshot.isReady) return;

    [self ts_registerDeviceCallbacks];
    self.deviceCallbacksRegistered = YES;
}

- (void)ts_resetDeviceCallbacksRegistration {
    self.deviceCallbacksRegistered = NO;
}

/**
 * 设备发起的 AI 对话完成双端激活后，仅负责展示会话页面
 */
- (void)ts_handleAIChatPresentationRequest:(NSNotification *)notification {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    UIViewController *top = self.navigationController.topViewController;
    if ([top isKindOfClass:[TSAIChatVC class]]) {
        return;
    }
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[TSAIChatVC class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    TSAIChatVC *chatVC = [[TSAIChatVC alloc] init];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)ts_initViews {
    // 移除父类 setupViews 已加入的 Plain 样式 tableView
    [self.sourceTableview removeFromSuperview];

    // 重建为 InsetGrouped 样式（iOS 13+），通过 property setter 赋值
    UITableView *groupedTable;
    if (@available(iOS 13.0, *)) {
        groupedTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    } else {
        groupedTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    }
    self.sourceTableview = groupedTable;
    self.sourceTableview.delegate        = self;
    self.sourceTableview.dataSource      = self;
    self.sourceTableview.backgroundColor = TSColor_Background;
    self.sourceTableview.showsVerticalScrollIndicator = YES;
    if (@available(iOS 15.0, *)) {
        self.sourceTableview.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:self.sourceTableview];

    // 顶部设备状态卡片（tableView 的 headerView）
    [self ts_buildTableHeaderView];
}

- (void)ts_buildTableHeaderView {
    CGFloat cardH   = 88.f;
    CGFloat margin  = 16.f;
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, cardH + margin * 2)];
    container.backgroundColor = [UIColor clearColor];

    self.statusCard = [[TSDeviceStatusCardView alloc] initWithFrame:CGRectMake(margin, margin, screenW - margin * 2, cardH)];
    [container addSubview:self.statusCard];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ts_statusCardTapped)];
    [self.statusCard addGestureRecognizer:tap];
    self.statusCard.userInteractionEnabled = YES;

    __weak typeof(self) weakSelf = self;
    self.statusCard.onReconnectTap = ^{
        [[TSDeviceCoordinator sharedInstance] reconnectWithCompletion:^(BOOL success, NSError *error) {
            if (!success) {
                [weakSelf.statusCard updateConnectionFailed];
            }
        }];
    };

    self.sourceTableview.tableHeaderView = container;
}

- (void)layoutViews {
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;
    self.sourceTableview.frame = CGRectMake(0, topOffset,
                                            self.view.frame.size.width,
                                            CGRectGetHeight(self.view.frame) - topOffset);

    // 更新 headerView 和 statusCard 的宽度，适配屏幕旋转/分屏
    [self ts_updateTableHeaderLayout];
}

/// 更新 headerView 布局以适配当前宽度
- (void)ts_updateTableHeaderLayout {
    CGFloat cardH  = 88.f;
    CGFloat margin = 16.f;
    CGFloat viewW  = CGRectGetWidth(self.view.bounds);

    UIView *header = self.sourceTableview.tableHeaderView;
    if (!header) return;

    CGRect headerFrame = CGRectMake(0, 0, viewW, cardH + margin * 2);
    if (!CGRectEqualToRect(header.frame, headerFrame)) {
        header.frame = headerFrame;
        self.statusCard.frame = CGRectMake(margin, margin, viewW - margin * 2, cardH);
        // 重新赋值 tableHeaderView 触发 tableView 重新计算高度
        self.sourceTableview.tableHeaderView = header;
    }
}

#pragma mark - Status Card

/// 重建缓存并刷新列表
- (void)ts_reloadTableData {
    self.cachedSectionData = [self ts_buildSectionData];
    [self.sourceTableview reloadData];
}

- (void)ts_refreshStatusCard {
    TSDeviceConnectionSnapshot *snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    if (snapshot.isReady) {
        TSPeripheral *peripheral = snapshot.peripheral;
        NSUInteger connectionGeneration = snapshot.connectionGeneration;
        __weak typeof(self) weakSelf = self;
        [[[TopStepComKit sharedInstance] battery]
            getAllBatteriesInfoCompletion:^(NSArray<TSBatteryModel *> *batteryModels, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                TSDeviceConnectionSnapshot *latestSnapshot = [TSDeviceCoordinator sharedInstance].snapshot;
                if (!strongSelf || !latestSnapshot.isReady ||
                    latestSnapshot.connectionGeneration != connectionGeneration) {
                    return;
                }
                [strongSelf.statusCard updateConnected:YES
                                            deviceName:peripheral.systemInfo.bleName
                                            macAddress:peripheral.systemInfo.mac
                                             batteries:batteryModels];
                [strongSelf ts_reloadTableData];
            });
        }];
        return;
    }

    if (snapshot.isTransitioning ||
        (snapshot.hasBinding && snapshot.sdkState == TSDemoSDKStateReady &&
         snapshot.connectionState != eTSBleStateDisconnected)) {
        [self.statusCard updateConnecting];
    } else if (snapshot.error && snapshot.hasBinding) {
        [self.statusCard updateConnectionFailed];
    } else {
        [self.statusCard updateConnected:NO deviceName:nil macAddress:nil batteries:nil];
    }
    [self ts_reloadTableData];
}

/**
 * 设备状态卡片点击：已连接时进入设备信息页，未连接时进入扫描页，连接失败时无响应（用重连按钮操作）
 */
- (void)ts_statusCardTapped {

    // 已连接设备，进入设备信息页
    if ([TSDeviceCoordinator sharedInstance].snapshot.isReady) {
        TSPeripheralInfoVC *infoVC = [[TSPeripheralInfoVC alloc] init];
        [self.navigationController pushViewController:infoVC animated:YES];
    }
}

#pragma mark - Navigation Title

- (void)ts_applyNavTitle {
    self.title = TSLocalizedString(@"device.title");
}

#pragma mark - Section Data

/**
 * 构建所有 section 数据，根据设备能力设置 enabled
 */
- (NSArray<NSArray *> *)ts_buildSectionData {
    return [TSDeviceMenuBuilder sectionDataWithSnapshot:[TSDeviceCoordinator sharedInstance].snapshot];
}
- (NSArray<NSArray *> *)currentSectionData {
    if (!_cachedSectionData) {
        _cachedSectionData = [self ts_buildSectionData];
    }
    return _cachedSectionData;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TSHomeSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < (NSInteger)self.currentSectionData.count) {
        return self.currentSectionData[section].count;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TSHomeSectionDevice:     return TSLocalizedString(@"device.section.features");
        case TSHomeSectionSettings:   return TSLocalizedString(@"device.section.settings");
        case TSHomeSectionDanger:     return TSLocalizedString(@"device.section.danger");
        default: return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"kTSHomeCell";
    TSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[TSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    if (indexPath.section < (NSInteger)self.currentSectionData.count) {
        NSArray *rows = self.currentSectionData[indexPath.section];
        if (indexPath.row < (NSInteger)rows.count) {
            [cell reloadCellWithModel:rows[indexPath.row]];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section >= (NSInteger)self.currentSectionData.count) return;
    NSArray *rows = self.currentSectionData[indexPath.section];
    if (indexPath.row >= (NSInteger)rows.count) return;

    TSValueModel *value = rows[indexPath.row];
    if (!value.enabled) return;

    // 解绑设备：危险操作 section 且 vcName 为 nil
    if (indexPath.section == TSHomeSectionDanger && value.vcName == nil) {
        [self ts_handleUnbind];
    } else if (value.kitType == eTSKitBle) {
        [self ts_checkBluetooth];
    } else {
        [self ts_pushVCWithModel:value];
    }
}

#pragma mark - Navigation

- (void)ts_pushVCWithModel:(TSValueModel *)model {
    if (model.vcName.length == 0) return;
    Class cls = NSClassFromString(model.vcName);
    if (!cls) return;
    TSBaseVC *vc = [[cls alloc] init];
    vc.title = model.valueName;
    [self ts_pushVC:vc];
}

- (void)ts_pushVC:(UIViewController *)vc {
    if (!vc) return;
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Unbind

/**
 * 处理解绑操作
 */
- (void)ts_handleUnbind {
    TSDeviceConnectionSnapshot *snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    BOOL isConnected = snapshot.connectionState == eTSBleStateConnected;
    __weak typeof(self) weakSelf = self;

    if (isConnected) {
        // 设备在线：正常解绑，通知设备
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"unbind.title")
                                                                       message:TSLocalizedString(@"unbind.message")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"unbind.action") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [weakSelf ts_performUnbind];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // 设备离线：仅清除本地数据
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"unbind.offline.title")
                                                                       message:TSLocalizedString(@"unbind.offline.message")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"unbind.offline.action") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [weakSelf ts_performLocalUnbind];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/**
 * 执行解绑
 */
- (void)ts_performUnbind {
    __weak typeof(self) weakSelf = self;
    [[TSDeviceCoordinator sharedInstance] unbindWithCompletion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;

            if (isSuccess) {
                [strongSelf ts_resetDeviceCallbacksRegistration];
            } else {
                NSString *msg = error ? error.localizedDescription : TSLocalizedString(@"unbind.failed");
                [strongSelf showAlertWithMsg:msg];
            }
        });
    }];
}

/**
 * 设备离线时强制清除本地绑定数据
 */
- (void)ts_performLocalUnbind {
    [self ts_resetDeviceCallbacksRegistration];
    [[TSDeviceCoordinator sharedInstance] clearLocalBinding];
}

#pragma mark - Bluetooth Permission

- (void)ts_checkBluetooth {
    switch (self.centralManager.state) {
        case CBManagerStatePoweredOn: {
            dispatch_async(dispatch_get_main_queue(), ^{
                TSDeviceScanVC *scanVC = [[TSDeviceScanVC alloc] init];
                [self.navigationController pushViewController:scanVC animated:YES];
            });
            break;
        }
        case CBManagerStatePoweredOff: {
            [self ts_showBluetoothAlert:TSLocalizedString(@"ble.turn_on")];
            break;
        }
        case CBManagerStateUnauthorized: {
            [self ts_showBluetoothAlert:TSLocalizedString(@"ble.authorize")];
            break;
        }
        default:
            break;
    }
}

- (void)ts_showBluetoothAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"ble.unavailable")
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.go_settings")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    TSLog(@"[TSViewController] 蓝牙状态变化: %ld", (long)central.state);
    // 仅记录日志和刷新状态，不弹窗打扰用户
    dispatch_async(dispatch_get_main_queue(), ^{
        [self ts_refreshStatusCard];
    });
}

@end
