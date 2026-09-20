//
//  WMManager.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMFindModel.h"
#import "WMPeripheral.h"
#import "WMError.h"
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMManager : NSObject

/// 可订阅对象，手机蓝牙状态改变（CBManagerState）(Subscribed object, mobile Bluetooth state change (CBManagerState))
@property (nonatomic, strong) RACSignal<NSNumber *> *centralState;

+ (instancetype)sharedInstance;

/// 注册SDK (Register SDK)
/// - Parameter watchMate: WMFindModel 的子类 (A subclass of WMFindModel)
- (void)registerWatchMate:(WMFindModel *)watchMate;

/// 通过二维码信息，获取一个设备对象（回调一次）(Get a device object via QR code information (callback once))
/// - Parameter code: 二维码信息 (Two-dimensional code information)
/// - Parameter uid: 登陆用户的用户id (User id of the logged-in user)
- (RACSignal<WMPeripheral *> * _Nullable )findWatchFromQRCode:(NSString *)code uid:(NSString *)uid;

/// 通过产品类型，搜索附近设备（回调多次，需要主动停止搜索） (Search for nearby devices by product type (callback multiple times, need to actively stop searching))
/// - Parameter product: 产品类型 (Product type)
/// - Parameter name: 只搜索保护name前缀的设备， nil或@“”不过滤
/// - Parameter uid: 登陆用户的用户id (User id of the logged-in user)
- (RACSignal<WMPeripheral *> * _Nullable )findWatchFromSearch:(NSString *)product bleNamePrefix:(NSString * _Nullable)name Uid:(NSString *)uid;

/// 用与回连设备，通过mac和产品型号，获取一个设备对象（回调一次） (Get a device object (callback once) by mac and product model with a callback device)
/// - Parameters:
///   - target: 目标设备（mac, name等） (Target device (mac, name, etc.))
///   - product: 产品类型 (Product type)
///   // - Parameter uid: 登陆用户的用户id (User id of the logged-in user)
- (RACSignal<WMPeripheral *> * _Nullable )findWatchFromTarget:(WMPeripheralTargetModel *)target product:(NSString *)product uid:(NSString *)uid;

/// 停止搜索 (Stop search)
/// - Parameter product: 产品类型 (Product type)
- (void)stopSearch:(NSString *)product;

@end

NS_ASSUME_NONNULL_END
