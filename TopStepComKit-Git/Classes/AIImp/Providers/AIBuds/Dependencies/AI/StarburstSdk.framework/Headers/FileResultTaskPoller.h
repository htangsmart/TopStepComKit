//
//  FileResultTaskPoller.h
//  IOT
//
//  Created by ByteDance on 2026/1/5.
//

#import <Foundation/Foundation.h>
#import <StarburstSdk/ITaskProcessStatusListener.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileResultTaskPoller : NSObject

- (void)addTask:(NSString *)taskId;
- (void)addTask:(NSString *)taskId useSimpleQuery:(BOOL)useSimple;
- (void)cancelTask:(NSString *)taskId;
- (void)setListener:(id<ITaskProcessStatusListener>)listener;
- (void)shutdown;
- (void)removeAll;

@end

NS_ASSUME_NONNULL_END
