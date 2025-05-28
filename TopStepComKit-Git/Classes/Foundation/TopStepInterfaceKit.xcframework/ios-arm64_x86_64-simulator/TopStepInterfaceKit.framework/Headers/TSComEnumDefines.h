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
 * [EN]: Used to identify different types of SDK modules.
 *      Each type corresponds to a specific hardware platform.
 * [CN]: 用于标识不同类型的SDK模块。
 *      每种类型对应特定的硬件平台。
 */
typedef NS_ENUM(NSUInteger, TSSDKType) {
    /// 未知类型 （Unknown type）
    eTSSDKTypeUnknow = 0,
    /// 瑞昱SDK （Realtek SDK）
    eTSSDKTypeFit,
    /// 恒玄SDK （BES SDK）
    eTSSDKTypeFw,
    /// 伸聚SDK （SJ SDK）
    eTSSDKTypeSJ,
    /// 魔样SDK （CRP SDK）
    eTSSDKTypeCRP,
    /// 优创意SDK （UTE SDK）
    eTSSDKTypeUTE
};

/**
 * @brief Bluetooth connection state enumeration
 * @chinese 蓝牙连接状态枚举
 *
 * @discussion
 * [EN]: Defines the basic states during Bluetooth connection process.
 *      Used for tracking the current connection status.
 * [CN]: 定义蓝牙连接过程中的基本状态。
 *      用于跟踪当前连接状态。
 */
