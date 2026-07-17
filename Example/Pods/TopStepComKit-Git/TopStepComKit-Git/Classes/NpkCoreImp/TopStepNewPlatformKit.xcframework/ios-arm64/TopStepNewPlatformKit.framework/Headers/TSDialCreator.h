//
//  TSDialCreator.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/4.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TSDialCreator : NSObject

+ (void)createCustomDial:(TSCustomDial *)dial completion:(void(^)(BOOL isSuccess, NSString *_Nullable resultFilePath, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
