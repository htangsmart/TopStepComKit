//
//  TSMessageModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/11.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSMessageModel (Fw)

+ (NSDictionary *)messageValuesFromModels:(NSArray<TSMessageModel *> *)messageModels;

+ (TSMessageModel *)messageModelsFromFwDicts:(NSDictionary *)messageDicts;

@end

NS_ASSUME_NONNULL_END
