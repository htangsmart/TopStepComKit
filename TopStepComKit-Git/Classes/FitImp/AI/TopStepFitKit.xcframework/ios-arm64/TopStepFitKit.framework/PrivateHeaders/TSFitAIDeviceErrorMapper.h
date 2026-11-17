#import <Foundation/Foundation.h>
#import <FitCloudKit/FitCloudKitDefines.h>
#import <TopStepAIKit/TSAIContractDefines.h>

NS_ASSUME_NONNULL_BEGIN
/// 将 Fit 平台错误归一化；原始错误仅用于诊断，不改变会话确定性判断。
@interface TSFitAIDeviceErrorMapper : NSObject
+ (NSError *)errorWithCode:(TSAIErrorCode)code description:(NSString *)description
           underlyingError:(nullable NSError *)underlyingError
         requestIdentifier:(nullable NSString *)requestIdentifier
                   useCase:(NSUInteger)useCase phase:(NSString *)phase;
+ (NSError *)startFailureWithReason:(FitCloudAIDeviceSideStartFailureReason)reason
                              error:(nullable NSError *)error
                  requestIdentifier:(nullable NSString *)requestIdentifier
                            useCase:(NSUInteger)useCase;
+ (NSError *)interruptionWithReason:(FitCloudAIDeviceInterruptionReason)reason
                  requestIdentifier:(nullable NSString *)requestIdentifier
                            useCase:(NSUInteger)useCase;
@end
NS_ASSUME_NONNULL_END
