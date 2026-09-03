//
//  TSOfflineMapVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSOfflineMapVC.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import <TopStepComKit/TopStepComKit.h>

#import "TSMyMapsVC.h"
#import "TSMapNamingModal.h"
#import "TSMapTransferOverlay.h"
#import "TSOfflineMapStore.h"
#import "UIViewController+TSToast.h"

/// 固定圆的视觉半径（点）
static const CGFloat kTSCircleRadiusPoints = 100.f;
/// 合法半径下限（公里）
static const double kTSRadiusMinKm = 1.0;
/// 合法半径上限（公里）
static const double kTSRadiusMaxKm = 20.0;
/// 默认半径（公里）
static const double kTSRadiusDefaultKm = 5.0;
/// 定位失败时的默认中心（北京）
static const CLLocationDegrees kTSDefaultLat = 39.9042;
static const CLLocationDegrees kTSDefaultLng = 116.4074;

@interface TSOfflineMapVC () <MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate,
                              UITableViewDataSource, UITableViewDelegate>

// 搜索栏
@property (nonatomic, strong) UIView *searchBar;
@property (nonatomic, strong) UITextField *searchField;
// 搜索结果下拉
@property (nonatomic, strong) UITableView *searchResultTable;
@property (nonatomic, strong) NSArray<MKMapItem *> *searchResults;
// 地图
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UIView *crossView;
@property (nonatomic, strong) UIButton *locateButton;
// 范围说明
@property (nonatomic, strong) UIView *rangeInfoView;
@property (nonatomic, strong) UILabel *rangeValueLabel;
// 底部按钮
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *myMapsButton;
// 定位
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL hasCenteredOnUser;
// 交互态
@property (nonatomic, assign) BOOL isProgrammaticRegionChange;
@property (nonatomic, assign) double currentRadiusKm;
@property (nonatomic, copy) NSString *centerName;
@property (nonatomic, assign) BOOL isDownloading;
// 设备已有地图名称（用于命名查重），进入页面时拉取
@property (nonatomic, strong) NSArray<NSString *> *deviceMapNames;
// 弹窗/覆盖层
@property (nonatomic, strong) TSMapNamingModal *namingModal;
@property (nonatomic, strong) TSMapTransferOverlay *transferOverlay;

@end

@implementation TSOfflineMapVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"offline_map.title");
    self.currentRadiusKm = kTSRadiusDefaultKm;
    self.centerName = TSLocalizedString(@"offline_map.center.mine");
    self.view.backgroundColor = TSColor_Card;
}

- (void)setupViews {
    // 不使用父类的 tableView
    [self.sourceTableview removeFromSuperview];

    [self ts_buildSearchBar];
    [self ts_buildMap];
    [self ts_buildRangeInfo];
    [self ts_buildBottomBar];
    [self ts_buildSearchResultTable];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ts_setupLocation];
    [self ts_fetchDeviceMapNames];
}

- (void)layoutViews {
    CGFloat top = self.ts_navigationBarTotalHeight;
    if (top <= 0) top = self.view.safeAreaInsets.top;
    CGFloat width = self.view.bounds.size.width;
    CGFloat bottomSafe = self.view.safeAreaInsets.bottom;

    CGFloat searchH = 52.f;
    self.searchBar.frame = CGRectMake(0, top, width, searchH);

    CGFloat bottomBarH = 60.f + bottomSafe;
    CGFloat rangeH = 52.f;
    self.bottomBar.frame = CGRectMake(0, self.view.bounds.size.height - bottomBarH, width, bottomBarH);
    self.rangeInfoView.frame = CGRectMake(0, CGRectGetMinY(self.bottomBar.frame) - rangeH, width, rangeH);

    CGFloat mapTop = CGRectGetMaxY(self.searchBar.frame);
    self.mapView.frame = CGRectMake(0, mapTop, width, CGRectGetMinY(self.rangeInfoView.frame) - mapTop);

    // 固定圆与十字始终居地图中心
    CGFloat circleD = kTSCircleRadiusPoints * 2.f;
    self.circleView.center = CGPointMake(CGRectGetMidX(self.mapView.bounds), CGRectGetMidY(self.mapView.bounds));
    self.circleView.bounds = CGRectMake(0, 0, circleD, circleD);
    self.crossView.center = self.circleView.center;

    self.locateButton.frame = CGRectMake(width - 14.f - 44.f,
                                         CGRectGetHeight(self.mapView.bounds) - 14.f - 44.f,
                                         44.f, 44.f);

    self.searchResultTable.frame = CGRectMake(12.f, CGRectGetMaxY(self.searchBar.frame),
                                              width - 24.f, 260.f);
}

