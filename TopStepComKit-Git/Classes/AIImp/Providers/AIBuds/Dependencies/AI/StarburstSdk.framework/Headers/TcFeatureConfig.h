#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TcFeatureConfig : NSObject

@property (nonatomic, copy) NSString *featureID;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, copy, nullable) NSString *featureDescription;
@property (nonatomic, copy, nullable) NSArray<NSString *> *languageList;

+ (instancetype)configWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
