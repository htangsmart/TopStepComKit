//
//  TopStepComKit.h
//  TopStepComKit
//
//  Created by 磐石 on 2024/12/27.
//
//  文件说明:
//  TopStepComKit核心类，提供SDK的初始化、配置和所有功能接口的访问

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief TopStep SDK core class for smart device communication
 * @chinese TopStep SDK智能设备通信核心类
 *
 * @discussion
 * [EN]: Core class of TopStep SDK that provides comprehensive functionality for smart device communication,
 *       including Bluetooth connection, data synchronization, and various device features.
 * [CN]: TopStep SDK的核心类，提供智能设备通信的完整功能，
 *       包括蓝牙连接、数据同步和各种设备功能。
 *
 * @note
 * [EN]: This class follows the singleton pattern and should be accessed via sharedInstance.
 * [CN]: 此类遵循单例模式，应通过sharedInstance方法访问。
 */
@interface TopStepComKit : NSObject<NSCopying, NSMutableCopying, TSKitBaseInterface, TSComKitInterface>

#pragma mark - Singleton Instance

/**
 * @brief Get the shared instance of TopStepComKit
 * @chinese 获取TopStepComKit的共享实例
 *
 * @return 
 * [EN]: The singleton instance of TopStepComKit
 * [CN]: TopStepComKit的单例实例
 */
+ (instancetype)sharedInstance;

#pragma mark - Core Properties

/**
 * @brief SDK configuration options
 * @chinese SDK配置选项
 *
 * @discussion
 * [EN]: Contains all configuration parameters for SDK initialization.
 * [CN]: 包含SDK初始化的所有配置参数。
 *
 * @note
 * [EN]: Must be set before using any SDK features.
 * [CN]: 必须在使用任何SDK功能前设置。
 */
@property (nonatomic, strong, readonly) TSKitConfigOptions *kitOption;

/**
 * @brief Currently connected peripheral device
 * @chinese 当前连接的外设设备
 *
 * @discussion
 * [EN]: Represents the currently connected Bluetooth device and its information.
 * [CN]: 表示当前连接的蓝牙设备及其信息。
 */
@property (nonatomic, strong, readonly) TSPeripheral *connectedPeripheral;

#pragma mark - System Management Interfaces

/**
 * @brief Log management interface
 * @chinese 日志管理接口
 *
 * @discussion
 * [EN]: Provides methods for system logging and debugging.
 * [CN]: 提供系统日志记录和调试的方法。
 */
@property (nonatomic, strong, readonly) id<TSKitLogInterface> log;

/**
 * @brief Bluetooth connection interface
 * @chinese 蓝牙连接接口
 *
 * @discussion
 * [EN]: Manages Bluetooth device scanning, connection and communication.
 * [CN]: 管理蓝牙设备扫描、连接和通信。
 */
@property (nonatomic, strong, readonly) id<TSBleConnectInterface> bleConnector;

#pragma mark - Device Feature Interfaces

/**
 * @brief Device finding interface
 * @chinese 设备查找接口
 *
 * @discussion
 * [EN]: Provides methods for finding and alerting connected devices.
 * [CN]: 提供查找和提醒已连接设备的方法。
 */
@property (nonatomic, strong, readonly) id<TSPeripheralFindInterface> peripheralFind;

/**
 * @brief Camera control interface
 * @chinese 相机控制接口
 *
 * @discussion
 * [EN]: Controls device camera operations and photo taking.
 * [CN]: 控制设备相机操作和拍照。
 */
@property (nonatomic, strong, readonly) id<TSCameraInterface> camera;

/**
 * @brief Contact management interface
 * @chinese 联系人管理接口
 *
 * @discussion
 * EN: Manages device contacts and phonebook.
 * CN: 管理设备联系人和电话簿。
 */
@property (nonatomic, strong, readonly) id<TSContactInterface> contact;

/**
 * @brief Alarm clock management interface
 * @chinese 闹钟管理接口
 *
 * @discussion
 * EN: Manages device alarm settings.
 * CN: 管理设备闹钟设置。
 */
@property (nonatomic, strong, readonly) id<TSAlarmClockInterface> alarmClock;


#pragma mark - Settings & Preferences

/**
 * @brief Language management interface
 * @chinese 语言管理接口
 *
 * @discussion
 * EN: Manages device language settings.
 * CN: 管理设备语言设置。
 */
@property (nonatomic, strong, readonly) id<TSLanguageInterface> language;

