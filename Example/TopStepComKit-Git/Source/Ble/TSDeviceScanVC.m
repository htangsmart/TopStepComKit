//
//  TSDeviceScanVC.m
//  TopStepComKit_Example
//
//  Created by Claude on 2026/3/17.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSDeviceScanVC.h"
#import "TSBaseVC.h"
#import "TSDeviceConnectVC.h"
#import <TopStepComKit/TopStepComKit.h>

// ─── 设备卡片视图 ───────────────────────────────────────────────────────
@interface TSDeviceCardView : UITableViewCell

@property (nonatomic, strong) TSPeripheral *peripheral;
@property (nonatomic, strong) UIImageView *deviceIconView;
@property (nonatomic, strong) UILabel *deviceNameLabel;
@property (nonatomic, strong) UILabel *macAddressLabel;
@property (nonatomic, strong) UIImageView *signalIconView;
@property (nonatomic, strong) UIImageView *arrowIconView;

- (void)updateWithPeripheral:(TSPeripheral *)peripheral;

@end

@implementation TSDeviceCardView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

/**
 * 初始化UI
 */
- (void)setupUI {
    self.backgroundColor = TSColor_Background;
    self.contentView.backgroundColor = TSColor_Card;
    self.contentView.layer.cornerRadius = TSRadius_LG;
    self.contentView.layer.masksToBounds = YES;

    // 设备图标
    self.deviceIconView = [[UIImageView alloc] init];
    self.deviceIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.deviceIconView.tintColor = TSColor_Primary;
    if (@available(iOS 13.0, *)) {
        self.deviceIconView.image = [UIImage systemImageNamed:@"applewatch"];
    }
    [self.contentView addSubview:self.deviceIconView];

    // 设备名称
    self.deviceNameLabel = [[UILabel alloc] init];
    self.deviceNameLabel.font = TSFont_H2;
    self.deviceNameLabel.textColor = TSColor_TextPrimary;
    [self.contentView addSubview:self.deviceNameLabel];

    // MAC 地址
    self.macAddressLabel = [[UILabel alloc] init];
    self.macAddressLabel.font = TSFont_Caption;
    self.macAddressLabel.textColor = TSColor_TextSecondary;
    [self.contentView addSubview:self.macAddressLabel];

    // 信号强度
    self.signalIconView = [[UIImageView alloc] init];
    self.signalIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.signalIconView.tintColor = TSColor_Success;
    if (@available(iOS 13.0, *)) {
        self.signalIconView.image = [UIImage systemImageNamed:@"wifi"];
    }
    [self.contentView addSubview:self.signalIconView];

    // 箭头
    self.arrowIconView = [[UIImageView alloc] init];
    self.arrowIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.arrowIconView.tintColor = TSColor_TextSecondary;
    if (@available(iOS 13.0, *)) {
        self.arrowIconView.image = [UIImage systemImageNamed:@"chevron.right"];
    }
    [self.contentView addSubview:self.arrowIconView];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);

    // contentView 留出上下左右间距
    self.contentView.frame = CGRectMake(TSSpacing_MD, TSSpacing_SM, w - TSSpacing_MD * 2, h - TSSpacing_SM * 2);

    CGFloat contentW = CGRectGetWidth(self.contentView.bounds);
    CGFloat contentH = CGRectGetHeight(self.contentView.bounds);

    self.deviceIconView.frame = CGRectMake(TSSpacing_MD, (contentH - 50) / 2, 50, 50);
    self.deviceNameLabel.frame = CGRectMake(CGRectGetMaxX(self.deviceIconView.frame) + TSSpacing_MD,
                                            TSSpacing_MD,
                                            contentW - 150,
                                            24);
    self.macAddressLabel.frame = CGRectMake(CGRectGetMaxX(self.deviceIconView.frame) + TSSpacing_MD,
                                            CGRectGetMaxY(self.deviceNameLabel.frame) + 4,
                                            contentW - 150,
                                            16);
    self.arrowIconView.frame = CGRectMake(contentW - 40, (contentH - 20) / 2, 20, 20);
    self.signalIconView.frame = CGRectMake(contentW - 70, (contentH - 20) / 2, 20, 20);
}

