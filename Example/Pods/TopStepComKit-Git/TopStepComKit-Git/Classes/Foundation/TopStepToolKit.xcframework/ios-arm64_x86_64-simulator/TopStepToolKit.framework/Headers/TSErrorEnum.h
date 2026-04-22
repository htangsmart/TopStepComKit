//
//  TSErrorEnum.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/8/17.
//

#ifndef TSErrorEnum_h
#define TSErrorEnum_h

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
    /// 设备空间不足（Device has no space）
    eTSErrorNoSpace                 = 2005,
    /// 设备繁忙（Device is busy）
    eTSErrorIsBusy                  = 2006,


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
    /// 数据为空 （Data is empty）
    eTSErrorDataIsEmpty             = 4004,

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
    eTSErrorChannelBusy             = 6008,

    #pragma mark - User Operation Errors (用户操作错误)
    /// 用户取消操作 (User cancelled operation)
    eTSErrorUserCancelled           = 7001
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
    eTSBleErrorNone                         = 0,
    
    #pragma mark - Parameter Errors (参数错误 9001-9099)
    /// 参数二维码错误 (Invalid random code parameter)
    eTSBleErrorInvalidRandomCode            = 9001,
    /// 参数用户ID错误 (Invalid user ID parameter)
    eTSBleErrorInvalidUserId                = 9002,
    /// 参数错误 (Invalid parameter)
    eTSBleErrorInvalidParam                 = 9003,
    /// 无效句柄 (Invalid handle)
    eTSBleErrorInvalidHandle                = 9004,

    #pragma mark - General Errors (通用错误 9101-9199)
    /// 未知错误 (Unknown error)
    eTSBleErrorUnknown                      = 9101,
    /// 连接超时 (Connection timeout)
    eTSBleErrorTimeout                      = 9102,
    /// 连接意外断开 (Connection unexpectedly terminated)
    eTSBleErrorDisconnected                 = 9103,
    /// 存储空间不足 (Out of space)
    eTSBleErrorOutOfSpace                   = 9104,
    /// UUID不被允许 (UUID not allowed)
    eTSBleErrorUUIDNotAllowed               = 9105,
    /// 已在广播 (Already advertising)
    eTSBleErrorAlreadyAdvertising           = 9106,

    #pragma mark - Permission & System Errors (权限和系统错误 9201-9299)
    /// 蓝牙未开启 (Bluetooth is not enabled)
    eTSBleErrorBluetoothOff                 = 9201,
    /// 蓝牙不支持 (Bluetooth not supported)
    eTSBleErrorBluetoothUnsupported         = 9202,
    /// 缺少蓝牙权限 (Missing Bluetooth permission)
    eTSBleErrorPermissionDenied             = 9203,
    /// 系统蓝牙服务不可用 (System Bluetooth service unavailable)
    eTSBleErrorSystemServiceUnavailable     = 9204,
    /// 蓝牙状态未知 (Bluetooth state unknown)
    eTSBleErrorBluetoothStateUnknown        = 9205,
    /// 蓝牙正在重置 (Bluetooth is resetting)
    eTSBleErrorBluetoothResetting           = 9206,

    #pragma mark - Connection Process Errors (连接过程错误 9301-9399)
    /// 连接失败 (General connection failure)
    eTSBleErrorConnectionFailed             = 9301,
    /// GATT连接失败 (GATT connection failed)
    eTSBleErrorGattConnectFailed            = 9302,
    /// 设备不在范围内 (Device out of range)
    eTSBleErrorDeviceOutOfRange             = 9303,
    /// 信号太弱 (Signal too weak)
    eTSBleErrorWeakSignal                   = 9304,
    /// 信号丢失 (Signal lost)
    eTSBleErrorSignalLost                   = 9305,
    /// 连接数达到限制 (Connection limit reached)
    eTSBleErrorConnectionLimitReached       = 9306,
    /// 未知设备 (Unknown device)
    eTSBleErrorUnknownDevice                = 9307,
    /// 操作不支持 (Operation not supported)
    eTSBleErrorOperationNotSupported        = 9308,

    #pragma mark - Authentication Errors (认证错误 9401-9499)
    /// 加密失败 (Encryption failed)
    eTSBleErrorEncryptionFailed             = 9404,
    /// 配对信息被移除 (Peer removed pairing information)
    eTSBleErrorPeerRemovedPairingInfo       = 9405,
    /// 加密超时 (Encryption timed out)
    eTSBleErrorEncryptionTimeout            = 9406,
    /// 用户ID不匹配 (User ID mismatch)
    eTSBleErrorUserIdMismatch               = 9407,
    /// 用户取消绑定 (User cancelled binding)
    eTSBleErrorBindCancelledByUser          = 9408,
    /// 绑定超时 (Bind timeout)
    eTSBleErrorBindTimeout                  = 9409,
    /// 经典蓝牙未连接 (Classic BT not connected)
    eTSBleErrorClassicBluetoothNotConnected = 9410,
    /// 电量不足无法删除数据 (Low battery, cannot delete data)
    eTSBleErrorLowBatteryCannotDeleteData   = 9411,
    /// 设备正在恢复出厂 (Device factory resetting)
    eTSBleErrorDeviceFactoryResetting       = 9412,
    /// 需要恢复出厂才能重新绑定 (Factory reset required)
    eTSBleErrorFactoryResetRequired         = 9413,
    /// 认证失败未知原因 (Auth failed unknown)
    eTSBleErrorAuthenticationUnknown        = 9499,

    #pragma mark - Device State Errors (设备状态错误 9501-9599)
    /// 设备被其他设备连接 (Device connected by another device)
    eTSBleErrorConnectedByOthers            = 9501,
    /// 设备已被绑定 (Device already bound)
    eTSBleErrorDeviceAlreadyBound           = 9502,
    /// 设备电量过低 (Device battery too low)
    eTSBleErrorLowBattery                   = 9503,
    /// 设备进入DFU模式 (Device entered DFU mode)
    eTSBleErrorDFUMode                      = 9504,
    /// 设备处于睡眠模式 (Device in sleep mode)
    eTSBleErrorDeviceSleeping               = 9505,
    /// 配对设备过多 (Too many paired devices)
    eTSBleErrorTooManyPairedDevices         = 9506,

    #pragma mark - Service & Protocol Errors (服务和协议错误 9601-9699)
    /// 未找到对应外设 (Peripheral not found)
    eTSBleErrorPeripheralNotFound           = 9601,
    /// 未找到所需服务 (Required service not found)
    eTSBleErrorServiceNotFound              = 9602,
    /// 特征值未找到 (Characteristic not found)
    eTSBleErrorCharacteristicNotFound       = 9603,
    /// 协议版本不匹配 (Protocol version mismatch)
    eTSBleErrorProtocolVersionMismatch      = 9604,
    /// MTU协商失败 (MTU negotiation failed)
    eTSBleErrorMtuNegotiationFailed         = 9605,

    #pragma mark - User Actions (用户操作 9701-9799)
    /// 用户主动断开连接 (Disconnected by user)
    eTSBleErrorDisconnectedByUser           = 9701,
    /// 用户取消连接 (Connection cancelled by user)
    eTSBleErrorCancelledByUser              = 9702
};


#endif /* TSErrorEnum_h */
