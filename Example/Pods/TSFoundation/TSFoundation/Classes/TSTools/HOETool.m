//
//  #import <TSFoundation/TSFoundation.h>m
//  JieliJianKang
//
//  Created by mac on 2022/9/24.
//

#import <Foundation/Foundation.h>
#import <TSFoundation/TSFoundation.h>
#import "NSDate+Tools.h"
#import "CommonCrypto/CommonDigest.h"
//#import <TSRequest/TSRequestConst.h>
#import "ColorConst.h"

@implementation HOETool

+(NSString *)getUserByKey:(NSString *)key{
    
    return  [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+(void)setUser:(id)user forKey:(NSString *)key{
    if (key == nil) {return;}
    if (key.length == 0) {return;}
    if ([key isEqualToString:@""]) {return;}
    [[NSUserDefaults standardUserDefaults] setObject:user forKey:key];
}

+ (void)removeUserByKey:(NSString *)key{
    if (key == nil) {return;}
    if (key.length == 0) {return;}
    if ([key isEqualToString:@""]) {return;}

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}


+(JLUser*)getUserInfoLocal{
    JLUser* userInfo = [[JLUser alloc] init];
    userInfo.nickname = [HOETool getUserByKey:@"nickName"];
    userInfo.gender = [[HOETool getUserByKey:@"gender"] intValue];
    userInfo.birthYear = [[HOETool getUserByKey:@"birthYear"] intValue];
    userInfo.birthMonth = [[HOETool getUserByKey:@"birthMonth"] intValue];
    userInfo.birthDay = [[HOETool getUserByKey:@"birthDay"] intValue];
    userInfo.height = [[HOETool getUserByKey:@"height"] intValue];
    userInfo.weight = [[HOETool getUserByKey:@"weight"] floatValue];
    return userInfo;
}

+(void)setUserLocal:(NSString*)nickName gender:(int)gender birthYear:(int)birthYear birthMonth:(int)birthMonth birthDay:(int)birthDay height:(int)height weight:(float)weight targetStep:(int)step{
    if(nickName != nil && ![nickName isEqualToString:kJL_TXT("请填写")]){
        [HOETool setUser:nickName forKey:@"nickName"];
    }
    if(gender > -1){
        [HOETool setUser:@(gender) forKey:@"gender"];
    }
    if(birthYear > 0 && birthMonth > 0 && birthDay > 0){
        [HOETool setUser:@(birthYear) forKey:@"birthYear"];
        [HOETool setUser:@(birthMonth) forKey:@"birthMonth"];
        [HOETool setUser:@(birthDay) forKey:@"birthDay"];
    }
    if(height > 0){
        [HOETool setUser:@(height) forKey:@"height"];
    }
    if(weight > 0){
        [HOETool setUser:@(weight) forKey:@"weight"];
    }
    if(step > 0){
        [HOETool setUser:@(step) forKey:@"step"];
    }
}

+(void)setTodayStepLocal:(int)todayStep{
    NSString* todayYYMMDD = [NSDate date].toYYYYMMdd;
    NSString* todayStepStr = [todayYYMMDD stringByAppendingString:[NSString stringWithFormat:@";%d",todayStep]];
    [HOETool setUser:todayStepStr forKey:@"todayStep"];
}

+(int)getTodayStepLocal{
    if([HOETool getUserByKey:@"todayStep"] != nil){
        NSString* todayStepStr = [HOETool getUserByKey:@"todayStep"];
        NSArray *array = [todayStepStr componentsSeparatedByString:@";"];
        NSString* todayYYMMDD = [NSDate date].toYYYYMMdd;
        if([array[0] isEqualToString:todayYYMMDD]){
            return [array[1] intValue];
        }else{
            return 0;
        }
    }
    return 0;
}

+(void)setTodayActNumLocal:(int)actNum{
    NSString* todayYYMMDD = [NSDate date].toYYYYMMdd;
    NSString* todayStepStr = [todayYYMMDD stringByAppendingString:[NSString stringWithFormat:@";%d",actNum]];
    [HOETool setUser:todayStepStr forKey:@"actNum"];
}

+(int)getTodayActNumLocal{
    if([HOETool getUserByKey:@"actNum"] != nil){
        NSString* todayStepStr = [HOETool getUserByKey:@"actNum"];
        NSArray *array = [todayStepStr componentsSeparatedByString:@";"];
        NSString* todayYYMMDD = [NSDate date].toYYYYMMdd;
        if([array[0] isEqualToString:todayYYMMDD]){
            return [array[1] intValue];
        }else{
            return 0;
        }
    }
    return 0;
}

+(void)setTodayCalLocal:(float)todayCal{
    NSString* todayYYMMDD = [NSDate date].toYYYYMMdd;
    NSString* todayStepStr = [todayYYMMDD stringByAppendingString:[NSString stringWithFormat:@";%f",todayCal]];
    [HOETool setUser:todayStepStr forKey:@"todayCal"];
}

+(float)getTodayCal{
    if([HOETool getUserByKey:@"todayCal"] != nil){
        NSString* todayStepStr = [HOETool getUserByKey:@"todayCal"];
        NSArray *array = [todayStepStr componentsSeparatedByString:@";"];
        NSString* todayYYMMDD = [NSDate date].toYYYYMMdd;
        if([array[0] isEqualToString:todayYYMMDD]){
            return [array[1] floatValue];
        }else{
            return 0;
        }
    }
    return 0;
}

+(void)setTodaySportDurationLocal:(float)todaySportDuration{
    NSString* todayYYMMDD = [NSDate date].toYYYYMMdd;
    NSString* todayStepStr = [todayYYMMDD stringByAppendingString:[NSString stringWithFormat:@";%f",todaySportDuration]];
    [HOETool setUser:todayStepStr forKey:@"todaySportDuration"];
}

+(float)getTodaySportDurationLocal{
    if([HOETool getUserByKey:@"todaySportDuration"] != nil){
        NSString* todayStepStr = [HOETool getUserByKey:@"todaySportDuration"];
        NSArray *array = [todayStepStr componentsSeparatedByString:@";"];
        NSString* todayYYMMDD = [NSDate date].toYYYYMMdd;
        if([array[0] isEqualToString:todayYYMMDD]){
            return [array[1] floatValue];
        }else{
            return 0;
        }
    }
    return 0;
}

+(void)setTodayDistanceLocal:(float)todayDistance{
    NSString* todayYYMMDD = [NSDate date].toYYYYMMdd;
    NSString *numString =  [NSDecimalNumber getDecimalByNumber:@(todayDistance) scale:2 roudMode:NSRoundDown].stringValue;
    NSString* todayStepStr = [todayYYMMDD stringByAppendingString:[NSString stringWithFormat:@";%@",numString]];
    [HOETool setUser:todayStepStr forKey:@"todayDistance"];
}

+(float)getTodayDistance{
    if([HOETool getUserByKey:@"todayDistance"] != nil){
        NSString* todayStepStr = [HOETool getUserByKey:@"todayDistance"];
        NSArray *array = [todayStepStr componentsSeparatedByString:@";"];
        NSString* todayYYMMDD = [NSDate date].toYYYYMMdd;
        if([array[0] isEqualToString:todayYYMMDD]){
            return [array[1] floatValue];
        }else{
            return 0;
        }
    }
    return 0;
}

+(NSString*)getLocalUserId{
    if([HOETool getUserByKey:@"localUserId"] == nil){
        NSDate *datenow = [NSDate date];
        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
        [HOETool setUser:timeSp forKey:@"localUserId"];
    }
    return [HOETool getUserByKey:@"localUserId"];
}

+(void)addOneKeyHeartRateResults:(int)heartRate recordTime:(NSTimeInterval)recordTime{
    [self addOneKeyResults:@"OneKeyHeartRateRustls" value:heartRate recordTime:recordTime];
}

+(NSString*)getOneKeyHeartRateResults{
    return [HOETool getUserByKey:@"OneKeyHeartRateRustls"];
}

+(void)addOneKeyLastHeartRateResults:(int)avg min:(int)min max:(int)max recordTime:(NSTimeInterval)recordTime{
    [self addOneKeyLastResults:@"OneKeyLastHeartRateResults" avg:avg min:min max:max recordTime:recordTime];
}

+(NSString*)getOneKeyLastHeartRateResults{
    return [HOETool getUserByKey:@"OneKeyLastHeartRateResults"];
}

+(void)addOneKeyPressureResults:(int)pressure recordTime:(NSTimeInterval)recordTime{
    [self addOneKeyResults:@"OneKeyPressureResults" value:pressure recordTime:recordTime];
}

+(NSString*)getOneKeyPressureResults{
    return [HOETool getUserByKey:@"OneKeyPressureResults"];
}

+(void)addOneKeyLastPressureResults:(int)avg min:(int)min max:(int)max recordTime:(NSTimeInterval)recordTime{
    [self addOneKeyLastResults:@"OneKeyLastPressureResults" avg:avg min:min max:max recordTime:recordTime];
}

+(NSString*)getOneKeyLastPressureResults{
    return [HOETool getUserByKey:@"OneKeyLastPressureResults"];
}

+(void)addOneKeyBloodOxygenResults:(int)bloodOxygen recordTime:(NSTimeInterval)recordTime{
    [self addOneKeyResults:@"OneKeyBloodOxygenResults" value:bloodOxygen recordTime:recordTime];
}

+(NSString*)getOneKeyBloodOxygenResults{
    return [HOETool getUserByKey:@"OneKeyBloodOxygenResults"];
}

+(void)addOneKeyLastBloodOxygenResults:(int)avg min:(int)min max:(int)max recordTime:(NSTimeInterval)recordTime{
    [self addOneKeyLastResults:@"OneKeyLastBloodOxygenResults" avg:avg min:min max:max recordTime:recordTime];
}

+(NSString*)getOneKeyLastBloodOxygenResults{
    return [HOETool getUserByKey:@"OneKeyLastBloodOxygenResults"];
}

//app是否至少连接过一次设备
+(void)setHasConnectedOnce{
    [HOETool setUser:@"1234" forKey:@"hasConnectedOnce"];
}

//app是否至少连接过一次设备
+(BOOL)getHasConnectedOnce{
    if([HOETool getUserByKey:@"hasConnectedOnce"] != nil){
        return YES;
    }else{
        return  NO;
    }
}

+(void)addOneKeyResults:(NSString*)key value:(int)value recordTime:(NSTimeInterval)recordTime{
    NSString* str = [NSString stringWithFormat:@"%d,%f",value,recordTime];
    if([HOETool getUserByKey:key] == nil){
        [HOETool setUser:str forKey:key];
    }else{
        NSString* historyRecord = [HOETool getUserByKey:key];
        NSArray* arr = [historyRecord componentsSeparatedByString:@";"];
        NSString* curRecord;
        if(arr.count > 9){
            NSMutableArray *marr = [[NSMutableArray alloc] initWithArray:arr];
            [marr removeObjectAtIndex:0];
            [marr addObject:str];
            curRecord = [marr componentsJoinedByString:@";"];
        }else{
            curRecord = [NSString stringWithFormat:@"%@;%@",historyRecord,str];
        }
        [HOETool setUser:curRecord forKey:key];
    }
}

+(void)addOneKeyLastResults:(NSString*)key avg:(int)avg min:(int)min max:(int)max recordTime:(NSTimeInterval)recordTime{
    NSString* str = [NSString stringWithFormat:@"%d,%d,%d,%f",avg,min,max,recordTime];
    [HOETool setUser:str forKey:key];
}


+(NSArray*)getDrinkRemindData{
    if([HOETool getUserByKey:@"drinkRemind"] == nil){
        return nil;
    }else{
        NSString* historyRecord = [HOETool getUserByKey:@"drinkRemind"];
        NSArray* arr = [historyRecord componentsSeparatedByString:@","];
        return arr;
    }
}

+(void)setDrinkRemindData:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin noonNotDisturb:(int)noonNotDisturb{
    NSString* dataStr = [NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d",status,startHour,startMin,endHour,endMin,noonNotDisturb];
    [HOETool setUser:dataStr forKey:@"drinkRemind"];
}

+(NSArray*)getJiuzuoRemindData{
    if([HOETool getUserByKey:@"jiuzuoRemind"] == nil){
        return nil;
    }else{
        NSString* historyRecord = [HOETool getUserByKey:@"jiuzuoRemind"];
        NSArray* arr = [historyRecord componentsSeparatedByString:@","];
        return arr;
    }
}

+(void)setJiuzuoRemindData:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin noonNotDisturb:(int)noonNotDisturb{
    NSString* dataStr = [NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d",status,startHour,startMin,endHour,endMin,noonNotDisturb];
    [HOETool setUser:dataStr forKey:@"jiuzuoRemind"];
}

+(NSArray*)getTaiwanData{
    if([HOETool getUserByKey:@"taiwanLiangping"] == nil){
        return nil;
    }else{
        NSString* historyRecord = [HOETool getUserByKey:@"taiwanLiangping"];
        NSArray* arr = [historyRecord componentsSeparatedByString:@","];
        return arr;
    }
}

+(void)setTaiwanData:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin{
    NSString* dataStr = [NSString stringWithFormat:@"%d,%d,%d,%d,%d",status,startHour,startMin,endHour,endMin];
    [HOETool setUser:dataStr forKey:@"taiwanLiangping"];
}

+(NSArray*)getNoDisturbData{
    if([HOETool getUserByKey:@"noDisturb"] == nil){
        return nil;
    }else{
        NSString* historyRecord = [HOETool getUserByKey:@"noDisturb"];
        NSArray* arr = [historyRecord componentsSeparatedByString:@","];
        return arr;
    }
}

+(void)setNoDisturbData:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin {
    NSString* dataStr = [NSString stringWithFormat:@"%d,%d,%d,%d,%d",status,startHour,startMin,endHour,endMin];
    [HOETool setUser:dataStr forKey:@"noDisturb"];
}

+(int)hearRate2Pressure:(int)hearRateAvg{
    int pressure = 0;
    if(hearRateAvg <= 39){
        pressure = 0;
    }else if (hearRateAvg > 39 && hearRateAvg < 60) {
        pressure = ((hearRateAvg - 40) * 40) / 20;
    } else if (hearRateAvg >= 60 && hearRateAvg < 80) {
        pressure = 40 + ((hearRateAvg - 40) * 10) / 20;
    } else if (hearRateAvg >= 80 && hearRateAvg < 100) {
        pressure = 50 + ((hearRateAvg - 80) * 10) / 20;
    } else if (hearRateAvg >= 100 && hearRateAvg < 120) {
        pressure = 60 + ((hearRateAvg - 100) * 20) / 20;
    } else if (hearRateAvg >= 120 && hearRateAvg < 150) {
        pressure = 80 + ((hearRateAvg - 120) * 20) / 30;
    } else{
        pressure = 99;//最大压力
    }
    return pressure;
}

+(NSString*)getPressureDes:(int)avg{
    NSString* des = @"";
    if(avg>=1&&avg<=29){
        des = kJL_TXT("放松");
    }else if(avg>=30&&avg<=59){
        des = kJL_TXT("正常");
    }else if(avg>=60&&avg<=79){
        des = kJL_TXT("中等");
    }else if(avg>=80&&avg<=99){
        des = kJL_TXT("偏高");
    }
    return des;
}

+(NSArray*)getBleHistoryPeripheralArr{
    if([HOETool getUserByKey:@"bleHistoryUUID"] == nil){
        return nil;
    }else{
        NSString* historyRecord = [HOETool getUserByKey:@"bleHistoryUUID"];
        NSArray* arr = [historyRecord componentsSeparatedByString:@",,,"];
        return arr;
    }
}

+(void)addBleHistoryPeripheral:(NSString*)uuidStr{
    if([HOETool getUserByKey:@"bleHistoryUUID"] == nil){
        [HOETool setUser:uuidStr forKey:@"bleHistoryUUID"];
    }else{
        NSString* historyRecord = [HOETool getUserByKey:@"bleHistoryUUID"];
        NSArray* arr = [historyRecord componentsSeparatedByString:@",,,"];
        BOOL hasExist = NO;
        for(int i=0;i<arr.count;i++){
            NSString* tmpStr = arr[i];
            if([tmpStr isEqualToString:uuidStr]){
                hasExist = YES;
            }
        }
        if(!hasExist){
            NSString* add = [NSString stringWithFormat:@"%@,,,%@",historyRecord,uuidStr];//不太清楚uuid会不会有逗号,故用3个逗号做分隔符,以防万一,防止混淆
            [HOETool setUser:add forKey:@"bleHistoryUUID"];
        }
    }
}

+(NSArray*)getFemaleCycleData{
    if([HOETool getUserByKey:@"femaleCycle"] == nil){
        return nil;
    }else{
        NSString* historyRecord = [HOETool getUserByKey:@"femaleCycle"];
        NSArray* arr = [historyRecord componentsSeparatedByString:@","];
        return arr;
    }
}

+(void)setFemaleCycleData:(int)status lastTime:(NSTimeInterval)lastTime duration:(int)duration period:(int)period jingqiOn:(int)jingqiOn beginPailuanOn:(int)beginPailuanOn endPailuanOn:(int)endPailuanOn{
    NSString* dataStr = [NSString stringWithFormat:@"%d,%.0f,%d,%d,%d,%d,%d",status,lastTime,duration,period,jingqiOn,beginPailuanOn,endPailuanOn];
    [HOETool setUser:dataStr forKey:@"femaleCycle"];
}

+(int)getAvatarBgColorId{
    NSString* colorId = [HOETool getUserByKey:@"avatarBgColorId"];
    if(colorId == nil){
        return 0;
    }else{
        return [colorId intValue];
    }
}

+(void)setAvatarBgColorId:(int)colorId{
    [HOETool setUser:[NSString stringWithFormat:@"%d",colorId] forKey:@"avatarBgColorId"];
}

+(int)getAvatarId{
    NSString* avatarId = [HOETool getUserByKey:@"avatarId"];
    if(avatarId == nil){
        return 0;
    }else{
        return [avatarId intValue];
    }
}



+(void)setAvatarId:(int)avatarId{
    [HOETool setUser:[NSString stringWithFormat:@"%d",avatarId] forKey:@"avatarId"];
}

+ (NSString *)avatarUrl{
    return [HOETool getUserByKey:@"avatarUrl"];
}

+ (void)setAvatarUrl:(NSString *)avatarUrl{
    [HOETool setUser:avatarUrl forKey:@"avatarUrl"];
}

+(NSArray*)getBloodOxygenMode{
    if([HOETool getUserByKey:@"bloodOxygenMode"] == nil){
        return nil;
    }else{
        NSString* historyRecord = [HOETool getUserByKey:@"bloodOxygenMode"];
        NSArray* arr = [historyRecord componentsSeparatedByString:@","];
        return arr;
    }
}

+(void)setBloodOxygenMode:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin{
    NSString* dataStr = [NSString stringWithFormat:@"%d,%d,%d,%d,%d",status,startHour,startMin,endHour,endMin];
    [HOETool setUser:dataStr forKey:@"bloodOxygenMode"];
}

+(NSArray*)getHeartRateMode{
    if([HOETool getUserByKey:@"lianxvHeartRateMode"] == nil){
        return nil;
    }else{
        NSString* historyRecord = [HOETool getUserByKey:@"lianxvHeartRateMode"];
        NSArray* arr = [historyRecord componentsSeparatedByString:@","];
        return arr;
    }
}

+(void)setHeartRateMode:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin{
    NSString* dataStr = [NSString stringWithFormat:@"%d,%d,%d,%d,%d",status,startHour,startMin,endHour,endMin];
    [HOETool setUser:dataStr forKey:@"lianxvHeartRateMode"];
}

+(NSArray*)getSleepMode{
    if([HOETool getUserByKey:@"sleepMonitorMode"] == nil){
        return nil;
    }else{
        NSString* historyRecord = [HOETool getUserByKey:@"sleepMonitorMode"];
        NSArray* arr = [historyRecord componentsSeparatedByString:@","];
        return arr;
    }
}

+(void)setSleepMode:(int)status startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin{
    NSString* dataStr = [NSString stringWithFormat:@"%d,%d,%d,%d,%d",status,startHour,startMin,endHour,endMin];
    [HOETool setUser:dataStr forKey:@"sleepMonitorMode"];
}

+(void)setHomeInUseCard:(NSArray*)arr{
    if(arr == nil){
        [HOETool removeUserByKey:@"homeInUseCard"];
    }else{
        NSString* str = [arr componentsJoinedByString:@","];
        [HOETool setUser:str forKey:@"homeInUseCard"];
    }
}

+(NSMutableArray*)getHomeInUseCard{
    if([HOETool getUserByKey:@"homeInUseCard"] == nil){
        return nil;
    }else{
        NSString* historyRecord = [HOETool getUserByKey:@"homeInUseCard"];
        NSArray* arr = [historyRecord componentsSeparatedByString:@","];
        NSMutableArray* marr = [NSMutableArray arrayWithArray:arr];
        return marr;
    }
}
+(void)setHomeNotUseCard:(NSArray*)arr{
    if(arr == nil){
        [HOETool removeUserByKey:@"homeNotUseCard"];
    }else{
        NSString* str = [arr componentsJoinedByString:@","];
        [HOETool setUser:str forKey:@"homeNotUseCard"];
    }
}

+(NSMutableArray*)getHomeNotUseCard{
    if([HOETool getUserByKey:@"homeNotUseCard"] == nil){
        return nil;
    }else{
        NSString* historyRecord = [HOETool getUserByKey:@"homeNotUseCard"];
        NSArray* arr = [historyRecord componentsSeparatedByString:@","];
        NSMutableArray* marr = [NSMutableArray arrayWithArray:arr];
        return marr;
    }
}


+(NSData *)byteArray2Data:(NSArray *)array {
    NSMutableData *data = [NSMutableData data];
    [array enumerateObjectsUsingBlock:^(NSNumber* number, NSUInteger index, BOOL* stop) {
        uint8_t tmp = number.unsignedCharValue;
        [data appendBytes:(void *)(&tmp)length:1];
    }];
    
    return data;
}

+(NSArray *)byteData2Array:(NSData *)data {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            [array addObject:[NSNumber numberWithInt:(dataBytes[i]) & 0xff]];
        }
    }];
    
    return array;
}

+(NSString*)strFormatToJsonStr:(NSString*)str{
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError * err = nil;
    id jsonobj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
    if(err!= nil)return nil;
    return  jsonobj;
}

+(NSString*)objectToJsonStr:(NSDictionary*)dic{
    NSError* err= nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:&err];
    NSString * jsons = nil;//[[NSString alloc]init];
    if(err==nil){
        jsons = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    return  jsons;
    
}

+(BOOL)isValidJson:(id)jsonString{
    BOOL isStrClass = [jsonString isKindOfClass:[NSString class]];
    if(!isStrClass){
        return YES;//不是字符串类型的，则认为已经是解析好的json，直接返回true
    }
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (result) {
        return YES;
    } else {
        return NO;
    }
}

+(NSDictionary*)dictionaryWithJsonString:(NSString*)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+(double)km2CaloriesWithKm:(double)km weight:(double)weight{
    return 0.78*weight*km;
}

+(NSDictionary*)dictionaryWithJsonNSDate:(NSData*)jsonData{
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+(NSData*)toJsonNSDataWithObject:(NSObject*)obj keys:(NSArray*)keys{
    NSDictionary* dic = [obj dictionaryWithValuesForKeys:keys];
    NSError *err;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:&err];
    if(err) {
        NSLog(@"TS_SportRecord json解析失败：%@",err);
        return nil;
    }
    return data;
}

+(void)setCaloriesGoal:(double)goal{
    if(goal <= 0){
        [HOETool setUser:nil forKey:@"caloriesGoal"];
    }else{
        [HOETool setUser:@(goal) forKey:@"caloriesGoal"];
    }
    [self regTargetModifyTime];
}

+(double)getCaloriesGoal{
    id obj = [HOETool getUserByKey:@"caloriesGoal"];
    if(obj){
        return [obj doubleValue];
    }else{
        return 50;
    }
}

+(void)setSportTimeGoal:(int)goal{
    if(goal<=0){
        [HOETool setUser:nil forKey:@"sportTimeGoal"];
    }else{
        [HOETool setUser:@(goal) forKey:@"sportTimeGoal"];
    }
    [self regTargetModifyTime];
}

//单位分钟，运动时长
+(int)getSportTimeGoal{
    id obj = [HOETool getUserByKey:@"sportTimeGoal"];
    if(obj){
        return [obj intValue];
    }else{
        return 30;
    }
}

+(void)setStepGoal:(int)goal{
    if(goal<=0){
        [HOETool setUser:nil forKey:@"stepGoal"];
    }else{
        [HOETool setUser:@(goal) forKey:@"stepGoal"];
    }
    [self regTargetModifyTime];
}

+(int)getStepGoal{
    id obj = [HOETool getUserByKey:@"stepGoal"];
    if(obj){
        return [obj intValue];
    }else{
        return 8000;
    }
}

+(void)setSleepGoal:(int)goal{
    if(goal<=0){
        [HOETool setUser:nil forKey:@"sleepGoal"];
    }else{
        [HOETool setUser:@(goal) forKey:@"sleepGoal"];
    }
}

+(int)getSleepGoal{
    id obj = [HOETool getUserByKey:@"sleepGoal"];
    if(obj){
        return [obj intValue];
    }else{
        return 8*60;
    }
}

//单位米
+(void)setDistanceGoal:(float)goal{
    if(goal <= 0){
        [HOETool setUser:nil forKey:@"distanceGoal"];
    }else{
        [HOETool setUser:@(goal) forKey:@"distanceGoal"];
    }
    [self regTargetModifyTime];
}

+(float)getDistanceGoal{
    id obj = [HOETool getUserByKey:@"distanceGoal"];
    if(obj){
        return [obj intValue];
    }else{
        return 1000;
    }
}

+(void)setActivityCountGoal:(int)goal{
    if(goal <= 0){
        [HOETool setUser:nil forKey:@"activityCountGoal"];
    }else{
        [HOETool setUser:@(goal) forKey:@"activityCountGoal"];
    }
    [self regTargetModifyTime];
}

+(int)getActivityCountGoal{
    id obj = [HOETool getUserByKey:@"activityCountGoal"];
    if(obj){
        return [obj intValue];
    }else{
        return 1;
    }
}

//单位分钟
+(void)setActivityDurationGoal:(int)goal{
    if(goal <= 0){
        [HOETool setUser:nil forKey:@"activityDurationGoal"];
    }else{
        [HOETool setUser:@(goal) forKey:@"activityDurationGoal"];
    }
    [self regTargetModifyTime];
}

//单位分钟
+(int)getActivityDurationGoal{
    id obj = [HOETool getUserByKey:@"activityDurationGoal"];
    if(obj){
        return [obj intValue];
    }else{
        return 30;
    }
}

+(void)setWeightGoal:(double)goal{
    if(goal <= 0){
        [HOETool setUser:nil forKey:@"weightGoal"];
    }else{
        [HOETool setUser:@(goal) forKey:@"weightGoal"];
    }
//    [self regTargetModifyTime];//体重目标不上传到手表
}

+(double)getWeightGoal{
    id obj = [HOETool getUserByKey:@"weightGoal"];
    if(obj){
        return [obj doubleValue];
    }else{
        return 50;
    }
}

+(long)getTargetModifyTime{
    id obj = [HOETool getUserByKey:@"targetModifyTime"];
    if(obj){
        return [obj longValue];
    }else{
        return 1;//不要设为0，保持未设置的状态就要比手表优先，否则可能会被手表上的空值覆盖
    }
}

+(void)regTargetModifyTime{
    long targetModifyTime = [[NSDate new] timeIntervalSince1970];
    [self setTargetModifyTime:targetModifyTime];
}

+(void)setTargetModifyTime:(long)targetModifyTime{
    [HOETool setUser:@(targetModifyTime) forKey:@"targetModifyTime"];
}

+(NSString*)getUserId{   
    if([HOETool getUserByKey:@"userId"] == nil){
        [HOETool setUser:@"9223372036854775807" forKey:@"userId"];//游客id，java里long的最大值，有符号long9223372036854775807
    }
    return [HOETool getUserByKey:@"userId"];
}

+(void)setUserId:(NSString*)userId{
    [HOETool setUser:userId forKey:@"userId"];
}

+(NSString*)getNickname{
    return [HOETool getUserByKey:@"tsNickname"];
}

+(void)setNickname:(NSString*)nickname{
    [HOETool setUser:nickname forKey:@"tsNickname"];
}

//0--女  1--男
+(int)getGender{
    if([HOETool getUserByKey:@"tsGender"] == nil){
        return 0;
    }
    return [[HOETool getUserByKey:@"tsGender"] intValue];
}

//0--女  1--男
+(void)setGender:(int)gender{
    [HOETool setUser:[NSString stringWithFormat:@"%d",gender] forKey:@"tsGender"];
}

//1990-08-07形式
+(NSString*)getBirthday{
    return [HOETool getUserByKey:@"tsBirthday"];
}

//1990-08-07形式
+(void)setBirthday:(NSString*)birthday{
    [HOETool setUser:birthday forKey:@"tsBirthday"];
}

+(int)getUserAge{
    NSString* birthday = [self getBirthday];
    if(birthday){
        NSString* curDate = [NSDate new].toYYYYMM;
        int age = [[curDate componentsSeparatedByString:@"-"][0] intValue] - [[birthday componentsSeparatedByString:@"-"][0] intValue];
        return age>=0 ? age : 0;
    }else{
        return 0;
    }
}

+(float)getHeight{
    if([HOETool getUserByKey:@"tsHeight"] == nil || [[HOETool getUserByKey:@"tsHeight"] intValue]==0){
        return 170;
    }
    return [[HOETool getUserByKey:@"tsHeight"] intValue];
}

+(void)setHeight:(float)height{
    [HOETool setUser:[NSString stringWithFormat:@"%d",(int)height] forKey:@"tsHeight"];
}

+(float)getWeight{
    if([HOETool getUserByKey:@"tsWeight"] == nil){
        return 60;
    }
    return [[HOETool getUserByKey:@"tsWeight"] intValue];
}

+(void)setWeight:(float)weight{
    [HOETool setUser:[NSString stringWithFormat:@"%d",(int)weight] forKey:@"tsWeight"];
}

+(BOOL)getIsVisitor{
    return [HOETool getUserByKey:@"isVisitor"] != nil;
}

+(void)setIsVisitor:(BOOL)isVisitor{
    if(isVisitor){
        [HOETool setUser:@"any" forKey:@"isVisitor"];
    }else{
        [HOETool setUser:nil forKey:@"isVisitor"];
    }
}

+(NSString*)getUserPhone{
    return [HOETool getUserByKey:@"phone"];
}

+(void)setUserPhone:(NSString*)phone{
    [HOETool setUser:phone forKey:@"phone"];
}

+(NSString*)getUserEmail{
    return [HOETool getUserByKey:@"email"];
}

+(void)setUserEmail:(NSString*)email{
    [HOETool setUser:email forKey:@"email"];
}

+(void)clearOnLogout{
    [HOETool setToken:nil];
    [HOETool setUserId:nil];
    [HOETool setUserPhone:nil];
    [HOETool setUserEmail:nil];
    [HOETool setIsVisitor:NO];
    [HOETool setNickname:nil];
    [HOETool setBirthday:nil];
    [HOETool setGender:0];
    [HOETool setHeight:0];
    [HOETool setWeight:0];
    [HOETool setStepGoal:-1];
    [HOETool setActivityCountGoal:-1];
    [HOETool setSportTimeGoal:-1];
    [HOETool setProjectId:nil];
}

+(void)setUserLoginInfo:(NSString*)nickName gender:(int)gender birthDay:(NSString*)birthday height:(int)height weight:(float)weight targetStep:(int)step targetActNum:(int)targetActNum targetSportDur:(int)targetSportDur{
    [HOETool setNickname:nickName];
    [HOETool setGender:gender];
    [HOETool setBirthday:birthday];
    [HOETool setHeight:height];
    [HOETool setWeight:weight];
    [HOETool setStepGoal:step];
    [HOETool setActivityCountGoal:targetActNum];
    [HOETool setSportTimeGoal:targetSportDur];
}

+(NSString*)getDeviceMac{
    if([HOETool getUserByKey:@"deviceMac"] == nil){
        [HOETool setUser:@"0" forKey:@"deviceMac"];//不明设备
    }
    return [HOETool getUserByKey:@"deviceMac"];
}

+(void)setDeviceMac:(NSString*)deviceMac{
    [HOETool setUser:deviceMac forKey:@"deviceMac"];
}

+(NSString*)getProjectId{
    if([HOETool getUserByKey:@"projectId"] == nil){
        [HOETool setUser:@"000000007000" forKey:@"projectId"];//不明设备
    }
    return [HOETool getUserByKey:@"projectId"];
}

+(void)setProjectId:(NSString*)projectId{
    [HOETool setUser:projectId forKey:@"projectId"];
}

+(NSString*)getMobo{
    return [HOETool getUserByKey:@"mobo"];
}

+(void)setMobo:(NSString*)mobo{
    [HOETool setUser:mobo forKey:@"mobo"];
}

+(int)getBattery{
    if([HOETool getUserByKey:@"deviceBattery"] == nil){
        [HOETool setUser:@(100) forKey:@"deviceBattery"];
    }
    return [[HOETool getUserByKey:@"deviceBattery"] intValue];
}

+(void)setBattery:(int)battery{
    [HOETool setUser:@(battery) forKey:@"deviceBattery"];
}


+(NSString *) md5: (NSString *) inPutText {
    if (!inPutText) {
        return nil;
    }
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
            ] lowercaseString];
}

