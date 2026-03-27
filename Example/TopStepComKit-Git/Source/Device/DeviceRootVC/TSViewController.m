//
//  TSViewController.m
//  TopStepComKit
//
//  Created by rd@hetangsmart.com on 12/23/2024.
//  Copyright (c) 2024 rd@hetangsmart.com. All rights reserved.
//

#import "TSViewController.h"
#import "TSDeviceScanVC.h"
#import "TSPeripheralFindVC.h"
#import "TSTakePhotoVC.h"
#import "TSContactVC.h"
#import "TSAlarmClockVC.h"
#import "TSDailyExerciseGoalVC.h"
#import "TSLanguagesVC.h"
#import "TSUserInfoVC.h"
#import "TSMessageVC.h"
#import "TSFileOTAVC.h"
#import "TSWeatherVC.h"
#import "TSPeripheralDialVC.h"
#import "TSRemoteControlVC.h"
#import "TSUnitVC.h"
#import "TSSettingVC.h"
#import "TSBatteryVC.h"
#import "TSTimeVC.h"
#import "TSReminderVC.h"
#import "TSAutoMonitorSettingVC.h"
#import "TSDataSyncVC.h"
#import "TSActivityMeasureVC.h"
#import "TSHearRateVC.h"
#import "TSBloodOxygenVC.h"
#import "TSBloodPressureVC.h"
#import "TSSportVC.h"
#import "TSSleepVC.h"
#import "TSStressVC.h"
#import "TSTemperatureVC.h"
#import "TSDailyActivityVC.h"
#import "TSElectrocardioVC.h"
#import "TSGlassesVC.h"
#import "TSPeripheralInfoVC.h"
#import "TSPeripheralLockVC.h"
#import "TSWorldClockVC.h"
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
    [[[TopStepComKit sharedInstance] camera] registerAppCameraeControledByDevice:^(TSCameraAction action) {
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

    // 电量变化：实时更新状态卡片
    [[[TopStepComKit sharedInstance] battery] registerBatteryDidChanged:^(TSBatteryModel *batteryModel, NSError *error) {
        if (!batteryModel) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            TSPeripheral *peri = [[TopStepComKit sharedInstance] connectedPeripheral];
            [strongSelf.statusCard updateConnected:YES
                                       deviceName:peri.systemInfo.bleName
                                       macAddress:peri.systemInfo.mac
                                          battery:batteryModel];
        });
    }];
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
        [weakSelf ts_autoConnect];
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
    id<TSBleConnectInterface> connector = [[TopStepComKit sharedInstance] bleConnector];

    // ① SDK 尚未初始化（bleConnector 为 nil）
    if (!connector) {
        NSString *savedMac = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCurrentMac"];
        if (savedMac.length > 0) {
            [self.statusCard updateConnecting];
        } else {
            [self.statusCard updateConnected:NO deviceName:nil macAddress:nil battery:nil];
        }
        [self ts_reloadTableData];
        return;
    }

    // ② 同步快速判断：已完全连接
    if ([connector isConnected]) {
        TSPeripheral *peri = [[TopStepComKit sharedInstance] connectedPeripheral];
        __weak typeof(self) weakSelf = self;
        [[[TopStepComKit sharedInstance] battery] getBatteryInfoCompletion:^(TSBatteryModel *batteryModel, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.statusCard updateConnected:YES
                                         deviceName:peri.systemInfo.bleName
                                         macAddress:peri.systemInfo.mac
                                            battery:batteryModel];
                [weakSelf ts_reloadTableData];
            });
        }];
        return;
    }

    // ③ 未完全连接：异步精确查询，处理"连接中/认证中"等过渡状态
    NSString *savedMac = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCurrentMac"];
    if (savedMac.length > 0) {
        [self.statusCard updateConnecting];
    } else {
        [self.statusCard updateConnected:NO deviceName:nil macAddress:nil battery:nil];
        [self ts_reloadTableData];
        return;
    }

    __weak typeof(self) weakSelf = self;
    [connector getConnectState:^(TSBleConnectionState state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (state == eTSBleStateConnected) {
                TSPeripheral *peri = [[TopStepComKit sharedInstance] connectedPeripheral];
                [[[TopStepComKit sharedInstance] battery] getBatteryInfoCompletion:^(TSBatteryModel *batteryModel, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.statusCard updateConnected:YES
                                                   deviceName:peri.systemInfo.bleName
                                                   macAddress:peri.systemInfo.mac
                                                      battery:batteryModel];
                        [strongSelf ts_reloadTableData];
                    });
                }];
            } else if (state == eTSBleStateDisconnected) {
                if (strongSelf.statusCard.isReconnectButtonVisible) return;
                [strongSelf.statusCard updateConnected:NO deviceName:nil macAddress:nil battery:nil];
                [strongSelf ts_reloadTableData];
            }
            // 其余状态（Connecting/Authenticating/PreparingData）保持"重连中"态
        });
    }];
}

