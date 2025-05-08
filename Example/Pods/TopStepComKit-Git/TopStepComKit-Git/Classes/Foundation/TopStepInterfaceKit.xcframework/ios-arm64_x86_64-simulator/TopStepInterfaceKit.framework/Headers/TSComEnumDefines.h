//
//  TopStepComDefines.h
//  Pods
//
//  Created by 磐石 on 2025/1/2.
//
//  文件说明:
//  该文件定义了TopStepComKit中使用的公共枚举类型，包括SDK类型、连接状态、指令状态和错误码等

#ifndef TopStepComDefines_h
#define TopStepComDefines_h

#import <Foundation/Foundation.h>

/**
 * @brief SDK type enumeration
 * @chinese SDK类型枚举
 *
 * @discussion
 * EN: Used to identify different types of SDK modules.
 *     Each type corresponds to a specific hardware platform.
 * CN: 用于标识不同类型的SDK模块。
 *     每种类型对应特定的硬件平台。
 */
typedef NS_ENUM(NSUInteger, TSSDKType) {
    /// 未知类型 (Unknown type)
    eTSSDKTypeUnknow = 0,
    /// 瑞昱SDK (Realtek SDK)
    eTSSDKTypeFit,
    /// 恒玄SDK (BES SDK)
    eTSSDKTypeFw,
    /// 伸聚SDK (SJ SDK)
    eTSSDKTypeSJ,
    /// 魔样SDK (CRP SDK)
    eTSSDKTypeCRP,
    /// 优创意SDK(UTE SDK)
    eTSSDKTypeUTE
};

/**
 * @brief Bluetooth connection state enumeration
 * @chinese 蓝牙连接状态枚举
 *
 * @discussion
 * [EN]: Defines the basic states during Bluetooth connection process.
 *       Used for tracking the current connection status.
 * [CN]: 定义蓝牙连接过程中的基本状态。
 *       用于跟踪当前连接状态。
 */
typedef NS_ENUM(NSUInteger, TSBleConnectionState) {
    /// 未连接 (Not connected)
    eTSBleStateDisconnected = 0,
    /// 连接中 (Connecting)
    eTSBleStateConnecting,
    /// 连接成功 (Connected successfully)
    eTSBleStateConnected
};

/**
 * @brief Bluetooth connection error enumeration
 * @chinese 蓝牙连接错误枚举
 *
 * @discussion
 * [EN]: Defines all possible error conditions during Bluetooth connection.
 *       Used for detailed error handling and user feedback.
 * [CN]: 定义蓝牙连接过程中可能出现的所有错误情况。
 *       用于详细的错误处理和用户反馈。
 */
typedef NS_ENUM(NSUInteger, TSBleConnectionError) {
    /// 无错误 (No error)
    eTSBleErrorNone = 0,
    /// 参数二维码错误
    eTSBleErrorInvalidRandomCode,
    /// 参数用户ID错误
    eTSBleErrorInvalidUserId,

    #pragma mark - General Errors (通用错误)
    /// 未知错误 (Unknown error)
    eTSBleErrorUnknown,
    /// 连接超时 (Connection timeout)
    eTSBleErrorTimeout,
    /// 连接意外断开 (Connection unexpectedly terminated)
    eTSBleErrorDisconnected,

    #pragma mark - Permission & System Errors (权限和系统错误)
    /// 蓝牙未开启 (Bluetooth is not enabled)
    eTSBleErrorBluetoothOff,
    /// 蓝牙不支持 (Bluetooth not supported)
    eTSBleErrorBluetoothUnsupported,
    /// 缺少蓝牙权限 (Missing Bluetooth permission)
    eTSBleErrorPermissionDenied,
    /// 系统蓝牙服务不可用 (System Bluetooth service unavailable)
    eTSBleErrorSystemServiceUnavailable,

    #pragma mark - Connection Process Errors (连接过程错误)
    /// 连接失败 (General connection failure)
    eTSBleErrorConnectionFailed,
    /// GATT连接失败 (GATT connection failed)
    eTSBleErrorGattConnectFailed,
    /// 设备不在范围内 (Device out of range)
    eTSBleErrorDeviceOutOfRange,
    /// 信号太弱 (Signal too weak)
    eTSBleErrorWeakSignal,
    /// 信号丢失 (Signal lost)
    eTSBleErrorSignalLost,

    #pragma mark - Authentication Errors (认证错误)
    /// 绑定失败 (Binding failure)
    eTSBleErrorBindingFailed,
    /// 配对失败 (Pairing failed)
    eTSBleErrorPairingFailed,
    /// 认证失败 (Authentication failed)
    eTSBleErrorAuthenticationFailed,
    /// 加密失败 (Encryption failed)
    eTSBleErrorEncryptionFailed,

    #pragma mark - Device State Errors (设备状态错误)
    /// 设备被其他设备连接 (Device connected by another device)
    eTSBleErrorConnectedByOthers,
    /// 设备已被绑定 (Device already bound)
    eTSBleErrorDeviceAlreadyBound,
    /// 设备电量过低 (Device battery too low)
    eTSBleErrorLowBattery,
    /// 设备进入DFU模式 (Device entered DFU mode)
    eTSBleErrorDFUMode,
    /// 设备处于睡眠模式 (Device in sleep mode)
    eTSBleErrorDeviceSleeping,

    #pragma mark - Service & Protocol Errors (服务和协议错误)
    /// 未找到对应外设
    eTSBleErrorPeripheralNotFound,
    /// 未找到所需服务 (Required service not found)
    eTSBleErrorServiceNotFound,
    /// 特征值未找到 (Characteristic not found)
    eTSBleErrorCharacteristicNotFound,
    /// 协议版本不匹配 (Protocol version mismatch)
    eTSBleErrorProtocolVersionMismatch,
    /// MTU协商失败 (MTU negotiation failed)
    eTSBleErrorMtuNegotiationFailed,

    #pragma mark - User Actions (用户操作)
    /// 用户主动断开连接 (Disconnected by user)
    eTSBleErrorDisconnectedByUser,
    /// 用户取消连接 (Connection cancelled by user)
    eTSBleErrorCancelledByUser
};

