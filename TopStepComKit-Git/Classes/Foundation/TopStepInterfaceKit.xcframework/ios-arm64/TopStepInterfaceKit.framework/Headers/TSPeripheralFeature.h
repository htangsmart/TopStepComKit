//
//  TSPeripheralFeature.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/8/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified peripheral feature options
 * @chinese 统一外设功能选项
 *
 * @discussion
 * [EN]: Each option represents an independent top-level feature normalized by InterfaceKit.
 *       These values are SDK-defined and do not correspond to raw firmware bits from any Provider.
 *       Feature-specific operations and capabilities belong to the corresponding TSXxxInterface.
 *       Published bit values must not be reordered or reused.
 * [CN]: 每个选项表示由 InterfaceKit 统一定义的一项独立顶层功能。
 *       这些值由 SDK 定义，不对应任何 Provider 的固件原始位。
 *       功能内的具体操作和能力由对应的 TSXxxInterface 定义。
 *       已发布的位值不得重新排序或复用。
 */
typedef NS_OPTIONS(uint64_t, TSFeatureOptions) {
    TSFeatureNone                    = 0,           ///< No feature / 无功能

    #pragma mark - Health Features
    TSFeatureDailyActivity           = 1ULL << 0,  ///< Daily activity / 每日活动
    TSFeatureHeartRate               = 1ULL << 1,  ///< Heart rate / 心率
    TSFeatureHeartRateVariability    = 1ULL << 2,  ///< HRV / 心率变异性
    TSFeatureBloodPressure           = 1ULL << 3,  ///< Blood pressure / 血压
    TSFeatureBloodOxygen             = 1ULL << 4,  ///< Blood oxygen / 血氧
    TSFeatureStress                  = 1ULL << 5,  ///< Stress / 压力
    TSFeatureSleep                   = 1ULL << 6,  ///< Sleep / 睡眠
    TSFeatureTemperature             = 1ULL << 7,  ///< Temperature / 体温
    TSFeatureElectrocardiogram       = 1ULL << 8,  ///< ECG / 心电图
    TSFeatureFemaleHealth            = 1ULL << 9,  ///< Female health / 女性健康
    TSFeatureWorkout                 = 1ULL << 10, ///< On-device workout / 设备端运动
    TSFeatureCompanionWorkout        = 1ULL << 11, ///< App-device companion workout / App 与设备互联运动
    TSFeatureWeightManagement        = 1ULL << 12, ///< Weight management / 体重管理

    #pragma mark - Smart Features
    TSFeatureReminder                = 1ULL << 13, ///< Reminder / 提醒
    TSFeatureCallManagement          = 1ULL << 14, ///< Call management / 来电管理
    TSFeatureMessageNotification     = 1ULL << 15, ///< Message notification / 消息通知
    TSFeatureMusic                   = 1ULL << 16, ///< Music / 音乐
    TSFeatureWeather                 = 1ULL << 17, ///< Weather / 天气
    TSFeaturePeripheralFind          = 1ULL << 18, ///< Mutual finding / App 与外设互找
    TSFeatureAlarmClock              = 1ULL << 19, ///< Alarm clock / 闹钟
    TSFeatureWorldClock              = 1ULL << 20, ///< World clock / 世界时钟
    TSFeatureNavigation              = 1ULL << 21, ///< Navigation / 导航
    TSFeatureCamera                  = 1ULL << 22, ///< Camera / 相机
    TSFeatureECardBag                = 1ULL << 23, ///< Electronic card bag / 电子卡包
    TSFeaturePayment                 = 1ULL << 24, ///< Contactless payment / 非接触式支付
    TSFeaturePhotoAlbum              = 1ULL << 25, ///< Photo album / 相册
    TSFeatureEBook                   = 1ULL << 26, ///< E-book / 电子书
    TSFeatureVoiceRecording          = 1ULL << 27, ///< Voice recording / 录音
    TSFeatureAppStore                = 1ULL << 28, ///< App store / 应用商店
    TSFeatureMotionGame              = 1ULL << 29, ///< Motion game / 体感游戏

    #pragma mark - Social Features
    TSFeatureContact                 = 1ULL << 30, ///< Contact / 联系人
    TSFeatureLovers                  = 1ULL << 31, ///< Lovers / 情侣互动

    #pragma mark - Religious Features
    TSFeaturePrayer                  = 1ULL << 32, ///< Prayer / 祈祷
    TSFeatureQiblaCompass            = 1ULL << 33, ///< Qibla compass / 朝拜指南针

    #pragma mark - AI Features
    TSFeatureAIChat                  = 1ULL << 34, ///< AI chat / AI 聊天
    TSFeatureVoiceAssistant          = 1ULL << 35, ///< Voice assistant / 语音助手

    #pragma mark - Device Features
    TSFeatureDial                    = 1ULL << 36, ///< Dial / 表盘
    TSFeatureTime                    = 1ULL << 37, ///< Time / 时间
    TSFeatureLanguage                = 1ULL << 38, ///< Language / 语言
    TSFeatureUserInfo                = 1ULL << 39, ///< User information / 用户信息
    TSFeatureFirmwareUpgrade         = 1ULL << 40, ///< Firmware upgrade / 固件升级
    TSFeatureUnit                    = 1ULL << 41, ///< Unit / 单位
    TSFeatureDeviceSetting           = 1ULL << 42, ///< Generic settings / 通用设备设置
    TSFeaturePeripheralLock          = 1ULL << 43, ///< Peripheral lock / 外设锁
    TSFeatureBattery                 = 1ULL << 44, ///< Battery information / 电池信息
    TSFeatureANC                     = 1ULL << 45, ///< Active noise cancellation / 主动降噪
    TSFeatureEqualizer               = 1ULL << 46, ///< Equalizer / 均衡器
    TSFeatureVolume                  = 1ULL << 47, ///< Volume control / 音量控制
    TSFeatureWearDetection           = 1ULL << 48, ///< Wear detection / 佩戴检测
    TSFeatureStorage                 = 1ULL << 49, ///< Storage information / 存储信息
    /// Restart, shutdown, and factory reset / 重启、关机和恢复出厂
    TSFeaturePeripheralControl       = 1ULL << 50,

    #pragma mark - Diagnostics Features
    TSFeaturePeripheralLog           = 1ULL << 51, ///< Peripheral log / 外设日志
};

