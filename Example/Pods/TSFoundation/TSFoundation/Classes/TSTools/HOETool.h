//
//  #import <TSFoundation/TSFoundation.h>h
//  JieliJianKang
//
//  Created by mac on 2022/9/24.
//

#ifndef HOETool_h
#define HOETool_h

#import "JLUser.h"

@interface HOETool : NSObject

+(NSString *)getUserByKey:(NSString *)key;

+(void)setUser:(id)user forKey:(NSString *)key;

+(JLUser*)getUserInfoLocal;
+(void)setUserLocal:(NSString*)nickName gender:(int)gender birthYear:(int)birthYear birthMonth:(int)birthMonth birthDay:(int)birthDay height:(int)height weight:(float)weight targetStep:(int)step;
+(void)setTodayStepLocal:(int)todayStep;
+(int)getTodayStepLocal;
+(void)setTodayCalLocal:(float)todayCal;
+(void)setTodayActNumLocal:(int)actNum;
+(int)getTodayActNumLocal;
+(void)setTodaySportDurationLocal:(float)todaySportDuration;
+(float)getTodaySportDurationLocal;
+(float)getTodayCal;
+(void)setTodayDistanceLocal:(float)todayDistance;
+(float)getTodayDistance;
+(NSString*)getLocalUserId;
+(void)addOneKeyHeartRateResults:(int)heartRate recordTime:(NSTimeInterval)recordTime;
+(NSString*)getOneKeyHeartRateResults;
+(void)addOneKeyLastHeartRateResults:(int)avg min:(int)min max:(int)max recordTime:(NSTimeInterval)recordTime;
+(NSString*)getOneKeyLastHeartRateResults;
+(void)addOneKeyPressureResults:(int)pressure recordTime:(NSTimeInterval)recordTime;
+(NSString*)getOneKeyPressureResults;
+(void)addOneKeyLastPressureResults:(int)avg min:(int)min max:(int)max recordTime:(NSTimeInterval)recordTime;
+(NSString*)getOneKeyLastPressureResults;
+(void)addOneKeyBloodOxygenResults:(int)bloodOxygen recordTime:(NSTimeInterval)recordTime;
+(NSString*)getOneKeyBloodOxygenResults;
+(void)addOneKeyLastBloodOxygenResults:(int)avg min:(int)min max:(int)max recordTime:(NSTimeInterval)recordTime;
+(NSString*)getOneKeyLastBloodOxygenResults;
+(int)hearRate2Pressure:(int)hearRateAvg;
+(NSString*)getPressureDes:(int)avg;
+(void)setHasConnectedOnce;
+(BOOL)getHasConnectedOnce;
+(NSArray*)getDrinkRemindData;
+(void)setDrinkRemindData:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin noonNotDisturb:(int)noonNotDisturb;
+(NSArray*)getJiuzuoRemindData;
+(void)setJiuzuoRemindData:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin noonNotDisturb:(int)noonNotDisturb;
+(NSArray*)getTaiwanData;
+(void)setTaiwanData:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin ;
+(NSArray*)getNoDisturbData;
+(void)setNoDisturbData:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin;
+(NSArray*)getBleHistoryPeripheralArr;
+(void)addBleHistoryPeripheral:(NSString*)uuidStr;
+(NSArray*)getFemaleCycleData;
+(void)setFemaleCycleData:(int)status lastTime:(NSTimeInterval)lastTime duration:(int)duration period:(int)period jingqiOn:(int)jingqiOn beginPailuanOn:(int)beginPailuanOn endPailuanOn:(int)endPailuanOn;
+(int)getAvatarBgColorId;
+(void)setAvatarBgColorId:(int)colorId;
+(int)getAvatarId;
+(void)setAvatarId:(int)avatarId;
+(NSArray*)getBloodOxygenMode;
+(void)setBloodOxygenMode:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin;
+(NSArray*)getHeartRateMode;
+(void)setHeartRateMode:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin;
+(NSArray*)getSleepMode;
+(void)setSleepMode:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin;
+(void)setHomeInUseCard:(NSArray*)arr;
+(NSMutableArray*)getHomeInUseCard;
+(void)setHomeNotUseCard:(NSArray*)arr;
+(NSMutableArray*)getHomeNotUseCard;





//以下是拓步的
+(double)km2CaloriesWithKm:(double)km weight:(double)weight;
+(NSDictionary*)dictionaryWithJsonNSDate:(NSData*)jsonData;
+(NSData*)toJsonNSDataWithObject:(NSObject*)obj keys:(NSArray*)keys;
+(void)setCaloriesGoal:(double)goal;//单位千卡
+(double)getCaloriesGoal;//单位千卡
+(void)setSportTimeGoal:(int)goal;
//单位分钟，运动时长
+(int)getSportTimeGoal;
+(void)setStepGoal:(int)goal;
+(int)getStepGoal;
+(void)setSleepGoal:(int)goal;
+(int)getSleepGoal;
//单位米
+(void)setDistanceGoal:(float)goal;
+(float)getDistanceGoal;
+(void)setActivityCountGoal:(int)goal;
+(int)getActivityCountGoal;
+(void)setActivityDurationGoal:(int)goal;
+(int)getActivityDurationGoal;
+(void)setWeightGoal:(double)goal;
+(double)getWeightGoal;
+(long)getTargetModifyTime;
+(void)setTargetModifyTime:(long)targetModifyTime;
+(NSString*)getUserId;
+(void)setUserId:(NSString*)userId;
+(NSString*)getNickname;
+(void)setNickname:(NSString*)nickname;

