//
//  TSPeripheralConnectParam.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <Foundation/Foundation.h>
#import "TSComEnumDefines.h"
#import "TSUserInfoModel.h"
#import "TSAIVendor.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Default connection timeout in seconds. Current value: 30 seconds.
 * @chinese 默认连接超时时间，单位秒。当前值：30秒。
 */
FOUNDATION_EXPORT NSTimeInterval const TSDefaultPeripheralConnectTimeout;

/**
 * @brief Default maximum auto-reconnect attempts. Current value: 5.
 * @chinese 默认最大自动重连次数。当前值：5。
 */
FOUNDATION_EXPORT NSInteger const TSDefaultPeripheralMaxReconnectCount;

/**
 * @brief Extra connection parameters used by specific SDK implementations.
 * @chinese 具体 SDK 实现使用的连接补充参数。
 */
@interface TSConnectExtraParam : NSObject

@end

/**
 * @brief Fit specific extra connection parameters.
 * @chinese Fit 连接补充参数。
 */
@interface TSFitConnectExtraParam : TSConnectExtraParam

/**
 * @brief Whether to also connect Classic Bluetooth when supported.
 * @chinese 支持时是否同时连接经典蓝牙。
 */
@property (nonatomic, assign) BOOL allowConnectWithBT;

@end

/**
 * @brief NewPlatform specific extra connection parameters.
 * @chinese NewPlatform 连接补充参数。
 */
@interface TSNpkConnectExtraParam : TSConnectExtraParam

/**
 * @brief User gender sent during NPK authentication.
 * @chinese NPK 鉴权时下发的用户性别。
 */
@property (nonatomic, assign) TSUserGender gender;

/**
 * @brief User age sent during NPK authentication.
 * @chinese NPK 鉴权时下发的用户年龄。
 */
@property (nonatomic, assign) UInt8 age;

/**
 * @brief User height in centimeters sent during NPK authentication.
 * @chinese NPK 鉴权时下发的用户身高，单位厘米。
 */
@property (nonatomic, assign) CGFloat height;

/**
 * @brief User weight in kilograms sent during NPK authentication.
 * @chinese NPK 鉴权时下发的用户体重，单位千克。
 */
@property (nonatomic, assign) CGFloat weight;

@end

/**
 * @brief Buds specific extra connection parameters.
 * @chinese Buds 连接补充参数。
 */
@interface TSBudsConnectExtraParam : TSConnectExtraParam

/**
 * @brief AI vendor license ID for Buds device authentication
 * @chinese Buds 设备 AI 方案商授权 ID
 *
 * @discussion
 * [EN]: The license ID issued by the AI solution provider for this specific device.
 *       Only required for Buds-type devices; can be nil for other device types.
 * [CN]: AI 方案商针对该设备下发的授权 ID。
 *       仅 Buds 类设备需要传入，其他设备类型可忽略（传 nil）。
 */
@property (nonatomic, copy, nullable) NSString *aiLicense;

/**
 * @brief AI vendor type for Buds device authentication
 * @chinese Buds 设备使用的 AI 方案商类型
 *
 * @discussion
 * [EN]: Specifies which AI solution provider is used by the target Buds device.
 *       Defaults to TSAIVendorUnknown; only required for Buds-type devices.
 * [CN]: 指定目标 Buds 设备使用的 AI 方案商。
 *       默认为 TSAIVendorUnknown，仅 Buds 类设备需要设置。
 */
@property (nonatomic, assign) TSAIVendor aiVendor;

@end

/**
 * @brief Peripheral connection parameters.
 * @chinese 外设连接参数。
 */
@interface TSPeripheralConnectParam : NSObject

/**
 * @brief User ID for device connection
 * @chinese 设备连接的用户ID
 *
 * @discussion
 * [EN]: Required. Identifies the app user that owns or logs in to the device.
 *       Must not be nil or empty.
 * [CN]: 必传。用于标识当前连接、绑定或登录设备的 App 用户。
 *       不能为空。
 */
@property (nonatomic,strong,nonnull) NSString * userId;

