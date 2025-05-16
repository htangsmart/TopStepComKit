//
//  TopStepErrorMsgDefines.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/12.
//

#import <Foundation/Foundation.h>
#import "TSComEnumDefines.h"
NS_ASSUME_NONNULL_BEGIN

@interface TopStepErrorMsgDefines : NSObject

#pragma mark - Error Messages
/**
 * @brief Device not supported
 * @chinese 设备不支持
 */
FOUNDATION_EXPORT NSString *const kEMsgNotSupportName;

/**
 * @brief Missing parameter
 * @chinese 参数缺失
 */
FOUNDATION_EXPORT NSString *const kEMsgInvalidParamName;

/**
 * @brief Error parameter
 * @chinese 参数错误
 */
FOUNDATION_EXPORT NSString *const kEMsgParamErrorName;

/**
 * @brief Invalid parameter type
 * @chinese 参数类型错误
 */
FOUNDATION_EXPORT NSString *const kEMsgInvalidParamTypeName;

/**
 * @brief Invalid param size
 * @chinese 参数大小错误
 */
FOUNDATION_EXPORT NSString *const kEMsgParamSizeErrorName;

/**
 * @brief Data retrieval failed
 * @chinese 数据获取失败
 */
FOUNDATION_EXPORT NSString *const kEMsgDataGetFailedName;

/**
 * @brief Command setting failed
 * @chinese 指令设置失败
 */
FOUNDATION_EXPORT NSString *const kEMsgSettingFailedName;

/**
 * @brief Data format error
 * @chinese 数据格式错误
 */
FOUNDATION_EXPORT NSString *const kEMsgDataFormatName;

/**
 * @brief Device not connected
 * @chinese 设备未连接
 */
FOUNDATION_EXPORT NSString *const kEMsgUnConnectedName;

/**
 * @brief Device low power (below 30%)
 * @chinese 设备电量低（小于30%）
 */
FOUNDATION_EXPORT NSString *const kEMsgLowPowerName;

/**
 * @brief Unknown error
 * @chinese 未知错误
 */
FOUNDATION_EXPORT NSString *const kEMsgUnknowName;

/**
 * @brief Task is currently executing
 * @chinese 存在正在执行的任务
 */
FOUNDATION_EXPORT NSString *const kTSErrorPreTaskExecutingName;

/**
 * @brief Command timeout
 * @chinese 超时未处理
 */
FOUNDATION_EXPORT NSString *const kTSErrorTimeoutName;

/**
 * @brief SDK initialization failed
 * @chinese SDK初始化失败
 */
FOUNDATION_EXPORT NSString *const kEMsgSDKInitFailedName;

/**
 * @brief SDK license error
 * @chinese SDK证书错误
 */
FOUNDATION_EXPORT NSString *const kEMsgLicenseIncorrectName;

/**
 * @brief SDK configuration error
 * @chinese SDK配置错误
 */
FOUNDATION_EXPORT NSString *const kEMsgSDKConfigErrorName;

/**
 * @brief Device not ready
 * @chinese 设备未就绪
 */
FOUNDATION_EXPORT NSString *const kEMsgNotReadyName;

/**
 * @brief Data setting failed
 * @chinese 数据设置失败
 */
FOUNDATION_EXPORT NSString *const kEMsgDataSettingFailedName;

/**
 * @brief Task execution failed
 * @chinese 任务执行失败
 */
FOUNDATION_EXPORT NSString *const kEMsgTaskExecutionFailedName;

/**
 * @brief Data transmission interrupted
 * @chinese 数据传输中断
 */
FOUNDATION_EXPORT NSString *const kEMsgTransmissionInterruptedName;

/**
 * @brief Signal interference or loss
 * @chinese 信号干扰或丢失
 */
FOUNDATION_EXPORT NSString *const kEMsgSignalInterferenceName;

/**
 * @brief Packet loss
 * @chinese 数据包丢失
 */
FOUNDATION_EXPORT NSString *const kEMsgPacketLossName;

/**
 * @brief Communication protocol mismatch
 * @chinese 通信协议不匹配
 */
FOUNDATION_EXPORT NSString *const kEMsgProtocolMismatchName;

/**
 * @brief Connection reset by peer
 * @chinese 连接被对方重置
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionResetName;

/**
 * @brief Communication buffer overflow
 * @chinese 通信缓冲区溢出
 */
FOUNDATION_EXPORT NSString *const kEMsgBufferOverflowName;

/**
 * @brief Communication channel busy
 * @chinese 通信通道忙
 */
FOUNDATION_EXPORT NSString *const kEMsgChannelBusyName;

