//
//  TSPeripheralInfoVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/6/22.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSPeripheralInfoVC.h"
#import "TSRootVC.h"

// ─── Helpers ───────────────────────────────────────────────────────────────

static NSString *TSShapeString(TSPeriphShape shape) {
    switch (shape) {
        case eTSPeriphShapeCircle:              return TSLocalizedString(@"peripheral_info.shape_circle");
        case eTSPeriphShapeSquare:              return TSLocalizedString(@"peripheral_info.shape_square");
        case eTSPeriphShapeVerticalRectangle:   return TSLocalizedString(@"peripheral_info.shape_vertical_rect");
        case eTSPeriphShapeTransverseRectangle: return TSLocalizedString(@"peripheral_info.shape_transverse_rect");
        default:                                return TSLocalizedString(@"peripheral_info.shape_unknown");
    }
}

// count==0 → nil（显示 —），255 → "无限制"，其余 → "%d 个"
static NSString *TSLimitCountStr(UInt8 count) {
    if (count == 0)   return nil;
    if (count == 255) return TSLocalizedString(@"peripheral_info.unlimited");
    return [NSString stringWithFormat:TSLocalizedString(@"peripheral_info.count_format"), count];
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
    item.value = (raw.length > 0) ? raw : TSLocalizedString(@"peripheral_info.placeholder");
    return item;
}
+ (instancetype)itemWithKey:(NSString *)key bool:(BOOL)supported {
    TSInfoItem *item = [[self alloc] init];
    item.key        = key;
    item.value      = supported ? TSLocalizedString(@"general.supported") : TSLocalizedString(@"general.not_supported");
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
    CGFloat keyW = 180.f;
    _keyLabel.frame   = CGRectMake(pad, (h - 20) / 2.f, keyW, 20);
    _valueLabel.frame = CGRectMake(pad + keyW + 8, (h - 20) / 2.f,
                                   w - pad * 2 - keyW - 8, 20);
}

