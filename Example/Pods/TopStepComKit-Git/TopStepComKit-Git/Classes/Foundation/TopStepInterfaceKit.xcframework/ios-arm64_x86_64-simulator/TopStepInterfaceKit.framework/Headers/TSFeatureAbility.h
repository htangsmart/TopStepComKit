//
//  TSFeatureAbility.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/5.
//

#import <Foundation/Foundation.h>

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
 * - Smart Features: bits 16-33
 * - Social Features: bits 34-36
 * - Religious Features: bits 37-38
 * - Hardware Features: bits 39-45
 * - System Settings: bits 46-50
 * - Reserved: bits 51-63
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
    /// 体重管理 (Weight management)
    TSPeripheralSupportWeightManagement  = 1ULL << 13,

    #pragma mark - Smart Features (智能功能) - Bits 16-33
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
    /// 世界时钟 (World clock)
    TSPeripheralSupportWorldClock        = 1ULL << 23,
    /// 地图导航 (Map navigation)
    TSPeripheralSupportMapNavigation     = 1ULL << 24,
    /// 摇一摇拍照 (Shake to take photo)
    TSPeripheralSupportShakeCamera       = 1ULL << 25,
    /// 相机视频预览 (Camera video preview)
    TSPeripheralSupportCameraPreview     = 1ULL << 26,
    /// 电子钱包 (E-wallet)
    TSPeripheralSupportEWallet           = 1ULL << 27,
    /// 电子名片 (Business card)
    TSPeripheralSupportBusinessCard      = 1ULL << 28,
    /// 相册功能 (Photo album)
    TSPeripheralSupportPhotoAlbum        = 1ULL << 29,
    /// 电子书功能 (E-book)
    TSPeripheralSupportEBook             = 1ULL << 30,
    /// 录音功能 (Voice recording)
    TSPeripheralSupportVoiceRecording    = 1ULL << 31,
    /// 应用商店 (App store)
    TSPeripheralSupportAppStore          = 1ULL << 32,
    /// 体感游戏 (Motion sensing games)
    TSPeripheralSupportMotionGames       = 1ULL << 33,

    #pragma mark - AI Features (AI功能) - Bits 34-36
    /// 上传运动类型到设备 (uploading sport to device)
    TSPeripheralSupportSportUpload       = 1ULL << 34,
    /// 文心一言 (ERNIE Bot)
    TSPeripheralSupportERNIEBot          = 1ULL << 35,
    /// ChatGPT (ChatGPT)
    TSPeripheralSupportChatGPT           = 1ULL << 36,

    #pragma mark - Social Features (社交功能) - Bits 37-39
    /// 情侣功能 (Lovers feature)
    TSPeripheralSupportLoversFeature     = 1ULL << 37,
    /// 联系人功能 (Contacts feature)
    TSPeripheralSupportContacts          = 1ULL << 38,
    /// 紧急联系人 (Emergency contacts)
    TSPeripheralSupportEmergencyContacts = 1ULL << 39,

    #pragma mark - Religious Features (宗教功能) - Bits 40-41
    /// 穆斯林祈祷提醒 (Muslim prayer reminders)
    TSPeripheralSupportMuslimPrayer      = 1ULL << 40,
    /// 朝拜指南针 (Qibla compass)
    TSPeripheralSupportQiblaCompass      = 1ULL << 41,

    #pragma mark - Hardware Features (硬件功能) - Bits 42-46
    /// NFC支付 (NFC payment)
    TSPeripheralSupportNFCPayment        = 1ULL << 42,
    /// 语音助手 (Voice assistant)
    TSPeripheralSupportVoiceAssistant    = 1ULL << 43,
    /// 表盘功能 (Watch face feature)
    TSPeripheralSupportFacePush          = 1ULL << 44,
    /// 自定义表盘 (Custom face)
    TSPeripheralSupportCustomFace        = 1ULL << 45,
    /// 幻灯片表盘 (Slideshow face)
    TSPeripheralSupportSlideshowFace     = 1ULL << 46,

    #pragma mark - System Settings (系统设置) - Bits 47-51
    /// 时间设置 (Time settings)
    TSPeripheralSupportTimeSettings      = 1ULL << 47,
    /// 语言设置 (Language settings)
    TSPeripheralSupportLanguageSettings  = 1ULL << 48,
    /// 用户信息设置 (User information settings)
    TSPeripheralSupportUserInfoSettings  = 1ULL << 49,
    /// 固件升级 (Firmware upgrade)
    TSPeripheralSupportFirmwareUpgrade   = 1ULL << 50,
    /// 单位设置 (Unit settings)
    TSPeripheralSupportUnitSettings      = 1ULL << 51,

    #pragma mark - Reserved: bits 52-63
};



