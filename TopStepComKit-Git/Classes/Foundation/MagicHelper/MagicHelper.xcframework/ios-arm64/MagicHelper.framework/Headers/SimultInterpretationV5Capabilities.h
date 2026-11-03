//
//  SimultInterpretationV5Capabilities.h
//  MagicHelper
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SimultInterpretationV5SourceLanguage : NSObject
@property (nonatomic, copy, readonly) NSString *locale;
@property (nonatomic, copy, readonly) NSString *name;
@end

@interface SimultInterpretationV5TargetLanguage : NSObject
@property (nonatomic, copy, readonly) NSString *code;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL ttsSupported;
@property (nonatomic, copy, readonly) NSArray<NSString *> *ttsLocales;
@end

@interface SimultInterpretationV5Voice : NSObject
@property (nonatomic, copy, readonly) NSString *voiceId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *localName;
@property (nonatomic, copy, readonly) NSString *language;
@property (nonatomic, copy, readonly) NSString *gender;
@property (nonatomic, copy, readonly) NSString *quality;
@end

@interface SimultInterpretationV5Capabilities : NSObject
@property (nonatomic, copy, readonly) NSString *version;
@property (nonatomic, copy, readonly) NSString *catalogVersion;
@property (nonatomic, copy, readonly) NSArray<SimultInterpretationV5SourceLanguage *> *sourceLanguages;
@property (nonatomic, copy, readonly) NSArray<SimultInterpretationV5TargetLanguage *> *targetLanguages;
@property (nonatomic, copy, readonly) NSArray<SimultInterpretationV5Voice *> *voices;

+ (nullable instancetype)capabilitiesFromResponseDictionary:(NSDictionary *)response;
@end

NS_ASSUME_NONNULL_END