/**
 * 更新设备信息
 */
- (void)updateWithPeripheral:(TSPeripheral *)peripheral {
    self.peripheral = peripheral;
    self.deviceNameLabel.text = peripheral.systemInfo.bleName ?: @"未知设备";
    self.macAddressLabel.text = peripheral.systemInfo.mac ?: @"--:--:--:--:--:--";

    // 根据信号强度显示不同图标
    NSInteger rssi = peripheral.systemInfo.RSSI.integerValue;
    if (@available(iOS 13.0, *)) {
        if (rssi > -60) {
            self.signalIconView.image = [UIImage systemImageNamed:@"wifi"];
            self.signalIconView.tintColor = TSColor_Success;
        } else if (rssi > -80) {
            self.signalIconView.image = [UIImage systemImageNamed:@"wifi.slash"];
            self.signalIconView.tintColor = TSColor_Warning;
        } else {
            self.signalIconView.image = [UIImage systemImageNamed:@"wifi.exclamationmark"];
            self.signalIconView.tintColor = TSColor_Danger;
        }
    }
}

@end

// ─── 主视图控制器 ───────────────────────────────────────────────────────
@interface TSDeviceScanVC ()

@property (nonatomic, strong) UIView *radarContainerView;
@property (nonatomic, strong) UIView *radarCenterView;
@property (nonatomic, strong) UIView *bluetoothIconView;
@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *rippleLayers;
@property (nonatomic, strong) CAShapeLayer *radarScanLayer;
@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) NSMutableArray<TSPeripheral *> *discoveredDevices;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TSPeripheral *> *peripheralDict;
@property (nonatomic, assign) BOOL isScanning;
@property (nonatomic, assign) TSSDKType currentSDKType;

@end

@implementation TSDeviceScanVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加设备";
    self.view.backgroundColor = TSColor_Background;

    self.discoveredDevices = [NSMutableArray array];
    self.peripheralDict = [NSMutableDictionary dictionary];
    self.rippleLayers = [NSMutableArray array];

    // 读取上次保存的 SDK 类型，默认 eTSSDKTypeTPB
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"TSSavedSDKType"]) {
        self.currentSDKType = (TSSDKType)[defaults integerForKey:@"TSSavedSDKType"];
    } else {
        self.currentSDKType = eTSSDKTypeTPB;
    }

    [self setupViews];
    [self ts_updateSDKTypeButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat topOffset = 0;
    if (@available(iOS 11.0, *)) {
        topOffset = self.view.safeAreaInsets.top;
    }
    if (topOffset == 0) topOffset = 64;

    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    CGFloat screenH = CGRectGetHeight(self.view.bounds);

    // 雷达区域
    CGFloat radarSize = 200;
    CGFloat radarY = topOffset + TSSpacing_XL;
    self.radarContainerView.frame = CGRectMake((screenW - radarSize) / 2, radarY, radarSize, radarSize);
    self.radarCenterView.frame = CGRectMake((radarSize - 80) / 2, (radarSize - 80) / 2, 80, 80);

    // 扫描按钮
    CGFloat buttonY = CGRectGetMaxY(self.radarContainerView.frame) + TSSpacing_LG;
    self.scanButton.frame = CGRectMake((screenW - 160) / 2, buttonY, 160, 50);

    // 状态标签
    self.statusLabel.frame = CGRectMake(TSSpacing_MD, CGRectGetMaxY(self.scanButton.frame) + TSSpacing_SM,
                                        screenW - TSSpacing_MD * 2, 20);

    // TableView
    CGFloat tableY = CGRectGetMaxY(self.statusLabel.frame) + TSSpacing_LG;
    self.tableView.frame = CGRectMake(0, tableY, screenW, screenH - tableY);

    // 空状态
    self.emptyLabel.frame = CGRectMake(TSSpacing_MD, tableY + 60,
                                       screenW - TSSpacing_MD * 2, 60);
}

#pragma mark - UI 设置

/**
 * 设置视图
 */