NS_ASSUME_NONNULL_BEGIN

@interface TSFeatureAbility : NSObject

/**
 * @brief Original ability data from device
 * @chinese 从设备获取的最原始能力数据
 *
 * @discussion
 * [EN]: The raw NSData containing the original ability information received from the device.
 *       This data represents the unprocessed capability flags as transmitted by the device.
 *       Maximum size is 16 bytes according to the device specification.
 *       This property is used for debugging, logging, and potential future data analysis.
 * [CN]: 包含从设备接收的原始能力信息的原始NSData。
 *       此数据表示设备传输的未处理的能力标志。
 *       根据设备规范，最大大小为16字节。
 *       此属性用于调试、日志记录和潜在的未来数据分析。
 */
@property (nonatomic, strong, nullable) NSData *originAbility;

/**
 * @brief Device capability support flags
 * @chinese 设备功能支持标志集
 *
 * @discussion
 * [EN]: Bit flags indicating which features are supported by the peripheral device.
 *       This is the parsed and processed version of the original ability data from the device.
 *       Each bit represents a specific feature capability (see TSPeripheralSupportAbility enum).
 *       Use bitwise operations to check for specific features.
 *       This value is automatically set when creating the capability object from device data.
 * [CN]: 位标志，指示外设支持哪些功能。
 *       这是从设备原始能力数据解析和处理后的版本。
 *       每一位代表一个特定的功能能力（参见TSPeripheralSupportAbility枚举）。
 *       使用位运算来检查特定功能。
 *       从设备数据创建能力对象时会自动设置此值。
 *
 * @note
 * [EN]: This property represents the processed capability flags, while originAbility contains
 *       the raw data received from the device. Both are useful for different purposes:
 *       - supportCapabilities: For feature checking and UI logic
 *       - originAbility: For debugging, logging, and protocol analysis
 * [CN]: 此属性表示处理后的能力标志，而originAbility包含从设备接收的原始数据。
 *       两者都有不同的用途：
 *       - supportCapabilities：用于功能检查和UI逻辑
 *       - originAbility：用于调试、日志记录和协议分析
 */
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

/**
 * @brief Indicates if weight management feature is supported
 * @chinese 指示是否支持体重管理功能
 */
@property (nonatomic, readonly) BOOL isSupportWeightManagement;

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
 * @brief Indicates if world clock feature is supported
 * @chinese 指示是否支持世界时钟功能
 */
@property (nonatomic, readonly) BOOL isSupportWorldClock;

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
 * @brief Indicates if camera video preview is supported
 * @chinese 指示是否支持相机视频预览功能
 */
@property (nonatomic, readonly) BOOL isSupportCameraPreview;

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
@property (nonatomic, readonly) BOOL isSupportFacePush;

/**
 * @brief Indicates if custom watch face is supported
 * @chinese 指示是否支持自定义表盘功能
 */
@property (nonatomic, readonly) BOOL isSupportCustomFace;

/**
 * @brief Indicates if slideshow watch face is supported
 * @chinese 指示是否支持幻灯片表盘功能
 *
 * @discussion
 * [EN]: Slideshow watch face (also known as photo album watch face) allows displaying
 *       multiple photos on a single watch face with automatic or manual switching.
 * [CN]: 幻灯片表盘（也称为相册表盘）允许在单个表盘上显示多张照片，
 *       支持自动或手动切换。
 */
