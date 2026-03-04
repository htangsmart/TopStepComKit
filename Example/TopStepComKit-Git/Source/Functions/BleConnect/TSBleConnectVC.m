//
//  TSBleConnectVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/1/3.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBleConnectVC.h"

// ─── RSSI → 信号格数（1~4，4 最强）────────────────────────────────────────────
static NSInteger TSRSSIToLevel(NSInteger rssi) {
    if (rssi >= -60) return 4;
    if (rssi >= -70) return 3;
    if (rssi >= -80) return 2;
    return 1;
}

// ─── 设备 Cell ────────────────────────────────────────────────────────────────
@interface TSDeviceCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *macLabel;
@property (nonatomic, strong) UILabel *rssiLabel;
@property (nonatomic, copy)   NSArray<UIView *> *signalBars;
- (void)reloadWithPeripheral:(TSPeripheral *)peripheral;
@end

@implementation TSDeviceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) { [self ts_setup]; }
    return self;
}

- (void)ts_setup {
    self.backgroundColor = TSColor_Card;
    self.selectionStyle  = UITableViewCellSelectionStyleDefault;

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font      = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    self.nameLabel.textColor = TSColor_TextPrimary;
    [self.contentView addSubview:self.nameLabel];

    self.macLabel = [[UILabel alloc] init];
    self.macLabel.font      = [UIFont systemFontOfSize:12];
    self.macLabel.textColor = TSColor_TextSecondary;
    [self.contentView addSubview:self.macLabel];

    self.rssiLabel = [[UILabel alloc] init];
    self.rssiLabel.font           = [UIFont systemFontOfSize:11];
    self.rssiLabel.textColor      = TSColor_TextSecondary;
    self.rssiLabel.textAlignment  = NSTextAlignmentRight;
    [self.contentView addSubview:self.rssiLabel];

    // 4 个信号格，高度递增
    NSMutableArray *bars = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        UIView *bar = [[UIView alloc] init];
        bar.layer.cornerRadius = 2;
        bar.backgroundColor    = TSColor_Separator;
        [self.contentView addSubview:bar];
        [bars addObject:bar];
    }
    self.signalBars = [bars copy];
}

- (void)reloadWithPeripheral:(TSPeripheral *)peripheral {
    NSString *name = peripheral.systemInfo.bleName;
    self.nameLabel.text = (name.length > 0) ? name : @"未知设备";
    self.macLabel.text  = peripheral.systemInfo.mac ?: @"—";

    NSInteger rssi = [peripheral.systemInfo.RSSI integerValue];
    if (rssi == 127 || rssi == 0) rssi = -100;
    self.rssiLabel.text = [NSString stringWithFormat:@"%ld dBm", (long)rssi];

    NSInteger level    = TSRSSIToLevel(rssi);
    UIColor *barActive = (level >= 3) ? TSColor_Success :
                         (level == 2) ? TSColor_Warning : TSColor_Danger;
    for (NSInteger i = 0; i < 4; i++) {
        self.signalBars[i].backgroundColor = (i < level) ? barActive : TSColor_Separator;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.contentView.bounds);
    CGFloat h = CGRectGetHeight(self.contentView.bounds);

    // 信号格区域（右侧 44pt）
    CGFloat signalAreaW = 44.f;
    CGFloat signalAreaX = w - signalAreaW - 12.f;
    CGFloat barW        = 7.f;
    CGFloat barSpacing  = 3.f;
    CGFloat maxBarH     = 22.f;
    CGFloat barsStartX  = signalAreaX;

    for (NSInteger i = 0; i < 4; i++) {
        CGFloat barH = maxBarH * (0.3f + 0.7f * (i + 1) / 4.f);
        CGFloat barX = barsStartX + i * (barW + barSpacing);
        CGFloat barY = h / 2.f - barH / 2.f;
        self.signalBars[i].frame = CGRectMake(barX, barY, barW, barH);
    }

    // RSSI 数值（信号格下方）
    self.rssiLabel.frame = CGRectMake(signalAreaX - 4, h / 2.f + 12, signalAreaW + 16, 14);

    // 文字（左侧）
    CGFloat textW = signalAreaX - 16 - 8;
    self.nameLabel.frame = CGRectMake(16, h / 2.f - 20, textW, 20);
    self.macLabel.frame  = CGRectMake(16, h / 2.f + 2,  textW, 16);
}