/**
 * @brief Immutable peripheral feature set
 * @chinese 不可变的外设功能集合
 *
 * @discussion
 * [EN]: Stores only normalized top-level features confirmed as supported by a peripheral.
 *       It does not parse Provider data, retain raw firmware data, or describe runtime availability.
 * [CN]: 仅保存已确认支持的统一顶层外设功能。
 *       本类不解析 Provider 数据、不保存固件原始数据，也不描述功能的实时可用状态。
 */
@interface TSPeripheralFeature : NSObject <NSCopying>

/**
 * @brief Supported top-level features
 * @chinese 已支持的顶层功能集合
 */
@property (nonatomic, assign, readonly) TSFeatureOptions supportedFeatures;

/**
 * @brief Unavailable; use initWithSupportedFeatures:
 * @chinese 不可用，请使用 initWithSupportedFeatures:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Unavailable; use initWithSupportedFeatures:
 * @chinese 不可用，请使用 initWithSupportedFeatures:
 */
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Initialize with supported top-level features
 * @chinese 使用已支持的顶层功能集合初始化
 *
 * @param supportedFeatures
 * EN: A single feature option or a bitwise combination of feature options.
 * CN: 单个功能选项或多个功能选项的按位组合。
 *
 * @return
 * EN: An initialized immutable feature set.
 * CN: 初始化完成的不可变功能集合。
 */
- (instancetype)initWithSupportedFeatures:(TSFeatureOptions)supportedFeatures NS_DESIGNATED_INITIALIZER;

/**
 * @brief Create a feature set with supported top-level features
 * @chinese 使用已支持的顶层功能集合创建设备功能对象
 *
 * @param supportedFeatures
 * EN: A single feature option or a bitwise combination of feature options.
 * CN: 单个功能选项或多个功能选项的按位组合。
 *
 * @return
 * EN: A new immutable feature set.
 * CN: 新的不可变功能集合。
 */
+ (instancetype)featureWithSupportedFeatures:(TSFeatureOptions)supportedFeatures;

/**
 * @brief Check whether one feature is supported
 * @chinese 检查是否支持单个功能
 *
 * @param feature
 * EN: One nonzero feature option. A combined value or None is invalid and returns NO.
 * CN: 一个非零功能选项。组合值或 None 均为无效参数并返回 NO。
 *
 * @return
 * EN: YES if the specified feature is supported, otherwise NO.
 * CN: 支持指定功能返回 YES，否则返回 NO。
 */
- (BOOL)supportsFeature:(TSFeatureOptions)feature;

/**
 * @brief Check whether all specified features are supported
 * @chinese 检查是否支持指定的全部功能
 *
 * @param features
 * EN: One or more feature options combined with bitwise OR. None returns NO.
 * CN: 一个或多个通过按位或组合的功能选项。传入 None 返回 NO。
 *
 * @return
 * EN: YES only if every specified feature is supported, otherwise NO.
 * CN: 仅当指定的全部功能均受支持时返回 YES，否则返回 NO。
 */
- (BOOL)supportsAllFeatures:(TSFeatureOptions)features;

/**
 * @brief Check whether any specified feature is supported
 * @chinese 检查是否支持指定功能中的任意一项
 *
 * @param features
 * EN: One or more feature options combined with bitwise OR. None returns NO.
 * CN: 一个或多个通过按位或组合的功能选项。传入 None 返回 NO。
 *
 * @return
 * EN: YES if at least one specified feature is supported, otherwise NO.
 * CN: 指定功能中至少一项受支持时返回 YES，否则返回 NO。
 */
- (BOOL)supportsAnyFeature:(TSFeatureOptions)features;

@end

NS_ASSUME_NONNULL_END
