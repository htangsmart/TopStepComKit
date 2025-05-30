#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TopStepFitKit.h"
#import "TSAlarmClockModel+Fit.h"
#import "TSFitAlarmClock.h"
#import "TSBatteryModel+Fit.h"
#import "TSFitBattery.h"
#import "TSFitBleConnect.h"
#import "TSPeripheral+Fit.h"
#import "NSBundle+TSFit.h"
#import "TSFitCamera.h"
#import "TSFitComDataStorage.h"
#import "TSFitComKit.h"
#import "TSContactModel+Fit.h"
#import "TSFitContact.h"
#import "TSFitBaseDataSync.h"
#import "TSBOValueModel+Fit.h"
#import "TSFitBODataSync.h"
#import "TSBPValueModel+Fit.h"
#import "TSFitBPDataSync.h"
#import "TSDailyActivityValueModel+Fit.h"
#import "TSFitDailyActivityDataSync.h"
#import "TSFitEcgDataSync.h"
#import "TSHRValueModel+Fit.h"
#import "TSFitHRDataSync.h"
#import "TSSleepConcreteModel+Fit.h"
#import "TSSleepItemModel+Fit.h"
#import "TSSleepModel+Fit.h"
#import "TSSleepNapModel+Fit.h"
#import "TSSleepSummaryModel+Fit.h"
#import "TSFitSleepDataSync.h"
#import "TSSportItemModel+Fit.h"
#import "TSSportModel+Fit.h"
#import "TSSportSummaryModel+Fit.h"
#import "TSFitSportDataSync.h"
#import "TSStressValueModel+Fit.h"
#import "TSFitStressDataSync.h"
#import "TSFitTempDataSync.h"
#import "TSFitDataSync.h"
#import "TSECardModel+Fit.h"
#import "TSFitECardBag.h"
#import "TSFitBloodOxygen.h"
#import "TSFitBPAutoMonitor.h"
#import "TSFitBloodPressure.h"
#import "TSDailyActivityGoalsModel+Fit.h"
#import "TSFitDailyActivity.h"
#import "TSFitElectrocardio.h"
#import "TSFitActiveMeasure.h"
#import "TSFitAutoMonitor.h"
#import "TSActivityMeasureParam+Fit.h"
#import "TSAutoMonitorConfigs+Fit.h"
#import "TSFitHealthBase.h"
#import "TSFitHRAutoMonitor.h"
#import "TSHRAutoMonitorConfigs+Fit.h"
#import "TSFitHeartRate.h"
#import "TSFitSleep.h"
#import "TSFitSport.h"
#import "TSFitStress.h"
#import "TSFitTemperature.h"
#import "TSTemperatureValueModel+Fit.h"
#import "TSFitKitBase.h"
#import "TSKitDevice.h"
#import "TSFitKitInit.h"
#import "TSFitLanguage.h"
#import "TSLanguageModel+Fit.h"
#import "TSFitMessage.h"
#import "TSMessageModel+Fit.h"
#import "TSFileOTAModel+Fit.h"
#import "TSFitFileOTA.h"
#import "TSFitDialModel+Fit.h"
#import "TSFitPeripheralDial.h"
#import "TSFitPeripheralFind.h"
#import "TSFitReminders.h"
#import "TSRemindersModel+Fit.h"
#import "TSFitRemoteControl.h"
#import "TSDoNotDisturbModel+Fit.h"
#import "TSFitSetting.h"
#import "TSWristWakeUpModel+Fit.h"
#import "TSFitTime.h"
#import "TSFitUnit.h"
#import "TSFitUserInfo.h"
#import "TSUserInfoModel+Fit.h"
#import "TSFitWeather.h"
#import "TSWeatherCode+Fit.h"
#import "TSWeatherDayModel+Fit.h"
#import "TSWeatherHourModel+Fit.h"
#import "TSWeatherModel+Fit.h"
#import "TSFitWorldClock.h"
#import "TSWorldClockModel+Fit.h"

FOUNDATION_EXPORT double TopStepFitKitVersionNumber;
FOUNDATION_EXPORT const unsigned char TopStepFitKitVersionString[];

