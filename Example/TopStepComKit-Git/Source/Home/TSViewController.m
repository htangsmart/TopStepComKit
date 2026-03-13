//
//  TSViewController.m
//  TopStepComKit
//
//  Created by rd@hetangsmart.com on 12/23/2024.
//  Copyright (c) 2024 rd@hetangsmart.com. All rights reserved.
//

#import "TSViewController.h"
#import "TSBleConnectVC.h"
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
    TSHomeSectionConnection = 0,   // 连接管理
    TSHomeSectionHealth,           // 健康数据
    TSHomeSectionDevice,           // 设备功能
    TSHomeSectionSettings,         // 系统设置
    TSHomeSectionCount
};

// ─── SDK 类型描述 ────────────────────────────────────────────────────────────
static NSString * const kSDKNames[] = {
    [eTSSDKTypeTPB] = @"NPK",
    [eTSSDKTypeCRP] = @"CRP",
    [eTSSDKTypeUTE] = @"UTE",
    [eTSSDKTypeFW]  = @"FW",
    [eTSSDKTypeFIT] = @"Fit",
    [eTSSDKTypeSJ]  = @"SJ",
};

// ─── 顶部设备状态卡片 ─────────────────────────────────────────────────────────
// 接口声明里补充新方法
@interface TSDeviceStatusCardView : UIView
@property (nonatomic, strong) UIView      *statusDot;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *detailLabel;
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

    // 状态指示点
    self.statusDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.statusDot.layer.cornerRadius = 5;
    self.statusDot.backgroundColor    = TSColor_Gray;
    [self addSubview:self.statusDot];

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
    if (connected) {
        self.statusDot.backgroundColor = TSColor_Success;
        self.titleLabel.text           = name.length > 0 ? name : @"设备已连接";
        self.detailLabel.text          = mac.length > 0 ? mac : @"";
        self.detailLabel.hidden        = (mac.length == 0);
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
                    symbolName = @available(iOS 14.0, *) ? @"battery.100.bolt" : @"bolt.fill";
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
            self.statusDot.backgroundColor  = TSColor_Gray;
            self.titleLabel.text            = @"未连接设备";
            self.detailLabel.text           = @"点击连接蓝牙设备";
            self.detailLabel.hidden         = NO;
            self.batteryIconView.hidden     = YES;
            self.batteryPercentLabel.hidden = YES;
        }
    }
}

// 重连中间态：有历史设备但连接尚未建立
- (void)updateConnecting {
    self.statusDot.backgroundColor = TSColor_Warning;
    self.titleLabel.text           = @"正在重连...";
    self.detailLabel.text          = @"尝试连接上次的设备";
    self.detailLabel.hidden        = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);

    // 右箭头
    CGFloat arrowW = 20.f;
    self.arrowLabel.frame = CGRectMake(w - arrowW - 16.f, (h - 20.f) / 2.f, arrowW, 20.f);

    // 状态点
    CGFloat dotSize = 10.f;
    self.statusDot.frame = CGRectMake(16.f, 16.f, dotSize, dotSize);

    // 文字区域宽度
    CGFloat textX = CGRectGetMaxX(self.statusDot.frame) + 10.f;
    CGFloat textW = CGRectGetMinX(self.arrowLabel.frame) - textX - 8.f;

    // 标题（第一行）
    self.titleLabel.frame = CGRectMake(textX, 12.f, textW, 20.f);

    // MAC（第二行）
    self.detailLabel.frame = CGRectMake(textX, CGRectGetMaxY(self.titleLabel.frame) + 4.f, textW, 16.f);

    // 电池行（第三行）：图标 + 百分比
    CGFloat batteryY  = CGRectGetMaxY(self.detailLabel.frame) + 6.f;
    CGFloat iconW     = 24.f;
    CGFloat iconH     = 16.f;
    CGFloat percentW  = 48.f;

    self.batteryIconView.frame     = CGRectMake(textX, batteryY, iconW, iconH);
    self.batteryPercentLabel.frame = CGRectMake(CGRectGetMaxX(self.batteryIconView.frame) + 6.f,
                                                batteryY, percentW, iconH);
}

@end

// ─── TSViewController ────────────────────────────────────────────────────────
@interface TSViewController () <CBCentralManagerDelegate, TSBleConnectVCDelegate>

@property (nonatomic, strong) CBCentralManager       *centralManager;
@property (nonatomic, assign) TSSDKType               currentSDKType;
@property (nonatomic, strong) NSArray<NSArray *>     *sectionData;    // 二维 sections
@property (nonatomic, strong) TSDeviceStatusCardView *statusCard;

