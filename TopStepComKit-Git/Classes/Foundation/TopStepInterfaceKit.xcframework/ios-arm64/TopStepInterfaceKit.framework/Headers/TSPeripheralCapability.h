//
//  TSPeripheralCapability.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Peripheral feature support flags
 * @chinese 外设功能支持标志
 *
 * @discussion
 * [EN]: Bit flags indicating which features are supported by a peripheral device.
 *       Use bitwise operations to check for specific features.
 *       Note: Using uint64_t to support more than 32 features.
 * [CN]: 位标志，指示外设支持哪些功能。
 *       使用位运算来检查特定功能。
 *       注意：使用uint64_t以支持超过32个功能。
 *
 * Bit allocation:
 * - Health Features: bits 0-15
 * - Smart Features: bits 16-31
 * - AI Features: bits 32-33
 * - Social Features: bits 34-36
 * - Religious Features: bits 37-38
 * - Hardware Features: bits 39-45
 * - System Settings: bits 46-51
 * - Reserved: bits 52-63
 */
typedef NS_OPTIONS(uint64_t, TSPeripheralSupportAbility) {
    /// 不支持任何功能 (No features supported)
    TSPeripheralSupportNone              = 0,
    
    #pragma mark - Health Features (健康功能) - Bits 0-15
    /// 步数计数 (Step counting)
    TSPeripheralSupportStepCounting      = 1ULL << 0,
    /// 距离计数 (Distance counting)
    TSPeripheralSupportDistanceCounting  = 1ULL << 1,
    /// 热量计数 (Calorie counting)
    TSPeripheralSupportCalorieCounting   = 1ULL << 2,
    /// 心率监测 (Heart rate monitoring)
    TSPeripheralSupportHeartRate         = 1ULL << 3,
    /// 血压监测 (Blood pressure monitoring)
    TSPeripheralSupportBloodPressure     = 1ULL << 4,
    /// 血氧监测 (Blood oxygen monitoring)
    TSPeripheralSupportBloodOxygen       = 1ULL << 5,
    /// 压力监测 (Stress monitoring)
    TSPeripheralSupportStress            = 1ULL << 6,
    /// 睡眠监测 (Sleep monitoring)
    TSPeripheralSupportSleep             = 1ULL << 7,
    /// 体温监测 (Temperature monitoring)
    TSPeripheralSupportTemperature       = 1ULL << 8,
    /// 心电图监测 (ECG monitoring)
    TSPeripheralSupportECG               = 1ULL << 9,
    /// 女性健康 (Female health)
    TSPeripheralSupportFemaleHealth      = 1ULL << 10,
    /// 发起运动功能 (Initiate workout)
    TSPeripheralSupportInitiateWorkout   = 1ULL << 11,
    /// 每日活动 (Daily activity )
    TSPeripheralSupportDailyActivity     = 1ULL << 12,

    #pragma mark - Smart Features (智能功能) - Bits 16-31
    /// 活动提醒 (Reminders)
    TSPeripheralSupportReminders         = 1ULL << 16,
    /// 来电管理 (Call management)
    TSPeripheralSupportCallManagement    = 1ULL << 17,
    /// 应用通知 (App notifications)
    TSPeripheralSupportAppNotifications  = 1ULL << 18,
    /// 音乐控制 (Music control)
    TSPeripheralSupportMusicControl      = 1ULL << 19,
    /// 天气显示 (Weather display)
    TSPeripheralSupportWeatherDisplay    = 1ULL << 20,
    /// 寻找手机 (Find my phone)
    TSPeripheralSupportFindMyPhone       = 1ULL << 21,
    /// 闹钟功能 (Alarm clock)
    TSPeripheralSupportAlarmClock        = 1ULL << 22,
    /// 地图导航 (Map navigation)
    TSPeripheralSupportMapNavigation     = 1ULL << 23,
    /// 摇一摇拍照 (Shake to take photo)
    TSPeripheralSupportShakeCamera       = 1ULL << 24,
    /// 电子钱包 (E-wallet)
    TSPeripheralSupportEWallet           = 1ULL << 25,
    /// 电子名片 (Business card)
    TSPeripheralSupportBusinessCard      = 1ULL << 26,
    /// 相册功能 (Photo album)
    TSPeripheralSupportPhotoAlbum        = 1ULL << 27,
    /// 电子书功能 (E-book)
    TSPeripheralSupportEBook             = 1ULL << 28,
    /// 录音功能 (Voice recording)
    TSPeripheralSupportVoiceRecording    = 1ULL << 29,
    /// 应用商店 (App store)
    TSPeripheralSupportAppStore          = 1ULL << 30,
    /// 体感游戏 (Motion sensing games)
    TSPeripheralSupportMotionGames       = 1ULL << 31,

    #pragma mark - AI Features (AI功能) - Bits 32-33
    /// 上传运动类型到设备 (uploading sport to device)
    TSPeripheralSupportSportUpload       = 1ULL << 32,
    /// 文心一言 (ERNIE Bot)
    TSPeripheralSupportERNIEBot          = 1ULL << 33,
    /// ChatGPT (ChatGPT)
    TSPeripheralSupportChatGPT           = 1ULL << 34,

    #pragma mark - Social Features (社交功能) - Bits 35-37
    /// 情侣功能 (Lovers feature)
    TSPeripheralSupportLoversFeature     = 1ULL << 35,
    /// 联系人功能 (Contacts feature)
    TSPeripheralSupportContacts          = 1ULL << 36,
    /// 紧急联系人 (Emergency contacts)
    TSPeripheralSupportEmergencyContacts = 1ULL << 37,

    #pragma mark - Religious Features (宗教功能) - Bits 38-39
    /// 穆斯林祈祷提醒 (Muslim prayer reminders)
    TSPeripheralSupportMuslimPrayer      = 1ULL << 38,
    /// 朝拜指南针 (Qibla compass)
    TSPeripheralSupportQiblaCompass      = 1ULL << 39,

    #pragma mark - Hardware Features (硬件功能) - Bits 40-42
    /// NFC支付 (NFC payment)
    TSPeripheralSupportNFCPayment        = 1ULL << 40,
    /// 语音助手 (Voice assistant)
    TSPeripheralSupportVoiceAssistant    = 1ULL << 41,
    /// 表盘功能 (Watch face feature)
    TSPeripheralSupportWatchFacePush         = 1ULL << 42,

    #pragma mark - System Settings (系统设置) - Bits 43-48
    /// 时间设置 (Time settings)
    TSPeripheralSupportTimeSettings      = 1ULL << 43,
    /// 世界时钟设置 (World clock settings)
    TSPeripheralSupportWorldClockSettings = 1ULL << 44,
    /// 语言设置 (Language settings)
    TSPeripheralSupportLanguageSettings  = 1ULL << 45,
    /// 用户信息设置 (User information settings)
    TSPeripheralSupportUserInfoSettings  = 1ULL << 46,
    /// 固件升级 (Firmware upgrade)
    TSPeripheralSupportFirmwareUpgrade   = 1ULL << 47,
    /// 单位设置 (Unit settings)
    TSPeripheralSupportUnitSettings       = 1ULL << 48,

    #pragma mark - Reserved: bits 52-63
};

