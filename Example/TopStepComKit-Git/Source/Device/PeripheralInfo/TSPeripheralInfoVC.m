//
//  TSPeripheralInfoVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/6/22.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSPeripheralInfoVC.h"

// ─── Helpers ───────────────────────────────────────────────────────────────

static NSString *TSShapeString(TSPeriphShape shape) {
    switch (shape) {
        case eTSPeriphShapeCircle:              return @"圆形";
        case eTSPeriphShapeSquare:              return @"方形";
        case eTSPeriphShapeVerticalRectangle:   return @"竖向矩形";
        case eTSPeriphShapeTransverseRectangle: return @"横向矩形";
        default:                                return @"未知";
    }
}

// count==0 → nil（显示 —），255 → "无限制"，其余 → "%d 个"
static NSString *TSLimitCountStr(UInt8 count) {
    if (count == 0)   return nil;
    if (count == 255) return @"无限制";
    return [NSString stringWithFormat:@"%d 个", count];
}

// ─── TSInfoItem ────────────────────────────────────────────────────────────
@interface TSInfoItem : NSObject
@property (nonatomic, copy)            NSString *key;
@property (nonatomic, copy)            NSString *value;
@property (nonatomic, strong, nullable) UIColor *valueColor; // nil = default TextPrimary
+ (instancetype)itemWithKey:(NSString *)key value:(nullable NSString *)raw;
+ (instancetype)itemWithKey:(NSString *)key bool:(BOOL)supported;
@end

@implementation TSInfoItem
+ (instancetype)itemWithKey:(NSString *)key value:(NSString *)raw {
    TSInfoItem *item = [[self alloc] init];
    item.key   = key;
    item.value = (raw.length > 0) ? raw : @"—";
    return item;
}
+ (instancetype)itemWithKey:(NSString *)key bool:(BOOL)supported {
    TSInfoItem *item = [[self alloc] init];
    item.key        = key;
    item.value      = supported ? @"支持" : @"不支持";
    item.valueColor = supported ? TSColor_Success : TSColor_TextSecondary;
    return item;
}
@end

// ─── TSInfoCell ────────────────────────────────────────────────────────────
@interface TSInfoCell : UITableViewCell
- (void)reloadWithItem:(TSInfoItem *)item;
@end

@implementation TSInfoCell {
    UILabel  *_keyLabel;
    UILabel  *_valueLabel;
    NSString *_copyText;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.backgroundColor = TSColor_Card;
    self.selectionStyle  = UITableViewCellSelectionStyleNone;

    _keyLabel = [[UILabel alloc] init];
    _keyLabel.font      = [UIFont systemFontOfSize:14];
    _keyLabel.textColor = TSColor_TextSecondary;
    [self.contentView addSubview:_keyLabel];

    _valueLabel = [[UILabel alloc] init];
    _valueLabel.font                      = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _valueLabel.textColor                 = TSColor_TextPrimary;
    _valueLabel.textAlignment             = NSTextAlignmentRight;
    _valueLabel.adjustsFontSizeToFitWidth = YES;
    _valueLabel.minimumScaleFactor        = 0.75;
    [self.contentView addSubview:_valueLabel];

    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc]
        initWithTarget:self action:@selector(ts_onLongPress:)];
    lp.minimumPressDuration = 0.5;
    [self.contentView addGestureRecognizer:lp];

    return self;
}

- (void)reloadWithItem:(TSInfoItem *)item {
    _keyLabel.text      = item.key;
    _valueLabel.text    = item.value;
    _valueLabel.textColor = item.valueColor ?: TSColor_TextPrimary;
    _copyText           = item.value;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w   = self.contentView.bounds.size.width;
    CGFloat h   = self.contentView.bounds.size.height;
    CGFloat pad = 16.f;
    CGFloat keyW = 90.f;
    _keyLabel.frame   = CGRectMake(pad, (h - 20) / 2.f, keyW, 20);
    _valueLabel.frame = CGRectMake(pad + keyW + 8, (h - 20) / 2.f,
                                   w - pad * 2 - keyW - 8, 20);
}

