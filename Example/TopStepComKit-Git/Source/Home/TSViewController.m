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
#import "TSWorldClockVC.h"

// ─── Section 枚举 ───────────────────────────────────────────────────────────
typedef NS_ENUM(NSUInteger, TSHomeSection) {
    TSHomeSectionDevice = 0,       // 设备功能
    TSHomeSectionSettings,         // 系统设置
    TSHomeSectionDanger,           // 危险操作
    TSHomeSectionCount
};

// ─── 顶部设备状态卡片 ─────────────────────────────────────────────────────────
// 接口声明里补充新方法
@interface TSDeviceStatusCardView : UIView
@property (nonatomic, strong) UIImageView *watchIconView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *detailLabel;
@property (nonatomic, strong) UILabel     *statusLabel;
@property (nonatomic, strong) UIImageView *batteryIconView;
@property (nonatomic, strong) UILabel     *batteryPercentLabel;
@property (nonatomic, strong) UILabel     *arrowLabel;
- (void)updateConnected:(BOOL)connected deviceName:(nullable NSString *)name macAddress:(nullable NSString *)mac battery:(nullable TSBatteryModel *)battery;
- (void)updateConnecting;
@end

@implementation TSDeviceStatusCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self ts_setup];
    }
    return self;
}

- (void)ts_setup {
    self.backgroundColor    = TSColor_Card;
    self.layer.cornerRadius = TSRadius_MD;
    self.layer.shadowColor  = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowRadius = 8;
    self.layer.shadowOpacity = 0.08f;
    self.clipsToBounds = NO;

    // 手表图标
    self.watchIconView = [[UIImageView alloc] init];
    self.watchIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.watchIconView.tintColor = TSColor_Primary;
    if (@available(iOS 13.0, *)) {
        self.watchIconView.image = [UIImage systemImageNamed:@"applewatch"];
    }
    [self addSubview:self.watchIconView];

    // 标题：设备名 or "未连接"
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font      = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    self.titleLabel.textColor = TSColor_TextPrimary;
    [self addSubview:self.titleLabel];

    // 副标题：MAC 地址
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font      = [UIFont systemFontOfSize:12];
    self.detailLabel.textColor = TSColor_TextSecondary;
    [self addSubview:self.detailLabel];

    // 状态文字标签
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font      = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [self addSubview:self.statusLabel];

    // 电池图标
    self.batteryIconView = [[UIImageView alloc] init];
    self.batteryIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.batteryIconView.tintColor   = TSColor_Success;
    self.batteryIconView.hidden      = YES;
    [self addSubview:self.batteryIconView];

    // 电池百分比数字
    self.batteryPercentLabel = [[UILabel alloc] init];
    self.batteryPercentLabel.font          = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.batteryPercentLabel.textColor     = TSColor_TextSecondary;
    self.batteryPercentLabel.hidden        = YES;
    [self addSubview:self.batteryPercentLabel];

    // 右侧箭头
    self.arrowLabel = [[UILabel alloc] init];
    self.arrowLabel.text      = @">";
    self.arrowLabel.font      = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.arrowLabel.textColor = TSColor_TextSecondary;
    [self addSubview:self.arrowLabel];

    [self updateConnected:NO deviceName:nil macAddress:nil battery:nil];
}