/**
 * @brief Command execution state
 * @chinese 指令执行状态
 *
 * @discussion
 * EN: Defines the possible states of command execution.
 *     Used for tracking command sending and result retrieval.
 * CN: 定义指令执行的可能状态。
 *     用于跟踪指令发送和结果获取。
 */
typedef NS_ENUM(NSUInteger, TSCommandState) {
    /// 指令发送成功 (Command sent successfully)
    eTSCommandSendSuccess = 0,
    /// 指令发送失败 (Command sending failed)
    eTSCommandSendFailed,
    /// 指令发送成功并获取结果 (Command sent and result received)
    eTSCommandGetResult
};

/**
 * @brief Error code enumeration
 * @chinese 错误码枚举
 *
 * @discussion
 * EN: Defines all possible error codes in the SDK.
 *     Categorized by error type for better error handling.
 * CN: 定义SDK中所有可能的错误码。
 *     按错误类型分类以便更好地处理错误。
 */
typedef NS_ENUM(NSUInteger, TSErrorCode) {
    #pragma mark - System Errors (系统错误)
    /// 未知错误 (Unknown error)
    eTSErrorUnknown                 = 1001,
    /// SDK初始化失败 (SDK initialization failed)
    eTSErrorSDKInitFailed           = 1002,
    /// SDK证书错误 (SDK license error)
    eTSErrorLicenseIncorrect        = 1003,
    /// SDK配置错误 (SDK configuration error)
    eTSErrorSDKConfigError          = 1004,

    #pragma mark - Device Status Errors (设备状态错误)
    /// 设备未就绪 (Device not ready)
    eTSErrorNotReady                = 2001,
    /// 设备电量过低（小于30%）(Device low battery - below 30%)
    eTSErrorLowBattery              = 2002,
    /// 设备未连接 (Device not connected)
    eTSErrorUnConnected             = 2003,
    /// 暂不支持此功能 (Feature not supported)
    eTSErrorNotSupport              = 2004,

    #pragma mark - Parameter Errors (参数错误)
    /// 参数不存在 (Parameter does not exist)
    eTSErrorInvalidParam            = 3001,
   /// 参数错误（Parameter error）
    eTSErrorParamError              = 3002,
    /// 参数类型错误 (Invalid parameter type)
    eTSErrorInvalidTypeError        = 3003,
    /// 参数大小错误 (Invalid param size)
    eTSErrorParamSizeError          = 3004,

    #pragma mark - Data Operation Errors (数据操作错误)
    /// 数据获取失败 (Data retrieval failed)
    eTSErrorDataGetFailed           = 4001,
    /// 数据设置失败 (Data setting failed)
    eTSErrorDataSettingFailed       = 4002,
    /// 数据格式错误 (Data format error)
    eTSErrorDataFormatError         = 4003,

    #pragma mark - Task Errors (持续性的任务比如：OTA错误)
    /// 任务执行中 (OTA updating)
    eTSErrorPreTaskExecuting        = 5001,
    /// 任务执行失败 (OTA update failed)
    eTSErrorTaskExecutionFailed     = 5002,

    #pragma mark - Communication Errors (通信错误)
    /// 通信超时错误 (Communication timeout)
    eTSErrorTimeoutError            = 6001,
    /// 数据传输中断 (Data transmission interrupted)
    eTSErrorTransmissionInterrupted = 6002,
    /// 信号干扰或丢失 (Signal interference or loss)
    eTSErrorSignalInterference      = 6003,
    /// 数据包丢失 (Packet loss)
    eTSErrorPacketLoss              = 6004,
    /// 通信协议不匹配 (Communication protocol mismatch)
    eTSErrorProtocolMismatch        = 6005,
    /// 连接被对方重置 (Connection reset by peer)
    eTSErrorConnectionReset         = 6006,
    /// 通信缓冲区溢出 (Communication buffer overflow)
    eTSErrorBufferOverflow          = 6007,
    /// 通信通道忙 (Communication channel busy)
    eTSErrorChannelBusy             = 6008
};

#endif /* TopStepComDefines_h */