#pragma mark - 构建 UI

/// 搜索栏
- (void)ts_buildSearchBar {
    self.searchBar = [[UIView alloc] init];
    self.searchBar.backgroundColor = TSColor_Card;
    [self.view addSubview:self.searchBar];

    UIView *wrap = [[UIView alloc] init];
    wrap.backgroundColor = TSColor_Background;
    wrap.layer.cornerRadius = 10.f;
    wrap.frame = CGRectMake(12.f, 8.f, self.view.bounds.size.width - 24.f, 36.f);
    wrap.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.searchBar addSubview:wrap];

    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, 10.f, 16.f, 16.f)];
    icon.tintColor = TSColor_TextSecondary;
    icon.contentMode = UIViewContentModeScaleAspectFit;
    if (@available(iOS 13.0, *)) {
        icon.image = [UIImage systemImageNamed:@"magnifyingglass"];
    }
    [wrap addSubview:icon];

    self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(34.f, 0, wrap.bounds.size.width - 44.f, 36.f)];
    self.searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchField.placeholder = TSLocalizedString(@"offline_map.search.placeholder");
    self.searchField.font = [UIFont systemFontOfSize:15.f];
    self.searchField.textColor = TSColor_TextPrimary;
    self.searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchField.returnKeyType = UIReturnKeySearch;
    self.searchField.delegate = self;
    [self.searchField addTarget:self action:@selector(ts_searchTextChanged) forControlEvents:UIControlEventEditingChanged];
    [wrap addSubview:self.searchField];
}

/// 地图
- (void)ts_buildMap {
    self.mapView = [[MKMapView alloc] init];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    [self.view addSubview:self.mapView];

    // 固定范围圆
    self.circleView = [[UIView alloc] init];
    self.circleView.userInteractionEnabled = NO;
    self.circleView.layer.cornerRadius = kTSCircleRadiusPoints;
    self.circleView.layer.borderWidth = 2.f;
    [self ts_applyCircleColorInBounds:YES];
    [self.mapView addSubview:self.circleView];

    // 中心十字
    self.crossView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18.f, 18.f)];
    self.crossView.userInteractionEnabled = NO;
    UIView *hBar = [[UIView alloc] initWithFrame:CGRectMake(0, 8.5f, 18.f, 1.f)];
    UIView *vBar = [[UIView alloc] initWithFrame:CGRectMake(8.5f, 0, 1.f, 18.f)];
    hBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55f];
    vBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55f];
    [self.crossView addSubview:hBar];
    [self.crossView addSubview:vBar];
    [self.mapView addSubview:self.crossView];

    // 回到我的位置
    self.locateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.locateButton.backgroundColor = TSColor_Card;
    self.locateButton.layer.cornerRadius = 22.f;
    self.locateButton.tintColor = TSColor_Primary;
    self.locateButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.locateButton.layer.shadowOpacity = 0.15f;
    self.locateButton.layer.shadowRadius = 6.f;
    self.locateButton.layer.shadowOffset = CGSizeMake(0, 2.f);
    if (@available(iOS 13.0, *)) {
        [self.locateButton setImage:[UIImage systemImageNamed:@"location.fill"] forState:UIControlStateNormal];
    }
    [self.locateButton addTarget:self action:@selector(ts_locateTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.locateButton];
}