- (void)ts_onLongPress:(UILongPressGestureRecognizer *)gr {
    if (gr.state != UIGestureRecognizerStateBegan) return;
    if (!_copyText.length || [_copyText isEqualToString:@"—"]) return;

    [UIPasteboard generalPasteboard].string = _copyText;

    [UIView animateWithDuration:0.15 animations:^{
        self.contentView.backgroundColor = [TSColor_Primary colorWithAlphaComponent:0.10];
    } completion:^(BOOL _) {
        [UIView animateWithDuration:0.35 animations:^{
            self.contentView.backgroundColor = TSColor_Card;
        }];
    }];
    [self ts_showToast:@"已复制"];
}

- (void)ts_showToast:(NSString *)text {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (!window) return;
    UILabel *toast = [[UILabel alloc] init];
    toast.text            = text;
    toast.font            = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    toast.textColor       = UIColor.whiteColor;
    toast.textAlignment   = NSTextAlignmentCenter;
    toast.backgroundColor = [UIColor colorWithWhite:0 alpha:0.72];
    toast.layer.cornerRadius = 8;
    toast.clipsToBounds   = YES;
    CGFloat tw = [toast sizeThatFits:CGSizeMake(200, 40)].width + 24;
    toast.frame = CGRectMake((window.bounds.size.width - tw) / 2.f,
                              window.bounds.size.height * 0.75f, tw, 34);
    toast.alpha = 0;
    [window addSubview:toast];
    [UIView animateWithDuration:0.2 animations:^{ toast.alpha = 1; } completion:^(BOOL _) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{ toast.alpha = 0; }
                            completion:^(BOOL __) { [toast removeFromSuperview]; }];
        });
    }];
}
@end

// ─── TSPeripheralInfoVC ────────────────────────────────────────────────────
typedef NS_ENUM(NSInteger, TSInfoState) {
    TSInfoStateInitial = 0,
    TSInfoStateLoading,
    TSInfoStateLoaded,
};

@interface TSPeripheralInfoVC ()
@property (nonatomic, assign) TSInfoState infoState;
@property (nonatomic, strong) NSArray<NSArray<TSInfoItem *> *> *sectionData;
@property (nonatomic, strong) NSArray<NSString *>              *sectionTitles;

@property (nonatomic, strong) UIView                  *loadingOverlay;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

@property (nonatomic, strong) UIBarButtonItem *refreshItem;
@end

@implementation TSPeripheralInfoVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设备信息";
    [self ts_replaceTableWithGrouped];
    [self ts_buildLoadingOverlay];
    [self ts_applyState:TSInfoStateLoading animated:NO];
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [wself ts_startAutoFetch];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.loadingOverlay.frame = self.view.bounds;
    UIView *loaderCard = [self.loadingOverlay viewWithTag:100];
    loaderCard.center = CGPointMake(self.loadingOverlay.bounds.size.width / 2.f,
                                    self.loadingOverlay.bounds.size.height / 2.f);
}

#pragma mark - Setup

- (void)ts_replaceTableWithGrouped {
    [self.sourceTableview removeFromSuperview];
    UITableView *grouped;
    if (@available(iOS 13.0, *)) {
        grouped = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    } else {
        grouped = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    }
    grouped.delegate        = self;
    grouped.dataSource      = self;
    grouped.backgroundColor = TSColor_Background;
    grouped.separatorColor  = TSColor_Separator;
    grouped.separatorInset  = UIEdgeInsetsMake(0, 16, 0, 0);
    if (@available(iOS 15.0, *)) {
        grouped.sectionHeaderTopPadding = 0;
    }
    self.sourceTableview = grouped;
    [self.view addSubview:self.sourceTableview];
    [self layoutViews];
}

