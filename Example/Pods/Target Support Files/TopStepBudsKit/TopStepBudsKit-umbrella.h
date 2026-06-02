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

#import "TopStepBudsKit.h"
#import "TSBudsAIAssistant.h"
#import "TSBudsAITranslate.h"
#import "TSBudsAIInterpreter.h"
#import "TSBudsAISpeech.h"
#import "TSBudsANC.h"
#import "TSBudsAudioRecord.h"
#import "TSBatteryModel+Buds.h"
#import "TSBudsBattery.h"
#import "TSBudsBleConnect.h"
#import "TSPeripheral+Buds.h"
#import "TSBudsCamera.h"
#import "TSBudsComDataStorage.h"
#import "TSBudsComKit.h"
#import "TSBudsEqualizer.h"
#import "TSEqualizerModel+Buds.h"
#import "TSBudsFirmwareUpgrade.h"
#import "TSBudsKitBase.h"
#import "TSBudsKitInit.h"
#import "TSBudsLanguage.h"
#import "TSLanguageModel+Buds.h"
#import "TSBudsMusic.h"
#import "TSBudsPeripheralFind.h"
#import "TSBudsPeripheralLog.h"
#import "TSBudsRemoteControl.h"
#import "TSBudsStorage.h"
#import "TSMediaCountMode+Buds.h"
#import "TSStorageInfoMode+Buds.h"
#import "TSBudsTime.h"
#import "TSBudsVideoRecord.h"
#import "TSBudsVolume.h"
#import "TSVolumeModel+Buds.h"
#import "TSBudsWearDetection.h"

FOUNDATION_EXPORT double TopStepBudsKitVersionNumber;
FOUNDATION_EXPORT const unsigned char TopStepBudsKitVersionString[];