/// 范围说明
- (void)ts_buildRangeInfo {
    self.rangeInfoView = [[UIView alloc] init];
    self.rangeInfoView.backgroundColor = TSColor_Card;
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = TSColor_Separator;
    topLine.frame = CGRectMake(0, 0, self.view.bounds.size.width, 0.5f);
    topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.rangeInfoView addSubview:topLine];
    [self.view addSubview:self.rangeInfoView];

    self.rangeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.f, 8.f, self.view.bounds.size.width - 32.f, 20.f)];
    self.rangeValueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.rangeValueLabel.font = [UIFont systemFontOfSize:14.f];
    self.rangeValueLabel.textColor = TSColor_TextPrimary;
    [self.rangeInfoView addSubview:self.rangeValueLabel];

    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.f, 28.f, self.view.bounds.size.width - 32.f, 16.f)];
    tipLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tipLabel.font = [UIFont systemFontOfSize:12.f];
    tipLabel.textColor = TSColor_TextSecondary;
    tipLabel.text = TSLocalizedString(@"offline_map.range.tip");
    [self.rangeInfoView addSubview:tipLabel];

    [self ts_updateRadiusUIWithKm:self.currentRadiusKm];
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

    self.downloadButton = [self ts_barButtonWithTitle:TSLocalizedString(@"offline_map.download") primary:YES];
    [self.downloadButton addTarget:self action:@selector(ts_downloadTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.downloadButton];

    self.myMapsButton = [self ts_barButtonWithTitle:TSLocalizedString(@"offline_map.view_my_maps") primary:NO];
    [self.myMapsButton addTarget:self action:@selector(ts_myMapsTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.myMapsButton];
}

/// 搜索结果下拉表
- (void)ts_buildSearchResultTable {
    self.searchResultTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.searchResultTable.dataSource = self;
    self.searchResultTable.delegate = self;
    self.searchResultTable.backgroundColor = TSColor_Card;
    self.searchResultTable.layer.cornerRadius = 10.f;
    self.searchResultTable.layer.masksToBounds = YES;
    self.searchResultTable.hidden = YES;
    self.searchResultTable.rowHeight = 56.f;
    [self.view addSubview:self.searchResultTable];
}

/// 创建底部按钮
- (UIButton *)ts_barButtonWithTitle:(NSString *)title primary:(BOOL)primary {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
    button.layer.cornerRadius = 12.f;
    if (primary) {
        button.backgroundColor = TSColor_Primary;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        button.backgroundColor = TSColor_Background;
        [button setTitleColor:TSColor_TextPrimary forState:UIControlStateNormal];
    }
    return button;
}

#pragma mark - 布局底部按钮

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat pad = 16.f;
    CGFloat gap = 10.f;
    CGFloat w = (self.bottomBar.bounds.size.width - pad * 2 - gap) / 2.f;
    CGFloat h = 44.f;
    self.downloadButton.frame = CGRectMake(pad, 8.f, w, h);
    self.myMapsButton.frame = CGRectMake(pad + w + gap, 8.f, w, h);
}

#pragma mark - 半径 UI

/// 更新半径文案与圆颜色
- (void)ts_updateRadiusUIWithKm:(double)km {
    self.currentRadiusKm = km;
    double display = MAX(0.1, km);
    self.rangeValueLabel.attributedText = [self ts_rangeTextForKm:display];
    BOOL inBounds = (km >= kTSRadiusMinKm - 0.05 && km <= kTSRadiusMaxKm + 0.05);
    [self ts_applyCircleColorInBounds:inBounds];
}

/// 拼接「当前范围 X.X 公里」富文本（数值蓝色加粗）
- (NSAttributedString *)ts_rangeTextForKm:(double)km {
    NSString *prefix = TSLocalizedString(@"offline_map.range.current");
    NSString *value = [NSString stringWithFormat:@"%.1f", km];
    NSString *unit = TSLocalizedString(@"offline_map.range.unit");
    NSString *full = [NSString stringWithFormat:@"%@ %@ %@", prefix, value, unit];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:full];
    NSRange valueRange = [full rangeOfString:value];
    if (valueRange.location != NSNotFound) {
        [attr addAttribute:NSForegroundColorAttributeName value:TSColor_Primary range:valueRange];
        [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.f weight:UIFontWeightSemibold] range:valueRange];
    }
    return attr;
}

