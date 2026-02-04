//
//  TSFwBaseSDKManager.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2026/2/4.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSFwBaseSDKManager : NSObject

@property (nonatomic,assign) BOOL isSDKInited;

+ (instancetype _Nonnull )sharedManager;

- (void)initPersimWearSDK:(NSString *)lincese completion:(TSCompletionBlock)completion ;

@end

NS_ASSUME_NONNULL_END