+(NSString *) md5WithSalt: (NSString *) inPutText salt:(NSString*)salt {
    NSString* tmp = [NSString stringWithFormat:@"%@%@",inPutText,salt];
    return [self md5:tmp];
}

+(NSString*)getFileNameWithoutExtendName:(NSString*)wholeFileName{
    NSRange range = [wholeFileName rangeOfString:@"." options:NSBackwardsSearch];
    NSString* b = [wholeFileName substringToIndex:range.location];
    return b;
}

+(NSString*)getExtendNameWithWholeName:(NSString*)wholeFileName{
    NSRange range = [wholeFileName rangeOfString:@"." options:NSBackwardsSearch];
    NSString* d = [wholeFileName substringFromIndex:(range.location+1)];
    return d;
}

+ (void)bundleToDocuments:(NSString *)dir fileName:(NSString *)fileName existsCover:(BOOL)cover
{
    BOOL success;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//找到 Documents 目录
    NSString *createDir = [documentsDirectory stringByAppendingPathComponent:dir];
    NSString *targetPath = [createDir stringByAppendingPathComponent:fileName];
    
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:createDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ){
        [fileManager createDirectoryAtPath:createDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if(!cover)
    {
        success = [fileManager fileExistsAtPath:targetPath];
        if (success) return;
    }else{
        [fileManager removeItemAtPath:targetPath error:&error];
    }
    //把 xxx.app 包里的文件拷贝到 targetPath
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    //如果文件存在了则不能覆盖，所以前面才要先把它删除掉
    success = [fileManager copyItemAtPath:bundlePath toPath:targetPath error:&error];
    if(!success)
        NSLog(@"'%@' 文件从 app 包里拷贝到 Documents 目录，失败:%@", fileName, error);
    else
        NSLog(@"'%@' 文件从 app 包里已经成功拷贝到了 Documents 目录。", fileName);
}

+ (void)copyToDocuments:(NSString *)dir fileName:(NSString *)fileName existsCover:(BOOL)cover
{
    BOOL success;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//找到 Documents 目录
    NSString *createDir = [documentsDirectory stringByAppendingPathComponent:dir];
    NSString *targetPath = [createDir stringByAppendingPathComponent:fileName];
    
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:createDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ){
        [fileManager createDirectoryAtPath:createDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if(!cover)
    {
        success = [fileManager fileExistsAtPath:targetPath];
        if (success) return;
    }else{
        [fileManager removeItemAtPath:targetPath error:&error];
    }
    //把 xxx.app 包里的文件拷贝到 targetPath
    NSString *fromPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    //如果文件存在了则不能覆盖，所以前面才要先把它删除掉
    success = [fileManager copyItemAtPath:fromPath toPath:targetPath error:&error];
    if(!success)
        NSLog(@"'%@' 文件拷贝到 Documents 目录，失败:%@", fileName, error);
    else
        NSLog(@"'%@' 文件已经成功拷贝到了 Documents 目录。", fileName);
}

+(NSString*)getFirmVersion{
    if([HOETool getUserByKey:@"firmVersion"] == nil){
        [HOETool setUser:@"1.0" forKey:@"firmVersion"];//不明设备
    }
    return [HOETool getUserByKey:@"firmVersion"];
}

+(void)setFirmVersion:(NSString*)firmVersion{
    [HOETool setUser:firmVersion forKey:@"firmVersion"];
}

+ (NSString*)getVirtualVersion {
    if([HOETool getUserByKey:@"virtualVersion"] == nil){
        [HOETool setUser:@"1.0" forKey:@"virtualVersion"];//不明设备
    }
    return [HOETool getUserByKey:@"virtualVersion"];
}

+ (void)setVirtualVersion:(NSString*)virtualVersion {
    [HOETool setUser:virtualVersion forKey:@"virtualVersion"];
}


+(NSString*)getJsVersion{
    if([HOETool getUserByKey:@"jsVersion"] == nil){
        [HOETool setUser:@"0.0" forKey:@"jsVersion"];//不明设备
    }
    return [HOETool getUserByKey:@"jsVersion"];
}

+(void)setJsVersion:(NSString*)jsVersion{
    [HOETool setUser:jsVersion forKey:@"jsVersion"];
}

+(NSString*)getAppVersion{
    NSBundle *mainBundle = [NSBundle mainBundle];
    if (mainBundle) {
        NSString *version = [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        return version;
    }
    return nil;
}

+(NSString*)getSysVersion{
    return [UIDevice currentDevice].systemVersion;
}

+(NSString*)getAppDeviceId{
    if([HOETool getUserByKey:@"appDeviceId"] == nil){
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [HOETool setUser:uuid forKey:@"appDeviceId"];
    }
    return [HOETool getUserByKey:@"appDeviceId"];
}

+(NSString*)getToken{
    if([HOETool getUserByKey:@"token"] == nil){
        return @"";
    }
    return [HOETool getUserByKey:@"token"];
}

+(void)setToken:(NSString*)token{
    [HOETool setUser:token forKey:@"token"];
}

+(BOOL)checkIsInfoExist:(NSDictionary*)info{
    if(info && ![info[@"data"] isEqual:[NSNull null]]){
        NSString* str = [NSString stringWithFormat:@"%@",info[@"data"]];
        if(![str isEqualToString:@""]){
            return YES;
        }
    }
    return NO;
}



+(NSDictionary *)getUrlParameterWithUrl:(NSURL *)url {
//    NSString *hString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)subUrl, NULL, (CFStringRef)@"!*'();:@&=+ $,./?%#[]", kCFStringEncodingUTF8));
//    NSString *hString = [aString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+ $,./?%#[]"]];
    NSMutableDictionary *parm = [[NSMutableDictionary alloc]init];
    //传入url创建url组件类
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
    //回调遍历所有参数，添加入字典
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [parm setObject:obj.value forKey:obj.name];
    }];
    return parm;
}

+(BOOL)getHasConfirmPrivacy{
     NSString* tmp = [HOETool getUserByKey:@"hasConfrimPrivacy"];
    if(tmp){
        return YES;
    }else{
        return NO;
    }
}

+(void)setHasConfirmPrivacy{
    [HOETool setUser:@"any" forKey:@"hasConfrimPrivacy"];
}

+(NSArray*)getStressSegments{
    return @[@(20),@(40),@(60),@(80)];
}

+(NSString*)getStressDes:(int)stress{
    NSArray* arr = [HOETool getStressSegments];
    NSString* u;
    if(stress <= [arr[0] intValue]){
        u = kJL_TXT("放松");
    }else if(stress > [arr[0] intValue] && stress <= [arr[1] intValue]){
        u = kJL_TXT("正常");
    }else if(stress > [arr[1] intValue] && stress <= [arr[2] intValue]){
        u = kJL_TXT("中等");
    }else{
        u = kJL_TXT("偏高");
    }
    return u;
}

+(NSString*)getStressColor:(int)stress{
    NSArray* arr = [HOETool getStressSegments];
    NSString* u;
    if(stress <= [arr[0] intValue]){
        u = STRESS_VC_RELAX;
    }else if(stress > [arr[0] intValue] && stress <= [arr[1] intValue]){
        u = STRESS_VC_NORMAL;
    }else if(stress > [arr[1] intValue] && stress <= [arr[2] intValue]){
        u = STRESS_VC_MID;
    }else{
        u = STRESS_VC_HIGH;
    }
    return u;
}

+(double)convertUnit:(NSString*)metricSystemName value:(double)value{
    NSDictionary* dic = @{
        kJL_TXT("公里"):@(0.621371192237),
        kJL_TXT("公斤"):@(2.20462262185),
        kJL_TXT("千克"):@(2.20462262185),
    };
    NSString* unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    if([unitStr isEqualToString:@"英制"]){
        if(dic[metricSystemName]){
            return value*[dic[metricSystemName] doubleValue];
        }else{
            return value;
        }
    }else{
        return value;
    }
}

+(NSString*)getUnit:(NSString*)metricSystemName{
    NSDictionary* dic = @{
        kJL_TXT("公里"):kJL_TXT("英里"),
        kJL_TXT("公斤"):kJL_TXT("磅"),
        kJL_TXT("千克"):kJL_TXT("磅"),
    };
    NSString* unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    if([unitStr isEqualToString:@"英制"]){
        return dic[metricSystemName] ? dic[metricSystemName] : metricSystemName;
    }else{
        return metricSystemName;
    }
}

+(NSString*)getPaceInEnglishSystemInDurationPerMile:(double)speedInMeterPerSecond{
    double tmp = speedInMeterPerSecond == 0 ? 0 : 1/(speedInMeterPerSecond/1000.0*0.621371192237);
    int durationPerMile = tmp;
    int min = (int)(durationPerMile / 60);
    int second = (int)(durationPerMile % 60);
    return [NSString stringWithFormat:@"%d'%d\"",min,second];
}

+(NSString*)getPaceInMetricSystemInDurationPerMile:(double)speedInMeterPerSecond{
    double tmp = speedInMeterPerSecond == 0 ? 0 : 1/(speedInMeterPerSecond/1000.0);
    int durationPerMile = tmp;
    int min = (int)(durationPerMile / 60);
    int second = (int)(durationPerMile % 60);
    return [NSString stringWithFormat:@"%d'%d\"",min,second];
}

+(BOOL)isMetricSystem{
    NSString* unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    if([unitStr isEqualToString:@"英制"]){
        return NO;
    }else{
        return YES;
    }
}

+(void)setMetricSystem:(BOOL)isMetric{
    if(isMetric){
        [[NSUserDefaults standardUserDefaults] setValue:@"公制" forKey:@"UNITS_ALERT"];
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:@"英制" forKey:@"UNITS_ALERT"];
    }
}

