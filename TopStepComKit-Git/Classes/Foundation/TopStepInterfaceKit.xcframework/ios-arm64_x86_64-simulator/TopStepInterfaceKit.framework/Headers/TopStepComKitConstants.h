//
//  TSKitConstants.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2024/12/27.
//
//  文件说明:
//  SDK常量定义，包括错误域、错误消息、错误宏定义等

#import <Foundation/Foundation.h>
#import "TopStepErrorMsgDefines.h"
NS_ASSUME_NONNULL_BEGIN


#pragma mark - Error Creation Macros
/**
 * @brief Error creation macros
 * @chinese 错误创建宏定义
 */
/// 创建未知错误 (Create unknown error)
#define TSERROR_UNKNOW(Domain) TSERROR_MESSAGE(Domain,eTSErrorUnknown,kEMsgUnknowName)
/// 创建数据格式错误 (Create data format error)
#define TSERROR_DATA_ERROR(Domain) TSERROR_MESSAGE(Domain,eTSErrorDataFormatError,kEMsgDataFormatName)
/// 创建参数类型错误 (Create parameter type error)
#define TSERROR_PARAM_ERROR(Domain) TSERROR_MESSAGE(Domain,eTSErrorInvalidTypeError,kEMsgInvalidParamTypeName)
/// 创建无效参数错误 (Create invalid parameter error)
#define TSERROR_INVALID_PARAM(Domain) TSERROR_MESSAGE(Domain,eTSErrorInvalidParam,kEMsgInvalidParamName)
/// 创建不支持错误 (Create not supported error)
#define TSERROR_NOTSUPPORT(Domain) TSERROR_MESSAGE(Domain,eTSErrorNotSupport,kEMsgNotSupportName)
/// 创建数据设置失败错误 (Create data setting failed error)
#define TSERROR_DATA_SET_FAILED(Domain) TSERROR_MESSAGE(Domain,eTSErrorDataSettingFailed,kEMsgSettingFailedName)
/// 创建数据获取失败错误 (Create data get failed error)
#define TSERROR_DATA_GET_FAILED(Domain) TSERROR_MESSAGE(Domain,eTSErrorDataGetFailed,kEMsgDataGetFailedName)
/// 创建错误码错误
#define TSERROR_BLE_CODE(Domain, Code) TSERROR_MESSAGE(Domain,Code,[TopStepErrorMsgDefines errorMsgForBleErCode:Code])
/// 创建错误码错误
#define TSERROR_COM_CODE(Domain, Code) TSERROR_MESSAGE(Domain,Code,[TopStepErrorMsgDefines errorMsgForCode:Code])

/// 创建自定义错误消息 (Create custom error message)
#define TSERROR_MESSAGE(Domain, Code, Description) [NSError errorWithDomain:Domain \
                                                                     code:Code \
                                                                 userInfo:@{NSLocalizedDescriptionKey: Description}]
/// 创建自定义错误信息 (Create custom error info)
#define TSERROR_USERINFO(Domain, Code, UserInfo) [NSError errorWithDomain:Domain \
                                                                    code:Code \
                                                                userInfo:UserInfo]

#pragma mark - Error Domains
/**
 * @brief Error domains for different features
 * @chinese 不同功能的错误域
 */
/// SDK初始化错误域 (SDK initialization error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainSDKInitName;
/// 闹钟错误域 (Alarm error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainAlarmName;
/// 电量错误域 (Battery error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainBatteryName;
/// 蓝牙连接错误域 (Bluetooth connection error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainBleConnectName;
/// 遥控拍照错误域 (Remote camera error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainCameraName;
/// 通讯录错误域 (Contact error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainContactName;
/// 数据同步错误域 (Data sync error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainDataSyncName;
/// 表盘错误域 (Watch face error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainDialName;
/// OTA错误域 (OTA error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainFileOTAName;
/// 语言错误域 (Language error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainLanguageName;
/// 消息错误域 (Message error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainMessageName;
/// 设备查找错误域 (Device find error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainDeviceFindName;
/// 提醒错误域 (Reminder error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainReminderName;
/// 远程控制错误域 (Remote control error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainRemoteControlName;
/// 设置错误域 (Setting error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainSettingName;
/// 时间错误域 (Time error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainTimeName;
/// 单位错误域 (Unit error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainUnitName;
/// 个人信息错误域 (User info error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainUserInfoName;
/// 天气错误域 (Weather error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainWeatherName;

/// 心率错误域 (Heart rate error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainHeartRateName;
/// 血压错误域 (Blood pressure error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainBloodPressureName;
/// 血氧错误域 (Blood oxygen error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainBloodOxygenName;
/// 压力错误域 (Stress error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainStressName;
/// 睡眠错误域 (Sleep error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainSleepName;
/// 体温错误域 (Temperature error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainTemperatureName;
/// 心电错误域 (ECG error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainECGName;
/// 运动错误域 (Workout error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainWorkoutName;
/// 每日活动错误域 (Daily activity error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainDailyActivityName;
/// 电子卡包错误域 (Electronic card bag error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainECardBagName;
/// 世界时钟错误域 (World clock error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainWorldClockName;

/// 智能眼镜错误域 (Glasses error domain)
FOUNDATION_EXPORT NSString *const kTSErrorDomainGlassesName;

#pragma mark - Method Parameters
/**
 * @brief Method parameter keys
 * @chinese 方法参数键
 */
/// 类名称 (class name)
FOUNDATION_EXPORT NSString *const kTSClassName;
/// 方法名称 (Method name)
FOUNDATION_EXPORT NSString *const kTSMethodName;
/// 方法参数 (Method parameters)
FOUNDATION_EXPORT NSString *const kTSMethodParams;

NS_ASSUME_NONNULL_END






