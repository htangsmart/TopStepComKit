//
//  TSNpkDialStyleConstraintMapper.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSNpkDialStyleResource;

NS_ASSUME_NONNULL_BEGIN

/** @brief Maps NPK cloud metadata to the public constraint @chinese 将 NPK 云元数据转换为公开约束 */
@interface TSNpkDialStyleConstraintMapper : NSObject

- (nullable TSCustomDialStyleConstraint *)constraintFromResource:(TSNpkDialStyleResource *)resource
                                                           screen:(TSPeripheralScreen *)screen
                                                            error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