+(double)getFTemperatureByC:(double)c {
    
    return c * 1.8 + 32;
}


+(NSString*)getTemperatureUnit{
    if([HOETool getUserByKey:@"temperatureUnit"]==nil){
        return @"C";
    }
    return [HOETool getUserByKey:@"temperatureUnit"];
}

+(void)setTemperatureUnit:(NSString*)temperatureUnit{
    [HOETool setUser:temperatureUnit forKey:@"temperatureUnit"];
}

+(NSString*)minuteToHHmm:(int)minute{
    if(minute/60==0){
        return [NSString stringWithFormat:@"%d%@",minute%60,kJL_TXT("分钟")];
    }else if(minute%60==0){
        return [NSString stringWithFormat:@"%d%@",minute/60,kJL_TXT("小时")];
    }else{
        if([kJL_GET hasPrefix:@"zh"]){
            return [NSString stringWithFormat:@"%d%@%d%@",minute/60,kJL_TXT("小时"),minute%60,kJL_TXT("分钟")];
        }else{
            return [NSString stringWithFormat:@"%d%@ %d%@",minute/60,kJL_TXT("小时"),minute%60,kJL_TXT("分钟")];
        }
    }
}

+(NSString*)secondsToHHmmss:(int)seconds{
    int hour = seconds/(60*60);
    int minute = (seconds-hour*60*60)/60;
    int second = seconds%60;
    NSString* hourStr = (hour==0 ? @"": [NSString stringWithFormat:@"%d%@",hour,kJL_TXT("小时")]);
    NSString* minStr = (minute==0 ? @"": [NSString stringWithFormat:@"%d%@",minute,kJL_TXT("分钟")]);
    NSString* secondStr = (second==0 ? @"": [NSString stringWithFormat:@"%d%@",second,kJL_TXT("秒")]);
    if([kJL_GET hasPrefix:@"zh"]){
        return [NSString stringWithFormat:@"%@%@%@",hourStr,minStr,secondStr];
    }else{
        return [NSString stringWithFormat:@"%@ %@ %@",hourStr,minStr,secondStr];
    }
}

