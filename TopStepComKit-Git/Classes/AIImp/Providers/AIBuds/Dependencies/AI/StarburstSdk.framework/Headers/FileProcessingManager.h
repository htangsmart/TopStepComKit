//
//  FileProcessingManager.h
//  IOT
//
//  Created by ByteDance on 2025/12/24.
//

#import <Foundation/Foundation.h>
#import <StarburstSdk/ITaskProcessStatusListener.h>

NS_ASSUME_NONNULL_BEGIN


@protocol IFileTaskCreatedCallback <NSObject>
- (void)onTaskCreated:(NSString *)taskId;
- (void)onError:(NSInteger)code message:(NSString *)message;
@end

@interface FileProcessingManager : NSObject

+ (instancetype)shared;

- (void)createFileAsrTask:(NSURL *)fileURL
                language:(NSString *)language
                 summary:(BOOL)summary
           speakerSplit:(BOOL)speakerSplit
             sampleRate:(int)sampleRate
                 format:(NSString *)format
                  codec:(NSString *)codec
              callback:(id<IFileTaskCreatedCallback>)callback;

- (void)createTextSummaryTask:(NSString *)text
                     language:(NSString *)language
                     callback:(id<IFileTaskCreatedCallback>)callback;

- (void)addQueryTaskId:(NSString *)taskId;
- (void)cancelQueryTaskId:(NSString *)taskId;
- (void)setTaskProcessStatusListener:(id<ITaskProcessStatusListener>)listener;
- (void)removeAllQueryTask;

@end

NS_ASSUME_NONNULL_END