@end

// ─── TSBleConnectVC ───────────────────────────────────────────────────────────
@interface TSBleConnectVC ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, TSPeripheral *> *peripheralDict;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *scanningLabel;
@property (nonatomic, strong) UIButton *unbindButton;
@end

@implementation TSBleConnectVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TSColor_Background;
    [self ts_buildHeader];

    if ([[[TopStepComKit sharedInstance] bleConnector] isConnected]) {
        [self ts_buildConnectedBanner];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self ts_startScanning];
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[[TopStepComKit sharedInstance] bleConnector] stopSearchPeripheral];
}

#pragma mark - Header

- (void)ts_buildHeader {
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat headerH = 52.f;
    UIView *header  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, headerH)];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.color  = TSColor_Primary;
    self.spinner.center = CGPointMake(28, headerH / 2.f);
    [header addSubview:self.spinner];
    [self.spinner startAnimating];

    self.scanningLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, 0, screenW - 52 - 16, headerH)];
    self.scanningLabel.text      = @"正在搜索附近设备...";
    self.scanningLabel.font      = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.scanningLabel.textColor = TSColor_TextSecondary;
    [header addSubview:self.scanningLabel];

    self.sourceTableview.tableHeaderView = header;
}

- (void)ts_buildConnectedBanner {
    // 在扫描提示下方追加一张"已连接设备"卡片
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat margin  = 16.f;
    CGFloat cardH   = 68.f;
    CGFloat scanH   = 52.f;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, scanH + margin + cardH + margin)];

    // Scanning row
    UIView *scanRow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, scanH)];
    self.spinner.center = CGPointMake(28, scanH / 2.f);
    [scanRow addSubview:self.spinner];
    self.scanningLabel.frame = CGRectMake(52, 0, screenW - 52 - 16, scanH);
    [scanRow addSubview:self.scanningLabel];
    [container addSubview:scanRow];

    // Card
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(margin, scanH + margin, screenW - margin * 2, cardH)];
    card.backgroundColor     = TSColor_Card;
    card.layer.cornerRadius  = TSRadius_MD;
    card.layer.shadowColor   = [UIColor blackColor].CGColor;
    card.layer.shadowOffset  = CGSizeMake(0, 2);
    card.layer.shadowRadius  = 8;
    card.layer.shadowOpacity = 0.08f;
    [container addSubview:card];

    UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(16, (cardH - 10) / 2.f, 10, 10)];
    dot.layer.cornerRadius = 5;
    dot.backgroundColor    = TSColor_Success;
    [card addSubview:dot];

    TSPeripheral *peri = [[TopStepComKit sharedInstance] connectedPeripheral];
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(36, cardH / 2.f - 20, screenW - margin * 2 - 110, 20)];
    nameLbl.text      = peri.systemInfo.bleName ?: @"已连接设备";
    nameLbl.font      = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    nameLbl.textColor = TSColor_TextPrimary;
    [card addSubview:nameLbl];

    UILabel *macLbl = [[UILabel alloc] initWithFrame:CGRectMake(36, cardH / 2.f + 2, screenW - margin * 2 - 110, 16)];
    macLbl.text      = peri.systemInfo.mac ?: @"";
    macLbl.font      = [UIFont systemFontOfSize:12];
    macLbl.textColor = TSColor_TextSecondary;
    [card addSubview:macLbl];

    self.unbindButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.unbindButton.frame = CGRectMake(card.bounds.size.width - 86, (cardH - 32) / 2.f, 78, 32);
    [self.unbindButton setTitle:@"解除绑定" forState:UIControlStateNormal];
    self.unbindButton.titleLabel.font     = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [self.unbindButton setTitleColor:TSColor_Danger forState:UIControlStateNormal];
    self.unbindButton.layer.cornerRadius  = TSRadius_SM;
    self.unbindButton.layer.borderWidth   = 1;
    self.unbindButton.layer.borderColor   = TSColor_Danger.CGColor;
    [self.unbindButton addTarget:self action:@selector(ts_unbindDevice) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:self.unbindButton];

    self.sourceTableview.tableHeaderView = container;
}

