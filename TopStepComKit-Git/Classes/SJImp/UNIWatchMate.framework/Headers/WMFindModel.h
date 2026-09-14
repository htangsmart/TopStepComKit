//
//  WMFindModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMPeripheral.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , WMPeripheralFormType){
    UNIWPeripheralFormTypeScanQR NS_SWIFT_NAME(scanQR),
    UNIWPeripheralFormTypeSearch NS_SWIFT_NAME(search),
    UNIWPeripheralFormTypeMac NS_SWIFT_NAME(mac),
};

/// 需要连接的设备 (Devices that need to be connected)
@interface WMPeripheralTargetModel : NSObject

/// 连接入口 (Connection entry)
@property (nonatomic, assign) WMPeripheralFormType type;
/// 设备Mac地址 (Device Mac address)
@property (nonatomic, strong) NSString * mac;
/// 设备蓝牙名称 (Device Bluetooth name)
@property (nonatomic, strong) NSString * name;
/// 产品型号 (Product model)
@property (nonatomic, strong) NSString * product;

@end

@interface WMFindModel : NSObject

/// 单例需要子类实现 (Singletons require subclass implementation)
+ (WMFindModel *)sharedInstance;

/// 通过二维码信息获取一个watch对象 (Get a watch object by QR code information)
/// - Parameter code: 二维码信息 (Two-dimensional code information)
- (RACSignal<WMPeripheral *> * _Nullable )fromScanQRCode:(NSString *)code uid:(NSString *)uid;

/// 搜索周围可以用的设备 (Search around for available devices)
- (RACSignal<WMPeripheral *> * _Nullable )fromSearchWithBleNamePrefix:(NSString * _Nullable)name Uid:(NSString *)uid;

/// 停止搜索 (Stop search)
- (void)stopSearch;

/// 通过target获取一个watch对象 (Get a watch object from target)
/// - Parameter target: target 包含mac，name等信息 (target contains information such as mac and name)
/// - Parameter uid: 用户ID (User ID)
- (RACSignal<WMPeripheral *> * _Nullable )fromTarget:(WMPeripheralTargetModel *)target uid:(NSString *)uid;

/// 是否支持某个产品 (Whether a product is supported)
/// - Parameter product: 产品型号 (Product model)
- (BOOL)isEnabledForProduct:(NSString *)product;

@end

NS_ASSUME_NONNULL_END
