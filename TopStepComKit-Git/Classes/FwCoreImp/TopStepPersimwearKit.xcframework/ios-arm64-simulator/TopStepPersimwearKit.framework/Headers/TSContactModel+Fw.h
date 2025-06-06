//
//  TSContactModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/7.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSContactModel (Fw)


+ (NSArray <TSContactModel *> *)contactsModelArrayWithDictArray:(NSArray *)contactDicts ;

+ (NSArray <TSContactModel *> *)emergencyContactsModelArrayWithDictArray:(NSArray *)contactDicts ;


+ (NSArray <NSDictionary *> *)fwDictsWithContactModels:(NSArray <TSContactModel *>*)contactModels ;

+ (NSArray <NSDictionary *> *)fwEmergencyDictsWithContactModels:(NSArray <TSContactModel *>*)contactModels ;

@end

NS_ASSUME_NONNULL_END