/// 应用圆边框颜色（越界橙色）
- (void)ts_applyCircleColorInBounds:(BOOL)inBounds {
    UIColor *color = inBounds ? TSColor_Primary : TSColor_Warning;
    self.circleView.layer.borderColor = color.CGColor;
    self.circleView.backgroundColor = [color colorWithAlphaComponent:0.13f];
}

#pragma mark - 半径 <-> 地图缩放换算

/// 测量固定圆当前覆盖的真实半径（公里）
- (double)ts_measureRadiusKm {
    if (self.mapView.bounds.size.width < 1) return self.currentRadiusKm;
    CGPoint center = CGPointMake(CGRectGetMidX(self.mapView.bounds), CGRectGetMidY(self.mapView.bounds));
    CGPoint edge = CGPointMake(center.x + kTSCircleRadiusPoints, center.y);
    CLLocationCoordinate2D centerCoord = [self.mapView convertPoint:center toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D edgeCoord = [self.mapView convertPoint:edge toCoordinateFromView:self.mapView];
    CLLocation *l1 = [[CLLocation alloc] initWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];
    CLLocation *l2 = [[CLLocation alloc] initWithLatitude:edgeCoord.latitude longitude:edgeCoord.longitude];
    return [l1 distanceFromLocation:l2] / 1000.0;
}

/// 设置地图缩放，使固定圆覆盖指定半径
- (void)ts_setRadiusKm:(double)km center:(CLLocationCoordinate2D)center animated:(BOOL)animated {
    CGFloat mapH = self.mapView.bounds.size.height;
    if (mapH < 1) mapH = 400.f;
    double spanMeters = km * 1000.0 * (mapH / kTSCircleRadiusPoints);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, spanMeters, spanMeters);
    self.isProgrammaticRegionChange = YES;
    [self.mapView setRegion:region animated:animated];
}

#pragma mark - 定位

- (void)ts_setupLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;

    CLAuthorizationStatus status;
    if (@available(iOS 14.0, *)) {
        status = self.locationManager.authorizationStatus;
    } else {
        status = [CLLocationManager authorizationStatus];
    }
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    } else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        [self ts_showLocationDeniedAlert];
        [self ts_centerOnDefaultLocation];
    } else {
        [self ts_startLocating];
    }
}

- (void)ts_startLocating {
    self.mapView.showsUserLocation = YES;
    [self.locationManager startUpdatingLocation];
}

- (void)ts_centerOnDefaultLocation {
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(kTSDefaultLat, kTSDefaultLng);
    [self ts_setRadiusKm:kTSRadiusDefaultKm center:center animated:NO];
}