- (void)setupViews {
    // 雷达容器
    self.radarContainerView = [[UIView alloc] init];
    self.radarContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.radarContainerView];

    // 雷达中心
    self.radarCenterView = [[UIView alloc] init];
    self.radarCenterView.backgroundColor = TSColor_Primary;
    self.radarCenterView.layer.cornerRadius = 40;
    self.radarCenterView.clipsToBounds = YES;
    [self.radarContainerView addSubview:self.radarCenterView];

    // 蓝牙图标（用 antenna.radiowaves.left.and.right，template 渲染，白色）
    if (@available(iOS 13.0, *)) {
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.image = [UIImage systemImageNamed:@"antenna.radiowaves.left.and.right"];
        iconView.tintColor = [UIColor whiteColor];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.frame = CGRectMake(18, 18, 44, 44);
        [self.radarCenterView addSubview:iconView];
        self.bluetoothIconView = iconView;
    }

    // 扫描按钮
    self.scanButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.scanButton setTitle:@"开始扫描" forState:UIControlStateNormal];
    [self.scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.scanButton.titleLabel.font = TSFont_H2;
    self.scanButton.backgroundColor = TSColor_Primary;
    self.scanButton.layer.cornerRadius = TSRadius_MD;
    [self.scanButton addTarget:self action:@selector(handleScanButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scanButton];

    // 状态标签
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"点击按钮开始扫描设备";
    self.statusLabel.font = TSFont_Caption;
    self.statusLabel.textColor = TSColor_TextSecondary;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];

    // TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = TSColor_Background;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(TSSpacing_MD, 0, TSSpacing_MD, 0);
    [self.view addSubview:self.tableView];

    // 空状态标签
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"暂无设备\n请确保设备已开机并靠近手机";
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.font = TSFont_Body;
    self.emptyLabel.textColor = TSColor_TextSecondary;
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.hidden = YES;
    [self.view addSubview:self.emptyLabel];
}

#pragma mark - SDK 类型选择

/**
 * 返回 SDK 类型显示名称
 */
- (NSString *)ts_sdkTypeName:(TSSDKType)type {
    switch (type) {
        case eTSSDKTypeTPB: return @"NPK";
        case eTSSDKTypeCRP: return @"CRP";
        case eTSSDKTypeUTE: return @"UTE";
        case eTSSDKTypeFW:  return @"FW";
        case eTSSDKTypeFIT: return @"Fit";
        case eTSSDKTypeSJ:  return @"SJ";
        default:            return @"NPK";
    }
}

/**
 * 更新右上角按钮标题
 */
- (void)ts_updateSDKTypeButton {
    NSString *title = [NSString stringWithFormat:@"%@ ▾", [self ts_sdkTypeName:self.currentSDKType]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(ts_showSDKTypeSelection)];
    self.navigationItem.rightBarButtonItem = item;
}

/**
 * 弹出 SDK 类型选择
 */
- (void)ts_showSDKTypeSelection {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择设备类型"
                                                                   message:@"请选择目标设备平台"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    NSArray<NSNumber *> *types = @[
        @(eTSSDKTypeTPB), @(eTSSDKTypeCRP), @(eTSSDKTypeUTE),
        @(eTSSDKTypeFW),  @(eTSSDKTypeFIT), @(eTSSDKTypeSJ)
    ];

    __weak typeof(self) weakSelf = self;
    for (NSNumber *typeNum in types) {
        TSSDKType type = (TSSDKType)typeNum.integerValue;
        NSString *name = [self ts_sdkTypeName:type];
        BOOL isSelected = (type == self.currentSDKType);
        NSString *title = isSelected ? [NSString stringWithFormat:@"✓  %@", name] : name;
        [alert addAction:[UIAlertAction actionWithTitle:title
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || strongSelf.currentSDKType == type) return;
            strongSelf.currentSDKType = type;
            [[NSUserDefaults standardUserDefaults] setInteger:type forKey:@"TSSavedSDKType"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [strongSelf ts_updateSDKTypeButton];
            if (strongSelf.isScanning) {
                [strongSelf stopScan];
            }
        }]];
    }

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    alert.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 扫描控制

/**
 * 处理扫描按钮点击
 */
- (void)handleScanButtonTap {
    if (self.isScanning) {
        [self stopScan];
    } else {
        [self startScan];
    }
}

