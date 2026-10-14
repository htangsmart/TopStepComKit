//
//  TSAIChatLocationService.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/14.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatLocationService.h"

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>

NSErrorDomain const TSAIChatLocationErrorDomain = @"TSAIChatLocationErrorDomain";

/// 缓存有效期（秒）
static const NSTimeInterval kTSAIChatLocationCacheInterval = 120;
/// 单次定位超时（秒），含权限弹窗后的等待
static const NSTimeInterval kTSAIChatLocationFixTimeout = 10;
/// 逆地理超时（秒）
static const NSTimeInterval kTSAIChatLocationGeocodeTimeout = 5;

@interface TSAIChatLocationService () <CLLocationManagerDelegate>

// 定位管理器
@property (nonatomic, strong) CLLocationManager *locationManager;
// 逆地理
@property (nonatomic, strong) CLGeocoder *geocoder;
// 最近一次成功的定位
@property (nonatomic, strong, nullable, readwrite) CLLocation *lastLocation;
// 最近一次成功定位的地名
@property (nonatomic, copy, nullable, readwrite) NSString *lastPlaceName;
// 合并中的回调（同一时间只跑一次定位）
@property (nonatomic, strong) NSMutableArray<TSAIChatLocationFetchBlock> *pendingBlocks;
// 是否在等待权限弹窗结果
@property (nonatomic, assign) BOOL waitingForAuthorization;
// 是否正在定位
@property (nonatomic, assign) BOOL locating;
// 定位超时计时
@property (nonatomic, strong, nullable) NSTimer *fixTimer;

@end

@implementation TSAIChatLocationService

#pragma mark - 生命周期

+ (instancetype)sharedService {
    static TSAIChatLocationService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc] initPrivate];
    });
    return service;
}

/// 私有初始化
- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _pendingBlocks = [NSMutableArray array];
        _geocoder = [[CLGeocoder alloc] init];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return self;
}

#pragma mark - 公开方法

/// 当前授权状态（最低 iOS 15，直接用实例属性）
- (CLAuthorizationStatus)authorizationStatus {
    return self.locationManager.authorizationStatus;
}

/// 是否已获得可用权限
- (BOOL)isAuthorized {
    CLAuthorizationStatus status = self.authorizationStatus;
    return status == kCLAuthorizationStatusAuthorizedWhenInUse ||
           status == kCLAuthorizationStatusAuthorizedAlways;
}

/// 获取当前位置与地名：缓存 → 权限 → 定位 → 逆地理
- (void)fetchLocationAllowingPrompt:(BOOL)allowPrompt
                         completion:(TSAIChatLocationFetchBlock)completion {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fetchLocationAllowingPrompt:allowPrompt completion:completion];
        });
        return;
    }
    if (!completion) {
        return;
    }
    if ([self hasFreshCache]) {
        TSLog(@"[TSAIChatLocationService] cache hit: age=%.0fs, place=%@",
              -[self.lastLocation.timestamp timeIntervalSinceNow], self.lastPlaceName);
        completion(self.lastLocation, self.lastPlaceName, nil);
        return;
    }
    [self.pendingBlocks addObject:[completion copy]];
    if (self.locating || self.waitingForAuthorization) {
        TSLog(@"[TSAIChatLocationService] request merged into in-flight fix");
        return;
    }
    [self beginFetchAllowingPrompt:allowPrompt];
}

/// 打开系统设置
- (void)openSystemSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

#pragma mark - 私有方法

/// 缓存是否仍在有效期内
- (BOOL)hasFreshCache {
    if (!self.lastLocation || self.lastPlaceName.length == 0) {
        return NO;
    }
    return -[self.lastLocation.timestamp timeIntervalSinceNow] < kTSAIChatLocationCacheInterval;
}

/// 按权限状态决定：申请权限 / 直接定位 / 失败
/// 不调用 locationServicesEnabled（iOS 16+ 主线程调用会告警）：系统定位关闭时状态即为 Denied，
/// 且 didFailWithError 会回 kCLErrorDenied，两者都按权限问题引导去设置
- (void)beginFetchAllowingPrompt:(BOOL)allowPrompt {
    CLAuthorizationStatus status = self.authorizationStatus;
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [self startLocating];
            break;
        case kCLAuthorizationStatusNotDetermined:
            if (!allowPrompt) {
                [self finishWithLocation:nil placeName:nil
                                   error:[self errorWithCode:TSAIChatLocationErrorCodePermissionNotDetermined
                                                 description:@"尚未授权定位"]];
                return;
            }
            TSLog(@"[TSAIChatLocationService] requesting when-in-use authorization");
            self.waitingForAuthorization = YES;
            [self.locationManager requestWhenInUseAuthorization];
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        default:
            [self finishWithLocation:nil placeName:nil
                               error:[self errorWithCode:TSAIChatLocationErrorCodePermissionDenied
                                             description:@"定位权限被拒绝"]];
            break;
    }
}

/// 开始一次定位并启动超时
- (void)startLocating {
    if (self.locating) {
        return;
    }
    self.locating = YES;
    TSLog(@"[TSAIChatLocationService] start locating");
    [self.locationManager startUpdatingLocation];
    [self.fixTimer invalidate];
    __weak typeof(self) weakSelf = self;
    self.fixTimer = [NSTimer scheduledTimerWithTimeInterval:kTSAIChatLocationFixTimeout
                                                    repeats:NO
                                                      block:^(NSTimer *timer) {
        [weakSelf onFixTimeout];
    }];
}