- (void)updateConnected:(BOOL)connected deviceName:(nullable NSString *)name macAddress:(nullable NSString *)mac battery:(nullable TSBatteryModel *)battery {
    // 停止连接动画
    [self stopConnectingAnimation];

    if (connected) {
        self.titleLabel.text           = name.length > 0 ? name : TSLocalizedString(@"device.connected_default");
        self.detailLabel.text          = mac.length > 0 ? mac : @"";
        self.detailLabel.hidden        = (mac.length == 0);

        // 状态文字：已连接（绿色）
        self.statusLabel.text      = TSLocalizedString(@"device.connected");
        self.statusLabel.textColor = TSColor_Success;

        if (battery) {
            NSInteger pct = battery.percentage;
            TSBatteryState s = battery.chargeState;

            // 颜色
            UIColor *levelColor;
            if (s == TSBatteryStateCharging || s == TSBatteryStateFull) {
                levelColor = TSColor_Success;
            } else if (pct > 50) {
                levelColor = TSColor_Success;
            } else if (pct > 20) {
                levelColor = TSColor_Warning;
            } else {
                levelColor = TSColor_Danger;
            }

            // 图标
            if (@available(iOS 13.0, *)) {
                NSString *symbolName;
                if (s == TSBatteryStateCharging) {
                    if (@available(iOS 14.0, *)) {
                        symbolName = @"battery.100.bolt";
                    } else {
                        symbolName = @"bolt.fill";
                    }
                } else if (s == TSBatteryStateFull || pct >= 90) {
                    symbolName = @"battery.100";
                } else if (pct >= 65) {
                    symbolName = @"battery.75";
                } else if (pct >= 40) {
                    symbolName = @"battery.50";
                } else if (pct >= 15) {
                    symbolName = @"battery.25";
                } else {
                    symbolName = @"battery.0";
                }
                UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration
                                                   configurationWithPointSize:18 weight:UIImageSymbolWeightRegular];
                self.batteryIconView.image     = [UIImage systemImageNamed:symbolName withConfiguration:cfg];
                self.batteryIconView.tintColor = levelColor;
                self.batteryPercentLabel.text      = [NSString stringWithFormat:@"%ld%%", (long)pct];
                self.batteryPercentLabel.textColor = levelColor;
                self.batteryIconView.hidden      = NO;
                self.batteryPercentLabel.hidden  = NO;
            } else {
                self.batteryIconView.hidden     = YES;
                self.batteryPercentLabel.hidden = YES;
            }
        } else {
            self.batteryIconView.hidden     = YES;
            self.batteryPercentLabel.hidden = YES;
        }
    } else {
        // 状态文字：未连接（灰色）
        self.statusLabel.text      = TSLocalizedString(@"device.disconnected");
        self.statusLabel.textColor = TSColor_Gray;

        self.titleLabel.text            = TSLocalizedString(@"device.not_connected");
        self.detailLabel.text           = TSLocalizedString(@"device.tap_to_connect");
        self.detailLabel.hidden         = NO;
        self.batteryIconView.hidden     = YES;
        self.batteryPercentLabel.hidden = YES;
    }
}

// 重连中间态：有历史设备但连接尚未建立
- (void)updateConnecting {
    // 状态文字：连接中...（橙色）
    self.statusLabel.text      = TSLocalizedString(@"device.connecting");
    self.statusLabel.textColor = TSColor_Warning;

    self.titleLabel.text           = TSLocalizedString(@"device.reconnecting");
    self.detailLabel.text          = TSLocalizedString(@"device.reconnect_hint");
    self.detailLabel.hidden        = NO;
    self.batteryIconView.hidden     = YES;
    self.batteryPercentLabel.hidden = YES;

    // 添加闪烁动画
    [self startConnectingAnimation];
}

/** 开始连接中动画 */
- (void)startConnectingAnimation {
    [self.statusLabel.layer removeAllAnimations];

    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1.0);
    opacityAnimation.toValue = @(0.3);
    opacityAnimation.duration = 0.8;
    opacityAnimation.repeatCount = HUGE_VALF;
    opacityAnimation.autoreverses = YES;
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    [self.statusLabel.layer addAnimation:opacityAnimation forKey:@"connecting"];
}