/**
 * 开始扫描
 */
- (void)startScan {
    self.isScanning = YES;
    [self.scanButton setTitle:@"停止扫描" forState:UIControlStateNormal];
    self.statusLabel.text = @"初始化中...";
    self.emptyLabel.hidden = YES;

    // 清空之前的设备
    [self.discoveredDevices removeAllObjects];
    [self.peripheralDict removeAllObjects];
    [self.tableView reloadData];

    // 开始雷达动画
    [self startRadarAnimation];

    // 初始化 SDK
    TopStepComKit *sdk = [TopStepComKit sharedInstance];
    TSKitConfigOptions *config = [TSKitConfigOptions configOptionWithSDKType:self.currentSDKType
                                                                     license:@"abcdef1234567890abcdef1234567890"];
    config.isDevelopModel = YES;

    __weak typeof(self) weakSelf = self;
    [sdk initSDKWithConfigOptions:config completion:^(BOOL isSuccess, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        if (!isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.statusLabel.text = @"SDK 初始化失败";
                [strongSelf stopScan];
            });
            return;
        }

        // SDK 初始化成功，开始扫描
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.statusLabel.text = @"扫描中...";
        });

        [[sdk bleConnector] startSearchPeripheral:30
                               discoverPeripheral:^(TSPeripheral *peripheral) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || !strongSelf.isScanning) return;

            // MAC 地址去重
            NSString *mac = peripheral.systemInfo.mac;
            if (!mac.length) return;

            if (!strongSelf.peripheralDict[mac]) {
                strongSelf.peripheralDict[mac] = peripheral;
                [strongSelf.discoveredDevices addObject:peripheral];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.tableView reloadData];
                });
            }
        } completion:^(TSScanCompletionReason reason, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.isScanning) {
                    [strongSelf stopScan];
                }
            });
        }];
    }];
}

/**
 * 停止扫描
 */
- (void)stopScan {
    self.isScanning = NO;
    [self.scanButton setTitle:@"重新扫描" forState:UIControlStateNormal];

    if (self.discoveredDevices.count == 0) {
        self.statusLabel.text = @"未发现设备";
        self.emptyLabel.hidden = NO;
    } else {
        self.statusLabel.text = [NSString stringWithFormat:@"发现 %lu 个设备", (unsigned long)self.discoveredDevices.count];
    }

    // 停止雷达动画
    [self stopRadarAnimation];

    // 停止蓝牙扫描
    TopStepComKit *sdk = [TopStepComKit sharedInstance];
    [[sdk bleConnector] stopSearchPeripheral];
}

#pragma mark - 雷达动画

/**
 * 开始雷达动画
 */
