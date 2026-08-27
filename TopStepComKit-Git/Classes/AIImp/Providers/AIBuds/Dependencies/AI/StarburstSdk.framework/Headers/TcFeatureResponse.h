#import <Foundation/Foundation.h>
#import <StarburstSdk/TcFeatureConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface TcFeatureResponse : NSObject

@property (nonatomic, copy) NSString *tcID;
@property (nonatomic, copy) NSString *tcName;
@property (nonatomic, copy, nullable) NSArray<TcFeatureConfig *> *featureList;

+ (nullable instancetype)responseWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
