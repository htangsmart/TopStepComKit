//
//  TSBusinessBase.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/8/17.
//

#import "TSMetaBase.h"
#import "TSCommand.h"
#import "TSCommandDefines.h"
#import <TopStepToolKit/TopStepToolKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TSBusinessBase : TSMetaBase


+ (void)handleComonRespondWithResult:(BOOL)isSuccess
                             respond:(NSData *)respondData
                               error:(NSError *)error
                              domain:(NSString *)errorDomain
                          completion:(TSMetaCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