/** 停止连接中动画 */
- (void)stopConnectingAnimation {
    [self.statusLabel.layer removeAnimationForKey:@"connecting"];
    self.statusLabel.layer.opacity = 1.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);

    // 左侧手表图标（高度和卡片一样）
    CGFloat watchIconW = h - 20;  // 宽度等于高度，保持正方形
    self.watchIconView.frame = CGRectMake(0, 10, watchIconW, watchIconW);

    // 右箭头
    CGFloat arrowW = 20.f;
    self.arrowLabel.frame = CGRectMake(w - arrowW - 16.f, (h - 20.f) / 2.f, arrowW, 20.f);

    // 文字区域起始位置（在手表图标右侧）
    CGFloat textX = CGRectGetMaxX(self.watchIconView.frame) + 10.f;
    CGFloat textW = CGRectGetMinX(self.arrowLabel.frame) - textX - 8.f;

    // 标题（第一行）
    self.titleLabel.frame = CGRectMake(textX, 12.f, textW, 20.f);

    // MAC（第二行）
    self.detailLabel.frame = CGRectMake(textX, CGRectGetMaxY(self.titleLabel.frame) + 4.f, textW, 16.f);

    // 第三行：状态文字 + 电池图标 + 百分比
    CGFloat thirdRowY = CGRectGetMaxY(self.detailLabel.frame) + 6.f;

    // 状态文字
    CGSize statusSize = [self.statusLabel.text sizeWithAttributes:@{NSFontAttributeName: self.statusLabel.font}];
    self.statusLabel.frame = CGRectMake(textX, thirdRowY, statusSize.width + 4.f, 16.f);

    // 电池图标（在状态文字右侧）
    CGFloat batteryX = CGRectGetMaxX(self.statusLabel.frame) + 12.f;
    CGFloat iconW    = 24.f;
    CGFloat iconH    = 16.f;
    CGFloat percentW = 48.f;

    self.batteryIconView.frame     = CGRectMake(batteryX, thirdRowY, iconW, iconH);
    self.batteryPercentLabel.frame = CGRectMake(CGRectGetMaxX(self.batteryIconView.frame) + 6.f,
                                                thirdRowY, percentW, iconH);
}

@end

// ─── TSViewController ────────────────────────────────────────────────────────
@interface TSViewController () <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager       *centralManager;
@property (nonatomic, strong) TSDeviceStatusCardView *statusCard;

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

    self.sourceTableview.tableHeaderView = container;
}

- (void)layoutViews {
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;
    self.sourceTableview.frame = CGRectMake(0, topOffset,
                                            self.view.frame.size.width,
                                            CGRectGetHeight(self.view.frame) - topOffset);
}

#pragma mark - Status Card

- (void)ts_refreshStatusCard {
    id<TSBleConnectInterface> connector = [[TopStepComKit sharedInstance] bleConnector];

    // ① SDK 尚未初始化（bleConnector 为 nil）
    if (!connector) {
        NSString *savedMac = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCurrentMac"];
        if (savedMac.length > 0) {
            [self.statusCard updateConnecting];   // 有历史设备，显示"重连中"
        } else {
            [self.statusCard updateConnected:NO deviceName:nil macAddress:nil battery:nil];
        }
        [self.sourceTableview reloadData];  // 刷新列表
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
                [weakSelf.sourceTableview reloadData];  // 刷新列表
            });
        }];
        return;
    }

    // ③ 未完全连接：异步精确查询，处理"连接中/认证中"等过渡状态
    NSString *savedMac = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCurrentMac"];
    // 先显示过渡态
    if (savedMac.length > 0) {
        [self.statusCard updateConnecting];
    } else {
        [self.statusCard updateConnected:NO deviceName:nil macAddress:nil battery:nil];
        [self.sourceTableview reloadData];  // 刷新列表
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
                        [strongSelf.sourceTableview reloadData];  // 刷新列表
                    });
                }];
            } else if (state == eTSBleStateDisconnected) {
                [strongSelf.statusCard updateConnected:NO deviceName:nil macAddress:nil battery:nil];
                [strongSelf.sourceTableview reloadData];  // 刷新列表
            }
            // 其余状态（Connecting/Authenticating/PreparingData）保持"重连中"态
        });
    }];
}

