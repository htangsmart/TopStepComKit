#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TSKitBaseInterface.h>
#import <TopStepInterfaceKit/TSECGMeasurementEvent.h>

NS_ASSUME_NONNULL_BEGIN

/// ECG 专用会话，命令传输由 FitCloud 适配层提供；状态及用户回调串行化到主线程。
@interface TSFitECGMeasurementSession : NSObject
- (instancetype)initWithStartCommand:(void (^)(TSCompletionBlock completion))startCommand
                         stopCommand:(void (^)(TSCompletionBlock completion))stopCommand;
- (void)startWithEventHandler:(TSECGMeasurementEventHandler)eventHandler
                errorHandler:(TSECGMeasurementErrorHandler)errorHandler
                  completion:(TSCompletionBlock)completion;
- (void)stopWithCompletion:(nullable TSCompletionBlock)completion;
- (void)receiveEvent:(TSECGMeasurementEvent *)event;
- (void)receiveError:(NSError *)error;
- (void)disconnect;
@end

NS_ASSUME_NONNULL_END
