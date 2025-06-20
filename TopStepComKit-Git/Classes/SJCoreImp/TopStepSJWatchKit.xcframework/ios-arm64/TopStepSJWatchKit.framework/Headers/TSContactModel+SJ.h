//
//  TSContactModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/2/26.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMEmergencyContactModel;
@class WMContactModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSContactModel (SJ)


+ (nullable TSContactModel *)modelWithWMEmergencyContact:(nullable WMEmergencyContactModel *)wmObject ;

+ (nullable NSArray<TSContactModel *> *)modelsWithWMEmergencyContacts:(nullable NSArray<WMEmergencyContactModel *> *)wmObjects ;

+ (nullable TSContactModel *)modelWithWMContact:(nullable WMContactModel *)wmObject ;

+ (nullable NSArray<TSContactModel *> *)modelsWithWMContacts:(nullable NSArray<WMContactModel *> *)wmObjects ;

+ (nullable WMEmergencyContactModel *)wmEmergencyContactWithModel:(TSContactModel *)model ;

+ (nullable NSArray<WMEmergencyContactModel *> *)wmEmergencyContactsWithModels:(NSArray<TSContactModel *> *)models ;

+ (nullable WMContactModel *)wmContactWithModel:(nullable TSContactModel *)model ;

+ (nullable NSArray<WMContactModel *> *)wmContactsWithModels:(nullable NSArray<TSContactModel *> *)models ;


@end

NS_ASSUME_NONNULL_END