/**
 * @brief No error
 * @chinese 无错误
 */
FOUNDATION_EXPORT NSString *const kEMsgNoneName;

/**
 * @brief Invalid random code
 * @chinese 参数二维码错误
 */
FOUNDATION_EXPORT NSString *const kEMsgInvalidRandomCodeName;

/**
 * @brief Invalid user ID
 * @chinese 参数用户ID错误
 */
FOUNDATION_EXPORT NSString *const kEMsgInvalidUserIdName;

/**
 * @brief Connection unexpectedly terminated
 * @chinese 连接意外断开
 */
FOUNDATION_EXPORT NSString *const kEMsgDisconnectedName;

/**
 * @brief Bluetooth is not enabled
 * @chinese 蓝牙未开启
 */
FOUNDATION_EXPORT NSString *const kEMsgBluetoothOffName;

/**
 * @brief Bluetooth not supported
 * @chinese 蓝牙不支持
 */
FOUNDATION_EXPORT NSString *const kEMsgBluetoothUnsupportedName;

/**
 * @brief Missing Bluetooth permission
 * @chinese 缺少蓝牙权限
 */
FOUNDATION_EXPORT NSString *const kEMsgPermissionDeniedName;

/**
 * @brief System Bluetooth service unavailable
 * @chinese 系统蓝牙服务不可用
 */
FOUNDATION_EXPORT NSString *const kEMsgSystemServiceUnavailableName;

/**
 * @brief General connection failure
 * @chinese 连接失败
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionFailedName;

/**
 * @brief GATT connection failed
 * @chinese GATT连接失败
 */
FOUNDATION_EXPORT NSString *const kEMsgGattConnectFailedName;

/**
 * @brief Device out of range
 * @chinese 设备不在范围内
 */
FOUNDATION_EXPORT NSString *const kEMsgDeviceOutOfRangeName;

/**
 * @brief Signal too weak
 * @chinese 信号太弱
 */
FOUNDATION_EXPORT NSString *const kEMsgWeakSignalName;

/**
 * @brief Signal lost
 * @chinese 信号丢失
 */
FOUNDATION_EXPORT NSString *const kEMsgSignalLostName;

/**
 * @brief Binding failure
 * @chinese 绑定失败
 */
FOUNDATION_EXPORT NSString *const kEMsgBindingFailedName;

/**
 * @brief Pairing failed
 * @chinese 配对失败
 */
FOUNDATION_EXPORT NSString *const kEMsgPairingFailedName;

/**
 * @brief Authentication failed
 * @chinese 认证失败
 */
FOUNDATION_EXPORT NSString *const kEMsgAuthenticationFailedName;

/**
 * @brief Encryption failed
 * @chinese 加密失败
 */
FOUNDATION_EXPORT NSString *const kEMsgEncryptionFailedName;

/**
 * @brief Device connected by another device
 * @chinese 设备被其他设备连接
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectedByOthersName;

/**
 * @brief Device already bound
 * @chinese 设备已被绑定
 */
FOUNDATION_EXPORT NSString *const kEMsgDeviceAlreadyBoundName;

/**
 * @brief Device entered DFU mode
 * @chinese 设备进入DFU模式
 */
FOUNDATION_EXPORT NSString *const kEMsgDFUModeName;

/**
 * @brief Device in sleep mode
 * @chinese 设备处于睡眠模式
 */
FOUNDATION_EXPORT NSString *const kEMsgDeviceSleepingName;

/**
 * @brief Peripheral not found
 * @chinese 未找到对应外设
 */
FOUNDATION_EXPORT NSString *const kEMsgPeripheralNotFoundName;

/**
 * @brief Required service not found
 * @chinese 未找到所需服务
 */
FOUNDATION_EXPORT NSString *const kEMsgServiceNotFoundName;

/**
 * @brief Characteristic not found
 * @chinese 特征值未找到
 */
FOUNDATION_EXPORT NSString *const kEMsgCharacteristicNotFoundName;

/**
 * @brief Protocol version mismatch
 * @chinese 协议版本不匹配
 */
FOUNDATION_EXPORT NSString *const kEMsgProtocolVersionMismatchName;

/**
 * @brief MTU negotiation failed
 * @chinese MTU协商失败
 */
FOUNDATION_EXPORT NSString *const kEMsgMtuNegotiationFailedName;

/**
 * @brief Disconnected by user
 * @chinese 用户主动断开连接
 */
FOUNDATION_EXPORT NSString *const kEMsgDisconnectedByUserName;