- (void)ts_showLocationDeniedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"offline_map.location.denied.title")
                                                                  message:TSLocalizedString(@"offline_map.location.denied.message")
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.go_settings")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager API_AVAILABLE(ios(14.0)) {
    CLAuthorizationStatus status = manager.authorizationStatus;
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self ts_startLocating];
    } else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        [self ts_centerOnDefaultLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject;
    if (!location || self.hasCenteredOnUser) return;
    self.hasCenteredOnUser = YES;
    [manager stopUpdatingLocation];
    [self ts_setRadiusKm:kTSRadiusDefaultKm center:location.coordinate animated:NO];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (!self.hasCenteredOnUser) {
        [self ts_centerOnDefaultLocation];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapViewDidChangeVisibleRegion:(MKMapView *)mapView API_AVAILABLE(ios(11.0)) {
    [self ts_updateRadiusUIWithKm:[self ts_measureRadiusKm]];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    double km = [self ts_measureRadiusKm];
    [self ts_updateRadiusUIWithKm:km];

    BOOL wasProgrammatic = self.isProgrammaticRegionChange;
    self.isProgrammaticRegionChange = NO;
    if (wasProgrammatic) return;

    // 用户手势结束后越界回弹至最近边界
    if (km < kTSRadiusMinKm - 0.05 || km > kTSRadiusMaxKm + 0.05) {
        double target = (km < kTSRadiusMinKm) ? kTSRadiusMinKm : kTSRadiusMaxKm;
        [self ts_setRadiusKm:target center:mapView.centerCoordinate animated:YES];
        return;
    }
    // 拖动地图后圆心不再是「我的位置」
    if ([self.centerName isEqualToString:TSLocalizedString(@"offline_map.center.mine")]) {
        self.centerName = TSLocalizedString(@"offline_map.center.selected");
    }
}

#pragma mark - 事件

- (void)ts_locateTapped {
    CLLocation *userLocation = self.mapView.userLocation.location;
    self.centerName = TSLocalizedString(@"offline_map.center.mine");
    if (userLocation) {
        [self ts_setRadiusKm:kTSRadiusDefaultKm center:userLocation.coordinate animated:YES];
    } else {
        [self ts_centerOnDefaultLocation];
    }
    [self ts_showToast:TSLocalizedString(@"offline_map.located_back")];
}

- (void)ts_myMapsTapped {
    TSMyMapsVC *vc = [[TSMyMapsVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)ts_downloadTapped {
    if (![[TopStepComKit sharedInstance] offlineMap]) {
        [self ts_showToast:TSLocalizedString(@"offline_map.device_disconnected")];
        return;
    }
    if ([TSOfflineMapStore sharedStore].localMapCount >= [TSOfflineMapStore sharedStore].maxLocalMapCount) {
        [self ts_showToast:TSLocalizedString(@"offline_map.local_full")];
        return;
    }

    __weak typeof(self) weakSelf = self;
    self.namingModal = [[TSMapNamingModal alloc] init];
    self.namingModal.onConfirm = ^(NSString *inputName) {
        [weakSelf ts_handleNamingConfirm:inputName];
    };
    [self.namingModal showInView:self.navigationController.view];
}

#pragma mark - 命名 + 下载

/// 命名确认：校验后开始下载
- (void)ts_handleNamingConfirm:(NSString *)name {
    NSString *error = [self ts_validateName:name];
    if (error) {
        [self.namingModal showError:error];
        return;
    }
    [self.namingModal dismiss];
    self.namingModal = nil;
    [self ts_startDownloadWithName:name];
}

/// 命名校验
- (NSString *)ts_validateName:(NSString *)name {
    if (name.length == 0) return TSLocalizedString(@"offline_map.name.empty");
    if (name.length > 20) return TSLocalizedString(@"offline_map.name.too_long");
    NSString *pattern = @"^[\\u4e00-\\u9fa5A-Za-z0-9_ ·\\-]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    if (![predicate evaluateWithObject:name]) return TSLocalizedString(@"offline_map.name.invalid");
    if ([[TSOfflineMapStore sharedStore] isNameUsedLocally:name]) return TSLocalizedString(@"offline_map.name.duplicate");
    if ([self.deviceMapNames containsObject:name]) return TSLocalizedString(@"offline_map.name.duplicate");
    return nil;
}

/// 开始下载
- (void)ts_startDownloadWithName:(NSString *)name {
    NSInteger radius = (NSInteger)round(MIN(kTSRadiusMaxKm, MAX(kTSRadiusMinKm, self.currentRadiusKm)));
    CLLocationCoordinate2D center = self.mapView.centerCoordinate;
    TSOfflineMapRegion *region = [TSOfflineMapRegion regionWithLatitude:center.latitude
                                                             longitude:center.longitude
                                                                radius:radius];

    self.isDownloading = YES;
    [self ts_setNavigationBlocked:YES];
    self.transferOverlay = [[TSMapTransferOverlay alloc] init];
    [self.transferOverlay showInView:self.navigationController.view
                               title:TSLocalizedString(@"offline_map.downloading.title")
                                hint:TSLocalizedString(@"offline_map.downloading.hint")];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] offlineMap] downloadOfflineMapWithRegion:region
                                                                     progress:^(TSFileTransferStatus state, NSInteger progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.transferOverlay updateProgress:progress];
        });
    } completion:^(NSString *packagePath, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf ts_handleDownloadFinished:packagePath name:name radius:radius error:error];
        });
    }];
}

