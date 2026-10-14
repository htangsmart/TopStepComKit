//
//  TSMessageAbility+NPK.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/11/5.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSMessageAbility (NPK)

+ (NSIndexSet *)convertNotificationFlagsToMessageTypes:(NSData *)flagsData ;

@end

NS_ASSUME_NONNULL_END
