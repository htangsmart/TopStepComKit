#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DscrowSdkManager : NSObject

+ (void)setUseProductionEnv:(BOOL)useProd;
- (nullable instancetype)initWithMac:(NSString *)mac
                             channel:(NSString *)channel
                          productId:(NSString *)productId;
- (int)process:(const short *)input output:(short *)output;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