@end

@implementation TSViewController

#pragma mark - Lifecycle

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
    self.currentSDKType = eTSSDKTypeTPB;
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
    // 右上角切换 SDK
    UIBarButtonItem *switchBtn = [[UIBarButtonItem alloc]
        initWithTitle:@"切换 SDK"
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(ts_switchSDKTapped)];
    self.navigationItem.rightBarButtonItem = switchBtn;

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
                    });
                }];
            } else if (state == eTSBleStateDisconnected) {
                [strongSelf.statusCard updateConnected:NO deviceName:nil macAddress:nil battery:nil];
            }
            // 其余状态（Connecting/Authenticating/PreparingData）保持"重连中"态
        });
    }];
}

- (void)ts_statusCardTapped {
    [self ts_pushToBle];
}

#pragma mark - Navigation Title

- (void)ts_applyNavTitle {
    NSString *name = [self ts_sdkName:self.currentSDKType];
    self.title = name.length > 0 ? [NSString stringWithFormat:@"TopStepComKit · %@", name] : @"TopStepComKit";
}

- (NSString *)ts_sdkName:(TSSDKType)type {
    switch (type) {
        case eTSSDKTypeTPB: return @"NPK";
        case eTSSDKTypeCRP: return @"CRP";
        case eTSSDKTypeUTE: return @"UTE";
        case eTSSDKTypeFW:  return @"FW";
        case eTSSDKTypeFIT: return @"Fit";
        case eTSSDKTypeSJ:  return @"SJ";
        default:            return @"";
    }
}

#pragma mark - SDK Switch

- (void)ts_switchSDKTapped {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"切换 SDK 类型"
                                                                   message:@"请选择目标设备平台"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSDictionary *sdkMap = @{
        @"NPK (新平台)": @(eTSSDKTypeTPB),
        @"CRP"         : @(eTSSDKTypeCRP),
        @"UTE"         : @(eTSSDKTypeUTE),
        @"FW"          : @(eTSSDKTypeFW),
        @"Fit"         : @(eTSSDKTypeFIT),
        @"SJ"          : @(eTSSDKTypeSJ),
    };
    NSArray *order = @[@"NPK (新平台)", @"CRP", @"UTE", @"FW", @"Fit", @"SJ"];
    for (NSString *title in order) {
        TSSDKType type = [sdkMap[title] unsignedIntegerValue];
        BOOL isCurrent = (type == self.currentSDKType);
        [sheet addAction:[UIAlertAction actionWithTitle:isCurrent ? [NSString stringWithFormat:@"✓ %@", title] : title
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
            [self ts_resetSDKWithType:type];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    if (sheet.popoverPresentationController) {
        sheet.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    }
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)ts_initSDKWithType:(TSSDKType)type {
    self.currentSDKType = type;
    [self ts_applyNavTitle];
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance] initSDKWithConfigOptions:[self ts_configOptionsWithType:type]
                                                  completion:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            // SDK 就绪后立刻刷新一次，再尝试自动重连
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf ts_refreshStatusCard];
            });
            [weakSelf ts_autoConnect];
        }
    }];
}

- (void)ts_resetSDKWithType:(TSSDKType)type {
    self.currentSDKType = type;
    [self ts_applyNavTitle];
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance] initSDKWithConfigOptions:[self ts_configOptionsWithType:type]
                                                  completion:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            TSLog(@"SDK 切换成功: %@", [weakSelf ts_sdkName:type]);
        } else {
            TSLog(@"SDK 切换失败: %@", error.debugDescription);
        }
    }];
}

- (TSKitConfigOptions *)ts_configOptionsWithType:(TSSDKType)type {
    TSKitConfigOptions *config = [TSKitConfigOptions configOptionWithSDKType:type
                                                                     license:@"abcdef1234567890abcdef1234567890"];
    config.isDevelopModel = YES;
    return config;
}

#pragma mark - Auto Connect

- (void)ts_autoConnect {
    NSString *mac    = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCurrentMac"];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUserId"];
    if (mac.length == 0) return;

    TSPeripheral *prePeripheral  = [[TSPeripheral alloc] init];
    prePeripheral.systemInfo.mac = mac;
    TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc] initWithUserId:userId];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] bleConnector] reconnectWithPeripheral:prePeripheral
                                                                     param:param
                                                                completion:^(TSBleConnectionState state, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf ts_refreshStatusCard];
            if (state == eTSBleStateDisconnected && error) {
                TSLog(@"自动重连失败: %@", error.localizedDescription);
            }
        });
    }];
}

