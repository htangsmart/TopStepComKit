#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSInteger const kTcFeatureLimitErrorCode;  // 81001
extern NSString * const kTcFeatureLimitDefaultMessage;

@interface TcFeatureDecision : NSObject

@property (nonatomic, readonly) BOOL allowed;
@property (nonatomic, readonly) NSInteger code;
@property (nonatomic, readonly, copy) NSString *message;

+ (instancetype)allow;
+ (instancetype)denyWithMessage:(NSString *)message;

- (NSError *)toError;

@end

NS_ASSUME_NONNULL_END
