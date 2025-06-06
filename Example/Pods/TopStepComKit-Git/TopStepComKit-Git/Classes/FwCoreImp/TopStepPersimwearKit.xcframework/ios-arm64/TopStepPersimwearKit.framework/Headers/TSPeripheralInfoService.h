//
//  TSPeripheralInfoService.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPeripheralInfoService : NSObject

- (void)requestFwPeripheralInfoCompletion:(void (^)(NSDictionary*jsonMsg, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
