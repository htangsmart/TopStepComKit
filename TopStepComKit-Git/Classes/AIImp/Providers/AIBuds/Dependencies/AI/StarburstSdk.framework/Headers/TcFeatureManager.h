#import <Foundation/Foundation.h>
#import <StarburstSdk/TcFeatureConfig.h>
#import <StarburstSdk/TcFeatureResponse.h>
#import <StarburstSdk/TcFeatureDecision.h>
#import <StarburstSdk/TcFeatureIds.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TcFeatureRefreshCallback)(NSString * _Nullable tcId,
                                        NSString * _Nullable tcName,
                                        NSArray<TcFeatureConfig *> * _Nullable featureList,
                                        NSError * _Nullable error);

@interface TcFeatureManager : NSObject

+ (instancetype)shared;

/// Fetch feature config from server; callback is optional.
- (void)refreshWithCallback:(nullable TcFeatureRefreshCallback)callback;

/// Check whether a feature is allowed under the current package.
- (TcFeatureDecision *)checkFeature:(NSString *)featureId;

/// Check whether a feature + specific language is allowed.
- (TcFeatureDecision *)checkFeatureLanguage:(NSString *)featureId language:(nullable NSString *)language;

/// Current cached response (nil if never fetched).
- (nullable TcFeatureResponse *)getCached;

/// Current package ID; empty string if unknown.
- (NSString *)currentTcId;

/// Clear in-memory cache (call on disconnect / release).
- (void)invalidateMemoryCache;

@end

NS_ASSUME_NONNULL_END