#pragma mark - Section Data

- (NSArray<NSArray *> *)sectionData {
    if (!_sectionData) {
        TSValueModel *glassesModel = [TSValueModel valueWithName:@"眼镜"
                                                        kitType:eTSKitActivityMeasure
                                                         vcName:NSStringFromClass([TSGlassesVC class])
                                                       iconName:@"eye.fill"
                                                      iconColor:TSColor_Teal
                                                       subtitle:@"智能眼镜功能控制"];
        glassesModel.enabled = NO;

        _sectionData = @[
            // ── 连接管理 ──────────────────────────────────────────────────
            @[
                [TSValueModel valueWithName:@"蓝牙连接"
                                   kitType:eTSKitBle
                                    vcName:NSStringFromClass([TSBleConnectVC class])
                                  iconName:@"dot.radiowaves.left.and.right"
                                 iconColor:TSColor_Primary
                                  subtitle:@"扫描并连接附近设备"],
                [TSValueModel valueWithName:@"设备信息"
                                   kitType:eTSKitPeripheralInfo
                                    vcName:NSStringFromClass([TSPeripheralInfoVC class])
                                  iconName:@"info.circle.fill"
                                 iconColor:TSColor_Gray
                                  subtitle:@"固件版本、SN 等详情"],
                [TSValueModel valueWithName:@"数据同步"
                                   kitType:eTSKitDataSync
                                    vcName:NSStringFromClass([TSDataSyncVC class])
                                  iconName:@"arrow.triangle.2.circlepath"
                                 iconColor:TSColor_Success
                                  subtitle:@"拉取历史健康数据"],
            ],
            // ── 健康数据 ──────────────────────────────────────────────────
            @[
                [TSValueModel valueWithName:@"心率"
                                   kitType:eTSKitHR
                                    vcName:NSStringFromClass([TSHearRateVC class])
                                  iconName:@"heart.fill"
                                 iconColor:TSColor_Danger
                                  subtitle:@"实时监测与历史记录"],
                [TSValueModel valueWithName:@"血压"
                                   kitType:eTSKitBP
                                    vcName:NSStringFromClass([TSBloodPressureVC class])
                                  iconName:@"drop.fill"
                                 iconColor:TSColor_Warning
                                  subtitle:@"收缩压 / 舒张压测量"],
                [TSValueModel valueWithName:@"血氧"
                                   kitType:eTSKitBO
                                    vcName:NSStringFromClass([TSBloodOxygenVC class])
                                  iconName:@"staroflife.fill"
                                 iconColor:TSColor_Primary
                                  subtitle:@"血液氧饱和度 SpO₂"],
                [TSValueModel valueWithName:@"压力"
                                   kitType:eTSKitStress
                                    vcName:NSStringFromClass([TSStressVC class])
                                  iconName:@"waveform.path"
                                 iconColor:TSColor_Purple
                                  subtitle:@"HRV 压力指数评估"],
                [TSValueModel valueWithName:@"睡眠"
                                   kitType:eTSKitSleep
                                    vcName:NSStringFromClass([TSSleepVC class])
                                  iconName:@"moon.fill"
                                 iconColor:TSColor_Indigo
                                  subtitle:@"深睡 / 浅睡 / REM 分析"],
                [TSValueModel valueWithName:@"体温"
                                   kitType:eTSKitTemp
                                    vcName:NSStringFromClass([TSTemperatureVC class])
                                  iconName:@"thermometer"
                                 iconColor:TSColor_Warning
                                  subtitle:@"腕温连续监测"],
                [TSValueModel valueWithName:@"心电"
                                   kitType:eTSKitECG
                                    vcName:NSStringFromClass([TSElectrocardioVC class])
                                  iconName:@"waveform.path.ecg"
                                 iconColor:TSColor_Danger
                                  subtitle:@"单导联 ECG 采集"],
                [TSValueModel valueWithName:@"运动"
                                   kitType:eTSKitSport
                                    vcName:NSStringFromClass([TSSportVC class])
                                  iconName:@"flame.fill"
                                 iconColor:TSColor_Success
                                  subtitle:@"运动记录与统计"],
                [TSValueModel valueWithName:@"日常活动"
                                   kitType:eTSKitDailyActivity
                                    vcName:NSStringFromClass([TSDailyActivityVC class])
                                  iconName:@"figure.walk"
                                 iconColor:TSColor_Teal
                                  subtitle:@"步数 / 卡路里 / 距离"],
                [TSValueModel valueWithName:@"健康数据测量"
                                   kitType:eTSKitActivityMeasure
                                    vcName:NSStringFromClass([TSActivityMeasureVC class])
                                  iconName:@"heart.circle.fill"
                                 iconColor:TSColor_Pink
                                  subtitle:@"主动触发综合测量"],
            ],
            // ── 设备功能 ──────────────────────────────────────────────────
            @[
                [TSValueModel valueWithName:@"查找设备"
                                   kitType:eTSKitFind
                                    vcName:NSStringFromClass([TSPeripheralFindVC class])
                                  iconName:@"location.fill"
                                 iconColor:TSColor_Primary
                                  subtitle:@"让手环振动发出提示"],
                [TSValueModel valueWithName:@"摇一摇拍照"
                                   kitType:eTSKitTakePhoto
                                    vcName:NSStringFromClass([TSTakePhotoVC class])
                                  iconName:@"camera.fill"
                                 iconColor:TSColor_Teal
                                  subtitle:@"手环远程触发拍照"],
                [TSValueModel valueWithName:@"通讯录"
                                   kitType:eTSKitContact
                                    vcName:NSStringFromClass([TSContactVC class])
                                  iconName:@"person.2.fill"
                                 iconColor:TSColor_Primary
                                  subtitle:@"同步联系人到设备"],
                [TSValueModel valueWithName:@"闹钟"
                                   kitType:eTSKitAlarmClock
                                    vcName:NSStringFromClass([TSAlarmClockVC class])
                                  iconName:@"alarm.fill"
                                 iconColor:TSColor_Warning
                                  subtitle:@"设置手环闹钟"],
                [TSValueModel valueWithName:@"世界时钟"
                                   kitType:eTSKitWorldClock
                                    vcName:NSStringFromClass([TSWorldClockVC class])
                                  iconName:@"globe"
                                 iconColor:TSColor_Teal
                                  subtitle:@"管理手表上的城市时钟"],
                [TSValueModel valueWithName:@"消息通知"
                                   kitType:eTSKitMessage
                                    vcName:NSStringFromClass([TSMessageVC class])
                                  iconName:@"bell.fill"
                                 iconColor:TSColor_Danger
                                  subtitle:@"推送通知到手环"],
                [TSValueModel valueWithName:@"天气"
                                   kitType:eTSKitWeather
                                    vcName:NSStringFromClass([TSWeatherVC class])
                                  iconName:@"cloud.sun.fill"
                                 iconColor:TSColor_Primary
                                  subtitle:@"同步天气预报到设备"],
                [TSValueModel valueWithName:@"表盘"
                                   kitType:eTSKitPeripheralDial
                                    vcName:NSStringFromClass([TSPeripheralDialVC class])
                                  iconName:@"clock.fill"
                                 iconColor:TSColor_Indigo
                                  subtitle:@"推送自定义表盘"],
                [TSValueModel valueWithName:@"OTA 升级"
                                   kitType:eTSKitFileOTA
                                    vcName:NSStringFromClass([TSFileOTAVC class])
                                  iconName:@"arrow.down.circle.fill"
                                 iconColor:TSColor_Success
                                  subtitle:@"固件空中升级 OTA"],
                [TSValueModel valueWithName:@"设备控制"
                                   kitType:eTSKitRemoteControl
                                    vcName:NSStringFromClass([TSRemoteControlVC class])
                                  iconName:@"hand.raised.fill"
                                 iconColor:TSColor_Purple
                                  subtitle:@"发送远程控制指令"],
                glassesModel,
            ],
            // ── 系统设置 ──────────────────────────────────────────────────
            @[
                [TSValueModel valueWithName:@"用户信息"
                                   kitType:eTSKitUserInfo
                                    vcName:NSStringFromClass([TSUserInfoVC class])
                                  iconName:@"person.fill"
                                 iconColor:TSColor_Primary
                                  subtitle:@"性别 / 年龄 / 身高 / 体重"],
                [TSValueModel valueWithName:@"每日运动目标"
                                   kitType:eTSKitExerciseGoal
                                    vcName:NSStringFromClass([TSDailyExerciseGoalVC class])
                                  iconName:@"flag.fill"
                                 iconColor:TSColor_Warning
                                  subtitle:@"步数与卡路里目标设置"],
                [TSValueModel valueWithName:@"语言设置"
                                   kitType:eTSKitLanguage
                                    vcName:NSStringFromClass([TSLanguagesVC class])
                                  iconName:@"globe"
                                 iconColor:TSColor_Primary
                                  subtitle:@"设备界面显示语言"],
                [TSValueModel valueWithName:@"单位设置"
                                   kitType:eTSKitUnit
                                    vcName:NSStringFromClass([TSUnitVC class])
                                  iconName:@"textformat"
                                 iconColor:TSColor_Gray
                                  subtitle:@"公制 / 英制单位切换"],
                [TSValueModel valueWithName:@"开关设置"
                                   kitType:eTSKitSetting
                                    vcName:NSStringFromClass([TSSettingVC class])
                                  iconName:@"gear"
                                 iconColor:TSColor_Gray
                                  subtitle:@"抬腕亮屏等功能开关"],
                [TSValueModel valueWithName:@"时间设置"
                                   kitType:eTSKitTime
                                    vcName:NSStringFromClass([TSTimeVC class])
                                  iconName:@"clock.fill"
                                 iconColor:TSColor_Primary
                                  subtitle:@"同步系统时间到设备"],
                [TSValueModel valueWithName:@"提醒设置"
                                   kitType:eTSKitReminder
                                    vcName:NSStringFromClass([TSReminderVC class])
                                  iconName:@"bell.circle.fill"
                                 iconColor:TSColor_Danger
                                  subtitle:@"久坐 / 喝水 / 吃药提醒"],
                [TSValueModel valueWithName:@"自动监测设置"
                                   kitType:eTSKitAutoMonitor
                                    vcName:NSStringFromClass([TSAutoMonitorSettingVC class])
                                  iconName:@"chart.bar.fill"
                                 iconColor:TSColor_Gray
                                  subtitle:@"后台自动健康测量配置"],
                [TSValueModel valueWithName:@"电量"
                                   kitType:eTSKitBattery
                                    vcName:NSStringFromClass([TSBatteryVC class])
                                  iconName:@"battery.100"
                                 iconColor:TSColor_Success
                                  subtitle:@"查询设备当前电量"],
            ],
        ];
    }
    return _sectionData;
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
        case TSHomeSectionConnection: return @"连接管理";
        case TSHomeSectionHealth:     return @"健康数据";
        case TSHomeSectionDevice:     return @"设备功能";
        case TSHomeSectionSettings:   return @"系统设置";
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

    if (value.kitType == eTSKitBle) {
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

- (void)ts_pushToBle {
    TSBleConnectVC *vc = [[TSBleConnectVC alloc] init];
    vc.title    = @"蓝牙连接";
    vc.delegate = self;
    [self ts_pushVC:vc];
}

- (void)ts_pushVC:(UIViewController *)vc {
    if (!vc) return;
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Bluetooth Permission

- (void)ts_checkBluetooth {
    switch (self.centralManager.state) {
        case CBManagerStatePoweredOn: {
            dispatch_async(dispatch_get_main_queue(), ^{ [self ts_pushToBle]; });
            break;
        }
        case CBManagerStatePoweredOff: {
            [self ts_showBluetoothAlert:@"请开启蓝牙以使用设备"];
            break;
        }
        case CBManagerStateUnauthorized: {
            [self ts_showBluetoothAlert:@"请在「设置 → 隐私与安全 → 蓝牙」中授权本应用"];
            break;
        }
        default:
            break;
    }
}

- (void)ts_showBluetoothAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"蓝牙不可用"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"前往设置"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn: {
            [self ts_initSDKWithType:eTSSDKTypeTPB];
            break;
        }
        case CBManagerStatePoweredOff: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self ts_showBluetoothAlert:@"请开启蓝牙以使用设备"];
            });
            break;
        }
        case CBManagerStateUnauthorized: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self ts_showBluetoothAlert:@"请在「设置」中授权蓝牙权限"];
            });
            break;
        }
        default:
            break;
    }
}

#pragma mark - TSBleConnectVCDelegate

- (void)connectSuccess:(TSPeripheral *)peripheral param:(TSPeripheralConnectParam *)connectParam {
    if (peripheral.systemInfo.mac.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:peripheral.systemInfo.mac forKey:@"kCurrentMac"];
        [[NSUserDefaults standardUserDefaults] setObject:connectParam.userId       forKey:@"kUserId"];
    }
    [self ts_registerDeviceCallbacks];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self ts_refreshStatusCard];
    });
}

- (void)unbindSuccess {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kCurrentMac"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kUserId"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self ts_refreshStatusCard];
    });
}

@end