/**
 * @brief 外设能力检查类
 * @chinese 用于检查外设支持的功能
 *
 * @discussion
 * [EN]: This class provides methods to check what features are supported by a peripheral device.
 *       Each feature has a corresponding check method that returns a boolean value.
 * [CN]: 这个类提供了检查外设支持功能的方法。
 *       每个功能都有对应的检查方法，返回布尔值表示是否支持。
 */
@interface TSPeripheralCapability : NSObject

#pragma mark - Health Features Properties

// 能力集
@property (nonatomic, assign) TSPeripheralSupportAbility supportCapabilities;

/**
 * @brief Indicates if step counting is supported
 * @chinese 指示是否支持计步功能
 */
@property (nonatomic, readonly) BOOL isSupportStepCounting;

/**
 * @brief Indicates if distance counting is supported
 * @chinese 指示是否支持距离计数功能
 */
@property (nonatomic, readonly) BOOL isSupportDistanceCounting;

/**
 * @brief Indicates if calorie counting is supported
 * @chinese 指示是否支持卡路里计数功能
 */
@property (nonatomic, readonly) BOOL isSupportCalorieCounting;

/**
 * @brief Indicates if heart rate monitoring is supported
 * @chinese 指示是否支持心率监测功能
 */
@property (nonatomic, readonly) BOOL isSupportHeartRate;

/**
 * @brief Indicates if blood pressure monitoring is supported
 * @chinese 指示是否支持血压监测功能
 */
@property (nonatomic, readonly) BOOL isSupportBloodPressure;

/**
 * @brief Indicates if blood oxygen monitoring is supported
 * @chinese 指示是否支持血氧监测功能
 */
@property (nonatomic, readonly) BOOL isSupportBloodOxygen;