/**
 * @brief Connection cancelled by user
 * @chinese 用户取消连接
 */
FOUNDATION_EXPORT NSString *const kEMsgCancelledByUserName;

/**
 * @brief Connection cancelled by user
 * @chinese 用户取消连接
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionCancelledName;

/**
 * @brief Connection timeout
 * @chinese 连接超时
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionTimeoutName;

/**
 * @brief Connection rejected
 * @chinese 连接被拒绝
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionRejectedName;

/**
 * @brief Connection already exists
 * @chinese 连接已存在
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionAlreadyExistsName;

/**
 * @brief Connection limit reached
 * @chinese 达到连接上限
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionLimitReachedName;

/**
 * @brief Connection not allowed
 * @chinese 不允许连接
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotAllowedName;

/**
 * @brief Connection not authorized
 * @chinese 连接未授权
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotAuthorizedName;

/**
 * @brief Connection not ready
 * @chinese 连接未就绪
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotReadyName;

/**
 * @brief Connection not supported
 * @chinese 连接不支持
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotSupportedName;

/**
 * @brief Connection not valid
 * @chinese 连接无效
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotValidName;

/**
 * @brief Connection not available
 * @chinese 连接不可用
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotAvailableName;

/**
 * @brief Connection not enabled
 * @chinese 连接未启用
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotEnabledName;

/**
 * @brief Connection not initialized
 * @chinese 连接未初始化
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotInitializedName;

/**
 * @brief Connection not configured
 * @chinese 连接未配置
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotConfiguredName;

/**
 * @brief Connection not authenticated
 * @chinese 连接未认证
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotAuthenticatedName;

/**
 * @brief Connection not encrypted
 * @chinese 连接未加密
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotEncryptedName;

/**
 * @brief Connection not paired
 * @chinese 连接未配对
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotPairedName;

/**
 * @brief Connection not bound
 * @chinese 连接未绑定
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotBoundName;

/**
 * @brief Connection not discovered
 * @chinese 连接未发现
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotDiscoveredName;

/**
 * @brief Connection not scanned
 * @chinese 连接未扫描
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotScannedName;

/**
 * @brief Connection not advertised
 * @chinese 连接未广播
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotAdvertisedName;

/**
 * @brief Connection not connected
 * @chinese 连接未连接
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotConnectedName;

/**
 * @brief Connection not disconnected
 * @chinese 连接未断开
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotDisconnectedName;

/**
 * @brief Connection not reconnected
 * @chinese 连接未重连
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotReconnectedName;

/**
 * @brief Connection not updated
 * @chinese 连接未更新
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotUpdatedName;

/**
 * @brief Connection not changed
 * @chinese 连接未改变
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotChangedName;

/**
 * @brief Connection not modified
 * @chinese 连接未修改
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotModifiedName;

/**
 * @brief Connection not created
 * @chinese 连接未创建
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotCreatedName;

/**
 * @brief Connection not destroyed
 * @chinese 连接未销毁
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotDestroyedName;

/**
 * @brief Connection not started
 * @chinese 连接未开始
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotStartedName;

/**
 * @brief Connection not stopped
 * @chinese 连接未停止
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotStoppedName;

/**
 * @brief Connection not paused
 * @chinese 连接未暂停
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotPausedName;

/**
 * @brief Connection not resumed
 * @chinese 连接未恢复
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotResumedName;

/**
 * @brief Connection not cancelled
 * @chinese 连接未取消
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotCancelledName;

/**
 * @brief Connection not rejected
 * @chinese 连接未拒绝
 */
FOUNDATION_EXPORT NSString *const kEMsgConnectionNotRejectedName;

/**
 * @brief Get error message string for TSBleConnectionError
 * @chinese 获取蓝牙连接错误对应的错误信息字符串
 *
 * @param errorCode 
 * EN: TSBleConnectionError enum value
 * CN: 蓝牙连接错误枚举值
 *
 * @return 
 * EN: Error message string corresponding to the error code
 * CN: 对应错误码的错误信息字符串
 */
+ (NSString *)errorMsgForBleErCode:(TSBleConnectionError)errorCode;

/**
 * @brief Get error message string for TSErrorCode
 * @chinese 获取错误码对应的错误信息字符串
 *
 * @param errorCode 
 * EN: TSErrorCode enum value
 * CN: 错误码枚举值
 *
 * @return 
 * EN: Error message string corresponding to the error code
 * CN: 对应错误码的错误信息字符串
 */
+ (NSString *)errorMsgForCode:(TSErrorCode)errorCode;

@end

NS_ASSUME_NONNULL_END