- (void)startRadarAnimation {
    [self stopRadarAnimation];

    CGFloat containerSize = 200;
    CGFloat centerSize = 80;
    CGFloat centerX = containerSize / 2;
    CGFloat centerY = containerSize / 2;

    // 同心圆放在 radarContainerView 上（以容器中心为圆心）
    CGFloat radii[] = {50, 75, 100};
    for (int i = 0; i < 3; i++) {
        CAShapeLayer *circle = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY)
                                                            radius:radii[i]
                                                        startAngle:0
                                                          endAngle:M_PI * 2
                                                         clockwise:YES];
        circle.path = path.CGPath;
        circle.fillColor = [UIColor clearColor].CGColor;
        circle.strokeColor = [[TSColor_Primary colorWithAlphaComponent:0.25] CGColor];
        circle.lineWidth = 1.0;
        circle.frame = CGRectMake(0, 0, containerSize, containerSize);
        [self.radarContainerView.layer addSublayer:circle];
        [self.rippleLayers addObject:circle];
    }

    // 扫描扇形放在 radarContainerView 上（同心圆同层，以容器中心旋转）
    CGFloat scanRadius = 100;
    CGPoint scanCenter = CGPointMake(centerX, centerY);

    UIBezierPath *scanPath = [UIBezierPath bezierPath];
    [scanPath moveToPoint:scanCenter];
    [scanPath addArcWithCenter:scanCenter
                        radius:scanRadius
                    startAngle:-M_PI_2
                      endAngle:-M_PI_2 + M_PI / 3
                     clockwise:YES];
    [scanPath closePath];

    self.radarScanLayer = [CAShapeLayer layer];
    self.radarScanLayer.path = scanPath.CGPath;
    self.radarScanLayer.fillColor = [[TSColor_Primary colorWithAlphaComponent:0.45] CGColor];
    self.radarScanLayer.frame = CGRectMake(0, 0, containerSize, containerSize);
    [self.radarContainerView.layer addSublayer:self.radarScanLayer];

    // 扫描指针线（从中心到边缘）
    CAShapeLayer *scanLine = [CAShapeLayer layer];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:scanCenter];
    [linePath addLineToPoint:CGPointMake(centerX, centerY - scanRadius)];
    scanLine.path = linePath.CGPath;
    scanLine.strokeColor = [[TSColor_Primary colorWithAlphaComponent:0.9] CGColor];
    scanLine.lineWidth = 2.0;
    scanLine.frame = CGRectMake(0, 0, containerSize, containerSize);
    [self.radarContainerView.layer addSublayer:scanLine];
    [self.rippleLayers addObject:scanLine];

    // 旋转动画（扇形 + 指针一起旋转，锚点为容器中心）
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.fromValue = @0;
    rotation.toValue = @(M_PI * 2);
    rotation.duration = 2.5;
    rotation.repeatCount = HUGE_VALF;
    rotation.removedOnCompletion = NO;

    self.radarScanLayer.anchorPoint = CGPointMake(centerX / containerSize, centerY / containerSize);
    self.radarScanLayer.position = CGPointMake(centerX, centerY);
    [self.radarScanLayer addAnimation:rotation forKey:@"radarScan"];

    scanLine.anchorPoint = CGPointMake(centerX / containerSize, centerY / containerSize);
    scanLine.position = CGPointMake(centerX, centerY);
    [scanLine addAnimation:rotation forKey:@"radarScan"];

    // 蓝牙图标置顶
    if (self.bluetoothIconView) {
        [self.radarCenterView bringSubviewToFront:self.bluetoothIconView];
    }

    // 中心圆置顶（确保在同心圆之上��
    [self.radarContainerView bringSubviewToFront:self.radarCenterView];
}

/**
 * 停止雷达动画
 */
- (void)stopRadarAnimation {
    for (CALayer *layer in self.rippleLayers) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }
    [self.rippleLayers removeAllObjects];

    if (self.radarScanLayer) {
        [self.radarScanLayer removeAllAnimations];
        [self.radarScanLayer removeFromSuperlayer];
        self.radarScanLayer = nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.discoveredDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"TSDeviceCardCell";
    TSDeviceCardView *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[TSDeviceCardView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.row < self.discoveredDevices.count) {
        [cell updateWithPeripheral:self.discoveredDevices[indexPath.row]];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.discoveredDevices.count) return;

    // 点击动画
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1 animations:^{
        cell.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            cell.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            TSPeripheral *peripheral = self.discoveredDevices[indexPath.row];
            [self handleDeviceSelected:peripheral];
        }];
    }];
}

#pragma mark - 设备选择

/**
 * 处理设备选择，直接进入连接页
 */
- (void)handleDeviceSelected:(TSPeripheral *)peripheral {
    [self stopScan];

    TSDeviceConnectVC *connectVC = [[TSDeviceConnectVC alloc] init];
    connectVC.peripheral = peripheral;
    connectVC.deviceName = peripheral.systemInfo.bleName ?: @"未知设备";

    __weak typeof(self) weakSelf = self;
    connectVC.onConnectSuccess = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // 连接成功，发送通知切换到主界面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSDeviceBindSuccessNotification" object:nil];
    };

    connectVC.onConnectFailure = ^(NSError *error) {
        // 连接失败，返回扫描页
        NSLog(@"连接失败: %@", error.localizedDescription);
    };

    connectVC.onCancel = ^{
        // 用户取消，返回扫描页
        NSLog(@"用户取消连接");
    };

    [self.navigationController pushViewController:connectVC animated:YES];
}

- (void)dealloc {
    [self stopRadarAnimation];
}

@end
