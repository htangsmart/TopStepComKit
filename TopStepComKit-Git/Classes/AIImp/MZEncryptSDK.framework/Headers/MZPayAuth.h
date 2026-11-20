//
//  MZPayAuth.h
//  MZPayAuthSDKDemo
//
//  Created by locke on 2022/4/13.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MZPayAuthError.h"
#import "MZAuthResult.h"

NS_ASSUME_NONNULL_BEGIN

/// 回调Delegate
@protocol MZPayAuthDelegate <NSObject>

@required

/// 发送蓝牙数据给设备
/// @param data 数据
- (void)mzPayAuthWriteValue:(NSData *)data;

@optional

/// 注意：onCheckAuthoriseState、onCheckAuthoriseResult两个回调结果都是同样的，只是时机不一样，选一个使用即可

/// 回调鉴权结果
/// 注意：SDK是包含多功能校验的，该接口可能会多次回调
/// @param error 见MZPayAuthError
- (void)onCheckAuthoriseState:(MZPayAuthError *)error;

/// 回调鉴权结果
/// 注意：SDK是包含多功能校验的，该接口会在所有校验完成后统一回调
/// @param result MZAuthResult
- (void)onCheckAuthoriseResult:(MZAuthResult *)result;

@end

/// 鉴权类
@interface MZPayAuth : NSObject

/// 是否打印log,默认否
@property (nonatomic, assign) BOOL logEnable;
/// YES 测试环境 NO 商用(默认)
@property (nonatomic, assign) BOOL isTest;

/// 单例
+ (instancetype)share;

/// 开始鉴权
/// @param peripheral 蓝牙设备
/// @param delegate 鉴权结果回调delegate
/// @note 该方法需在蓝牙设备已连接上已监听特征（4a02）通知的前提下再调用，换个设备连接需再次调用该方法。
- (void)authWithPeripheral:(CBPeripheral *)peripheral delegate:(id<MZPayAuthDelegate>)delegate __attribute__((deprecated("Use authWithMac:name:delegate: instead")));


#pragma mark - 双支付、离线语音
/// 双支付、离线语音鉴权
/// @param mac 设备mac地址
/// @param name 设备名称
/// @param delegate 鉴权结果回调delegate
/// @note 该方法需在蓝牙设备已连接上已监听特征（4a02）通知的前提下再调用，换个设备连接需再次调用该方法。
- (void)authWithMac:(NSString *)mac name:(NSString *)name delegate:(id<MZPayAuthDelegate>)delegate;

/// 设备返回的蓝牙数据
/// @param data 蓝牙数据
- (void)parseData:(NSData *)data;


#pragma mark - 红外
/// 红外鉴权
/// @param mac 设备mac地址
- (void)hwAuthWithChannle:(NSString *)channle mac:(NSString *)mac complete:(void(^)(NSString* _Nullable sn, NSError * _Nullable error))complete;

@end

NS_ASSUME_NONNULL_END