/**
 * 设备状态卡片点击：已连接时进入设备信息页，未连接时进入扫描页
 */
- (void)ts_statusCardTapped {
    id<TSBleConnectInterface> connector = [[TopStepComKit sharedInstance] bleConnector];

    // 已连接设备，进入设备信息页
    if (connector && [connector isConnected]) {
        TSPeripheralInfoVC *infoVC = [[TSPeripheralInfoVC alloc] init];
        [self.navigationController pushViewController:infoVC animated:YES];
    } else {
        // 未连接，进入扫描页
        TSDeviceScanVC *scanVC = [[TSDeviceScanVC alloc] init];
        [self.navigationController pushViewController:scanVC animated:YES];
    }
}

#pragma mark - Navigation Title

- (void)ts_applyNavTitle {
    self.title = TSLocalizedString(@"device.title");
}

#pragma mark - SDK Init

- (void)ts_initSDK {
    TSLog(@"[TSViewController] 开始初始化 SDK");
    [self ts_applyNavTitle];
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance] initSDKWithConfigOptions:[self ts_configOptions]
                                                  completion:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            TSLog(@"[TSViewController] SDK 初始化成功");
            // SDK 就绪后立刻刷新一次，再尝试自动重连
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf ts_refreshStatusCard];
            });
            [weakSelf ts_autoConnect];
        } else {
            TSLog(@"[TSViewController] SDK 初始化失败: %@", error);
        }
    }];
}

- (TSKitConfigOptions *)ts_configOptions {
    TSKitConfigOptions *config = [TSKitConfigOptions configOptionWithSDKType:eTSSDKTypeTPB
                                                                     license:@"abcdef1234567890abcdef1234567890"];
    config.isDevelopModel = YES;
    return config;
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
            TSLog(@"[TSViewController] 自动重连状态变化: %ld, error: %@", (long)state, error);
            [weakSelf ts_refreshStatusCard];
            if (state == eTSBleStateConnected) {
                // 重连成功，发送通知触发 TSHomeVC 刷新
                TSLog(@"[TSViewController] 自动重连成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TSDeviceReconnectedNotification" object:nil];
            } else if (state == eTSBleStateDisconnected && error) {
                TSLog(@"[TSViewController] 自动重连失败: %@", error.localizedDescription);
            }
        });
    }];
}

#pragma mark - Section Data

/**
 * 构建所有 section 数据，根据设备能力设置 enabled
 */
- (NSArray<NSArray *> *)sectionData {
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
                    m.enabled = hasDevice;  // 需要已连接设备
                    m;
                }),
            ],
        ];

    return sectionData;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TSHomeSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < (NSInteger)self.sectionData.count) {
        return self.sectionData[section].count;
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
    if (indexPath.section < (NSInteger)self.sectionData.count) {
        NSArray *rows = self.sectionData[indexPath.section];
        if (indexPath.row < (NSInteger)rows.count) {
            [cell reloadCellWithModel:rows[indexPath.row]];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section >= (NSInteger)self.sectionData.count) return;
    NSArray *rows = self.sectionData[indexPath.section];
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"unbind.title")
                                                                   message:TSLocalizedString(@"unbind.message")
                                                            preferredStyle:UIAlertControllerStyleAlert];

    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"unbind.action") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [weakSelf ts_performUnbind];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
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
    switch (central.state) {
        case CBManagerStatePoweredOn: {
            TSLog(@"[TSViewController] 蓝牙已开启，开始初始化 SDK");
            [self ts_initSDK];
            break;
        }
        case CBManagerStatePoweredOff: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self ts_showBluetoothAlert:TSLocalizedString(@"ble.turn_on")];
            });
            break;
        }
        case CBManagerStateUnauthorized: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self ts_showBluetoothAlert:TSLocalizedString(@"ble.authorize_short")];
            });
            break;
        }
        default:
            break;
    }
}

@end