/**
 * 设备状态卡片点击：已连接时进入设备信息页，未连接时进入扫描页，连接失败时无响应（用重连按钮操作）
 */
- (void)ts_statusCardTapped {

    id<TSBleConnectInterface> connector = [[TopStepComKit sharedInstance] bleConnector];

    // 已连接设备，进入设备信息页
    if (connector && [connector isConnected]) {
        TSPeripheralInfoVC *infoVC = [[TSPeripheralInfoVC alloc] init];
        [self.navigationController pushViewController:infoVC animated:YES];
    }
}

#pragma mark - Navigation Title

- (void)ts_applyNavTitle {
    self.title = TSLocalizedString(@"device.title");
}

#pragma mark - Auto Connect

- (void)ts_autoConnect {
    NSString *mac    = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCurrentMac"];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUserId"];

    TSLog(@"[TSViewController] 尝试自动重连，MAC: %@, userId: %@", mac, userId);

    if (mac.length == 0) {
        TSLog(@"[TSViewController] 没有历史设备，跳过自动重连");
        return;
    }

    TSPeripheral *prePeripheral  = [[TSPeripheral alloc] init];
    prePeripheral.systemInfo.mac = mac;
    TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc] initWithUserId:userId];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] bleConnector] reconnectWithPeripheral:prePeripheral
                                                                     param:param
                                                                completion:^(TSBleConnectionState state, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            TSLog(@"[TSViewController] 自动重连状态变化: %ld, error: %@", (long)state, error);
            if (state == eTSBleStateConnected) {
                TSLog(@"[TSViewController] 自动重连成功");
                [strongSelf ts_registerDeviceCallbacks];
                [strongSelf ts_refreshStatusCard];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TSDeviceReconnectedNotification" object:nil];
                // 成功：两声强振动
                if (@available(iOS 13.0, *)) {
                    UIImpactFeedbackGenerator *impact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
                    [impact impactOccurredWithIntensity:1.0];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [impact impactOccurredWithIntensity:1.0];
                    });
                } else {
                    UIImpactFeedbackGenerator *impact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
                    [impact impactOccurred];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [impact impactOccurred];
                    });
                }
            } else if (state == eTSBleStateDisconnected) {
                TSLog(@"[TSViewController] 自动重连失败: %@", error.localizedDescription);
                [strongSelf.statusCard updateConnectionFailed];
                // 失败：一声强振动
                UINotificationFeedbackGenerator *notif = [[UINotificationFeedbackGenerator alloc] init];
                [notif notificationOccurred:UINotificationFeedbackTypeError];
            } else {
                [strongSelf ts_refreshStatusCard];
            }
        });
    }];
}

#pragma mark - Section Data

/**
 * 构建所有 section 数据，根据设备能力设置 enabled
 */
