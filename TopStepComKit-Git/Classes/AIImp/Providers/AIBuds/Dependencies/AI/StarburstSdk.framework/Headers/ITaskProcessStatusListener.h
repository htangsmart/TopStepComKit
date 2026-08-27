//
//  ITaskProcessStatusListener.h
//  IOT
//
//  Created by ByteDance on 2026/1/5.
//

#import <Foundation/Foundation.h>
@class FileTaskResult;

NS_ASSUME_NONNULL_BEGIN

@protocol ITaskProcessStatusListener <NSObject>
- (void)onProcessing:(NSString *)taskId code:(NSInteger)code;
- (void)onSuccess:(NSString *)taskId result:(FileTaskResult *)result;
- (void)onFailure:(NSString *)taskId message:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