- (void)ts_onLongPress:(UILongPressGestureRecognizer *)gr {
    if (gr.state != UIGestureRecognizerStateBegan) return;
    if (!_copyText.length || [_copyText isEqualToString:TSLocalizedString(@"peripheral_info.placeholder")]) return;

    [UIPasteboard generalPasteboard].string = _copyText;

    [UIView animateWithDuration:0.15 animations:^{
        self.contentView.backgroundColor = [TSColor_Primary colorWithAlphaComponent:0.10];
    } completion:^(BOOL _) {
        [UIView animateWithDuration:0.35 animations:^{
            self.contentView.backgroundColor = TSColor_Card;
        }];
    }];
    [self ts_showToast:TSLocalizedString(@"general.copied")];
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
    self.title = TSLocalizedString(@"peripheral_info.title");
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
        [self showAlertWithMsg:TSLocalizedString(@"device.not_connected_hint")];
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
    loadingLabel.text          = TSLocalizedString(@"device.reading");
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
        [self showAlertWithMsg:TSLocalizedString(@"device.not_connected_hint")];
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
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.device_name")  value:sys.bleName],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.mac")  value:sys.mac],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.rssi")  value:rssiStr],
        [TSInfoItem itemWithKey:@"UUID"       value:sys.uuid],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.mtu")  value:mtuStr],
    ];

    // ── Section 2: 版本信息 ─────────────────────────────────────────────────
    NSArray *verSection = @[
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.firm_version")  value:proj.firmVersion],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.virtual_version")  value:proj.virtualVersion],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.serial_number")    value:proj.serialNumber],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.brand")      value:proj.brand],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.model")      value:proj.model],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.project_id")   value:proj.projectId],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.company_id")   value:proj.companyId],
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
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.screen_shape")   value:TSShapeString(scr.shape)],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.screen_size")   value:screenSizeStr],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.screen_radius")   value:screenRadiusStr],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.dial_preview")   value:dialSizeStr],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.dial_radius")   value:dialRadiusStr],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.video_preview")   value:videoSizeStr],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.video_radius")   value:videoRadiusStr],
    ];

    // ── Section 4: 功能限制 ─────────────────────────────────────────────────
    NSArray *limSection = lim ? @[
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.max_alarm")     value:TSLimitCountStr(lim.maxAlarmCount)],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.max_contact")     value:TSLimitCountStr(lim.maxContactCount)],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.max_emergency_contact")     value:TSLimitCountStr(lim.maxEmergencyContactCount)],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.max_push_dial")     value:TSLimitCountStr(lim.maxPushDialCount)],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.max_inner_dial")     value:TSLimitCountStr(lim.maxInnerDialCount)],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.max_world_clock")     value:TSLimitCountStr(lim.maxWorldClockCount)],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.max_sedentary")     value:TSLimitCountStr(lim.maxSedentaryReminderCount)],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.max_water")     value:TSLimitCountStr(lim.maxWaterDrinkingReminderCount)],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.max_medication")     value:TSLimitCountStr(lim.maxMedicationReminderCount)],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.max_custom_reminder")   value:TSLimitCountStr(lim.maxCustomReminderCount)],
    ] : @[ [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.limitation_title") value:nil] ];

    // ── Section 5: 健康能力 ─────────────────────────────────────────────────
    NSArray *healthSection = feat ? @[
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.step_counting")   bool:feat.isSupportStepCounting],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.distance_counting")   bool:feat.isSupportDistanceCounting],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.calorie")     bool:feat.isSupportCalorieCounting],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.heart_rate")   bool:feat.isSupportHeartRate],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.blood_pressure")   bool:feat.isSupportBloodPressure],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.blood_oxygen")   bool:feat.isSupportBloodOxygen],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.stress")   bool:feat.isSupportStress],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.sleep")   bool:feat.isSupportSleep],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.temperature")   bool:feat.isSupportTemperature],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.ecg")     bool:feat.isSupportECG],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.female_health")   bool:feat.isSupportFemaleHealth],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.workout")   bool:feat.isSupportInitiateWorkout],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.daily_activity")   bool:feat.isSupportDailyActivity],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.weight_management")   bool:feat.isSupportWeightManagement],
    ] : @[ [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.health_title") value:nil] ];

    // ── Section 6: 设备功能 ─────────────────────────────────────────────────
    NSArray *deviceSection = feat ? @[
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.reminders")   bool:feat.isSupportReminders],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.call_management")   bool:feat.isSupportCallManagement],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.app_notifications")   bool:feat.isSupportAppNotifications],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.music_control")   bool:feat.isSupportMusicControl],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.weather")   bool:feat.isSupportWeatherDisplay],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.find_phone")   bool:feat.isSupportFindMyPhone],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.alarm_clock")       bool:feat.isSupportAlarmClock],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.world_clock")   bool:feat.isSupportWorldClock],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.map_navigation")   bool:feat.isSupportMapNavigation],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.shake_camera") bool:feat.isSupportShakeCamera],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.camera_preview")   bool:feat.isSupportCameraPreview],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.e_wallet")   bool:feat.isSupportEWallet],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.business_card")   bool:feat.isSupportBusinessCard],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.photo_album")   bool:feat.isSupportPhotoAlbum],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.e_book")     bool:feat.isSupportEBook],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.voice_recording")       bool:feat.isSupportVoiceRecording],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.app_store")   bool:feat.isSupportAppStore],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.motion_games")   bool:feat.isSupportMotionGames],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.contacts")     bool:feat.isSupportContacts],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.emergency_contacts") bool:feat.isSupportEmergencyContacts],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.nfc_payment")   bool:feat.isSupportNFCPayment],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.voice_assistant")   bool:feat.isSupportVoiceAssistant],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.face_push")   bool:feat.isSupportFacePush],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.custom_face") bool:feat.isSupportCustomFace],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.slideshow_face") bool:feat.isSupportSlideshowFace],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.time_settings")   bool:feat.isSupportTimeSettings],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.language_settings")   bool:feat.isSupportLanguage],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.user_info")   bool:feat.isSupportUserInfoSettings],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.firmware_upgrade")   bool:feat.isSupportFirmwareUpgrade],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.unit_settings")   bool:feat.isSupportUnitSettings],
        [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.earbuds")     bool:feat.isSupportEarbudsAPIs],
    ] : @[ [TSInfoItem itemWithKey:TSLocalizedString(@"peripheral_info.device_title") value:nil] ];

    self.sectionData   = @[bleSection, verSection, scrSection, limSection, healthSection, deviceSection];
    self.sectionTitles = @[
        TSLocalizedString(@"peripheral_info.section_ble"),
        TSLocalizedString(@"peripheral_info.section_version"),
        TSLocalizedString(@"peripheral_info.section_screen"),
        TSLocalizedString(@"peripheral_info.section_limitation"),
        TSLocalizedString(@"peripheral_info.section_health"),
        TSLocalizedString(@"peripheral_info.section_device")
    ];
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