/**
 * @brief Indicates if stress monitoring is supported
 * @chinese 指示是否支持压力监测功能
 */
@property (nonatomic, readonly) BOOL isSupportStress;

/**
 * @brief Indicates if sleep monitoring is supported
 * @chinese 指示是否支持睡眠监测功能
 */
@property (nonatomic, readonly) BOOL isSupportSleep;

/**
 * @brief Indicates if temperature monitoring is supported
 * @chinese 指示是否支持体温监测功能
 */
@property (nonatomic, readonly) BOOL isSupportTemperature;

/**
 * @brief Indicates if ECG monitoring is supported
 * @chinese 指示是否支持心电图监测功能
 */
@property (nonatomic, readonly) BOOL isSupportECG;

/**
 * @brief Indicates if female health features are supported
 * @chinese 指示是否支持女性健康功能
 */
@property (nonatomic, readonly) BOOL isSupportFemaleHealth;

/**
 * @brief Indicates if initiate workout feature is supported
 * @chinese 指示是否支持发起运动功能
 */
@property (nonatomic, readonly) BOOL isSupportInitiateWorkout;

#pragma mark - Smart Features Properties
/**
 * @brief Indicates if reminders are supported
 * @chinese 指示是否支持提醒功能
 */
@property (nonatomic, readonly) BOOL isSupportReminders;

/**
 * @brief Indicates if call management is supported
 * @chinese 指示是否支持来电管理功能
 */
@property (nonatomic, readonly) BOOL isSupportCallManagement;

/**
 * @brief Indicates if app notifications are supported
 * @chinese 指示是否支持应用通知功能
 */
@property (nonatomic, readonly) BOOL isSupportAppNotifications;

/**
 * @brief Indicates if music control is supported
 * @chinese 指示是否支持音乐控制功能
 */
@property (nonatomic, readonly) BOOL isSupportMusicControl;

/**
 * @brief Indicates if weather display is supported
 * @chinese 指示是否支持天气显示功能
 */
@property (nonatomic, readonly) BOOL isSupportWeatherDisplay;

/**
 * @brief Indicates if find my phone feature is supported
 * @chinese 指示是否支持查找手机功能
 */
@property (nonatomic, readonly) BOOL isSupportFindMyPhone;

/**
 * @brief Indicates if alarm clock feature is supported
 * @chinese 指示是否支持闹钟功能
 */
@property (nonatomic, readonly) BOOL isSupportAlarmClock;

/**
 * @brief Indicates if map navigation is supported
 * @chinese 指示是否支持地图导航功能
 */
@property (nonatomic, readonly) BOOL isSupportMapNavigation;

/**
 * @brief Indicates if shake camera feature is supported
 * @chinese 指示是否支持摇一摇拍照功能
 */
@property (nonatomic, readonly) BOOL isSupportShakeCamera;

/**
 * @brief Indicates if e-wallet feature is supported
 * @chinese 指示是否支持电子钱包功能
 */
@property (nonatomic, readonly) BOOL isSupportEWallet;

/**
 * @brief Indicates if business card feature is supported
 * @chinese 指示是否支持电子名片功能
 */
@property (nonatomic, readonly) BOOL isSupportBusinessCard;

/**
 * @brief Indicates if photo album feature is supported
 * @chinese 指示是否支持相册功能
 */
@property (nonatomic, readonly) BOOL isSupportPhotoAlbum;

/**
 * @brief Indicates if e-book feature is supported
 * @chinese 指示是否支持电子书功能
 */
@property (nonatomic, readonly) BOOL isSupportEBook;

/**
 * @brief Indicates if voice recording is supported
 * @chinese 指示是否支持录音功能
 */
@property (nonatomic, readonly) BOOL isSupportVoiceRecording;

/**
 * @brief Indicates if app store is supported
 * @chinese 指示是否支持应用商店功能
 */
@property (nonatomic, readonly) BOOL isSupportAppStore;

/**
 * @brief Indicates if motion games are supported
 * @chinese 指示是否支持体感游戏功能
 */
@property (nonatomic, readonly) BOOL isSupportMotionGames;

/**
 * @brief Indicates if sport upload is supported
 * @chinese 指示是否支持运动上传功能
 */
@property (nonatomic, readonly) BOOL isSupportSportUpload;

#pragma mark - AI Features Properties
/**
 * @brief Indicates if ERNIE Bot is supported
 * @chinese 指示是否支持文心一言功能
 */