- (NSArray<NSArray *> *)ts_buildSectionData {
    TopStepComKit *sdk = [TopStepComKit sharedInstance];
    TSPeripheral *peripheral = sdk.connectedPeripheral;
    TSFeatureAbility *ability = peripheral.capability.featureAbility;

    // 未连接设备时，所有功能不可用
    BOOL hasDevice = (peripheral != nil);

    // 眼镜功能
    TSValueModel *glassesModel = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.glasses")
                                                    kitType:eTSKitActivityMeasure
                                                     vcName:NSStringFromClass([TSGlassesVC class])
                                                   iconName:@"eye.fill"
                                                  iconColor:TSColor_Teal
                                                   subtitle:TSLocalizedString(@"device.menu.glasses.sub")];
    glassesModel.enabled = NO;  // 暂不支持眼镜

    // 构建各 section 数据
    NSArray *sectionData = @[
            // ── 设备功能 ──────────────────────────────────────────────────
            @[
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.health_measure")
                                                          kitType:eTSKitActivityMeasure
                                                           vcName:NSStringFromClass([TSActivityMeasureVC class])
                                                         iconName:@"heart.circle.fill"
                                                        iconColor:TSColor_Pink
                                                         subtitle:TSLocalizedString(@"device.menu.health_measure.sub")];
                    m.enabled = hasDevice;  // 综合测量：设备连接即可触发
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.find")
                                                          kitType:eTSKitFind
                                                           vcName:NSStringFromClass([TSPeripheralFindVC class])
                                                         iconName:@"location.fill"
                                                        iconColor:TSColor_Primary
                                                         subtitle:TSLocalizedString(@"device.menu.find.sub")];
                    m.enabled = hasDevice && ability.isSupportFindMyPhone;
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.camera")
                                                          kitType:eTSKitTakePhoto
                                                           vcName:NSStringFromClass([TSTakePhotoVC class])
                                                         iconName:@"camera.fill"
                                                        iconColor:TSColor_Teal
                                                         subtitle:TSLocalizedString(@"device.menu.camera.sub")];
                    m.enabled = hasDevice && (ability.isSupportShakeCamera || ability.isSupportCameraPreview);
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.contacts")
                                                          kitType:eTSKitContact
                                                           vcName:NSStringFromClass([TSContactVC class])
                                                         iconName:@"person.2.fill"
                                                        iconColor:TSColor_Primary
                                                         subtitle:TSLocalizedString(@"device.menu.contacts.sub")];
                    m.enabled = hasDevice && ability.isSupportContacts;
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.alarm")
                                                          kitType:eTSKitAlarmClock
                                                           vcName:NSStringFromClass([TSAlarmClockVC class])
                                                         iconName:@"alarm.fill"
                                                        iconColor:TSColor_Warning
                                                         subtitle:TSLocalizedString(@"device.menu.alarm.sub")];
                    m.enabled = hasDevice && ability.isSupportAlarmClock;
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.world_clock")
                                                          kitType:eTSKitWorldClock
                                                           vcName:NSStringFromClass([TSWorldClockVC class])
                                                         iconName:@"globe"
                                                        iconColor:TSColor_Teal
                                                         subtitle:TSLocalizedString(@"device.menu.world_clock.sub")];
                    m.enabled = hasDevice && ability.isSupportWorldClock;
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.message")
                                                          kitType:eTSKitMessage
                                                           vcName:NSStringFromClass([TSMessageVC class])
                                                         iconName:@"bell.fill"
                                                        iconColor:TSColor_Danger
                                                         subtitle:TSLocalizedString(@"device.menu.message.sub")];
                    m.enabled = hasDevice && ability.isSupportAppNotifications;
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.weather")
                                                          kitType:eTSKitWeather
                                                           vcName:NSStringFromClass([TSWeatherVC class])
                                                         iconName:@"cloud.sun.fill"
                                                        iconColor:TSColor_Primary
                                                         subtitle:TSLocalizedString(@"device.menu.weather.sub")];
                    m.enabled = hasDevice && ability.isSupportWeatherDisplay;
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.dial")
                                                          kitType:eTSKitPeripheralDial
                                                           vcName:NSStringFromClass([TSPeripheralDialVC class])
                                                         iconName:@"clock.fill"
                                                        iconColor:TSColor_Indigo
                                                         subtitle:TSLocalizedString(@"device.menu.dial.sub")];
                    m.enabled = hasDevice && (ability.isSupportFacePush || ability.isSupportCustomFace);
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.ota")
                                                          kitType:eTSKitFileOTA
                                                           vcName:NSStringFromClass([TSFileOTAVC class])
                                                         iconName:@"arrow.down.circle.fill"
                                                        iconColor:TSColor_Success
                                                         subtitle:TSLocalizedString(@"device.menu.ota.sub")];
                    m.enabled = hasDevice && ability.isSupportFirmwareUpgrade;
                    m;
                }),
                glassesModel,
            ],
            // ── 系统设置 ──────────────────────────────────────────────────
            @[
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.user_info")
                                                          kitType:eTSKitUserInfo
                                                           vcName:NSStringFromClass([TSUserInfoVC class])
                                                         iconName:@"person.fill"
                                                        iconColor:TSColor_Primary
                                                         subtitle:TSLocalizedString(@"device.menu.user_info.sub")];
                    m.enabled = hasDevice && ability.isSupportUserInfoSettings;
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.daily_goal")
                                                          kitType:eTSKitExerciseGoal
                                                           vcName:NSStringFromClass([TSDailyExerciseGoalVC class])
                                                         iconName:@"flag.fill"
                                                        iconColor:TSColor_Warning
                                                         subtitle:TSLocalizedString(@"device.menu.daily_goal.sub")];
                    m.enabled = hasDevice && ability.isSupportDailyActivity;  // 每日目标与日常活动相关
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.language")
                                                          kitType:eTSKitLanguage
                                                           vcName:NSStringFromClass([TSLanguagesVC class])
                                                         iconName:@"globe"
                                                        iconColor:TSColor_Primary
                                                         subtitle:TSLocalizedString(@"device.menu.language.sub")];
                    m.enabled = hasDevice && ability.isSupportLanguage;
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.unit")
                                                          kitType:eTSKitUnit
                                                           vcName:NSStringFromClass([TSUnitVC class])
                                                         iconName:@"textformat"
                                                        iconColor:TSColor_Gray
                                                         subtitle:TSLocalizedString(@"device.menu.unit.sub")];
                    m.enabled = hasDevice && ability.isSupportUnitSettings;
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.setting")
                                                          kitType:eTSKitSetting
                                                           vcName:NSStringFromClass([TSSettingVC class])
                                                         iconName:@"gear"
                                                        iconColor:TSColor_Gray
                                                         subtitle:TSLocalizedString(@"device.menu.setting.sub")];
                    m.enabled = hasDevice;  // 开关设置：设备连接即可
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.time")
                                                          kitType:eTSKitTime
                                                           vcName:NSStringFromClass([TSTimeVC class])
                                                         iconName:@"clock.fill"
                                                        iconColor:TSColor_Primary
                                                         subtitle:TSLocalizedString(@"device.menu.time.sub")];
                    m.enabled = hasDevice && ability.isSupportTimeSettings;
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.reminder")
                                                          kitType:eTSKitReminder
                                                           vcName:NSStringFromClass([TSReminderVC class])
                                                         iconName:@"bell.circle.fill"
                                                        iconColor:TSColor_Danger
                                                         subtitle:TSLocalizedString(@"device.menu.reminder.sub")];
                    m.enabled = hasDevice && ability.isSupportReminders;
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.lock")
                                                          kitType:eTSKitPeripheralLock
                                                           vcName:NSStringFromClass([TSPeripheralLockVC class])
                                                         iconName:@"lock.fill"
                                                        iconColor:TSColor_Gray
                                                         subtitle:TSLocalizedString(@"device.menu.lock.sub")];
                    m.enabled = hasDevice && (ability.isSupportGameLock||ability.isSupportScreenLock);
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.auto_monitor")
                                                          kitType:eTSKitAutoMonitor
                                                           vcName:NSStringFromClass([TSAutoMonitorSettingVC class])
                                                         iconName:@"chart.bar.fill"
                                                        iconColor:TSColor_Gray
                                                         subtitle:TSLocalizedString(@"device.menu.auto_monitor.sub")];
                    m.enabled = hasDevice;  // 自动监测：设备连接即可配置
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.battery")
                                                          kitType:eTSKitBattery
                                                           vcName:NSStringFromClass([TSBatteryVC class])
                                                         iconName:@"battery.100"
                                                        iconColor:TSColor_Success
                                                         subtitle:TSLocalizedString(@"device.menu.battery.sub")];
                    m.enabled = hasDevice;  // 电量查询：设备连接即可
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.device_info")
                                                          kitType:eTSKitPeripheralInfo
                                                           vcName:NSStringFromClass([TSPeripheralInfoVC class])
                                                         iconName:@"info.circle.fill"
                                                        iconColor:TSColor_Gray
                                                         subtitle:TSLocalizedString(@"device.menu.device_info.sub")];
                    m.enabled = hasDevice;  // 需要已连接设备
                    m;
                }),
            ],
            // ── 危险操作 ──────────────────────────────────────────────────
            @[
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.remote_control")
                                                          kitType:eTSKitRemoteControl
                                                           vcName:NSStringFromClass([TSRemoteControlVC class])
                                                         iconName:@"hand.raised.fill"
                                                        iconColor:TSColor_Purple
                                                         subtitle:TSLocalizedString(@"device.menu.remote_control.sub")];
                    m.enabled = hasDevice;  // 远程控制：设备连接即可
                    m;
                }),
                ({
                    TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.unbind")
                                                          kitType:0
                                                           vcName:nil
                                                         iconName:@"trash.fill"
                                                        iconColor:TSColor_Danger
                                                         subtitle:TSLocalizedString(@"device.menu.unbind.sub")];
                    // 有绑定记录即可删除（离线时走强制删除流程）
                    NSString *savedMac = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCurrentMac"];
                    m.enabled = (hasDevice || savedMac.length > 0);
                    m;
                }),
            ],
        ];

    return sectionData;
}

