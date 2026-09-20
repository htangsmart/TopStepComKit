//
//  WMMusilinDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2024/7/6.
//

#import <Foundation/Foundation.h>
#import "WMAlarmModel.h"

typedef NS_ENUM(NSInteger, WMAllahNames) {
    WMAllahNameArRahmaan,
    WMAllahNameArRaheem,
    WMAllahNameAlMalik,
    WMAllahNameAlQuddus,
    WMAllahNameAsSalam,
    WMAllahNameAlMumin,
    WMAllahNameAlMuhaymin,
    WMAllahNameAlAzeez,
    WMAllahNameAlJabbar,
    WMAllahNameAlMutakabbir,
    WMAllahNameAlKhaaliq,
    WMAllahNameAlBaari,
    WMAllahNameAlMusawwir,
    WMAllahNameAlGhaffar,
    WMAllahNameAlQahhar,
    WMAllahNameAlWahhaab,
    WMAllahNameArRazzaaq,
    WMAllahNameAlFattaah,
    WMAllahNameAlAleem,
    WMAllahNameAlQaabid,
    WMAllahNameAlBaasit,
    WMAllahNameAlKhaafidh,
    WMAllahNameArRaafi,
    WMAllahNameAlMuizz,
    WMAllahNameAlMuzil,
    WMAllahNameAsSamee,
    WMAllahNameAlBaseer,
    WMAllahNameAlHakam,
    WMAllahNameAlAdl,
    WMAllahNameAlLateef,
    WMAllahNameAlKhabeer,
    WMAllahNameAlHaleem,
    WMAllahNameAlAtheem,
    WMAllahNameAlGhafoor,
    WMAllahNameAshShakoor,
    WMAllahNameAlAlee,
    WMAllahNameAlKabeer,
    WMAllahNameAlHafeedh,
    WMAllahNameAlMuqeet,
    WMAllahNameAlHaseeb,
    WMAllahNameAlJaleel,
    WMAllahNameAlKareem,
    WMAllahNameArRaqeeb,
    WMAllahNameAlMujeeb,
    WMAllahNameAlWaasi,
    WMAllahNameAlHakeem,
    WMAllahNameAlWadood,
    WMAllahNameAlMajeed,
    WMAllahNameAlBaith,
    WMAllahNameAshShaheed,
    WMAllahNameAlHaqq,
    WMAllahNameAlWakeel,
    WMAllahNameAlQawiyy,
    WMAllahNameAlMateen,
    WMAllahNameAlWaliyy,
    WMAllahNameAlHameed,
    WMAllahNameAlMuhsee,
    WMAllahNameAlMubdi,
    WMAllahNameAlMuid,
    WMAllahNameAlMuhyee,
    WMAllahNameAlMumeet,
    WMAllahNameAlHayy,
    WMAllahNameAlQayyoom,
    WMAllahNameAlWaajid,
    WMAllahNameAlMaajid,
    WMAllahNameAlWaahid,
    WMAllahNameAlAhad,
    WMAllahNameAsSamad,
    WMAllahNameAlQadir,
    WMAllahNameAlMuqtadir,
    WMAllahNameAlMuqaddim,
    WMAllahNameAlMuakhkhir,
    WMAllahNameAlAwwal,
    WMAllahNameAlAakhir,
    WMAllahNameAzDhaahir,
    WMAllahNameAlBaatin,
    WMAllahNameAlWaali,
    WMAllahNameAlMutaali,
    WMAllahNameAlBarr,
    WMAllahNameAtTawwab,
    WMAllahNameAlMuntaqim,
    WMAllahNameAlafuww,
    WMAllahNameArRaoof,
    WMAllahNameMaalikUlMulk,
    WMAllahNameDhulJalaaliWalIkraam,
    WMAllahNameAlMuqsit,
    WMAllahNameAlJaami,
    WMAllahNameAlGhaniyy,
    WMAllahNameAlMughni,
    WMAllahNameAlMani,
    WMAllahNameAdDharr,
    WMAllahNameAnNafi,
    WMAllahNameAnNur,
    WMAllahNameAlHaadi,
    WMAllahNameAlBadee,
    WMAllahNameAlBaaqi,
    WMAllahNameAlWaarith,
    WMAllahNameArRasheed,
    WMAllahNameAsSaboor
};

typedef NS_OPTIONS(uint8_t, WMPrayerTimes) {
    WMPrayerTimeNone     = 0,       // 无祈祷时间
    WMPrayerTimeFajr     = 1 << 0,  // Fajr（晨礼）
    WMPrayerTimeSunrise  = 1 << 1,  // Sunrise（日出）
    WMPrayerTimeDhuhr    = 1 << 2,  // Dhuhr（晌礼）
    WMPrayerTimeAsr      = 1 << 3,  // Asr（晡礼）
    WMPrayerTimeMaghrib  = 1 << 4,  // Maghrib（昏礼）
    WMPrayerTimeIsha     = 1 << 5   // Isha（宵礼）
};

typedef NS_ENUM(NSInteger, WMPrayerFunc) {
    WMPrayerFuncShiaIthnaAshari = 0, // Shia Ithna Ashari
    WMPrayerFuncUniversityOfIslamicScience, // University of Islamic Science
    WMPrayerFuncMuslimWorldLeague, // Muslim World League
    WMPrayerFuncIslamicSocietyOfNorthAmerica, // Islamic Society of North America
    WMPrayerFuncUmmAlQura // Umm al-Qura
};

typedef NS_ENUM(NSInteger, WMPrayerJuristicMethod) {
    WMPrayerJuristicMethodShafii = 0, // Shafi'i, Maliki, Ja'fari, and Hanbali
    WMPrayerJuristicMethodHanafi, // Hanafi
};


@interface WMPrayerFuncModel : NSObject

@property (nonatomic, assign) WMPrayerFunc style;
@property (nonatomic, assign) WMPrayerJuristicMethod method;

@end

/// 已收藏真主 （Allah Names）
@interface WMAllahNameCollectModel : NSObject

- (instancetype)initWithData:(NSData *)data;

- (NSData *)data;
/// 是否已收藏真主 （Is Allah translated into English）
- (BOOL)isCollect:(WMAllahNames)name;
/// 收藏/取消收藏真主（Collect Allah / Uncollect Allah）
- (void)collect:(BOOL)isCollect name:(WMAllahNames)name;

@end

/// 祈祷提醒
@interface WMPrayerTimingsModel : NSObject

@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) WMPrayerTimes timings;

@end

/// 念经提醒 (Tasbih Reminder)
@interface WMTasbihReminderModel : NSObject

/// 是否启用提醒 (Is Reminder On)
@property (nonatomic, assign) BOOL isOn;
/// 开始时间小时 (Start Hour)
@property (nonatomic, assign) NSInteger startHour;
/// 开始时间分钟 (Start Minute)
@property (nonatomic, assign) NSInteger startMinute;
/// 结束时间小时 (End Hour)
@property (nonatomic, assign) NSInteger endHour;
/// 结束时间分钟 (End Minute)
@property (nonatomic, assign) NSInteger endMinute;
/// 提醒频次（分钟）(Frequency in Minutes)
@property (nonatomic, assign) NSInteger frequency;
/// 重复规则 (Repeat Options)
@property (nonatomic, assign) WMAlarmRepeat repeatOptions;

@end