/// 定位超时：有旧位置就降级使用，否则失败
- (void)onFixTimeout {
    if (!self.locating) {
        return;
    }
    TSLog(@"[TSAIChatLocationService] fix timeout, hasStale=%d", self.lastLocation != nil);
    [self.locationManager stopUpdatingLocation];
    self.locating = NO;
    if (self.lastLocation) {
        [self resolvePlaceNameForLocation:self.lastLocation];
        return;
    }
    [self finishWithLocation:nil placeName:nil
                       error:[self errorWithCode:TSAIChatLocationErrorCodeFixFailed
                                     description:@"定位超时"]];
}

/// 逆地理：成功拼"省市区街道"，失败降级为 GPS 文本
- (void)resolvePlaceNameForLocation:(CLLocation *)location {
    __weak typeof(self) weakSelf = self;
    __block BOOL finished = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTSAIChatLocationGeocodeTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (finished) {
            return;
        }
        finished = YES;
        [weakSelf.geocoder cancelGeocode];
        TSLog(@"[TSAIChatLocationService] reverse geocode timeout, fallback to GPS text");
        [weakSelf finishWithLocation:location placeName:[weakSelf gpsPlaceNameForLocation:location] error:nil];
    });
    [self.geocoder reverseGeocodeLocation:location
                        completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finished) {
                return;
            }
            finished = YES;
            NSString *placeName = [weakSelf placeNameFromPlacemark:placemarks.firstObject];
            if (placeName.length == 0) {
                TSLog(@"[TSAIChatLocationService] reverse geocode failed: %@", error);
                placeName = [weakSelf gpsPlaceNameForLocation:location];
            }
            [weakSelf finishWithLocation:location placeName:placeName error:nil];
        });
    }];
}

/// 把 placemark 拼成"省 市 区 街道"（去重、去空）
- (nullable NSString *)placeNameFromPlacemark:(nullable CLPlacemark *)placemark {
    if (!placemark) {
        return nil;
    }
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    for (NSString *part in @[placemark.administrativeArea ?: @"",
                             placemark.locality ?: @"",
                             placemark.subLocality ?: @"",
                             placemark.thoroughfare ?: @""]) {
        if (part.length > 0 && ![parts containsObject:part]) {
            [parts addObject:part];
        }
    }
    return parts.count > 0 ? [parts componentsJoinedByString:@""] : nil;
}

/// GPS 降级文本
- (NSString *)gpsPlaceNameForLocation:(CLLocation *)location {
    return [NSString stringWithFormat:@"GPS(%.4f,%.4f)",
            location.coordinate.latitude, location.coordinate.longitude];
}

/// 统一收口：更新缓存并回调所有等待者
- (void)finishWithLocation:(nullable CLLocation *)location
                 placeName:(nullable NSString *)placeName
                     error:(nullable NSError *)error {
    [self.fixTimer invalidate];
    self.fixTimer = nil;
    self.locating = NO;
    self.waitingForAuthorization = NO;
    if (location && placeName.length > 0) {
        self.lastLocation = location;
        self.lastPlaceName = placeName;
    }
    NSArray<TSAIChatLocationFetchBlock> *blocks = [self.pendingBlocks copy];
    [self.pendingBlocks removeAllObjects];
    TSLog(@"[TSAIChatLocationService] finish: hasLocation=%d, place=%@, error=%@, waiters=%lu",
          location != nil, placeName, error, (unsigned long)blocks.count);
    for (TSAIChatLocationFetchBlock block in blocks) {
        block(location, placeName, error);
    }
}

/// 构造错误
- (NSError *)errorWithCode:(TSAIChatLocationErrorCode)code description:(NSString *)description {
    return [NSError errorWithDomain:TSAIChatLocationErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

#pragma mark - CLLocationManagerDelegate

/// 权限变化：等待中的请求按新状态继续
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    CLAuthorizationStatus status = self.authorizationStatus;
    TSLog(@"[TSAIChatLocationService] authorization changed: status=%d, waiting=%d",
          (int)status, self.waitingForAuthorization);
    if (!self.waitingForAuthorization || status == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    self.waitingForAuthorization = NO;
    [self beginFetchAllowingPrompt:NO];
}

/// 拿到位置：停止并逆地理
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject;
    if (!location || !self.locating) {
        return;
    }
    [manager stopUpdatingLocation];
    self.locating = NO;
    [self.fixTimer invalidate];
    self.fixTimer = nil;
    [self resolvePlaceNameForLocation:location];
}

/// 定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (!self.locating) {
        return;
    }
    TSLog(@"[TSAIChatLocationService] locate failed: %@", error);
    [manager stopUpdatingLocation];
    self.locating = NO;
    if (error.code == kCLErrorDenied) {
        [self finishWithLocation:nil placeName:nil
                           error:[self errorWithCode:TSAIChatLocationErrorCodePermissionDenied
                                         description:@"定位权限被拒绝"]];
        return;
    }
    if (self.lastLocation) {
        [self resolvePlaceNameForLocation:self.lastLocation];
        return;
    }
    [self finishWithLocation:nil placeName:nil
                       error:[self errorWithCode:TSAIChatLocationErrorCodeFixFailed
                                     description:error.localizedDescription ?: @"定位失败"]];
}

@end