/// 下载结束处理
- (void)ts_handleDownloadFinished:(NSString *)packagePath name:(NSString *)name radius:(NSInteger)radius error:(NSError *)error {
    self.isDownloading = NO;
    [self ts_setNavigationBlocked:NO];
    [self.transferOverlay dismiss];
    self.transferOverlay = nil;

    if (error || packagePath.length == 0) {
        NSString *msg = error.localizedDescription ?: TSLocalizedString(@"offline_map.download.failed");
        [self ts_showToast:msg];
        return;
    }

    // 入库前再查一次重，重名自动追加序号
    NSString *finalName = name;
    NSInteger suffix = 2;
    while ([[TSOfflineMapStore sharedStore] isNameUsedLocally:finalName] || [self.deviceMapNames containsObject:finalName]) {
        finalName = [NSString stringWithFormat:@"%@ %ld", name, (long)suffix++];
    }
    [[TSOfflineMapStore sharedStore] addLocalMapWithName:finalName packagePath:packagePath radius:radius];
    [self ts_showToast:TSLocalizedString(@"offline_map.download.done")];

    TSMyMapsVC *vc = [[TSMyMapsVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/// 下载中拦截导航返回
- (void)ts_setNavigationBlocked:(BOOL)blocked {
    self.navigationItem.hidesBackButton = blocked;
    self.navigationController.interactivePopGestureRecognizer.enabled = !blocked;
}

#pragma mark - 设备地图名称（查重用）

- (void)ts_fetchDeviceMapNames {
    id<TSOfflineMapsInterface> offlineMap = [[TopStepComKit sharedInstance] offlineMap];
    if (!offlineMap) return;
    __weak typeof(self) weakSelf = self;
    [offlineMap fetchDeviceOfflineMaps:^(NSArray<NSString *> *mapNames, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.deviceMapNames = mapNames ?: @[];
        });
    }];
}

#pragma mark - 搜索

- (void)ts_searchTextChanged {
    NSString *keyword = [self.searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (keyword.length == 0) {
        self.searchResults = nil;
        self.searchResultTable.hidden = YES;
        return;
    }

    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = keyword;
    request.region = self.mapView.region;

    __weak typeof(self) weakSelf = self;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.searchResults = response.mapItems;
            weakSelf.searchResultTable.hidden = (response.mapItems.count == 0);
            [weakSelf.searchResultTable reloadData];
        });
    }];
}

- (void)ts_pickSearchItem:(MKMapItem *)item {
    [self.searchField resignFirstResponder];
    self.searchResultTable.hidden = YES;
    self.searchField.text = item.name;
    self.centerName = item.name;
    [self ts_setRadiusKm:self.currentRadiusKm center:item.placemark.coordinate animated:YES];
    [self ts_showToast:[NSString stringWithFormat:TSLocalizedString(@"offline_map.located_to"), item.name]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDataSource / Delegate（搜索结果）

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"kTSSearchResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.textLabel.font = [UIFont systemFontOfSize:15.f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.f];
        cell.detailTextLabel.textColor = TSColor_TextSecondary;
        if (@available(iOS 13.0, *)) {
            cell.imageView.image = [UIImage systemImageNamed:@"mappin.circle.fill"];
            cell.imageView.tintColor = TSColor_Danger;
        }
    }
    MKMapItem *item = self.searchResults[indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [self ts_addressForPlacemark:item.placemark];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self ts_pickSearchItem:self.searchResults[indexPath.row]];
}

/// 拼接地址描述
- (NSString *)ts_addressForPlacemark:(MKPlacemark *)placemark {
    NSMutableArray *parts = [NSMutableArray array];
    if (placemark.locality) [parts addObject:placemark.locality];
    if (placemark.thoroughfare) [parts addObject:placemark.thoroughfare];
    return [parts componentsJoinedByString:@" "];
}

@end
