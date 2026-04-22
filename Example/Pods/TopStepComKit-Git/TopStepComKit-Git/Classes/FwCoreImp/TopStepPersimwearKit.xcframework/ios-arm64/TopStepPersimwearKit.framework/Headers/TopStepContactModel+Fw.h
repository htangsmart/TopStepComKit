//
//  TopStepContactModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/7.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TopStepContactModel (Fw)


+ (NSArray <TopStepContactModel *> *)contactsModelArrayWithDictArray:(NSArray *)contactDicts ;

+ (NSArray <TopStepContactModel *> *)emergencyContactsModelArrayWithDictArray:(NSArray *)contactDicts ;


+ (NSArray <NSDictionary *> *)fwDictsWithContactModels:(NSArray <TopStepContactModel *>*)contactModels ;

+ (NSArray <NSDictionary *> *)fwEmergencyDictsWithContactModels:(NSArray <TopStepContactModel *>*)contactModels ;

@end

NS_ASSUME_NONNULL_END