/// 返回缓存的 sectionData（供 tableView 回调使用）
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
    BOOL isConnected = [[[TopStepComKit sharedInstance] bleConnector] isConnected];
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
    TopStepComKit *sdk = [TopStepComKit sharedInstance];

    __weak typeof(self) weakSelf = self;
    [[sdk bleConnector] unbindPeripheralCompletion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;

            if (isSuccess) {
                // 清理保存的绑定信息
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kCurrentMac"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kUserId"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TSHasBoundDevice"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                // 解绑成功，切换到设备扫描页面（不带 TabBar）
                TSDeviceScanVC *scanVC = [[TSDeviceScanVC alloc] init];
                UINavigationController *newNavController = [[UINavigationController alloc] initWithRootViewController:scanVC];
                newNavController.modalPresentationStyle = UIModalPresentationFullScreen;

                // 获取 window 并切换根视图控制器
                UIWindow *window = strongSelf.view.window;
                if (window) {
                    window.rootViewController = newNavController;
                    [UIView transitionWithView:window
                                      duration:0.3
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:nil
                                    completion:nil];
                }
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kCurrentMac"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kUserId"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TSHasBoundDevice"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    TSDeviceScanVC *scanVC = [[TSDeviceScanVC alloc] init];
    UINavigationController *newNavController = [[UINavigationController alloc] initWithRootViewController:scanVC];
    newNavController.modalPresentationStyle = UIModalPresentationFullScreen;

    UIWindow *window = self.view.window;
    if (window) {
        window.rootViewController = newNavController;
        [UIView transitionWithView:window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
    }
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