/** 进入页面后自动拉取设备信息，拉取完成后直接展示列表 */
- (void)ts_startAutoFetch {
    if (![[TopStepComKit sharedInstance] connectedPeripheral]) {
        [self showAlertWithMsg:@"设备未连接，请先连接设备后再试"];
        self.sectionData   = @[];
        self.sectionTitles = @[];
        [self ts_applyState:TSInfoStateLoaded animated:NO];
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self ts_populateData];
        [self ts_applyState:TSInfoStateLoaded animated:YES];
    });
}

- (void)ts_buildLoadingOverlay {
    self.loadingOverlay = [[UIView alloc] init];
    self.loadingOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];

    UIView *loaderCard = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 120)];
    loaderCard.tag                = 100;
    loaderCard.backgroundColor    = [UIColor colorWithWhite:1 alpha:0.94];
    loaderCard.layer.cornerRadius = TSRadius_LG;

    self.loadingSpinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingSpinner.color  = TSColor_Primary;
    self.loadingSpinner.center = CGPointMake(70, 46);
    [loaderCard addSubview:self.loadingSpinner];

    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 76, 140, 28)];
    loadingLabel.text          = @"正在读取...";
    loadingLabel.font          = [UIFont systemFontOfSize:13];
    loadingLabel.textColor     = TSColor_TextSecondary;
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    [loaderCard addSubview:loadingLabel];

    [self.loadingOverlay addSubview:loaderCard];
    [self.view addSubview:self.loadingOverlay];
}

#pragma mark - State Machine

- (void)ts_applyState:(TSInfoState)state animated:(BOOL)animated {
    self.infoState = state;
    switch (state) {
        case TSInfoStateInitial:
            break;
        case TSInfoStateLoading: {
            self.sourceTableview.hidden = YES;
            self.loadingOverlay.frame   = self.view.bounds;
            UIView *loaderCard = [self.loadingOverlay viewWithTag:100];
            loaderCard.center  = CGPointMake(self.loadingOverlay.bounds.size.width / 2.f,
                                              self.loadingOverlay.bounds.size.height / 2.f);
            [self.view bringSubviewToFront:self.loadingOverlay];
            self.loadingOverlay.hidden = NO;
            self.loadingOverlay.alpha  = 0;
            [self.loadingSpinner startAnimating];
            [UIView animateWithDuration:0.2 animations:^{ self.loadingOverlay.alpha = 1; }];
            break;
        }
        case TSInfoStateLoaded: {
            [self.loadingSpinner stopAnimating];
            self.sourceTableview.hidden = NO;
            [self.sourceTableview reloadData];
            if (animated) {
                self.sourceTableview.alpha = 0;
                [UIView animateWithDuration:0.35 animations:^{
                    self.sourceTableview.alpha = 1;
                    self.loadingOverlay.alpha  = 0;
                } completion:^(BOOL _) { self.loadingOverlay.hidden = YES; }];
            } else {
                self.loadingOverlay.hidden = YES;
            }
            if (!self.refreshItem) {
                UIImage *icon = nil;
                if (@available(iOS 13.0, *)) {
                    icon = [UIImage systemImageNamed:@"arrow.clockwise"];
                }
                self.refreshItem = [[UIBarButtonItem alloc]
                    initWithImage:icon style:UIBarButtonItemStylePlain
                           target:self action:@selector(ts_fetchInfo)];
            }
            self.navigationItem.rightBarButtonItem = self.refreshItem;
            break;
        }
    }
}

#pragma mark - Fetch

/** 导航栏刷新按钮：重新拉取并展示 */
- (void)ts_fetchInfo {
    if (![[TopStepComKit sharedInstance] connectedPeripheral]) {
        [self showAlertWithMsg:@"设备未连接，请先连接设备后再试"];
        return;
    }
    [self ts_applyState:TSInfoStateLoading animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self ts_populateData];
        [self ts_applyState:TSInfoStateLoaded animated:YES];
    });
}

#pragma mark - Populate Data