/**
 * @brief auth code obtained from QR code scanning during device binding
 * @chinese 设备绑定时通过扫描二维码获得的随机码
 *
 * @discussion
 * [EN]: Required only when binding from QR-code scanning. It can be nil for
 *       search-based connection or already-bound login flows.
 * [CN]: 仅扫码绑定时必传。搜索连接或已绑定设备登录流程可为空。
 */
@property (nonatomic,strong) NSString * authCode;

/**
 * @brief Connection timeout in seconds
 * @chinese 连接超时时间（秒）
 *
 * @discussion
 * [EN]: Maximum duration to wait for this connection (including authentication) to complete.
 *       If 0 or negative, the SDK uses TSDefaultPeripheralConnectTimeout (30 seconds).
 * [CN]: 等待本次连接（含鉴权）完成的最大时长。
 *       为0或负数时，SDK 使用 TSDefaultPeripheralConnectTimeout（30秒）。
 *
 * @note
 * [EN]: Default is TSDefaultPeripheralConnectTimeout (30 seconds).
 * [CN]: 默认值为 TSDefaultPeripheralConnectTimeout（30秒）。
 */
@property (nonatomic,assign) NSInteger connectTimeout;

/**
 * @brief Maximum auto-reconnect attempts after an unexpected disconnection
 * @chinese 异常断开后的最大自动重连次数
 *
 * @discussion
 * [EN]: After an established connection drops unexpectedly, the SDK retries up to this many times.
 *       User-initiated disconnects and permanent errors do not trigger reconnection.
 *       If 0 or negative, the SDK uses TSDefaultPeripheralMaxReconnectCount (5).
 * [CN]: 已建立的连接异常断开后，SDK 最多重连的次数。
 *       用户主动断开与永久性错误不会触发重连。
 *       为0或负数时，SDK 使用 TSDefaultPeripheralMaxReconnectCount（5）。
 *
 * @note
 * [EN]: Default is TSDefaultPeripheralMaxReconnectCount (5).
 * [CN]: 默认值为 TSDefaultPeripheralMaxReconnectCount（5）。
 */
@property (nonatomic,assign) NSInteger maxReconnectCount;

/**
 * @brief Whether the SDK automatically sets the device time after connection
 * @chinese 连接成功后 SDK 是否自动设置设备时间
 *
 * @note
 * [EN]: Defaults to NO. Set to YES explicitly to enable automatic time setting.
 * [CN]: 默认为 NO。调用方需显式设置为 YES 才会自动设置时间。
 */
@property (nonatomic, assign) BOOL shouldAutoSetTime;

/**
 * @brief Whether the SDK automatically sets the device language after connection
 * @chinese 连接成功后 SDK 是否自动设置设备语言
 *
 * @note
 * [EN]: Defaults to NO. Set to YES explicitly to enable automatic language setting.
 * [CN]: 默认为 NO。调用方需显式设置为 YES 才会自动设置语言。
 */
@property (nonatomic, assign) BOOL shouldAutoSetLanguage;


/**
 * @brief Extra parameters used by specific SDK implementations.
 * @chinese 具体 SDK 实现使用的连接补充参数。
 *
 * @discussion
 * [EN]: Optional. Use the concrete extra parameter type required by the target
 *       SDK implementation, such as TSFitConnectExtraParam,
 *       TSNpkConnectExtraParam or TSBudsConnectExtraParam.
 * [CN]: 可选。需要时按目标 SDK 实现传入对应的补充参数类型，例如
 *       TSFitConnectExtraParam、TSNpkConnectExtraParam 或 TSBudsConnectExtraParam。
 */
@property (nonatomic,strong,nullable) TSConnectExtraParam * extraParam;


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

+ (instancetype)paramWithUserId:(NSString *)userId;
+ (instancetype)paramWithUserId:(NSString *)userId authCode:(nullable NSString *)authCode;
+ (instancetype)paramWithUserId:(NSString *)userId
                       authCode:(nullable NSString *)authCode
                     extraParam:(nullable TSConnectExtraParam *)extraParam;

@end

NS_ASSUME_NONNULL_END