// 调用C语言API，不能使用，暂时是废的
+(NSString *)mimeTypeForFileAtPath:(NSString *)path
{
    if (![[[NSFileManager alloc] init] fileExistsAtPath:path]) {
        return nil;
    }
    
//    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
//    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
//    CFRelease(UTI);
//    if (!MIMEType) {
//        return @"application/octet-stream";
//    }
//    return (__bridge NSString *)(MIMEType);
    return nil;
}

  


+(NSArray*)sortStrArrAsc:(NSArray*)arr{
//    NSArray *arr = @[@"2023-09-07",@"2023-09-02",@"2023-10-02",@"2023-10-07",@"UncaughtException",@"2021-10-07",@"2023-10-05"];
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
           NSRange range = NSMakeRange(0,obj1.length);
           return [obj1 compare:obj2 options:comparisonOptions range:range];
       };
       NSArray *resultArray = [arr sortedArrayUsingComparator:sort];
       NSLog(@"字符串数组排序结果(升)%@",resultArray);
    return resultArray;
}

+(NSArray*)sortStrArrDesc:(NSArray*)arr{
//    NSArray *arr = @[@"2023-09-07.log",@"2023-09-02.log",@"2023-10-02.log",@"2023-10-07.log",@"UncaughtException.log",@"2021-10-07.log",@"2023-10-05.log"];
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
           NSRange range = NSMakeRange(0,obj2.length);
           return [obj2 compare:obj1 options:comparisonOptions range:range];
       };
       NSArray *resultArray = [arr sortedArrayUsingComparator:sort];
       NSLog(@"字符串数组排序结果(降)%@",resultArray);
    return resultArray;
}