#pragma mark - Scanning

- (void)ts_startScanning {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] bleConnector] startSearchPeripheral:30
        discoverPeripheral:^(TSPeripheral *peripheral) {
            if (!peripheral.systemInfo.mac.length) return;
            [weakSelf.peripheralDict setObject:peripheral forKey:peripheral.systemInfo.mac];
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) self = weakSelf;
                NSArray *sorted = [[self.peripheralDict allValues] sortedArrayUsingComparator:^NSComparisonResult(TSPeripheral *a, TSPeripheral *b) {
                    NSInteger rA = a.systemInfo.RSSI ? a.systemInfo.RSSI.integerValue : -127;
                    NSInteger rB = b.systemInfo.RSSI ? b.systemInfo.RSSI.integerValue : -127;
                    if (rA == 127 || rA > 0) rA = -127;
                    if (rB == 127 || rB > 0) rB = -127;
                    return (rA > rB) ? NSOrderedAscending : (rA < rB ? NSOrderedDescending : NSOrderedSame);
                }];
                self.sourceArray = sorted;
                [self.sourceTableview reloadData];
            });
        }
        completion:^(TSScanCompletionReason reason, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) self = weakSelf;
                [self.spinner stopAnimating];
                NSUInteger count = self.sourceArray.count;
                self.scanningLabel.text = count > 0
                    ? [NSString stringWithFormat:@"发现 %lu 台设备，点击连接", (unsigned long)count]
                    : @"未发现设备，请确认设备已开机";
            });
            TSLogError(@"[TSBleConnectVC] Scan done, reason:%d error:%@", reason, error);
        }
    ];
}

#pragma mark - Unbind

- (void)ts_unbindDevice {
    UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"解除绑定"
                                                                     message:@"确定要解绑当前设备吗？解绑后需重新配对。"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [confirm addAction:[UIAlertAction actionWithTitle:@"解绑" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        self.unbindButton.enabled = NO;
        [[[TopStepComKit sharedInstance] bleConnector] unbindPeripheralCompletion:^(BOOL isSuccess, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.unbindButton.enabled = YES;
                if (isSuccess) {
                    if ([self.delegate respondsToSelector:@selector(unbindSuccess)]) {
                        [self.delegate unbindSuccess];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [self showAlertWithMsg:@"解绑失败，请重试"];
                }
            });
        }];
    }]];
    [confirm addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:confirm animated:YES completion:nil];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"kTSDeviceCell";
    TSDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[TSDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if (indexPath.row < (NSInteger)self.sourceArray.count) {
        [cell reloadWithPeripheral:self.sourceArray[indexPath.row]];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sourceArray.count > 0 ? @"附近设备" : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= (NSInteger)self.sourceArray.count) return;

    TSPeripheral *peri  = self.sourceArray[indexPath.row];
    TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc] initWithUserId:@"fajlief"];

    // 连接中 UI 反馈
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *ind = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    [ind startAnimating];
    cell.accessoryView = ind;
    tableView.userInteractionEnabled = NO;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] bleConnector] connectWithPeripheral:peri
                                                                   param:param
                                                              completion:^(TSBleConnectionState state, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.accessoryView = nil;
            tableView.userInteractionEnabled = YES;
            if (state == eTSBleStateConnected) {
                if ([weakSelf.delegate respondsToSelector:@selector(connectSuccess:param:)]) {
                    [weakSelf.delegate connectSuccess:peri param:param];
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else if (state == eTSBleStateDisconnected && error) {
                [weakSelf showAlertWithMsg:[NSString stringWithFormat:@"连接失败：%@", error.localizedDescription]];
            }
        });
    }];
}

#pragma mark - Lazy

- (NSMutableDictionary *)peripheralDict {
    if (!_peripheralDict) {
        _peripheralDict = [NSMutableDictionary dictionary];
    }
    return _peripheralDict;
}

@end