/**
 * @brief User information management interface
 * @chinese 用户信息管理接口
 *
 * @discussion
 * EN: Manages user profile and settings.
 * CN: 管理用户档案和设置。
 */
@property (nonatomic, strong, readonly) id<TSUserInfoInterface> userInfo;

/**
 * @brief Message management interface
 * @chinese 消息管理接口
 *
 * @discussion
 * EN: Manages device notifications and messages.
 * CN: 管理设备通知和消息。
 */
@property (nonatomic, strong, readonly) id<TSMessageInterface> message;

/**
 * @brief File OTA update interface
 * @chinese 文件OTA升级接口
 *
 * @discussion
 * EN: Manages device firmware updates.
 * CN: 管理设备固件更新。
 */
@property (nonatomic, strong, readonly) id<TSFileOTAInterface> fileOTA;

/**
 * @brief Weather information interface
 * @chinese 天气信息接口
 *
 * @discussion
 * EN: Manages weather data synchronization.
 * CN: 管理天气数据同步。
 */
@property (nonatomic, strong, readonly) id<TSWeatherInterface> weather;

/**
 * @brief Watch face management interface
 * @chinese 表盘管理接口
 *
 * @discussion
 * EN: Manages device watch faces.
 * CN: 管理设备表盘。
 */
@property (nonatomic, strong, readonly) id<TSPeripheralDialInterface> dial;

/**
 * @brief Remote control interface
 * @chinese 远程控制接口
 *
 * @discussion
 * EN: Controls remote device operations.
 * CN: 控制远程设备操作。
 */
@property (nonatomic, strong, readonly) id<TSRemoteControlInterface> remoteControl;

/**
 * @brief Unit management interface
 * @chinese 单位管理接口
 *
 * @discussion
 * EN: Manages measurement unit settings.
 * CN: 管理计量单位设置。
 */
@property (nonatomic, strong, readonly) id<TSUnitInterface> unit;

/**
 * @brief Settings management interface
 * @chinese 设置管理接口
 *
 * @discussion
 * EN: Manages device general settings.
 * CN: 管理设备通用设置。
 */
@property (nonatomic, strong, readonly) id<TSSettingInterface> setting;

/**
 * @brief Battery management interface
 * @chinese 电池管理接口
 *
 * @discussion
 * EN: Manages device battery information.
 * CN: 管理设备电池信息。
 */
@property (nonatomic, strong, readonly) id<TSBatteryInterface> battery;

/**
 * @brief Time management interface
 * @chinese 时间管理接口
 *
 * @discussion
 * EN: Manages device time settings.
 * CN: 管理设备时间设置。
 */
@property (nonatomic, strong, readonly) id<TSTimeInterface> time;

/**
 * @brief Reminder management interface
 * @chinese 提醒管理接口
 *
 * @discussion
 * EN: Manages device reminders.
 * CN: 管理设备提醒。
 */
@property (nonatomic, strong, readonly) id<TSRemindersInterface> reminder;


/**
 * @brief Data synchronization interface
 * @chinese 数据同步接口
 *
 * @discussion
 * EN: Manages health data synchronization.
 * CN: 管理健康数据同步。
 */
@property (nonatomic, strong, readonly) id<TSDataSyncInterface> dataSync;

/**
 * @brief Heart rate measurement and monitoring interface
 * @chinese 心率测量和监测接口
 *
 * @discussion
 * [EN]: Provides methods for heart rate measurement, monitoring, and data synchronization.
 * Includes functionality for both real-time measurements and historical data analysis.
 * [CN]: 提供心率测量、监测和数据同步的方法。
 * 包括实时测量和历史数据分析的功能。
 */
@property (nonatomic, strong, readonly) id<TSHeartRateInterface> heartRate;

/**
 * @brief Blood oxygen measurement and monitoring interface
 * @chinese 血氧测量和监测接口
 *
 * @discussion
 * [EN]: Provides methods for blood oxygen (SpO2) measurement, monitoring, and data synchronization.
 * Blood oxygen saturation is an important vital sign indicating how well oxygen is being transported throughout the body.
 * [CN]: 提供血氧(SpO2)测量、监测和数据同步的方法。
 * 血氧饱和度是一个重要的生命体征，表示氧气在体内运输的效率。
 */
@property (nonatomic, strong, readonly) id<TSBloodOxygenInterface> bloodOxygen;

