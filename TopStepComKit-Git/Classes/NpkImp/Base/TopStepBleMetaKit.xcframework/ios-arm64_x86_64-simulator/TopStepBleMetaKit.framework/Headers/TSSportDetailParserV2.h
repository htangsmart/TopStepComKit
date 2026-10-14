//
//  TSSportDetailParserV2.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>

@class TSMetaSportDetailData;
@class TSMetaSportRecord;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Facade for the V2 sport detail parser. Drop-in replacement for TSSportDetailParser.
 * @chinese V2 运动详情解析器门面类，与旧版接口完全相同，可直接替换。
 *
 * Internally delegates to TSSportFileParser and its registered block parsers.
 * The original TSSportDetailParser is preserved as a fallback and is not modified.
 */
@interface TSSportDetailParserV2 : NSObject

/**
 * Parse sport detail .bin file and save as .pb file.
 * Identical signature to TSSportDetailParser +parseAndSaveFile:withRecord:error:
 */
+ (NSString * _Nullable)parseAndSaveFile:(NSString *)binFilePath
                              withRecord:(TSMetaSportRecord *)record
                                   error:(NSError **)error;

/**
 * Load parsed sport detail data from .pb file.
 * Identical signature to TSSportDetailParser +loadFromFile:error:
 */
+ (TSMetaSportDetailData * _Nullable)loadFromFile:(NSString *)pbFilePath
                                            error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
