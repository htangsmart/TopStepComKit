//
//  TSApplicationModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/12/12.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSApplicationModel (Fw)

+ (NSArray<TSApplicationModel *> *)applicationsWithFwAppNames:(NSArray<NSString *> *)fwAppNames ;

+ (TSApplicationModel *)applicationWithName:(NSString *)appName ;

@end

NS_ASSUME_NONNULL_END
