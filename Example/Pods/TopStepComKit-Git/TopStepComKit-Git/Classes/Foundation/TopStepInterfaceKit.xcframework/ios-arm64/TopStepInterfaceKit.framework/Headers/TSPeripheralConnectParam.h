//
//  TSPeripheralConnectParam.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <Foundation/Foundation.h>
#import "TSComEnumDefines.h"
#import "TSUserInfoModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TSPeripheralConnectParam : NSObject

/**
 * @brief User ID for device connection
 * @chinese 设备连接的用户ID
 *
 * @discussion
 * [EN]: The user ID requirements vary by SDK type:
 * - eTSSDKTypeFw: Max 32 characters, cannot be empty
 * - eTSSDKTypeSJ: Cannot be empty
 * - eTSSDKTypeFit: Cannot be empty
 * 
 * [CN]: 用户ID要求根据SDK类型不同而异：
 * - eTSSDKTypeFw: 最大32个字符，不能为空
 * - eTSSDKTypeSJ: 不能为空
 * - eTSSDKTypeFit: 不能为空
 */
@property (nonatomic,strong,nonnull) NSString * userId;

/**
 * @brief User information model for device connection
 * @chinese 设备连接的用户信息模型
 *
 * @discussion
 * EN: Contains detailed user profile information used for device connection and personalization. *
 * CN: 包含用于设备连接和个性化的详细用户档案信息。
 */
@property (nonatomic,strong) TSUserInfoModel * userInfo;

/**
 * @brief auth code obtained from QR code scanning during device binding
 * @chinese 设备绑定时通过扫描二维码获得的随机码
 *
 * @discussion
 * [EN]: This code is used for device authentication during the binding process
 * [CN]: 此随机码用于设备绑定过程中的认证
 */
@property (nonatomic,strong) NSString * authCode;

/**
 * @brief Flag indicating whether Bluetooth connection is allowed
 * @chinese 标识是否允许蓝牙连接
 *
 * @discussion
 * [EN]: Controls whether the device can establish Bluetooth connections
 * [CN]: 控制设备是否可以建立蓝牙连接
 */
@property (nonatomic, assign) BOOL allowConnectWithBT;

/**
 * @brief Phone brand information
 * @chinese 手机品牌信息
 *
 * @discussion
 * [EN]: Identifies the manufacturer of the phone (e.g., Apple, Samsung)
 * [CN]: 标识手机制造商（如：苹果、三星）
 */
@property (nonatomic,strong) NSString * brand;

/**
 * @brief Phone model information
 * @chinese 手机型号信息
 *
 * @discussion
 * [EN]: Specific model identifier of the phone (e.g., iPhone 12, iPhone 13 Pro)
 * [CN]: 手机的具体型号标识（如：iPhone 12、iPhone 13 Pro）
 */
@property (nonatomic,strong) NSString * model;

/**
 * @brief Phone system version
 * @chinese 手机系统版本
 *
 * @discussion
 * [EN]: Operating system version of the phone (e.g., iOS 15.0)
 * [CN]: 手机的操作系统版本（如：iOS 15.0）
 */
@property (nonatomic,strong) NSString * systemVersion;

/**
 * @brief Unavailable default initializer
 * @chinese 不可用的默认初始化方法
 *
 * @discussion
 * [EN]: This initializer is unavailable. Use initWithUserId: instead.
 * [CN]: 此初始化方法不可用。请使用 initWithUserId: 方法代替。
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Disable copy method
 * @chinese 禁用复制方法
 *
 * @discussion
 * [EN]: This method is unavailable. TSPeripheralConnectParam instances should not be copied.
 * [CN]: 此方法不可用。TSPeripheralConnectParam实例不应被复制。
 */
- (instancetype)copy NS_UNAVAILABLE;

/**
 * @brief Disable new method
 * @chinese 禁用new方法
 *
 * @discussion
 * [EN]: This method is unavailable. Use initWithUserId: instead.
 * [CN]: 此方法不可用。请使用initWithUserId:代替。
 */
- (instancetype)new NS_UNAVAILABLE;


/**
 * @brief Designated initializer with user ID
 * @chinese 指定的用户ID初始化方法
 *
 * @param userId 
 * [EN]: User ID for device connection, must not be empty
 * [CN]: 设备连接的用户ID，不能为空
 *
 * @return 
 * [EN]: An initialized TSPeripheralConnectParam instance
 * [CN]: 初始化后的TSPeripheralConnectParam实例
 *
 * @discussion
 * [EN]: Creates a connection parameter object with the specified user ID.
 * This is the only valid way to initialize this class.
 * Other properties can be set after initialization.
 *
 * [CN]: 使用指定的用户ID创建连接参数对象。
 * 这是初始化此类的唯一有效方式。
 * 其他属性可以在初始化后设置。
 */
- (instancetype)initWithUserId:(NSString *)userId NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
