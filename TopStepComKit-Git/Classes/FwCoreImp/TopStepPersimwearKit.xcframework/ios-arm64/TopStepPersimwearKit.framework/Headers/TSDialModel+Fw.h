//
//  TSDialModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSDialModel (Fw)


+ (NSArray<TSDialModel*>*)dialModelsWithFwDialDicts:(NSArray<NSDictionary *> *)fwDials;

+ (TSDialModel*)dialModelWithFwDialDict:(NSDictionary *)fwDial;

@end

NS_ASSUME_NONNULL_END