+(void)setAvatarUrl:(NSString*)avatarUrl;
+(NSString *)avatarUrl;

//0--女  1--男
+(int)getGender;
//0--女  1--男
+(void)setGender:(int)gender;
+(NSString*)getBirthday;
+(void)setBirthday:(NSString*)birthday;
+(int)getUserAge;
+(float)getHeight;
+(void)setHeight:(float)height;
+(float)getWeight;
+(void)setWeight:(float)weight;
+(BOOL)getIsVisitor;
+(void)setIsVisitor:(BOOL)isVisitor;
+(NSString*)getUserPhone;
+(void)setUserPhone:(NSString*)phone;
+(NSString*)getUserEmail;
+(void)setUserEmail:(NSString*)email;
+(void)setUserLoginInfo:(NSString*)nickName gender:(int)gender birthDay:(NSString*)birthday height:(int)height weight:(float)weight targetStep:(int)step targetActNum:(int)targetActNum targetSportDur:(int)targetSportDur;
+(void)clearOnLogout;
+(NSString*)getDeviceMac;
+(void)setDeviceMac:(NSString*)deviceMac;
+(NSString*)getProjectId;
+(void)setProjectId:(NSString*)projectId;
+(NSString*)getMobo;
+(void)setMobo:(NSString*)mobo;
+(int)getBattery;
+(void)setBattery:(int)battery;
+(NSString *) md5: (NSString *) inPutText;
+(NSString *) md5WithSalt: (NSString *) inPutText salt:(NSString*)salt;
+(NSString*)getFileNameWithoutExtendName:(NSString*)wholeFileName;
+(NSString*)getExtendNameWithWholeName:(NSString*)wholeFileName;
+ (void)bundleToDocuments:(NSString *)dir fileName:(NSString *)fileName existsCover:(BOOL)cover;
+ (void)copyToDocuments:(NSString *)dir fileName:(NSString *)fileName existsCover:(BOOL)cover;
+(NSString*)getFirmVersion;
+(void)setFirmVersion:(NSString*)firmVersion;

+(NSString*)getVirtualVersion;
+(void)setVirtualVersion:(NSString*)virtualVersion;

+(NSString*)getJsVersion;
+(void)setJsVersion:(NSString*)jsVersion;
+(NSString*)getAppVersion;
+(NSString*)getSysVersion;
+(NSString*)getAppDeviceId;
+(NSString*)getToken;
+(void)setToken:(NSString*)token;
+(BOOL)checkIsInfoExist:(NSDictionary*)info;
+(NSDictionary *)getUrlParameterWithUrl:(NSURL *)url;
+(NSString*)strFormatToJsonStr:(NSString*)str;
+(NSString*)objectToJsonStr:(NSDictionary*)dic;
+(BOOL)isValidJson:(id)jsonString;
+(NSDictionary*)dictionaryWithJsonString:(NSString*)jsonString;
+(BOOL)getHasConfirmPrivacy;
+(void)setHasConfirmPrivacy;
+(NSArray*)getStressSegments;
+(NSString*)getStressDes:(int)stress;
+(NSString*)getStressColor:(int)stress;
+(double)convertUnit:(NSString*)metricSystemName value:(double)value;
+(NSString*)getUnit:(NSString*)metricSystemName;
+(NSString*)getPaceInEnglishSystemInDurationPerMile:(double)speedInMeterPerSecond;
+(NSString*)getPaceInMetricSystemInDurationPerMile:(double)speedInMeterPerSecond;
+(BOOL)isMetricSystem;
+(void)setMetricSystem:(BOOL)isMetric;
+(double)getFTemperatureByC:(double)c;
+(NSString*)getTemperatureUnit;
+(void)setTemperatureUnit:(NSString*)temperatureUnit;
+(NSString*)minuteToHHmm:(int)minute;
+(NSString*)secondsToHHmmss:(int)seconds;
+(NSString *)mimeTypeForFileAtPath:(NSString *)path;
+(NSArray*)sortStrArrAsc:(NSArray*)arr;
+(NSArray*)sortStrArrDesc:(NSArray*)arr;
+(double)getWidthWithString:(NSString*)str font:(UIFont*)font;
+(double)getBMI:(double)weight;
+(NSString*)getBMIDes:(double)bmi;
+(NSData*)convertHexStrToData:(NSString *)str;
+(NSString*)convertHexStrToStr:(NSString*)hexStr;
+(void)popViewControllerWithClass:(Class)cls navigationController:(UINavigationController*)navigationController;
//从图片中点为中心算起，按指定的框截取图片
+(UIImage*)trimImageInCenter:(UIImage*)scaledImage centerW:(float)centerW centerH:(float)centerW;
+(UIImage *)resizeImage:(UIImage *)image width:(float)width height:(float)height;
+(NSString*)macWithSplit:(NSString*)macWithoutSplit;

+(CGSize)getSizeWithString:(NSString*)str font:(UIFont*)font;

+ (BOOL)isLogin;

+ (BOOL)isUserDeleteWatch;
+ (void)setIsUserDeleteWatch:(BOOL)isUserDeleteWatch;

+ (void)setAppChannel:(NSString *)channel;
+ (NSString *)appChannelName;

+ (void)saveAbilityLimit:(NSArray *)abilityLimit;
+ (BOOL)isSupportAd;
+ (BOOL)isSupportAIGC;
+ (BOOL)isSupportCHATGPT;
+ (BOOL)isSupportTRANS;

+ (NSString *)deviceUUid;


@end

#endif /* HOETool_h */