@property (nonatomic, readonly) BOOL isSupportERNIEBot;

/**
 * @brief Indicates if ChatGPT is supported
 * @chinese 指示是否支持ChatGPT
 */
@property (nonatomic, readonly) BOOL isSupportChatGPT;

#pragma mark - Social Features Properties
/**
 * @brief Indicates if lovers feature is supported
 * @chinese 指示是否支持情侣功能
 */
@property (nonatomic, readonly) BOOL isSupportLoversFeature;

/**
 * @brief Indicates if contacts feature is supported
 * @chinese 指示是否支持联系人功能
 */
@property (nonatomic, readonly) BOOL isSupportContacts;

/**
 * @brief Indicates if emergency contacts feature is supported
 * @chinese 指示是否支持紧急联系人功能
 */
@property (nonatomic, readonly) BOOL isSupportEmergencyContacts;

#pragma mark - Religious Features Properties
/**
 * @brief Indicates if Muslim prayer feature is supported
 * @chinese 指示是否支持穆斯林祈祷功能
 */
@property (nonatomic, readonly) BOOL isSupportMuslimPrayer;

/**
 * @brief Indicates if Qibla compass feature is supported
 * @chinese 指示是否支持朝拜指南针功能
 */
@property (nonatomic, readonly) BOOL isSupportQiblaCompass;

#pragma mark - Hardware Features Properties
/**
 * @brief Indicates if NFC payment is supported
 * @chinese 指示是否支持NFC支付功能
 */
@property (nonatomic, readonly) BOOL isSupportNFCPayment;

/**
 * @brief Indicates if voice assistant is supported
 * @chinese 指示是否支持语音助手功能
 */
@property (nonatomic, readonly) BOOL isSupportVoiceAssistant;

/**
 * @brief Indicates if watch face push feature is supported
 * @chinese 指示是否支持表盘推送功能
 */
@property (nonatomic, readonly) BOOL isSupportWatchFacePush;

#pragma mark - System Settings Properties
/**
 * @brief Indicates if time settings are supported
 * @chinese 指示是否支持时间设置功能
 */
@property (nonatomic, readonly) BOOL isSupportTimeSettings;

/**
 * @brief Indicates if world clock settings are supported
 * @chinese 指示是否支持世界时钟设置功能
 */
@property (nonatomic, readonly) BOOL isSupportWorldClockSettings;

/**
 * @brief Indicates if language settings are supported
 * @chinese 指示是否支持语言设置功能
 */
@property (nonatomic, readonly) BOOL isSupportLanguageSettings;

/**
 * @brief Indicates if user information settings are supported
 * @chinese 指示是否支持用户信息设置功能
 */
@property (nonatomic, readonly) BOOL isSupportUserInfoSettings;

/**
 * @brief Indicates if daily activity are supported
 * @chinese 指示是否支持每日活动
 */
@property (nonatomic, readonly) BOOL isSupportDailyActivity;

/**
 * @brief Indicates if firmware upgrade is supported
 * @chinese 指示是否支持固件升级功能
 */
@property (nonatomic, readonly) BOOL isSupportFirmwareUpgrade;

/**
 * @brief Indicates if unit settings are supported
 * @chinese 指示是否支持单位设置功能
 */
@property (nonatomic, readonly) BOOL isSupportUnitSettings;



/**
 * @brief Create a new TSPeripheralCapability instance with raw capability value
 * @chinese 使用原始能力值创建新的TSPeripheralCapability实例
 *
 * @param rawValue
 * EN: Raw capability value, typically received from device
 * CN: 原始能力值，通常从设备接收
 *
 * @return
 * EN: A new TSPeripheralCapability instance
 * CN: 新的TSPeripheralCapability实例
 */
+ (instancetype)capabilityWithRawValue:(uint64_t)rawValue;

/**
 * @brief Initialize with raw capability value
 * @chinese 使用原始能力值初始化
 *
 * @param rawValue
 * EN: Raw capability value, typically received from device
 * CN: 原始能力值，通常从设备接收
 *
 * @return
 * EN: A new TSPeripheralCapability instance
 * CN: 新的TSPeripheralCapability实例
 */
- (instancetype)initWithRawValue:(uint64_t)rawValue;

/**
 * @brief Get the raw capability value
 * @chinese 获取原始能力值
 *
 * @return
 * EN: Raw capability value that can be stored or transmitted
 * CN: 可以存储或传输的原始能力值
 */
- (uint64_t)rawValue;


@end

NS_ASSUME_NONNULL_END