@property (nonatomic, readonly) BOOL isSupportSlideshowFace;

#pragma mark - System Settings Properties
/**
 * @brief Indicates if time settings are supported
 * @chinese 指示是否支持时间设置功能
 */
@property (nonatomic, readonly) BOOL isSupportTimeSettings;

/**
 * @brief Indicates if language settings are supported
 * @chinese 指示是否支持语言设置功能
 */
@property (nonatomic, readonly) BOOL isSupportLanguage;

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
 * @brief Create a new TSPeripheralCapability instance with capability flags
 * @chinese 使用功能标志创建新的TSPeripheralCapability实例
 *
 * @param capabilityFlags
 * EN: Capability flags indicating supported features
 * CN: 指示支持功能的能力标志
 *
 * @return
 * EN: A new TSPeripheralCapability instance
 * CN: 新的TSPeripheralCapability实例
 */
+ (instancetype)capabilityWithFlags:(uint64_t)capabilityFlags;

/**
 * @brief Create a new TSPeripheralCapability instance with capability flags and original data
 * @chinese 使用功能标志和原始数据创建新的TSPeripheralCapability实例
 *
 * @param capabilityFlags
 * EN: Capability flags indicating supported features
 * CN: 指示支持功能的能力标志
 *
 * @param originData
 * EN: Original ability data from device (max 16 bytes)
 * CN: 从设备获取的原始能力数据（最大16字节）
 *
 * @return
 * EN: A new TSPeripheralCapability instance
 * CN: 新的TSPeripheralCapability实例
 */
+ (instancetype)capabilityWithFlags:(uint64_t)capabilityFlags originData:(NSData *_Nullable)originData;

/**
 * @brief Initialize with capability flags
 * @chinese 使用功能标志初始化
 *
 * @param capabilities
 * EN: Capability flags indicating supported features
 * CN: 指示支持功能的能力标志
 *
 * @return
 * EN: A new TSPeripheralCapability instance
 * CN: 新的TSPeripheralCapability实例
 */
- (instancetype)initWithCapabilities:(uint64_t)capabilities;


/**
 * @brief Get the capability flags value
 * @chinese 获取功能标志值
 *
 * @return
 * EN: Capability flags value representing supported features
 * CN: 表示支持功能的功能标志值
 */
- (uint64_t)capabilities;


/**
 * @brief Check if a specific capability bit is supported based on original data
 * @chinese 根据原始数据检查特定功能位是否支持
 *
 * @param bitIndex
 * EN: Bit index to check (0-based index)
 * CN: 要检查的位索引（从0开始）
 *
 * @return
 * EN: YES if the bit at the specified index is set, NO otherwise
 * CN: 如果指定索引的位被设置返回YES，否则返回NO
 *
 * @discussion
 * [EN]: This method checks the original ability data from the device to determine
 *       if a specific feature is supported. It converts the original NSData to binary
 *       and checks the bit at the specified index.
 *       This is useful for checking features that might not be mapped to the standard
 *       capability flags or for debugging purposes.
 * [CN]: 此方法检查设备原始能力数据以确定特定功能是否支持。
 *       它将原始NSData转换为二进制并检查指定索引的位。
 *       这对于检查可能未映射到标准功能标志的功能或用于调试目的很有用。
 *
 * @note
 * [EN]: If originAbility is nil or the bitIndex is out of range, this method returns NO.
 *       The bitIndex is 0-based, so bit 0 is the least significant bit.
 * [CN]: 如果originAbility为nil或bitIndex超出范围，此方法返回NO。
 *       位索引从0开始，所以位0是最低位。
 */
- (BOOL)isCapabilitySupportedAtBitIndex:(NSInteger)bitIndex;


@end

NS_ASSUME_NONNULL_END