typedef NS_ENUM(NSUInteger, TSBleConnectionState) {
    /// 未连接 （Not connected）
    eTSBleStateDisconnected = 0,
    /// 连接中 （Connecting）
    eTSBleStateConnecting,
    /// 连接成功 （Connected successfully）
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
 * [EN]: Defines the possible states of command execution.
 *      Used for tracking command sending and result retrieval.
 * [CN]: 定义指令执行的可能状态。
 *      用于跟踪指令发送和结果获取。
 */
typedef NS_ENUM(NSUInteger, TSCommandState) {
    /// 指令发送成功 （Command sent successfully）
    eTSCommandSendSuccess = 0,
    /// 指令发送失败 （Command sending failed）
    eTSCommandSendFailed,
    /// 指令发送成功并获取结果 （Command sent and result received）
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


/**
 * @brief Supported language types
 * @chinese 支持的语言类型
 *
 * @discussion
 * [EN]: Defines all supported language types in the system.
 *      Used for language switching and localization.
 * [CN]: 定义系统中所有支持的语言类型。
 *      用于语言切换和本地化。
 */
typedef NS_ENUM(NSInteger, TSLanguageType) {
    /// 未设置 （Not set）
    TSLanguage_UNKNOW             = 0,
    /// 简体中文 （Simplified Chinese）
    TSLanguage_CHINESESIMPLIFIED  = 1,
    /// 繁体中文 （Traditional Chinese）
    TSLanguage_CHINESETRADITIONAL = 2,
    /// 英语 （English）
    TSLanguage_ENGLISH            = 3,
    /// 德语 （German）
    TSLanguage_GERMAN             = 4,
    /// 俄语 （Russian）
    TSLanguage_RUSSIAN            = 5,
    /// 西班牙语 （Spanish）
    TSLanguage_SPANISH            = 6,
    /// 葡萄牙语 （Portuguese）
    TSLanguage_PORTUGUESE         = 7,
    /// 法语 （French）
    TSLanguage_FRENCH             = 8,
    /// 日语 （Japanese）
    TSLanguage_JAPANESE           = 9,
    /// 阿拉伯语 （Arabic）
    TSLanguage_ARABIC             = 10,
    /// 荷兰语 （Dutch）
    TSLanguage_DUTCH              = 11,
    /// 意大利语 （Italian）
    TSLanguage_ITALIAN            = 12,
    /// 孟加拉语 （Bengali）
    TSLanguage_BENGALI            = 13,
    /// 克罗地亚语 （Croatian）
    TSLanguage_CROATIAN           = 14,
    /// 捷克语 （Czech）
    TSLanguage_CZECH              = 15,
    /// 丹麦语 （Danish）
    TSLanguage_DANISH             = 16,
    /// 希腊语 （Greek）
    TSLanguage_GREEK              = 17,
    /// 希伯来语 （Hebrew）
    TSLanguage_HEBREW             = 18,
    /// 印度语 （Hindi）
    TSLanguage_HINDI              = 19,
    /// 匈牙利语 （Hungarian）
    TSLanguage_HUN                = 20,
    /// 印度尼西亚语 （Indonesian）
    TSLanguage_INDONESIAN         = 21,
    /// 韩语 （Korean）
    TSLanguage_KOREAN             = 22,
    /// 马来语 （Malay）
    TSLanguage_MALAY              = 23,
    /// 波斯语 （Persian）
    TSLanguage_PERSIAN            = 24,
    /// 波兰语 （Polish）
    TSLanguage_POLISH             = 25,
    /// 罗马尼亚语 （Romanian）
    TSLanguage_RUMANIAN           = 26,
    /// 塞尔维亚语 （Serbian）
    TSLanguage_SERB               = 27,
    /// 瑞典语 （Swedish）
    TSLanguage_SWEDISH            = 28,
    /// 泰语 （Thai）
    TSLanguage_THAI               = 29,
    /// 土耳其语 （Turkish）
    TSLanguage_TURKISH            = 30,
    /// 乌尔都语 （Urdu）
    TSLanguage_URDU               = 31,
    /// 越南语 （Vietnamese）
    TSLanguage_VIETNAMESE         = 32,
    /// 加泰隆语 （Catalan）
    TSLanguage_CATALAN            = 33,
    /// 拉脱维亚语 （Latvian）
    TSLanguage_LATVIAN            = 34,
    /// 立陶宛语 （Lithuanian）
    TSLanguage_LITHUANIAN         = 35,
    /// 挪威语 （Norwegian）
    TSLanguage_NORWEGIAN          = 36,
    /// 斯洛伐克语 （Slovak）
    TSLanguage_SLOVAK             = 37,
    /// 斯洛文尼亚语 （Slovenian）
    TSLanguage_SLOVENIAN          = 38,
    /// 保加利亚语 （Bulgarian）
    TSLanguage_BULGARIAN          = 39,
    /// 乌克兰语 （Ukrainian）
    TSLanguage_UKRAINIAN          = 40,
    /// 菲律宾语 （Filipino）
    TSLanguage_FILIPINO           = 41,
    /// 芬兰语 （Finnish）
    TSLanguage_FINNISH            = 42,
    /// 南非语 （South African）
    TSLanguage_SOUTHAFRICAN       = 43,
    /// 罗曼什语 （Romansh）
    TSLanguage_ROMANSH            = 44,
    /// 缅甸语 （Burmese）
    TSLanguage_BURMESE            = 45,
    /// 柬埔寨语 （Cambodian）
    TSLanguage_CAMBODIAN          = 46,
    /// 阿姆哈拉语 （Amharic）
    TSLanguage_AMHARIC            = 47,
    /// 白俄罗斯语 （Belarusian）
    TSLanguage_BELARUSIAN         = 48,
    /// 爱沙尼亚语 （Estonian）
    TSLanguage_ESTONIAN           = 49,
    /// 斯瓦希里语 （Swahili）
    TSLanguage_SWAHILI            = 50,
    /// 祖鲁语 （Zulu）
    TSLanguage_ZULU               = 51,
    /// 阿塞拜疆语 （Azerbaijani）
    TSLanguage_AZERBAIJANI        = 52,
    /// 亚美尼亚语 （Armenian）
    TSLanguage_ARMENIAN           = 53,
    /// 格鲁吉亚语 （Georgian）
    TSLanguage_GEORGIAN           = 54,
    /// 老挝语 （Lao）
    TSLanguage_LAO                = 55,
    /// 蒙古语 （Mongolian）
    TSLanguage_MONGOLIAN          = 56,
    /// 尼泊尔语 （Nepali）
    TSLanguage_NEPALI             = 57,
    /// 哈萨克语 （Kazakh）
    TSLanguage_KAZAKH             = 58,
    /// 加利西亚语 （Galician）
    TSLanguage_GALICIAN           = 59,
    /// 冰岛语 （Icelandic）
    TSLanguage_ICELANDIC          = 60,
    /// 卡纳达语 （Kannada）
    TSLanguage_KANNADA            = 61,
    /// 吉尔吉斯语 （Kyrgyz）
    TSLanguage_KYRGYZ             = 62,
    /// 马拉雅拉姆语 （Malayalam）
    TSLanguage_MALAYALAM          = 63,
    /// 马拉提语 （Marathi）
    TSLanguage_MARATHI            = 64,
    /// 泰米尔语 （Tamil）
    TSLanguage_TAMIL              = 65,
    /// 马其顿语 （Macedonian）
    TSLanguage_MACEDONIAN         = 66,
    /// 泰卢固语 （Telugu）
    TSLanguage_TELUGU             = 67,
    /// 乌兹别克语 （Uzbek）
    TSLanguage_UZBEK              = 68,
    /// 巴斯克语 （Basque）
    TSLanguage_BASQUE             = 69,
    /// 僧伽罗语 （Sinhala）
    TSLanguage_BERBER             = 70,
    /// 阿尔巴尼亚语 （Albanian）
    TSLanguage_ALBANIAN           = 71
};


/**
 * @brief Message notification types supported by the device
 * @chinese 设备支持的消息通知类型
 *
 * @discussion
 * [EN]: Defines all possible message notification types that can be supported by the device.
 *      Each type represents a specific notification category.
 * [CN]: 定义设备可能支持的所有消息通知类型。
 *      每种类型代表特定的通知类别。
 */
typedef NS_ENUM(NSInteger, TSMessageType) {
    /// 总数 （Total number of message types）
    TSMessage_Total               = 0,
    /// 电话 （Phone call notifications）
    TSMessage_Phone               = 1,
    /// 短信 （SMS notifications）
    TSMessage_Messages            = 2,
    /// 微信 （WeChat notifications）
    TSMessage_WeChat              = 3,
    /// QQ （QQ notifications）
    TSMessage_QQ                  = 4,
    /// Facebook （Facebook notifications）
    TSMessage_Facebook            = 5,
    /// 推特 （Twitter notifications）
    TSMessage_Twitter             = 6,
    /// Instagram （Instagram notifications）
    TSMessage_Instagram           = 7,
    /// Skype （Skype notifications）
    TSMessage_Skype               = 8,
    /// WhatsApp （WhatsApp notifications）
    TSMessage_WhatsApp            = 9,
    /// Line （Line notifications）
    TSMessage_Line                = 10,
    /// KakaoTalk （KakaoTalk notifications）
    TSMessage_KakaoTalk           = 11,
    /// 邮件 （Email notifications）
    TSMessage_Email               = 12,
    /// Messenger （Facebook Messenger notifications）
    TSMessage_Messenger           = 13,
    /// Zalo （Zalo notifications）
    TSMessage_Zalo                = 14,
    /// Telegram （Telegram notifications）
    TSMessage_Telegram            = 15,
    /// Viber （Viber notifications）
    TSMessage_Viber               = 16,
    /// NateOn （NateOn notifications）
    TSMessage_NateOn              = 17,
    /// Gmail （Gmail notifications）
    TSMessage_Gmail               = 18,
    /// 日历 （Calendar notifications）
    TSMessage_Calendar            = 19,
    /// DailyHunt （DailyHunt notifications）
    TSMessage_DailyHunt           = 20,
    /// Outlook （Outlook notifications）
    TSMessage_Outlook             = 21,
    /// Yahoo （Yahoo notifications）
    TSMessage_Yahoo               = 22,
    /// Inshorts （Inshorts notifications）
    TSMessage_Inshorts            = 23,
    /// Phonepe （Phonepe notifications）
    TSMessage_Phonepe             = 24,
    /// Google Pay （Google Pay notifications）
    TSMessage_Gpay                = 25,
    /// Paytm （Paytm notifications）
    TSMessage_Paytm               = 26,
    /// Swiggy （Swiggy notifications）
    TSMessage_Swiggy              = 27,
    /// Zomato （Zomato notifications）
    TSMessage_Zomato              = 28,
    /// Uber （Uber notifications）
    TSMessage_Uber                = 29,
    /// Ola （Ola notifications）
    TSMessage_Ola                 = 30,
    /// ReflexApp （ReflexApp notifications）
    TSMessage_ReflexApp           = 31,
    /// Snapchat （Snapchat notifications）
    TSMessage_Snapchat            = 32,
    /// YouTube Music （YouTube Music notifications）
    TSMessage_YtMusic             = 33,
    /// YouTube （YouTube notifications）
    TSMessage_YouTube             = 34,
    /// LinkedIn （LinkedIn notifications）
    TSMessage_LinkEdin            = 35,
    /// Amazon （Amazon notifications）
    TSMessage_Amazon              = 36,
    /// Flipkart （Flipkart notifications）
    TSMessage_Flipkart            = 37,
    /// Netflix （Netflix notifications）
    TSMessage_NetFlix             = 38,
    /// Hotstar （Hotstar notifications）
    TSMessage_Hotstar             = 39,
    /// Amazon Prime （Amazon Prime notifications）
    TSMessage_AmazonPrime         = 40,
    /// Google Chat （Google Chat notifications）
    TSMessage_GoogleChat          = 41,
    /// Wynk （Wynk notifications）
    TSMessage_Wynk                = 42,
    /// Google Drive （Google Drive notifications）
    TSMessage_GoogleDrive         = 43,
    /// Dunzo （Dunzo notifications）
    TSMessage_Dunzo               = 44,
    /// Gaana （Gaana notifications）
    TSMessage_Gaana               = 45,
    /// 未接来电 （Missed call notifications）
    TSMessage_MissCall            = 46,
    /// WhatsApp Business （WhatsApp Business notifications）
    TSMessage_WhatsAppBusiness    = 47,
    /// 钉钉 （Dingtalk notifications）
    TSMessage_Dingtalk            = 48,
    /// TikTok （TikTok notifications）
    TSMessage_Tiktok              = 49,
    /// Lyft （Lyft notifications）
    TSMessage_Lyft                = 50,
    /// Google Maps （Google Maps notifications）
    TSMessage_GoogleMaps          = 51,
    /// Slack （Slack notifications）
    TSMessage_Slack               = 52,
    /// Microsoft Teams （Microsoft Teams notifications）
    TSMessage_MicrosoftTeams      = 53,
    /// Mormaii Smartwatches （Mormaii Smartwatches notifications）
    TSMessage_MormaiiSmartwatches = 54,
    /// Reddit （Reddit notifications）
    TSMessage_Reddit              = 55,
    /// Discord （Discord notifications）
    TSMessage_Discord             = 56,
    /// Gojek （Gojek notifications）
    TSMessage_Gojek               = 57,
    /// 飞书 （Lark notifications）
    TSMessage_Lark                = 58,
    /// Garb （Garb notifications）
    TSMessage_Garb                = 59,
    /// Shopee （Shopee notifications）
    TSMessage_Shopee              = 60,
    /// Tokopedia （Tokopedia notifications）
    TSMessage_Tokopedia           = 61,
    /// Hinge通知 （Hinge notifications）
    TSMessage_Hinge               = 62,
    /// Myntra通知 （Myntra notifications）
    TSMessage_Myntra              = 63,
    /// Meesho通知 （Meesho notifications）
    TSMessage_Meesho              = 64,
    /// Zivame通知 （Zivame notifications）
    TSMessage_Zivame              = 65,
    /// Ajio通知 （Ajio notifications）
    TSMessage_Ajio                = 66,
    /// Urbanic通知 （Urbanic notifications）
    TSMessage_Urbanic             = 67,
    /// Nykaa通知 （Nykaa notifications）
    TSMessage_Nykaa               = 68,
    /// Healthifyme通知 （Healthifyme notifications）
    TSMessage_Healthifyme         = 69,
    /// Cultfit通知 （Cultfit notifications）
    TSMessage_Cultfit             = 70,
    /// Flo通知 （Flo notifications）
    TSMessage_Flo                 = 71,
    /// Bumble通知 （Bumble notifications）
    TSMessage_Bumble              = 72,
    /// Tira通知 （Tira notifications）
    TSMessage_Tira                = 73,
    /// Hike通知 （Hike notifications）
    TSMessage_Hike                = 74,
    /// Apple Music通知 （Apple Music notifications）
    TSMessage_AppleMusic          = 75,
    /// Zoom通知 （Zoom notifications）
    TSMessage_Zoom                = 76,
    /// Fastrack通知 （Fastrack notifications）
    TSMessage_Fastrack            = 77,
    /// Titan Smart World通知 （Titan Smart World notifications）
    TSMessage_TitanSmartWorld     = 78,
    /// Pinterest通知 （Pinterest notifications）
    TSMessage_Pinterest           = 79,
    /// 支付宝通知 （Alipay notifications）
    TSMessage_Alipay              = 80,
    /// FaceTime通知 （FaceTime notifications）
    TSMessage_FaceTime            = 81,
    /// Hangouts通知 （Hangouts notifications）
    TSMessage_Hangouts            = 82,
    /// VK通知 （VK notifications）
    TSMessage_VK                  = 83,
    /// 微博通知 （Weibo notifications）
    TSMessage_Weibo               = 84,
    /// 其他APP通知 （Other app notifications）
    TSMessage_Other               = 85
};


/**
 * @brief Unit system type
 * @chinese 单位系统类型
 *
 * @discussion
 * EN: Defines the overall unit system for measurements, primarily affecting length and weight units.
 * CN: 定义测量数据的整体单位系统，主要影响长度和重量单位。
 */
typedef NS_ENUM(NSInteger, TSUnitSystem) {
    /**
     * @brief Metric unit system
     * @chinese 公制单位系统
     */
    TSUnitSystemMetric = 0,
    /**
     * @brief Imperial unit system
     * @chinese 英制单位系统
     */
    TSUnitSystemImperial
};

/**
 * @brief Length unit type
 * @chinese 长度单位类型
 */
typedef NS_ENUM(NSInteger, TSLengthUnit) {
    /**
     * @brief Metric (kilometer/meter)
     * @chinese 公制（千米/米）
     */
    TSLengthUnitMetric = 0,
    /**
     * @brief Imperial (mile/foot)
     * @chinese 英制（英里/英尺）
     */
    TSLengthUnitImperial
};

/**
 * @brief Temperature unit type
 * @chinese 温度单位类型
 */
typedef NS_ENUM(NSInteger, TSTemperatureUnit) {
    /**
     * @brief Celsius
     * @chinese 摄氏度
     */
    TSTemperatureUnitCelsius = 0,
    /**
     * @brief Fahrenheit
     * @chinese 华氏度
     */
    TSTemperatureUnitFahrenheit
};

/**
 * @brief Weight unit type
 * @chinese 重量单位类型
 */
typedef NS_ENUM(NSInteger, TSWeightUnit) {
    /**
     * @brief Kilogram
     * @chinese 千克
     */
    TSWeightUnitKG = 0,
    /**
     * @brief Pound
     * @chinese 磅
     */
    TSWeightUnitLB
};

/**
 * @brief Time format type
 * @chinese 时间格式类型
 */
typedef NS_ENUM(NSInteger, TSTimeFormat) {
    /**
     * @brief 12-hour format
     * @chinese 12小时制
     */
    TSTimeFormat12Hour = 0,
    /**
     * @brief 24-hour format
     * @chinese 24小时制
     */
    TSTimeFormat24Hour
};



#endif /* TopStepComDefines_h */