- (void)ts_populateData {
    TSPeripheral            *peri = [[TopStepComKit sharedInstance] connectedPeripheral];
    TSPeripheralSystem      *sys  = peri.systemInfo;
    TSPeripheralProject     *proj = peri.projectInfo;
    TSPeripheralScreen      *scr  = peri.screenInfo;
    TSPeripheralCapability  *cap  = peri.capability;
    TSPeripheralLimitations *lim  = peri.limitation;
    TSFeatureAbility        *feat = cap.featureAbility;

    TSLog(@"current peripheral is %@",peri.debugDescription);
    // ── Section 1: 蓝牙连接 ─────────────────────────────────────────────────
    NSInteger rssiVal = sys.RSSI ? sys.RSSI.integerValue : -100;
    if (rssiVal == 127 || rssiVal == 0) rssiVal = -100;
    NSString *rssiStr = [NSString stringWithFormat:@"%ld dBm", (long)rssiVal];
    NSInteger mtu = [sys peripheralMTU];
    NSString *mtuStr = mtu > 0 ? [NSString stringWithFormat:@"%ld bytes", (long)mtu] : nil;

    NSArray *bleSection = @[
        [TSInfoItem itemWithKey:@"设备名称"  value:sys.bleName],
        [TSInfoItem itemWithKey:@"MAC 地址"  value:sys.mac],
        [TSInfoItem itemWithKey:@"信号强度"  value:rssiStr],
        [TSInfoItem itemWithKey:@"UUID"       value:sys.uuid],
        [TSInfoItem itemWithKey:@"MTU 大小"  value:mtuStr],
    ];

    // ── Section 2: 版本信息 ─────────────────────────────────────────────────
    NSArray *verSection = @[
        [TSInfoItem itemWithKey:@"固件版本"  value:proj.firmVersion],
        [TSInfoItem itemWithKey:@"虚拟版本"  value:proj.virtualVersion],
        [TSInfoItem itemWithKey:@"序列号"    value:proj.serialNumber],
        [TSInfoItem itemWithKey:@"品牌"      value:proj.brand],
        [TSInfoItem itemWithKey:@"型号"      value:proj.model],
        [TSInfoItem itemWithKey:@"项目 ID"   value:proj.projectId],
        [TSInfoItem itemWithKey:@"公司 ID"   value:proj.companyId],
    ];

    // ── Section 3: 屏幕规格 ─────────────────────────────────────────────────
    NSString *screenSizeStr   = (scr.screenSize.width > 0)
        ? [NSString stringWithFormat:@"%.0f × %.0f px", scr.screenSize.width, scr.screenSize.height]
        : nil;
    NSString *screenRadiusStr = (scr.screenBorderRadius > 0)
        ? [NSString stringWithFormat:@"%.0f px", scr.screenBorderRadius] : nil;
    NSString *dialSizeStr     = (scr.dialPreviewSize.width > 0)
        ? [NSString stringWithFormat:@"%.0f × %.0f px", scr.dialPreviewSize.width, scr.dialPreviewSize.height]
        : nil;
    NSString *dialRadiusStr   = (scr.dialPreviewBorderRadius > 0)
        ? [NSString stringWithFormat:@"%.0f px", scr.dialPreviewBorderRadius] : nil;
    NSString *videoSizeStr    = (scr.videoPreviewSize.width > 0)
        ? [NSString stringWithFormat:@"%.0f × %.0f px", scr.videoPreviewSize.width, scr.videoPreviewSize.height]
        : nil;
    NSString *videoRadiusStr  = (scr.videoPreviewBorderRadius > 0)
        ? [NSString stringWithFormat:@"%.0f px", scr.videoPreviewBorderRadius] : nil;

    NSArray *scrSection = @[
        [TSInfoItem itemWithKey:@"屏幕形状"   value:TSShapeString(scr.shape)],
        [TSInfoItem itemWithKey:@"屏幕尺寸"   value:screenSizeStr],
        [TSInfoItem itemWithKey:@"屏幕圆角"   value:screenRadiusStr],
        [TSInfoItem itemWithKey:@"表盘预览"   value:dialSizeStr],
        [TSInfoItem itemWithKey:@"表盘圆角"   value:dialRadiusStr],
        [TSInfoItem itemWithKey:@"视频预览"   value:videoSizeStr],
        [TSInfoItem itemWithKey:@"视频圆角"   value:videoRadiusStr],
    ];

    // ── Section 4: 功能限制 ─────────────────────────────────────────────────
    NSArray *limSection = lim ? @[
        [TSInfoItem itemWithKey:@"最大闹钟数"     value:TSLimitCountStr(lim.maxAlarmCount)],
        [TSInfoItem itemWithKey:@"联系人上限"     value:TSLimitCountStr(lim.maxContactCount)],
        [TSInfoItem itemWithKey:@"紧急联系人"     value:TSLimitCountStr(lim.maxEmergencyContactCount)],
        [TSInfoItem itemWithKey:@"可推表盘数"     value:TSLimitCountStr(lim.maxPushDialCount)],
        [TSInfoItem itemWithKey:@"预装表盘数"     value:TSLimitCountStr(lim.maxInnerDialCount)],
        [TSInfoItem itemWithKey:@"世界时钟数"     value:TSLimitCountStr(lim.maxWorldClockCount)],
        [TSInfoItem itemWithKey:@"久坐提醒数"     value:TSLimitCountStr(lim.maxSedentaryReminderCount)],
        [TSInfoItem itemWithKey:@"喝水提醒数"     value:TSLimitCountStr(lim.maxWaterDrinkingReminderCount)],
        [TSInfoItem itemWithKey:@"吃药提醒数"     value:TSLimitCountStr(lim.maxMedicationReminderCount)],
        [TSInfoItem itemWithKey:@"自定义提醒数"   value:TSLimitCountStr(lim.maxCustomReminderCount)],
    ] : @[ [TSInfoItem itemWithKey:@"功能限制" value:nil] ];

    // ── Section 5: 健康能力 ─────────────────────────────────────────────────
    NSArray *healthSection = feat ? @[
        [TSInfoItem itemWithKey:@"步数计数"   bool:feat.isSupportStepCounting],
        [TSInfoItem itemWithKey:@"距离计数"   bool:feat.isSupportDistanceCounting],
        [TSInfoItem itemWithKey:@"卡路里"     bool:feat.isSupportCalorieCounting],
        [TSInfoItem itemWithKey:@"心率监测"   bool:feat.isSupportHeartRate],
        [TSInfoItem itemWithKey:@"血压监测"   bool:feat.isSupportBloodPressure],
        [TSInfoItem itemWithKey:@"血氧监测"   bool:feat.isSupportBloodOxygen],
        [TSInfoItem itemWithKey:@"压力监测"   bool:feat.isSupportStress],
        [TSInfoItem itemWithKey:@"睡眠监测"   bool:feat.isSupportSleep],
        [TSInfoItem itemWithKey:@"体温监测"   bool:feat.isSupportTemperature],
        [TSInfoItem itemWithKey:@"心电图"     bool:feat.isSupportECG],
        [TSInfoItem itemWithKey:@"女性健康"   bool:feat.isSupportFemaleHealth],
        [TSInfoItem itemWithKey:@"运动功能"   bool:feat.isSupportInitiateWorkout],
        [TSInfoItem itemWithKey:@"每日活动"   bool:feat.isSupportDailyActivity],
        [TSInfoItem itemWithKey:@"体重管理"   bool:feat.isSupportWeightManagement],
    ] : @[ [TSInfoItem itemWithKey:@"健康能力" value:nil] ];

    // ── Section 6: 设备功能 ─────────────────────────────────────────────────
    NSArray *deviceSection = feat ? @[
        [TSInfoItem itemWithKey:@"活动提醒"   bool:feat.isSupportReminders],
        [TSInfoItem itemWithKey:@"来电管理"   bool:feat.isSupportCallManagement],
        [TSInfoItem itemWithKey:@"应用通知"   bool:feat.isSupportAppNotifications],
        [TSInfoItem itemWithKey:@"音乐控制"   bool:feat.isSupportMusicControl],
        [TSInfoItem itemWithKey:@"天气显示"   bool:feat.isSupportWeatherDisplay],
        [TSInfoItem itemWithKey:@"查找手机"   bool:feat.isSupportFindMyPhone],
        [TSInfoItem itemWithKey:@"闹钟"       bool:feat.isSupportAlarmClock],
        [TSInfoItem itemWithKey:@"世界时钟"   bool:feat.isSupportWorldClock],
        [TSInfoItem itemWithKey:@"地图导航"   bool:feat.isSupportMapNavigation],
        [TSInfoItem itemWithKey:@"摇一摇拍照" bool:feat.isSupportShakeCamera],
        [TSInfoItem itemWithKey:@"相机预览"   bool:feat.isSupportCameraPreview],
        [TSInfoItem itemWithKey:@"电子钱包"   bool:feat.isSupportEWallet],
        [TSInfoItem itemWithKey:@"电子名片"   bool:feat.isSupportBusinessCard],
        [TSInfoItem itemWithKey:@"相册功能"   bool:feat.isSupportPhotoAlbum],
        [TSInfoItem itemWithKey:@"电子书"     bool:feat.isSupportEBook],
        [TSInfoItem itemWithKey:@"录音"       bool:feat.isSupportVoiceRecording],
        [TSInfoItem itemWithKey:@"应用商店"   bool:feat.isSupportAppStore],
        [TSInfoItem itemWithKey:@"体感游戏"   bool:feat.isSupportMotionGames],
        [TSInfoItem itemWithKey:@"联系人"     bool:feat.isSupportContacts],
        [TSInfoItem itemWithKey:@"紧急联系人" bool:feat.isSupportEmergencyContacts],
        [TSInfoItem itemWithKey:@"NFC 支付"   bool:feat.isSupportNFCPayment],
        [TSInfoItem itemWithKey:@"语音助手"   bool:feat.isSupportVoiceAssistant],
        [TSInfoItem itemWithKey:@"表盘推送"   bool:feat.isSupportFacePush],
        [TSInfoItem itemWithKey:@"自定义表盘" bool:feat.isSupportCustomFace],
        [TSInfoItem itemWithKey:@"幻灯片表盘" bool:feat.isSupportSlideshowFace],
        [TSInfoItem itemWithKey:@"时间设置"   bool:feat.isSupportTimeSettings],
        [TSInfoItem itemWithKey:@"语言设置"   bool:feat.isSupportLanguage],
        [TSInfoItem itemWithKey:@"用户信息"   bool:feat.isSupportUserInfoSettings],
        [TSInfoItem itemWithKey:@"固件升级"   bool:feat.isSupportFirmwareUpgrade],
        [TSInfoItem itemWithKey:@"单位设置"   bool:feat.isSupportUnitSettings],
        [TSInfoItem itemWithKey:@"耳机仓"     bool:feat.isSupportEarbudsAPIs],
    ] : @[ [TSInfoItem itemWithKey:@"设备功能" value:nil] ];

    self.sectionData   = @[bleSection, verSection, scrSection, limSection, healthSection, deviceSection];
    self.sectionTitles = @[@"蓝牙连接", @"版本信息", @"屏幕规格", @"功能限制", @"健康能力", @"设备功能"];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.infoState == TSInfoStateLoaded) ? (NSInteger)self.sectionData.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.sectionData[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"kTSInfoCell";
    TSInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[TSInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell reloadWithItem:self.sectionData[indexPath.section][indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

#pragma mark - layoutViews override

- (void)layoutViews {
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;
    self.sourceTableview.frame = CGRectMake(0, topOffset,
                                            self.view.frame.size.width,
                                            CGRectGetHeight(self.view.frame) - topOffset);
}

@end