+(double)getWidthWithString:(NSString*)str font:(UIFont*)font{
    NSDictionary *dict = @{NSFontAttributeName:font};
    CGSize detailSize = [str sizeWithAttributes:dict];
    return detailSize.width;
}

+(CGSize)getSizeWithString:(NSString*)str font:(UIFont*)font{
    NSDictionary *dict = @{NSFontAttributeName:font};
    CGSize detailSize = [str sizeWithAttributes:dict];
    return detailSize;
}


+(double)getBMI:(double)weight{
    double bodyH =[HOETool getHeight]*1.0/100.0;
    return weight*1.0/(bodyH*bodyH);
}

+(NSString*)getBMIDes:(double)bmi{
    if(bmi < 18.5){
        return kJL_TXT("偏瘦");
    }else if(bmi >= 18.5 && bmi < 25){
        return kJL_TXT("正常");
    }else if(bmi >= 25 && bmi < 30){
        return kJL_TXT("过重");
    }else{
        return kJL_TXT("肥胖");
    }
}

+(NSData*)convertHexStrToData:(NSString *)str{
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [NSMutableData new];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

+(NSString*)convertHexStrToStr:(NSString*)hexStr{
    NSData* data = [HOETool convertHexStrToData:hexStr];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+(void)popViewControllerWithClass:(Class)cls navigationController:(UINavigationController*)navigationController{
    int findIndex = -1;
    for(int i=navigationController.viewControllers.count-1;i>=0;i--){
        if([navigationController.viewControllers[i] isMemberOfClass:cls]){
            findIndex = i;
            break;
        }
    }
    if(findIndex > -1){
        NSMutableArray* ctrs = [navigationController.viewControllers mutableCopy];
        [ctrs removeObjectAtIndex:findIndex];
        navigationController.viewControllers = ctrs;
    }
}

+(UIImage*)trimImageInCenter:(UIImage*)scaledImage centerW:(float)centerW centerH:(float)centerH{
    float drawW = 0.0;
    float drawH = 0.0;
    CGSize reSize = CGSizeMake(centerW, centerH);
    CGSize size_new = scaledImage.size;
    if (size_new.width > reSize.width) {
        drawW = (size_new.width - reSize.width)/2.0;
    }
    if (size_new.height > reSize.height) {
        drawH = (size_new.height - reSize.height)/2.0;
    }
    NSLog(@"drawW=====w==%f\n--------drawH==%f\n\n",drawW,drawH);
    //截取截取大小为需要显示的大小。取图片中间位置截取
    CGRect myImageRect = CGRectMake(drawW, drawH, reSize.width, reSize.height);
    UIImage* bigImage= scaledImage;
    scaledImage = nil;
    CGImageRef imageRef = bigImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    UIGraphicsBeginImageContext(reSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    
    return smallImage;
}

+(UIImage *)resizeImage:(UIImage *)image width:(float)width height:(float)height{
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+(NSString*)macWithSplit:(NSString*)macWithoutSplit{
    NSMutableString *result = [NSMutableString stringWithString:[macWithoutSplit lowercaseString]];
    //不确定手表返回的带不带冒号，先统一去掉
    result = [NSMutableString stringWithString:[result stringByReplacingOccurrencesOfString:@":" withString:@""]];
    [result insertString:@":" atIndex:2];
    [result insertString:@":" atIndex:5];
    [result insertString:@":" atIndex:8];
    [result insertString:@":" atIndex:11];
    [result insertString:@":" atIndex:14];
    return result;
}

+ (BOOL)isLogin{
    NSString* token = [HOETool getToken];
    if(token!=nil && token.length > 0){
        return YES;
    }
    return NO;
}

+(BOOL)isUserDeleteWatch{
    return [[HOETool getUserByKey:@"isUserDeleteWatch"] boolValue];
}

+(void)setIsUserDeleteWatch:(BOOL)isUserDeleteWatch{
    [HOETool setUser:[NSNumber numberWithBool:isUserDeleteWatch] forKey:@"isUserDeleteWatch"];
}

+ (void)setAppChannel:(NSString *)channel{
    [[NSUserDefaults standardUserDefaults] setObject:channel forKey:@"appChannelName"];
}
+ (NSString *)appChannelName{
    return  [[NSUserDefaults standardUserDefaults] objectForKey:@"appChannelName"];
}


+ (void)saveAbilityLimit:(NSArray *)abilityLimit{
    [[NSUserDefaults standardUserDefaults] setObject:abilityLimit forKey:@"abilityLimit"];
}

+ (NSArray *)abilityLimits{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"abilityLimit"];
}

+ (BOOL)isSupportAd{
    return [HOETool abilityWithArray:[HOETool abilityLimits] abilityName:@"AD"];
}

+ (BOOL)isSupportAIGC{
    return [HOETool abilityWithArray:[HOETool abilityLimits] abilityName:@"AIGC"];
}

+ (BOOL)isSupportCHATGPT{
    return [HOETool abilityWithArray:[HOETool abilityLimits] abilityName:@"CHATGPT"];
}

+ (BOOL)isSupportTRANS{
    return [HOETool abilityWithArray:[HOETool abilityLimits] abilityName:@"TRANS"];
}

+ (BOOL)abilityWithArray:(NSArray *)abilityLimits abilityName:(NSString *)abilityName{
    if (abilityLimits == nil || abilityLimits.count == 0 || [TSChecker isEmptyString:abilityName]) {
        return NO;
    }
    for (NSDictionary *ability in abilityLimits) {
        NSString *ablity_name = [ability objectForKey:@"ablity_name"];
        if ([ablity_name isEqualToString:abilityName]) {
            BOOL ablity = [ability objectForKey:@"ablity"];
            return ablity;
        }
    }
    return NO;
}


+ (NSString *)deviceUUid{
    NSString *deviceUUid = [[NSUserDefaults standardUserDefaults] objectForKey:@"kDeviceUUid"];
    if (deviceUUid == nil || deviceUUid.length<=0) {
        deviceUUid = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:deviceUUid forKey:@"kDeviceUUid"];
    }
    return deviceUUid;
}


@end
