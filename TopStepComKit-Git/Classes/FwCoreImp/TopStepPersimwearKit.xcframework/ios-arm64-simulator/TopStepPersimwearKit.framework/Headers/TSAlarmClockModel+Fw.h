//
//  TSAlarmClockModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/11.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

typedef NS_ENUM(NSUInteger, FWAlarmEditType) {
    eFWAlarmEditTypeAdd = 0,
    eFWAlarmEditTypeModify,
    eFWAlarmEditTypeDelete,
};
NS_ASSUME_NONNULL_BEGIN

@interface TSAlarmClockModel (Fw)

+ (NSArray<TSAlarmClockModel *> *)alarmModelsFromFwAlarmDicts:(NSArray<NSDictionary *> *)fwAlarmDicts;


- (BOOL)isEqualToModel:(TSAlarmClockModel *)alarmModel;

-(NSDictionary*)toAddedJson;

-(NSDictionary*)toModifyJson;

-(NSDictionary*)toDeletedJson;

-(NSDictionary*)toAlarmJsonWithType:(FWAlarmEditType)modifyType;

@end

NS_ASSUME_NONNULL_END