/**
 * @brief Blood pressure measurement and monitoring interface
 * @chinese 血压测量和监测接口
 *
 * @discussion
 * [EN]: Provides methods for blood pressure measurement, monitoring, and data synchronization.
 * Includes both systolic and diastolic pressure measurements, which are key indicators of cardiovascular health.
 * [CN]: 提供血压测量、监测和数据同步的方法。
 * 包括收缩压和舒张压测量，这是心血管健康的关键指标。
 */
@property (nonatomic, strong, readonly) id<TSBloodPressureInterface> bloodPressure;

/**
 * @brief Stress level measurement and monitoring interface
 * @chinese 压力水平测量和监测接口
 *
 * @discussion
 * [EN]: Provides methods for stress level measurement, monitoring, and data synchronization.
 * Stress levels are typically derived from heart rate variability and other physiological indicators.
 * [CN]: 提供压力水平测量、监测和数据同步的方法。
 * 压力水平通常从心率变异性和其他生理指标中推导。
 */
@property (nonatomic, strong, readonly) id<TSStressInterface> stress;

/**
 * @brief Body temperature measurement and monitoring interface
 * @chinese 体温测量和监测接口
 *
 * @discussion
 * [EN]: Provides methods for body temperature measurement, monitoring, and data synchronization.
 * Temperature monitoring can help detect fever and other health conditions.
 * [CN]: 提供体温测量、监测和数据同步的方法。
 * 体温监测可以帮助检测发热和其他健康状况。
 */
@property (nonatomic, strong, readonly) id<TSTemperatureInterface> temperature;

/**
 * @brief Electrocardiogram (ECG) measurement and analysis interface
 * @chinese 心电图(ECG)测量和分析接口
 *
 * @discussion
 * [EN]: Provides methods for ECG measurement, analysis, and data synchronization.
 * ECG data can help detect various heart conditions and arrhythmias.
 * [CN]: 提供心电图测量、分析和数据同步的方法。
 * 心电图数据可以帮助检测各种心脏状况和心律不齐。
 */
@property (nonatomic, strong, readonly) id<TSElectrocardioInterface> electrocardio;

/**
 * @brief Sleep tracking and analysis interface
 * @chinese 睡眠跟踪和分析接口
 *
 * @discussion
 * [EN]: Provides methods for sleep tracking, analysis, and data synchronization.
 * Includes sleep stages, duration, and quality metrics to assess overall sleep health.
 * [CN]: 提供睡眠跟踪、分析和数据同步的方法。
 * 包括睡眠阶段、时长和质量指标，用于评估整体睡眠健康。
 */
@property (nonatomic, strong, readonly) id<TSSleepInterface> sleep;

/**
 * @brief Sports and workout tracking interface
 * @chinese 运动和锻炼跟踪接口
 *
 * @discussion
 * [EN]: Provides methods for tracking various sports activities, workouts, and exercise data.
 * Includes real-time metrics and historical performance analysis.
 * [CN]: 提供跟踪各种运动活动、锻炼和运动数据的方法。
 * 包括实时指标和历史表现分析。
 */
@property (nonatomic, strong, readonly) id<TSSportInterface> sport;

/**
 * @brief Daily activity tracking and management interface
 * @chinese 每日活动跟踪和管理接口
 *
 * @discussion
 * [EN]: Provides methods for tracking daily activities like steps, distance, calories, and active minutes.
 * Also manages activity goals and provides progress tracking.
 * [CN]: 提供跟踪每日活动的方法，如步数、距离、卡路里和活动分钟数。
 * 还管理活动目标并提供进度跟踪。
 */
@property (nonatomic, strong, readonly) id<TSDailyActivityInterface> dailyActivity;





#pragma mark - Initialization Methods

/**
 * @brief Initialize SDK with configuration options
 * @chinese 使用配置选项初始化SDK
 *
 * @param options 
 * [EN]: Configuration options for SDK initialization
 * [CN]: SDK初始化的配置选项
 *
 * @param completion 
 * [EN]: Completion callback with success status and error information
 * [CN]: 完成回调，包含成功状态和错误信息
 *
 * @discussion
 * [EN]: This method must be called before using any SDK features.
 *       It will validate the license and setup all necessary components.
 * [CN]: 必须在使用任何SDK功能前调用此方法。
 *       它将验证证书并设置所有必要的组件。
 */
- (void)initSDKWithConfigOptions:(TSKitConfigOptions *)options 
                     completion:(nullable TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
